# Slice 3 — Generalize SRS to Items (words + letters) — Design Spec

**Date**: 2026-06-03
**Status**: Approved for implementation
**Parent spec**: `docs/superpowers/specs/2026-06-02-modular-games-and-review-design.md` (Slice 3 of its build order)
**Branch**: `slice-3-srs-items` (stacked on `slice-2-localization` until earlier slices merge)

## 1. Purpose

Make the spaced-repetition system track **both words and letters** (today it's `Progress.srsByWord` — words only, keyed by `wordId`). Introduce a polymorphic `Item` supertype + an `ItemType` discriminator, key the SRS by item, and give letters a real recall signal from the Trace activity. This is the groundwork the **ReviewSession** (Slice 4) consumes — it has no user-visible behavior change yet (lessons play identically; the SRS just records more).

## 2. Locked decisions

1. **`abstract interface class Item` + `ItemType` enum** (not a `sealed` class). `Word`/`Letter` each `implements Item` and stay in their own files. Exhaustiveness comes from `switch (item.type)` over the enum; sealed's only extra (auto smart-cast) wasn't worth collapsing the per-model file layout (freezed `part` files can't be nested under a shared library).
2. **SRS entry policy: track everything** (classic Leitner). Every practiced item gets a box — keep today's `_persistCompletion` behavior, now extended to letters. (Not the failure-only model.)
3. **Letter signal = Trace first-attempt correctness**; words = Listen/Read first-attempt. `SessionRunner` generalizes `wordCorrectness` → `itemCorrectness`.
4. **Schema change is a clean fresh-start** on version mismatch (no real users yet) — no data migration.
5. **Deferred, documented, assigned:**
   - **Sub-groupings** — `LetterCategory{vowel, consonant}` on `Letter`, word groups/themes on `Word` → **Slice 7 (Item sub-categories)**, built when an activity/review needs them. Added to the parent build order.
   - **`lastWarmupAt`** field on `Progress` → **Slice 5 (warm-up)**, where it's used (YAGNI here).

## 3. Type design

Solid = built in Slice 3. Dotted `future · Slice 7` = deferred sub-groupings, shown so the attachment points are explicit.

```mermaid
classDiagram
    direction LR

    class ItemType {
        <<enumeration>>
        word
        letter
    }

    class Item {
        <<interface>>
        +String id
        +ItemType type
    }

    class Word {
        +String id
        +String imageAssetPath
        +List~String~ letterIds
        +Map~String,WordLocalization~ localizations
        +ItemType type
        +String text(String lang)
        +String~nullable~ audioPath(String lang)
    }

    class Letter {
        +String id
        +String cyrillic
        +String romanization
        +String audioAssetPath
        +String traceTemplatePath
        +ItemType type
    }

    class WordLocalization {
        +String text
        +String~nullable~ audioAssetPath
    }

    class SrsBox {
        +String itemId
        +ItemType itemType
        +int level
        +DateTime nextReviewAt
        +int correctStreak
    }

    class LeitnerEngine {
        <<service>>
        +initial(String id, ItemType type, DateTime now) SrsBox
        +onCorrect(SrsBox box, DateTime now) SrsBox
        +onWrong(SrsBox box, DateTime now) SrsBox
        +isDue(SrsBox box, DateTime now) bool
        +dueItems(Map srsByItem, DateTime now) List~SrsBox~
    }

    class Progress {
        +Map~String,SrsBox~ srsByItem
        +Map~String,LessonProgress~ lessons
        +Set~String~ earnedStickerIds
        +int schemaVersion
        +DateTime lastPlayed
    }

    class SessionRunnerState {
        +ActivitySpec current
        +int totalSteps
        +int currentStep
        +Map~String,bool~ itemCorrectness
    }

    class LetterCategory {
        <<enumeration>>
        vowel
        consonant
    }
    class WordGroup {
        <<enumeration>>
        tbd
    }

    Item <|.. Word : implements
    Item <|.. Letter : implements
    Item ..> ItemType : type
    Word *-- "1..*" WordLocalization : localizations
    SrsBox ..> ItemType
    Progress *-- "0..*" SrsBox : srsByItem (key "type:id")
    LeitnerEngine ..> SrsBox : operates on
    SessionRunnerState ..> Item : itemCorrectness keyed "type:id"
    Letter ..> LetterCategory : category (future · Slice 7)
    Word ..> WordGroup : group (future · Slice 7)
```

### Notes
- **`Item`** is the polymorphic parent; `Word`/`Letter` `implements` it (supplying `id` + `type`). Each keeps its own distinct fields and file.
- **`ItemType`** is the discriminator for SRS keys, the activity capability map (`{word:[listen,read], letter:[trace]}`), and `switch (item.type)` branching.
- **SRS key scheme:** `"${item.type.name}:${item.id}"` → `"word:word_aav"`, `"letter:letter_a"`. A single helper builds this key so the runner's `itemCorrectness`, `Progress.srsByItem`, and `_persistCompletion` all agree.
- **`LetterCategory` / `WordGroup`** are not built now — they mark where Slice 7 attaches (fields on `Letter`/`Word`). `WordGroup` members are TBD when that slice lands.

## 4. SRS engine + persistence

- **`SrsBox`**: `wordId` → `itemId` + `itemType: ItemType`.
- **`LeitnerEngine`**: `initial`/`onCorrect`/`onWrong`/`isDue` operate on `SrsBox` (unchanged spacing); add `dueItems(Map<String,SrsBox> srsByItem, DateTime now) → List<SrsBox>` returning the boxes where `isDue` (each box carries its `itemType`+`itemId` so callers can resolve). Pure, fully unit-testable.
- **`Progress`**: `srsByWord` → `srsByItem` (`Map<String,SrsBox>` keyed by the `"type:id"` scheme). Bump `schemaVersion`. `ProgressRepository.load` already returns `Progress.empty()` on schema mismatch → existing progress files reset cleanly. No migration code.

## 5. Capturing correctness for letters

- `SessionRunner` currently tracks `wordCorrectness: Map<String,bool>` from Listen/Read specs. Generalize to **`itemCorrectness: Map<String,bool>`** keyed by the `"type:id"` scheme, recording first-attempt correctness for **Trace** (letters) as well as Listen/Read (words). `IntroSpec`/`RewardSpec` are presentational (no signal).
- `_persistCompletion` (in `lesson_runner_screen.dart`) iterates the lesson's **words AND letters**, reads correctness from `itemCorrectness`, and updates `srsByItem` via `LeitnerEngine` (create box if absent → track-everything). Sticker/unlock logic unchanged. SRS is language-agnostic (keyed by id), so it composes cleanly with Slice 2's localization.

## 6. Testing

- **`Item` conformance:** `Word(...).type == ItemType.word`, `Letter(...).type == ItemType.letter`; both usable as `Item`.
- **`LeitnerEngine`:** existing tests updated for `itemId`/`itemType`; new `dueItems` test (returns only due boxes; ordering/contents).
- **`SessionRunner.itemCorrectness`:** a letter lesson (Intro+Trace+Listen+Read) records correctness for both the letter (Trace) and the words; a Trace fail marks the letter incorrect.
- **`_persistCompletion`** (or its extracted helper): given an `itemCorrectness` map, produces the right `srsByItem` updates for words + letters (box created/promoted/demoted).
- **`Progress`:** `srsByItem` round-trips through `ProgressRepository`; schema-bump → fresh-start path still green.
- Existing content/persistence/distractor/session tests updated for the renames.

## 7. Out of scope

- **Slice 4:** `reviewQueueProvider` (consumes `dueItems`), `ReviewSession`, the Practice landmark + `/review`.
- **Slice 5:** daily warm-up + `lastWarmupAt`.
- **Slice 7:** `LetterCategory`/`WordGroup` sub-categories.
- No user-visible behavior change in this slice — lessons play identically; only the SRS records more (words + letters).
