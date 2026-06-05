import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

/// How a lesson plays. `letter` lessons teach a letter (Intro + Trace) before
/// their words; `vocabulary` lessons teach words only (no letter steps).
enum LessonKind { vocabulary, letter }

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required int order,
    String? title,
    @Default(LessonKind.letter) LessonKind kind,
    required String regionId,
    required List<String> letterIds,
    required List<String> wordIds,
    required String stickerId,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}
