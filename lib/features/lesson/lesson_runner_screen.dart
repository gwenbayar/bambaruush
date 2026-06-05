import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../models/lesson.dart';
import '../../models/lesson_progress.dart';
import '../mascot/mascot_overlay.dart';
import 'activity_spec.dart';
import 'activity_view.dart';
import 'lesson_session.dart';
import 'session_runner.dart';
import 'srs_update.dart';

final lessonRunnerProvider = StateNotifierProvider.autoDispose
    .family<SessionRunner, SessionRunnerState, Lesson>((ref, lesson) {
  final content = ref.watch(contentRepositoryProvider);
  final sequence = LessonSession(lesson: lesson, content: content).buildSequence();
  return SessionRunner(sequence: sequence);
});

class LessonRunnerScreen extends ConsumerWidget {
  const LessonRunnerScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final lesson = content.lessonById(lessonId);
    final state = ref.watch(lessonRunnerProvider(lesson));
    final runner = ref.read(lessonRunnerProvider(lesson).notifier);

    ref.listen<SessionRunnerState>(
      lessonRunnerProvider(lesson),
      (prev, next) async {
        if (next.current is SessionComplete && prev?.current is! SessionComplete) {
          await _persistCompletion(ref, lesson, next);
          if (context.mounted) context.pop();
        }
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmQuit(context) && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.title ?? 'Lesson ${lesson.order}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmQuit(context) && context.mounted) {
                context.pop();
              }
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

  Future<bool> _confirmQuit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit lesson?'),
        content: const Text('Your progress in this lesson will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep playing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _persistCompletion(
    WidgetRef ref,
    Lesson lesson,
    SessionRunnerState s,
  ) async {
    final progress = ref.read(progressControllerProvider);
    final progressCtrl = ref.read(progressControllerProvider.notifier);
    final content = ref.read(contentRepositoryProvider);
    final now = DateTime.now();

    final newSrs = applySessionToSrs(
      current: progress.srsByItem,
      itemCorrectness: s.itemCorrectness,
      now: now,
    );

    final newLessons = {...progress.lessons};
    newLessons[lesson.id] = LessonProgress(
      lessonId: lesson.id,
      unlocked: true,
      completed: true,
      completionCount:
          (progress.lessons[lesson.id]?.completionCount ?? 0) + 1,
      completedAt: now,
    );
    final allLessons = content.lessons;
    final nextList = allLessons.where((l) => l.order == lesson.order + 1).toList();
    if (nextList.isNotEmpty && newLessons[nextList.first.id] == null) {
      final next = nextList.first;
      newLessons[next.id] = LessonProgress(
        lessonId: next.id,
        unlocked: true,
        completed: false,
        completionCount: 0,
      );
    }

    await progressCtrl.update(
      progress.copyWith(
        lessons: newLessons,
        srsByItem: newSrs,
        earnedStickerIds: {...progress.earnedStickerIds, lesson.stickerId},
        lastPlayed: now,
      ),
    );
  }
}
