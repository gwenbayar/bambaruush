import 'package:bambaruush/features/lesson/distractors.dart';
import 'package:bambaruush/models/lesson.dart';
import 'package:bambaruush/models/word.dart';
import 'package:bambaruush/models/word_localization.dart';
import 'package:flutter_test/flutter_test.dart';

Word _w(String id, [List<String> letters = const []]) => Word(
  id: id, imageAssetPath: '',
  letterIds: letters,
  localizations: {
    'mn': WordLocalization(text: id, audioAssetPath: ''),
    'en': WordLocalization(text: id),
  },
);

Lesson _lesson(String id, String regionId, List<String> wordIds) => Lesson(
  id: id, order: 1, regionId: regionId,
  letterIds: const [], wordIds: wordIds, stickerId: 's',
);

void main() {
  final allWords = [_w('a'), _w('b'), _w('c'), _w('d'), _w('e')];
  final lessonInRegion = _lesson('l1', 'r1', ['a', 'b', 'c']);
  final wordToRegion = {'a': 'r1', 'b': 'r1', 'c': 'r1', 'd': 'r2', 'e': 'r2'};

  test('returns 2 distractors from same region when available', () {
    final result = pickDistractors(
      targetWordId: 'a',
      lesson: lessonInRegion,
      allWords: allWords,
      wordIdToRegionId: wordToRegion,
      n: 2,
      seed: 42,
    );
    expect(result.length, 2);
    expect(result.contains('a'), isFalse);
    expect(result.every((id) => ['b', 'c'].contains(id)), isTrue);
  });

  test('falls back across regions when same-region pool is short', () {
    final lessonAlone = _lesson('l1', 'r1', ['a']);
    final wordRegion = {'a': 'r1', 'd': 'r2', 'e': 'r2'};
    final result = pickDistractors(
      targetWordId: 'a',
      lesson: lessonAlone,
      allWords: [_w('a'), _w('d'), _w('e')],
      wordIdToRegionId: wordRegion,
      n: 2,
      seed: 42,
    );
    expect(result.length, 2);
    expect(result.contains('a'), isFalse);
    expect(result.toSet(), {'d', 'e'});
  });

  test('deterministic for same seed', () {
    final a = pickDistractors(
      targetWordId: 'a', lesson: lessonInRegion, allWords: allWords,
      wordIdToRegionId: wordToRegion, n: 2, seed: 7,
    );
    final b = pickDistractors(
      targetWordId: 'a', lesson: lessonInRegion, allWords: allWords,
      wordIdToRegionId: wordToRegion, n: 2, seed: 7,
    );
    expect(a, b);
  });
}
