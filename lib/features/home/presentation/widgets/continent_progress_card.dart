import 'package:flutter/material.dart';
import '../../domain/models/study_progress.dart';
import '../../../../theme/app_colors.dart';

/// Progress card for individual subjects displayed as continents
/// Shows subject progress with traveler's diary styling
class ContinentProgressCard extends StatelessWidget {
  final StudyProgress progress;

  const ContinentProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSubject(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primaryBrown.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subject name and continent emoji
            Row(
              children: [
                // Continent emoji
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    progress.continentEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),

                const SizedBox(width: 12),

                // Subject name and level
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.subject.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.military_tech,
                            size: 14,
                            color: AppColors.primaryGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Level ${progress.level}",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Weekly time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        progress.targetAchieved
                            ? AppColors.successGreen.withOpacity(0.1)
                            : AppColors.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          progress.targetAchieved
                              ? AppColors.successGreen.withOpacity(0.3)
                              : AppColors.warningOrange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatTime(progress.weeklyTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          progress.targetAchieved
                              ? AppColors.successGreen
                              : AppColors.warningOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Weekly Progress",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${(progress.clampedProgress * 100).toInt()}%",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clampedProgress,
                    backgroundColor: AppColors.lightGray.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress.targetAchieved
                          ? AppColors.successGreen
                          : AppColors.primaryGold,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom row with stats and next topic
            Row(
              children: [
                // Sessions this week
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.event_note,
                    value: "${progress.sessionsThisWeek}",
                    label: "Sessions",
                  ),
                ),

                // Last studied indicator
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.schedule,
                    value: _getLastStudiedText(),
                    label: "Last Study",
                  ),
                ),

                // XP earned
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.stars,
                    value: "${progress.xpEarned}",
                    label: "XP",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Next suggested topic
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBrown.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBrown.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.primaryBrown.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Next: ${progress.nextSuggestedTopic}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryBrown.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryBrown.withOpacity(0.7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// Format time duration
  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return "${minutes}m";
    } else if (minutes == 0) {
      return "${hours}h";
    } else {
      return "${hours}h ${minutes}m";
    }
  }

  /// Get last studied text
  String _getLastStudiedText() {
    final daysSince = progress.daysSinceLastStudy;

    if (daysSince == 0) {
      return "Today";
    } else if (daysSince == 1) {
      return "Yesterday";
    } else if (daysSince < 7) {
      return "${daysSince}d ago";
    } else {
      return "${(daysSince / 7).floor()}w ago";
    }
  }

  /// Navigate to subject details
  void _navigateToSubject(BuildContext context) {
    // TODO: Navigate to subject detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${progress.subject.name} details coming soon!"),
        backgroundColor: AppColors.primaryBrown,
      ),
    );
  }
}
