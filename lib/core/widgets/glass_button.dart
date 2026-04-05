import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_container.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    required this.label,
    required this.onTap,
    super.key,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.labelStyle,
    this.iconColor = AppColors.textMain,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final TextStyle? labelStyle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: GlassContainer(
        padding: padding,
        borderRadius: borderRadius,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: labelStyle ??
                  AppTypography.display(
                    color: AppColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
