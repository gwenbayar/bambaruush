import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A self-contained, dependency-free confetti animation that plays once when
/// mounted. About 40 colored particles launch upward/outward from the
/// bottom-center, arc under gravity, and fade out near the end.
///
/// It sizes to its parent and is wrapped in [IgnorePointer] so it never blocks
/// taps on widgets beneath it.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  static const _count = 40;

  static const _palette = <Color>[
    AppColors.coral,
    AppColors.sun,
    AppColors.meadow,
    AppColors.sky,
    Color(0xFFFF8FB1), // pink
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // Deterministic per-mount randomness, seeded by particle index.
    _particles = List.generate(_count, (i) {
      final rnd = math.Random(i * 7919 + 17);
      // Launch mostly upward: angle measured from the upward vertical, spread
      // out to both sides.
      final spread = (rnd.nextDouble() - 0.5) * 1.7; // ~ -0.85..0.85 rad
      final speed = 0.9 + rnd.nextDouble() * 0.9; // relative launch speed
      return _Particle(
        color: _palette[i % _palette.length],
        // Start near bottom-center with a little horizontal scatter.
        startX: 0.5 + (rnd.nextDouble() - 0.5) * 0.2,
        angle: spread,
        speed: speed,
        size: 8 + rnd.nextDouble() * 4, // ~8-12px
        rotation: rnd.nextDouble() * math.pi * 2,
        spin: (rnd.nextDouble() - 0.5) * 8,
        isCircle: i.isEven,
      );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.color,
    required this.startX,
    required this.angle,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.isCircle,
  });

  /// Fractional horizontal launch position (0..1 of width).
  final double startX;

  /// Launch angle in radians, offset from straight up.
  final double angle;

  /// Relative launch speed.
  final double speed;
  final Color color;
  final double size;
  final double rotation;
  final double spin;
  final bool isCircle;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Launch impulse and gravity expressed as fractions of the canvas height
    // so the burst scales with whatever space it fills.
    final launch = size.height * 0.95;
    final gravity = size.height * 1.6;
    final t = progress; // 0..1

    for (final p in particles) {
      // Projectile motion: y = -v0*t + 0.5*g*t^2 (y grows downward on screen).
      final vy = -math.cos(p.angle) * p.speed * launch;
      final vx = math.sin(p.angle) * p.speed * (size.width * 0.55);
      final dx = vx * t;
      final dy = vy * t + 0.5 * gravity * t * t;

      final x = p.startX * size.width + dx;
      final y = size.height + dy; // start at bottom edge

      // Fade out over the last ~35% of the timeline.
      final opacity = t < 0.65 ? 1.0 : (1.0 - (t - 0.65) / 0.35).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()..color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.spin * t);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.7,
          ),
          Radius.circular(p.size * 0.25),
        );
        canvas.drawRRect(r, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
