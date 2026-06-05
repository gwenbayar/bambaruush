# Slice 4 — Review Session + Practice Landmark Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the SRS data into a playable review tool — a Practice landmark on the Steppe map opens a session built from due items, reusing the existing activities and `SessionRunner`.

**Architecture:** Review is a second `Session` source (peer to `LessonSession`) that builds a `List<ActivitySpec>` from due/free-practice items. The existing `SessionRunner` drives it; a shared `ActivityView` renders specs; completion calls the existing `applySessionToSrs`. No new game engine.

**Tech Stack:** Flutter, Riverpod (StateNotifier/Provider/family), go_router, existing activity library. Pure logic (queue, picker, session, distractors) is fully unit-tested; UI is verified by `flutter analyze` + the existing suite + web smoke.

**Spec:** `docs/superpowers/specs/2026-06-03-slice-4-review-session-design.md`

---

## ⚠️ Git policy (read first)

**This repo's owner handles ALL git. Do NOT run any git command** (`init/add/commit/push/status/log/diff/branch/checkout/rebase/…`). Ignore the standard "Commit" step from TDD/plan templates. End each task at the **Verify** step (analyze + test green). The user commits between tasks themselves.

## Known constraint: widget tests hang

`flutter_test` widget tests that mount `Image.asset` + `GoRouter`/providers hang in this project (documented in prior slices). **Do not write widget tests for screens/views.** Cover logic with pure Dart unit tests (Tasks 1–3); verify UI tasks (4–6) with `flutter analyze` (clean) + `flutter test` (existing suite stays green) + a `flutter build web --debug` smoke. Manual/web is the human's check.

## Conventions in this codebase

- All activity views live in `lib/features/lesson/` named `*_activity.dart` with a `*ActivityView` class (`intro_activity.dart`/`IntroActivityView`, etc.). New views follow this.
- Presentational views (`IntroActivityView`, `RewardActivityView`) take `{spec, onContinue}`; graded views (`Trace/Listen/Read`) take `{spec, onResult}` where `onResult` is `void Function({required bool correct})`.
- `SessionRunner.advance({required bool correct})` steps the sequence; presentational specs advance with `correct: true`.
- `ContentRepository` exposes `words` / `letters` as `Map<String, Word>` / `Map<String, Letter>` (null-safe lookup) plus throwing `wordById`/`letterById`.
- Theme: `AppColors.{coral,meadow,sun,sky,ink,inkSoft,cardBorder}`, `AppFonts.display`, `AppRadii.tile`, `kSoftShadow`. Buttons: `CandyButton(label, onPressed, {icon, color})`.

## File structure

```
NEW  lib/features/review/review_distractors.dart      pickReviewDistractors (pure)
NEW  lib/features/review/review_session.dart           ReviewActivityKind, gradedActivitiesFor, pickActivityForItem, ReviewSession
NEW  lib/features/review/review_queue.dart             dueReviewItems / freePracticeItems (pure) + providers
NEW  lib/features/lesson/activity_view.dart            shared ActivityView switch (extracted from lesson screen)
NEW  lib/features/lesson/review_complete_activity.dart ReviewCompleteActivityView (stars celebration)
NEW  lib/features/review/review_runner_screen.dart     reviewRunnerProvider, ReviewMode, gate + runner + SRS persist
MOD  lib/features/lesson/activity_spec.dart            + ReviewCompleteSpec
MOD  lib/features/lesson/lesson_runner_screen.dart     use shared ActivityView (drop _activityWidget)
MOD  lib/core/routing/app_router.dart                  + /review route
MOD  lib/features/steppe/steppe_map_screen.dart        + Practice landmark with due badge
NEW  test/features/review/review_distractors_test.dart
NEW  test/features/review/review_session_test.dart
NEW  test/features/review/review_queue_test.dart
```

**Decisions locked here (refining the spec's file layout):** `ReviewCompleteActivityView` lives in `lib/features/lesson/` (with the other activity views, `*_activity.dart` convention) rather than `features/review/`. This keeps all activity views co-located and avoids a `lesson → review` import (the shared `ActivityView` would otherwise import across features). Review still depends on the activity library (correct direction).

---

## Task 1: `ReviewCompleteSpec` + review distractors

**Files:**
- Modify: `lib/features/lesson/activity_spec.dart`
- Create: `lib/features/review/review_distractors.dart`
- Test: `test/features/review/review_distractors_test.dart`

- [ ] **Step 1: Add `ReviewCompleteSpec` to `activity_spec.dart`**

Append after `SessionComplete` (keep `SessionComplete` last is not required; just add the class):

```dart
/// Presentational end-of-review celebration (no album sticker). Last step of a
/// ReviewSession sequence; shows how many items were practiced.
class ReviewCompleteSpec extends ActivitySpec {
  const ReviewCompleteSpec({required this.reviewedCount});
  final int reviewedCount;
}
```

- [ ] **Step 2: Write the failing test** `test/features/review/review_distractors_test.dart`

```dart
import 'package:bambaruush/features/review/review_distractors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const all = ['word_aav', 'word_akh', 'word_baavgai', 'word_bombog'];

  test('prefers the learned pool, excludes the target, returns n', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: all,
      allWordIds: all,
      n: 2,
      seed: 1,
    );
    expect(picks, hasLength(2));
    expect(picks, isNot(contains('word_aav')));
    expect(picks.toSet().length, 2); // no duplicates
    expect(all.toSet().containsAll(picks), isTrue);
  });

  test('falls back to allWordIds when the learned pool is too small', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: ['word_aav'], // only the target is "learned"
      allWordIds: all,
      n: 2,
      seed: 1,
    );
    expect(picks, hasLength(2));
    expect(picks, isNot(contains('word_aav')));
  });

  test('same seed is deterministic', () {
    List<String> run() => pickReviewDistractors(
          targetWordId: 'word_aav',
          learnedWordIds: all,
          allWordIds: all,
          n: 2,
          seed: 42,
        );
    expect(run(), run());
  });

  test('never returns the target even when it is the only candidate', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: ['word_aav'],
      allWordIds: ['word_aav'],
      n: 2,
      seed: 1,
    );
    expect(picks, isNot(contains('word_aav')));
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

Run: `flutter test test/features/review/review_distractors_test.dart`
Expected: FAIL — `review_distractors.dart` / `pickReviewDistractors` undefined.

- [ ] **Step 4: Implement** `lib/features/review/review_distractors.dart`

```dart
import 'dart:math';

/// Pick [n] distractor word ids for a review tile. Prefers the learned pool
/// (words the child has already practiced), excluding the target; falls back to
/// [allWordIds] when the learned pool is too small. Seeded → deterministic.
List<String> pickReviewDistractors({
  required String targetWordId,
  required List<String> learnedWordIds,
  required List<String> allWordIds,
  required int n,
  int? seed,
}) {
  final rand = Random(seed ?? DateTime.now().microsecondsSinceEpoch);

  final learned = learnedWordIds.where((id) => id != targetWordId).toSet().toList()
    ..shuffle(rand);
  if (learned.length >= n) return learned.take(n).toList();

  final fallback = allWordIds
      .where((id) => id != targetWordId && !learned.contains(id))
      .toSet()
      .toList()
    ..shuffle(rand);

  return [...learned, ...fallback.take(n - learned.length)];
}
```

- [ ] **Step 5: Verify**

Run: `flutter test test/features/review/review_distractors_test.dart` → PASS
Run: `flutter analyze` → No issues.

---

## Task 2: Activity picker + `ReviewSession`

**Files:**
- Create: `lib/features/review/review_session.dart`
- Test: `test/features/review/review_session_test.dart`
- Depends on: Task 1 (`ReviewCompleteSpec`, `pickReviewDistractors`)

- [ ] **Step 1: Write the failing test** `test/features/review/review_session_test.dart`

```dart
import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/features/lesson/activity_spec.dart';
import 'package:bambaruush/features/lesson/session_runner.dart';
import 'package:bambaruush/features/review/review_session.dart';
import 'package:bambaruush/models/item.dart';
import 'package:flutter_test/flutter_test.dart';

ContentRepository _content() {
  final json = jsonDecode(
    File('test/fixtures/content_valid.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return ContentRepository.fromJson(json);
}

void main() {
  final content = _content();
  final aav = content.wordById('word_aav');   // ItemType.word
  final letterA = content.letterById('letter_a'); // ItemType.letter
  const learned = ['word_aav', 'word_akh', 'word_baavgai', 'word_bombog'];

  group('pickActivityForItem', () {
    test('letter → always trace, any seed', () {
      for (var s = 0; s < 6; s++) {
        expect(pickActivityForItem(letterA, seed: s), ReviewActivityKind.trace);
      }
    });

    test('word → even seed Listen, odd seed Read (deterministic)', () {
      expect(pickActivityForItem(aav, seed: 0), ReviewActivityKind.listen);
      expect(pickActivityForItem(aav, seed: 2), ReviewActivityKind.listen);
      expect(pickActivityForItem(aav, seed: 1), ReviewActivityKind.read);
      expect(pickActivityForItem(aav, seed: 3), ReviewActivityKind.read);
    });
  });

  group('ReviewSession.buildSequence', () {
    List<Item> items() => [aav, letterA, content.wordById('word_akh')];

    test('one graded spec per item + a trailing ReviewCompleteSpec', () {
      final seq = ReviewSession.due(
        items: items(), content: content, learnedWordIds: learned, seed: 7,
      ).buildSequence();

      expect(seq.last, isA<ReviewCompleteSpec>());
      expect((seq.last as ReviewCompleteSpec).reviewedCount, 3);
      expect(seq.length, 4); // 3 graded + 1 complete

      // letter → Trace; words → Listen or Read.
      expect(seq.whereType<TraceSpec>().map((s) => s.letterId), ['letter_a']);
      final wordSpecs = seq.where((s) => s is ListenSpec || s is ReadSpec).toList();
      expect(wordSpecs, hasLength(2));
    });

    test('word specs carry 2 distractors that are not the target', () {
      final seq = ReviewSession.due(
        items: [aav], content: content, learnedWordIds: learned, seed: 4,
      ).buildSequence();
      final wordSpec = seq.firstWhere((s) => s is ListenSpec || s is ReadSpec);
      final distractors = wordSpec is ListenSpec
          ? wordSpec.distractorIds
          : (wordSpec as ReadSpec).distractorIds;
      expect(distractors, hasLength(2));
      expect(distractors, isNot(contains('word_aav')));
    });

    test('caps the session at 8 graded items', () {
      final many = List<Item>.generate(12, (_) => aav);
      final seq = ReviewSession.due(
        items: many, content: content, learnedWordIds: learned, seed: 1,
      ).buildSequence();
      expect(seq.whereType<ReviewCompleteSpec>(), hasLength(1));
      expect((seq.last as ReviewCompleteSpec).reviewedCount, 8);
      expect(seq.length, 9); // 8 graded + 1 complete
    });

    test('same seed yields an identical sequence', () {
      List<String> shape() => ReviewSession.due(
            items: items(), content: content, learnedWordIds: learned, seed: 9,
          ).buildSequence().map((s) {
            if (s is ListenSpec) return 'listen:${s.wordId}:${s.distractorIds.join(",")}';
            if (s is ReadSpec) return 'read:${s.wordId}:${s.distractorIds.join(",")}';
            if (s is TraceSpec) return 'trace:${s.letterId}';
            if (s is ReviewCompleteSpec) return 'done:${s.reviewedCount}';
            return s.runtimeType.toString();
          }).toList();
      expect(shape(), shape());
    });

    test('SessionRunner drives a review sequence to completion', () {
      final seq = ReviewSession.due(
        items: [aav], content: content, learnedWordIds: learned, seed: 0,
      ).buildSequence(); // [one graded word spec (Listen|Read), ReviewCompleteSpec]
      final runner = SessionRunner(sequence: seq);
      while (runner.state.current is! SessionComplete) {
        runner.advance(correct: true);
      }
      expect(runner.state.itemCorrectness['word:word_aav'], isTrue);
      // ReviewCompleteSpec is presentational — no extra correctness keys.
      expect(runner.state.itemCorrectness.keys, ['word:word_aav']);
    });
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/review/review_session_test.dart`
Expected: FAIL — `review_session.dart` / `pickActivityForItem` / `ReviewSession` undefined.

- [ ] **Step 3: Implement** `lib/features/review/review_session.dart`

```dart
import '../../core/content/content_repository.dart';
import '../../models/item.dart';
import '../lesson/activity_spec.dart';
import 'review_distractors.dart';

/// Graded activity kinds the review tool can choose from.
enum ReviewActivityKind { listen, read, trace }

/// Which graded activities each item type supports. Forward-looking seam: new
/// ItemTypes (verb, color…) add their compatible games here.
const gradedActivitiesFor = <ItemType, List<ReviewActivityKind>>{
  ItemType.word: [ReviewActivityKind.listen, ReviewActivityKind.read],
  ItemType.letter: [ReviewActivityKind.trace],
};

/// Deterministic given (item, seed): picks one compatible graded activity.
/// Words alternate Listen/Read by seed parity; letters are always Trace.
ReviewActivityKind pickActivityForItem(Item item, {required int seed}) {
  final options = gradedActivitiesFor[item.type];
  if (options == null || options.isEmpty) {
    throw StateError('No graded activities for item type ${item.type}');
  }
  return options[seed % options.length];
}

/// Builds a review activity sequence from due (or free-practice) items, reusing
/// the same ActivitySpecs as lessons. Caps the session and ends on a
/// ReviewCompleteSpec celebration.
class ReviewSession {
  ReviewSession.due({
    required this.items,
    required this.content,
    required this.learnedWordIds,
    this.seed,
  });
  ReviewSession.free({
    required this.items,
    required this.content,
    required this.learnedWordIds,
    this.seed,
  });

  final List<Item> items;
  final ContentRepository content;
  final List<String> learnedWordIds;
  final int? seed;

  static const sessionCap = 8;

  List<ActivitySpec> buildSequence() {
    final s = seed;
    final chosen = items.take(sessionCap).toList();
    final allWordIds = content.words.keys.toList();
    final specs = <ActivitySpec>[];

    for (var i = 0; i < chosen.length; i++) {
      final item = chosen[i];
      final kind = pickActivityForItem(item, seed: s == null ? i : Object.hash(s, i));
      switch (kind) {
        case ReviewActivityKind.listen:
          specs.add(ListenSpec(
            wordId: item.id,
            attempt: 1,
            distractorIds: _distractors(item.id, allWordIds, s),
          ));
        case ReviewActivityKind.read:
          specs.add(ReadSpec(
            wordId: item.id,
            attempt: 1,
            distractorIds: _distractors(item.id, allWordIds, s),
          ));
        case ReviewActivityKind.trace:
          specs.add(TraceSpec(letterId: item.id, attempt: 1));
      }
    }

    specs.add(ReviewCompleteSpec(reviewedCount: chosen.length));
    return specs;
  }

  List<String> _distractors(String wordId, List<String> allWordIds, int? s) =>
      pickReviewDistractors(
        targetWordId: wordId,
        learnedWordIds: learnedWordIds,
        allWordIds: allWordIds,
        n: 2,
        seed: s == null ? null : Object.hash(s, wordId),
      );
}
```

- [ ] **Step 4: Verify**

Run: `flutter test test/features/review/review_session_test.dart` → PASS
Run: `flutter analyze` → No issues.

---

## Task 3: Review queue (`dueReviewItems`, `freePracticeItems`) + providers

**Files:**
- Create: `lib/features/review/review_queue.dart`
- Test: `test/features/review/review_queue_test.dart`

- [ ] **Step 1: Write the failing test** `test/features/review/review_queue_test.dart`

```dart
import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/features/review/review_queue.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter_test/flutter_test.dart';

ContentRepository _content() {
  final json = jsonDecode(
    File('test/fixtures/content_valid.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return ContentRepository.fromJson(json);
}

SrsBox _box(String id, ItemType type, DateTime when) =>
    SrsBox(itemId: id, itemType: type, level: 1, nextReviewAt: when, correctStreak: 0);

void main() {
  final content = _content();
  final now = DateTime.utc(2026, 6, 3, 12);

  Map<String, SrsBox> srs() => {
        'word:word_aav': _box('word_aav', ItemType.word, now), // due now
        'word:word_akh': _box('word_akh', ItemType.word, now.subtract(const Duration(days: 2))), // more overdue
        'letter:letter_a': _box('letter_a', ItemType.letter, now.add(const Duration(days: 3))), // not due
        'word:word_ghost': _box('word_ghost', ItemType.word, now), // due but absent from content
      };

  test('dueReviewItems: only due, most-overdue-first, drops unknown ids', () {
    final due = dueReviewItems(srsByItem: srs(), content: content, now: now);
    expect(due.map((i) => i.id).toList(), ['word_akh', 'word_aav']);
    expect(due.every((i) => i is Item), isTrue);
  });

  test('freePracticeItems: all resolvable boxes, soonest-due-first, drops unknown', () {
    final pool = freePracticeItems(srsByItem: srs(), content: content);
    expect(pool.map((i) => i.id).toList(), ['word_akh', 'word_aav', 'letter_a']);
  });

  test('empty SRS → empty results', () {
    expect(dueReviewItems(srsByItem: {}, content: content, now: now), isEmpty);
    expect(freePracticeItems(srsByItem: {}, content: content), isEmpty);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/review/review_queue_test.dart`
Expected: FAIL — `review_queue.dart` / `dueReviewItems` / `freePracticeItems` undefined.

- [ ] **Step 3: Implement** `lib/features/review/review_queue.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content_repository.dart';
import '../../core/providers.dart';
import '../../core/srs/leitner_engine.dart';
import '../../models/item.dart';
import '../../models/srs_box.dart';

/// Resolve an SRS box to its concrete content Item, or null if the id no longer
/// exists. Word and Letter both implement Item.
Item? _itemForBox(SrsBox box, ContentRepository content) =>
    box.itemType == ItemType.word
        ? content.words[box.itemId]
        : content.letters[box.itemId];

List<Item> _resolve(List<SrsBox> boxes, ContentRepository content) {
  final out = <Item>[];
  for (final box in boxes) {
    final item = _itemForBox(box, content);
    if (item != null) out.add(item);
  }
  return out;
}

/// All due items, resolved to concrete Items (unknown ids dropped), sorted
/// most-overdue-first (earliest nextReviewAt first). Not capped — the badge uses
/// the length; the session caps.
List<Item> dueReviewItems({
  required Map<String, SrsBox> srsByItem,
  required ContentRepository content,
  required DateTime now,
}) {
  final due = LeitnerEngine.dueItems(srsByItem, now)
    ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
  return _resolve(due, content);
}

/// Items the child has already practiced (have an SRS box), resolved & sorted
/// soonest-due-first. Used for free practice when nothing is due.
List<Item> freePracticeItems({
  required Map<String, SrsBox> srsByItem,
  required ContentRepository content,
}) {
  final boxes = srsByItem.values.toList()
    ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
  return _resolve(boxes, content);
}

/// Due items right now (drives the map badge + the review entry gate).
final reviewQueueProvider = Provider<List<Item>>((ref) {
  final progress = ref.watch(progressControllerProvider);
  final content = ref.watch(contentRepositoryProvider);
  return dueReviewItems(
    srsByItem: progress.srsByItem,
    content: content,
    now: DateTime.now(),
  );
});

/// Learned items for "Practice anyway" when nothing is due.
final freePracticeProvider = Provider<List<Item>>((ref) {
  final progress = ref.watch(progressControllerProvider);
  final content = ref.watch(contentRepositoryProvider);
  return freePracticeItems(srsByItem: progress.srsByItem, content: content);
});
```

- [ ] **Step 4: Verify**

Run: `flutter test test/features/review/review_queue_test.dart` → PASS
Run: `flutter analyze` → No issues.

---

## Task 4: Shared `ActivityView` + `ReviewCompleteActivityView`

**Files:**
- Create: `lib/features/lesson/activity_view.dart`
- Create: `lib/features/lesson/review_complete_activity.dart`
- Modify: `lib/features/lesson/lesson_runner_screen.dart`
- Depends on: Task 1 (`ReviewCompleteSpec`)

**No new unit tests** (UI; widget tests hang). This is a behavior-preserving extraction — the existing `session_runner_test`/`lesson_session_test` and `flutter analyze` are the guard.

- [ ] **Step 1: Create** `lib/features/lesson/review_complete_activity.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';
import '../../widgets/confetti_burst.dart';
import '../mascot/mascot_controller.dart';
import 'activity_spec.dart';

/// Stars celebration at the end of a review session. No album sticker (those
/// stay tied to lessons) — just encouragement.
class ReviewCompleteActivityView extends ConsumerStatefulWidget {
  const ReviewCompleteActivityView({
    super.key,
    required this.spec,
    required this.onContinue,
  });
  final ReviewCompleteSpec spec;
  final VoidCallback onContinue;

  @override
  ConsumerState<ReviewCompleteActivityView> createState() =>
      _ReviewCompleteActivityViewState();
}

class _ReviewCompleteActivityViewState
    extends ConsumerState<ReviewCompleteActivityView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mascotProvider.notifier).cheer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.spec.reviewedCount;
    return Stack(
      children: [
        const ConfettiBurst(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Great practice!',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: AppColors.coral,
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 400))
                  .slideY(
                    begin: -0.4,
                    end: 0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 400),
                  ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    const Icon(Icons.star_rounded, size: 48, color: AppColors.sun)
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          curve: Curves.elasticOut,
                          duration: const Duration(milliseconds: 500),
                        ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                count == 1
                    ? 'You practiced 1 item!'
                    : 'You practiced $count items!',
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 24),
              CandyButton(
                label: 'Done',
                icon: Icons.check_rounded,
                onPressed: widget.onContinue,
                color: AppColors.meadow,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Create** `lib/features/lesson/activity_view.dart` (the switch, lifted verbatim from `lesson_runner_screen._activityWidget`, plus the `ReviewCompleteSpec` case)

```dart
import 'package:flutter/material.dart';

import 'activity_spec.dart';
import 'intro_activity.dart';
import 'listen_activity.dart';
import 'read_activity.dart';
import 'review_complete_activity.dart';
import 'reward_activity.dart';
import 'session_runner.dart';
import 'trace_activity.dart';

/// Renders any [ActivitySpec] to its game/celebration widget, wiring results
/// back to [runner]. Shared by the lesson and review runner screens — the single
/// place that knows spec→widget, so adding an activity never drifts.
class ActivityView extends StatelessWidget {
  const ActivityView({super.key, required this.spec, required this.runner});

  final ActivitySpec spec;
  final SessionRunner runner;

  @override
  Widget build(BuildContext context) {
    final s = spec;
    if (s is IntroSpec) {
      return IntroActivityView(
        spec: s,
        onContinue: () => runner.advance(correct: true),
      );
    }
    if (s is TraceSpec) {
      return TraceActivityView(spec: s, onResult: runner.advance);
    }
    if (s is ListenSpec) {
      return ListenActivityView(
        key: ValueKey('listen-${s.wordId}-${s.attempt}'),
        spec: s,
        onResult: runner.advance,
      );
    }
    if (s is ReadSpec) {
      return ReadActivityView(
        key: ValueKey('read-${s.wordId}-${s.attempt}'),
        spec: s,
        onResult: runner.advance,
      );
    }
    if (s is RewardSpec) {
      return RewardActivityView(
        spec: s,
        onContinue: () => runner.advance(correct: true),
      );
    }
    if (s is ReviewCompleteSpec) {
      return ReviewCompleteActivityView(
        spec: s,
        onContinue: () => runner.advance(correct: true),
      );
    }
    return const SizedBox.shrink(); // SessionComplete
  }
}
```

- [ ] **Step 3: Refactor `lesson_runner_screen.dart` to use `ActivityView`**

In `lib/features/lesson/lesson_runner_screen.dart`:
1. Replace the body usage `_activityWidget(state, runner)` with `ActivityView(spec: state.current, runner: runner)`.
2. Delete the private `_activityWidget(...)` method entirely.
3. Update imports: **add** `import 'activity_view.dart';`; **remove** the now-unused `import 'intro_activity.dart';`, `import 'read_activity.dart';`, `import 'reward_activity.dart';`, `import 'trace_activity.dart';`, and `import 'listen_activity.dart';` (they moved into `activity_view.dart`). Keep `activity_spec.dart`, `lesson_session.dart`, `session_runner.dart`, `srs_update.dart` imports — still used.

The body `Stack` becomes:

```dart
body: Stack(
  children: [
    ActivityView(spec: state.current, runner: runner),
    Positioned(
      top: 8,
      left: 16,
      right: 16,
      child: LinearProgressIndicator(
        value: state.totalSteps == 0 ? 0 : state.currentStep / state.totalSteps,
      ),
    ),
    const MascotOverlay(),
  ],
),
```

- [ ] **Step 4: Verify (behavior-preserving)**

Run: `flutter analyze` → No issues (watch for unused-import warnings — remove any flagged).
Run: `flutter test` → entire existing suite still passes (49+ tests).
Run: `flutter build web --debug` → builds. (Lesson flow unchanged.)

---

## Task 5: `ReviewRunnerScreen` + provider + `/review` route

**Files:**
- Create: `lib/features/review/review_runner_screen.dart`
- Modify: `lib/core/routing/app_router.dart`
- Depends on: Tasks 2, 3, 4

**No new unit tests** (screen; widget tests hang). Verify via analyze + web build.

- [ ] **Step 1: Create** `lib/features/review/review_runner_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../models/item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';
import '../lesson/activity_spec.dart';
import '../lesson/activity_view.dart';
import '../lesson/session_runner.dart';
import '../lesson/srs_update.dart';
import '../mascot/mascot_overlay.dart';
import 'review_queue.dart';
import 'review_session.dart';

enum ReviewMode { due, free }

/// Fresh runner per entry, keyed by mode. Reads the item list once at creation
/// (ref.read, not watch) so the session is fixed for its duration.
final reviewRunnerProvider = StateNotifierProvider.autoDispose
    .family<SessionRunner, SessionRunnerState, ReviewMode>((ref, mode) {
  final content = ref.watch(contentRepositoryProvider);
  final srs = ref.read(progressControllerProvider).srsByItem;
  final learnedWordIds = <String>[
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

class ReviewRunnerScreen extends ConsumerStatefulWidget {
  const ReviewRunnerScreen({super.key});

  @override
  ConsumerState<ReviewRunnerScreen> createState() => _ReviewRunnerScreenState();
}

class _ReviewRunnerScreenState extends ConsumerState<ReviewRunnerScreen> {
  // Locked at entry so a post-session progress change can't flip us back to the
  // gate before we pop.
  ReviewMode? _mode;

  @override
  void initState() {
    super.initState();
    if (ref.read(reviewQueueProvider).isNotEmpty) {
      _mode = ReviewMode.due;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    if (mode == null) {
      return _CaughtUpView(
        canPractice: ref.watch(freePracticeProvider).isNotEmpty,
        onPractice: () => setState(() => _mode = ReviewMode.free),
        onBack: () => context.pop(),
      );
    }
    return _RunningView(mode: mode);
  }
}

class _RunningView extends ConsumerWidget {
  const _RunningView({required this.mode});
  final ReviewMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewRunnerProvider(mode));
    final runner = ref.read(reviewRunnerProvider(mode).notifier);

    ref.listen<SessionRunnerState>(reviewRunnerProvider(mode), (prev, next) async {
      if (next.current is SessionComplete && prev?.current is! SessionComplete) {
        await _persistReview(ref, next);
        if (context.mounted) context.pop();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmQuit(context) && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmQuit(context) && context.mounted) context.pop();
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

Future<void> _persistReview(WidgetRef ref, SessionRunnerState s) async {
  final progress = ref.read(progressControllerProvider);
  final now = DateTime.now();
  final newSrs = applySessionToSrs(
    current: progress.srsByItem,
    itemCorrectness: s.itemCorrectness,
    now: now,
  );
  await ref.read(progressControllerProvider.notifier).update(
        progress.copyWith(srsByItem: newSrs, lastPlayed: now),
      );
}

Future<bool> _confirmQuit(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Stop practice?'),
      content: const Text('Your practice progress will not be saved.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Keep playing'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Stop'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _CaughtUpView extends StatelessWidget {
  const _CaughtUpView({
    required this.canPractice,
    required this.onPractice,
    required this.onBack,
  });
  final bool canPractice;
  final VoidCallback onPractice;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nothing needs review right now.',
              style: TextStyle(fontSize: 16, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 28),
            if (canPractice) ...[
              CandyButton(
                label: 'Practice anyway',
                icon: Icons.bolt_rounded,
                onPressed: onPractice,
                color: AppColors.meadow,
              ),
              const SizedBox(height: 12),
            ],
            CandyButton(
              label: 'Back to map',
              icon: Icons.map_rounded,
              onPressed: onBack,
              color: AppColors.sky,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Add the `/review` route in `app_router.dart`**

Add the import and a route inside `routes: [...]` (e.g. after the `/lesson/:id` route):

```dart
import '../../features/review/review_runner_screen.dart';
```
```dart
GoRoute(path: '/review', builder: (_, __) => const ReviewRunnerScreen()),
```

- [ ] **Step 3: Verify**

Run: `flutter analyze` → No issues.
Run: `flutter test` → existing suite still green.
Run: `flutter build web --debug` → builds.

---

## Task 6: Practice landmark on the Steppe map

**Files:**
- Modify: `lib/features/steppe/steppe_map_screen.dart`
- Depends on: Task 3 (`reviewQueueProvider`), Task 5 (`/review` route)

**No new unit tests** (map UI). Verify via analyze + web build.

- [ ] **Step 1: Add the anchor constant + import**

In `lib/features/steppe/steppe_map_screen.dart` add the import:

```dart
import '../review/review_queue.dart';
```

and next to `_kMapImageHeight`:

```dart
// Practice landmark anchor (image-normalized, lower-left, clear of the Ger at
// [0.5, 0.63]). Nudge to taste like the region tiles.
const Offset _kPracticeAnchor = Offset(0.22, 0.82);
```

- [ ] **Step 2: Read the due count in `build` and place the marker**

In `SteppeMapScreen.build`, after `final progress = ref.watch(progressControllerProvider);` add:

```dart
final dueCount = ref.watch(reviewQueueProvider).length;
```

Inside the `Stack` children, **before** `const MascotOverlay()`, add:

```dart
Positioned(
  left: offsetX + _kPracticeAnchor.dx * dispW,
  top: offsetY + _kPracticeAnchor.dy * dispH,
  child: FractionalTranslation(
    translation: const Offset(-0.5, -0.5),
    child: _PracticeLandmark(
      dueCount: dueCount,
      onTap: () => context.push('/review'),
    ),
  ),
),
```

- [ ] **Step 3: Add the `_PracticeLandmark` widget** (bottom of the file, beside `_RegionTile`)

```dart
class _PracticeLandmark extends StatelessWidget {
  const _PracticeLandmark({required this.dueCount, required this.onTap});

  /// Number of items due for review; shows a badge when > 0.
  final int dueCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.95,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.tile),
              border: Border.all(color: AppColors.cardBorder, width: 2),
              boxShadow: const [kSoftShadow],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_stories_rounded, size: 28, color: AppColors.coral),
                SizedBox(height: 2),
                Text(
                  'Practice',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          if (dueCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                constraints: const BoxConstraints(minWidth: 22),
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  dueCount > 9 ? '9+' : '$dueCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Verify**

Run: `flutter analyze` → No issues.
Run: `flutter test` → existing suite green.
Run: `flutter build web --debug` → builds. (Manual: the Practice tile appears on the map and opens `/review`.)

---

## Final verification (after all tasks)

- [ ] `flutter analyze` → **No issues found!**
- [ ] `flutter test` → all green (existing + 3 new review test files: distractors, session, queue).
- [ ] `flutter build web --debug` → builds.
- [ ] Spot-check the data flow end-to-end: complete a lesson → items get SRS boxes; on a day when items are due the Practice badge shows a count and `/review` runs a session; with nothing due, the gate shows "All caught up!" + "Practice anyway". (Human/web check.)

## Out of scope (Slice 5+)

Daily warm-up (`/warmup`, once/day), `isWarmup` flag, rotating daily sticker, `lastWarmupAt` on `Progress` — deferred. The `ReviewMode`/`ReviewSession.free` seam is where warm-up plugs in.
