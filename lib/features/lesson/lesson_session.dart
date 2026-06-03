import '../../core/content/content_repository.dart';
import '../../models/lesson.dart';
import 'activity_spec.dart';
import 'distractors.dart';

/// Builds the ordered activity sequence for a [Lesson], honoring its kind, with
/// distractors precomputed so the game widgets stay content-source agnostic.
class LessonSession {
  LessonSession({required this.lesson, required this.content, this.seed});

  final Lesson lesson;
  final ContentRepository content;

  /// Optional seed for deterministic distractor selection in tests.
  final int? seed;

  List<ActivitySpec> buildSequence() {
    final stages = <ActivitySpec>[];

    if (lesson.kind == LessonKind.letter) {
      for (final letterId in lesson.letterIds) {
        stages.add(IntroSpec(letterId));
        stages.add(TraceSpec(letterId: letterId, attempt: 1));
      }
    }

    final wordToRegion = <String, String>{
      for (final l in content.lessons)
        for (final wid in l.wordIds) wid: l.regionId,
    };
    final allWords = content.words.values.toList();

    List<String> distractors(String wid, String tag) => pickDistractors(
          targetWordId: wid,
          lesson: lesson,
          allWords: allWords,
          wordIdToRegionId: wordToRegion,
          n: 2,
          seed: seed == null ? null : Object.hash(seed, tag, wid),
        );

    for (final wid in lesson.wordIds) {
      stages.add(
        ListenSpec(
          wordId: wid,
          attempt: 1,
          distractorIds: distractors(wid, 'listen'),
        ),
      );
    }
    for (final wid in lesson.wordIds) {
      stages.add(
        ReadSpec(
          wordId: wid,
          attempt: 1,
          distractorIds: distractors(wid, 'read'),
        ),
      );
    }
    stages.add(RewardSpec(lesson.stickerId));
    return stages;
  }
}
