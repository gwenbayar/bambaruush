import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/constellation.dart';
import '../../theme/app_theme.dart';

/// Od's night sky: the permanent record of mastered words/letters. The first 7
/// stars fill Doloon Burhan; extras scatter as ambient background stars.
class SkyScreen extends ConsumerWidget {
  const SkyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final progress = ref.watch(progressControllerProvider);
    final stars = progress.skyStarItemKeys;

    Constellation? found;
    for (final c in content.constellations) {
      if (c.id == 'doloon_burhan') {
        found = c;
        break;
      }
    }
    // final so the null-promotion below flows into the LayoutBuilder closure.
    final dipper = found ??
        (content.constellations.isEmpty ? null : content.constellations.first);

    final complete = dipper != null &&
        (progress.completedConstellationIds.contains(dipper.id) ||
            stars.length >= dipper.slots.length);

    return Scaffold(
      appBar: AppBar(title: const Text("Od's Sky")),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1026), Color(0xFF1B2350), Color(0xFF2E2A4A)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/sky_night.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            if (dipper != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final d = dipper;
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(w, h),
                        painter: _DipperLines(slots: d.slots, filled: stars.length),
                      ),
                      for (var i = 0; i < d.slots.length; i++)
                        Positioned(
                          left: d.slots[i].dx * w - _kSlotStarSize / 2,
                          top: d.slots[i].dy * h - _kSlotStarSize / 2,
                          child: Icon(
                            Icons.star_rounded,
                            size: _kSlotStarSize,
                            color: i < stars.length ? AppColors.sun : Colors.white24,
                          ),
                        ),
                      for (var i = d.slots.length; i < stars.length; i++)
                        _ambientStar(stars[i], w, h),
                    ],
                  );
                },
              ),
            Positioned(top: 12, right: 16, child: _CountChip(count: stars.length)),
            if (dipper != null)
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      dipper.nameEn,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: complete ? AppColors.sun : Colors.white54,
                      ),
                    ),
                    Text(
                      dipper.nameMn,
                      style: TextStyle(
                        fontFamily: AppFonts.learning,
                        fontSize: 16,
                        color: complete ? Colors.white : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Diameter of a Doloon Burhan slot star; the slot is centered on its anchor.
const double _kSlotStarSize = 28;

/// A small decorative star for an earned star beyond the constellation's slots,
/// placed at a deterministic position derived from [key] (same key → same spot).
Positioned _ambientStar(String key, double w, double h) {
  final hx = key.hashCode;
  final dx = ((hx & 0xFFFF) / 0xFFFF) * 0.9 + 0.05;
  final dy = (((hx >> 16) & 0xFFFF) / 0xFFFF) * 0.4 + 0.08;
  return Positioned(
    left: dx * w,
    top: dy * h,
    child: const Icon(Icons.star_rounded, size: 12, color: Colors.white70),
  );
}

class _DipperLines extends CustomPainter {
  _DipperLines({required this.slots, required this.filled});
  final List<Offset> slots;
  final int filled;

  @override
  void paint(Canvas canvas, Size size) {
    final n = filled.clamp(0, slots.length);
    if (n < 2) return;
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final p = Offset(slots[i].dx * size.width, slots[i].dy * size.height);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DipperLines old) =>
      old.filled != filled || old.slots != slots;
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.sun, size: 18),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.display,
            ),
          ),
        ],
      ),
    );
  }
}
