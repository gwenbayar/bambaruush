import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';
import '../../widgets/confetti_burst.dart';
import '../mascot/mascot_controller.dart';
import 'activity_spec.dart';

/// Stars celebration at the end of a review session. No album sticker (those
/// stay tied to lessons) — just encouragement.
class ReviewCompleteActivityView extends ConsumerStatefulWidget {
  const ReviewCompleteActivityView({
    super.key,
    required this.spec,
    required this.onContinue,
  });
  final ReviewCompleteSpec spec;
  final VoidCallback onContinue;

  @override
  ConsumerState<ReviewCompleteActivityView> createState() =>
      _ReviewCompleteActivityViewState();
}

class _ReviewCompleteActivityViewState
    extends ConsumerState<ReviewCompleteActivityView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mascotProvider.notifier).cheer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.spec.reviewedCount;
    return Stack(
      children: [
        const ConfettiBurst(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Great practice!',
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    const Icon(Icons.star_rounded, size: 48, color: AppColors.sun)
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          curve: Curves.elasticOut,
                          duration: const Duration(milliseconds: 500),
                        ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                count == 1
                    ? 'You practiced 1 item!'
                    : 'You practiced $count items!',
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 24),
              CandyButton(
                label: 'Done',
                icon: Icons.check_rounded,
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
