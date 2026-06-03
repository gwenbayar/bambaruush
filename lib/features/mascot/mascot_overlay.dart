import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mascot_mood.dart';
import '../../theme/app_theme.dart';
import 'mascot_controller.dart';

/// A living mascot in the bottom-right corner: the bear gently bobs/breathes
/// continuously, and a small speech bubble pops up above it for expressive
/// moods (hidden while idle). Never intercepts touches.
class MascotOverlay extends ConsumerWidget {
  const MascotOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(mascotProvider);
    return Positioned(
      right: 16,
      bottom: 24,
      child: IgnorePointer(
        child: SizedBox(
          width: 84,
          // Reserve a little headroom above the bear for the speech bubble so
          // it can be positioned absolutely without shifting the bear.
          height: 84 + _bubbleHeadroom,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Speech bubble sits above the bear; absolutely positioned so it
              // never pushes the bear around.
              if (_message(mood) != null)
                Positioned(
                  left: -28,
                  right: -28,
                  top: 0,
                  child: _SpeechBubble(
                    key: ValueKey(mood),
                    text: _message(mood)!,
                  ),
                ),
              // The bear circle, anchored to the bottom.
              Positioned(
                bottom: 0,
                child: _BobbingBear(mood: mood, ringColor: _ringColor(mood)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Space reserved above the 84px bear for the bubble + tail.
  static const double _bubbleHeadroom = 56;

  Color _ringColor(MascotMood mood) {
    switch (mood) {
      case MascotMood.cheer:
        return const Color(0xFF6BB66B);
      case MascotMood.sad:
        return const Color(0xFF8AA0B0);
      case MascotMood.point:
      case MascotMood.wave:
        return const Color(0xFFE0A93B);
      case MascotMood.sleep:
        return const Color(0xFFB0A6C0);
      case MascotMood.idle:
        return const Color(0xFF8B5E2A);
    }
  }

  /// Short, friendly encouragement for expressive moods. `null` => no bubble.
  String? _message(MascotMood mood) {
    switch (mood) {
      case MascotMood.cheer:
        return 'Great! 🎉';
      case MascotMood.sad:
        return 'Try again! 💪';
      case MascotMood.point:
        return 'Your turn! 👉';
      case MascotMood.wave:
        return 'Hi! 👋';
      case MascotMood.sleep:
        return 'Zzz… 💤';
      case MascotMood.idle:
        return null;
    }
  }
}

/// The circular bear with mood ring + emoji fallback. It pops on mood change
/// and continuously bobs/breathes so the corner feels alive at rest.
class _BobbingBear extends StatelessWidget {
  const _BobbingBear({required this.mood, required this.ringColor});

  final MascotMood mood;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: ringColor, width: 3),
        boxShadow: const [kSoftShadow],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/bambaruush.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('🐻', style: TextStyle(fontSize: 44)),
          ),
        ),
      ),
    );

    // Pop on each mood change (keyed by mood), then bob forever.
    return circle
        .animate(key: ValueKey(mood))
        .scale(
          duration: const Duration(milliseconds: 280),
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        )
        // Continuous gentle breathing/bob using transforms only (no layout
        // changes), so it can't cause jank or overflow.
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -6,
          duration: 1200.ms,
          curve: Curves.easeInOut,
        )
        .scaleXY(
          begin: 1.0,
          end: 1.03,
          duration: 1200.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// A small rounded white speech bubble with a downward tail pointing at the
/// bear. Animates in (fade + scale + slide-up) whenever it appears.
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bubble = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: const [kSoftShadow],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.15,
              color: AppColors.ink,
            ),
          ),
        ),
        // Little tail pointing down toward the bear.
        CustomPaint(
          size: const Size(16, 8),
          painter: _BubbleTailPainter(),
        ),
      ],
    );

    return bubble
        .animate(key: ValueKey(text))
        .fadeIn(duration: 220.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 260.ms,
          curve: Curves.easeOutBack,
        )
        .moveY(begin: 8, end: 0, duration: 240.ms, curve: Curves.easeOut);
  }
}

/// Draws the bubble tail (a small downward triangle) with the same fill and
/// border as the bubble body so it reads as one shape.
class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);

    // Only stroke the two slanted edges so the top blends into the bubble body.
    final border = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final edges = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(edges, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
