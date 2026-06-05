import 'package:flutter/material.dart';

import 'activity_spec.dart';
import 'intro_activity.dart';
import 'listen_activity.dart';
import 'read_activity.dart';
import 'review_complete_activity.dart';
import 'reward_activity.dart';
import 'session_runner.dart';
import 'trace_activity.dart';

/// Renders any [ActivitySpec] to its game/celebration widget, wiring results
/// back to [runner]. Shared by the lesson and review runner screens — the single
/// place that knows spec→widget, so adding an activity never drifts.
class ActivityView extends StatelessWidget {
  const ActivityView({super.key, required this.spec, required this.runner});

  final ActivitySpec spec;
  final SessionRunner runner;

  @override
  Widget build(BuildContext context) => switch (spec) {
        IntroSpec s => IntroActivityView(
            spec: s,
            onContinue: () => runner.advance(correct: true),
          ),
        TraceSpec s => TraceActivityView(spec: s, onResult: runner.advance),
        ListenSpec s => ListenActivityView(
            key: ValueKey('listen-${s.wordId}-${s.attempt}'),
            spec: s,
            onResult: runner.advance,
          ),
        ReadSpec s => ReadActivityView(
            key: ValueKey('read-${s.wordId}-${s.attempt}'),
            spec: s,
            onResult: runner.advance,
          ),
        RewardSpec s => RewardActivityView(
            spec: s,
            onContinue: () => runner.advance(correct: true),
          ),
        ReviewCompleteSpec s => ReviewCompleteActivityView(
            spec: s,
            onContinue: () => runner.advance(correct: true),
          ),
        SessionComplete() => const SizedBox.shrink(),
      };
}
