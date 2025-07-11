import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/models/study_analytics.dart';
import '../../providers/analytics_providers.dart';
import '../../../../widgets/shared_loading_error.dart';

/// Widget displaying subject breakdown with donut chart and list
class SubjectBreakdownWidget extends ConsumerWidget {
  const SubjectBreakdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(selectedTimeRangeProvider);
    final subjectAnalyticsAsync = ref.watch(
      subjectAnalyticsProvider(timeRange),
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
                Icon(Icons.pie_chart, color: AppColors.primaryBrown, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Subject Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Caveat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            subjectAnalyticsAsync.when(
              data: (subjects) => _buildContent(context, subjects),
              loading:
                  () =>
                      const SharedLoadingSkeleton(itemCount: 3, itemHeight: 60),
              error: (error, stack) => SharedErrorState(error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SubjectAnalytics> subjects) {
    if (subjects.isEmpty) {
      return _buildEmptyState();
    }

    final totalMinutes = subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.totalTime.inMinutes,
    );

    if (totalMinutes == 0) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            children: [
              // Donut Chart
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: _buildPieChartSections(subjects, totalMinutes),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Legend
              Expanded(flex: 3, child: _buildLegend(subjects)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Subject List
        _buildSubjectList(context, subjects),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<SubjectAnalytics> subjects,
    int totalMinutes,
  ) {
    final colors = [
      AppColors.primaryGold,
      AppColors.treasureGreen,
      AppColors.skyBlue,
      AppColors.compassRed,
      AppColors.primaryBrown,
    ];

    return subjects.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final subject = entry.value;
      final percentage = (subject.totalTime.inMinutes / totalMinutes) * 100;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: subject.totalTime.inMinutes.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 25,
        titleStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.parchmentWhite,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<SubjectAnalytics> subjects) {
    final colors = [
      AppColors.primaryGold,
      AppColors.treasureGreen,
      AppColors.skyBlue,
      AppColors.compassRed,
      AppColors.primaryBrown,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          subjects.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final subject = entry.value;
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subject.subjectName,
                      style: const TextStyle(
                        color: AppColors.inkBlack,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSubjectList(
    BuildContext context,
    List<SubjectAnalytics> subjects,
  ) {
    return Column(
      children:
          subjects.map((subject) {
            final hours = subject.totalTime.inHours;
            final minutes = subject.totalTime.inMinutes % 60;
            final timeText =
                hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.fadeGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.subjectName,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${subject.sessionsCompleted} sessions • Avg: ${subject.averageSessionDuration.toStringAsFixed(0)}min',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.fadeGray),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildTrendIndicator(subject.trend),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTrendIndicator(StudyTrend trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case StudyTrend.increasing:
        icon = Icons.trending_up;
        color = AppColors.treasureGreen;
        break;
      case StudyTrend.decreasing:
        icon = Icons.trending_down;
        color = AppColors.compassRed;
        break;
      case StudyTrend.stable:
        icon = Icons.trending_flat;
        color = AppColors.fadeGray;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          trend.displayName,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.fadeGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subject, color: AppColors.fadeGray, size: 32),
            const SizedBox(height: 8),
            Text(
              'No subject data available',
              style: TextStyle(color: AppColors.fadeGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
