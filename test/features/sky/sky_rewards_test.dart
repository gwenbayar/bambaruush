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

  test('filling the 7th slot completes Doloon Burhan through the orchestrator', () {
    // Guards the pipeline order: completion must use the POST-award star count
    // (stars.updated.length), not the pre-award count. Seed 6 prior stars, then
    // master a 7th item so the Big Dipper's last slot fills.
    final start = Progress.empty(now: DateTime.utc(2026, 6, 1)).copyWith(
      skyStarItemKeys: List.generate(6, (i) => 'word:word_seed_$i'),
      srsByItem: {
        'word:word_aav': SrsBox(
          itemId: 'word_aav',
          itemType: ItemType.word,
          level: 2, // one more correct → level 3 (the 7th star)
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
    expect(r.progress.skyStarItemKeys, hasLength(7));
    expect(r.completedConstellations.map((c) => c.id), ['doloon_burhan']);
    expect(r.progress.completedConstellationIds, contains('doloon_burhan'));
  });
}
