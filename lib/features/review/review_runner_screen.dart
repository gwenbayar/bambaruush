import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../models/item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';
import '../lesson/activity_spec.dart';
import '../lesson/activity_view.dart';
import '../lesson/session_runner.dart';
import '../mascot/mascot_overlay.dart';
import '../sky/sky_logic.dart';
import '../sky/sky_reward_overlay.dart';
import 'review_queue.dart';
import 'review_session.dart';

enum ReviewMode { due, free, warmup }

/// Fresh runner per entry, keyed by mode. Reads the item list once at creation
/// (ref.read, not watch) so the session is fixed for its duration.
final reviewRunnerProvider = StateNotifierProvider.autoDispose
    .family<SessionRunner, SessionRunnerState, ReviewMode>((ref, mode) {
  final content = ref.watch(contentRepositoryProvider);
  final srs = ref.read(progressControllerProvider).srsByItem;
  final learnedWordIds = <String>[
    for (final b in srs.values)
      if (b.itemType == ItemType.word) b.itemId,
  ];
  final due = ref.read(reviewQueueProvider);
  final free = ref.read(freePracticeProvider);
  // Warm-up reviews due items if any, else free-practice. due/free modes are
  // unchanged. (.due and .free build identically; the factory name documents
  // which pool the items came from.)
  final useDue =
      mode == ReviewMode.due || (mode == ReviewMode.warmup && due.isNotEmpty);
  final items = useDue ? due : free;
  final session = useDue
      ? ReviewSession.due(
          items: items,
          content: content,
          learnedWordIds: learnedWordIds,
        )
      : ReviewSession.free(
          items: items,
          content: content,
          learnedWordIds: learnedWordIds,
        );
  return SessionRunner(sequence: session.buildSequence());
});

class ReviewRunnerScreen extends ConsumerStatefulWidget {
  const ReviewRunnerScreen({super.key, this.warmup = false});

  /// When true, this is the daily warm-up: always run (no gate), persist via
  /// _persistWarmup, and exit with go('/steppe') instead of pop.
  final bool warmup;

  @override
  ConsumerState<ReviewRunnerScreen> createState() => _ReviewRunnerScreenState();
}

class _ReviewRunnerScreenState extends ConsumerState<ReviewRunnerScreen> {
  // Locked at entry so a post-session progress change can't flip us back to the
  // gate before we exit.
  ReviewMode? _mode;

  @override
  void initState() {
    super.initState();
    if (widget.warmup) {
      final hasItems = ref.read(reviewQueueProvider).isNotEmpty ||
          ref.read(freePracticeProvider).isNotEmpty;
      if (hasItems) {
        _mode = ReviewMode.warmup;
      } else {
        // Defensive: reached warm-up with nothing to practice (normally
        // prevented by the splash check). Bounce to the map.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/steppe');
        });
      }
    } else if (ref.read(reviewQueueProvider).isNotEmpty) {
      _mode = ReviewMode.due;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    if (mode != null) return _RunningView(mode: mode);
    if (widget.warmup) return const SizedBox.shrink(); // redirecting to /steppe
    return _CaughtUpView(
      canPractice: ref.watch(freePracticeProvider).isNotEmpty,
      onPractice: () => setState(() => _mode = ReviewMode.free),
      onBack: () => context.pop(),
    );
  }
}

class _RunningView extends ConsumerWidget {
  const _RunningView({required this.mode});
  final ReviewMode mode;

  bool get _isWarmup => mode == ReviewMode.warmup;

  // Warm-up is entered via go (splash → /warmup → /review?warmup=1), so it exits
  // to the map; due/free are pushed from the landmark, so they pop.
  void _exit(BuildContext context) {
    if (_isWarmup) {
      context.go('/steppe');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewRunnerProvider(mode));
    final runner = ref.read(reviewRunnerProvider(mode).notifier);

    ref.listen<SessionRunnerState>(reviewRunnerProvider(mode), (prev, next) async {
      if (next.current is SessionComplete && prev?.current is! SessionComplete) {
        final rewards = await _persist(ref, next, isWarmup: _isWarmup);
        if (context.mounted) {
          await showSkyRewards(
            context,
            newStarCount: rewards.newStarKeys.length,
            completedConstellations: rewards.completedConstellations,
          );
        }
        if (context.mounted) _exit(context);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmQuit(context) && context.mounted) _exit(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isWarmup ? 'Warm-up' : 'Practice'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmQuit(context) && context.mounted) _exit(context);
            },
          ),
        ),
        body: Stack(
          children: [
            ActivityView(spec: state.current, runner: runner),
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: LinearProgressIndicator(
                value: state.totalSteps == 0
                    ? 0
                    : state.currentStep / state.totalSteps,
              ),
            ),
            const MascotOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Persist a finished review (or warm-up) through the shared sky-reward
/// orchestrator. Warm-up additionally bumps warmupCount + stamps lastWarmupAt.
Future<SessionRewards> _persist(
  WidgetRef ref,
  SessionRunnerState s, {
  bool isWarmup = false,
}) async {
  final progress = ref.read(progressControllerProvider);
  final content = ref.read(contentRepositoryProvider);
  final rewards = applySessionRewards(
    current: progress,
    itemCorrectness: s.itemCorrectness,
    now: DateTime.now(),
    content: content,
    isWarmup: isWarmup,
  );
  await ref.read(progressControllerProvider.notifier).update(rewards.progress);
  return rewards;
}

Future<bool> _confirmQuit(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Stop practice?'),
      content: const Text('Your practice progress will not be saved.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Keep playing'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Stop'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _CaughtUpView extends StatelessWidget {
  const _CaughtUpView({
    required this.canPractice,
    required this.onPractice,
    required this.onBack,
  });
  final bool canPractice;
  final VoidCallback onPractice;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nothing needs review right now.',
              style: TextStyle(fontSize: 16, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 28),
            if (canPractice) ...[
              CandyButton(
                label: 'Practice anyway',
                icon: Icons.bolt_rounded,
                onPressed: onPractice,
                color: AppColors.meadow,
              ),
              const SizedBox(height: 12),
            ],
            CandyButton(
              label: 'Back to map',
              icon: Icons.map_rounded,
              onPressed: onBack,
              color: AppColors.sky,
            ),
          ],
        ),
      ),
    );
  }
}
