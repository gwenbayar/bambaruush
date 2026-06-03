import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/press_scale.dart';
import '../mascot/mascot_overlay.dart';

// Intrinsic size of assets/images/steppe_map_kids.png. Used to map a region's
// image-normalized mapPosition onto the BoxFit.cover-displayed image, so tiles
// stay pinned to landmarks (the ger) regardless of the phone's aspect ratio.
const double _kMapImageWidth = 714;
const double _kMapImageHeight = 1280;

class SteppeMapScreen extends ConsumerWidget {
  const SteppeMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final progress = ref.watch(progressControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Steppe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark),
            tooltip: 'Sticker Album',
            onPressed: () => context.push('/album'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings/gate'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // Replicate BoxFit.cover so we can place tiles in image space.
          final coverScale =
              math.max(w / _kMapImageWidth, h / _kMapImageHeight);
          final dispW = _kMapImageWidth * coverScale;
          final dispH = _kMapImageHeight * coverScale;
          final offsetX = (w - dispW) / 2;
          final offsetY = (h - dispH) / 2;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/steppe_map_kids.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFBFE3FF),
                          Color(0xFFC8D89A),
                          Color(0xFFAFC36E),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              for (final region in content.regions)
                Positioned(
                  // Anchor is image-normalized; map it onto the displayed image
                  // and center the tile on that point.
                  left: offsetX + region.mapPosition.dx * dispW,
                  top: offsetY + region.mapPosition.dy * dispH,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: _RegionTile(
                      label: region.nameEn,
                      lessonCompletions: [
                        for (final lesson in content.lessonsInRegion(region.id))
                          progress.lessons[lesson.id]?.completed ?? false,
                      ],
                      onTap: () => context.push('/region/${region.id}'),
                    ),
                  ),
                ),
              const MascotOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    required this.label,
    required this.lessonCompletions,
    required this.onTap,
  });
  final String label;

  /// One entry per lesson in the region; true if that lesson is completed.
  final List<bool> lessonCompletions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: AppColors.cardBorder, width: 2),
          boxShadow: const [kSoftShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.ink,
              ),
            ),
            if (lessonCompletions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final completed in lessonCompletions)
                    Icon(
                      completed
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: completed ? AppColors.sun : AppColors.inkSoft,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
