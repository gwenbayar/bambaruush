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
import '../lesson/srs_update.dart';
import '../mascot/mascot_overlay.dart';
import 'review_queue.dart';
import 'review_session.dart';

enum ReviewMode { due, free }

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
  final items = mode == ReviewMode.due
      ? ref.read(reviewQueueProvider)
      : ref.read(freePracticeProvider);
  final session = mode == ReviewMode.due
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
  const ReviewRunnerScreen({super.key});

  @override
  ConsumerState<ReviewRunnerScreen> createState() => _ReviewRunnerScreenState();
}

class _ReviewRunnerScreenState extends ConsumerState<ReviewRunnerScreen> {
  // Locked at entry so a post-session progress change can't flip us back to the
  // gate before we pop.
  ReviewMode? _mode;

  @override
  void initState() {
    super.initState();
    if (ref.read(reviewQueueProvider).isNotEmpty) {
      _mode = ReviewMode.due;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    if (mode == null) {
      return _CaughtUpView(
        canPractice: ref.watch(freePracticeProvider).isNotEmpty,
        onPractice: () => setState(() => _mode = ReviewMode.free),
        onBack: () => context.pop(),
      );
    }
    return _RunningView(mode: mode);
  }
}

class _RunningView extends ConsumerWidget {
  const _RunningView({required this.mode});
  final ReviewMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewRunnerProvider(mode));
    final runner = ref.read(reviewRunnerProvider(mode).notifier);

    ref.listen<SessionRunnerState>(reviewRunnerProvider(mode), (prev, next) async {
      if (next.current is SessionComplete && prev?.current is! SessionComplete) {
        await _persistReview(ref, next);
        if (context.mounted) context.pop();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmQuit(context) && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmQuit(context) && context.mounted) context.pop();
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

Future<void> _persistReview(WidgetRef ref, SessionRunnerState s) async {
  final progress = ref.read(progressControllerProvider);
  final now = DateTime.now();
  final newSrs = applySessionToSrs(
    current: progress.srsByItem,
    itemCorrectness: s.itemCorrectness,
    now: now,
  );
  await ref.read(progressControllerProvider.notifier).update(
        progress.copyWith(srsByItem: newSrs, lastPlayed: now),
      );
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
