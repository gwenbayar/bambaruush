import 'package:bambaruush/features/lesson/srs_update.dart';
import 'package:bambaruush/models/item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 6, 3, 12);

  test('creates boxes for words AND letters from itemCorrectness', () {
    final srs = applySessionToSrs(
      current: const {},
      itemCorrectness: const {'word:word_aav': true, 'letter:letter_a': false},
      now: now,
    );
    expect(srs['word:word_aav']!.level, 2); // correct → promoted
    expect(srs['word:word_aav']!.itemType, ItemType.word);
    expect(srs['word:word_aav']!.itemId, 'word_aav');
    expect(srs['letter:letter_a']!.level, 1); // missed → level 1
    expect(srs['letter:letter_a']!.itemType, ItemType.letter);
    expect(srs['letter:letter_a']!.itemId, 'letter_a');
  });

  test('only items present in itemCorrectness get boxes', () {
    final srs = applySessionToSrs(
      current: const {},
      itemCorrectness: const {'word:word_aav': true},
      now: now,
    );
    expect(srs.keys, ['word:word_aav']);
  });

  test('promotes an existing box on a correct answer', () {
    final base = applySessionToSrs(
      current: const {},
      itemCorrectness: const {'word:word_x': true},
      now: now,
    );
    final again = applySessionToSrs(
      current: base,
      itemCorrectness: const {'word:word_x': true},
      now: now,
    );
    expect(again['word:word_x']!.level, 3);
  });
}
