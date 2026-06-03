import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Large round "play audio" button — the always-obvious way to hear the word.
class AudioButton extends StatefulWidget {
  const AudioButton({
    super.key,
    required this.onPressed,
    this.size = 72,
    this.color = AppColors.sky,
    this.icon = Icons.volume_up_rounded,
  });

  final VoidCallback onPressed;
  final double size;
  final Color color;
  final IconData icon;

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: const [kSoftShadow],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.5),
        ),
      ),
    );
  }
}
