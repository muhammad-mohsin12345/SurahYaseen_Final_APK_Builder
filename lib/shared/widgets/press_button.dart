import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Rounded button that gently shrinks when pressed.
class PressButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const PressButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = true,
  });

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.filled ? AppColors.emerald : Colors.transparent;
    final fg = widget.filled
        ? Colors.white
        : (dark ? AppColors.gold : AppColors.emeraldDark);
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold, width: widget.filled ? 0 : 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
