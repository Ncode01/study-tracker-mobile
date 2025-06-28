import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/models/study_analytics.dart';
import '../../providers/analytics_providers.dart';

/// Widget displaying earned achievements
class AchievementsWidget extends ConsumerWidget {
  const AchievementsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(
      achievementsProvider((
        timeRange: AnalyticsTimeRange.year,
        newOnly: false,
      )),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.parchmentWhite,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppColors.primaryBrown,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Caveat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            achievementsAsync.when(
              data: (achievements) => _buildAchievements(context, achievements),
              loading: () => _buildLoadingSkeleton(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    if (achievements.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children:
          achievements.map((achievement) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    achievement.isNew
                        ? AppColors.primaryGold.withOpacity(0.1)
                        : AppColors.fadeGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    achievement.isNew
                        ? Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3),
                        )
                        : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getAchievementColor(achievement.type),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getAchievementIcon(achievement.type),
                      color: AppColors.parchmentWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                achievement.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.inkBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (achievement.isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'NEW',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: AppColors.parchmentWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.fadeGray),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatAchievementDate(achievement.unlockedAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.fadeGray,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Color _getAchievementColor(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return AppColors.compassRed;
      case AchievementType.studyTime:
        return AppColors.primaryGold;
      case AchievementType.consistency:
        return AppColors.treasureGreen;
      case AchievementType.subject:
        return AppColors.skyBlue;
      case AchievementType.milestone:
        return AppColors.primaryBrown;
    }
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.studyTime:
        return Icons.access_time;
      case AchievementType.consistency:
        return Icons.check_circle;
      case AchievementType.subject:
        return Icons.subject;
      case AchievementType.milestone:
        return Icons.flag;
    }
  }

  String _formatAchievementDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.fadeGray.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.compassRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.compassRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.compassRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load achievements',
              style: TextStyle(color: AppColors.compassRed, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.fadeGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: AppColors.fadeGray,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'No achievements yet',
              style: TextStyle(
                color: AppColors.fadeGray,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Start studying to earn your first achievement!',
              style: TextStyle(color: AppColors.fadeGray, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
