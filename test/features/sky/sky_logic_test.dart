import 'package:bambaruush/features/sky/sky_logic.dart';
import 'package:bambaruush/models/constellation.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter_test/flutter_test.dart';

SrsBox _box(String id, ItemType t, int level) => SrsBox(
      itemId: id,
      itemType: t,
      level: level,
      nextReviewAt: DateTime.utc(2026, 6, 14),
      correctStreak: 0,
    );

void main() {
  group('isMastered', () {
    test('true at the threshold (level 3), false below it', () {
      expect(isMastered(_box('word_aav', ItemType.word, 3)), isTrue);
      expect(isMastered(_box('word_aav', ItemType.word, 2)), isFalse);
    });
  });

  group('awardSkyStars', () {
    test('adds items at level >= 3 (sorted), ignores below threshold', () {
      final r = awardSkyStars(current: const [], srsByItem: {
        'word:word_aav': _box('word_aav', ItemType.word, 3),
        'letter:letter_a': _box('letter_a', ItemType.letter, 4),
        'word:word_eej': _box('word_eej', ItemType.word, 2),
      },);
      expect(r.newlyEarned, ['letter:letter_a', 'word:word_aav']);
      expect(r.updated, ['letter:letter_a', 'word:word_aav']);
    });

    test('does not duplicate an already-earned star', () {
      final r = awardSkyStars(current: const ['word:word_aav'], srsByItem: {
        'word:word_aav': _box('word_aav', ItemType.word, 5),
      },);
      expect(r.newlyEarned, isEmpty);
      expect(r.updated, ['word:word_aav']);
    });

    test('permanence: keeps the star even after the box drops below mastery', () {
      final r = awardSkyStars(current: const ['word:word_aav'], srsByItem: {
        'word:word_aav': _box('word_aav', ItemType.word, 1),
      },);
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
        starCount: 7,
        all: [dipper],
        alreadyCompleted: const {},
      );
      expect(r.map((c) => c.id), ['doloon_burhan']);
    });
    test('does not fire before the slot count', () {
      expect(
        newlyCompletedConstellations(
          starCount: 6,
          all: [dipper],
          alreadyCompleted: const {},
        ),
        isEmpty,
      );
    });
    test('does not re-fire when already completed', () {
      expect(
        newlyCompletedConstellations(
          starCount: 8,
          all: [dipper],
          alreadyCompleted: const {'doloon_burhan'},
        ),
        isEmpty,
      );
    });
  });
}
