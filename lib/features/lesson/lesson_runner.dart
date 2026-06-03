import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/lesson.dart';

sealed class LessonStage {
  const LessonStage();
}

class IntroStage extends LessonStage {
  const IntroStage(this.letterId);
  final String letterId;
}

class TraceStage extends LessonStage {
  const TraceStage(this.letterId);
  final String letterId;
}

class ListenStage extends LessonStage {
  const ListenStage({required this.wordId, required this.attempt});
  final String wordId;
  final int attempt;
}

class ReadStage extends LessonStage {
  const ReadStage({required this.wordId, required this.attempt});
  final String wordId;
  final int attempt;
}

class RewardStage extends LessonStage {
  const RewardStage(this.stickerId);
  final String stickerId;
}

class LessonComplete extends LessonStage {
  const LessonComplete();
}

class LessonRunnerState {
  LessonRunnerState({
    required this.lesson,
    required this.stage,
    required this.totalSteps,
    required this.currentStep,
    required this.wordCorrectness,
  });

  final Lesson lesson;
  final LessonStage stage;
  final int totalSteps;
  final int currentStep;
  final Map<String, bool> wordCorrectness;

  LessonRunnerState copyWith({
    LessonStage? stage,
    int? currentStep,
    Map<String, bool>? wordCorrectness,
  }) =>
      LessonRunnerState(
        lesson: lesson,
        stage: stage ?? this.stage,
        totalSteps: totalSteps,
        currentStep: currentStep ?? this.currentStep,
        wordCorrectness: wordCorrectness ?? this.wordCorrectness,
      );
}

class LessonRunnerController extends StateNotifier<LessonRunnerState> {
  LessonRunnerController({required Lesson lesson, this.skipTrace = false})
      : _lesson = lesson,
        super(_initial(lesson, skipTrace));

  final bool skipTrace;
  final Lesson _lesson;

  // Per-word first-attempt correctness (true until proven false).
  final Map<String, bool> _firstAttemptCorrect = {};

  static LessonRunnerState _initial(Lesson lesson, bool skipTrace) {
    final stages = _buildSequence(lesson, skipTrace);
    return LessonRunnerState(
      lesson: lesson,
      stage: stages.first,
      totalSteps: stages.length,
      currentStep: 0,
      wordCorrectness: {for (final w in lesson.wordIds) w: true},
    );
  }

  static List<LessonStage> _buildSequence(Lesson lesson, bool skipTrace) {
    final stages = <LessonStage>[];
    for (final letterId in lesson.letterIds) {
      stages.add(IntroStage(letterId));
      if (!skipTrace) stages.add(TraceStage(letterId));
    }
    for (final wid in lesson.wordIds) {
      stages.add(ListenStage(wordId: wid, attempt: 1));
    }
    for (final wid in lesson.wordIds) {
      stages.add(ReadStage(wordId: wid, attempt: 1));
    }
    stages.add(RewardStage(lesson.stickerId));
    return stages;
  }

  List<LessonStage> get _sequence => _buildSequence(_lesson, skipTrace);

  void advance({required bool correct}) {
    final current = state.stage;

    // Handle Listen/Read retry semantics and record first-attempt correctness.
    if (current is ListenStage || current is ReadStage) {
      final wordId = current is ListenStage ? current.wordId : (current as ReadStage).wordId;
      final attempt = current is ListenStage ? current.attempt : (current as ReadStage).attempt;
      if (attempt == 1 && !correct) {
        _firstAttemptCorrect[wordId] = false;
        state = state.copyWith(
          stage: current is ListenStage
              ? ListenStage(wordId: wordId, attempt: 2)
              : ReadStage(wordId: wordId, attempt: 2),
        );
        return;
      }
      if (attempt == 1 && correct) {
        _firstAttemptCorrect[wordId] = _firstAttemptCorrect[wordId] ?? true;
      } else {
        // attempt 2 — first-attempt was already failed
        _firstAttemptCorrect[wordId] = false;
      }
    }

    final nextIndex = state.currentStep + 1;
    final seq = _sequence;
    if (nextIndex >= seq.length) {
      state = state.copyWith(
        stage: const LessonComplete(),
        currentStep: nextIndex,
        wordCorrectness: _computeWordCorrectness(),
      );
      return;
    }
    state = state.copyWith(
      stage: seq[nextIndex],
      currentStep: nextIndex,
      wordCorrectness: _computeWordCorrectness(),
    );
  }

  Map<String, bool> _computeWordCorrectness() => {
        for (final w in _lesson.wordIds)
          w: _firstAttemptCorrect[w] ?? true,
      };
}
