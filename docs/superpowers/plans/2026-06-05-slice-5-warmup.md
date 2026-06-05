# Slice 5 — Daily Warm-Up Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** An optional once-a-day warm-up that, after the splash, offers a quick review of due-or-learned items and ends with the existing stars celebration — recording `warmupCount` + `lastWarmupAt` as the seam a future reward attaches to.

**Architecture:** Reuses the Slice 4 review flow via a new `ReviewMode.warmup`. Warm-up differs only in: always runs (no gate), persists via `_persistWarmup` (SRS + count + date), and navigates with `go`. New: a prompt screen + a splash-time routing check. Pure logic (`shouldOfferWarmup`, `applyWarmupCompletion`) is unit-tested.

**Tech Stack:** Flutter, Riverpod (StateNotifier/family), go_router, freezed + json_serializable (codegen via `dart run build_runner build --delete-conflicting-outputs`).

**Spec:** `docs/superpowers/specs/2026-06-05-slice-5-warmup-design.md`

---

## ⚠️ Git policy (read first)

**This repo's owner handles ALL git.** Do NOT run any git command. Ignore the "Commit" step from TDD templates. End each task at the **Verify** step. The user commits between tasks.

## Known constraint: widget tests hang

`flutter_test` widget tests that mount `Image.asset` + `GoRouter`/providers hang in this project. **Do not write widget tests for screens.** Cover logic with pure Dart unit tests; verify UI tasks with `flutter analyze` (clean) + `flutter test` (existing suite stays green) + `flutter build web --debug`.

## Conventions

- After editing a `@freezed` model, regenerate: `dart run build_runner build --delete-conflicting-outputs`.
- `Progress` is freezed with `copyWith`. `ProgressController.update(Progress next)` saves.
- Theme: `AppColors.{coral,meadow,sky,ink,inkSoft}`, `AppFonts.display`. `CandyButton({required label, required onPressed, IconData? icon, Color color})`.

## File structure

```
NEW  lib/features/warmup/warmup_logic.dart            isSameDay, shouldOfferWarmup, applyWarmupCompletion (pure)
NEW  lib/features/warmup/warmup_prompt_screen.dart    WarmupPromptScreen (mascot offer)
NEW  test/features/warmup/warmup_logic_test.dart
MOD  lib/models/progress.dart                          + lastWarmupAt, warmupCount; schemaVersion 3
MOD  lib/core/persistence/progress_repository.dart     _currentSchemaVersion = 3
MOD  test/core/persistence/progress_repository_test.dart  schema 3 + new-field round-trip
MOD  lib/features/review/review_runner_screen.dart     ReviewMode.warmup, warmup flag, _persistWarmup, go-nav
MOD  lib/core/routing/app_router.dart                  + /warmup, /review?warmup= param
MOD  lib/features/steppe/splash_screen.dart            shouldOfferWarmup routing
```

---

## Task 1: `Progress` fields + schema bump to 3

**Files:**
- Modify: `lib/models/progress.dart`, `lib/core/persistence/progress_repository.dart`
- Test: `test/core/persistence/progress_repository_test.dart` (existing — update)

- [ ] **Step 1: Edit `lib/models/progress.dart`**

Add the two fields to the factory (after `volume`) and set `schemaVersion: 3` in `empty()`:

```dart
@freezed
class Progress with _$Progress {
  const factory Progress({
    required Map<String, LessonProgress> lessons,
    required Map<String, SrsBox> srsByItem,
    required Set<String> earnedStickerIds,
    required int schemaVersion,
    required DateTime lastPlayed,
    @Default(1.0) double volume,
    DateTime? lastWarmupAt,
    @Default(0) int warmupCount,
  }) = _Progress;

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);

  factory Progress.empty({DateTime? now}) => Progress(
        lessons: const {},
        srsByItem: const {},
        earnedStickerIds: const {},
        schemaVersion: 3,
        lastPlayed: now ?? DateTime.now(),
      );
}
```

- [ ] **Step 2: Regenerate codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `progress.freezed.dart` + `progress.g.dart` rebuilt, no errors.

- [ ] **Step 3: Bump the schema version in the repo**

In `lib/core/persistence/progress_repository.dart`, change:
```dart
  static const _currentSchemaVersion = 2;
```
to:
```dart
  static const _currentSchemaVersion = 3;
```

- [ ] **Step 4: Update the existing repository test**

Open `test/core/persistence/progress_repository_test.dart`. **Read it first.** Then:
- Wherever it expects `schemaVersion` `2`, change to `3` (e.g. the "loads what it saved" / `Progress.empty` assertions, and any hand-written JSON whose `schemaVersion` is `2` for the *current-version* round-trip — leave a deliberately-old-version test at its old number, since that one asserts the mismatch→fresh-start path).
- Add a round-trip test for the new fields:

```dart
test('round-trips lastWarmupAt and warmupCount', () async {
  final store = /* same in-test ProgressStore the other tests use */;
  final now = DateTime.utc(2026, 6, 5, 9);
  final p = Progress.empty(now: now).copyWith(
    lastWarmupAt: now,
    warmupCount: 4,
  );
  await store.save(p);
  final loaded = await store.load();
  expect(loaded.lastWarmupAt, now);
  expect(loaded.warmupCount, 4);
  expect(loaded.schemaVersion, 3);
});
```
(Match the test's existing setup for constructing the store/repository — reuse whatever helper or `setUp` the file already uses; don't invent a new persistence path.)

- [ ] **Step 5: Verify**

Run: `dart run build_runner build --delete-conflicting-outputs` (if not already clean)
Run: `flutter analyze` → No issues.
Run: `flutter test` → all green. If any OTHER test asserts `schemaVersion == 2` or builds `Progress` without the new fields, fix those assertions to `3` (the fields have defaults, so construction sites don't need changes). Report totals.

---

## Task 2: `warmup_logic.dart` (pure) + tests

**Files:**
- Create: `lib/features/warmup/warmup_logic.dart`
- Test: `test/features/warmup/warmup_logic_test.dart`
- Depends on: Task 1 (`Progress.warmupCount`/`lastWarmupAt`, `applySessionToSrs` already exists)

- [ ] **Step 1: Write the failing test** `test/features/warmup/warmup_logic_test.dart`

```dart
import 'package:bambaruush/features/warmup/warmup_logic.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/progress.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 6, 5, 9);

  group('isSameDay', () {
    test('same calendar day → true', () {
      expect(isSameDay(DateTime(2026, 6, 5, 23), now), isTrue);
    });
    test('different day → false', () {
      expect(isSameDay(DateTime(2026, 6, 4, 9), now), isFalse);
    });
    test('null → false', () {
      expect(isSameDay(null, now), isFalse);
    });
  });

  group('shouldOfferWarmup', () {
    test('offers when items exist and not warmed up today', () {
      expect(
        shouldOfferWarmup(lastWarmupAt: null, now: now, hasPracticeItems: true),
        isTrue,
      );
      expect(
        shouldOfferWarmup(
            lastWarmupAt: DateTime(2026, 6, 4), now: now, hasPracticeItems: true),
        isTrue,
      );
    });
    test('not when already warmed up today', () {
      expect(
        shouldOfferWarmup(
            lastWarmupAt: DateTime(2026, 6, 5, 1), now: now, hasPracticeItems: true),
        isFalse,
      );
    });
    test('not when there is nothing to practice', () {
      expect(
        shouldOfferWarmup(lastWarmupAt: null, now: now, hasPracticeItems: false),
        isFalse,
      );
    });
  });

  group('applyWarmupCompletion', () {
    test('updates SRS, bumps warmupCount, stamps dates; leaves lessons/stickers', () {
      final start = Progress.empty(now: DateTime(2026, 6, 1)).copyWith(
        warmupCount: 2,
        earnedStickerIds: {'sticker_a'},
      );
      final next = applyWarmupCompletion(
        current: start,
        itemCorrectness: {'word:word_aav': true},
        now: now,
      );
      expect(next.warmupCount, 3);
      expect(next.lastWarmupAt, now);
      expect(next.lastPlayed, now);
      expect(next.earnedStickerIds, {'sticker_a'}); // untouched (no reward yet)
      expect(next.lessons, isEmpty); // untouched
      // SRS box created for the quizzed word.
      expect(next.srsByItem.containsKey('word:word_aav'), isTrue);
      final box = next.srsByItem['word:word_aav']!;
      expect(box.itemId, 'word_aav');
      expect(box.itemType, ItemType.word);
    });
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/warmup/warmup_logic_test.dart`
Expected: FAIL — `warmup_logic.dart` undefined.

- [ ] **Step 3: Implement** `lib/features/warmup/warmup_logic.dart`

```dart
import '../../models/progress.dart';
import '../lesson/srs_update.dart';

/// True iff [a] is the same calendar day as [b] in local time (null a → false).
bool isSameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

/// Offer the daily warm-up when there's something to practice and we haven't
/// already warmed up (or skipped) today.
bool shouldOfferWarmup({
  required DateTime? lastWarmupAt,
  required DateTime now,
  required bool hasPracticeItems,
}) =>
    hasPracticeItems && !isSameDay(lastWarmupAt, now);

/// Apply a completed warm-up to progress: the SRS update (same as a normal
/// review) plus bumping [Progress.warmupCount] and stamping the dates. No reward
/// is granted yet — that's the seam the future house-accessory reward attaches to.
Progress applyWarmupCompletion({
  required Progress current,
  required Map<String, bool> itemCorrectness,
  required DateTime now,
}) =>
    current.copyWith(
      srsByItem: applySessionToSrs(
        current: current.srsByItem,
        itemCorrectness: itemCorrectness,
        now: now,
      ),
      warmupCount: current.warmupCount + 1,
      lastWarmupAt: now,
      lastPlayed: now,
    );
```

- [ ] **Step 4: Verify**

Run: `flutter test test/features/warmup/warmup_logic_test.dart` → PASS
Run: `flutter analyze` → No issues.

---

## Task 3: `ReviewMode.warmup` + warmup mode in `ReviewRunnerScreen`

**Files:**
- Modify: `lib/features/review/review_runner_screen.dart`, `lib/core/routing/app_router.dart`
- Depends on: Tasks 1, 2

**No new unit tests** (UI/provider wiring; widget tests hang; the meaningful logic `applyWarmupCompletion` is already tested in Task 2). Verify via analyze + existing suite + build.

- [ ] **Step 1: Edit `lib/features/review/review_runner_screen.dart`**

(a) Add the import (with the other imports):
```dart
import '../warmup/warmup_logic.dart';
```

(b) Extend the enum:
```dart
enum ReviewMode { due, free, warmup }
```

(c) Replace the `reviewRunnerProvider` body's item/session selection so warm-up uses due-or-free. The full provider becomes:
```dart
final reviewRunnerProvider = StateNotifierProvider.autoDispose
    .family<SessionRunner, SessionRunnerState, ReviewMode>((ref, mode) {
  final content = ref.watch(contentRepositoryProvider);
  final srs = ref.read(progressControllerProvider).srsByItem;
  final learnedWordIds = <String>[
    for (final b in srs.values)
      if (b.itemType == ItemType.word) b.itemId,
  ];
  final due = ref.read(reviewQueueProvider);
  final free = ref.read(freePracticeProvider);
  // Warm-up reviews due items if any, else free-practice. due/free modes are
  // unchanged. (.due and .free build identically; the factory name documents
  // which pool the items came from.)
  final useDue =
      mode == ReviewMode.due || (mode == ReviewMode.warmup && due.isNotEmpty);
  final items = useDue ? due : free;
  final session = useDue
      ? ReviewSession.due(
          items: items, content: content, learnedWordIds: learnedWordIds)
      : ReviewSession.free(
          items: items, content: content, learnedWordIds: learnedWordIds);
  return SessionRunner(sequence: session.buildSequence());
});
```

(d) Add the `warmup` flag to the screen widget:
```dart
class ReviewRunnerScreen extends ConsumerStatefulWidget {
  const ReviewRunnerScreen({super.key, this.warmup = false});

  /// When true, this is the daily warm-up: always run (no gate), persist via
  /// _persistWarmup, and exit with go('/steppe') instead of pop.
  final bool warmup;

  @override
  ConsumerState<ReviewRunnerScreen> createState() => _ReviewRunnerScreenState();
}
```

(e) Replace `_ReviewRunnerScreenState` with warm-up-aware entry logic:
```dart
class _ReviewRunnerScreenState extends ConsumerState<ReviewRunnerScreen> {
  // Locked at entry so a post-session progress change can't flip us back to the
  // gate before we exit.
  ReviewMode? _mode;

  @override
  void initState() {
    super.initState();
    if (widget.warmup) {
      final hasItems = ref.read(reviewQueueProvider).isNotEmpty ||
          ref.read(freePracticeProvider).isNotEmpty;
      if (hasItems) {
        _mode = ReviewMode.warmup;
      } else {
        // Defensive: reached warm-up with nothing to practice (normally
        // prevented by the splash check). Bounce to the map.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/steppe');
        });
      }
    } else if (ref.read(reviewQueueProvider).isNotEmpty) {
      _mode = ReviewMode.due;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    if (mode != null) return _RunningView(mode: mode, warmup: widget.warmup);
    if (widget.warmup) return const SizedBox.shrink(); // redirecting to /steppe
    return _CaughtUpView(
      canPractice: ref.watch(freePracticeProvider).isNotEmpty,
      onPractice: () => setState(() => _mode = ReviewMode.free),
      onBack: () => context.pop(),
    );
  }
}
```

(f) Replace `_RunningView` with warm-up-aware persist + navigation:
```dart
class _RunningView extends ConsumerWidget {
  const _RunningView({required this.mode, required this.warmup});
  final ReviewMode mode;
  final bool warmup;

  // Warm-up is entered via go (splash → /warmup → /review?warmup=1), so it exits
  // to the map; due/free are pushed from the landmark, so they pop.
  void _exit(BuildContext context) {
    if (warmup) {
      context.go('/steppe');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewRunnerProvider(mode));
    final runner = ref.read(reviewRunnerProvider(mode).notifier);

    ref.listen<SessionRunnerState>(reviewRunnerProvider(mode), (prev, next) async {
      if (next.current is SessionComplete && prev?.current is! SessionComplete) {
        if (warmup) {
          await _persistWarmup(ref, next);
        } else {
          await _persistReview(ref, next);
        }
        if (context.mounted) _exit(context);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmQuit(context) && context.mounted) _exit(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(warmup ? 'Warm-up' : 'Practice'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmQuit(context) && context.mounted) _exit(context);
            },
          ),
        ),
        body: Stack(
          children: [
            ActivityView(spec: state.current, runner: runner),
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: LinearProgressIndicator(
                value: state.totalSteps == 0
                    ? 0
                    : state.currentStep / state.totalSteps,
              ),
            ),
            const MascotOverlay(),
          ],
        ),
      ),
    );
  }
}
```

(g) Add `_persistWarmup` next to `_persistReview` (keep `_persistReview` unchanged):
```dart
Future<void> _persistWarmup(WidgetRef ref, SessionRunnerState s) async {
  final progress = ref.read(progressControllerProvider);
  await ref.read(progressControllerProvider.notifier).update(
        applyWarmupCompletion(
          current: progress,
          itemCorrectness: s.itemCorrectness,
          now: DateTime.now(),
        ),
      );
}
```

- [ ] **Step 2: Edit `lib/core/routing/app_router.dart`** — make `/review` read the `warmup` query param:

Replace the `/review` route:
```dart
GoRoute(path: '/review', builder: (_, __) => const ReviewRunnerScreen()),
```
with:
```dart
GoRoute(
  path: '/review',
  builder: (_, state) =>
      ReviewRunnerScreen(warmup: state.uri.queryParameters['warmup'] == '1'),
),
```

- [ ] **Step 3: Verify**

Run: `flutter analyze` → No issues.
Run: `flutter test` → existing suite green (incl. Task 1/2 tests). Report totals.
Run: `flutter build web --debug` → builds.

---

## Task 4: `WarmupPromptScreen` + `/warmup` route

**Files:**
- Create: `lib/features/warmup/warmup_prompt_screen.dart`
- Modify: `lib/core/routing/app_router.dart`
- Depends on: Task 3 (`/review?warmup=1`)

**No new unit tests** (screen). Verify via analyze + build.

- [ ] **Step 1: Create** `lib/features/warmup/warmup_prompt_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';
import '../mascot/mascot_overlay.dart';

/// Once-a-day offer shown after the splash. "Let's go" runs the warm-up review;
/// "Maybe later" stamps the day (so we don't re-ask) and goes to the map.
class WarmupPromptScreen extends ConsumerWidget {
  const WarmupPromptScreen({super.key});

  Future<void> _skip(BuildContext context, WidgetRef ref) async {
    final progress = ref.read(progressControllerProvider);
    await ref
        .read(progressControllerProvider.notifier)
        .update(progress.copyWith(lastWarmupAt: DateTime.now()));
    if (context.mounted) context.go('/steppe');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _skip(context, ref);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/bambaruush.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Text('🐻', style: TextStyle(fontSize: 64)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ready for a quick warm-up?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A few quick reviews to keep your words fresh.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 28),
                  CandyButton(
                    label: "Let's go!",
                    icon: Icons.bolt_rounded,
                    onPressed: () => context.go('/review?warmup=1'),
                    color: AppColors.coral,
                  ),
                  const SizedBox(height: 12),
                  CandyButton(
                    label: 'Maybe later',
                    icon: Icons.bedtime_rounded,
                    onPressed: () => _skip(context, ref),
                    color: AppColors.sky,
                  ),
                ],
              ),
            ),
            const MascotOverlay(),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Register the route in `app_router.dart`**

Add the import:
```dart
import '../../features/warmup/warmup_prompt_screen.dart';
```
and a route (e.g. right after `/review`):
```dart
GoRoute(path: '/warmup', builder: (_, __) => const WarmupPromptScreen()),
```

- [ ] **Step 3: Verify**

Run: `flutter analyze` → No issues.
Run: `flutter test` → green.
Run: `flutter build web --debug` → builds.

---

## Task 5: Splash routes to warm-up

**Files:**
- Modify: `lib/features/steppe/splash_screen.dart`
- Depends on: Tasks 2, 4

**No new unit tests** (screen). Verify via analyze + build.

- [ ] **Step 1: Edit `lib/features/steppe/splash_screen.dart`**

Add imports:
```dart
import '../../core/providers.dart';
import '../review/review_queue.dart';
import '../warmup/warmup_logic.dart';
```

Replace the `initState` post-frame body so it decides `/warmup` vs `/steppe`:
```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final progress = ref.read(progressControllerProvider);
      final hasPracticeItems = ref.read(reviewQueueProvider).isNotEmpty ||
          ref.read(freePracticeProvider).isNotEmpty;
      final destination = shouldOfferWarmup(
        lastWarmupAt: progress.lastWarmupAt,
        now: DateTime.now(),
        hasPracticeItems: hasPracticeItems,
      )
          ? '/warmup'
          : '/steppe';
      if (mounted) context.go(destination);
    });
  }
```
(The `build` method and the rest of the widget are unchanged.)

- [ ] **Step 2: Verify**

Run: `flutter analyze` → No issues.
Run: `flutter test` → green.
Run: `flutter build web --debug` → builds.

---

## Final verification (after all tasks)

- [ ] `flutter analyze` → **No issues found!**
- [ ] `flutter test` → all green (existing + `warmup_logic_test` + updated `progress_repository_test`).
- [ ] `flutter build web --debug` → builds.
- [ ] Logic trace: fresh start (schema 3) → after completing a lesson there are learned items → next launch splash routes to `/warmup` → "Let's go" runs a review ending in stars → `warmupCount` becomes 1, `lastWarmupAt` today → re-launch same day goes straight to `/steppe`. (Human/web check.)

## Out of scope (next track)

The warm-up **reward** (house accessories/decorations) — attaches later at `warmupCount` + `_persistWarmup`. Streaks — room left on `warmupCount`/`lastWarmupAt`.
