import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/features/review/review_queue.dart';
import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/srs_box.dart';
import 'package:flutter_test/flutter_test.dart';

ContentRepository _content() {
  final json = jsonDecode(
    File('test/fixtures/content_valid.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return ContentRepository.fromJson(json);
}

SrsBox _box(String id, ItemType type, DateTime when) =>
    SrsBox(itemId: id, itemType: type, level: 1, nextReviewAt: when, correctStreak: 0);

void main() {
  final content = _content();
  final now = DateTime.utc(2026, 6, 3, 12);

  Map<String, SrsBox> srs() => {
        'word:word_aav': _box('word_aav', ItemType.word, now), // due now
        'word:word_akh': _box('word_akh', ItemType.word, now.subtract(const Duration(days: 2))), // more overdue
        'letter:letter_a': _box('letter_a', ItemType.letter, now.add(const Duration(days: 3))), // not due
        'word:word_ghost': _box('word_ghost', ItemType.word, now), // due but absent from content
      };

  test('dueReviewItems: only due, most-overdue-first, drops unknown ids', () {
    final due = dueReviewItems(srsByItem: srs(), content: content, now: now);
    expect(due.map((i) => i.id).toList(), ['word_akh', 'word_aav']);
    expect(due.map((i) => i.type).toList(), [ItemType.word, ItemType.word]);
  });

  test('freePracticeItems: all resolvable boxes, soonest-due-first, drops unknown', () {
    final pool = freePracticeItems(srsByItem: srs(), content: content);
    expect(pool.map((i) => i.id).toList(), ['word_akh', 'word_aav', 'letter_a']);
  });

  test('empty SRS → empty results', () {
    expect(dueReviewItems(srsByItem: {}, content: content, now: now), isEmpty);
    expect(freePracticeItems(srsByItem: {}, content: content), isEmpty);
  });

  test('dueReviewItems resolves a due letter via the letter branch', () {
    final s = {
      'letter:letter_a': _box('letter_a', ItemType.letter, now), // due
    };
    final due = dueReviewItems(srsByItem: s, content: content, now: now);
    expect(due.single.id, 'letter_a');
    expect(due.single.type, ItemType.letter);
  });
}
