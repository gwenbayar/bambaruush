# Modular Mini-Games, SRS Review & Long-Run Architecture — Design Spec

**Date**: 2026-06-02
**Status**: Approved for implementation (Slice 1 = demo, builds now; Slices 2+ = designed roadmap)
**Related**: `docs/superpowers/specs/2026-05-27-bambaruush-v1-design.md` (v1), `docs/game_ideas.md` (long-run vision)

## 1. Purpose & framing

Two goals at once:

1. **Demo due 2026-06-03 (tomorrow):** fix the "My Family" lesson (it currently forces a letter Intro+Trace) and lay the modular foundation the long-run needs — without jeopardizing the demo. **This is Slice 1 and is the only thing built now.**
2. **Long-run readiness:** the app must grow into "lots of mini-games" with composable characters, a rich language-agnostic content taxonomy, and an SRS-driven review tool. This spec captures that architecture so today's refactor doesn't have to be torn up later.

The core architectural move (Approach 1, chosen): **extract the mini-games from the lesson flow into a reusable Activity/Session framework.** Lessons and the future review tool become two *consumers* of one activity library. New game = new Activity. New mode = new Session. New content type = new Concept.

## 2. Long-run vision (from `docs/game_ideas.md`) and how this architecture absorbs it

The long-run doc points at three pillars beyond "words + 3 games":

| Long-run pillar | Architectural home | Built now? |
|---|---|---|
| Rich, language-agnostic content taxonomy (nouns, verbs/actions, colors, places, characters, items), "dictionary maps to English → any language" | **Concept model** + localization-ready content schema (§5) | No — documented seam (§9) |
| Fixed-proportion characters with slots (worn/held) and actions (walk/run/jump/eat) | **Character composition / rig layer** that *feeds* activities (§9) | No — largest future subsystem |
| Many varied mini-games (match-to-character, dress-up, walk-to-place, match-action-to-verb) | New **`ActivitySpec` + `ActivityView`** types; the core is deliberately NOT limited to "tap one of N tiles" | No — each is a future Activity |

**Key principle:** `ActivitySpec` is an open sealed hierarchy. Tile-picking (Listen/Read) is *one* shape. Dress-up, walk-to-place, etc. define their own specs/views and never inherit tile-picking assumptions. The `Session`/`SessionRunner` core sequences and grades arbitrary activities; it does not know game internals.

## 3. Architecture overview

Three independently-testable layers; data flows one way.

```
 SOURCE                SESSION                  RUNNER + VIEWS              DOMAIN
 ──────                ───────                  ──────────────             ──────
 Lesson  ─┐                                   ┌─ SessionRunner ─┐
          ├─► Session.buildSequence() ───────►│  (steps, retry) │──► ActivityView ─► game widget
 SRS due ─┘     → List<ActivitySpec>          └─ onComplete ────┘          │
 (later)                                            │                      ▼
                                                    └──► LeitnerEngine ◄── ActivityResult
                                                         (per ReviewItem)
```

- **Domain** — `ItemRef` (a Concept reference: type + id), generalized `SrsBox`, `LeitnerEngine`.
- **Activities** — `ActivitySpec` (data for one round), `ActivityView` (renders any spec, reports an `ActivityResult`), with distractors supplied *by the session*, not computed inside the widget.
- **Sessions** — `Session` builds an ordered `List<ActivitySpec>` from a source and defines completion (`onComplete`: SRS updates, rewards, unlocks). `LessonSession` and (later) `ReviewSession` implement it. One shared `SessionRunner` drives both, including the attempt-1→attempt-2 retry logic.

## 4. Activity library

The current `LessonStage` sealed type becomes `ActivitySpec`; the four stage widgets become `ActivityView`s with **no `Lesson` dependency**.

```dart
sealed class ActivitySpec { ItemRef get item; }

class IntroSpec  extends ActivitySpec { final String letterId; }                       // presentational
class TraceSpec  extends ActivitySpec { final String letterId; final int attempt; }    // graded (letter)
class ListenSpec extends ActivitySpec { final String wordId; final List<String> distractorIds; final int attempt; }
class ReadSpec   extends ActivitySpec { final String wordId; final List<String> distractorIds; final int attempt; }
class RewardSpec extends ActivitySpec { final String stickerId; }                      // presentational

class ActivityResult { final ItemRef item; final bool firstAttemptCorrect; }
```

Capability map (self-describing; drives future review game-picking):

```dart
enum ActivityKind { intro, trace, listen, read, reward }
const gradedActivitiesFor = {
  ReviewItemType.word:   [ActivityKind.listen, ActivityKind.read],
  ReviewItemType.letter: [ActivityKind.trace], // + future letter-recognition game
};
```

`ActivityView(spec, onResult)` is the single switch (today's `_stageWidget`), delegating to `IntroActivity`/`TraceActivity`/`ListenActivity`/`ReadActivity`/`RewardView`. Mascot reactions, haptics, and confetti stay inside the views. **Adding a game = a spec + a view + (if graded) one `gradedActivitiesFor` entry.**

## 5. Domain model — `ItemRef` and the Concept taxonomy

```dart
// Open taxonomy: today {word, letter}; grows to noun/verb/color/place/character/item…
enum ReviewItemType { word, letter }

@freezed
class ItemRef with _$ItemRef {
  const factory ItemRef({ required ReviewItemType type, required String id }) = _ItemRef;
  // map key: "${type.name}:$id"  →  "word:word_aav", "letter:letter_a"
}
```

**Target content model (Concept dictionary, localization-ready — Slice 5, not now):** each concept is a neutral `key` + `category` + a `localizations` map, implementing game_ideas line 13 ("dictionary maps to English → any language"):

```jsonc
{
  "key": "father", "category": "noun",
  "localizations": { "mn": {"text": "Аав", "audio": "..."}, "en": {"text": "father"} },
  "asset": { "image": "..." }   // future: rig ref, slots, actions
}
```

Today's `Word{cyrillic, english, audio, image}` and `Letter{cyrillic, romanization, audio, traceMask}` are already Concepts (categories noun/letter, mn+en localizations). The localization-ready migration is **Slice 2** (right after the demo, while content is ~3 lessons and cheap to migrate); **the demo keeps `Word`/`Letter`.**

**Localization: what's cheap vs. what's costly (be honest about this).** Separating language is genuinely *plug-and-play for vocabulary*: a word splits into shared parts (`key`, `image`, `category`) and per-language parts (`text`, `audio`) behind the `localizations` map + an `activeLanguage` selector. Code reads `word.text(lang)`. Adding a vocabulary language later is then "same images, supply that language's text + audio." The real costs of "language agnostic" live elsewhere and are independent of *when* we separate:

- **Audio is per-language content production, not code** — every word/letter needs a recording per language. This dominates.
- **The alphabet + tracing track is per-language/script** — Mongolian Cyrillic ≠ Latin ≠ Arabic: per-language letter sets, per-script fonts, per-letter stroke templates, and RTL for some scripts. Vocabulary games port for free; letter/trace games are rebuilt per script. So "language agnostic" precisely means *vocabulary-agnostic + a per-language alphabet track*.
- **Avoid over-building:** do the schema separation + accessor now; add script-specific plumbing (RTL, new fonts, stroke templates) only when a real second language is on the table.

## 6. Sessions + the shared `SessionRunner`

```dart
abstract class Session {
  String get title;
  List<ActivitySpec> buildSequence();
  Future<SessionOutcome> onComplete(SessionResult result, Ref ref);
}
```

- **`SessionResult`** — per-`ItemRef` first-attempt correctness (today's `wordCorrectness`, generalized).
- **`SessionOutcome`** — end-screen payload (sticker earned, next unlocked, daily star…).
- **`SessionRunner`** (renamed `LessonRunner`) — `StateNotifier` holding the sequence, current index/spec, the shared attempt-1→attempt-2 retry, accumulating `SessionResult`; calls `session.onComplete` on finish. The runner *screen* is generic.

**`LessonSession(lesson)`** — `buildSequence`: if `lesson.kind == letter` → per letter `IntroSpec`+`TraceSpec`, then per word `ListenSpec`, then per word `ReadSpec`, then `RewardSpec`; if `kind == vocabulary` → words + reward only (**the My Family fix as a first-class config**). Distractors computed here via `pickDistractors`. `onComplete`: update word SRS, mark complete, unlock next, award sticker. (Letter SRS seeding arrives in Slice 3.)

**`ReviewSession(dueItems, {isWarmup})`** *(Slice 4)* — `buildSequence`: per due `ItemRef`, pick a compatible graded activity (`word`→Listen|Read varied; `letter`→Trace), distractors from the learned pool, capped at ~8; append `RewardSpec` only if warm-up. `onComplete`: update SRS per reviewed item; if warm-up, award daily sticker + stamp `lastWarmupAt`.

Runner + views are shared; only these two small classes differ.

## 7. Review subsystem — queue, entry points, warm-up *(Slices 4–5, designed, not in demo)*

- **`reviewQueueProvider`** — reads SRS + content, returns due `ItemRef`s sorted most-overdue-first, filtered to items that still exist and have a compatible game, capped to session size.
- **Practice landmark** on the Steppe map — image-anchored marker (campfire/owl) with a due-count badge → `/review`. If nothing due: light "free practice" of recently-learned items, or "All caught up! ⭐".
- **Optional daily warm-up** — after splash, if items are due and `lastWarmupAt` isn't today, route to `/warmup`: mascot offers *"Warm up and earn a sticker?"* (Yes / Skip — never forced). Yes → `/review?warmup=1` → completion awards a daily sticker + celebration + stamps `lastWarmupAt`. Skip → `/steppe`. Once per day.
- **Reward model:** warm-up grants a rotating daily sticker; ordinary practice gives encouragement (mascot + stars) but not lesson stickers, keeping the album meaningful.

## 8. Persistence + migration *(Slice 3)*

`Progress`: `srsByWord` → `srsByItem` (`Map<String,SrsBox>` keyed `"type:id"`); add `DateTime? lastWarmupAt`. `SrsBox`: `wordId` → `itemId` + `itemType`. Bump `schemaVersion` 1 → 2; on mismatch the repo already falls back to a fresh start — acceptable (no real users yet). Optional one-time migration (`srsByWord` → `srsByItem` as `word:`) is noted but not required.

## 9. Future seams (explicitly NOT built now)

- **Concept/localization content model (§5)** — unifies words/letters/verbs/colors/places into one localized dictionary. **Slice 2, right after the demo** (cheap while content is tiny).
- **Character composition / rig layer** — fixed-proportion characters, slot definitions (worn/held + correct placement), action set (walk/run/jump/eat). A content+render subsystem that *produces* the items future activities consume. Plugs in as new `ReviewItemType`s (character/item/action) + a rig renderer; the Activity/Session core is unchanged.
- **Advanced games** — match-picture-to-character (with walk/run), dress-up, walk-to-place, match-action-to-verb. Each = a new `ActivitySpec` + `ActivityView`; sourced by either a Lesson or a ReviewSession exactly like today's games.

These are real and intended; capturing them here ensures the Slice-1 boundaries (open `ActivitySpec`, generic `ItemRef`, source-agnostic Session) don't block them.

## 10. Module structure (target)

```
lib/domain/review_item.dart            ItemRef, ReviewItemType          (pure)
lib/core/srs/leitner_engine.dart       generalized + dueItems()         (Slice 2)
lib/features/activities/                activity_spec.dart, activity_view.dart, intro/trace/listen/read/reward, distractors.dart
lib/features/session/                  session.dart, session_runner.dart (+ screen), lesson_session.dart, review_session.dart (Slice 3), review_queue.dart (Slice 3)
lib/features/review/                   practice landmark, warmup_prompt_screen.dart (Slices 3–4)
```

For Slice 1, introducing the abstractions is required; a full directory move is desirable but may stay within `features/lesson/` if it reduces risk before the demo — the implementation plan decides the safest path.

## 11. Testing (logic is pure → cheap)

- `LessonSession.buildSequence` — **vocabulary vs letter shapes** (locks in the My Family fix). *(Slice 1)*
- `SessionRunner` — sequence stepping + retry (ported from current `lesson_runner_test`). *(Slice 1)*
- `word.text(lang)` accessor + content load with `localizations` (Slice 2).
- `LeitnerEngine` incl. letter items + `dueItems` ordering/filtering (Slice 3).
- `pickActivityForItem` mapping + determinism (Slice 4).
- `ReviewSession.buildSequence` — due items → correct games, cap, warm-up reward (Slice 4).
- `onComplete` — SRS updates per item, letter seeding, unlock, warm-up stamp.
- Existing content/persistence/distractor tests updated for the generalized types.

## 12. Build order

| Slice | Scope | When |
|---|---|---|
| **1** | **Decouple games → Activity/Session/SessionRunner; add `Lesson.kind`; My Family becomes vocabulary-only; move distractors into the session; fix the tile avatar for vocab lessons. No new visible feature; identical UX except My Family has no А Intro/Trace.** | **NOW (demo)** |
| 2 | **Localization-ready content model:** split per-language `text`/`audio` into a `localizations` map + `activeLanguage` selector; code reads `word.text(lang)`. Done while content is tiny. Vocabulary becomes plug-and-play across languages; alphabet/audio caveats per §5. | Next (right after demo) |
| 3 | Generalize SRS to items: `abstract interface class Item` + `ItemType` enum (Word/Letter implement it); `srsByItem` keyed `"type:id"`; letters get SRS via the Trace signal (`SessionRunner.itemCorrectness`); track-everything; schemaVersion bump. See `docs/superpowers/specs/2026-06-03-srs-items-design.md`. | After Slice 2 |
| 4 | `ReviewSession` + `reviewQueueProvider` + Practice landmark (`/review`, due badge). | After Slice 3 |
| 5 | Optional daily warm-up (`/warmup`, once/day, reward) + `lastWarmupAt` on `Progress`. | After Slice 4 |
| 6 | Character rig (slots/actions) + advanced games (dress-up, walk-to-place, match-to-character). | Long-run |
| 7 | **Item sub-categories** — `LetterCategory{vowel, consonant}` on `Letter`, word groups/themes on `Word` (enum fields on the subtypes). Deferred from Slice 3; build when an activity/review uses them. | Feature-driven |

## 13. Demo scope (Slice 1) — exact changes built now

1. **`Lesson.kind`** — add `enum LessonKind { vocabulary, letter }` to the `Lesson` model (default `letter` for back-compat); set it in `content.json` (`lesson_family` = `vocabulary` with `letterIds: []`; `lesson_a`, `lesson_b` = `letter`). A vocabulary lesson carries no `letterIds`.
2. **Extract `ActivitySpec`** from the sealed `LessonStage` (Intro/Trace/Listen/Read/Reward specs); `ActivityResult`.
3. **`Session` + `LessonSession`** — `LessonSession.buildSequence()` honors `kind`: `vocabulary` emits no Intro/Trace. Distractor computation moves out of the widgets into the session via the existing `pickDistractors`.
4. **Rename `LessonRunner` → `SessionRunner`**, driving `List<ActivitySpec>`; keep the attempt-1/attempt-2 retry and per-item correctness (`SessionResult`). `onComplete` keeps today's word-SRS update + unlock + sticker.
5. **`ActivityView`** — the game widgets lose their `Lesson` dependency; distractors arrive via the spec.
6. **Region tile avatar** — must not assume a letter. For `letter` lessons show the first letter's cyrillic glyph (as today); for `vocabulary` lessons (empty `letterIds`) show the lesson's reward sticker (or first word) image as a rounded thumbnail. This both avoids the `letterIds.first` crash and stops "А" from mislabeling the My Family card.
7. **Tests** — port `lesson_runner_test` → `session_runner_test`; add `LessonSession.buildSequence` tests asserting vocabulary lessons produce **no** Intro/Trace and letter lessons do.

**Out of demo scope (this slice):** SRS generalization, letter-SRS seeding, review queue/session, entry points, warm-up, Concept model, rig — all designed above, built in later slices.
