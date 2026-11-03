import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class IslamicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  const IslamicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(20);
    return Material(
      color: color ?? (dark ? AppColors.charcoalLight : Colors.white),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.gold.withValues(alpha: 0.30),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
