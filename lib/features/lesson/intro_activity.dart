import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/audio_button.dart';
import '../../widgets/candy_button.dart';
import 'activity_spec.dart';

class IntroActivityView extends ConsumerStatefulWidget {
  const IntroActivityView({super.key, required this.spec, required this.onContinue});
  final IntroSpec spec;
  final VoidCallback onContinue;
  @override
  ConsumerState<IntroActivityView> createState() => _IntroActivityViewState();
}

class _IntroActivityViewState extends ConsumerState<IntroActivityView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final letter = ref.read(contentRepositoryProvider).letterById(widget.spec.letterId);
      ref.read(audioServiceProvider).play(letter.audioAssetPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final letter = ref.watch(contentRepositoryProvider).letterById(widget.spec.letterId);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letter.cyrillic,
            style: const TextStyle(fontSize: 160, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AudioButton(
            onPressed: () =>
                ref.read(audioServiceProvider).play(letter.audioAssetPath),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hear it again',
            style: TextStyle(
              fontFamily: AppFonts.display,
              color: AppColors.inkSoft,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          CandyButton(
            label: 'Next',
            icon: Icons.arrow_forward_rounded,
            onPressed: widget.onContinue,
          ),
        ],
      ),
    );
  }
}
