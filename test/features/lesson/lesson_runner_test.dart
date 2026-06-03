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
