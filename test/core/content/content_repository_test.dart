import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _loadFixture(String name) {
  final file = File('test/fixtures/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('ContentRepository.fromJson', () {
    test('parses a valid content fixture', () {
      final repo = ContentRepository.fromJson(_loadFixture('content_valid.json'));
      expect(repo.lessons, hasLength(2));
      expect(repo.letterById('letter_a').cyrillic, 'А');
      expect(repo.wordById('word_aav').text('en'), 'father');
      expect(repo.lessonByOrder(1).id, 'lesson_01');
    });

    test('throws on dangling sticker reference', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_dangling_ref.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });

    test('throws on duplicate letter id', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_duplicate_id.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });

    test('throws on dangling word → letter reference', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_dangling_word_letter.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });

    test('throws when a word is missing a required localization', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_word_missing_lang.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });

    test('throws on dangling lesson → region reference', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_dangling_lesson_region.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });

    test('throws on non-contiguous lesson order', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_non_contiguous_order.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });

    test('lessonsInRegion returns only that region, sorted by order', () {
      final repo = ContentRepository.fromJson(_loadFixture('content_valid.json'));
      final lessons = repo.lessonsInRegion('region_yurt');
      expect(lessons.map((l) => l.id), ['lesson_01', 'lesson_02']);
    });
  });
}
