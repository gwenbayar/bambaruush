import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';
import '../../widgets/confetti_burst.dart';
import '../mascot/mascot_controller.dart';
import 'lesson_runner.dart';

class RewardStageWidget extends ConsumerStatefulWidget {
  const RewardStageWidget({super.key, required this.stage, required this.onContinue});
  final RewardStage stage;
  final VoidCallback onContinue;
  @override
  ConsumerState<RewardStageWidget> createState() => _RewardStageWidgetState();
}

class _RewardStageWidgetState extends ConsumerState<RewardStageWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mascotProvider.notifier).cheer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sticker = ref.watch(contentRepositoryProvider).stickerById(widget.stage.stickerId);
    return Stack(
      children: [
        // Celebration confetti behind the content. IgnorePointer keeps taps
        // flowing to the Continue button.
        const ConfettiBurst(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Great job!',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: AppColors.coral,
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 400))
                  .slideY(
                    begin: -0.4,
                    end: 0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 400),
                  ),
              const SizedBox(height: 16),
              Image.asset(
                sticker.imageAssetPath,
                width: 180,
                height: 180,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.sun.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  child: Text(
                    sticker.nameEn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    curve: Curves.elasticOut,
                    duration: const Duration(milliseconds: 600),
                  ),
              const SizedBox(height: 12),
              Text(
                sticker.nameEn,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 18, color: AppColors.sun),
                  SizedBox(width: 4),
                  Text(
                    'New sticker!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 400),
                  ),
              const SizedBox(height: 24),
              CandyButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: widget.onContinue,
                color: AppColors.meadow,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
