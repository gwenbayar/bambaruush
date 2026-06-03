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
