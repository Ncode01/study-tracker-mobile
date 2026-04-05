import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_panel.dart';

class TopStatsBar extends StatelessWidget {
  const TopStatsBar({
    super.key,
    required this.totalProductiveLabel,
    required this.streakLabel,
    required this.nextLabel,
    required this.totalProductive,
    required this.streak,
    required this.next,
  });

  final String totalProductiveLabel;
  final String streakLabel;
  final String nextLabel;
  final String totalProductive;
  final String streak;
  final String next;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              title: totalProductiveLabel,
              value: totalProductive,
            ),
          ),
          _StatDivider(),
          Expanded(child: _StatItem(title: streakLabel, value: streak)),
          _StatDivider(),
          Expanded(child: _StatItem(title: nextLabel, value: next)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.mono(
              color: AppColors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.glassBorder);
  }
}
