import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_button.dart';

class QuickSwitchChips extends StatelessWidget {
  const QuickSwitchChips({
    super.key,
    required this.onMathsTap,
    required this.onBreakTap,
  });

  final VoidCallback onMathsTap;
  final VoidCallback onBreakTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassButton(
          label: 'Maths',
          onTap: onMathsTap,
          icon: Icons.calculate_outlined,
          iconColor: AppColors.accentMaths,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          labelStyle: AppTypography.display(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        GlassButton(
          label: 'Break',
          onTap: onBreakTap,
          icon: Icons.free_breakfast_outlined,
          iconColor: AppColors.idleGrey,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          labelStyle: AppTypography.display(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
