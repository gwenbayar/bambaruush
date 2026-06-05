import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/item.dart';
import 'activity_spec.dart';

class SessionRunnerState {
  SessionRunnerState({
    required this.current,
    required this.totalSteps,
    required this.currentStep,
    required this.itemCorrectness,
  });

  final ActivitySpec current;
  final int totalSteps;
  final int currentStep;

  /// First-attempt correctness per item, keyed "type:id" (e.g. "word:word_aav",
  /// "letter:letter_a"). Words come from Listen/Read; letters from Trace.
  final Map<String, bool> itemCorrectness;

  SessionRunnerState copyWith({
    ActivitySpec? current,
    int? currentStep,
    Map<String, bool>? itemCorrectness,
  }) =>
      SessionRunnerState(
        current: current ?? this.current,
        totalSteps: totalSteps,
        currentStep: currentStep ?? this.currentStep,
        itemCorrectness: itemCorrectness ?? this.itemCorrectness,
      );
}

/// Drives a prebuilt [ActivitySpec] sequence, tracking first-attempt correctness
/// per item. Listen/Read use the attempt-1 → attempt-2 retry; Trace reports its
/// final first-attempt result once (the widget self-manages its retry).
class SessionRunner extends StateNotifier<SessionRunnerState> {
  SessionRunner({required List<ActivitySpec> sequence})
      : _sequence = sequence,
        super(_initialState(sequence)) {
    _itemKeys = _itemKeysOf(sequence);
  }

  final List<ActivitySpec> _sequence;
  late final List<String> _itemKeys;
  final Map<String, bool> _firstAttemptCorrect = {};

  static SessionRunnerState _initialState(List<ActivitySpec> sequence) {
    final keys = _itemKeysOf(sequence);
    return SessionRunnerState(
      current: sequence.first,
      totalSteps: sequence.length,
      currentStep: 0,
      itemCorrectness: {for (final k in keys) k: true},
    );
  }

  static List<String> _itemKeysOf(List<ActivitySpec> seq) {
    final keys = <String>[];
    void add(String k) {
      if (!keys.contains(k)) keys.add(k);
    }
    for (final s in seq) {
      if (s is ListenSpec) add(itemKeyOf(ItemType.word, s.wordId));
      if (s is ReadSpec) add(itemKeyOf(ItemType.word, s.wordId));
      if (s is TraceSpec) add(itemKeyOf(ItemType.letter, s.letterId));
    }
    return keys;
  }

  void advance({required bool correct}) {
    final cur = state.current;

    if (cur is ListenSpec || cur is ReadSpec) {
      final wordId = cur is ListenSpec ? cur.wordId : (cur as ReadSpec).wordId;
      final attempt = cur is ListenSpec ? cur.attempt : (cur as ReadSpec).attempt;
      final key = itemKeyOf(ItemType.word, wordId);

      if (attempt == 1 && !correct) {
        _firstAttemptCorrect[key] = false;
        final retry = cur is ListenSpec
            ? ListenSpec(wordId: cur.wordId, distractorIds: cur.distractorIds, attempt: 2)
            : ReadSpec(
                wordId: (cur as ReadSpec).wordId,
                distractorIds: cur.distractorIds,
                attempt: 2,
              );
        state = state.copyWith(current: retry, itemCorrectness: _compute());
        return;
      }
      if (attempt == 1 && correct) {
        _firstAttemptCorrect[key] = _firstAttemptCorrect[key] ?? true;
      } else {
        _firstAttemptCorrect[key] = false;
      }
    } else if (cur is TraceSpec) {
      // Trace reports its final first-attempt result once; record a miss.
      if (!correct) {
        _firstAttemptCorrect[itemKeyOf(ItemType.letter, cur.letterId)] = false;
      }
    }

    final nextIndex = state.currentStep + 1;
    if (nextIndex >= _sequence.length) {
      state = state.copyWith(
        current: const SessionComplete(),
        currentStep: nextIndex,
        itemCorrectness: _compute(),
      );
      return;
    }
    state = state.copyWith(
      current: _sequence[nextIndex],
      currentStep: nextIndex,
      itemCorrectness: _compute(),
    );
  }

  Map<String, bool> _compute() => {
        for (final k in _itemKeys) k: _firstAttemptCorrect[k] ?? true,
      };
}
