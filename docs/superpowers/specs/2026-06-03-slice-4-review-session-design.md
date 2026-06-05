# Slice 4 — Review Session + Practice Landmark — Design Spec

**Date**: 2026-06-03
**Status**: Approved for implementation
**Parent spec**: `docs/superpowers/specs/2026-06-02-modular-games-and-review-design.md` (Slice 4 of its build order)
**Builds on**: Slice 3 (`docs/superpowers/specs/2026-06-03-srs-items-design.md`) — `Item`/`ItemType`, `srsByItem`, `LeitnerEngine.dueItems`, `SessionRunner.itemCorrectness`, `applySessionToSrs`.
**Branch**: `slice-4-review-session` (stacked on `slice-3-srs-items` until earlier slices merge)

## 1. Purpose

Turn the SRS data Slice 3 records into a **playable review tool**. The child taps a Practice landmark on the Steppe map and reviews items that are due — reinforcing memory between lessons. This is the first feature that *consumes* the SRS rather than just feeding it.

**No new game.** Review reuses the existing activities (`ListenSpec`/`ReadSpec`/`TraceSpec`) and the existing `SessionRunner`. Review is simply a **second `Session` source** that builds an activity sequence from due items instead of from a `Lesson`. This is the payoff of the Slice 1 Activity/Session split: lessons and review share one runner and one activity library.

## 2. Locked decisions

1. **Empty queue → caught-up screen + "Practice anyway."** Items aren't due for 1–3 days after a lesson, so the due queue is usually empty right after playing. When empty, show a friendly *"All caught up! ⭐"* with a **Practice anyway** button that runs **free practice** of already-learned items, plus **Back to map**. Never a dead end; testable immediately without waiting for items to come due. (If the child has no learned items at all, *Practice anyway* is hidden.)
2. **Finish = stars celebration, no album sticker.** A review session ends on a brief mascot + star summary (*"You practiced N! ⭐⭐⭐"*) then returns to the map. Ordinary practice never grants album stickers — those stay tied to lessons, keeping the album meaningful (parent spec §7).
3. **Practice landmark = book/signpost marker** with a due-count badge, placed on the map via the same cover-rect anchor math as the region tiles (a `_kPracticeAnchor` constant, nudgeable later like the Ger tile).
4. **Two concrete `Session` classes, no abstract base yet.** `ReviewSession` sits beside `LessonSession` as a peer concrete class. The parent spec's abstract `Session { onComplete }` base is **not** introduced now (YAGNI — no third consumer). Documented as a future consolidation (§9).
5. **Reuse `applySessionToSrs` unchanged.** It already iterates the quizzed set (`itemCorrectness` keyed `"type:id"`), creates-or-promotes/demotes each box, and is language-agnostic. Review completion calls it exactly as lessons do.

## 3. Architecture & data flow

Review adds a new **source** and a new **screen**; the runner, activity views, and SRS engine are unchanged.

```
 SRS boxes ──► reviewQueueProvider ──► ReviewSession.buildSequence() ──► List<ActivitySpec>
 (Slice 3)     (due: resolve, filter,    (cap 8, pick activity,                │
                sort overdue-first)       attach distractors,                  ▼
                                          + ReviewCompleteSpec)       SessionRunner (existing)
                                                                              │
                                                                      ActivityView (shared switch)
                                                                              │
                                                                              ▼ on SessionComplete
                                                                      applySessionToSrs() (existing)
```

```mermaid
flowchart TD
    Map["Steppe map<br/>Practice landmark (badge = due count)"] -->|/review| Gate{due queue empty?}
    Gate -->|no| Due["Run due session"]
    Gate -->|yes| Caught["All caught up! ⭐"]
    Caught -->|Practice anyway<br/>(if learned pool non-empty)| Free["Run free-practice session"]
    Caught -->|Back to map| Map
    Due --> Complete["ReviewCompleteSpec → stars"]
    Free --> Complete
    Complete -->|persist SRS, pop| Map
```

## 4. Domain note — no new domain types

Slice 3 already shipped `Item`/`ItemType` + `itemKeyOf`/`itemRefFromKey`. The parent spec's older `ItemRef`/`ReviewItemType` names are **superseded** by Slice 3's `Item`/`ItemType`. Slice 4 resolves a `SrsBox` to its concrete `Item` using the existing public content maps:

```dart
Item? itemForBox(SrsBox box, ContentRepository content) =>
    box.itemType == ItemType.word ? content.words[box.itemId] : content.letters[box.itemId];
// null → the id no longer exists in content → filtered out of the queue.
```

(`Word` and `Letter` both `implements Item`; `content.words`/`content.letters` are `Map`s that return null safely — no new content method needed.)

## 5. Review queue (pure logic + thin provider)

`lib/features/review/review_queue.dart`

**Pure, testable functions** (take an explicit `now`, no `DateTime.now()` inside):

```dart
/// All due items, resolved to concrete Items, unknown ids dropped, sorted
/// most-overdue-first (nextReviewAt ascending). NOT capped — the badge uses the
/// full length; the session caps.
List<Item> dueReviewItems({
  required Map<String, SrsBox> srsByItem,
  required ContentRepository content,
  required DateTime now,
});

/// Items the child has already practiced (have an SRS box), resolved & sorted
/// soonest-due-first. Used by free practice when nothing is due. NOT capped.
List<Item> freePracticeItems({
  required Map<String, SrsBox> srsByItem,
  required ContentRepository content,
});
```

- `dueReviewItems` uses `LeitnerEngine.dueItems(srsByItem, now)` (already exists), maps each `SrsBox` via `itemForBox`, drops nulls, sorts by `nextReviewAt` ascending.
- `freePracticeItems` takes all boxes (every learned item), maps & drops nulls, sorts by `nextReviewAt` ascending (closest-to-due first = most worth practicing). When `dueReviewItems` is non-empty we never use this (we're in due mode); it only matters once due is empty, where every box is not-due.

**Providers** (thin wrappers, supply `DateTime.now()`):

```dart
final reviewQueueProvider = Provider<List<Item>>((ref) =>
    dueReviewItems(srsByItem: ref.watch(progressControllerProvider).srsByItem,
                   content: ref.watch(contentRepositoryProvider),
                   now: DateTime.now()));

final freePracticeProvider = Provider<List<Item>>((ref) =>
    freePracticeItems(srsByItem: ref.watch(progressControllerProvider).srsByItem,
                      content: ref.watch(contentRepositoryProvider)));
```

The map badge shows `reviewQueueProvider.length` (rendered "9+" past 9). Recomputes when `Progress` changes.

## 6. Activity selection (capability map)

`lib/features/review/review_session.dart`

```dart
/// Graded activity kinds review can choose from.
enum ReviewActivityKind { listen, read, trace }

/// Which graded activities each item type supports. Forward-looking seam:
/// new ItemTypes (verb, color…) add their compatible games here.
const gradedActivitiesFor = <ItemType, List<ReviewActivityKind>>{
  ItemType.word: [ReviewActivityKind.listen, ReviewActivityKind.read],
  ItemType.letter: [ReviewActivityKind.trace],
};

/// Deterministic given (item, seed): options[seed % options.length].
/// Words alternate Listen/Read across the queue via differing per-item seeds
/// → variety; letters always Trace. Throws if an item type has no graded games.
ReviewActivityKind pickActivityForItem(Item item, {required int seed});
```

## 7. `ReviewSession` — building the sequence

`lib/features/review/review_session.dart`

A concrete class parallel to `LessonSession`, with two factory constructors so the screen's intent is explicit:

```dart
class ReviewSession {
  ReviewSession.due({
    required this.items, required this.content, required this.learnedWordIds, this.seed});
  ReviewSession.free({
    required this.items, required this.content, required this.learnedWordIds, this.seed});

  final List<Item> items;            // already sorted by the queue
  final ContentRepository content;
  final List<String> learnedWordIds; // word-typed ids with an SRS box (distractor pool)
  final int? seed;                   // deterministic distractors/activity in tests

  static const sessionCap = 8;

  List<ActivitySpec> buildSequence();
}
```

`buildSequence()`:
1. Take the first `sessionCap` (8) `items`.
2. For each item at index `i`, `pickActivityForItem(item, seed: seed == null ? i : Object.hash(seed, i))` — index-based so words alternate Listen/Read across the session (`i % 2`), and a fixed `seed` stays reproducible:
   - `word` → `ListenSpec`/`ReadSpec`, `attempt: 1`, `distractorIds` from `pickReviewDistractors(targetWordId: item.id, learnedWordIds: learnedWordIds, allWordIds: content.words.keys.toList(), n: 2, seed: seed == null ? null : Object.hash(seed, item.id))`.
   - `letter` → `TraceSpec(letterId: item.id, attempt: 1)`.
3. Append `ReviewCompleteSpec(reviewedCount: <number of graded specs built>)`.

(Both `.due` and `.free` build identically — they differ only in the item list handed in. The two constructors document caller intent and leave room for `.free` to diverge later, e.g. Slice 5 warm-up.)

**Review distractors** — `lib/features/review/review_distractors.dart` (review has no lesson/region context, so the lesson `pickDistractors` doesn't apply):

```dart
/// Pick n distractor word ids for a review tile from the learned word pool,
/// excluding the target. Falls back to any words when the pool is thin. Seeded
/// → deterministic in tests.
List<String> pickReviewDistractors({
  required String targetWordId,
  required List<String> learnedWordIds,   // words that have an SRS box
  required List<String> allWordIds,       // fallback pool
  required int n,
  int? seed,
});
```

`ReviewSession` receives `learnedWordIds` (computed by `reviewRunnerProvider` from `srsByItem` — the word-typed ids) and derives `allWordIds` from `content.words.keys`.

## 8. Completion celebration — `ReviewCompleteSpec` (in the sequence)

Modeled as the **last activity in the sequence**, exactly how lessons end on `RewardSpec`. This keeps the runner and screen generic — no post-session special-casing.

`lib/features/lesson/activity_spec.dart` (add):

```dart
/// Presentational end-of-review celebration (no album sticker). Last step of a
/// ReviewSession sequence.
class ReviewCompleteSpec extends ActivitySpec {
  const ReviewCompleteSpec({required this.reviewedCount});
  final int reviewedCount;
}
```

- **Runner unchanged:** `SessionRunner.advance` already advances on any non-graded spec; `_itemKeysOf` only collects Listen/Read/Trace. `ReviewCompleteSpec` is presentational (like `IntroSpec`/`RewardSpec`) — no correctness tracked, advances via a continue tap → `advance(correct: true)` → `SessionComplete`.
- `ReviewCompleteView` (`lib/features/review/review_complete_view.dart`) renders the mascot + "You practiced N! ⭐⭐⭐" + a continue button; `reviewedCount` drives the star/label.

## 9. Shared `ActivityView` (extraction)

Today the spec→widget switch lives as the private `_activityWidget` in `lesson_runner_screen.dart`. Extract it to a shared widget so lesson and review render activities identically and adding a spec never drifts (parent spec §4 calls this the single `ActivityView` switch).

`lib/features/lesson/activity_view.dart`:

```dart
class ActivityView extends StatelessWidget {
  const ActivityView({super.key, required this.spec, required this.runner});
  final ActivitySpec spec;
  final SessionRunner runner;
  // switch over spec → Intro/Trace/Listen/Read/Reward/ReviewComplete views,
  // wiring runner.advance / runner.advance(correct: true) exactly as today.
}
```

- `LessonRunnerScreen` replaces its `_activityWidget(...)` with `ActivityView(spec: state.current, runner: runner)` — **behavior-preserving**; guarded by the existing `session_runner` tests and lesson tests.
- Adds the `ReviewCompleteSpec` → `ReviewCompleteView` case.
- The `SessionRunnerState` keeps the `ValueKey('listen-…')`/`'read-…'` keys for the Listen/Read views (they live in the switch).

*(YAGNI note: the runner **screen scaffold** — PopScope quit-confirm, progress bar, mascot overlay — is mirrored by `ReviewRunnerScreen` rather than fully generalized into one screen widget. Two small scaffolds beat a premature generic screen; consolidating into one `SessionRunnerScreen` is a future option once a third consumer appears.)*

## 10. `ReviewRunnerScreen` + route

`lib/features/review/review_runner_screen.dart`, route `/review` (added to `app_router.dart`).

A `ConsumerStatefulWidget` with a small phase model:

- **On entry** read `reviewQueueProvider`.
  - **Non-empty** → build a runner from `ReviewSession.due(items: queue, content)` and run it (start in the running phase).
  - **Empty** → **gate phase**: show *"All caught up! ⭐"*, **Back to map** (`context.pop()`), and — only if `freePracticeProvider` is non-empty — **Practice anyway**, which switches to the running phase with `ReviewSession.free(items: freePool, content)`.
- **Running phase** mirrors `LessonRunnerScreen`: `PopScope` quit-confirm, top `LinearProgressIndicator`, `MascotOverlay`, body = `ActivityView(spec: state.current, runner: runner)`.
- **On `SessionComplete`** (the `ref.listen` pattern from the lesson screen): persist, then `context.pop()` back to the map.

The runner is provided via an autoDispose family keyed by mode so each entry is fresh:

```dart
enum ReviewMode { due, free }
final reviewRunnerProvider = StateNotifierProvider.autoDispose
    .family<SessionRunner, SessionRunnerState, ReviewMode>((ref, mode) {
  final content = ref.watch(contentRepositoryProvider);
  final srs = ref.read(progressControllerProvider).srsByItem;
  final learnedWordIds = [
    for (final b in srs.values)
      if (b.itemType == ItemType.word) b.itemId,
  ];
  final items = mode == ReviewMode.due
      ? ref.read(reviewQueueProvider)
      : ref.read(freePracticeProvider);
  final session = mode == ReviewMode.due
      ? ReviewSession.due(items: items, content: content, learnedWordIds: learnedWordIds)
      : ReviewSession.free(items: items, content: content, learnedWordIds: learnedWordIds);
  return SessionRunner(sequence: session.buildSequence());
});
```

**Persistence on complete** (`_persistReview`): SRS only — no unlock, no sticker.

```dart
final progress = ref.read(progressControllerProvider);
final now = DateTime.now();
final newSrs = applySessionToSrs(
  current: progress.srsByItem, itemCorrectness: state.itemCorrectness, now: now);
await ref.read(progressControllerProvider.notifier)
    .update(progress.copyWith(srsByItem: newSrs, lastPlayed: now));
```

## 11. Practice landmark on the map

`lib/features/steppe/steppe_map_screen.dart`:

- Add `const _kPracticeAnchor = Offset(0.22, 0.82)` (image-normalized lower-left, clear of the Ger at `[0.5, 0.63]`; nudgeable later like the Ger tile) and render a marker with the existing cover-rect math + `FractionalTranslation(-0.5,-0.5)`.
- Marker styled consistently with `_RegionTile` (white rounded card, `kSoftShadow`): a book/study icon (e.g. `Icons.auto_stories`) + label "Practice", with a **due-count badge** (top-right pill) showing `ref.watch(reviewQueueProvider).length` ("9+" past 9), hidden when 0.
- `onTap` → `context.push('/review')`.
- A real signpost/book image asset can replace the icon later (errorBuilder-style fallback like the map image), but Slice 4 ships the icon marker.

## 12. Module structure

```
lib/features/review/review_queue.dart          dueReviewItems / freePracticeItems (pure) + providers
lib/features/review/review_session.dart        ReviewActivityKind, gradedActivitiesFor, pickActivityForItem, ReviewSession
lib/features/review/review_distractors.dart    pickReviewDistractors (pure)
lib/features/review/review_runner_screen.dart  entry gate + runner + SRS persist; reviewRunnerProvider, ReviewMode
lib/features/review/review_complete_view.dart  stars celebration view
lib/features/lesson/activity_view.dart         shared ActivityView switch (extracted)
lib/features/lesson/activity_spec.dart         + ReviewCompleteSpec
lib/core/routing/app_router.dart               + /review route
lib/features/steppe/steppe_map_screen.dart     + Practice landmark
```

(Stays within `features/` to match Slice 1's decision not to do the full `features/session/` directory move yet.)

## 13. Testing (logic is pure → cheap)

- **`pickActivityForItem`** — determinism (same `(item, seed)` → same kind); word even/odd seed → `read`/`listen`; letter → always `trace`.
- **`dueReviewItems`** — filters to due only; most-overdue-first ordering; drops `SrsBox`es whose id is absent from content; words and letters both resolved.
- **`freePracticeItems`** — returns all learned items sorted soonest-due-first; drops unknown ids; empty when no boxes.
- **`ReviewSession.buildSequence`** — due & free: correct spec per item type; caps at 8; ends with exactly one `ReviewCompleteSpec`; `reviewedCount` equals the graded-spec count; word specs carry distractors.
- **`pickReviewDistractors`** — pulls from learned pool, excludes target, falls back to `allWordIds` when thin, seeded determinism, never returns the target.
- **Regression** — existing `session_runner_test`, `lesson_session_test`, and lesson-flow tests stay green after the `ActivityView` extraction (behavior-preserving).
- Widget/screen tests historically hang in `flutter_test` (Image.asset + GoRouter); keep coverage on the pure logic above. A `/review` route smoke test only if it runs reliably.

## 14. Out of scope (deferred, designed elsewhere)

- **Slice 5 — daily warm-up:** `/warmup` (once/day, after splash), the `isWarmup` flag on the review flow, the rotating daily sticker reward, and `DateTime? lastWarmupAt` on `Progress`. Slice 4 ships **manual** practice via the landmark only. `ReviewSession.free` and the `ReviewMode` seam leave room for warm-up to plug in.
- **Slice 6 —** character rig + advanced games (new `ActivitySpec`s the review queue can also source).
- **Slice 7 —** item sub-categories (`LetterCategory`, word groups) — would let review filter/balance by category.
- Abstract `Session { onComplete }` base — future consolidation once a third session consumer exists (§2.4, §9).

## 15. No user-visible change to existing flows

Lessons play identically (the `ActivityView` extraction is behavior-preserving). The only new surface is the Practice landmark → `/review`. The demo on `main` is untouched.
