import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/models/study_plan_entry_model.dart';

/// Widget that displays overview statistics for a selected date.
class DailyStudyOverview extends StatelessWidget {
  /// The selected date to show overview for.
  final DateTime selectedDate;

  /// List of study plan entries for the selected date.
  final List<StudyPlanEntry> entries;

  /// Creates a [DailyStudyOverview].
  const DailyStudyOverview({
    super.key,
    required this.selectedDate,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStatsRow(stats),
          if (stats.totalPlannedMinutes > 0) ...[
            const SizedBox(height: 16),
            _buildProgressBar(stats),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final formatter = DateFormat('EEEE, MMMM d');
    final isToday = _isToday(selectedDate);

    return Row(
      children: [
        Icon(Icons.calendar_today, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isToday ? 'Today' : formatter.format(selectedDate),
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (entries.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow(_OverviewStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.schedule,
            label: 'Planned',
            value: _formatMinutes(stats.totalPlannedMinutes),
            color: AppColors.primaryColor,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle,
            label: 'Completed',
            value: '${stats.completedCount}/${stats.totalCount}',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.access_time,
            label: 'Time Done',
            value: _formatMinutes(stats.completedMinutes),
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProgressBar(_OverviewStats stats) {
    final completionPercentage =
        stats.totalCount > 0 ? (stats.completedCount / stats.totalCount) : 0.0;

    final timePercentage =
        stats.totalPlannedMinutes > 0
            ? (stats.completedMinutes / stats.totalPlannedMinutes).clamp(
              0.0,
              1.0,
            )
            : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(completionPercentage * 100).round()}% complete',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Completion progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completionPercentage,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                completionPercentage >= 1.0
                    ? Colors.green
                    : AppColors.primaryColor,
              ),
            ),
          ),
        ),

        // Time progress bar (if applicable)
        if (stats.totalPlannedMinutes > 0) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time Progress',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              Text(
                '${(timePercentage * 100).round()}% of planned time',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: timePercentage,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  timePercentage >= 1.0 ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  _OverviewStats _calculateStats() {
    final totalCount = entries.length;
    final completedCount = entries.where((e) => e.isCompleted).length;

    final totalPlannedMinutes = entries.fold<int>(
      0,
      (sum, entry) => sum + (entry.durationMinutes ?? 0),
    );

    final completedMinutes = entries
        .where((e) => e.isCompleted)
        .fold<int>(0, (sum, entry) => sum + (entry.durationMinutes ?? 0));

    return _OverviewStats(
      totalCount: totalCount,
      completedCount: completedCount,
      totalPlannedMinutes: totalPlannedMinutes,
      completedMinutes: completedMinutes,
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return '0m';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    } else if (remainingMinutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${remainingMinutes}m';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Internal class to hold overview statistics.
class _OverviewStats {
  final int totalCount;
  final int completedCount;
  final int totalPlannedMinutes;
  final int completedMinutes;

  const _OverviewStats({
    required this.totalCount,
    required this.completedCount,
    required this.totalPlannedMinutes,
    required this.completedMinutes,
  });
}
