# Slice 3 — Generalize SRS to Items — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the SRS track words **and** letters: add an `Item`/`ItemType` supertype, key the SRS by item (`srsByItem`), and seed letters from the Trace activity's first-attempt result — with no user-visible behavior change.

**Architecture:** `abstract interface class Item` + `enum ItemType { word, letter }`; `Word`/`Letter` implement it. `SrsBox` keyed by `itemId`+`itemType`; `Progress.srsByItem` keyed `"type:id"`. `SessionRunner` generalizes `wordCorrectness` → `itemCorrectness` (records Trace for letters); `_persistCompletion` updates boxes for every word + letter (track-everything). `LeitnerEngine` gains `dueItems`.

**Tech Stack:** Flutter · Dart 3 · freezed/json_serializable · flutter_riverpod

**Spec:** `docs/superpowers/specs/2026-06-03-srs-items-design.md`

**Scope guard:** No ReviewSession/queue/landmark (Slice 4), no warm-up/`lastWarmupAt` (Slice 5), no sub-categories `LetterCategory`/`WordGroup` (Slice 7). Schema change = clean fresh-start, no migration.

**No git commit steps** — user manages git. Pause after each task to commit.

---

## File map

```
lib/models/item.dart                    CREATE — ItemType enum, Item interface, itemKeyOf(), Item.key extension
lib/models/word.dart                    MODIFY — implements Item (+ type getter)
lib/models/letter.dart                  MODIFY — implements Item (+ const Letter._(); + type getter)
lib/models/srs_box.dart                 MODIFY — wordId → itemId + itemType
lib/core/srs/leitner_engine.dart        MODIFY — initial(id,type,now); add dueItems()
lib/models/progress.dart                MODIFY — srsByWord → srsByItem; schemaVersion 2
lib/core/persistence/progress_repository.dart  MODIFY — _currentSchemaVersion → 2
lib/features/lesson/lesson_runner_screen.dart  MODIFY — _persistCompletion keyed by item (words T2, +letters T3)
lib/features/lesson/session_runner.dart        MODIFY (T3) — wordCorrectness → itemCorrectness (track Trace)
lib/features/lesson/srs_update.dart     CREATE (T3) — pure applySessionToSrs() helper
test/models/item_test.dart              CREATE (T1)
test/core/srs/leitner_engine_test.dart  MODIFY (T2) — itemId/itemType + dueItems test
test/features/lesson/session_runner_test.dart  MODIFY (T3) — itemCorrectness keys + letter test
test/features/lesson/srs_update_test.dart      CREATE (T3)
```

---

## Task 1: `Item` + `ItemType`; `Word`/`Letter` implement it

Additive — nothing breaks. Ends green.

**Files:** Create `lib/models/item.dart`, `test/models/item_test.dart`; Modify `lib/models/word.dart`, `lib/models/letter.dart`.

- [ ] **Step 1: Failing test** — `test/models/item_test.dart`:

```dart
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/letter.dart';
import 'package:bambaruush/models/word.dart';
import 'package:bambaruush/models/word_localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Word is an Item of type word with the right key', () {
    const w = Word(
      id: 'word_aav',
      imageAssetPath: 'assets/images/words/word_aav.png',
      letterIds: ['letter_a'],
      localizations: {'mn': WordLocalization(text: 'Аав'), 'en': WordLocalization(text: 'father')},
    );
    expect(w, isA<Item>());
    expect(w.type, ItemType.word);
    expect(w.key, 'word:word_aav');
  });

  test('Letter is an Item of type letter with the right key', () {
    const l = Letter(
      id: 'letter_a',
      cyrillic: 'А',
      romanization: 'A',
      audioAssetPath: 'assets/audio/letter_a.mp3',
      traceTemplatePath: 'assets/trace_masks/letter_a.png',
    );
    expect(l, isA<Item>());
    expect(l.type, ItemType.letter);
    expect(l.key, 'letter:letter_a');
  });

  test('itemKeyOf builds "type:id"', () {
    expect(itemKeyOf(ItemType.word, 'x'), 'word:x');
    expect(itemKeyOf(ItemType.letter, 'y'), 'letter:y');
  });
}
```

Run: `flutter test test/models/item_test.dart` → FAIL (Item/ItemType undefined).

- [ ] **Step 2: Create `lib/models/item.dart`**

```dart
/// The kind of a reviewable item. Open taxonomy: today {word, letter}; future
/// types (verb, color, place, character…) extend the enum, and every
/// `switch (item.type)` will be flagged by the analyzer to handle them.
enum ItemType { word, letter }

/// A reviewable unit the SRS tracks and activities quiz. `Word` and `Letter`
/// implement this; they keep their own distinct fields.
abstract interface class Item {
  String get id;
  ItemType get type;
}

/// Stable key used for SRS maps and correctness tracking: "word:word_aav".
String itemKeyOf(ItemType type, String id) => '${type.name}:$id';

extension ItemKey on Item {
  String get key => itemKeyOf(type, id);
}
```

- [ ] **Step 3: `Word` implements `Item`** — in `lib/models/word.dart`, add the import and make `Word` implement `Item` with a `type` getter. `Word` already has `const Word._();` (from Slice 2), so add the getter there.

Add import (with the other imports):
```dart
import 'item.dart';
```
Change the class declaration line `class Word with _$Word {` → `class Word with _$Word implements Item {`, and inside the class (alongside the existing `const Word._();` private constructor and the `text`/`audioPath` methods) add:
```dart
  @override
  ItemType get type => ItemType.word;
```
(`id` is already a field, satisfying `Item.id`.)

- [ ] **Step 4: `Letter` implements `Item`** — `lib/models/letter.dart` currently has no private constructor. Add one + the import + `type`.

Add import:
```dart
import 'item.dart';
```
Change `class Letter with _$Letter {` → `class Letter with _$Letter implements Item {`, and add inside the class (above the factory):
```dart
  const Letter._();

  @override
  ItemType get type => ItemType.letter;
```
(`id` field satisfies `Item.id`. Adding `const Letter._();` is required so freezed lets the class declare the `type` getter.)

- [ ] **Step 5: Regenerate + verify**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/models/item_test.dart` → 3 PASS.
Run: `flutter analyze` → clean. Run: `flutter test` → all pass (purely additive).

**Checkpoint:** `Item`/`ItemType` exist; Word/Letter conform. Pause to commit.

---

## Task 2: SRS keyed by item (`SrsBox` + `LeitnerEngine` + `Progress` + persistence)

Generalizes the SRS plumbing. Words still the only thing seeded (behavior-preserving); letters arrive in Task 3. This is the big atomic rename — all references update together.

**Files:** Modify `lib/models/srs_box.dart`, `lib/core/srs/leitner_engine.dart`, `lib/models/progress.dart`, `lib/core/persistence/progress_repository.dart`, `lib/features/lesson/lesson_runner_screen.dart`, `test/core/srs/leitner_engine_test.dart`.

- [ ] **Step 1: Update `leitner_engine_test.dart` (failing) for the new API + `dueItems`**

Replace `test/core/srs/leitner_engine_test.dart` with:

```dart
import 'package:bambaruush/core/srs/leitner_engine.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 5, 27, 12);

  test('initial box is level 1 due now, carrying item id + type', () {
    final box = LeitnerEngine.initial('word_x', ItemType.word, now);
    expect(box.itemId, 'word_x');
    expect(box.itemType, ItemType.word);
    expect(box.level, 1);
    expect(box.correctStreak, 0);
    expect(box.nextReviewAt, now);
  });

  test('onCorrect promotes one level, schedules next interval', () {
    final box = LeitnerEngine.initial('word_x', ItemType.word, now);
    final next = LeitnerEngine.onCorrect(box, now);
    expect(next.level, 2);
    expect(next.correctStreak, 1);
    expect(next.nextReviewAt, now.add(const Duration(days: 3)));
  });

  test('promotion clamps at level 5', () {
    var box = LeitnerEngine.initial('letter_a', ItemType.letter, now);
    for (var i = 0; i < 10; i++) {
      box = LeitnerEngine.onCorrect(box, now);
    }
    expect(box.level, 5);
    expect(box.nextReviewAt, now.add(const Duration(days: 30)));
  });

  test('onWrong drops to level 1 and resets streak', () {
    var box = LeitnerEngine.initial('word_x', ItemType.word, now);
    box = LeitnerEngine.onCorrect(box, now);
    box = LeitnerEngine.onWrong(box, now);
    expect(box.level, 1);
    expect(box.correctStreak, 0);
    expect(box.nextReviewAt, now.add(const Duration(days: 1)));
  });

  test('isDue is true at or after nextReviewAt', () {
    final box = SrsBox(itemId: 'w', itemType: ItemType.word, level: 1, nextReviewAt: now, correctStreak: 0);
    expect(LeitnerEngine.isDue(box, now), isTrue);
    expect(LeitnerEngine.isDue(box, now.subtract(const Duration(seconds: 1))), isFalse);
  });

  test('dueItems returns only the boxes that are due now', () {
    final due = SrsBox(itemId: 'word_a', itemType: ItemType.word, level: 1, nextReviewAt: now, correctStreak: 0);
    final notDue = SrsBox(itemId: 'letter_a', itemType: ItemType.letter, level: 2, nextReviewAt: now.add(const Duration(days: 3)), correctStreak: 1);
    final srs = {due.itemId: due, 'letter:letter_a': notDue}; // keys arbitrary here
    final result = LeitnerEngine.dueItems(srs, now);
    expect(result, contains(due));
    expect(result, isNot(contains(notDue)));
  });
}
```

Run: `flutter test test/core/srs/leitner_engine_test.dart` → FAIL (itemId/itemType/dueItems/3-arg initial don't exist).

- [ ] **Step 2: Generalize `lib/models/srs_box.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'item.dart';

part 'srs_box.freezed.dart';
part 'srs_box.g.dart';

@freezed
class SrsBox with _$SrsBox {
  const factory SrsBox({
    required String itemId,
    required ItemType itemType,
    required int level,
    required DateTime nextReviewAt,
    required int correctStreak,
  }) = _SrsBox;

  factory SrsBox.fromJson(Map<String, dynamic> json) => _$SrsBoxFromJson(json);
}
```

- [ ] **Step 3: Generalize `lib/core/srs/leitner_engine.dart`**

```dart
import '../../models/item.dart';
import '../../models/srs_box.dart';

class LeitnerEngine {
  static const intervals = <int, Duration>{
    1: Duration(days: 1),
    2: Duration(days: 3),
    3: Duration(days: 7),
    4: Duration(days: 14),
    5: Duration(days: 30),
  };

  static SrsBox initial(String id, ItemType type, DateTime now) => SrsBox(
        itemId: id,
        itemType: type,
        level: 1,
        nextReviewAt: now,
        correctStreak: 0,
      );

  static SrsBox onCorrect(SrsBox box, DateTime now) {
    final newLevel = (box.level + 1).clamp(1, 5);
    return box.copyWith(
      level: newLevel,
      nextReviewAt: now.add(intervals[newLevel]!),
      correctStreak: box.correctStreak + 1,
    );
  }

  static SrsBox onWrong(SrsBox box, DateTime now) => box.copyWith(
        level: 1,
        nextReviewAt: now.add(intervals[1]!),
        correctStreak: 0,
      );

  static bool isDue(SrsBox box, DateTime now) => !now.isBefore(box.nextReviewAt);

  /// All boxes that are due for review at [now].
  static List<SrsBox> dueItems(Map<String, SrsBox> srsByItem, DateTime now) =>
      srsByItem.values.where((b) => isDue(b, now)).toList();
}
```

- [ ] **Step 4: `Progress` — `srsByWord` → `srsByItem`, schemaVersion 2** in `lib/models/progress.dart`

Change the field `required Map<String, SrsBox> srsByWord,` → `required Map<String, SrsBox> srsByItem,`, and in `Progress.empty()` change `srsByWord: const {},` → `srsByItem: const {},` and `schemaVersion: 1,` → `schemaVersion: 2,`.

- [ ] **Step 5: Bump the repository schema constant** in `lib/core/persistence/progress_repository.dart`

Change `static const _currentSchemaVersion = 1;` → `static const _currentSchemaVersion = 2;`. (Existing v1 progress files now mismatch → `load()` returns `Progress.empty()` — clean reset, no real users.)

- [ ] **Step 6: Update `_persistCompletion` in `lib/features/lesson/lesson_runner_screen.dart`** to key the SRS by item (words only this task)

Add import: `import '../../models/item.dart';`. In `_persistCompletion`, replace the SRS block:
```dart
    final newSrs = {...progress.srsByWord};
    for (final wid in lesson.wordIds) {
      final correct = s.wordCorrectness[wid] ?? false;
      final existing = newSrs[wid] ?? LeitnerEngine.initial(wid, now);
      newSrs[wid] = correct
          ? LeitnerEngine.onCorrect(existing, now)
          : LeitnerEngine.onWrong(existing, now);
    }
```
with:
```dart
    final newSrs = {...progress.srsByItem};
    for (final wid in lesson.wordIds) {
      final key = itemKeyOf(ItemType.word, wid);
      final correct = s.wordCorrectness[wid] ?? false;
      final existing = newSrs[key] ?? LeitnerEngine.initial(wid, ItemType.word, now);
      newSrs[key] = correct
          ? LeitnerEngine.onCorrect(existing, now)
          : LeitnerEngine.onWrong(existing, now);
    }
```
and change the `progress.copyWith(... srsByWord: newSrs ...)` → `srsByItem: newSrs`.

- [ ] **Step 7: Regenerate + verify**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/core/srs/leitner_engine_test.dart` → PASS.
Run: `flutter analyze` → clean. If it flags any other `srsByWord` / `SrsBox(wordId:` / `initial(<id>, now)` reference, fix it (e.g. `progress_repository_test` if it constructs SrsBox — update to `itemId`/`itemType`). Run: `flutter test` → all pass.

**Checkpoint:** SRS keyed by item; words flow through it as `"word:id"`. Pause to commit.

---

## Task 3: Track letters (Trace) in `SessionRunner` + seed letters in `_persistCompletion`

Now letters enter the SRS. Generalize the runner's correctness map and extract a tested SRS-update helper.

**Files:** Modify `lib/features/lesson/session_runner.dart`, `lib/features/lesson/lesson_runner_screen.dart`, `test/features/lesson/session_runner_test.dart`; Create `lib/features/lesson/srs_update.dart`, `test/features/lesson/srs_update_test.dart`.

- [ ] **Step 1: Update `session_runner_test.dart` (failing) — itemCorrectness + a Trace/letter case**

Replace `test/features/lesson/session_runner_test.dart` with:

```dart
import 'package:bambaruush/features/lesson/activity_spec.dart';
import 'package:bambaruush/features/lesson/session_runner.dart';
import 'package:flutter_test/flutter_test.dart';

List<ActivitySpec> _seq() => const [
      IntroSpec('letter_a'),
      TraceSpec(letterId: 'letter_a', attempt: 1),
      ListenSpec(wordId: 'word_aav', distractorIds: ['word_x', 'word_y'], attempt: 1),
      ListenSpec(wordId: 'word_akh', distractorIds: ['word_x', 'word_y'], attempt: 1),
      ReadSpec(wordId: 'word_aav', distractorIds: ['word_x', 'word_y'], attempt: 1),
      ReadSpec(wordId: 'word_akh', distractorIds: ['word_x', 'word_y'], attempt: 1),
      RewardSpec('sticker_x'),
    ];

void main() {
  test('drives the sequence in order, then SessionComplete', () {
    final runner = SessionRunner(sequence: _seq());
    final seen = <Type>[];
    while (runner.state.current is! SessionComplete) {
      seen.add(runner.state.current.runtimeType);
      runner.advance(correct: true);
    }
    expect(seen, [
      IntroSpec, TraceSpec, ListenSpec, ListenSpec, ReadSpec, ReadSpec, RewardSpec,
    ]);
  });

  test('all-correct leaves every item correct (keyed type:id)', () {
    final runner = SessionRunner(sequence: _seq());
    while (runner.state.current is! SessionComplete) {
      runner.advance(correct: true);
    }
    expect(runner.state.itemCorrectness['word:word_aav'], isTrue);
    expect(runner.state.itemCorrectness['word:word_akh'], isTrue);
    expect(runner.state.itemCorrectness['letter:letter_a'], isTrue);
  });

  test('a wrong Trace marks the letter incorrect', () {
    final runner = SessionRunner(sequence: _seq());
    runner.advance(correct: true); // intro
    runner.advance(correct: false); // trace fails
    runner.advance(correct: true); // listen aav
    runner.advance(correct: true); // listen akh
    runner.advance(correct: true); // read aav
    runner.advance(correct: true); // read akh
    runner.advance(correct: true); // reward → complete
    expect(runner.state.current, isA<SessionComplete>());
    expect(runner.state.itemCorrectness['letter:letter_a'], isFalse);
    expect(runner.state.itemCorrectness['word:word_aav'], isTrue);
  });

  test('attempt-1 wrong on Listen retries (same tiles) then records fail', () {
    final runner = SessionRunner(sequence: _seq());
    runner.advance(correct: true); // intro
    runner.advance(correct: true); // trace
    runner.advance(correct: true); // listen aav pass
    runner.advance(correct: false); // listen akh fail attempt 1
    final cur = runner.state.current as ListenSpec;
    expect(cur.wordId, 'word_akh');
    expect(cur.attempt, 2);
    expect(cur.distractorIds, ['word_x', 'word_y']);
    runner.advance(correct: true); // attempt 2 advances; records fail
    expect(runner.state.itemCorrectness['word:word_akh'], isFalse);
  });
}
```

Run: `flutter test test/features/lesson/session_runner_test.dart` → FAIL (`itemCorrectness` doesn't exist; letters not tracked).

- [ ] **Step 2: Generalize `lib/features/lesson/session_runner.dart`**

Replace the whole file with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/item.dart';
import 'activity_spec.dart';

class SessionRunnerState {
  SessionRunnerState({
    required this.current,
    required this.totalSteps,
    required this.currentStep,
    required this.itemCorrectness,
  });

  final ActivitySpec current;
  final int totalSteps;
  final int currentStep;

  /// First-attempt correctness per item, keyed "type:id" (e.g. "word:word_aav",
  /// "letter:letter_a"). Words come from Listen/Read; letters from Trace.
  final Map<String, bool> itemCorrectness;

  SessionRunnerState copyWith({
    ActivitySpec? current,
    int? currentStep,
    Map<String, bool>? itemCorrectness,
  }) =>
      SessionRunnerState(
        current: current ?? this.current,
        totalSteps: totalSteps,
        currentStep: currentStep ?? this.currentStep,
        itemCorrectness: itemCorrectness ?? this.itemCorrectness,
      );
}

/// Drives a prebuilt [ActivitySpec] sequence, tracking first-attempt correctness
/// per item. Listen/Read use the attempt-1 → attempt-2 retry; Trace reports its
/// final first-attempt result once (the widget self-manages its retry).
class SessionRunner extends StateNotifier<SessionRunnerState> {
  SessionRunner({required List<ActivitySpec> sequence})
      : _sequence = sequence,
        super(_initialState(sequence)) {
    _itemKeys = _itemKeysOf(sequence);
  }

  final List<ActivitySpec> _sequence;
  late final List<String> _itemKeys;
  final Map<String, bool> _firstAttemptCorrect = {};

  static SessionRunnerState _initialState(List<ActivitySpec> sequence) {
    final keys = _itemKeysOf(sequence);
    return SessionRunnerState(
      current: sequence.first,
      totalSteps: sequence.length,
      currentStep: 0,
      itemCorrectness: {for (final k in keys) k: true},
    );
  }

  static List<String> _itemKeysOf(List<ActivitySpec> seq) {
    final keys = <String>[];
    void add(String k) {
      if (!keys.contains(k)) keys.add(k);
    }
    for (final s in seq) {
      if (s is ListenSpec) add(itemKeyOf(ItemType.word, s.wordId));
      if (s is ReadSpec) add(itemKeyOf(ItemType.word, s.wordId));
      if (s is TraceSpec) add(itemKeyOf(ItemType.letter, s.letterId));
    }
    return keys;
  }

  void advance({required bool correct}) {
    final cur = state.current;

    if (cur is ListenSpec || cur is ReadSpec) {
      final wordId = cur is ListenSpec ? cur.wordId : (cur as ReadSpec).wordId;
      final attempt = cur is ListenSpec ? cur.attempt : (cur as ReadSpec).attempt;
      final key = itemKeyOf(ItemType.word, wordId);

      if (attempt == 1 && !correct) {
        _firstAttemptCorrect[key] = false;
        final retry = cur is ListenSpec
            ? ListenSpec(wordId: cur.wordId, distractorIds: cur.distractorIds, attempt: 2)
            : ReadSpec(
                wordId: (cur as ReadSpec).wordId,
                distractorIds: cur.distractorIds,
                attempt: 2);
        state = state.copyWith(current: retry, itemCorrectness: _compute());
        return;
      }
      if (attempt == 1 && correct) {
        _firstAttemptCorrect[key] = _firstAttemptCorrect[key] ?? true;
      } else {
        _firstAttemptCorrect[key] = false;
      }
    } else if (cur is TraceSpec) {
      // Trace reports its final first-attempt result once; record a miss.
      if (!correct) {
        _firstAttemptCorrect[itemKeyOf(ItemType.letter, cur.letterId)] = false;
      }
    }

    final nextIndex = state.currentStep + 1;
    if (nextIndex >= _sequence.length) {
      state = state.copyWith(
        current: const SessionComplete(),
        currentStep: nextIndex,
        itemCorrectness: _compute(),
      );
      return;
    }
    state = state.copyWith(
      current: _sequence[nextIndex],
      currentStep: nextIndex,
      itemCorrectness: _compute(),
    );
  }

  Map<String, bool> _compute() => {
        for (final k in _itemKeys) k: _firstAttemptCorrect[k] ?? true,
      };
}
```

Run: `flutter test test/features/lesson/session_runner_test.dart` → PASS.

- [ ] **Step 3: Failing test for the SRS-update helper** — `test/features/lesson/srs_update_test.dart`:

```dart
import 'package:bambaruush/features/lesson/srs_update.dart';
import 'package:bambaruush/models/item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 6, 3, 12);

  test('creates boxes for words AND letters from itemCorrectness', () {
    final srs = applySessionToSrs(
      current: const {},
      items: [
        (type: ItemType.word, id: 'word_aav'),
        (type: ItemType.letter, id: 'letter_a'),
      ],
      itemCorrectness: const {'word:word_aav': true, 'letter:letter_a': false},
      now: now,
    );
    // word answered right → promoted past level 1
    expect(srs['word:word_aav']!.level, 2);
    expect(srs['word:word_aav']!.itemType, ItemType.word);
    // letter missed → stays/reset to level 1
    expect(srs['letter:letter_a']!.level, 1);
    expect(srs['letter:letter_a']!.itemType, ItemType.letter);
  });

  test('missing correctness entry defaults to wrong', () {
    final srs = applySessionToSrs(
      current: const {},
      items: [(type: ItemType.word, id: 'word_x')],
      itemCorrectness: const {},
      now: now,
    );
    expect(srs['word:word_x']!.level, 1);
  });
}
```

Run: `flutter test test/features/lesson/srs_update_test.dart` → FAIL.

- [ ] **Step 4: Create `lib/features/lesson/srs_update.dart`**

```dart
import '../../core/srs/leitner_engine.dart';
import '../../models/item.dart';
import '../../models/srs_box.dart';

/// Applies a session's first-attempt results to the SRS map (track-everything:
/// every listed item gets created/updated). Pure → easy to test.
Map<String, SrsBox> applySessionToSrs({
  required Map<String, SrsBox> current,
  required List<({ItemType type, String id})> items,
  required Map<String, bool> itemCorrectness,
  required DateTime now,
}) {
  final next = {...current};
  for (final item in items) {
    final key = itemKeyOf(item.type, item.id);
    final correct = itemCorrectness[key] ?? false;
    final box = next[key] ?? LeitnerEngine.initial(item.id, item.type, now);
    next[key] =
        correct ? LeitnerEngine.onCorrect(box, now) : LeitnerEngine.onWrong(box, now);
  }
  return next;
}
```

Run: `flutter test test/features/lesson/srs_update_test.dart` → PASS.

- [ ] **Step 5: Use the helper in `_persistCompletion` (now seeds letters too)** in `lib/features/lesson/lesson_runner_screen.dart`

Add import: `import 'srs_update.dart';`. Replace the inline SRS block (from Task 2) and the `s.wordCorrectness` reference with:

```dart
    final newSrs = applySessionToSrs(
      current: progress.srsByItem,
      items: [
        for (final wid in lesson.wordIds) (type: ItemType.word, id: wid),
        for (final lid in lesson.letterIds) (type: ItemType.letter, id: lid),
      ],
      itemCorrectness: s.itemCorrectness,
      now: now,
    );
```
Keep `progress.copyWith(srsByItem: newSrs, ...)`. The `s` is now a `SessionRunnerState` whose field is `itemCorrectness` (renamed in Step 2) — ensure the listener/typing references `itemCorrectness`, not `wordCorrectness`. Remove the now-unused `LeitnerEngine`/`itemKeyOf` imports if they're no longer referenced directly (the helper encapsulates them); keep whatever analyze says is still used.

- [ ] **Step 6: Regenerate (if needed) + verify**

Run: `flutter analyze` → clean. (Fixes any lingering `wordCorrectness` reference — the screen must read `s.itemCorrectness`.)
Run: `flutter test` → all pass.
Run: `flutter build web --debug` → builds.

- [ ] **Step 7: Manual sanity walk**

Serve `build/web` on a fresh port. Play **Letter А** (Intro → Trace → Listen → Read → Reward) and **My Family**. Behavior is unchanged (no visible difference). The SRS now records letters + words under the hood — there's no UI surfacing it yet (that's Slice 4), so this is just confirming nothing regressed.

**Checkpoint:** Letters + words both tracked in `srsByItem`. Slice 3 complete. Pause to commit.

---

## Self-review (done at write time)

- **Spec coverage:** `Item`+`ItemType`+conformance (T1); `SrsBox` itemId/itemType + `LeitnerEngine` generalize + `dueItems` (T2); `Progress.srsByItem` + schema bump + fresh-start (T2 steps 4-5); `SessionRunner.itemCorrectness` incl. Trace/letters (T3 step 2); `_persistCompletion` seeds words+letters via tested `applySessionToSrs` (T3 steps 4-5); tests for each (item, leitner+dueItems, session runner letter case, srs_update). Deferrals (Slice 4/5/7) untouched. ✅
- **Placeholder scan:** none — every step has concrete code.
- **Type consistency:** `itemKeyOf(type,id)` + `Item.key` = `"type:id"` used identically in runner, helper, `_persistCompletion`, and tests. `SrsBox{itemId,itemType}`, `LeitnerEngine.initial(id,type,now)`, `Progress.srsByItem`, `SessionRunnerState.itemCorrectness`, `applySessionToSrs(current,items,itemCorrectness,now)` consistent across tasks. Record type `({ItemType type, String id})` used in helper + caller. Behavior preserved for words (T2 keeps words-only seeding); letters added only in T3.
