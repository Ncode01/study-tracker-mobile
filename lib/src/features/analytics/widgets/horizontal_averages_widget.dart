import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_averages.dart';
import '../providers/analytics_provider.dart';
import '../../../constants/app_colors.dart';
import '../screens/detailed_analytics_screen.dart';

class HorizontalAveragesWidget extends StatelessWidget {
  const HorizontalAveragesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        final averages = analyticsProvider.studyAverages;
        if (analyticsProvider.isLoading) {
          return SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
          );
        }
        if (averages == null) {
          return SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'No study data yet.',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        final data = [
          {
            'title': 'Weekly',
            'icon': Icons.date_range_outlined,
            'color': AppColors.primaryColor,
            'average': averages.weekly,
            'period': 'week',
          },
          {
            'title': 'Monthly',
            'icon': Icons.calendar_month_outlined,
            'color': AppColors.accentColor,
            'average': averages.monthly,
            'period': 'month',
          },
          {
            'title': 'Termly',
            'icon': Icons.school_outlined,
            'color': Colors.orangeAccent,
            'average': averages.termly,
            'period': 'term',
          },
        ];
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];
              final PeriodAverage avg = item['average'] as PeriodAverage;
              final Color cardColor = item['color'] as Color;

              return Container(
                width: 200,
                margin: EdgeInsets.only(
                  left: i == 0 ? 16 : 8,
                  right: i == data.length - 1 ? 16 : 8,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DetailedAnalyticsScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cardColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cardColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: cardColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: cardColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item['title']} Avg',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          color: AppColors.textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Tap for details',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: AppColors.secondaryTextColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.secondaryTextColor,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${avg.totalHoursFormatted}h',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color: cardColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${avg.targetHoursFormatted}h goal',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: cardColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
