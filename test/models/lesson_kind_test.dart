import 'package:bambaruush/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _base() => {
      'id': 'lesson_x',
      'order': 1,
      'regionId': 'r1',
      'letterIds': <String>[],
      'wordIds': <String>['word_a'],
      'stickerId': 's1',
    };

void main() {
  test('kind defaults to letter when absent from JSON', () {
    final lesson = Lesson.fromJson(_base());
    expect(lesson.kind, LessonKind.letter);
  });

  test('kind parses "vocabulary"', () {
    final lesson = Lesson.fromJson({..._base(), 'kind': 'vocabulary'});
    expect(lesson.kind, LessonKind.vocabulary);
  });

  test('kind parses "letter"', () {
    final lesson = Lesson.fromJson({..._base(), 'kind': 'letter'});
    expect(lesson.kind, LessonKind.letter);
  });
}
