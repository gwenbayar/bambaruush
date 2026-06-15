import 'dart:io';

import 'package:bambaruush/core/persistence/progress_repository.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/lesson_progress.dart';
import 'package:bambaruush/models/progress.dart';
import 'package:bambaruush/models/srs_box.dart';
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
    expect(p.schemaVersion, 4);
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
    await f.writeAsString('{"schemaVersion": 999, "lessons": {}, "srsByItem": {}, '
        '"earnedStickerIds": [], "lastPlayed": "2026-05-27T00:00:00.000Z"}');
    final loaded = await repo.load();
    expect(loaded.schemaVersion, 4);
    expect(loaded.lessons, isEmpty);
  });

  test('srsByItem round-trips a box with its itemType', () async {
    final original = Progress.empty().copyWith(
      srsByItem: {
        'letter:letter_a': SrsBox(
          itemId: 'letter_a',
          itemType: ItemType.letter,
          level: 3,
          nextReviewAt: DateTime.utc(2026, 6, 10),
          correctStreak: 2,
        ),
      },
    );
    await repo.save(original);
    final loaded = await repo.load();
    final box = loaded.srsByItem['letter:letter_a']!;
    expect(box.itemType, ItemType.letter);
    expect(box.level, 3);
  });

  test('round-trips lastWarmupAt and warmupCount', () async {
    final now = DateTime.utc(2026, 6, 5, 9);
    final p = Progress.empty(now: now).copyWith(lastWarmupAt: now, warmupCount: 4);
    await repo.save(p);
    final loaded = await repo.load();
    expect(loaded.lastWarmupAt, now);
    expect(loaded.warmupCount, 4);
    expect(loaded.schemaVersion, 4);
  });

  test('preserves default lastWarmupAt (null) and warmupCount (0)', () async {
    final fresh = Progress.empty(now: DateTime.utc(2026, 6, 5, 9));
    await repo.save(fresh);
    final loaded = await repo.load();
    expect(loaded.lastWarmupAt, isNull);
    expect(loaded.warmupCount, 0);
    expect(loaded.schemaVersion, 4);
  });

  test('round-trips skyStarItemKeys and completedConstellationIds', () async {
    final p = Progress.empty().copyWith(
      skyStarItemKeys: ['word:word_aav', 'letter:letter_a'],
      completedConstellationIds: {'doloon_burhan'},
    );
    await repo.save(p);
    final loaded = await repo.load();
    expect(loaded.skyStarItemKeys, orderedEquals(['word:word_aav', 'letter:letter_a']));
    expect(loaded.completedConstellationIds, unorderedEquals({'doloon_burhan'}));
  });

  test('fresh start defaults sky fields to empty', () async {
    final p = await repo.load();
    expect(p.skyStarItemKeys, isEmpty);
    expect(p.completedConstellationIds, isEmpty);
  });

  test('reset deletes the file', () async {
    await repo.save(Progress.empty());
    await repo.reset();
    expect(File('${tmp.path}/progress.json').existsSync(), isFalse);
  });
}
