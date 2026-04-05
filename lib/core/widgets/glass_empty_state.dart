import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_button.dart';
import 'glass_container.dart';

class GlassEmptyState extends StatelessWidget {
  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onButtonTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        borderRadius: BorderRadius.circular(26),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple.withValues(alpha: 0.18),
                border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(icon, color: AppColors.textMain, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.heading(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            GlassButton(
              label: buttonLabel,
              icon: Icons.play_arrow_rounded,
              onTap: onButtonTap,
              labelStyle: AppTypography.display(
                color: AppColors.primaryPurple,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              iconColor: AppColors.primaryPurple,
            ),
          ],
        ),
      ),
    );
  }
}
