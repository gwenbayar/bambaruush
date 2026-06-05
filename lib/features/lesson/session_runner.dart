import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'activity_spec.dart';

class SessionRunnerState {
  SessionRunnerState({
    required this.current,
    required this.totalSteps,
    required this.currentStep,
    required this.wordCorrectness,
  });

  final ActivitySpec current;
  final int totalSteps;
  final int currentStep;
  final Map<String, bool> wordCorrectness;

  SessionRunnerState copyWith({
    ActivitySpec? current,
    int? currentStep,
    Map<String, bool>? wordCorrectness,
  }) =>
      SessionRunnerState(
        current: current ?? this.current,
        totalSteps: totalSteps,
        currentStep: currentStep ?? this.currentStep,
        wordCorrectness: wordCorrectness ?? this.wordCorrectness,
      );
}

/// Drives a prebuilt [ActivitySpec] sequence (from any Session), with the
/// shared attempt-1 → attempt-2 retry semantics for Listen/Read.
class SessionRunner extends StateNotifier<SessionRunnerState> {
  SessionRunner({required List<ActivitySpec> sequence})
      : _sequence = sequence,
        super(_initialState(sequence)) {
    _wordIds = _wordIdsOf(sequence);
  }

  final List<ActivitySpec> _sequence;
  late final List<String> _wordIds;
  final Map<String, bool> _firstAttemptCorrect = {};

  static SessionRunnerState _initialState(List<ActivitySpec> sequence) {
    final wordIds = _wordIdsOf(sequence);
    return SessionRunnerState(
      current: sequence.first,
      totalSteps: sequence.length,
      currentStep: 0,
      wordCorrectness: {for (final w in wordIds) w: true},
    );
  }

  static List<String> _wordIdsOf(List<ActivitySpec> seq) {
    final ids = <String>[];
    for (final s in seq) {
      final id = s is ListenSpec
          ? s.wordId
          : (s is ReadSpec ? s.wordId : null);
      if (id != null && !ids.contains(id)) ids.add(id);
    }
    return ids;
  }

  void advance({required bool correct}) {
    final cur = state.current;

    if (cur is ListenSpec || cur is ReadSpec) {
      final wordId = cur is ListenSpec ? cur.wordId : (cur as ReadSpec).wordId;
      final attempt = cur is ListenSpec ? cur.attempt : (cur as ReadSpec).attempt;

      if (attempt == 1 && !correct) {
        _firstAttemptCorrect[wordId] = false;
        final retry = cur is ListenSpec
            ? ListenSpec(
                wordId: cur.wordId,
                distractorIds: cur.distractorIds,
                attempt: 2,
              )
            : ReadSpec(
                wordId: (cur as ReadSpec).wordId,
                distractorIds: cur.distractorIds,
                attempt: 2,
              );
        state = state.copyWith(
          current: retry,
          wordCorrectness: _computeCorrectness(),
        );
        return;
      }
      if (attempt == 1 && correct) {
        _firstAttemptCorrect[wordId] = _firstAttemptCorrect[wordId] ?? true;
      } else {
        _firstAttemptCorrect[wordId] = false;
      }
    }

    final nextIndex = state.currentStep + 1;
    if (nextIndex >= _sequence.length) {
      state = state.copyWith(
        current: const SessionComplete(),
        currentStep: nextIndex,
        wordCorrectness: _computeCorrectness(),
      );
      return;
    }
    state = state.copyWith(
      current: _sequence[nextIndex],
      currentStep: nextIndex,
      wordCorrectness: _computeCorrectness(),
    );
  }

  Map<String, bool> _computeCorrectness() => {
        for (final w in _wordIds) w: _firstAttemptCorrect[w] ?? true,
      };
}
