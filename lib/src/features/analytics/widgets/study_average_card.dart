import 'package:flutter/material.dart';
import '../models/study_averages.dart';

class StudyAverageCard extends StatelessWidget {
  final String title;
  final PeriodAverage average;
  final IconData icon;
  final Color primaryColor;

  const StudyAverageCard({
    super.key,
    required this.title,
    required this.average,
    required this.icon,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showDetailedView(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(icon, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(context),
                ],
              ),

              const SizedBox(height: 16),

              // Main metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricColumn(
                      context,
                      'Average',
                      '${average.averageHoursFormatted}h',
                      'per active day',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricColumn(
                      context,
                      'Total',
                      '${average.totalHoursFormatted}h',
                      'in period',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricColumn(
                      context,
                      'Target',
                      '${average.targetHoursFormatted}h',
                      'goal',
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
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        average.progressPercentageFormatted,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getProgressColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (average.progressPercentage / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(),
                    ),
                    minHeight: 8,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Additional stats
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.event_note,
                    '${average.sessionCount} sessions',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.calendar_today,
                    '${average.activeDays} active days',
                  ),
                  const SizedBox(width: 8),
                  if (average.streak > 0)
                    _buildStatChip(
                      context,
                      Icons.local_fire_department,
                      '${average.streak} day streak',
                      color: Colors.orange,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getProgressColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getProgressColor().withOpacity(0.3)),
      ),
      child: Text(
        average.statusText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _getProgressColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context,
    String label,
    String value,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey[600]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (average.isExceeding) return Colors.green;
    if (average.isOnTrack) return Colors.blue;
    if (average.needsImprovement) return Colors.red;
    return Colors.orange;
  }

  void _showDetailedView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Row(
                        children: [
                          Icon(icon, color: primaryColor, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            '$title Details',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Detailed metrics
                      _buildDetailRow(
                        context,
                        'Average Study Time',
                        '${average.averageHoursFormatted} hours per active day',
                      ),
                      _buildDetailRow(
                        context,
                        'Total Study Time',
                        '${average.totalHoursFormatted} hours in period',
                      ),
                      _buildDetailRow(
                        context,
                        'Target Hours',
                        '${average.targetHoursFormatted} hours goal',
                      ),
                      _buildDetailRow(
                        context,
                        'Progress',
                        '${average.progressPercentageFormatted} of target',
                      ),
                      _buildDetailRow(
                        context,
                        'Study Sessions',
                        '${average.sessionCount} sessions completed',
                      ),
                      _buildDetailRow(
                        context,
                        'Active Days',
                        '${average.activeDays} days with study sessions',
                      ),
                      if (average.streak > 0)
                        _buildDetailRow(
                          context,
                          'Current Streak',
                          '${average.streak} consecutive days',
                        ),

                      const SizedBox(height: 24),

                      // Status summary
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getProgressColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getProgressColor().withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getStatusIcon(),
                              size: 48,
                              color: _getProgressColor(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              average.statusText,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getProgressColor(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getStatusDescription(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (average.isExceeding) return Icons.trending_up;
    if (average.isOnTrack) return Icons.check_circle;
    if (average.needsImprovement) return Icons.trending_down;
    return Icons.warning;
  }

  String _getStatusDescription() {
    if (average.isExceeding) {
      return 'Excellent work! You\'re exceeding your study targets.';
    }
    if (average.isOnTrack) {
      return 'Great job! You\'re on track with your study goals.';
    }
    if (average.needsImprovement) {
      return 'You\'re falling behind your targets. Consider adjusting your study schedule.';
    }
    return 'You\'re below your target but making progress. Keep it up!';
  }
}
