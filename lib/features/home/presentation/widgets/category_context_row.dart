import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CategoryContextRow extends StatelessWidget {
  const CategoryContextRow({
    super.key,
    required this.subject,
    required this.accentColor,
    required this.icon,
    required this.heroTag,
  });

  final String subject;
  final Color accentColor;
  final IconData icon;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: heroTag,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.42)),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          subject,
          style: AppTypography.heading(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
