# Bambaruush v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a single-profile, offline, ~12-15 lesson Mongolian language-learning app for kids 7+ in Flutter, with three mini-games (trace, listen, read), Leitner SRS, sticker rewards, and a Rive-animated mascot.

**Architecture:** Feature-first folders under `lib/`. Riverpod 2.x `StateNotifierProvider`s for state, `go_router` for navigation, JSON-bundled content + JSON-persisted progress in app documents dir, `just_audio` for audio, `rive` for the mascot. A `LessonRunner` state machine drives the fixed Intro→Trace→Listen→Read→Reward pedagogy.

**Tech Stack:** Flutter 3.x · Dart 3 · flutter_riverpod 2.x · go_router · just_audio · rive · flutter_animate · freezed + json_serializable · path_provider

**Spec:** `docs/superpowers/specs/2026-05-27-bambaruush-v1-design.md`

**Commits:** This plan **does not include git commit steps**. The user manages all git operations themselves. After each milestone, pause for the user to commit if they choose.

---

## File map

```
pubspec.yaml
analysis_options.yaml
assets/
  content/content.json
  audio/             (stub silent .mp3 files for dev)
  images/words/      (stub colored .png files)
  images/stickers/   (stub colored .png files)
  images/regions/    (stub .png)
  images/steppe_map.png
  trace_masks/       (stub bitmap masks)
  rive/bambaruush.riv (placeholder; real rig added in Milestone D)
lib/
  main.dart
  app.dart
  core/
    audio/audio_service.dart
    content/content_repository.dart
    persistence/progress_repository.dart
    srs/leitner_engine.dart
    routing/app_router.dart
  features/
    steppe/steppe_map_screen.dart
    steppe/region_detail_screen.dart
    steppe/region_providers.dart
    lesson/lesson_runner.dart
    lesson/lesson_runner_screen.dart
    lesson/intro_stage.dart
    lesson/trace_stage.dart
    lesson/listen_stage.dart
    lesson/read_stage.dart
    lesson/reward_stage.dart
    lesson/distractors.dart
    stickers/sticker_album_screen.dart
    stickers/sticker_providers.dart
    mascot/mascot_controller.dart
    mascot/mascot_overlay.dart
    settings/settings_screen.dart
    settings/parent_gate_screen.dart
    settings/settings_providers.dart
  models/
    letter.dart
    word.dart
    lesson.dart
    region.dart
    sticker.dart
    progress.dart
    lesson_progress.dart
    srs_box.dart
    mascot_mood.dart
test/
  core/srs/leitner_engine_test.dart
  core/content/content_repository_test.dart
  core/persistence/progress_repository_test.dart
  features/lesson/lesson_runner_test.dart
  features/lesson/distractors_test.dart
integration_test/
  first_launch_test.dart
```

---

# Milestone A — Skeleton + one playable lesson

Goal: app launches, kid sees a minimal Steppe map, taps Lesson 1, plays through Intro→Listen→Read→Reward (Trace deferred to Milestone B), earns a sticker, progress persists across relaunch.

---

## Task 1: Bootstrap Flutter project and pubspec

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `lib/main.dart`
- Create: `lib/app.dart`

- [ ] **Step 1: Initialize the Flutter project in-place**

Run: `flutter create --org com.bambaruush --project-name bambaruush --platforms ios,android .`
Expected: scaffold files appear (`pubspec.yaml`, `lib/main.dart`, `ios/`, `android/`, `test/`). Existing `docs/` and `.superpowers/` are untouched.

- [ ] **Step 2: Replace `pubspec.yaml` contents with the full dependency set**

Write `pubspec.yaml`:

```yaml
name: bambaruush
description: Mongolian language learning for kids.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  just_audio: ^0.9.40
  rive: ^0.13.13
  flutter_animate: ^4.5.0
  path_provider: ^2.1.3
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  build_runner: ^2.4.11
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/content/
    - assets/audio/
    - assets/images/
    - assets/images/words/
    - assets/images/stickers/
    - assets/images/regions/
    - assets/trace_masks/
    - assets/rive/
```

- [ ] **Step 3: Create `analysis_options.yaml`**

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    avoid_print: true
    require_trailing_commas: true
```

- [ ] **Step 4: Replace `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: BambaruushApp()));
}
```

- [ ] **Step 5: Create `lib/app.dart` (minimal shell)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BambaruushApp extends ConsumerWidget {
  const BambaruushApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Bambaruush',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC08A4A)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Bambaruush — coming soon')),
      ),
    );
  }
}
```

- [ ] **Step 6: Run pub get and launch on a simulator**

Run: `flutter pub get`
Expected: "Got dependencies!"

Run: `flutter run -d <simulator-id>` (or just `flutter run` and pick a device)
Expected: app launches; "Bambaruush — coming soon" is visible.

- [ ] **Step 7: Create empty asset directories so the bundler doesn't choke**

Run:
```bash
mkdir -p assets/content assets/audio assets/images/words assets/images/stickers assets/images/regions assets/trace_masks assets/rive
touch assets/audio/.gitkeep assets/images/words/.gitkeep assets/images/stickers/.gitkeep assets/images/regions/.gitkeep assets/trace_masks/.gitkeep assets/rive/.gitkeep
```

**Checkpoint:** App boots on iOS + Android. Empty asset folders in place. Stop here if you want to commit Milestone A1.

---

## Task 2: Define immutable models with freezed

**Files:**
- Create: `lib/models/letter.dart`
- Create: `lib/models/word.dart`
- Create: `lib/models/lesson.dart`
- Create: `lib/models/region.dart`
- Create: `lib/models/sticker.dart`
- Create: `lib/models/srs_box.dart`
- Create: `lib/models/lesson_progress.dart`
- Create: `lib/models/progress.dart`
- Create: `lib/models/mascot_mood.dart`

- [ ] **Step 1: Create `lib/models/letter.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'letter.freezed.dart';
part 'letter.g.dart';

@freezed
class Letter with _$Letter {
  const factory Letter({
    required String id,
    required String cyrillic,
    required String romanization,
    required String audioAssetPath,
    required String traceTemplatePath,
  }) = _Letter;

  factory Letter.fromJson(Map<String, dynamic> json) => _$LetterFromJson(json);
}
```

- [ ] **Step 2: Create `lib/models/word.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';
part 'word.g.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required String id,
    required String cyrillic,
    required String english,
    required String audioAssetPath,
    required String imageAssetPath,
    required List<String> letterIds,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
```

- [ ] **Step 3: Create `lib/models/lesson.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required int order,
    required String regionId,
    required List<String> letterIds,
    required List<String> wordIds,
    required String stickerId,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}
```

- [ ] **Step 4: Create `lib/models/region.dart`**

```dart
import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'region.freezed.dart';
part 'region.g.dart';

@freezed
class Region with _$Region {
  const factory Region({
    required String id,
    required String nameEn,
    required String nameMn,
    required int order,
    required String mapImagePath,
    @OffsetConverter() required Offset mapPosition,
  }) = _Region;

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
}

class OffsetConverter implements JsonConverter<Offset, List<dynamic>> {
  const OffsetConverter();
  @override
  Offset fromJson(List<dynamic> json) =>
      Offset((json[0] as num).toDouble(), (json[1] as num).toDouble());
  @override
  List<dynamic> toJson(Offset o) => [o.dx, o.dy];
}
```

- [ ] **Step 5: Create `lib/models/sticker.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sticker.freezed.dart';
part 'sticker.g.dart';

@freezed
class Sticker with _$Sticker {
  const factory Sticker({
    required String id,
    required String lessonId,
    required String imageAssetPath,
    required String nameEn,
  }) = _Sticker;

  factory Sticker.fromJson(Map<String, dynamic> json) => _$StickerFromJson(json);
}
```

- [ ] **Step 6: Create `lib/models/srs_box.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'srs_box.freezed.dart';
part 'srs_box.g.dart';

@freezed
class SrsBox with _$SrsBox {
  const factory SrsBox({
    required String wordId,
    required int level,
    required DateTime nextReviewAt,
    required int correctStreak,
  }) = _SrsBox;

  factory SrsBox.fromJson(Map<String, dynamic> json) => _$SrsBoxFromJson(json);
}
```

- [ ] **Step 7: Create `lib/models/lesson_progress.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_progress.freezed.dart';
part 'lesson_progress.g.dart';

@freezed
class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required String lessonId,
    required bool unlocked,
    required bool completed,
    required int completionCount,
    DateTime? completedAt,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressFromJson(json);
}
```

- [ ] **Step 8: Create `lib/models/progress.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'lesson_progress.dart';
import 'srs_box.dart';

part 'progress.freezed.dart';
part 'progress.g.dart';

@freezed
class Progress with _$Progress {
  const factory Progress({
    required Map<String, LessonProgress> lessons,
    required Map<String, SrsBox> srsByWord,
    required Set<String> earnedStickerIds,
    required int schemaVersion,
    required DateTime lastPlayed,
    @Default(1.0) double volume,
  }) = _Progress;

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);

  factory Progress.empty() => Progress(
        lessons: const {},
        srsByWord: const {},
        earnedStickerIds: const {},
        schemaVersion: 1,
        lastPlayed: DateTime.now(),
      );
}
```

- [ ] **Step 9: Create `lib/models/mascot_mood.dart`**

```dart
enum MascotMood { idle, cheer, sad, point, sleep, wave }
```

- [ ] **Step 10: Generate freezed + json code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `*.freezed.dart` and `*.g.dart` files appear next to each model.

- [ ] **Step 11: Confirm models compile**

Run: `flutter analyze`
Expected: "No issues found!" (or only style warnings — fix any errors).

**Checkpoint:** All models compile. Stop to commit if desired.

---

## Task 3: Author content fixture (2 lessons for dev)

**Files:**
- Create: `assets/content/content.json`
- Create stub asset files (silent mp3, colored pngs)

- [ ] **Step 1: Write `assets/content/content.json`**

```json
{
  "schemaVersion": 1,
  "regions": [
    {
      "id": "region_yurt",
      "nameEn": "The Yurt",
      "nameMn": "Гэр",
      "order": 1,
      "mapImagePath": "region_yurt.png",
      "mapPosition": [0.22, 0.62]
    }
  ],
  "letters": [
    {
      "id": "letter_a",
      "cyrillic": "А",
      "romanization": "A",
      "audio": "letter_a.mp3",
      "traceMask": "letter_a.png"
    },
    {
      "id": "letter_b",
      "cyrillic": "Б",
      "romanization": "B",
      "audio": "letter_b.mp3",
      "traceMask": "letter_b.png"
    }
  ],
  "words": [
    {
      "id": "word_aav",
      "cyrillic": "Аав",
      "english": "father",
      "audio": "word_aav.mp3",
      "image": "word_aav.png",
      "letterIds": ["letter_a"]
    },
    {
      "id": "word_akh",
      "cyrillic": "Ах",
      "english": "older brother",
      "audio": "word_akh.mp3",
      "image": "word_akh.png",
      "letterIds": ["letter_a"]
    },
    {
      "id": "word_baavgai",
      "cyrillic": "Баавгай",
      "english": "bear",
      "audio": "word_baavgai.mp3",
      "image": "word_baavgai.png",
      "letterIds": ["letter_b", "letter_a"]
    },
    {
      "id": "word_bombog",
      "cyrillic": "Бөмбөг",
      "english": "ball",
      "audio": "word_bombog.mp3",
      "image": "word_bombog.png",
      "letterIds": ["letter_b"]
    }
  ],
  "lessons": [
    {
      "id": "lesson_01",
      "order": 1,
      "regionId": "region_yurt",
      "letterIds": ["letter_a"],
      "wordIds": ["word_aav", "word_akh"],
      "stickerId": "sticker_father_bear"
    },
    {
      "id": "lesson_02",
      "order": 2,
      "regionId": "region_yurt",
      "letterIds": ["letter_b"],
      "wordIds": ["word_baavgai", "word_bombog"],
      "stickerId": "sticker_ball"
    }
  ],
  "stickers": [
    {
      "id": "sticker_father_bear",
      "lessonId": "lesson_01",
      "image": "sticker_father_bear.png",
      "nameEn": "Father Bear"
    },
    {
      "id": "sticker_ball",
      "lessonId": "lesson_02",
      "image": "sticker_ball.png",
      "nameEn": "Ball"
    }
  ]
}
```

- [ ] **Step 2: Create a tiny silent MP3 stub**

Run:
```bash
# Create a 0.1s silent mp3 using ffmpeg if available; otherwise use a checked-in stub.
if command -v ffmpeg >/dev/null; then
  ffmpeg -f lavfi -i anullsrc=r=22050:cl=mono -t 0.1 -q:a 9 -acodec libmp3lame assets/audio/_silent.mp3 -y
fi
for f in letter_a letter_b word_aav word_akh word_baavgai word_bombog; do
  cp assets/audio/_silent.mp3 assets/audio/$f.mp3
done
```

If `ffmpeg` is unavailable, manually create a 0.1s silent `assets/audio/_silent.mp3` (any tiny valid mp3 works) and copy it under each expected name.

- [ ] **Step 3: Generate stub PNGs (32×32 colored squares)**

Use any image tool to make a single 32×32 PNG per file below. A quick Dart approach: write a one-off script, or just copy a Flutter default icon. Required filenames:

```
assets/images/words/word_aav.png
assets/images/words/word_akh.png
assets/images/words/word_baavgai.png
assets/images/words/word_bombog.png
assets/images/stickers/sticker_father_bear.png
assets/images/stickers/sticker_ball.png
assets/images/regions/region_yurt.png
assets/images/steppe_map.png
assets/trace_masks/letter_a.png
assets/trace_masks/letter_b.png
```

Reference script (run from project root):

```bash
# Requires ImageMagick; otherwise replace each file by hand.
mkdir -p assets/images/words assets/images/stickers assets/images/regions assets/trace_masks
for f in word_aav word_akh word_baavgai word_bombog; do
  convert -size 200x200 xc:"#FFD66B" assets/images/words/$f.png
done
for f in sticker_father_bear sticker_ball; do
  convert -size 200x200 xc:"#6BB66B" assets/images/stickers/$f.png
done
convert -size 400x250 xc:"#C8B070" assets/images/regions/region_yurt.png
convert -size 800x600 xc:"#BFE3FF" assets/images/steppe_map.png
for f in letter_a letter_b; do
  convert -size 256x256 xc:white -font Helvetica -pointsize 200 -fill black -gravity center -annotate +0+0 "${f: -1}" assets/trace_masks/$f.png
done
```

- [ ] **Step 4: Sanity check the asset bundle**

Run: `flutter clean && flutter pub get && flutter build apk --debug` (or `flutter build ios --no-codesign --debug`)
Expected: build succeeds. If it fails complaining about missing assets, double-check the filenames match `pubspec.yaml`.

**Checkpoint:** Content fixture + stub assets in place.

---

## Task 4: ContentRepository — load and validate `content.json`

**Files:**
- Create: `lib/core/content/content_repository.dart`
- Create: `test/core/content/content_repository_test.dart`
- Create: `test/fixtures/content_valid.json`
- Create: `test/fixtures/content_dangling_ref.json`
- Create: `test/fixtures/content_duplicate_id.json`

- [ ] **Step 1: Write the failing test**

Create `test/fixtures/content_valid.json` — copy the contents of `assets/content/content.json`.

Create `test/fixtures/content_dangling_ref.json` — same as valid but change `"stickerId": "sticker_father_bear"` in `lesson_01` to `"sticker_missing"`.

Create `test/fixtures/content_duplicate_id.json` — same as valid but duplicate the `"letter_a"` entry under `letters`.

Write `test/core/content/content_repository_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _loadFixture(String name) {
  final file = File('test/fixtures/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('ContentRepository.fromJson', () {
    test('parses a valid content fixture', () {
      final repo = ContentRepository.fromJson(_loadFixture('content_valid.json'));
      expect(repo.lessons, hasLength(2));
      expect(repo.letterById('letter_a').cyrillic, 'А');
      expect(repo.wordById('word_aav').english, 'father');
      expect(repo.lessonByOrder(1).id, 'lesson_01');
    });

    test('throws on dangling sticker reference', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_dangling_ref.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });

    test('throws on duplicate letter id', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_duplicate_id.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/content/content_repository_test.dart`
Expected: FAIL — `ContentRepository` doesn't exist.

- [ ] **Step 3: Implement `lib/core/content/content_repository.dart`**

```dart
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/lesson.dart';
import '../../models/letter.dart';
import '../../models/region.dart';
import '../../models/sticker.dart';
import '../../models/word.dart';

class ContentValidationError implements Exception {
  ContentValidationError(this.message);
  final String message;
  @override
  String toString() => 'ContentValidationError: $message';
}

class ContentRepository {
  ContentRepository._({
    required this.regions,
    required this.letters,
    required this.words,
    required this.lessons,
    required this.stickers,
  });

  final List<Region> regions;
  final Map<String, Letter> letters;
  final Map<String, Word> words;
  final List<Lesson> lessons;
  final Map<String, Sticker> stickers;

  static const _audioPrefix = 'assets/audio/';
  static const _wordImagePrefix = 'assets/images/words/';
  static const _stickerImagePrefix = 'assets/images/stickers/';
  static const _regionImagePrefix = 'assets/images/regions/';
  static const _traceMaskPrefix = 'assets/trace_masks/';

  Letter letterById(String id) =>
      letters[id] ?? (throw ContentValidationError('Unknown letter: $id'));
  Word wordById(String id) =>
      words[id] ?? (throw ContentValidationError('Unknown word: $id'));
  Lesson lessonById(String id) => lessons.firstWhere(
        (l) => l.id == id,
        orElse: () => throw ContentValidationError('Unknown lesson: $id'),
      );
  Lesson lessonByOrder(int order) => lessons.firstWhere(
        (l) => l.order == order,
        orElse: () => throw ContentValidationError('No lesson with order $order'),
      );
  Sticker stickerById(String id) =>
      stickers[id] ?? (throw ContentValidationError('Unknown sticker: $id'));
  Region regionById(String id) => regions.firstWhere(
        (r) => r.id == id,
        orElse: () => throw ContentValidationError('Unknown region: $id'),
      );

  List<Lesson> lessonsInRegion(String regionId) =>
      lessons.where((l) => l.regionId == regionId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  static Future<ContentRepository> loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/content/content.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw ContentValidationError('Root is not a JSON object');
    }
    return fromJson(decoded);
  }

  static ContentRepository fromJson(Map<String, dynamic> json) {
    final regionList = (json['regions'] as List)
        .map((e) => _regionFromRawJson(e as Map<String, dynamic>))
        .toList();
    final letterList = (json['letters'] as List)
        .map((e) => _letterFromRawJson(e as Map<String, dynamic>))
        .toList();
    final wordList = (json['words'] as List)
        .map((e) => _wordFromRawJson(e as Map<String, dynamic>))
        .toList();
    final lessonList = (json['lessons'] as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
    final stickerList = (json['stickers'] as List)
        .map((e) => _stickerFromRawJson(e as Map<String, dynamic>))
        .toList();

    _checkUniqueIds(regionList.map((e) => e.id), 'regions');
    _checkUniqueIds(letterList.map((e) => e.id), 'letters');
    _checkUniqueIds(wordList.map((e) => e.id), 'words');
    _checkUniqueIds(lessonList.map((e) => e.id), 'lessons');
    _checkUniqueIds(stickerList.map((e) => e.id), 'stickers');

    final letters = {for (final l in letterList) l.id: l};
    final words = {for (final w in wordList) w.id: w};
    final stickers = {for (final s in stickerList) s.id: s};
    final regionIds = regionList.map((r) => r.id).toSet();

    for (final w in wordList) {
      for (final lid in w.letterIds) {
        if (!letters.containsKey(lid)) {
          throw ContentValidationError(
              'word ${w.id} references unknown letter $lid');
        }
      }
    }

    for (final lesson in lessonList) {
      if (!regionIds.contains(lesson.regionId)) {
        throw ContentValidationError(
            'lesson ${lesson.id} references unknown region ${lesson.regionId}');
      }
      for (final lid in lesson.letterIds) {
        if (!letters.containsKey(lid)) {
          throw ContentValidationError(
              'lesson ${lesson.id} references unknown letter $lid');
        }
      }
      for (final wid in lesson.wordIds) {
        if (!words.containsKey(wid)) {
          throw ContentValidationError(
              'lesson ${lesson.id} references unknown word $wid');
        }
      }
      if (!stickers.containsKey(lesson.stickerId)) {
        throw ContentValidationError(
            'lesson ${lesson.id} references unknown sticker ${lesson.stickerId}');
      }
    }

    for (final s in stickerList) {
      if (!lessonList.any((l) => l.id == s.lessonId)) {
        throw ContentValidationError(
            'sticker ${s.id} references unknown lesson ${s.lessonId}');
      }
    }

    _checkContiguousOrder(lessonList.map((l) => l.order).toList(), 'lessons');
    _checkContiguousOrder(regionList.map((r) => r.order).toList(), 'regions');

    return ContentRepository._(
      regions: regionList..sort((a, b) => a.order.compareTo(b.order)),
      letters: letters,
      words: words,
      lessons: lessonList..sort((a, b) => a.order.compareTo(b.order)),
      stickers: stickers,
    );
  }

  static Region _regionFromRawJson(Map<String, dynamic> j) => Region.fromJson({
        ...j,
        'mapImagePath': '$_regionImagePrefix${j['mapImagePath']}',
      });

  static Letter _letterFromRawJson(Map<String, dynamic> j) => Letter(
        id: j['id'] as String,
        cyrillic: j['cyrillic'] as String,
        romanization: j['romanization'] as String,
        audioAssetPath: '$_audioPrefix${j['audio']}',
        traceTemplatePath: '$_traceMaskPrefix${j['traceMask']}',
      );

  static Word _wordFromRawJson(Map<String, dynamic> j) => Word(
        id: j['id'] as String,
        cyrillic: j['cyrillic'] as String,
        english: j['english'] as String,
        audioAssetPath: '$_audioPrefix${j['audio']}',
        imageAssetPath: '$_wordImagePrefix${j['image']}',
        letterIds: List<String>.from(j['letterIds'] as List),
      );

  static Sticker _stickerFromRawJson(Map<String, dynamic> j) => Sticker(
        id: j['id'] as String,
        lessonId: j['lessonId'] as String,
        imageAssetPath: '$_stickerImagePrefix${j['image']}',
        nameEn: j['nameEn'] as String,
      );

  static void _checkUniqueIds(Iterable<String> ids, String label) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        throw ContentValidationError('Duplicate $label id: $id');
      }
    }
  }

  static void _checkContiguousOrder(List<int> orders, String label) {
    final sorted = [...orders]..sort();
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i] != i + 1) {
        throw ContentValidationError(
            '$label orders are not contiguous from 1: $sorted');
      }
    }
  }
}
```

**Important**: Region's `Region.fromJson` expects `mapImagePath` not `mapImagePath` filename. The content.json uses `"mapImagePath": "region_yurt.png"` and we prefix it via `_regionFromRawJson`. The `OffsetConverter` handles `mapPosition`.

- [ ] **Step 4: Run the test — confirm it passes**

Run: `flutter test test/core/content/content_repository_test.dart`
Expected: all three tests PASS.

**Checkpoint:** Content loads, dangling/dup refs caught.

---

## Task 5: ProgressRepository — atomic JSON persistence

**Files:**
- Create: `lib/core/persistence/progress_repository.dart`
- Create: `test/core/persistence/progress_repository_test.dart`

- [ ] **Step 1: Write the failing test**

`test/core/persistence/progress_repository_test.dart`:

```dart
import 'dart:io';

import 'package:bambaruush/core/persistence/progress_repository.dart';
import 'package:bambaruush/models/lesson_progress.dart';
import 'package:bambaruush/models/progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;
  late ProgressRepository repo;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('progress_test_');
    repo = ProgressRepository(documentsDir: tmp);
  });

  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('load returns Progress.empty() when file missing', () async {
    final p = await repo.load();
    expect(p.lessons, isEmpty);
    expect(p.schemaVersion, 1);
  });

  test('save then load round-trips', () async {
    final original = Progress.empty().copyWith(
      lessons: {
        'lesson_01': const LessonProgress(
          lessonId: 'lesson_01',
          unlocked: true,
          completed: true,
          completionCount: 1,
        ),
      },
      earnedStickerIds: {'sticker_father_bear'},
    );
    await repo.save(original);
    final loaded = await repo.load();
    expect(loaded.lessons['lesson_01']!.completed, isTrue);
    expect(loaded.earnedStickerIds, contains('sticker_father_bear'));
  });

  test('corrupted file is treated as fresh start', () async {
    final f = File('${tmp.path}/progress.json');
    await f.writeAsString('{ not json');
    final loaded = await repo.load();
    expect(loaded.lessons, isEmpty);
  });

  test('schema version mismatch is treated as fresh start', () async {
    final f = File('${tmp.path}/progress.json');
    await f.writeAsString('{"schemaVersion": 999, "lessons": {}, "srsByWord": {}, '
        '"earnedStickerIds": [], "lastPlayed": "2026-05-27T00:00:00.000Z"}');
    final loaded = await repo.load();
    expect(loaded.schemaVersion, 1);
    expect(loaded.lessons, isEmpty);
  });

  test('reset deletes the file', () async {
    await repo.save(Progress.empty());
    await repo.reset();
    expect(File('${tmp.path}/progress.json').existsSync(), isFalse);
  });
}
```

- [ ] **Step 2: Run — confirm failure**

Run: `flutter test test/core/persistence/progress_repository_test.dart`
Expected: FAIL — `ProgressRepository` doesn't exist.

- [ ] **Step 3: Implement `lib/core/persistence/progress_repository.dart`**

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/progress.dart';

class ProgressRepository {
  ProgressRepository({required Directory documentsDir})
      : _file = File('${documentsDir.path}/progress.json');

  final File _file;

  static const _currentSchemaVersion = 1;

  Future<Progress> load() async {
    if (!_file.existsSync()) return Progress.empty();
    try {
      final raw = await _file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return Progress.empty();
      if (decoded['schemaVersion'] != _currentSchemaVersion) {
        return Progress.empty();
      }
      return Progress.fromJson(decoded);
    } catch (_) {
      return Progress.empty();
    }
  }

  Future<void> save(Progress p) async {
    final tmp = File('${_file.path}.tmp');
    await tmp.writeAsString(jsonEncode(p.toJson()), flush: true);
    await tmp.rename(_file.path);
  }

  Future<void> reset() async {
    if (_file.existsSync()) await _file.delete();
  }
}
```

- [ ] **Step 4: Run — confirm passes**

Run: `flutter test test/core/persistence/progress_repository_test.dart`
Expected: all tests PASS.

**Checkpoint:** Persistence works.

---

## Task 6: LeitnerEngine — pure SRS logic

**Files:**
- Create: `lib/core/srs/leitner_engine.dart`
- Create: `test/core/srs/leitner_engine_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:bambaruush/core/srs/leitner_engine.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 5, 27, 12);

  test('initial box is level 1 due now', () {
    final box = LeitnerEngine.initial('word_x', now);
    expect(box.level, 1);
    expect(box.correctStreak, 0);
    expect(box.nextReviewAt, now);
  });

  test('onCorrect promotes one level, schedules next interval', () {
    final box = LeitnerEngine.initial('word_x', now);
    final next = LeitnerEngine.onCorrect(box, now);
    expect(next.level, 2);
    expect(next.correctStreak, 1);
    expect(next.nextReviewAt, now.add(const Duration(days: 3)));
  });

  test('promotion clamps at level 5', () {
    var box = LeitnerEngine.initial('word_x', now);
    for (var i = 0; i < 10; i++) {
      box = LeitnerEngine.onCorrect(box, now);
    }
    expect(box.level, 5);
    expect(box.nextReviewAt, now.add(const Duration(days: 30)));
  });

  test('onWrong drops to level 1 and resets streak', () {
    var box = LeitnerEngine.initial('word_x', now);
    box = LeitnerEngine.onCorrect(box, now);
    box = LeitnerEngine.onCorrect(box, now);
    box = LeitnerEngine.onWrong(box, now);
    expect(box.level, 1);
    expect(box.correctStreak, 0);
    expect(box.nextReviewAt, now.add(const Duration(days: 1)));
  });

  test('isDue returns true at or after nextReviewAt', () {
    final box = SrsBox(
      wordId: 'w',
      level: 1,
      nextReviewAt: now,
      correctStreak: 0,
    );
    expect(LeitnerEngine.isDue(box, now), isTrue);
    expect(LeitnerEngine.isDue(box, now.add(const Duration(seconds: 1))), isTrue);
    expect(LeitnerEngine.isDue(box, now.subtract(const Duration(seconds: 1))), isFalse);
  });
}
```

- [ ] **Step 2: Run — confirm failure**

Run: `flutter test test/core/srs/leitner_engine_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
import '../../models/srs_box.dart';

class LeitnerEngine {
  static const intervals = <int, Duration>{
    1: Duration(days: 1),
    2: Duration(days: 3),
    3: Duration(days: 7),
    4: Duration(days: 14),
    5: Duration(days: 30),
  };

  static SrsBox initial(String wordId, DateTime now) => SrsBox(
        wordId: wordId,
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
}
```

- [ ] **Step 4: Run — confirm passes**

Run: `flutter test test/core/srs/leitner_engine_test.dart`
Expected: all PASS.

**Checkpoint:** SRS engine done.

---

## Task 7: Distractor selection

**Files:**
- Create: `lib/features/lesson/distractors.dart`
- Create: `test/features/lesson/distractors_test.dart`

- [ ] **Step 1: Failing test**

```dart
import 'package:bambaruush/features/lesson/distractors.dart';
import 'package:bambaruush/models/lesson.dart';
import 'package:bambaruush/models/word.dart';
import 'package:flutter_test/flutter_test.dart';

Word _w(String id, [List<String> letters = const []]) => Word(
  id: id, cyrillic: id, english: id,
  audioAssetPath: '', imageAssetPath: '',
  letterIds: letters,
);

Lesson _lesson(String id, String regionId, List<String> wordIds) => Lesson(
  id: id, order: 1, regionId: regionId,
  letterIds: const [], wordIds: wordIds, stickerId: 's',
);

void main() {
  final allWords = [_w('a'), _w('b'), _w('c'), _w('d'), _w('e')];
  final lessonInRegion = _lesson('l1', 'r1', ['a', 'b', 'c']);
  final wordToRegion = {'a': 'r1', 'b': 'r1', 'c': 'r1', 'd': 'r2', 'e': 'r2'};

  test('returns 2 distractors from same region when available', () {
    final result = pickDistractors(
      targetWordId: 'a',
      lesson: lessonInRegion,
      allWords: allWords,
      wordIdToRegionId: wordToRegion,
      n: 2,
      seed: 42,
    );
    expect(result.length, 2);
    expect(result.contains('a'), isFalse);
    expect(result.every((id) => ['b', 'c'].contains(id)), isTrue);
  });

  test('falls back across regions when same-region pool is short', () {
    final lessonAlone = _lesson('l1', 'r1', ['a']);
    final wordRegion = {'a': 'r1', 'd': 'r2', 'e': 'r2'};
    final result = pickDistractors(
      targetWordId: 'a',
      lesson: lessonAlone,
      allWords: [_w('a'), _w('d'), _w('e')],
      wordIdToRegionId: wordRegion,
      n: 2,
      seed: 42,
    );
    expect(result.length, 2);
    expect(result.contains('a'), isFalse);
    expect(result.toSet(), {'d', 'e'});
  });

  test('deterministic for same seed', () {
    final a = pickDistractors(
      targetWordId: 'a', lesson: lessonInRegion, allWords: allWords,
      wordIdToRegionId: wordToRegion, n: 2, seed: 7,
    );
    final b = pickDistractors(
      targetWordId: 'a', lesson: lessonInRegion, allWords: allWords,
      wordIdToRegionId: wordToRegion, n: 2, seed: 7,
    );
    expect(a, b);
  });
}
```

- [ ] **Step 2: Run — confirm failure**

Run: `flutter test test/features/lesson/distractors_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
import 'dart:math';

import '../../models/lesson.dart';
import '../../models/word.dart';

List<String> pickDistractors({
  required String targetWordId,
  required Lesson lesson,
  required List<Word> allWords,
  required Map<String, String> wordIdToRegionId,
  required int n,
  int? seed,
}) {
  final rand = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
  final targetRegion = lesson.regionId;

  final sameRegion = allWords
      .where((w) => w.id != targetWordId)
      .where((w) => wordIdToRegionId[w.id] == targetRegion)
      .map((w) => w.id)
      .toList()
    ..shuffle(rand);

  if (sameRegion.length >= n) return sameRegion.take(n).toList();

  final fallback = allWords
      .where((w) => w.id != targetWordId && wordIdToRegionId[w.id] != targetRegion)
      .map((w) => w.id)
      .toList()
    ..shuffle(rand);

  return [...sameRegion, ...fallback.take(n - sameRegion.length)];
}
```

- [ ] **Step 4: Run — confirm passes**

Run: `flutter test test/features/lesson/distractors_test.dart`
Expected: all PASS.

**Checkpoint:** Distractor logic done.

---

## Task 8: AudioService

**Files:**
- Create: `lib/core/audio/audio_service.dart`

No unit test — `just_audio` requires platform plugins. We'll verify via widget/integration tests later.

- [ ] **Step 1: Implement**

```dart
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService() : _player = AudioPlayer();

  final AudioPlayer _player;
  double _volume = 1.0;
  final Set<String> _preloaded = <String>{};

  Future<void> preload(List<String> assetPaths) async {
    for (final p in assetPaths) {
      if (_preloaded.contains(p)) continue;
      try {
        await _player.setAsset(p);
        _preloaded.add(p);
      } catch (_) {
        // Bundled asset missing or unreadable — skip.
      }
    }
  }

  Future<void> play(String assetPath) async {
    try {
      await _player.stop();
      await _player.setAsset(assetPath);
      await _player.setVolume(_volume);
      await _player.play();
    } catch (_) {
      // Playback failure is non-fatal; skip silently.
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _player.setVolume(_volume);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
```

- [ ] **Step 2: Confirm compiles**

Run: `flutter analyze`
Expected: no errors.

**Checkpoint:** Audio service ready (untested at unit level; covered by integration test later).

---

## Task 9: Riverpod providers for core services

**Files:**
- Create: `lib/core/providers.dart`

- [ ] **Step 1: Create the file**

```dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/progress.dart';
import 'audio/audio_service.dart';
import 'content/content_repository.dart';
import 'persistence/progress_repository.dart';

/// Set in main() after async bootstrap completes.
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  throw UnimplementedError('Override in ProviderScope at app start');
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  throw UnimplementedError('Override in ProviderScope at app start');
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final svc = AudioService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// Mutable Progress state. Reads pull from disk on first access via the repository.
class ProgressController extends StateNotifier<Progress> {
  ProgressController(this._repo, Progress initial) : super(initial);
  final ProgressRepository _repo;

  Future<void> update(Progress next) async {
    state = next;
    await _repo.save(next);
  }

  Future<void> reset() async {
    await _repo.reset();
    state = Progress.empty();
  }
}

final progressControllerProvider =
    StateNotifierProvider<ProgressController, Progress>((ref) {
  throw UnimplementedError('Override in ProviderScope at app start');
});

Future<Directory> appDocumentsDirectory() => getApplicationDocumentsDirectory();
```

- [ ] **Step 2: Confirm compile**

Run: `flutter analyze`
Expected: no errors.

**Checkpoint:** Provider wiring stubs ready.

---

## Task 10: Bootstrap in main.dart — load content + progress, then runApp

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace `lib/main.dart` contents**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/content/content_repository.dart';
import 'core/persistence/progress_repository.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final content = await ContentRepository.loadFromAssets();
  final docs = await appDocumentsDirectory();
  final progressRepo = ProgressRepository(documentsDir: docs);
  final progress = await progressRepo.load();

  runApp(
    ProviderScope(
      overrides: [
        contentRepositoryProvider.overrideWithValue(content),
        progressRepositoryProvider.overrideWithValue(progressRepo),
        progressControllerProvider.overrideWith(
          (ref) => ProgressController(progressRepo, progress),
        ),
      ],
      child: const BambaruushApp(),
    ),
  );
}
```

- [ ] **Step 2: Run the app**

Run: `flutter run`
Expected: app launches normally; the home screen still says "Bambaruush — coming soon". No exceptions in the console.

**Checkpoint:** Bootstrap wires content + progress.

---

## Task 11: Routing skeleton + Splash + minimal Steppe map

**Files:**
- Create: `lib/core/routing/app_router.dart`
- Create: `lib/features/steppe/splash_screen.dart`
- Create: `lib/features/steppe/steppe_map_screen.dart`
- Create: `lib/features/steppe/region_detail_screen.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Create `lib/features/steppe/splash_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Tiny delay so the splash is visible at all.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted) context.go('/steppe');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🐻', style: TextStyle(fontSize: 64)),
            SizedBox(height: 12),
            Text('Bambaruush'),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create `lib/features/steppe/steppe_map_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

class SteppeMapScreen extends ConsumerWidget {
  const SteppeMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Steppe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark),
            tooltip: 'Sticker Album',
            onPressed: () => context.push('/album'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings/gate'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/steppe_map.png',
              fit: BoxFit.cover,
            ),
          ),
          for (final region in content.regions)
            Positioned(
              left: region.mapPosition.dx *
                  MediaQuery.of(context).size.width,
              top: region.mapPosition.dy *
                  MediaQuery.of(context).size.height,
              child: _RegionTile(
                regionId: region.id,
                label: region.nameEn,
                onTap: () => context.push('/region/${region.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    required this.regionId,
    required this.label,
    required this.onTap,
  });
  final String regionId;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.brown.shade700, width: 2),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
```

- [ ] **Step 3: Create `lib/features/steppe/region_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../models/lesson.dart';
import '../../models/progress.dart';

class RegionDetailScreen extends ConsumerWidget {
  const RegionDetailScreen({super.key, required this.regionId});
  final String regionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final progress = ref.watch(progressControllerProvider);
    final region = content.regionById(regionId);
    final lessons = content.lessonsInRegion(regionId);

    return Scaffold(
      appBar: AppBar(title: Text(region.nameEn)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final lesson = lessons[i];
          final unlocked = _isUnlocked(lesson, content.lessons, progress);
          final completed =
              progress.lessons[lesson.id]?.completed ?? false;
          return _LessonTile(
            lesson: lesson,
            letterCyrillic: content
                .letterById(lesson.letterIds.first)
                .cyrillic,
            unlocked: unlocked,
            completed: completed,
            onTap: unlocked
                ? () => context.push('/lesson/${lesson.id}')
                : null,
          );
        },
      ),
    );
  }

  bool _isUnlocked(Lesson lesson, List<Lesson> all, Progress progress) {
    if (lesson.order == 1) return true;
    final prev = all.firstWhere((l) => l.order == lesson.order - 1);
    return progress.lessons[prev.id]?.completed ?? false;
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.letterCyrillic,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });
  final Lesson lesson;
  final String letterCyrillic;
  final bool unlocked;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.45,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              completed ? Colors.green.shade400 : Colors.amber.shade400,
          child: Text(
            letterCyrillic,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(lesson.id),
        trailing: completed
            ? const Icon(Icons.star, color: Colors.amber)
            : (unlocked ? const Icon(Icons.chevron_right) : const Icon(Icons.lock)),
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.brown.shade200),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create `lib/core/routing/app_router.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/steppe/region_detail_screen.dart';
import '../../features/steppe/splash_screen.dart';
import '../../features/steppe/steppe_map_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/steppe', builder: (_, __) => const SteppeMapScreen()),
      GoRoute(
        path: '/region/:id',
        builder: (_, state) =>
            RegionDetailScreen(regionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) => Scaffold(
          appBar: AppBar(title: Text('Lesson ${state.pathParameters['id']}')),
          body: const Center(child: Text('Lesson runner — coming next task')),
        ),
      ),
      GoRoute(
        path: '/album',
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Sticker Album')),
          body: const Center(child: Text('Album — coming in Milestone C')),
        ),
      ),
      GoRoute(
        path: '/settings/gate',
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: const Center(child: Text('Settings — coming in Milestone C')),
        ),
      ),
    ],
  );
});
```

- [ ] **Step 5: Replace `lib/app.dart` to use the router**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';

class BambaruushApp extends ConsumerWidget {
  const BambaruushApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Bambaruush',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC08A4A)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 6: Run and verify**

Run: `flutter run`
Expected:
- Splash flash (bear + title)
- Steppe map with one "The Yurt" region label visible
- Tap "The Yurt" → list shows two lessons (lesson_01 unlocked, lesson_02 locked)
- Tap lesson_01 → placeholder "Lesson runner — coming next task"

**Checkpoint:** Navigation skeleton works end-to-end.

---

## Task 12: MascotController and placeholder overlay

**Files:**
- Create: `lib/features/mascot/mascot_controller.dart`
- Create: `lib/features/mascot/mascot_overlay.dart`

- [ ] **Step 1: Create `mascot_controller.dart`**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mascot_mood.dart';

class MascotController extends StateNotifier<MascotMood> {
  MascotController() : super(MascotMood.idle);
  Timer? _resetTimer;

  void cheer() => _setTransient(MascotMood.cheer);
  void sad() => _setTransient(MascotMood.sad);
  void point() => _setTransient(MascotMood.point);
  void wave() => _setTransient(MascotMood.wave);
  void sleep() => _set(MascotMood.sleep);
  void idle() => _set(MascotMood.idle);

  void _set(MascotMood mood) {
    _resetTimer?.cancel();
    state = mood;
  }

  void _setTransient(MascotMood mood) {
    _resetTimer?.cancel();
    state = mood;
    _resetTimer = Timer(const Duration(seconds: 2), () {
      state = MascotMood.idle;
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
}

final mascotProvider =
    StateNotifierProvider<MascotController, MascotMood>((ref) => MascotController());
```

- [ ] **Step 2: Create `mascot_overlay.dart` (placeholder — emoji bear; Rive comes in Milestone D)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mascot_mood.dart';
import 'mascot_controller.dart';

class MascotOverlay extends ConsumerWidget {
  const MascotOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(mascotProvider);
    return Positioned(
      right: 16,
      bottom: 24,
      child: IgnorePointer(
        child: Text(
          _emojiFor(mood),
          style: const TextStyle(fontSize: 56),
        ).animate(key: ValueKey(mood)).scale(
              duration: const Duration(milliseconds: 280),
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  String _emojiFor(MascotMood mood) {
    switch (mood) {
      case MascotMood.cheer:
        return '🎉🐻';
      case MascotMood.sad:
        return '😢🐻';
      case MascotMood.point:
        return '👉🐻';
      case MascotMood.wave:
        return '👋🐻';
      case MascotMood.sleep:
        return '💤🐻';
      case MascotMood.idle:
        return '🐻';
    }
  }
}
```

- [ ] **Step 3: Wire `MascotOverlay` into the Steppe + Region screens**

In `lib/features/steppe/steppe_map_screen.dart`, wrap the `body` Stack so it ends with the overlay:

Replace:
```dart
      body: Stack(
        children: [
          Positioned.fill(...),
          for (final region in content.regions) ...
        ],
      ),
```

With:
```dart
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/steppe_map.png', fit: BoxFit.cover),
          ),
          for (final region in content.regions)
            Positioned(
              left: region.mapPosition.dx * MediaQuery.of(context).size.width,
              top: region.mapPosition.dy * MediaQuery.of(context).size.height,
              child: _RegionTile(
                regionId: region.id,
                label: region.nameEn,
                onTap: () => context.push('/region/${region.id}'),
              ),
            ),
          const MascotOverlay(),
        ],
      ),
```

(Add `import '../mascot/mascot_overlay.dart';` at the top.)

In `RegionDetailScreen`, wrap its `body: ListView(...)` similarly:

```dart
      body: Stack(
        children: [
          ListView.separated(...),
          const MascotOverlay(),
        ],
      ),
```

- [ ] **Step 4: Run, confirm a bear is visible on Steppe + Region screens**

Run: `flutter run`
Expected: emoji bear appears in the bottom-right corner of both screens. No tap interaction yet.

**Checkpoint:** Mascot controller + placeholder overlay in place.

---

## Task 13: LessonRunner — state machine

**Files:**
- Create: `lib/features/lesson/lesson_runner.dart`
- Create: `test/features/lesson/lesson_runner_test.dart`

- [ ] **Step 1: Failing test — drives a 1-letter, 2-word lesson through Intro, Listen×2, Read×2, Reward**

```dart
import 'package:bambaruush/features/lesson/lesson_runner.dart';
import 'package:bambaruush/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

Lesson _l() => const Lesson(
  id: 'lesson_01', order: 1, regionId: 'r1',
  letterIds: ['letter_a'],
  wordIds: ['word_aav', 'word_akh'],
  stickerId: 'sticker_father_bear',
);

void main() {
  test('step sequence is intro, listen×N, read×N, reward (trace skipped in MVP)', () {
    final runner = LessonRunnerController(lesson: _l(), skipTrace: true);
    final stages = <Type>[];
    while (runner.state.stage is! LessonComplete) {
      stages.add(runner.state.stage.runtimeType);
      runner.advance(correct: true);
    }
    expect(stages, [
      IntroStage, ListenStage, ListenStage, ReadStage, ReadStage, RewardStage,
    ]);
  });

  test('all-correct lesson leaves all wordCorrectness true', () {
    final runner = LessonRunnerController(lesson: _l(), skipTrace: true);
    // intro, listen×2, read×2, reward — all correct first try → 6 advances.
    for (var i = 0; i < 6; i++) {
      runner.advance(correct: true);
    }
    expect(runner.state.wordCorrectness['word_aav'], isTrue);
    expect(runner.state.wordCorrectness['word_akh'], isTrue);
  });

  test('attempt-1 wrong puts stage into attempt 2, then advancing records fail', () {
    final runner = LessonRunnerController(lesson: _l(), skipTrace: true);
    runner.advance(correct: true); // intro
    runner.advance(correct: true); // listen word_aav attempt 1 — pass
    // Now on listen word_akh attempt 1.
    runner.advance(correct: false); // fail attempt 1
    // Still on listen word_akh but now attempt 2.
    final stage = runner.state.stage as ListenStage;
    expect(stage.wordId, 'word_akh');
    expect(stage.attempt, 2);
    runner.advance(correct: true); // attempt 2 — advance regardless; records as fail.
    // Now on read word_aav attempt 1.
    expect(runner.state.stage, isA<ReadStage>());
    runner.advance(correct: true); // read word_aav pass
    runner.advance(correct: true); // read word_akh pass (but already marked fail from listen)
    expect(runner.state.wordCorrectness['word_aav'], isTrue);
    expect(runner.state.wordCorrectness['word_akh'], isFalse);
  });
}
```

- [ ] **Step 2: Run — confirm failure**

Run: `flutter test test/features/lesson/lesson_runner_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `lib/features/lesson/lesson_runner.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/lesson.dart';

sealed class LessonStage {
  const LessonStage();
}

class IntroStage extends LessonStage {
  const IntroStage(this.letterId);
  final String letterId;
}

class TraceStage extends LessonStage {
  const TraceStage(this.letterId);
  final String letterId;
}

class ListenStage extends LessonStage {
  const ListenStage({required this.wordId, required this.attempt});
  final String wordId;
  final int attempt;
}

class ReadStage extends LessonStage {
  const ReadStage({required this.wordId, required this.attempt});
  final String wordId;
  final int attempt;
}

class RewardStage extends LessonStage {
  const RewardStage(this.stickerId);
  final String stickerId;
}

class LessonComplete extends LessonStage {
  const LessonComplete();
}

class LessonRunnerState {
  LessonRunnerState({
    required this.lesson,
    required this.stage,
    required this.totalSteps,
    required this.currentStep,
    required this.wordCorrectness,
  });

  final Lesson lesson;
  final LessonStage stage;
  final int totalSteps;
  final int currentStep;
  final Map<String, bool> wordCorrectness;

  LessonRunnerState copyWith({
    LessonStage? stage,
    int? currentStep,
    Map<String, bool>? wordCorrectness,
  }) =>
      LessonRunnerState(
        lesson: lesson,
        stage: stage ?? this.stage,
        totalSteps: totalSteps,
        currentStep: currentStep ?? this.currentStep,
        wordCorrectness: wordCorrectness ?? this.wordCorrectness,
      );
}

class LessonRunnerController extends StateNotifier<LessonRunnerState> {
  LessonRunnerController({required Lesson lesson, this.skipTrace = false})
      : super(_initial(lesson, skipTrace)) {
    _lesson = lesson;
  }

  final bool skipTrace;
  late final Lesson _lesson;

  // Tracks current-word attempt count between stages.
  final Map<String, int> _attempts = {};
  // Per-word first-attempt correctness (true until proven false).
  final Map<String, bool> _firstAttemptCorrect = {};

  static LessonRunnerState _initial(Lesson lesson, bool skipTrace) {
    final stages = _buildSequence(lesson, skipTrace);
    return LessonRunnerState(
      lesson: lesson,
      stage: stages.first,
      totalSteps: stages.length,
      currentStep: 0,
      wordCorrectness: {for (final w in lesson.wordIds) w: true},
    );
  }

  static List<LessonStage> _buildSequence(Lesson lesson, bool skipTrace) {
    final stages = <LessonStage>[];
    for (final letterId in lesson.letterIds) {
      stages.add(IntroStage(letterId));
      if (!skipTrace) stages.add(TraceStage(letterId));
    }
    for (final wid in lesson.wordIds) {
      stages.add(ListenStage(wordId: wid, attempt: 1));
    }
    for (final wid in lesson.wordIds) {
      stages.add(ReadStage(wordId: wid, attempt: 1));
    }
    stages.add(RewardStage(lesson.stickerId));
    return stages;
  }

  List<LessonStage> get _sequence => _buildSequence(_lesson, skipTrace);

  void advance({required bool correct}) {
    final current = state.stage;
    if (current is ListenStage || current is ReadStage) {
      final wordId = current is ListenStage ? current.wordId : (current as ReadStage).wordId;
      final attempt = current is ListenStage ? current.attempt : (current as ReadStage).attempt;
      if (attempt == 1 && !correct) {
        // Stay on same stage with attempt 2; record first-attempt failure.
        _firstAttemptCorrect[wordId] = false;
        state = state.copyWith(
          stage: current is ListenStage
              ? ListenStage(wordId: wordId, attempt: 2)
              : ReadStage(wordId: wordId, attempt: 2),
        );
        return;
      }
      // Either attempt-1 correct (true) or attempt-2 (anything → records as failure if not already true).
      if (attempt == 1 && correct) {
        _firstAttemptCorrect[wordId] = (_firstAttemptCorrect[wordId] ?? true) && true;
      } else {
        // attempt 2 always records first-attempt fail
        _firstAttemptCorrect[wordId] = false;
      }
    }

    final nextIndex = state.currentStep + 1;
    final seq = _sequence;
    if (nextIndex >= seq.length) {
      state = state.copyWith(
        stage: const LessonComplete(),
        currentStep: nextIndex,
        wordCorrectness: _computeWordCorrectness(),
      );
      return;
    }
    state = state.copyWith(
      stage: seq[nextIndex],
      currentStep: nextIndex,
      wordCorrectness: _computeWordCorrectness(),
    );
  }

  Map<String, bool> _computeWordCorrectness() => {
        for (final w in _lesson.wordIds)
          w: _firstAttemptCorrect[w] ?? true,
      };
}
```

- [ ] **Step 4: Run — confirm passes**

Run: `flutter test test/features/lesson/lesson_runner_test.dart`
Expected: both tests PASS.

**Checkpoint:** LessonRunner state machine works.

---

## Task 14: LessonRunnerScreen + Intro/Listen/Read/Reward stages (Trace stubbed)

**Files:**
- Create: `lib/features/lesson/lesson_runner_screen.dart`
- Create: `lib/features/lesson/intro_stage.dart`
- Create: `lib/features/lesson/listen_stage.dart`
- Create: `lib/features/lesson/read_stage.dart`
- Create: `lib/features/lesson/reward_stage.dart`
- Modify: `lib/core/routing/app_router.dart` (point `/lesson/:id` to the real screen)

- [ ] **Step 1: `lesson_runner_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/srs/leitner_engine.dart';
import '../../models/lesson.dart';
import '../../models/lesson_progress.dart';
import '../../models/progress.dart';
import '../../models/srs_box.dart';
import '../mascot/mascot_overlay.dart';
import 'intro_stage.dart';
import 'lesson_runner.dart';
import 'listen_stage.dart';
import 'read_stage.dart';
import 'reward_stage.dart';

final lessonRunnerProvider = StateNotifierProvider.autoDispose
    .family<LessonRunnerController, LessonRunnerState, Lesson>(
  (ref, lesson) => LessonRunnerController(lesson: lesson, skipTrace: true),
);

class LessonRunnerScreen extends ConsumerWidget {
  const LessonRunnerScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final lesson = content.lessonById(lessonId);
    final state = ref.watch(lessonRunnerProvider(lesson));
    final runner = ref.read(lessonRunnerProvider(lesson).notifier);

    ref.listen<LessonRunnerState>(
      lessonRunnerProvider(lesson),
      (prev, next) async {
        if (next.stage is LessonComplete && prev?.stage is! LessonComplete) {
          await _persistCompletion(ref, lesson, next);
          if (context.mounted) context.pop();
        }
      },
    );

    return WillPopScope(
      onWillPop: () async => await _confirmQuit(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lesson ${lesson.order}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmQuit(context) && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            _stageWidget(state, runner),
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
      ),
    );
  }

  Widget _stageWidget(LessonRunnerState s, LessonRunnerController r) {
    final stage = s.stage;
    if (stage is IntroStage) return IntroStageWidget(stage: stage, onContinue: () => r.advance(correct: true));
    if (stage is ListenStage) return ListenStageWidget(stage: stage, lesson: s.lesson, onResult: r.advance);
    if (stage is ReadStage) return ReadStageWidget(stage: stage, lesson: s.lesson, onResult: r.advance);
    if (stage is RewardStage) return RewardStageWidget(stage: stage, onContinue: () => r.advance(correct: true));
    return const SizedBox.shrink();
  }

  Future<bool> _confirmQuit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit lesson?'),
        content: const Text('Your progress in this lesson will not be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep playing')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Quit')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _persistCompletion(WidgetRef ref, Lesson lesson, LessonRunnerState s) async {
    final progress = ref.read(progressControllerProvider);
    final progressCtrl = ref.read(progressControllerProvider.notifier);
    final content = ref.read(contentRepositoryProvider);
    final now = DateTime.now();

    final newSrs = {...progress.srsByWord};
    for (final wid in lesson.wordIds) {
      final correct = s.wordCorrectness[wid] ?? false;
      final existing = newSrs[wid] ?? LeitnerEngine.initial(wid, now);
      newSrs[wid] = correct ? LeitnerEngine.onCorrect(existing, now) : LeitnerEngine.onWrong(existing, now);
    }

    final newLessons = {...progress.lessons};
    newLessons[lesson.id] = LessonProgress(
      lessonId: lesson.id,
      unlocked: true,
      completed: true,
      completionCount: (progress.lessons[lesson.id]?.completionCount ?? 0) + 1,
      completedAt: now,
    );
    final allLessons = content.lessons;
    final next = allLessons.where((l) => l.order == lesson.order + 1).firstOrNull;
    if (next != null && newLessons[next.id] == null) {
      newLessons[next.id] = LessonProgress(
        lessonId: next.id, unlocked: true, completed: false, completionCount: 0,
      );
    }

    await progressCtrl.update(progress.copyWith(
      lessons: newLessons,
      srsByWord: newSrs,
      earnedStickerIds: {...progress.earnedStickerIds, lesson.stickerId},
      lastPlayed: now,
    ));
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
```

- [ ] **Step 2: `intro_stage.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'lesson_runner.dart';

class IntroStageWidget extends ConsumerStatefulWidget {
  const IntroStageWidget({super.key, required this.stage, required this.onContinue});
  final IntroStage stage;
  final VoidCallback onContinue;
  @override
  ConsumerState<IntroStageWidget> createState() => _IntroStageWidgetState();
}

class _IntroStageWidgetState extends ConsumerState<IntroStageWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final letter = ref.read(contentRepositoryProvider).letterById(widget.stage.letterId);
      ref.read(audioServiceProvider).play(letter.audioAssetPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final letter = ref.watch(contentRepositoryProvider).letterById(widget.stage.letterId);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(letter.cyrillic, style: const TextStyle(fontSize: 160, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(audioServiceProvider).play(letter.audioAssetPath),
            icon: const Icon(Icons.volume_up),
            label: const Text('Hear it again'),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: widget.onContinue,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: `listen_stage.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/lesson.dart';
import '../../models/word.dart';
import '../mascot/mascot_controller.dart';
import 'distractors.dart';
import 'lesson_runner.dart';

class ListenStageWidget extends ConsumerStatefulWidget {
  const ListenStageWidget({
    super.key,
    required this.stage,
    required this.lesson,
    required this.onResult,
  });
  final ListenStage stage;
  final Lesson lesson;
  final void Function({required bool correct}) onResult;

  @override
  ConsumerState<ListenStageWidget> createState() => _ListenStageWidgetState();
}

class _ListenStageWidgetState extends ConsumerState<ListenStageWidget> {
  late List<Word> _tiles;

  @override
  void initState() {
    super.initState();
    _prepare();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playTarget());
  }

  void _prepare() {
    final content = ref.read(contentRepositoryProvider);
    final wordToRegion = <String, String>{};
    for (final lesson in content.lessons) {
      for (final wid in lesson.wordIds) {
        wordToRegion[wid] = lesson.regionId;
      }
    }
    final distractorIds = pickDistractors(
      targetWordId: widget.stage.wordId,
      lesson: widget.lesson,
      allWords: content.words.values.toList(),
      wordIdToRegionId: wordToRegion,
      n: 2,
      seed: '${widget.stage.wordId}-${widget.stage.attempt}'.hashCode,
    );
    final tiles = [
      content.wordById(widget.stage.wordId),
      ...distractorIds.map(content.wordById),
    ]..shuffle();
    _tiles = tiles;
  }

  Future<void> _playTarget() async {
    final content = ref.read(contentRepositoryProvider);
    final target = content.wordById(widget.stage.wordId);
    await ref.read(audioServiceProvider).play(target.audioAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('Tap the picture', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _playTarget,
            icon: const Icon(Icons.volume_up),
            label: const Text('Play'),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _tiles.map((w) => _Tile(word: w, onTap: () => _onTap(w))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(Word tapped) {
    final correct = tapped.id == widget.stage.wordId;
    final mascot = ref.read(mascotProvider.notifier);
    if (correct) {
      mascot.cheer();
    } else {
      mascot.sad();
      if (widget.stage.attempt == 1) {
        _playTarget();
      }
    }
    widget.onResult(correct: correct);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.word, required this.onTap});
  final Word word;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.brown.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(word.imageAssetPath, fit: BoxFit.contain),
            ),
            Text(word.english, style: const TextStyle(fontSize: 12, color: Colors.brown)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: `read_stage.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/lesson.dart';
import '../../models/word.dart';
import '../mascot/mascot_controller.dart';
import 'distractors.dart';
import 'lesson_runner.dart';

class ReadStageWidget extends ConsumerStatefulWidget {
  const ReadStageWidget({
    super.key,
    required this.stage,
    required this.lesson,
    required this.onResult,
  });
  final ReadStage stage;
  final Lesson lesson;
  final void Function({required bool correct}) onResult;

  @override
  ConsumerState<ReadStageWidget> createState() => _ReadStageWidgetState();
}

class _ReadStageWidgetState extends ConsumerState<ReadStageWidget> {
  late List<Word> _tiles;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare() {
    final content = ref.read(contentRepositoryProvider);
    final wordToRegion = <String, String>{};
    for (final lesson in content.lessons) {
      for (final wid in lesson.wordIds) {
        wordToRegion[wid] = lesson.regionId;
      }
    }
    final distractorIds = pickDistractors(
      targetWordId: widget.stage.wordId,
      lesson: widget.lesson,
      allWords: content.words.values.toList(),
      wordIdToRegionId: wordToRegion,
      n: 2,
      seed: 'read-${widget.stage.wordId}-${widget.stage.attempt}'.hashCode,
    );
    _tiles = [
      content.wordById(widget.stage.wordId),
      ...distractorIds.map(content.wordById),
    ]..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(contentRepositoryProvider).wordById(widget.stage.wordId);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(target.cyrillic, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => ref.read(audioServiceProvider).play(target.audioAssetPath),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _tiles.map((w) => _Tile(word: w, onTap: () => _onTap(w))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(Word tapped) {
    final correct = tapped.id == widget.stage.wordId;
    final mascot = ref.read(mascotProvider.notifier);
    correct ? mascot.cheer() : mascot.sad();
    widget.onResult(correct: correct);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.word, required this.onTap});
  final Word word;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.brown.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(word.imageAssetPath, fit: BoxFit.contain),
      ),
    );
  }
}
```

- [ ] **Step 5: `reward_stage.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../mascot/mascot_controller.dart';
import 'lesson_runner.dart';

class RewardStageWidget extends ConsumerStatefulWidget {
  const RewardStageWidget({super.key, required this.stage, required this.onContinue});
  final RewardStage stage;
  final VoidCallback onContinue;
  @override
  ConsumerState<RewardStageWidget> createState() => _RewardStageWidgetState();
}

class _RewardStageWidgetState extends ConsumerState<RewardStageWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mascotProvider.notifier).cheer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sticker = ref.watch(contentRepositoryProvider).stickerById(widget.stage.stickerId);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(sticker.imageAssetPath, width: 180, height: 180)
              .animate()
              .scale(begin: const Offset(0.6, 0.6), curve: Curves.elasticOut, duration: const Duration(milliseconds: 600)),
          const SizedBox(height: 12),
          Text(sticker.nameEn, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.onContinue,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Wire route**

Modify `lib/core/routing/app_router.dart` — replace the `/lesson/:id` placeholder route with:

```dart
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) =>
            LessonRunnerScreen(lessonId: state.pathParameters['id']!),
      ),
```

And add `import '../../features/lesson/lesson_runner_screen.dart';` at the top.

- [ ] **Step 7: Run the app, play through Lesson 1**

Run: `flutter run`
Expected:
- Splash → Steppe → tap Yurt → tap Lesson 1
- See letter "А", tap Next
- See "Tap the picture" with 3 word tiles. Tapping any tile advances (audio plays only if device audio works; otherwise silent — that's expected with stub mp3s).
- Two listen rounds, two read rounds, then sticker animation.
- Tap Continue → returns to Region. Lesson 1 now shows the star icon, Lesson 2 is unlocked.
- Kill app, relaunch → Lesson 1 still complete, Lesson 2 still unlocked.

**Checkpoint:** End-to-end MVP. Trace stubbed, but the loop works.

---

# Milestone B — TraceStage

## Task 15: TraceStage widget + bitmap coverage evaluation

**Files:**
- Create: `lib/features/lesson/trace_stage.dart`
- Create: `lib/features/lesson/trace_evaluator.dart`
- Create: `test/features/lesson/trace_evaluator_test.dart`
- Modify: `lib/features/lesson/lesson_runner_screen.dart` (route TraceStage)
- Modify: `lib/features/lesson/lesson_runner.dart` (default `skipTrace` false in production)

- [ ] **Step 1: Failing test for evaluator**

```dart
import 'dart:typed_data';

import 'package:bambaruush/features/lesson/trace_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A 4×4 template where the diagonal is the "letter" (alpha = 255 on diagonal).
  final template = Uint8List.fromList([
    255, 0, 0, 0,
    0, 255, 0, 0,
    0, 0, 255, 0,
    0, 0, 0, 255,
  ]);

  test('full diagonal coverage with no outside marks passes', () {
    final strokes = Uint8List.fromList([
      255, 0, 0, 0,
      0, 255, 0, 0,
      0, 0, 255, 0,
      0, 0, 0, 255,
    ]);
    final result = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(result.passed, isTrue);
    expect(result.insideRatio, 1.0);
    expect(result.outsideRatio, 0.0);
  });

  test('all-outside-no-inside fails', () {
    final strokes = Uint8List.fromList([
      0, 255, 255, 255,
      255, 0, 255, 255,
      255, 255, 0, 255,
      255, 255, 255, 0,
    ]);
    final result = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(result.passed, isFalse);
    expect(result.insideRatio, 0.0);
  });

  test('majority-inside under threshold for outside passes', () {
    // 3 of 4 diagonal pixels filled; 0 outside marks.
    final strokes = Uint8List.fromList([
      255, 0, 0, 0,
      0, 255, 0, 0,
      0, 0, 255, 0,
      0, 0, 0, 0,
    ]);
    final r = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(r.insideRatio, closeTo(0.75, 0.001));
    expect(r.passed, isTrue);
  });

  test('inside threshold met but heavy outside fails', () {
    final strokes = Uint8List.fromList([
      255, 255, 255, 255,
      255, 255, 255, 255,
      255, 255, 255, 255,
      255, 255, 255, 255,
    ]);
    final r = TraceEvaluator.evaluate(
      strokesMask: strokes, templateMask: template, width: 4, height: 4,
    );
    expect(r.insideRatio, 1.0);
    expect(r.outsideRatio, greaterThan(0.4));
    expect(r.passed, isFalse);
  });
}
```

- [ ] **Step 2: Run — confirm failure**

Run: `flutter test test/features/lesson/trace_evaluator_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `trace_evaluator.dart`**

```dart
import 'dart:typed_data';

class TraceEvaluationResult {
  TraceEvaluationResult({
    required this.passed,
    required this.insideRatio,
    required this.outsideRatio,
  });
  final bool passed;
  final double insideRatio;
  final double outsideRatio;
}

class TraceEvaluator {
  static const insideThreshold = 0.6;
  static const outsideThreshold = 0.4;

  /// Both masks: row-major bytes, non-zero == filled.
  static TraceEvaluationResult evaluate({
    required Uint8List strokesMask,
    required Uint8List templateMask,
    required int width,
    required int height,
  }) {
    assert(strokesMask.length == width * height);
    assert(templateMask.length == width * height);

    var templatePixels = 0;
    var insidePixels = 0;
    var strokePixels = 0;
    var outsidePixels = 0;

    for (var i = 0; i < strokesMask.length; i++) {
      final t = templateMask[i] > 0;
      final s = strokesMask[i] > 0;
      if (t) templatePixels++;
      if (s) strokePixels++;
      if (t && s) insidePixels++;
      if (!t && s) outsidePixels++;
    }

    final insideRatio = templatePixels == 0 ? 0.0 : insidePixels / templatePixels;
    final outsideRatio = strokePixels == 0 ? 0.0 : outsidePixels / strokePixels;
    final passed = insideRatio >= insideThreshold && outsideRatio <= outsideThreshold;

    return TraceEvaluationResult(
      passed: passed,
      insideRatio: insideRatio,
      outsideRatio: outsideRatio,
    );
  }
}
```

- [ ] **Step 4: Run — confirm passes**

Run: `flutter test test/features/lesson/trace_evaluator_test.dart`
Expected: all PASS.

- [ ] **Step 5: Implement `trace_stage.dart`**

```dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../mascot/mascot_controller.dart';
import 'lesson_runner.dart';
import 'trace_evaluator.dart';

class TraceStageWidget extends ConsumerStatefulWidget {
  const TraceStageWidget({
    super.key,
    required this.stage,
    required this.onResult,
  });
  final TraceStage stage;
  final void Function({required bool correct}) onResult;
  @override
  ConsumerState<TraceStageWidget> createState() => _TraceStageWidgetState();
}

class _TraceStageWidgetState extends ConsumerState<TraceStageWidget> {
  final List<List<Offset>> _strokes = [];
  Timer? _idleTimer;
  ui.Image? _templateImage;
  static const _evalSize = 256;
  int _attempt = 1;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    final letter = ref.read(contentRepositoryProvider).letterById(widget.stage.letterId);
    final data = await rootBundle.load(letter.traceTemplatePath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() => _templateImage = frame.image);
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 2), _finishAttempt);
  }

  Future<void> _finishAttempt() async {
    if (_templateImage == null) return;
    final pass = await _evaluate();
    final mascot = ref.read(mascotProvider.notifier);
    if (pass && _attempt == 1) {
      mascot.cheer();
      widget.onResult(correct: true);
    } else if (!pass && _attempt == 1) {
      mascot.sad();
      setState(() {
        _strokes.clear();
        _attempt = 2;
      });
    } else {
      // attempt 2 — always advance, record correct=false
      if (pass) mascot.cheer(); else mascot.sad();
      widget.onResult(correct: false);
    }
  }

  Future<bool> _evaluate() async {
    final template = await _rasterTemplate();
    final strokes = await _rasterStrokes();
    return TraceEvaluator.evaluate(
      strokesMask: strokes,
      templateMask: template,
      width: _evalSize,
      height: _evalSize,
    ).passed;
  }

  Future<Uint8List> _rasterTemplate() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _evalSize.toDouble(), _evalSize.toDouble()));
    canvas.drawColor(const Color(0xFFFFFFFF), BlendMode.src);
    final paint = Paint()..color = const Color(0xFF000000);
    canvas.drawImageRect(
      _templateImage!,
      Rect.fromLTWH(0, 0, _templateImage!.width.toDouble(), _templateImage!.height.toDouble()),
      Rect.fromLTWH(0, 0, _evalSize.toDouble(), _evalSize.toDouble()),
      paint,
    );
    final pic = recorder.endRecording();
    final img = await pic.toImage(_evalSize, _evalSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return _toMask(byteData!.buffer.asUint8List());
  }

  Future<Uint8List> _rasterStrokes() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _evalSize.toDouble(), _evalSize.toDouble()));
    canvas.drawColor(const Color(0xFFFFFFFF), BlendMode.src);
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final box = context.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(_evalSize.toDouble(), _evalSize.toDouble());
    final scaleX = _evalSize / size.width;
    final scaleY = _evalSize / size.height;
    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx * scaleX, stroke.first.dy * scaleY);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx * scaleX, p.dy * scaleY);
      }
      canvas.drawPath(path, paint);
    }
    final pic = recorder.endRecording();
    final img = await pic.toImage(_evalSize, _evalSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return _toMask(byteData!.buffer.asUint8List());
  }

  /// Convert RGBA → grayscale mask (non-zero if pixel is "dark", i.e. drawn-on).
  Uint8List _toMask(Uint8List rgba) {
    final out = Uint8List(rgba.length ~/ 4);
    for (var i = 0, j = 0; i < rgba.length; i += 4, j++) {
      final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
      final luminance = (r + g + b) ~/ 3;
      out[j] = luminance < 128 ? 255 : 0;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final letter = ref.watch(contentRepositoryProvider).letterById(widget.stage.letterId);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text('Trace the letter', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              onPanStart: (d) {
                setState(() => _strokes.add([d.localPosition]));
                _resetIdleTimer();
              },
              onPanUpdate: (d) {
                setState(() => _strokes.last.add(d.localPosition));
                _resetIdleTimer();
              },
              onPanEnd: (_) => _resetIdleTimer(),
              child: CustomPaint(
                size: Size.infinite,
                painter: _TracePainter(
                  template: _templateImage,
                  cyrillic: letter.cyrillic,
                  strokes: _strokes,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(_strokes.clear),
                icon: const Icon(Icons.refresh),
                label: const Text('Clear'),
              ),
              FilledButton(
                onPressed: _strokes.isEmpty ? null : _finishAttempt,
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.template,
    required this.cyrillic,
    required this.strokes,
  });
  final ui.Image? template;
  final String cyrillic;
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    // Background letter as faded guide. Prefer drawing a giant text glyph
    // so we don't depend on the stub bitmap looking right.
    final tp = TextPainter(
      text: TextSpan(
        text: cyrillic,
        style: TextStyle(
          fontSize: size.height * 0.85,
          color: Colors.brown.withOpacity(0.18),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );

    final paint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) =>
      old.strokes != strokes || old.template != template;
}
```

- [ ] **Step 6: Wire TraceStage in `lesson_runner_screen.dart`**

In the `_stageWidget` method, add a TraceStage branch above the existing returns:

```dart
    if (stage is TraceStage) return TraceStageWidget(stage: stage, onResult: r.advance);
```

Add the import:
```dart
import 'trace_stage.dart';
```

- [ ] **Step 7: Stop skipping trace in production**

In `lib/features/lesson/lesson_runner_screen.dart`, change the provider definition:

```dart
final lessonRunnerProvider = StateNotifierProvider.autoDispose
    .family<LessonRunnerController, LessonRunnerState, Lesson>(
  (ref, lesson) => LessonRunnerController(lesson: lesson, skipTrace: false),
);
```

(The default is now `skipTrace: false` since traces are real.)

- [ ] **Step 8: Run, play Lesson 1, trace the letter**

Run: `flutter run`
Expected:
- After the Intro stage you now see a trace canvas with a faded "А".
- Drag a finger/cursor across it. After 2s idle (or Done tap), evaluation runs.
- Mascot reacts; lesson advances. Tracing crudely usually passes given the lenient thresholds — that's intended.

**Checkpoint:** TraceStage live.

---

# Milestone C — Stickers, Settings, polish

## Task 16: StickerAlbumScreen

**Files:**
- Create: `lib/features/stickers/sticker_album_screen.dart`
- Modify: `lib/core/routing/app_router.dart` (real `/album` route)

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class StickerAlbumScreen extends ConsumerWidget {
  const StickerAlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final progress = ref.watch(progressControllerProvider);
    final stickers = content.stickers.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Sticker Album')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
        ),
        itemCount: stickers.length,
        itemBuilder: (context, i) {
          final s = stickers[i];
          final earned = progress.earnedStickerIds.contains(s.id);
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.brown.shade200, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: earned ? 1.0 : 0.18,
                    child: Image.asset(s.imageAssetPath, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  earned ? s.nameEn : '???',
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Wire route**

In `lib/core/routing/app_router.dart`, replace the placeholder `/album` route:

```dart
      GoRoute(path: '/album', builder: (_, __) => const StickerAlbumScreen()),
```

Add: `import '../../features/stickers/sticker_album_screen.dart';`

- [ ] **Step 3: Run, complete Lesson 1, open Album**

Run: `flutter run`
Expected: Sticker Album shows two sticker slots; after completing Lesson 1, one is filled and named "Father Bear"; the other is a faded silhouette with "???".

**Checkpoint:** Album working.

---

## Task 17: Settings + ParentGate + Reset Progress

**Files:**
- Create: `lib/features/settings/settings_screen.dart`
- Create: `lib/features/settings/parent_gate_screen.dart`
- Modify: `lib/core/routing/app_router.dart` (real `/settings` + `/settings/gate`)
- Modify: `lib/core/audio/audio_service.dart` (none — already supports setVolume)
- Modify: `lib/features/lesson/lesson_runner_screen.dart` (apply volume on each play — already via AudioService)

- [ ] **Step 1: Implement parent gate**

`lib/features/settings/parent_gate_screen.dart`:

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});
  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  late int _a;
  late int _b;
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = Random();
    _a = 4 + r.nextInt(6);
    _b = 4 + r.nextInt(6);
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == _a + _b) {
      context.go('/settings');
    } else {
      setState(() => _error = 'Try again');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adults only')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('What is $_a + $_b?', style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _submit, child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Implement settings screen**

`lib/features/settings/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final progressCtrl = ref.read(progressControllerProvider.notifier);
    final audio = ref.read(audioServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('Volume')),
          Slider(
            value: progress.volume,
            onChanged: (v) async {
              audio.setVolume(v);
              await progressCtrl.update(progress.copyWith(volume: v));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Reset all progress'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset progress?'),
                  content: const Text('Stickers, lesson progress, and SRS history will be erased.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                  ],
                ),
              );
              if (confirm == true) {
                await progressCtrl.reset();
                if (context.mounted) context.go('/steppe');
              }
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Wire routes**

In `lib/core/routing/app_router.dart`, replace the placeholder `/settings/gate` route and add a `/settings` route:

```dart
      GoRoute(path: '/settings/gate', builder: (_, __) => const ParentGateScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
```

Add imports:
```dart
import '../../features/settings/parent_gate_screen.dart';
import '../../features/settings/settings_screen.dart';
```

- [ ] **Step 4: Apply persisted volume at startup**

In `lib/main.dart`, after `final progress = await progressRepo.load();`, prime the audio service volume *after* `ProviderScope` builds. Simplest path: in `BambaruushApp.build`, listen once:

In `lib/app.dart` change `BambaruushApp` to use a `ConsumerStatefulWidget`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/routing/app_router.dart';

class BambaruushApp extends ConsumerStatefulWidget {
  const BambaruushApp({super.key});
  @override
  ConsumerState<BambaruushApp> createState() => _BambaruushAppState();
}

class _BambaruushAppState extends ConsumerState<BambaruushApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progress = ref.read(progressControllerProvider);
      ref.read(audioServiceProvider).setVolume(progress.volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Bambaruush',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC08A4A)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 5: Run, verify**

Run: `flutter run`
Expected:
- Tap settings cog on Steppe → ParentGate (e.g. "What is 7+5?").
- Wrong answer → "Try again". Correct → Settings.
- Move volume slider; relaunch app — slider value persists.
- Tap "Reset all progress" → confirm → back to Steppe with all progress cleared.

**Checkpoint:** Settings done.

---

# Milestone D — Polish (Rive, integration test)

## Task 18: Rive mascot integration

**Files:**
- Modify: `lib/features/mascot/mascot_overlay.dart`
- Asset to drop in: `assets/rive/bambaruush.riv`

**Note:** This task is gated on a real `.riv` file with a state machine named `"BambaruushSM"` and an integer input named `"mood"` (values 0=idle, 1=cheer, 2=sad, 3=point, 4=sleep, 5=wave — matching `MascotMood.index`). Until the rig exists, leave the emoji overlay in place and skip this task.

- [ ] **Step 1: Replace `mascot_overlay.dart` with Rive version**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import '../../models/mascot_mood.dart';
import 'mascot_controller.dart';

class MascotOverlay extends ConsumerStatefulWidget {
  const MascotOverlay({super.key});
  @override
  ConsumerState<MascotOverlay> createState() => _MascotOverlayState();
}

class _MascotOverlayState extends ConsumerState<MascotOverlay> {
  Artboard? _artboard;
  SMINumber? _moodInput;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final file = await RiveFile.asset('assets/rive/bambaruush.riv');
    final artboard = file.mainArtboard;
    final ctrl = StateMachineController.fromArtboard(artboard, 'BambaruushSM');
    if (ctrl != null) {
      artboard.addController(ctrl);
      _moodInput = ctrl.findInput<double>('mood') as SMINumber?;
    }
    setState(() => _artboard = artboard);
  }

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(mascotProvider);
    _moodInput?.value = mood.index.toDouble();
    if (_artboard == null) return const SizedBox.shrink();
    return Positioned(
      right: 8,
      bottom: 16,
      width: 120,
      height: 120,
      child: IgnorePointer(child: Rive(artboard: _artboard!)),
    );
  }
}
```

- [ ] **Step 2: Confirm asset exists**

Run: `ls assets/rive/bambaruush.riv`
Expected: file exists. If not, skip this task — leave the emoji version live.

- [ ] **Step 3: Run, verify**

Run: `flutter run`
Expected: Rive-animated bear appears bottom-right; cheers when a lesson is correct, sad when wrong.

**Checkpoint:** Rive integrated (if rig exists).

---

## Task 19: End-to-end integration test

**Files:**
- Create: `integration_test/first_launch_test.dart`

- [ ] **Step 1: Write the test**

```dart
import 'package:bambaruush/app.dart';
import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/core/persistence/progress_repository.dart';
import 'package:bambaruush/core/providers.dart';
import 'package:bambaruush/models/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first-launch happy path: splash → steppe → finish lesson 1', (tester) async {
    final content = await ContentRepository.loadFromAssets();
    final docsDir = await getApplicationDocumentsDirectory();
    final progressRepo = ProgressRepository(documentsDir: docsDir);
    await progressRepo.reset();
    final progress = await progressRepo.load();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        contentRepositoryProvider.overrideWithValue(content),
        progressRepositoryProvider.overrideWithValue(progressRepo),
        progressControllerProvider.overrideWith(
          (ref) => ProgressController(progressRepo, progress),
        ),
      ],
      child: const BambaruushApp(),
    ));

    // Wait through splash.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Tap "The Yurt"
    expect(find.text('The Yurt'), findsOneWidget);
    await tester.tap(find.text('The Yurt'));
    await tester.pumpAndSettle();

    // Tap lesson 1
    expect(find.text('lesson_01'), findsOneWidget);
    await tester.tap(find.text('lesson_01'));
    await tester.pumpAndSettle();

    // Through stages. Intro: Next.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Trace: clear+done counts as a tap of Done after no strokes — but our UI disables Done with no strokes.
    // For the integration test, we draw a stroke first via a gesture.
    final canvasFinder = find.byType(GestureDetector).first;
    await tester.drag(canvasFinder, const Offset(80, 80));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Listen rounds — tap any tile (target is randomized so we accept that
    // some tests may go to attempt 2; both paths still advance).
    for (var i = 0; i < 4; i++) {
      final tiles = find.byType(InkWell);
      await tester.tap(tiles.first);
      await tester.pumpAndSettle();
      // If we hit attempt 2 due to wrong tap, repeat one more.
      if (find.byType(InkWell).evaluate().length > 1 &&
          find.text('Continue').evaluate().isEmpty) {
        await tester.tap(find.byType(InkWell).first);
        await tester.pumpAndSettle();
      }
    }

    // Reward: tap Continue.
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Back on RegionDetail — lesson_01 should now show a star.
    expect(find.byIcon(Icons.star), findsOneWidget);

    // Sticker should be earned.
    final reloaded = await progressRepo.load();
    expect(reloaded.earnedStickerIds, contains('sticker_father_bear'));
    expect(reloaded.lessons['lesson_01']!.completed, isTrue);
    expect(reloaded.lessons['lesson_02']!.unlocked, isTrue);
  });
}
```

- [ ] **Step 2: Run the integration test**

Run: `flutter test integration_test/first_launch_test.dart`
Expected: PASS. (Note: integration tests must run on a real device or simulator; `flutter test` works for the same file under `integration_test/`.)

**Checkpoint:** End-to-end happy path verified.

---

# Self-Review (already done at write time)

This plan was reviewed against the spec for:
- **Coverage**: every spec section maps to one or more tasks above.
- **Placeholders**: none — every code step is complete code.
- **Type consistency**: model field names match across `ContentRepository`, `LessonRunner`, stages, and `ProgressRepository`. `skipTrace` is the only knob; defaults to `false` in production after Task 15.
- **Scope**: stays within v1 spec. Multi-profile, cloud sync, "Review" screen for SRS-due words are explicitly out of scope.

**Production assets still required** (out of plan scope, tracked separately):
- Native Mongolian speaker recordings (~75 clips) replacing the silent mp3 stubs.
- Word/sticker/region/steppe map illustrations replacing the colored placeholders.
- Real trace-mask bitmaps (right now we render with text; the eval path uses a synthetic mask).
- Real `bambaruush.riv` rig with the `BambaruushSM` state machine and `mood` input (Task 18).
- Final lesson/region content mapping (current `content.json` only has 2 lessons).
