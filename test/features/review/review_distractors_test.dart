import 'package:bambaruush/features/review/review_distractors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const all = ['word_aav', 'word_akh', 'word_baavgai', 'word_bombog'];

  test('prefers the learned pool, excludes the target, returns n', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: all,
      allWordIds: all,
      n: 2,
      seed: 1,
    );
    expect(picks, hasLength(2));
    expect(picks, isNot(contains('word_aav')));
    expect(picks.toSet().length, 2); // no duplicates
    expect(all.toSet().containsAll(picks), isTrue);
  });

  test('falls back to allWordIds when the learned pool is too small', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: ['word_aav'], // only the target is "learned"
      allWordIds: all,
      n: 2,
      seed: 1,
    );
    expect(picks, hasLength(2));
    expect(picks, isNot(contains('word_aav')));
  });

  test('same seed is deterministic', () {
    List<String> run() => pickReviewDistractors(
          targetWordId: 'word_aav',
          learnedWordIds: all,
          allWordIds: all,
          n: 2,
          seed: 42,
        );
    expect(run(), run());
  });

  test('never returns the target even when it is the only candidate', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: ['word_aav'],
      allWordIds: ['word_aav'],
      n: 2,
      seed: 1,
    );
    expect(picks, isNot(contains('word_aav')));
  });

  test('returns fewer than n when content is too small', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: ['word_aav', 'word_akh'],
      allWordIds: ['word_aav', 'word_akh'],
      n: 4,
      seed: 1,
    );
    expect(picks, ['word_akh']); // only one non-target candidate
  });

  test('de-duplicates repeated ids in the input pools', () {
    final picks = pickReviewDistractors(
      targetWordId: 'word_aav',
      learnedWordIds: ['word_akh', 'word_akh', 'word_baavgai'],
      allWordIds: all,
      n: 2,
      seed: 1,
    );
    expect(picks.toSet().length, picks.length); // no duplicates
    expect(picks, isNot(contains('word_aav')));
  });
}
