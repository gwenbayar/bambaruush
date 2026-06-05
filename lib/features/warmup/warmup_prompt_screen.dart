import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/candy_button.dart';

/// Once-a-day offer shown after the splash. "Let's go" runs the warm-up review;
/// "Maybe later" stamps the day (so we don't re-ask) and goes to the map.
class WarmupPromptScreen extends ConsumerWidget {
  const WarmupPromptScreen({super.key});

  Future<void> _skip(BuildContext context, WidgetRef ref) async {
    final progress = ref.read(progressControllerProvider);
    await ref
        .read(progressControllerProvider.notifier)
        .update(progress.copyWith(lastWarmupAt: DateTime.now()));
    if (context.mounted) context.go('/steppe');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _skip(context, ref);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/bambaruush.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Text('🐻', style: TextStyle(fontSize: 64)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ready for a quick warm-up?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A few quick reviews to keep your words fresh.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 28),
              CandyButton(
                label: "Let's go!",
                icon: Icons.bolt_rounded,
                onPressed: () => context.go('/review?warmup=1'),
                color: AppColors.coral,
              ),
              const SizedBox(height: 12),
              CandyButton(
                label: 'Maybe later',
                icon: Icons.bedtime_rounded,
                onPressed: () => _skip(context, ref),
                color: AppColors.sky,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
