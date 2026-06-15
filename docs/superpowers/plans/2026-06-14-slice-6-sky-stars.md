# Slice 6 — The Sky (Sky-Stars + Doloon Burhan) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **GIT IS HANDLED BY THE HUMAN OPERATOR.** Do NOT run any `git` command (no add/commit/push/branch/status/diff/etc.). Each task ends with a **Checkpoint** (run analyze + tests) — stop there for the user to review and commit. This overrides the writing-plans default "Commit" steps.

**Goal:** Every word/letter the child *masters* (Leitner level ≥ 3) lights a permanent star in Od's night sky; the first 7 fill **Долоон бурхан / The Big Dipper**, which on completion plays a trivia celebration with an animated ladle — all viewable anytime via a tappable ★ count chip on the map.

**Architecture:** A pure orchestrator `applySessionRewards` (SRS update → award permanent sky-stars → detect constellation completion) is the single path all three completion handlers (lesson / review / warm-up) call, replacing their duplicated persist logic. Earned stars are *stored* (an append-only `List<String>` on `Progress`) so they stay lit even after a word's SRS level later drops — permanence the kindness invariant requires. A new `/sky` screen and a post-session reward overlay render them.

**Tech Stack:** Flutter 3 / Dart 3, Riverpod 2 (StateNotifierProvider), go_router, freezed + json_serializable (codegen via `dart run build_runner build --delete-conflicting-outputs`), flutter_animate. Pure logic is unit-tested; widgets are verified by `flutter analyze` + full `flutter test` + a `flutter build web --debug` smoke (Image.asset + GoRouter hang `flutter_test`, per prior slices).

**Spec:** `docs/superpowers/specs/2026-06-14-slice-6-sky-stars-design.md`

---

## File Map

| File | Responsibility | Task |
|---|---|---|
| `lib/models/converters/offset_converter.dart` | add `OffsetListConverter` (List<Offset> ↔ JSON) | 1 |
| `lib/models/constellation.dart` (NEW) | `Constellation` data model | 1 |
| `lib/core/content/content_repository.dart` | load + expose `constellations` (optional key) | 2 |
| `assets/content/content.json` | `constellations: [doloon_burhan]` | 2 |
| `test/fixtures/content_valid.json` | fixture gains a constellation | 2 |
| `lib/models/progress.dart` | `+ skyStarItemKeys, completedConstellationIds`; schema 4 | 3 |
| `lib/core/persistence/progress_repository.dart` | `_currentSchemaVersion = 4` | 3 |
| `lib/features/sky/sky_logic.dart` (NEW) | `isMastered`, `awardSkyStars`, `newlyCompletedConstellations`, `applySessionRewards`, `SessionRewards` (pure) | 4, 5 |
| `lib/features/warmup/warmup_logic.dart` | remove `applyWarmupCompletion` (subsumed) | 6 |
| `lib/features/sky/sky_reward_overlay.dart` (NEW) | `showSkyRewards` post-session celebration | 6 |
| `lib/features/lesson/lesson_runner_screen.dart` | completion → `applySessionRewards` + overlay | 6 |
| `lib/features/review/review_runner_screen.dart` | review/warm-up → `applySessionRewards` + overlay | 6 |
| `lib/features/sky/sky_screen.dart` (NEW) | `/sky` night-sky view | 7 |
| `lib/core/routing/app_router.dart` | `+ /sky` route | 7 |
| `lib/features/steppe/steppe_map_screen.dart` | tappable ★ chip → `/sky`; ⭐→done marker cleanup | 7 |
| `.claude/skills/bambaruush-creative-director/references/story-guide.md` | §8 permanence edit | 8 |

**Asset note:** new images (`ladle.png`, `sky_night.png`) live directly under the already-registered `assets/images/` directory — **no `pubspec.yaml` change**, and missing files fall through to `errorBuilder` so the build stays green before real art exists.

---

## Task 1: `Constellation` model + `OffsetListConverter`

**Files:**
- Modify: `lib/models/converters/offset_converter.dart`
- Create: `lib/models/constellation.dart`
- Create: `test/models/constellation_test.dart`

- [ ] **Step 1: Add `OffsetListConverter`** to `lib/models/converters/offset_converter.dart` (append after the existing `OffsetConverter`):

```dart
class OffsetListConverter implements JsonConverter<List<Offset>, List<dynamic>> {
  const OffsetListConverter();
  @override
  List<Offset> fromJson(List<dynamic> json) => [
        for (final e in json)
          Offset(
            ((e as List)[0] as num).toDouble(),
            (e[1] as num).toDouble(),
          ),
      ];
  @override
  List<dynamic> toJson(List<Offset> list) => [
        for (final o in list) [o.dx, o.dy],
      ];
}
```

- [ ] **Step 2: Create `lib/models/constellation.dart`:**

```dart
import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/offset_converter.dart';

part 'constellation.freezed.dart';
part 'constellation.g.dart';

@freezed
class Constellation with _$Constellation {
  const factory Constellation({
    required String id,
    required String nameEn, // accurate English astronomical name
    required String nameMn, // faithful Cyrillic; native-speaker check
    required int order,
    @OffsetListConverter() required List<Offset> slots, // normalized star positions
    required String shapeImage, // what it resembles; animates in on completion
    required String trivia, // one warm kid-sentence; cultural pride
  }) = _Constellation;

  factory Constellation.fromJson(Map<String, dynamic> json) =>
      _$ConstellationFromJson(json);
}
```

- [ ] **Step 3: Write the failing test** `test/models/constellation_test.dart`:

```dart
import 'package:bambaruush/models/constellation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips slots, shapeImage, and trivia through JSON', () {
    const c = Constellation(
      id: 'doloon_burhan',
      nameEn: 'The Big Dipper',
      nameMn: 'Долоон бурхан',
      order: 1,
      slots: [Offset(0.2, 0.3), Offset(0.7, 0.4)],
      shapeImage: 'assets/images/ladle.png',
      trivia: 'It looks like a ladle.',
    );
    final back = Constellation.fromJson(c.toJson());
    expect(back.nameEn, 'The Big Dipper');
    expect(back.nameMn, 'Долоон бурхан');
    expect(back.slots, hasLength(2));
    expect(back.slots.first, const Offset(0.2, 0.3));
    expect(back.shapeImage, 'assets/images/ladle.png');
    expect(back.trivia, 'It looks like a ladle.');
  });
}
```

- [ ] **Step 4: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: generates `constellation.freezed.dart` + `constellation.g.dart`, no errors.

- [ ] **Step 5: Run the test**

Run: `flutter test test/models/constellation_test.dart`
Expected: PASS.

- [ ] **Step 6: Checkpoint** — `flutter analyze` (no issues), then stop for review. (User commits — do NOT run git.)

---

## Task 2: `ContentRepository` loads `constellations`

**Files:**
- Modify: `lib/core/content/content_repository.dart`
- Modify: `assets/content/content.json`
- Modify: `test/fixtures/content_valid.json`
- Modify: `test/core/content/content_repository_test.dart`

- [ ] **Step 1: Write the failing assertions** — in `test/core/content/content_repository_test.dart`, inside the existing `test('parses a valid content fixture', ...)` body, add after the current expectations:

```dart
      expect(repo.constellations, hasLength(1));
      expect(repo.constellations.first.id, 'doloon_burhan');
      expect(repo.constellations.first.nameEn, 'The Big Dipper');
      expect(repo.constellations.first.slots, hasLength(7));
      expect(repo.constellations.first.shapeImage, 'assets/images/ladle.png');
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/core/content/content_repository_test.dart`
Expected: FAIL — `constellations` getter not defined (and fixture lacks the data).

- [ ] **Step 3: Add the constellations array to the fixture** `test/fixtures/content_valid.json` — add this as a new top-level key (e.g. immediately after the `"stickers": [...]` array; remember to add a comma after the preceding array's `]`):

```json
  "constellations": [
    {
      "id": "doloon_burhan",
      "nameEn": "The Big Dipper",
      "nameMn": "Долоон бурхан",
      "order": 1,
      "slots": [[0.20,0.30],[0.32,0.34],[0.44,0.40],[0.57,0.44],[0.70,0.40],[0.72,0.56],[0.58,0.58]],
      "shapeImage": "ladle.png",
      "trivia": "In Mongolia this is Долоон бурхан — 'the seven gods.' Some people also call it Шанага Долоо, the Ladle Seven, because it looks like a ladle for scooping."
    }
  ]
```

- [ ] **Step 4: Add the same constellations array to** `assets/content/content.json` — same JSON block, inserted as a new top-level key after the `"stickers": [...]` array (add the comma after its `]`). (The Mongolian strings `Долоон бурхан` / `Шанага Долоо` are working drafts flagged for native-speaker verification in the spec; JSON has no comments so the flag lives only in the spec.)

- [ ] **Step 5: Wire `ContentRepository`** in `lib/core/content/content_repository.dart`:

  (a) Add the import near the other model imports:
```dart
import '../../models/constellation.dart';
```
  (b) Add the public field (next to `final Map<String, Sticker> stickers;`):
```dart
  final List<Constellation> constellations;
```
  (c) Add it to the private constructor parameter list (next to `required this.stickers,`):
```dart
    required this.constellations,
```
  (d) Add the asset-prefix constant + the raw-json mapper (next to the other `_xFromRawJson` helpers and prefixes):
```dart
  static const _constellationImagePrefix = 'assets/images/';

  static Constellation _constellationFromRawJson(Map<String, dynamic> j) =>
      Constellation.fromJson({
        ...j,
        'shapeImage': '$_constellationImagePrefix${j['shapeImage']}',
      });
```
  (e) In `fromJson`, after the `stickerList` is built, parse the **optional** constellations key, dedupe ids, and sort by order. Add:
```dart
    final constellationList = ((json['constellations'] as List?) ?? const [])
        .map((e) => _constellationFromRawJson(e as Map<String, dynamic>))
        .toList();
    _checkUniqueIds(constellationList.map((e) => e.id), 'constellations');
    final sortedConstellations = constellationList
      ..sort((a, b) => a.order.compareTo(b.order));
```
  (f) Pass it into the `return ContentRepository._(...)` call (add the named arg):
```dart
      constellations: sortedConstellations,
```

- [ ] **Step 6: Run the content tests**

Run: `flutter test test/core/content/content_repository_test.dart`
Expected: PASS (including the new assertions; the other fixtures, which lack a `constellations` key, still load because it's optional).

- [ ] **Step 7: Checkpoint** — `flutter analyze`, then stop for review.

---

## Task 3: `Progress` sky fields + schema bump to 4

**Files:**
- Modify: `lib/models/progress.dart`
- Modify: `lib/core/persistence/progress_repository.dart:14`
- Modify: `test/core/persistence/progress_repository_test.dart`

- [ ] **Step 1: Add the fields** in `lib/models/progress.dart` — inside the `const factory Progress({...})` list, after `@Default(0) int warmupCount,`:

```dart
    @Default(<String>[]) List<String> skyStarItemKeys,
    @Default(<String>{}) Set<String> completedConstellationIds,
```

And bump the schema version in `Progress.empty(...)`: change `schemaVersion: 3,` to `schemaVersion: 4,`.

- [ ] **Step 2: Bump the repository constant** in `lib/core/persistence/progress_repository.dart:14`:

```dart
  static const _currentSchemaVersion = 4;
```

- [ ] **Step 3: Update the existing schema assertions** in `test/core/persistence/progress_repository_test.dart` — change **every** `expect(..., 3);` that checks a `schemaVersion` to `4`. Specifically:
  - `test('load returns Progress.empty() when file missing')`: `expect(p.schemaVersion, 4);`
  - `test('schema version mismatch is treated as fresh start')`: `expect(loaded.schemaVersion, 4);`
  - `test('round-trips lastWarmupAt and warmupCount')`: `expect(loaded.schemaVersion, 4);`
  - `test('preserves default lastWarmupAt (null) and warmupCount (0)')`: `expect(loaded.schemaVersion, 4);`

- [ ] **Step 4: Add a round-trip test** for the new fields (append inside `main()`):

```dart
  test('round-trips skyStarItemKeys and completedConstellationIds', () async {
    final p = Progress.empty().copyWith(
      skyStarItemKeys: ['word:word_aav', 'letter:letter_a'],
      completedConstellationIds: {'doloon_burhan'},
    );
    await repo.save(p);
    final loaded = await repo.load();
    expect(loaded.skyStarItemKeys, ['word:word_aav', 'letter:letter_a']);
    expect(loaded.completedConstellationIds, {'doloon_burhan'});
  });

  test('fresh start defaults sky fields to empty', () async {
    final p = await repo.load();
    expect(p.skyStarItemKeys, isEmpty);
    expect(p.completedConstellationIds, isEmpty);
  });
```

- [ ] **Step 5: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: regenerates `progress.freezed.dart` + `progress.g.dart`, no errors.

- [ ] **Step 6: Run the persistence tests**

Run: `flutter test test/core/persistence/progress_repository_test.dart`
Expected: PASS.

- [ ] **Step 7: Checkpoint** — `flutter analyze`, then stop for review.

---

## Task 4: Sky logic — `isMastered`, `awardSkyStars`, `newlyCompletedConstellations`

**Files:**
- Create: `lib/features/sky/sky_logic.dart`
- Create: `test/features/sky/sky_logic_test.dart`

- [ ] **Step 1: Write the failing tests** `test/features/sky/sky_logic_test.dart`:

```dart
import 'package:bambaruush/features/sky/sky_logic.dart';
import 'package:bambaruush/models/constellation.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

SrsBox _box(String id, ItemType t, int level) => SrsBox(
      itemId: id,
      itemType: t,
      level: level,
      nextReviewAt: DateTime.utc(2026, 6, 14),
      correctStreak: 0,
    );

void main() {
  group('awardSkyStars', () {
    test('adds items at level >= 3 (sorted), ignores below threshold', () {
      final r = awardSkyStars(current: const [], srsByItem: {
        'word:word_aav': _box('word_aav', ItemType.word, 3),
        'letter:letter_a': _box('letter_a', ItemType.letter, 4),
        'word:word_eej': _box('word_eej', ItemType.word, 2),
      });
      expect(r.newlyEarned, ['letter:letter_a', 'word:word_aav']);
      expect(r.updated, ['letter:letter_a', 'word:word_aav']);
    });

    test('does not duplicate an already-earned star', () {
      final r = awardSkyStars(current: const ['word:word_aav'], srsByItem: {
        'word:word_aav': _box('word_aav', ItemType.word, 5),
      });
      expect(r.newlyEarned, isEmpty);
      expect(r.updated, ['word:word_aav']);
    });

    test('permanence: keeps the star even after the box drops below mastery', () {
      final r = awardSkyStars(current: const ['word:word_aav'], srsByItem: {
        'word:word_aav': _box('word_aav', ItemType.word, 1),
      });
      expect(r.updated, ['word:word_aav']);
      expect(r.newlyEarned, isEmpty);
    });

    test('idempotent on re-run with the same SRS', () {
      final srs = {'word:word_aav': _box('word_aav', ItemType.word, 3)};
      final first = awardSkyStars(current: const [], srsByItem: srs);
      final second = awardSkyStars(current: first.updated, srsByItem: srs);
      expect(second.newlyEarned, isEmpty);
      expect(second.updated, first.updated);
    });
  });

  group('newlyCompletedConstellations', () {
    final dipper = Constellation(
      id: 'doloon_burhan',
      nameEn: 'The Big Dipper',
      nameMn: 'Долоон бурхан',
      order: 1,
      slots: List.filled(7, const Offset(0, 0)),
      shapeImage: 'x.png',
      trivia: 't',
    );
    test('fires when star count reaches the slot count', () {
      final r = newlyCompletedConstellations(
          starCount: 7, all: [dipper], alreadyCompleted: const {});
      expect(r.map((c) => c.id), ['doloon_burhan']);
    });
    test('does not fire before the slot count', () {
      expect(
          newlyCompletedConstellations(
              starCount: 6, all: [dipper], alreadyCompleted: const {}),
          isEmpty);
    });
    test('does not re-fire when already completed', () {
      expect(
          newlyCompletedConstellations(
              starCount: 8, all: [dipper], alreadyCompleted: const {'doloon_burhan'}),
          isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/sky/sky_logic_test.dart`
Expected: FAIL — `sky_logic.dart` / functions not defined.

- [ ] **Step 3: Create `lib/features/sky/sky_logic.dart`:**

```dart
import '../../models/constellation.dart';
import '../../models/srs_box.dart';

/// A word/letter is "mastered" — and earns a permanent sky-star — once its
/// Leitner box reaches this level (recall across a few spaced sessions). See
/// Story Guide §8: mastery, never a single tap.
const kMasteryLevel = 3;

bool isMastered(SrsBox box) => box.level >= kMasteryLevel;

/// Append every item now mastered whose key isn't already a star, in a
/// deterministic order (sorted ascending), preserving prior placement order.
/// Idempotent. Earned keys are never removed — permanence (kindness invariant).
({List<String> updated, List<String> newlyEarned}) awardSkyStars({
  required List<String> current,
  required Map<String, SrsBox> srsByItem,
}) {
  final have = current.toSet();
  final newly = <String>[
    for (final entry in srsByItem.entries)
      if (entry.value.level >= kMasteryLevel && !have.contains(entry.key))
        entry.key,
  ]..sort();
  return (updated: [...current, ...newly], newlyEarned: newly);
}

/// Constellations whose slot count is now filled and not yet celebrated.
List<Constellation> newlyCompletedConstellations({
  required int starCount,
  required List<Constellation> all,
  required Set<String> alreadyCompleted,
}) =>
    [
      for (final c in all)
        if (starCount >= c.slots.length && !alreadyCompleted.contains(c.id)) c,
    ];
```

- [ ] **Step 4: Run the test**

Run: `flutter test test/features/sky/sky_logic_test.dart`
Expected: PASS.

- [ ] **Step 5: Checkpoint** — `flutter analyze`, then stop for review.

---

## Task 5: `applySessionRewards` orchestrator + `SessionRewards`

**Files:**
- Modify: `lib/features/sky/sky_logic.dart`
- Create: `test/features/sky/sky_rewards_test.dart`

> Leaves `applyWarmupCompletion` in place for now (its caller is rewritten in Task 6) so the build stays green between tasks.

- [ ] **Step 1: Write the failing tests** `test/features/sky/sky_rewards_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/features/sky/sky_logic.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/progress.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter_test/flutter_test.dart';

ContentRepository _content() => ContentRepository.fromJson(
      jsonDecode(File('test/fixtures/content_valid.json').readAsStringSync())
          as Map<String, dynamic>,
    );

void main() {
  final now = DateTime.utc(2026, 6, 14);

  test('awards a star at mastery; leaves lessons and stickers untouched', () {
    final start = Progress.empty(now: DateTime.utc(2026, 6, 1)).copyWith(
      earnedStickerIds: {'sticker_a'},
      srsByItem: {
        'word:word_aav': SrsBox(
          itemId: 'word_aav',
          itemType: ItemType.word,
          level: 2, // one more correct → level 3 (mastered)
          nextReviewAt: now,
          correctStreak: 1,
        ),
      },
    );
    final r = applySessionRewards(
      current: start,
      itemCorrectness: {'word:word_aav': true},
      now: now,
      content: _content(),
    );
    expect(r.progress.srsByItem['word:word_aav']!.level, 3);
    expect(r.newStarKeys, ['word:word_aav']);
    expect(r.progress.skyStarItemKeys, contains('word:word_aav'));
    expect(r.progress.lessons, isEmpty);
    expect(r.progress.earnedStickerIds, {'sticker_a'});
    expect(r.progress.lastPlayed, now);
  });

  test('warm-up path bumps warmupCount and stamps lastWarmupAt', () {
    final start = Progress.empty(now: DateTime.utc(2026, 6, 1)).copyWith(warmupCount: 2);
    final r = applySessionRewards(
      current: start,
      itemCorrectness: {'word:word_aav': true},
      now: now,
      content: _content(),
      isWarmup: true,
    );
    expect(r.progress.warmupCount, 3);
    expect(r.progress.lastWarmupAt, now);
  });

  test('no star for an item that has not yet reached mastery', () {
    final r = applySessionRewards(
      current: Progress.empty(),
      itemCorrectness: {'word:word_aav': true}, // fresh box → level 2 only
      now: now,
      content: _content(),
    );
    expect(r.newStarKeys, isEmpty);
    expect(r.progress.skyStarItemKeys, isEmpty);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/sky/sky_rewards_test.dart`
Expected: FAIL — `applySessionRewards` / `SessionRewards` not defined.

- [ ] **Step 3: Append to `lib/features/sky/sky_logic.dart`** — add these imports at the top (with the existing ones):

```dart
import '../../core/content/content_repository.dart';
import '../../models/progress.dart';
import '../lesson/srs_update.dart';
```

and append at the end of the file:

```dart
/// Result of applying a finished session to progress: the next Progress plus
/// what to celebrate.
class SessionRewards {
  const SessionRewards({
    required this.progress,
    required this.newStarKeys,
    required this.completedConstellations,
  });

  final Progress progress;
  final List<String> newStarKeys;
  final List<Constellation> completedConstellations;
}

/// The single path every completion handler (lesson / review / warm-up) calls:
/// SRS update → permanent sky-stars → constellation completion → (warm-up)
/// warmupCount/lastWarmupAt. Pure. Lesson-specific bits (lessons/sticker/unlock)
/// are layered on top of [SessionRewards.progress] by the caller.
SessionRewards applySessionRewards({
  required Progress current,
  required Map<String, bool> itemCorrectness,
  required DateTime now,
  required ContentRepository content,
  bool isWarmup = false,
}) {
  final newSrs = applySessionToSrs(
    current: current.srsByItem,
    itemCorrectness: itemCorrectness,
    now: now,
  );
  final stars = awardSkyStars(
    current: current.skyStarItemKeys,
    srsByItem: newSrs,
  );
  final completed = newlyCompletedConstellations(
    starCount: stars.updated.length,
    all: content.constellations,
    alreadyCompleted: current.completedConstellationIds,
  );
  final next = current.copyWith(
    srsByItem: newSrs,
    skyStarItemKeys: stars.updated,
    completedConstellationIds: {
      ...current.completedConstellationIds,
      for (final c in completed) c.id,
    },
    lastPlayed: now,
    warmupCount: isWarmup ? current.warmupCount + 1 : current.warmupCount,
    lastWarmupAt: isWarmup ? now : current.lastWarmupAt,
  );
  return SessionRewards(
    progress: next,
    newStarKeys: stars.newlyEarned,
    completedConstellations: completed,
  );
}
```

- [ ] **Step 4: Run the test**

Run: `flutter test test/features/sky/sky_rewards_test.dart`
Expected: PASS.

- [ ] **Step 5: Checkpoint** — `flutter analyze` (the rest of the app still builds — `applyWarmupCompletion` is untouched), then stop for review.

---

## Task 6: Reward overlay + wire all three completion paths

**Files:**
- Create: `lib/features/sky/sky_reward_overlay.dart`
- Modify: `lib/features/lesson/lesson_runner_screen.dart`
- Modify: `lib/features/review/review_runner_screen.dart`
- Modify: `lib/features/warmup/warmup_logic.dart`
- Modify: `test/features/warmup/warmup_logic_test.dart`

> No widget tests (Image.asset + GoRouter hang `flutter_test`). This task is verified by analyze + the full pure-test suite + the web smoke in Task 8.

- [ ] **Step 1: Create `lib/features/sky/sky_reward_overlay.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/constellation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';

/// Post-session celebration for newly-earned sky-stars and any constellation
/// just completed. Returns immediately (no dialog) when there's nothing to show.
Future<void> showSkyRewards(
  BuildContext context, {
  required int newStarCount,
  required List<Constellation> completedConstellations,
}) {
  if (newStarCount == 0 && completedConstellations.isEmpty) {
    return Future<void>.value();
  }
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _SkyRewardDialog(
      newStarCount: newStarCount,
      completed: completedConstellations,
    ),
  );
}

class _SkyRewardDialog extends StatelessWidget {
  const _SkyRewardDialog({required this.newStarCount, required this.completed});
  final int newStarCount;
  final List<Constellation> completed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (newStarCount > 0) ...[
              const Icon(Icons.star_rounded, color: AppColors.sun, size: 56)
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    curve: Curves.elasticOut,
                    duration: const Duration(milliseconds: 500),
                  ),
              const SizedBox(height: 8),
              Text(
                newStarCount == 1
                    ? 'A new star for your sky!'
                    : '$newStarCount new stars for your sky!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.coral,
                ),
              ),
            ],
            for (final c in completed) ...[
              const SizedBox(height: 20),
              Image.asset(
                c.shapeImage,
                width: 96,
                height: 96,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome,
                  size: 72,
                  color: AppColors.sun,
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    curve: Curves.easeOutBack,
                    duration: const Duration(milliseconds: 500),
                  ),
              const SizedBox(height: 8),
              Text(
                c.nameEn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.ink,
                ),
              ),
              Text(
                c.nameMn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.learning,
                  fontSize: 16,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                c.trivia,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
              ),
            ],
            const SizedBox(height: 24),
            CandyButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.meadow,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Rewrite the lesson completion path** in `lib/features/lesson/lesson_runner_screen.dart`:

  (a) Imports — **remove** `import 'srs_update.dart';` and **add**:
```dart
import '../sky/sky_logic.dart';
import '../sky/sky_reward_overlay.dart';
```
  (b) Replace the `ref.listen<SessionRunnerState>(lessonRunnerProvider(lesson), ...)` callback body with:
```dart
      (prev, next) async {
        if (next.current is SessionComplete && prev?.current is! SessionComplete) {
          final rewards = await _persistCompletion(ref, lesson, next);
          if (context.mounted) {
            await showSkyRewards(
              context,
              newStarCount: rewards.newStarKeys.length,
              completedConstellations: rewards.completedConstellations,
            );
          }
          if (context.mounted) context.pop();
        }
      },
```
  (c) Replace the whole `Future<void> _persistCompletion(...)` method with:
```dart
  Future<SessionRewards> _persistCompletion(
    WidgetRef ref,
    Lesson lesson,
    SessionRunnerState s,
  ) async {
    final progress = ref.read(progressControllerProvider);
    final progressCtrl = ref.read(progressControllerProvider.notifier);
    final content = ref.read(contentRepositoryProvider);
    final now = DateTime.now();

    final rewards = applySessionRewards(
      current: progress,
      itemCorrectness: s.itemCorrectness,
      now: now,
      content: content,
    );

    final newLessons = {...progress.lessons};
    newLessons[lesson.id] = LessonProgress(
      lessonId: lesson.id,
      unlocked: true,
      completed: true,
      completionCount: (progress.lessons[lesson.id]?.completionCount ?? 0) + 1,
      completedAt: now,
    );
    final nextList =
        content.lessons.where((l) => l.order == lesson.order + 1).toList();
    if (nextList.isNotEmpty && newLessons[nextList.first.id] == null) {
      final nx = nextList.first;
      newLessons[nx.id] = LessonProgress(
        lessonId: nx.id,
        unlocked: true,
        completed: false,
        completionCount: 0,
      );
    }

    final updated = rewards.progress.copyWith(
      lessons: newLessons,
      earnedStickerIds: {...progress.earnedStickerIds, lesson.stickerId},
    );
    await progressCtrl.update(updated);
    return SessionRewards(
      progress: updated,
      newStarKeys: rewards.newStarKeys,
      completedConstellations: rewards.completedConstellations,
    );
  }
```

- [ ] **Step 3: Rewrite the review/warm-up completion path** in `lib/features/review/review_runner_screen.dart`:

  (a) Imports — **remove** `import 'srs_update.dart';` and `import '../warmup/warmup_logic.dart';`; **add**:
```dart
import '../sky/sky_logic.dart';
import '../sky/sky_reward_overlay.dart';
```
  (b) Replace the `ref.listen<SessionRunnerState>(reviewRunnerProvider(mode), ...)` callback body (inside `_RunningView.build`) with:
```dart
    ref.listen<SessionRunnerState>(reviewRunnerProvider(mode), (prev, next) async {
      if (next.current is SessionComplete && prev?.current is! SessionComplete) {
        final rewards = _isWarmup
            ? await _persistWarmup(ref, next)
            : await _persistReview(ref, next);
        if (context.mounted) {
          await showSkyRewards(
            context,
            newStarCount: rewards.newStarKeys.length,
            completedConstellations: rewards.completedConstellations,
          );
        }
        if (context.mounted) _exit(context);
      }
    });
```
  (c) Replace the top-level `_persistReview` and `_persistWarmup` functions with:
```dart
Future<SessionRewards> _persistReview(WidgetRef ref, SessionRunnerState s) async {
  final progress = ref.read(progressControllerProvider);
  final content = ref.read(contentRepositoryProvider);
  final rewards = applySessionRewards(
    current: progress,
    itemCorrectness: s.itemCorrectness,
    now: DateTime.now(),
    content: content,
  );
  await ref.read(progressControllerProvider.notifier).update(rewards.progress);
  return rewards;
}

Future<SessionRewards> _persistWarmup(WidgetRef ref, SessionRunnerState s) async {
  final progress = ref.read(progressControllerProvider);
  final content = ref.read(contentRepositoryProvider);
  final rewards = applySessionRewards(
    current: progress,
    itemCorrectness: s.itemCorrectness,
    now: DateTime.now(),
    content: content,
    isWarmup: true,
  );
  await ref.read(progressControllerProvider.notifier).update(rewards.progress);
  return rewards;
}
```

- [ ] **Step 4: Remove the now-unused `applyWarmupCompletion`** from `lib/features/warmup/warmup_logic.dart`: delete the entire `Progress applyWarmupCompletion({...}) => ...;` function (and its doc comment), and remove the now-unused imports at the top: `import '../../models/progress.dart';` and `import '../lesson/srs_update.dart';`. Keep `isSameDay` and `shouldOfferWarmup`.

- [ ] **Step 5: Remove its test** in `test/features/warmup/warmup_logic_test.dart`: delete the entire `group('applyWarmupCompletion', () { ... });` block, and remove the now-unused imports `import 'package:bambaruush/models/item.dart';` and `import 'package:bambaruush/models/progress.dart';`. Keep the `isSameDay` and `shouldOfferWarmup` groups.

- [ ] **Step 6: Run the full test suite + analyze**

Run: `flutter analyze`
Expected: No issues.
Run: `flutter test`
Expected: PASS (warm-up logic, sky logic/rewards, persistence, content, and all prior tests green).

- [ ] **Step 7: Checkpoint** — stop for review.

---

## Task 7: Sky screen + `/sky` route + map ★ chip + ⭐ cleanup

**Files:**
- Create: `lib/features/sky/sky_screen.dart`
- Modify: `lib/core/routing/app_router.dart`
- Modify: `lib/features/steppe/steppe_map_screen.dart`

- [ ] **Step 1: Create `lib/features/sky/sky_screen.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/constellation.dart';
import '../../theme/app_theme.dart';

/// Od's night sky: the permanent record of mastered words/letters. The first 7
/// stars fill Doloon Burhan; extras scatter as ambient background stars.
class SkyScreen extends ConsumerWidget {
  const SkyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final progress = ref.watch(progressControllerProvider);
    final stars = progress.skyStarItemKeys;

    Constellation? dipper;
    for (final c in content.constellations) {
      if (c.id == 'doloon_burhan') {
        dipper = c;
        break;
      }
    }
    dipper ??= content.constellations.isEmpty ? null : content.constellations.first;

    final complete = dipper != null &&
        (progress.completedConstellationIds.contains(dipper.id) ||
            stars.length >= dipper.slots.length);

    return Scaffold(
      appBar: AppBar(title: const Text("Od's Sky")),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1026), Color(0xFF1B2350), Color(0xFF2E2A4A)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/sky_night.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            if (dipper != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final d = dipper!;
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(w, h),
                        painter: _DipperLines(slots: d.slots, filled: stars.length),
                      ),
                      for (var i = 0; i < d.slots.length; i++)
                        Positioned(
                          left: d.slots[i].dx * w - 14,
                          top: d.slots[i].dy * h - 14,
                          child: Icon(
                            Icons.star_rounded,
                            size: 28,
                            color: i < stars.length ? AppColors.sun : Colors.white24,
                          ),
                        ),
                      for (var i = d.slots.length; i < stars.length; i++)
                        Positioned(
                          left: _ambient(stars[i], w, h).dx,
                          top: _ambient(stars[i], w, h).dy,
                          child: const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  );
                },
              ),
            Positioned(top: 12, right: 16, child: _CountChip(count: stars.length)),
            if (dipper != null)
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      dipper.nameEn,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: complete ? AppColors.sun : Colors.white54,
                      ),
                    ),
                    Text(
                      dipper.nameMn,
                      style: TextStyle(
                        fontFamily: AppFonts.learning,
                        fontSize: 16,
                        color: complete ? Colors.white : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Offset _ambient(String key, double w, double h) {
  final hx = key.hashCode;
  final dx = ((hx & 0xFFFF) / 0xFFFF) * 0.9 + 0.05;
  final dy = (((hx >> 16) & 0xFFFF) / 0xFFFF) * 0.4 + 0.08;
  return Offset(dx * w, dy * h);
}

class _DipperLines extends CustomPainter {
  _DipperLines({required this.slots, required this.filled});
  final List<Offset> slots;
  final int filled;

  @override
  void paint(Canvas canvas, Size size) {
    final n = filled.clamp(0, slots.length);
    if (n < 2) return;
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final p = Offset(slots[i].dx * size.width, slots[i].dy * size.height);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DipperLines old) => old.filled != filled;
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.sun, size: 18),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.display,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add the `/sky` route** in `lib/core/routing/app_router.dart` — add the import:
```dart
import '../../features/sky/sky_screen.dart';
```
and add the route (e.g. after the `/warmup` route):
```dart
      GoRoute(path: '/sky', builder: (_, __) => const SkyScreen()),
```

- [ ] **Step 3: Add the tappable ★ chip + ⭐ cleanup** in `lib/features/steppe/steppe_map_screen.dart`:

  (a) Inside the main `Stack` children (in `SteppeMapScreen.build`), add a chip Positioned just **before** `const MascotOverlay(),`:
```dart
              Positioned(
                top: 12,
                left: 12,
                child: _SkyStarChip(
                  count: progress.skyStarItemKeys.length,
                  onTap: () => context.push('/sky'),
                ),
              ),
```
  (b) Add the chip widget at the bottom of the file:
```dart
class _SkyStarChip extends StatelessWidget {
  const _SkyStarChip({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: AppColors.cardBorder, width: 2),
          boxShadow: const [kSoftShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.sun, size: 20),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
  (c) **⭐ cleanup** — in `_RegionTile.build`, replace the lesson-completion `Icon(...)` (currently `Icons.star_rounded` / `Icons.star_outline_rounded` colored `AppColors.sun`) with a non-star "done" marker so *star* now means *sky-star* only:
```dart
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: completed ? AppColors.meadow : AppColors.inkSoft,
                    ),
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: No issues.
Run: `flutter build web --debug`
Expected: Builds successfully (smoke test of the whole widget tree, including `/sky` and the map chip).

- [ ] **Step 5: Checkpoint** — stop for review.

---

## Task 8: Canon update + full verification

**Files:**
- Modify: `.claude/skills/bambaruush-creative-director/references/story-guide.md`

- [ ] **Step 1: Record the permanence decision in canon** — in `.claude/skills/bambaruush-creative-director/references/story-guide.md`, §8 "Learning & mastery", replace the line:
```
- Spaced repetition: mastered words resurface in new lessons. A word can drop **mastered → practiced** if repeatedly missed, and re-earn its star.
```
with:
```
- Spaced repetition: mastered words resurface in new lessons. A word can drop **mastered → practiced** for *review-scheduling* if repeatedly missed — **but its earned sky-star is permanent** (once lit, never removed; the kindness invariant forbids taking a star back). This permanence is realized in Slice 6.
```
  Then grep for the same wording in the team copy and mirror the edit if present:
  Run: `grep -rn "re-earn its star" docs/`
  If a match exists in `docs/Bambaruush_Story_Guide.md` (or `docs/files/...`), apply the same replacement there.

- [ ] **Step 2: Full analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 3: Full test suite**

Run: `flutter test`
Expected: All pass — including `constellation_test`, `sky_logic_test`, `sky_rewards_test`, updated `progress_repository_test` (schema 4), `content_repository_test` (constellations), and the trimmed `warmup_logic_test`.

- [ ] **Step 4: Web build smoke**

Run: `flutter build web --debug`
Expected: Builds successfully.

- [ ] **Step 5: Manual sanity checklist** (optional, run `flutter run` if a device is available):
  - Complete a lesson twice (so an item reaches level ≥ 3) → "A new star for your sky!" overlay appears.
  - The map shows a ★ chip with the count; tapping it opens Od's Sky.
  - Region tiles show check-circles (not stars) for completed lessons.

- [ ] **Step 6: Checkpoint** — stop for final review. The slice is feature-complete; the user commits and merges per `superpowers:finishing-a-development-branch`.

---

## Self-Review (author)

**Spec coverage:** §2 mastery level ≥ 3 (Task 4 `kMasteryLevel`); permanence (Task 4 `awardSkyStars` + test; Task 8 canon edit); words+letters (Task 4 — keyed by `type:id`, type-agnostic); Doloon Burhan first constellation (Task 2 content + Task 4 completion + Task 7 screen); accurate English / faithful Mongolian / trivia / shapeImage (Tasks 1–2 model+content, Task 6 overlay); schema 3→4 fresh-start (Task 3); shared orchestrator across all three paths (Task 5–6); Sky screen + tappable ★ chip entry (Task 7); ⭐→done cleanup (Task 7); native-speaker flag (spec-level — JSON can't carry comments; noted in Task 2). All covered.

**Placeholder scan:** none — every code/test step has full code; coordinates are intentionally tunable but valid.

**Type consistency:** `awardSkyStars` returns `({List<String> updated, List<String> newlyEarned})` (Tasks 4–7 consistent); `SessionRewards{progress,newStarKeys,completedConstellations}` (Task 5 def; Task 6 callers); `applySessionRewards(current,itemCorrectness,now,content,isWarmup)` (Task 5 def; Task 6 callers); `showSkyRewards(context, newStarCount, completedConstellations)` (Task 6 def + 2 callers); `Constellation` fields `{id,nameEn,nameMn,order,slots,shapeImage,trivia}` consistent across model/content/overlay/screen.
