import 'package:bambaruush/features/lesson/activity_spec.dart';
import 'package:bambaruush/features/lesson/session_runner.dart';
import 'package:flutter_test/flutter_test.dart';

List<ActivitySpec> _seq() => const [
      IntroSpec('letter_a'),
      TraceSpec(letterId: 'letter_a', attempt: 1),
      ListenSpec(wordId: 'word_aav', distractorIds: ['word_x', 'word_y'], attempt: 1),
      ListenSpec(wordId: 'word_akh', distractorIds: ['word_x', 'word_y'], attempt: 1),
      ReadSpec(wordId: 'word_aav', distractorIds: ['word_x', 'word_y'], attempt: 1),
      ReadSpec(wordId: 'word_akh', distractorIds: ['word_x', 'word_y'], attempt: 1),
      RewardSpec('sticker_x'),
    ];

void main() {
  test('drives the sequence in order, then SessionComplete', () {
    final runner = SessionRunner(sequence: _seq());
    final seen = <Type>[];
    while (runner.state.current is! SessionComplete) {
      seen.add(runner.state.current.runtimeType);
      runner.advance(correct: true);
    }
    expect(seen, [
      IntroSpec, TraceSpec, ListenSpec, ListenSpec, ReadSpec, ReadSpec, RewardSpec,
    ]);
  });

  test('all-correct leaves every wordCorrectness true', () {
    final runner = SessionRunner(sequence: _seq());
    while (runner.state.current is! SessionComplete) {
      runner.advance(correct: true);
    }
    expect(runner.state.wordCorrectness['word_aav'], isTrue);
    expect(runner.state.wordCorrectness['word_akh'], isTrue);
  });

  test('attempt-1 wrong on Listen retries (attempt 2, same tiles) then records fail', () {
    final runner = SessionRunner(sequence: _seq());
    runner.advance(correct: true); // intro
    runner.advance(correct: true); // trace
    runner.advance(correct: true); // listen word_aav (pass)
    runner.advance(correct: false); // listen word_akh fail attempt 1
    final cur = runner.state.current as ListenSpec;
    expect(cur.wordId, 'word_akh');
    expect(cur.attempt, 2);
    expect(cur.distractorIds, ['word_x', 'word_y']);
    runner.advance(correct: true); // attempt 2 advances; records fail
    expect(runner.state.current, isA<ReadSpec>());
    runner.advance(correct: true); // read word_aav
    runner.advance(correct: true); // read word_akh
    expect(runner.state.wordCorrectness['word_aav'], isTrue);
    expect(runner.state.wordCorrectness['word_akh'], isFalse);
  });

  test('attempt-1 wrong on Read retries then records fail (Read branch)', () {
    final runner = SessionRunner(sequence: _seq());
    runner.advance(correct: true); // intro
    runner.advance(correct: true); // trace
    runner.advance(correct: true); // listen word_aav
    runner.advance(correct: true); // listen word_akh
    runner.advance(correct: true); // read word_aav
    // now on read word_akh attempt 1
    runner.advance(correct: false); // fail attempt 1
    final cur = runner.state.current as ReadSpec;
    expect(cur.wordId, 'word_akh');
    expect(cur.attempt, 2);
    expect(cur.distractorIds, ['word_x', 'word_y']);
    runner.advance(correct: true); // attempt 2 advances; records fail -> reward
    runner.advance(correct: true); // reward -> SessionComplete
    expect(runner.state.current, isA<SessionComplete>());
    expect(runner.state.wordCorrectness['word_akh'], isFalse);
    expect(runner.state.wordCorrectness['word_aav'], isTrue);
  });

  test('retry does not advance the progress step', () {
    final runner = SessionRunner(sequence: _seq());
    runner.advance(correct: true); // intro -> step 1
    runner.advance(correct: true); // trace -> step 2
    final stepBefore = runner.state.currentStep;
    runner.advance(correct: false); // listen word_aav wrong: retry, step unchanged
    expect(runner.state.currentStep, stepBefore);
    expect(runner.state.current, isA<ListenSpec>());
  });
}
