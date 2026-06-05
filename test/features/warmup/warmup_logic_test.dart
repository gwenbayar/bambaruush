import 'package:bambaruush/features/warmup/warmup_logic.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/progress.dart';
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
    test('across year boundary → false', () {
      expect(isSameDay(DateTime(2025, 12, 31, 23), DateTime(2026, 1, 1, 0)), isFalse);
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
          lastWarmupAt: DateTime(2026, 6, 4),
          now: now,
          hasPracticeItems: true,
        ),
        isTrue,
      );
    });
    test('not when already warmed up today', () {
      expect(
        shouldOfferWarmup(
          lastWarmupAt: DateTime(2026, 6, 5, 1),
          now: now,
          hasPracticeItems: true,
        ),
        isFalse,
      );
    });
    test('not when there is nothing to practice', () {
      expect(
        shouldOfferWarmup(
          lastWarmupAt: null,
          now: now,
          hasPracticeItems: false,
        ),
        isFalse,
      );
    });
    test('not when warmup stamp is later same-day (time-of-day ignored)', () {
      expect(
        shouldOfferWarmup(
          lastWarmupAt: DateTime(2026, 6, 5, 23),
          now: now, // 6/5 09:00
          hasPracticeItems: true,
        ),
        isFalse,
      );
    });
  });

  group('applyWarmupCompletion', () {
    test(
        'updates SRS, bumps warmupCount, stamps dates; leaves lessons/stickers',
        () {
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
      expect(next.srsByItem.containsKey('word:word_aav'), isTrue);
      final box = next.srsByItem['word:word_aav']!;
      expect(box.itemId, 'word_aav');
      expect(box.itemType, ItemType.word);
      expect(box.level, 2); // a correct first attempt advanced the box (onCorrect)
    });
  });
}
