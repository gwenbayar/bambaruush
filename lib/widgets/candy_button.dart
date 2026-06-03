import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// A chunky, tactile "candy" button: rounded, with a darker bottom lip that
/// the face presses into on tap. Big touch target for small fingers.
class CandyButton extends StatefulWidget {
  const CandyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.coral,
    this.textColor = Colors.white,
    this.icon,
    this.minWidth = 200,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final double minWidth;

  @override
  State<CandyButton> createState() => _CandyButtonState();
}

class _CandyButtonState extends State<CandyButton> {
  bool _pressed = false;
  static const _lip = 6.0;

  bool get _enabled => widget.onPressed != null;

  Color get _lipColor => Color.alphaBlend(Colors.black.withValues(alpha: 0.22), widget.color);

  void _setPressed(bool v) {
    if (!_enabled) return;
    if (v) HapticFeedback.lightImpact();
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.button);
    return Opacity(
      opacity: _enabled ? 1 : 0.5,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: SizedBox(
          width: widget.minWidth,
          height: 64 + _lip,
          child: Stack(
            children: [
              // Lip (shadow base)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(color: _lipColor, borderRadius: radius),
                ),
              ),
              // Face
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: _pressed ? _lip : 0,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(color: widget.color, borderRadius: radius),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.textColor, size: 24),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: widget.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
