import 'package:flutter/material.dart';
import '../../domain/models/home_dashboard_data.dart';
import '../../../../theme/app_colors.dart';

/// Welcome card showing personalized greeting and current streak
/// Displays user name, motivational message, and streak indicator
class ExplorerWelcomeCard extends StatelessWidget {
  final HomeDashboardData dashboardData;

  const ExplorerWelcomeCard({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGold.withOpacity(0.1),
            AppColors.primaryCream.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBrown.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with greeting and avatar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryBrown,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dashboardData.greetingMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // User level badge
              _buildLevelBadge(context),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              // Streak indicator
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  iconColor:
                      dashboardData.stats.currentStreak > 0
                          ? AppColors.errorRed
                          : AppColors.fadeGray,
                  value: "${dashboardData.stats.currentStreak}",
                  label: "Day Streak",
                ),
              ),

              // Vertical divider
              Container(
                height: 40,
                width: 1,
                color: AppColors.primaryBrown.withOpacity(0.2),
              ),

              // Weekly sessions
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.school,
                  iconColor: AppColors.treasureGreen,
                  value: "${dashboardData.stats.totalSessionsThisWeek}",
                  label: "This Week",
                ),
              ),

              // Vertical divider
              Container(
                height: 40,
                width: 1,
                color: AppColors.primaryBrown.withOpacity(0.2),
              ),

              // Total time
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.access_time,
                  iconColor: AppColors.skyBlue,
                  value: _formatTime(dashboardData.stats.totalTimeThisWeek),
                  label: "Total Time",
                ),
              ),
            ],
          ),

          // Motivational message if there's an active streak
          if (dashboardData.stats.currentStreak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: 16,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _getStreakMessage(dashboardData.stats.currentStreak),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build user level badge
  Widget _buildLevelBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Level ${dashboardData.user.level}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.parchmentWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            dashboardData.stats.currentRank,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryGold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Get time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    final name = dashboardData.user.displayName;

    if (hour < 12) {
      return "Good morning, $name!";
    } else if (hour < 17) {
      return "Good afternoon, $name!";
    } else {
      return "Good evening, $name!";
    }
  }

  /// Format duration to readable string
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

  /// Get streak message based on count
  String _getStreakMessage(int streak) {
    if (streak == 1) {
      return "Great start! Keep the momentum going!";
    } else if (streak < 7) {
      return "Building momentum! $streak days strong!";
    } else if (streak < 30) {
      return "Incredible dedication! $streak day streak!";
    } else {
      return "Legendary explorer! $streak day streak!";
    }
  }
}
