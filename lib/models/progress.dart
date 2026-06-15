import 'package:freezed_annotation/freezed_annotation.dart';

import 'lesson_progress.dart';
import 'srs_box.dart';

part 'progress.freezed.dart';
part 'progress.g.dart';

@freezed
class Progress with _$Progress {
  const factory Progress({
    required Map<String, LessonProgress> lessons,
    required Map<String, SrsBox> srsByItem,
    required Set<String> earnedStickerIds,
    required int schemaVersion,
    required DateTime lastPlayed,
    @Default(1.0) double volume,
    DateTime? lastWarmupAt,
    @Default(0) int warmupCount,
    @Default(<String>[]) List<String> skyStarItemKeys,
    @Default(<String>{}) Set<String> completedConstellationIds,
  }) = _Progress;

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);

  factory Progress.empty({DateTime? now}) => Progress(
        lessons: const {},
        srsByItem: const {},
        earnedStickerIds: const {},
        schemaVersion: 4,
        lastPlayed: now ?? DateTime.now(),
      );
}
