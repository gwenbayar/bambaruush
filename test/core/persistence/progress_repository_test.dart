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
