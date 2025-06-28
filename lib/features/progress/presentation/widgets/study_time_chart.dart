import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/models/study_analytics.dart';
import '../../providers/analytics_providers.dart';

/// Chart widget displaying study time over time
class StudyTimeChart extends ConsumerWidget {
  const StudyTimeChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(currentAnalyticsProvider);

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
                  Icons.trending_up,
                  color: AppColors.primaryBrown,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Study Time Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Caveat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: analyticsAsync.when(
                data: (analytics) => _buildChart(context, analytics),
                loading: () => _buildLoadingSkeleton(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, StudyAnalytics analytics) {
    if (analytics.dailyData.isEmpty) {
      return _buildEmptyState();
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < analytics.dailyData.length; i++) {
      final data = analytics.dailyData[i];
      final minutes = data.studyTime.inMinutes.toDouble();
      spots.add(FlSpot(i.toDouble(), minutes));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 30,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.fadeGray.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}m',
                  style: TextStyle(color: AppColors.fadeGray, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < analytics.dailyData.length) {
                  final date = analytics.dailyData[index].date;
                  final day = date.day.toString();
                  return Text(
                    day,
                    style: TextStyle(color: AppColors.fadeGray, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.fadeGray.withOpacity(0.3)),
            left: BorderSide(color: AppColors.fadeGray.withOpacity(0.3)),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryGold,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryGold,
                    strokeWidth: 2,
                    strokeColor: AppColors.parchmentWhite,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryGold.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY:
            spots.isNotEmpty
                ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2
                : 100,
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fadeGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGold,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.compassRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.compassRed.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.compassRed, size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load chart',
              style: TextStyle(color: AppColors.compassRed, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fadeGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              color: AppColors.fadeGray,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No study data available',
              style: TextStyle(color: AppColors.fadeGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
