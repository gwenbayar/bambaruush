import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../models/lesson.dart';
import '../../models/progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/press_scale.dart';
import '../mascot/mascot_overlay.dart';

class RegionDetailScreen extends ConsumerWidget {
  const RegionDetailScreen({super.key, required this.regionId});
  final String regionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final progress = ref.watch(progressControllerProvider);
    final region = content.regionById(regionId);
    final lessons = content.lessonsInRegion(regionId);

    return Scaffold(
      appBar: AppBar(title: Text(region.nameEn)),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              final unlocked = _isUnlocked(lesson, content.lessons, progress);
              final completed =
                  progress.lessons[lesson.id]?.completed ?? false;
              final wordsPreview = lesson.wordIds
                  .map((w) => content.wordById(w).english)
                  .join(' · ');
              return _LessonTile(
                lesson: lesson,
                letterCyrillic:
                    content.letterById(lesson.letterIds.first).cyrillic,
                wordsPreview: wordsPreview,
                unlocked: unlocked,
                completed: completed,
                onTap: unlocked
                    ? () => context.push('/lesson/${lesson.id}')
                    : null,
              );
            },
          ),
          const MascotOverlay(),
        ],
      ),
    );
  }

  bool _isUnlocked(Lesson lesson, List<Lesson> all, Progress progress) {
    if (lesson.order == 1) return true;
    final prev = all.firstWhere((l) => l.order == lesson.order - 1);
    return progress.lessons[prev.id]?.completed ?? false;
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.letterCyrillic,
    required this.wordsPreview,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });
  final Lesson lesson;
  final String letterCyrillic;
  final String wordsPreview;
  final bool unlocked;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = PressScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.cardBorder, width: 2),
          boxShadow: const [kSoftShadow],
        ),
        child: Row(
          children: [
            _Avatar(
              letterCyrillic: letterCyrillic,
              unlocked: unlocked,
              completed: completed,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.title ?? 'Lesson ${lesson.order}',
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.ink,
                    ),
                  ),
                  if (wordsPreview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      wordsPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.learning,
                        fontSize: 14,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Trailing(unlocked: unlocked, completed: completed),
          ],
        ),
      ),
    );

    if (!unlocked) {
      return Opacity(opacity: 0.5, child: card);
    }
    return card;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.letterCyrillic,
    required this.unlocked,
    required this.completed,
  });
  final String letterCyrillic;
  final bool unlocked;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final Color background;
    if (!unlocked) {
      background = AppColors.inkSoft;
    } else if (completed) {
      background = AppColors.meadow;
    } else {
      background = AppColors.sun;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: unlocked
          ? Text(
              letterCyrillic,
              style: const TextStyle(
                // Cyrillic glyph: must use the learning font.
                fontFamily: AppFonts.learning,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.unlocked, required this.completed});
  final bool unlocked;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return const Icon(Icons.star_rounded, color: AppColors.sun, size: 32);
    }
    if (unlocked) {
      return const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.coral,
        size: 32,
      );
    }
    return const Icon(
      Icons.star_outline_rounded,
      color: AppColors.inkSoft,
      size: 32,
    );
  }
}
