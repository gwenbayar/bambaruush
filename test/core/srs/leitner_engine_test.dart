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
    final srs = {'word:word_a': due, 'letter:letter_a': notDue};
    final result = LeitnerEngine.dueItems(srs, now);
    expect(result, contains(due));
    expect(result, isNot(contains(notDue)));
  });
}
