import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a child so it gently scales down on tap-down, giving small fingers
/// a satisfying, tactile press response. When [onTap] is null the child is
/// shown as-is and does not respond to touches.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.97,
    this.haptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Scale applied while pressed (e.g. 0.97 for a subtle dip, 0.95 stronger).
  final double pressedScale;
  final bool haptics;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (!_enabled) return;
    if (value && widget.haptics) HapticFeedback.lightImpact();
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
