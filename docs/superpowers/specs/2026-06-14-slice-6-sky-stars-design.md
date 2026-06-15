# Slice 6 — The Sky (Sky-Stars + Doloon Burhan) — Design Spec

**Date**: 2026-06-14
**Status**: Approved for implementation
**Parent spec**: `docs/superpowers/specs/2026-06-02-modular-games-and-review-design.md` (§7 Track B sky-stars; this slice realizes it)
**Builds on**: Slices 3–5 — per-item SRS (`SrsBox.level`, `LeitnerEngine`), `applySessionToSrs`, the lesson/review/warm-up completion paths, schema-versioned `Progress` fresh-start.
**Story Guide**: §7 (Track B — Sky-stars; currency invariant), §8 (Learning & mastery; Kindness; Cultural & safety).
**Branch**: `slice-6-sky-stars` (off `main`)

## 1. Purpose

Make the app's central promise real: **every word (and letter) Od truly *masters* becomes a permanent star in Od's night sky.** This is the emotional engine of the whole app (the opening scene: *"Every word you learn, I'll hang up here as a star… so I'll always know how much you've grown"*) and the **#1 divergence** between the shipped app and the Story Guide — today there is no sky-star track at all, and the word "star" is mis-used for lesson-completion checkmarks (§7 reserves "star" for the sky).

This slice builds **Track B (Sky-stars)** from §7: a mastery-earned, **never-spent, permanent** record of learning, with a viewable **Sky** screen. It also delivers the first constellation — **Долоон бурхан / The Big Dipper** — as a concrete first goal that, when completed, plays a small celebration with a culture-pride trivia card and an animated picture of the shape it resembles.

It does **not** touch the spendable economy (Odon), the shop, or stickers — those are the next slice. Sky-stars and Odon are deliberately separate tracks (§7 currency invariant); this slice ships only the permanent one.

## 2. Locked decisions

1. **Mastery threshold = Leitner `level ≥ 3`.** An item earns its star once it has been recalled correctly across a few spaced sessions (survived the day-1 and day-3 reviews). Matches §8 ("mastery, not a single tap") and the "days, not weeks" pacing target. Not a single correct tap; not the full level-5 ladder.
2. **Permanent once lit.** A star, once earned, **stays in the sky forever** — it is never removed, even if the item's SRS level later drops below 3. The SRS still resurfaces the word for practice; the star is an honest record that "you learned this." This **deliberately overrides** the §8 line *"a word can drop mastered → practiced … and re-earn its star."* The **kindness invariant** (no loss, no failure states) wins — a star vanishing from a 5-year-old's sky reads as punishment. **Action:** update that Story Guide §8 line so canon doesn't drift silently (see §10).
3. **Words *and* letters earn stars.** The sky = everything Od has truly learned. The SRS already masters both `ItemType.word` and `ItemType.letter`; both contribute stars.
4. **Doloon Burhan is the first constellation.** The first 7 earned stars fill the Big Dipper's 7 slots in placement order; star #8+ scatter as ambient background stars. Completing it fires a one-time celebration. Further constellations + the **Altan Gadas** endgame are deferred.
5. **English names are the real English astronomical names; Mongolian names stay faithful Cyrillic; meaning/lore lives only in trivia, never as the display label.** So `nameEn: "The Big Dipper"` (not a translation of the Mongolian), `nameMn: "Долоон бурхан"`. The "seven gods" meaning and the **Шанага Долоо** (Ladle Seven) folk name are trivia.
6. **Each constellation carries a `shapeImage` + `trivia`**, shown together in the completion celebration — pride, never a lecture (§8 cultural rule). The `shapeImage` animates in over the connected stars to reveal what the shape resembles (a ladle), so a pre-reader *sees* the resemblance.
7. **Schema bump 3 → 4, fresh-start on mismatch** (no real users; same as prior slices).
8. **Map "star" cleanup.** Region-tile lesson-completion markers stop using the ⭐ icon (a `star` meaning that collides with §7) and switch to a non-star "done" marker. After this slice, *star* means *sky-star* only.

## 3. Flow

```
Any session completes (lesson / review / warm-up)
  └─ applySessionRewards(progress, itemCorrectness, now, content, isWarmup)
       1. SRS update  (existing applySessionToSrs)
       2. awardSkyStars: every item now at level ≥ 3 whose key isn't already a
          star → append (deterministic order) to skyStarItemKeys → newStarKeys
       3. constellation check: any constellation whose slot count is now filled
          and not yet in completedConstellationIds → newlyCompleted; mark it
       4. (warm-up only) warmupCount++ , lastWarmupAt
     → returns next Progress + { newStarKeys, newlyCompletedConstellations }
  └─ completion screen shows, in order:
       • "★ +N  A new star for your sky!"  (if newStarKeys non-empty)
       • Doloon Burhan reveal: stars connect → shapeImage animates in → trivia
         card  (if a constellation newly completed)
  └─ Sky screen (/sky) — reachable anytime from the map app bar — shows the
     night sky: Doloon Burhan slots (filled / faint-empty), ambient extra
     stars, and a "★ N" count.
```

## 4. Data model — `Progress` (schemaVersion 3 → 4)

Add:
```dart
@Default(<String>[]) List<String> skyStarItemKeys;     // ordered, append-only item keys
                                                       // ("word:word_aav", "letter:letter_a")
@Default(<String>{}) Set<String> completedConstellationIds;  // milestone-celebrated once
```
- `skyStarItemKeys` membership = "this item has a star." Order = placement order = constellation-slot assignment. Append-only (permanence).
- Bump `Progress.empty().schemaVersion` and `ProgressRepository._currentSchemaVersion` to **4**. On mismatch the repo already returns `Progress.empty()` — clean reset, no migration.

## 5. Content — the `Constellation` model + `content.json`

New `Constellation` (freezed + json, mirrors `Region`; `slots` uses the existing `OffsetConverter`):
```dart
@freezed
class Constellation with _$Constellation {
  const factory Constellation({
    required String id,
    required String nameEn,                 // accurate English name
    required String nameMn,                 // faithful Cyrillic; native-speaker check
    required int order,
    @OffsetListConverter() required List<Offset> slots,  // normalized star positions
    required String shapeImage,             // what it resembles; animates in on completion
    required String trivia,                 // one warm kid-sentence; cultural pride
  }) = _Constellation;
  factory Constellation.fromJson(...) => ...;
}
```
`ContentRepository` loads a new top-level `constellations` array (sorted by `order`) and exposes `List<Constellation> get constellations`.

`assets/content/content.json` gains:
```jsonc
"constellations": [
  {
    "id": "doloon_burhan",
    "nameEn": "The Big Dipper",
    "nameMn": "Долоон бурхан",            // native-speaker check
    "order": 1,
    "slots": [
      [0.20, 0.30], [0.32, 0.34], [0.44, 0.40],
      [0.57, 0.44], [0.70, 0.40], [0.72, 0.56], [0.58, 0.58]
    ],                                      // approximate Dipper; tune to the art
    "shapeImage": "ladle.png",
    "trivia": "In Mongolia this is Долоон бурхан — 'the seven gods.' Some people also call it Шанага Долоо, the Ladle Seven, because it looks like a ladle for scooping."  // Mongolian terms: native-speaker check
  }
]
```
> **Localization invariant:** `Долоон бурхан` and `Шанага Долоо` (spelling + word order) are working drafts — **flag for native-speaker verification** before shipping, like every Mongolian string.

## 6. Logic — `lib/features/sky/sky_logic.dart` (pure, testable)

```dart
const kMasteryLevel = 3;
bool isMastered(SrsBox box) => box.level >= kMasteryLevel;

/// Append every item now at level ≥ 3 whose key isn't already a star, in a
/// deterministic order (sorted ascending by key), preserving prior order.
/// Idempotent: re-running with the same SRS adds nothing.
({List<String> updated, List<String> newlyEarned}) awardSkyStars({
  required List<String> current,
  required Map<String, SrsBox> srsByItem,
});

/// Constellations whose slot count is now filled and not yet celebrated.
List<Constellation> newlyCompletedConstellations({
  required int starCount,
  required List<Constellation> all,
  required Set<String> alreadyCompleted,
});
```

**Orchestrator** `applySessionRewards` (in `sky_logic.dart` or `sky_rewards.dart`) — the single path all three completion handlers call:
```dart
class SessionRewards {
  final Progress progress;                       // next Progress
  final List<String> newStarKeys;                // for the "+N new star" moment
  final List<Constellation> completedConstellations;  // for the reveal
}

SessionRewards applySessionRewards({
  required Progress current,
  required Map<String, bool> itemCorrectness,
  required DateTime now,
  required ContentRepository content,
  bool isWarmup = false,
});
```
It runs `applySessionToSrs` → `awardSkyStars` → `newlyCompletedConstellations` → (warm-up) `warmupCount`/`lastWarmupAt`, always stamps `lastPlayed`, and returns the next `Progress` plus the UI payload. **`_persistReview`, `_persistWarmup`, and the lesson-completion handler all funnel through it** (sticker/unlock logic for lessons stays where it is — only the SRS-update portion is replaced). This collapses the three duplicated persist paths into one and guarantees stars are awarded no matter which session type earned them. `applyWarmupCompletion` (Slice 5) is subsumed by `applySessionRewards(isWarmup: true)`.

## 7. Sky screen — `lib/features/sky/sky_screen.dart` (`/sky`)

- **Background:** `assets/images/sky_night.png`, `BoxFit.cover`, with a deep-blue gradient `errorBuilder` fallback (established pattern). Star positions mapped onto the cover-displayed image the same way region tiles are (the `_kMapImageWidth/Height` cover math).
- **Doloon Burhan:** for each of its 7 `slots`, draw a **bright star** if `slot i < skyStarItemKeys.length`, else a **faint empty-slot** placeholder. Draw thin connecting lines between consecutive filled slots (the Dipper outline emerges as it fills).
- **Ambient stars:** `skyStarItemKeys` beyond 7 → small scattered background stars (deterministic positions, e.g., hashed from the key).
- **Count chip:** `★ {skyStarItemKeys.length}`.
- **Constellation label:** `nameEn` + `nameMn`, dim until the constellation is complete, then lit.
- **Entry point:** a persistent, tappable **`★ N` count chip** on the Steppe map (top corner) showing the current sky-star count → `context.push('/sky')`. It doubles as an obvious kid-sized button *and* a live, healthy progress counter (the child's own sky filling up — a record, not a streak). New `GoRoute('/sky')`. The count reads `progress.skyStarItemKeys.length`.
- *(Deferred: tap a filled star to replay its word audio — next slice.)*

## 8. Celebrations (additive to existing end-of-session screens)

- **New star(s):** when `newStarKeys` is non-empty, the existing completion screen (lesson `RewardSpec` view / review `ReviewCompleteSpec` view) shows a warm *"★ +N — A new star for your sky!"* beat before exit. Mascot + copy; the Aav-voiced version is a later art add.
- **Doloon Burhan complete:** when a constellation is newly completed, a one-time reveal — the 7 stars connect, the `shapeImage` (ladle) animates in over them (`flutter_animate`, in-stack), and the `trivia` card appears. Warm, brief, skippable. **No ger-decoration/unlock reward** (deferred — see §10). Asset fallback: if `ladle.png` is missing, show the trivia card without the image.

## 9. Module structure

```
NEW  lib/models/constellation.dart                 Constellation (freezed) + OffsetListConverter if needed
NEW  lib/features/sky/sky_logic.dart               isMastered, awardSkyStars, newlyCompletedConstellations, applySessionRewards (pure)
NEW  lib/features/sky/sky_screen.dart              SkyScreen (/sky)
MOD  lib/models/progress.dart                       + skyStarItemKeys, completedConstellationIds; schemaVersion 4
MOD  lib/core/persistence/progress_repository.dart  _currentSchemaVersion = 4
MOD  lib/core/content/content_repository.dart       load + expose constellations
MOD  assets/content/content.json                    + constellations: [doloon_burhan]
MOD  lib/core/routing/app_router.dart               + /sky
MOD  lib/features/steppe/steppe_map_screen.dart     tappable "★ N" count chip → /sky; ⭐ completion marker → "done" marker
MOD  lib/features/review/review_runner_screen.dart  _persistReview / _persistWarmup → applySessionRewards; show new-star moment
MOD  lib/features/lesson/<completion handler>       lesson SRS-update → applySessionRewards; show new-star moment
MOD  lib/features/lesson/review_complete_activity.dart / reward view  render "+N star" + constellation reveal
```
(No Odon, shop, sticker, or character-rig changes — those are later slices.)

## 10. Out of scope (deferred, named)

- **Odon currency, wallet, shop, Bars's snacks** — the spendable track (§7 Track A). The very next slice.
- **Retiring "stickers" / the album** — belongs with the Odon slice (decide stickers' fate then).
- **Tap-a-star-to-hear-the-word** reinforcement on the Sky screen.
- **Further constellations + the Altan Gadas endgame**, chapter-unlock structure, and **ger-decoration milestone rewards** (the canon ties constellation completion to a "special ger decoration" — deferred until the decoration/season subsystem exists; here completion is celebration + trivia only).
- **The opening scene "The First Star"** cinematic + Aav/Od character art & voice.

**Story Guide update required (do not let canon drift):** §8 currently says a word can *"drop mastered → practiced … and re-earn its star."* Decision 2 makes stars **permanent once lit**. Update that line to: a word may drop mastered → practiced for *review-scheduling* purposes, **but its earned sky-star is permanent** — the kindness invariant forbids removing it.

## 11. Testing (logic is pure → cheap)

- **`awardSkyStars`:** items at level ≥ 3 added once; items below 3 not added; **permanence** — a key already in `current` stays after its box drops below 3; idempotent on re-run; deterministic order for multiple simultaneous masters.
- **`newlyCompletedConstellations`:** fires when slot count reached, only once (respects `alreadyCompleted`), not before.
- **`applySessionRewards`:** SRS updates + stars + constellation payload together; warm-up path also bumps `warmupCount`/`lastWarmupAt`; does **not** alter `lessons`/`earnedStickerIds`.
- **`Progress`:** round-trips `skyStarItemKeys` + `completedConstellationIds`; schema-4 fresh-start path green.
- **Content:** `content.json` loads `constellations` (Doloon Burhan: 7 slots, names, shapeImage, trivia); existing content/persistence/review tests stay green.
- **Regression:** lesson, review, and warm-up completion still persist correctly through the shared `applySessionRewards`.
- Screen/widget tests omitted (Image.asset + GoRouter hang in `flutter_test`, per prior slices) — verify UI via `flutter analyze` + full `flutter test` + a `flutter build web --debug` smoke.

## 12. Canon self-review (creative director)

- **Kindness ✓** — stars never removed (permanent); no failure state; warm copy; trivia is pride, not a lecture.
- **Currency invariant ✓** — "star" now means *only* the sky track; the map ⭐ collision is removed; Odon untouched (separate, deferred).
- **Learning integrity ✓** — only mastery (level ≥ 3, across spaced sessions) earns a star; never a single tap.
- **Naming ✓** — Долоон бурхан exact; English name is the real "Big Dipper," not a translation; Altan Gadas reserved for the endgame.
- **Cultural & safety ✓** — Doloon Burhan / Шанага Долоо are real; all Mongolian flagged for native-speaker verification; trivia warm and brief.
- **Surfaced tension** — the §8 "re-earn" line; resolved toward permanence and flagged for a deliberate Story Guide edit (§10).
```
