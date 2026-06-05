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

  test('all-correct leaves every item correct (keyed type:id)', () {
    final runner = SessionRunner(sequence: _seq());
    while (runner.state.current is! SessionComplete) {
      runner.advance(correct: true);
    }
    expect(runner.state.itemCorrectness['word:word_aav'], isTrue);
    expect(runner.state.itemCorrectness['word:word_akh'], isTrue);
    expect(runner.state.itemCorrectness['letter:letter_a'], isTrue);
  });

  test('a wrong Trace marks the letter incorrect', () {
    final runner = SessionRunner(sequence: _seq());
    runner.advance(correct: true); // intro
    runner.advance(correct: false); // trace fails
    runner.advance(correct: true); // listen aav
    runner.advance(correct: true); // listen akh
    runner.advance(correct: true); // read aav
    runner.advance(correct: true); // read akh
    runner.advance(correct: true); // reward → complete
    expect(runner.state.current, isA<SessionComplete>());
    expect(runner.state.itemCorrectness['letter:letter_a'], isFalse);
    expect(runner.state.itemCorrectness['word:word_aav'], isTrue);
  });

  test('attempt-1 wrong on Listen retries (same tiles) then records fail', () {
    final runner = SessionRunner(sequence: _seq());
    runner.advance(correct: true); // intro
    runner.advance(correct: true); // trace
    runner.advance(correct: true); // listen aav pass
    runner.advance(correct: false); // listen akh fail attempt 1
    final cur = runner.state.current as ListenSpec;
    expect(cur.wordId, 'word_akh');
    expect(cur.attempt, 2);
    expect(cur.distractorIds, ['word_x', 'word_y']);
    runner.advance(correct: true); // attempt 2 advances; records fail
    expect(runner.state.itemCorrectness['word:word_akh'], isFalse);
  });
}
