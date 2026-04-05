import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../application/analytics_view_notifier.dart';
import '../providers/analytics_providers.dart';
import '../widgets/daily_truth_sheet.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late final PageController _insightController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _insightController = PageController(viewportFraction: 0.84);
  }

  @override
  void dispose() {
    _insightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AnalyticsViewState> asyncState =
        ref.watch(analyticsViewProvider);
    final AnalyticsViewNotifier notifier =
        ref.read(analyticsViewProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          asyncState.when(
            data: (AnalyticsViewState state) => SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.selectedPeriod,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF11131A),
                                borderRadius: BorderRadius.circular(18),
                                iconEnabledColor: AppColors.textMain,
                                items: [
                                  for (final String period in state.periods)
                                    DropdownMenuItem<String>(
                                      value: period,
                                      child: Text(
                                        period,
                                        style: AppTypography.display(
                                          color: AppColors.textMain,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                                onChanged: (String? value) {
                                  if (value != null) {
                                    unawaited(notifier.selectPeriod(value));
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassButton(
                          label: 'Daily Truth',
                          icon: Icons.auto_graph_rounded,
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const DailyTruthSheet(),
                            );
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassButton(
                          label: _isExporting ? 'Exporting...' : 'Export Data',
                          icon: Icons.ios_share_rounded,
                          onTap: _isExporting
                              ? () {}
                              : () => unawaited(_exportAnalytics()),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ],
                    ).animate().fade(duration: 400.ms).slideY(begin: 0.05),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: <Color>[
                                Color(0xFFFFFFFF),
                                Color(0xFF8554F8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds);
                          },
                          child: Text(
                            '${state.productivityScore}',
                            style: AppTypography.heading(
                              fontSize: 84,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 0.95,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                color: Color(0xFF22C55E),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Productivity Score',
                                style: AppTypography.display(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 192,
                      child: PageView.builder(
                        controller: _insightController,
                        itemCount: state.insights.length,
                        itemBuilder: (BuildContext context, int index) {
                          final AnalyticsInsight insight =
                              state.insights[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _InsightCard(insight: insight)
                                .animate(delay: (70 * index).ms)
                                .scaleXY(begin: 0.96),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassContainer(
                      borderRadius: BorderRadius.circular(28),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time Distribution',
                                style: AppTypography.heading(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                state.totalTrackedLabel,
                                style: AppTypography.display(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 66,
                                    sectionsSpace: 3,
                                    startDegreeOffset: -90,
                                    sections: [
                                      for (final DistributionSlice slice
                                          in state.distribution)
                                        PieChartSectionData(
                                          value: slice.value,
                                          color: slice.color,
                                          radius: 22,
                                          showTitle: false,
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(state.totalTrackedMinutes / 60).floor()}h ${(state.totalTrackedMinutes % 60).toString().padLeft(2, '0')}m',
                                      style: AppTypography.mono(
                                        color: AppColors.textMain,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tracked',
                                      style: AppTypography.display(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 14,
                            runSpacing: 10,
                            children: [
                              for (final DistributionSlice slice
                                  in state.distribution)
                                _LegendChip(slice: slice),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 380.ms).slideY(begin: 0.04),
                    const SizedBox(height: 18),
                    GlassContainer(
                      borderRadius: BorderRadius.circular(28),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Trend',
                            style: AppTypography.heading(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                maxY: 10,
                                alignment: BarChartAlignment.spaceAround,
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        final int index = value.toInt();
                                        if (index < 0 ||
                                            index >= state.weeklyTrend.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return SideTitleWidget(
                                          meta: meta,
                                          child: Text(
                                            state.weeklyTrend[index].day,
                                            style: AppTypography.display(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  for (int index = 0;
                                      index < state.weeklyTrend.length;
                                      index++)
                                    BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: state.weeklyTrend[index].value,
                                          width: 16,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: AppColors.primaryPurple,
                                          backDrawRodData:
                                              BackgroundBarChartRodData(
                                            show: true,
                                            toY: 10,
                                            color: AppColors.glassBorder,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (final SmartInsight insight in state.smartInsights)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SmartInsightCard(insight: insight),
                      ),
                  ],
                ),
              ),
            ),
            loading: () => const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stackTrace) => SafeArea(
              child: Center(
                child: Text(
                  'Unable to load analytics. $error',
                  style: AppTypography.display(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAnalytics() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final AnalyticsViewNotifier notifier =
          ref.read(analyticsViewProvider.notifier);
      final String filePath = await notifier.exportToTempCsv();

      await Share.shareXFiles(
        <XFile>[XFile(filePath)],
        text: 'TimeFlow analytics export',
        subject: 'Study tracker analytics CSV',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final AnalyticsInsight insight;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.08),
      borderColor: AppColors.primaryPurple.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                insight.title,
                style: AppTypography.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(insight.progress * 100).round()}%',
                style: AppTypography.mono(
                  color: AppColors.textMain,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.subtitle,
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: insight.progress,
              backgroundColor: AppColors.glassBorder,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final Color color in insight.segments)
                Expanded(
                  child: Container(
                    height: 12,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.slice});

  final DistributionSlice slice;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: slice.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${slice.label} ${slice.value.toStringAsFixed(0)}%',
          style: AppTypography.display(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SmartInsightCard extends StatelessWidget {
  const _SmartInsightCard({required this.insight});

  final SmartInsight insight;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(16),
      backgroundColor: insight.accentColor.withValues(alpha: 0.06),
      borderColor: insight.accentColor.withValues(alpha: 0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: insight.accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(insight.icon, color: insight.accentColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      insight.title,
                      style: AppTypography.display(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  insight.detail,
                  style: AppTypography.display(
                    color: AppColors.textMuted,
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
