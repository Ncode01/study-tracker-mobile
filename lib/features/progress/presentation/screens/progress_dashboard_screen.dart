import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/models/study_analytics.dart';
import '../widgets/achievements_widget.dart';
import '../widgets/study_insights_widget.dart';
import '../widgets/study_time_chart.dart';
import '../widgets/subject_breakdown_widget.dart';
import '../widgets/time_range_selector.dart';
import '../../providers/analytics_providers.dart';

/// Main Progress Analytics Dashboard Screen
class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAnalyticsAsync = ref.watch(currentAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.parchmentWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: AppColors.parchmentWhite,
        elevation: 0,
        title: Text(
          'Progress Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.parchmentWhite,
            fontWeight: FontWeight.bold,
            fontFamily: 'Caveat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentAnalyticsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentAnalyticsProvider);
        },
        color: AppColors.primaryGold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Time Range Selector
              const TimeRangeSelector(),

              // Summary Stats
              currentAnalyticsAsync.when(
                data: (analytics) => _buildSummaryStats(context, analytics),
                loading: () => _buildSummaryLoadingSkeleton(),
                error: (error, stack) => _buildSummaryErrorState(error),
              ),

              const SizedBox(height: 8),

              // Study Time Chart
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StudyTimeChart(),
              ),

              const SizedBox(height: 16),

              // Subject Breakdown
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SubjectBreakdownWidget(),
              ),

              const SizedBox(height: 16),

              // Study Insights
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StudyInsightsWidget(),
              ),

              const SizedBox(height: 16),

              // Achievements
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AchievementsWidget(),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, StudyAnalytics analytics) {
    final totalHours = analytics.totalStudyTime.inHours;
    final totalMinutes = analytics.totalStudyTime.inMinutes % 60;
    final timeText =
        totalHours > 0 ? '${totalHours}h ${totalMinutes}m' : '${totalMinutes}m';

    final sessionsCount = analytics.dailyData.fold<int>(
      0,
      (sum, day) => sum + day.sessionsCompleted,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold,
            AppColors.primaryGold.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context: context,
              icon: Icons.access_time,
              label: 'Total Study Time',
              value: timeText,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.parchmentWhite.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              context: context,
              icon: Icons.school,
              label: 'Study Sessions',
              value: sessionsCount.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.parchmentWhite.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              context: context,
              icon: Icons.subject,
              label: 'Subjects',
              value: analytics.subjectBreakdown.length.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.parchmentWhite, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.parchmentWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.parchmentWhite.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSummaryLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.fadeGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
    );
  }

  Widget _buildSummaryErrorState(Object error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.compassRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.compassRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.compassRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load analytics',
                  style: TextStyle(
                    color: AppColors.compassRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pull to refresh to try again',
                  style: TextStyle(
                    color: AppColors.compassRed.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
