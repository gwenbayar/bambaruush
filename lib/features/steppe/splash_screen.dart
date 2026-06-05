import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../review/review_queue.dart';
import '../warmup/warmup_logic.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final progress = ref.read(progressControllerProvider);
      final hasPracticeItems = ref.read(reviewQueueProvider).isNotEmpty ||
          ref.read(freePracticeProvider).isNotEmpty;
      final destination = shouldOfferWarmup(
        lastWarmupAt: progress.lastWarmupAt,
        now: DateTime.now(),
        hasPracticeItems: hasPracticeItems,
      )
          ? '/warmup'
          : '/steppe';
      if (mounted) context.go(destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/bambaruush.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Text('🐻', style: TextStyle(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bambaruush',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
