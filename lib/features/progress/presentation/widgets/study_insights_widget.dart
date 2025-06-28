import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/models/study_analytics.dart' as analytics;
import '../../providers/analytics_providers.dart';

/// Widget displaying study insights and patterns
class StudyInsightsWidget extends ConsumerWidget {
  const StudyInsightsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(selectedTimeRangeProvider);
    final insightsAsync = ref.watch(studyInsightsProvider(timeRange));

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
                Icon(Icons.insights, color: AppColors.primaryBrown, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Study Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Caveat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            insightsAsync.when(
              data: (insights) => _buildInsights(context, insights),
              loading: () => _buildLoadingSkeleton(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(
    BuildContext context,
    analytics.StudyInsights insights,
  ) {
    return Column(
      children: [
        // Current Streak
        _buildInsightTile(
          context: context,
          icon: Icons.local_fire_department,
          iconColor: AppColors.compassRed,
          title: 'Current Streak',
          value: '${insights.currentStreak.days} days',
          subtitle:
              insights.currentStreak.days > 0
                  ? 'Keep it up! 🔥'
                  : 'Start a new streak today!',
        ),
        const SizedBox(height: 12),

        // Weekly Goal Progress
        _buildProgressTile(
          context: context,
          title: 'Weekly Goal',
          progress: insights.weeklyGoalProgress,
          valueText:
              '${(insights.weeklyGoalProgress * 100).toStringAsFixed(0)}%',
        ),
        const SizedBox(height: 12),

        // Most Productive Time
        _buildInsightTile(
          context: context,
          icon: Icons.access_time,
          iconColor: AppColors.skyBlue,
          title: 'Most Productive Time',
          value: _formatTime(insights.mostProductiveTime),
          subtitle: 'Peak focus hours',
        ),
        const SizedBox(height: 12),

        // Most Productive Day
        _buildInsightTile(
          context: context,
          icon: Icons.calendar_today,
          iconColor: AppColors.treasureGreen,
          title: 'Most Productive Day',
          value: insights.mostProductiveDay.displayName,
          subtitle: 'Your best study day',
        ),
        const SizedBox(height: 12),

        // Average Daily Study Time
        _buildInsightTile(
          context: context,
          icon: Icons.timer,
          iconColor: AppColors.primaryGold,
          title: 'Daily Average',
          value: _formatDuration(insights.averageDailyStudyTime),
          subtitle: 'Time per day',
        ),

        if (insights.recommendedSubjects.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecommendedSubjects(context, insights.recommendedSubjects),
        ],
      ],
    );
  }

  Widget _buildInsightTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fadeGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.fadeGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.fadeGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTile({
    required BuildContext context,
    required String title,
    required double progress,
    required String valueText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fadeGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.fadeGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                valueText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.fadeGray.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppColors.treasureGreen : AppColors.primaryGold,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            progress >= 1.0 ? 'Goal achieved! 🎉' : 'Keep going!',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.fadeGray),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSubjects(
    BuildContext context,
    List<String> subjectIds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Focus',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.inkBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.skyBlue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.skyBlue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consider reviewing these subjects for better balance',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkBlack),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 60,
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
              'Failed to load insights',
              style: TextStyle(color: AppColors.compassRed, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(analytics.TimeOfDay time) {
    final hour =
        time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
