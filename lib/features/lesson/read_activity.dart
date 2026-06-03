import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/language.dart';
import '../../core/providers.dart';
import '../../models/word.dart';
import '../../theme/app_theme.dart';
import '../../widgets/audio_button.dart';
import '../mascot/mascot_controller.dart';
import 'activity_spec.dart';

const _kWrongColor = Color(0xFFE2574C);

class ReadActivityView extends ConsumerStatefulWidget {
  const ReadActivityView({
    super.key,
    required this.spec,
    required this.onResult,
  });
  final ReadSpec spec;
  final void Function({required bool correct}) onResult;

  @override
  ConsumerState<ReadActivityView> createState() => _ReadActivityViewState();
}

class _ReadActivityViewState extends ConsumerState<ReadActivityView> {
  late List<Word> _tiles;

  /// The id of the tile the child tapped, or null until a choice is made.
  /// Once set, further taps are ignored while feedback plays.
  String? _lockedChoiceId;
  bool? _wasCorrect;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare() {
    final content = ref.read(contentRepositoryProvider);
    _tiles = [
      content.wordById(widget.spec.wordId),
      ...widget.spec.distractorIds.map(content.wordById),
    ]..shuffle(Random(widget.spec.wordId.hashCode));
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(contentRepositoryProvider).wordById(widget.spec.wordId);
    final lang = ref.watch(learningLanguageProvider);
    final feedbackActive = _lockedChoiceId != null;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            target.text(lang),
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AudioButton(
            size: 60,
            onPressed: () {
              final path = target.audioPath(lang);
              if (path != null) {
                ref.read(audioServiceProvider).play(path);
              }
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _tiles.map((w) {
                final isTarget = w.id == widget.spec.wordId;
                final isTapped = w.id == _lockedChoiceId;
                return _Tile(
                  word: w,
                  onTap: () => _onTap(w),
                  showCorrect: feedbackActive && _wasCorrect == false && isTarget,
                  showWrongSelected:
                      feedbackActive && isTapped && _wasCorrect == false,
                  selectedCorrect:
                      feedbackActive && isTapped && _wasCorrect == true,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(Word tapped) {
    if (_lockedChoiceId != null) return;
    final correct = tapped.id == widget.spec.wordId;
    setState(() {
      _lockedChoiceId = tapped.id;
      _wasCorrect = correct;
    });

    final mascot = ref.read(mascotProvider.notifier);
    if (correct) {
      mascot.cheer();
      HapticFeedback.mediumImpact();
    } else {
      mascot.sad();
      HapticFeedback.lightImpact();
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) widget.onResult(correct: correct);
    });
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.word,
    required this.onTap,
    this.showCorrect = false,
    this.showWrongSelected = false,
    this.selectedCorrect = false,
  });
  final Word word;
  final VoidCallback onTap;

  /// This tile is the correct answer and feedback is active (used to teach the
  /// child which one was right after a wrong tap).
  final bool showCorrect;

  /// This tile was tapped and it was wrong.
  final bool showWrongSelected;

  /// This tile was tapped and it was correct.
  final bool selectedCorrect;

  @override
  Widget build(BuildContext context) {
    final highlightCorrect = selectedCorrect || showCorrect;
    final borderColor = showWrongSelected
        ? _kWrongColor
        : (highlightCorrect ? AppColors.meadow : Colors.brown.shade300);
    final borderWidth = (highlightCorrect || showWrongSelected) ? 4.0 : 2.0;

    Widget tile = AnimatedScale(
      scale: selectedCorrect ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Image.asset(
              word.imageAssetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  _imageFallback(word.text(glossLanguage)),
            ),
            if (highlightCorrect)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.meadow,
                  size: 26,
                ),
              ),
          ],
        ),
      ),
    );

    if (showWrongSelected) {
      tile = tile.animate().shake(
            duration: const Duration(milliseconds: 500),
            hz: 6,
            offset: const Offset(6, 0),
          );
    }

    return InkWell(onTap: onTap, child: tile);
  }
}

/// Soft fallback shown when a word image asset is missing or fails to decode
/// (e.g. a placeholder/stub image on web). Shows the English label instead of
/// a broken-image error widget.
Widget _imageFallback(String label) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.sun.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.all(8),
    alignment: Alignment.center,
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 15,
        color: AppColors.ink,
      ),
    ),
  );
}
