import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/constellation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';

/// Post-session celebration for newly-earned sky-stars and any constellation
/// just completed. Returns immediately (no dialog) when there's nothing to show.
Future<void> showSkyRewards(
  BuildContext context, {
  required int newStarCount,
  required List<Constellation> completedConstellations,
}) {
  if (newStarCount == 0 && completedConstellations.isEmpty) {
    return Future<void>.value();
  }
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _SkyRewardDialog(
      newStarCount: newStarCount,
      completed: completedConstellations,
    ),
  );
}

class _SkyRewardDialog extends StatelessWidget {
  const _SkyRewardDialog({required this.newStarCount, required this.completed});
  final int newStarCount;
  final List<Constellation> completed;

  @override
  Widget build(BuildContext dialogContext) {
    return Dialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (newStarCount > 0) ...[
              const Icon(Icons.star_rounded, color: AppColors.sun, size: 56)
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    curve: Curves.elasticOut,
                    duration: const Duration(milliseconds: 500),
                  ),
              const SizedBox(height: 8),
              Text(
                newStarCount == 1
                    ? 'A new star for your sky!'
                    : '$newStarCount new stars for your sky!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.coral,
                ),
              ),
            ],
            for (final c in completed) ...[
              const SizedBox(height: 20),
              Image.asset(
                c.shapeImage,
                width: 96,
                height: 96,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome,
                  size: 72,
                  color: AppColors.sun,
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500))
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    curve: Curves.easeOutBack,
                    duration: const Duration(milliseconds: 500),
                  ),
              const SizedBox(height: 8),
              Text(
                c.nameEn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.ink,
                ),
              ),
              Text(
                c.nameMn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.learning,
                  fontSize: 16,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                c.trivia,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
              ),
            ],
            const SizedBox(height: 24),
            CandyButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(dialogContext).pop(),
              color: AppColors.meadow,
            ),
          ],
        ),
      ),
    );
  }
}
