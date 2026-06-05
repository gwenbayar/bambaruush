import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/features/lesson/activity_spec.dart';
import 'package:bambaruush/features/lesson/session_runner.dart';
import 'package:bambaruush/features/review/review_session.dart';
import 'package:bambaruush/models/item.dart';
import 'package:flutter_test/flutter_test.dart';

ContentRepository _content() {
  final json = jsonDecode(
    File('test/fixtures/content_valid.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return ContentRepository.fromJson(json);
}

void main() {
  final content = _content();
  final aav = content.wordById('word_aav');   // ItemType.word
  final letterA = content.letterById('letter_a'); // ItemType.letter
  const learned = ['word_aav', 'word_akh', 'word_baavgai', 'word_bombog'];

  group('pickActivityForItem', () {
    test('letter → always trace, any seed', () {
      for (var s = 0; s < 6; s++) {
        expect(pickActivityForItem(letterA, seed: s), ReviewActivityKind.trace);
      }
    });

    test('word → even seed Listen, odd seed Read (deterministic)', () {
      expect(pickActivityForItem(aav, seed: 0), ReviewActivityKind.listen);
      expect(pickActivityForItem(aav, seed: 2), ReviewActivityKind.listen);
      expect(pickActivityForItem(aav, seed: 1), ReviewActivityKind.read);
      expect(pickActivityForItem(aav, seed: 3), ReviewActivityKind.read);
    });
  });

  group('ReviewSession.buildSequence', () {
    List<Item> items() => [aav, letterA, content.wordById('word_akh')];

    test('one graded spec per item + a trailing ReviewCompleteSpec', () {
      final seq = ReviewSession.due(
        items: items(), content: content, learnedWordIds: learned, seed: 7,
      ).buildSequence();

      expect(seq.last, isA<ReviewCompleteSpec>());
      expect((seq.last as ReviewCompleteSpec).reviewedCount, 3);
      expect(seq.length, 4); // 3 graded + 1 complete

      expect(seq.whereType<TraceSpec>().map((s) => s.letterId), ['letter_a']);
      final wordSpecs = seq.where((s) => s is ListenSpec || s is ReadSpec).toList();
      expect(wordSpecs, hasLength(2));
    });

    test('word specs carry 2 distractors that are not the target', () {
      final seq = ReviewSession.due(
        items: [aav], content: content, learnedWordIds: learned, seed: 4,
      ).buildSequence();
      final wordSpec = seq.firstWhere((s) => s is ListenSpec || s is ReadSpec);
      final distractors = wordSpec is ListenSpec
          ? wordSpec.distractorIds
          : (wordSpec as ReadSpec).distractorIds;
      expect(distractors, hasLength(2));
      expect(distractors, isNot(contains('word_aav')));
    });

    test('caps the session at 8 graded items', () {
      final many = List<Item>.generate(12, (_) => aav);
      final seq = ReviewSession.due(
        items: many, content: content, learnedWordIds: learned, seed: 1,
      ).buildSequence();
      expect(seq.whereType<ReviewCompleteSpec>(), hasLength(1));
      expect((seq.last as ReviewCompleteSpec).reviewedCount, 8);
      expect(seq.length, 9); // 8 graded + 1 complete
    });

    test('same seed yields an identical sequence', () {
      List<String> shape() => ReviewSession.due(
            items: items(), content: content, learnedWordIds: learned, seed: 9,
          ).buildSequence().map((s) {
            if (s is ListenSpec) return 'listen:${s.wordId}:${s.distractorIds.join(",")}';
            if (s is ReadSpec) return 'read:${s.wordId}:${s.distractorIds.join(",")}';
            if (s is TraceSpec) return 'trace:${s.letterId}';
            if (s is ReviewCompleteSpec) return 'done:${s.reviewedCount}';
            return s.runtimeType.toString();
          }).toList();
      expect(shape(), shape());
    });

    test('SessionRunner drives a review sequence to completion', () {
      final seq = ReviewSession.due(
        items: [aav], content: content, learnedWordIds: learned, seed: 0,
      ).buildSequence(); // [one graded word spec (Listen|Read), ReviewCompleteSpec]
      final runner = SessionRunner(sequence: seq);
      while (runner.state.current is! SessionComplete) {
        runner.advance(correct: true);
      }
      expect(runner.state.itemCorrectness['word:word_aav'], isTrue);
      expect(runner.state.itemCorrectness.keys, ['word:word_aav']);
    });

    test('graded specs preserve input order', () {
      final seq = ReviewSession.due(
        items: items(), content: content, learnedWordIds: learned, seed: 7,
      ).buildSequence();
      final ids = seq.take(3).map((s) => switch (s) {
        ListenSpec s => s.wordId,
        ReadSpec s => s.wordId,
        TraceSpec s => s.letterId,
        _ => 'x',
      },).toList();
      expect(ids, ['word_aav', 'letter_a', 'word_akh']);
    });

    test('letter items produce a TraceSpec and no distractors', () {
      final seq = ReviewSession.due(
        items: [letterA], content: content, learnedWordIds: learned, seed: 1,
      ).buildSequence();
      expect(seq.first, isA<TraceSpec>());
      expect((seq.first as TraceSpec).letterId, 'letter_a');
      expect(seq.whereType<ListenSpec>(), isEmpty);
      expect(seq.whereType<ReadSpec>(), isEmpty);
    });

    test('empty items → just a ReviewCompleteSpec with reviewedCount 0', () {
      final seq = ReviewSession.due(
        items: const [], content: content, learnedWordIds: learned, seed: 1,
      ).buildSequence();
      expect(seq, hasLength(1));
      expect(seq.single, isA<ReviewCompleteSpec>());
      expect((seq.single as ReviewCompleteSpec).reviewedCount, 0);
    });
  });
}
