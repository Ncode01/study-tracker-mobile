import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/analytics_view_notifier.dart';
import '../providers/analytics_providers.dart';

class DailyTruthSheet extends ConsumerWidget {
  const DailyTruthSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnalyticsViewState state = ref.watch(analyticsViewProvider).maybeWhen(
          data: (AnalyticsViewState state) => state,
          orElse: () => const AnalyticsViewState(
            periods: <String>['This Week', 'This Month', 'Term'],
            selectedPeriod: 'This Week',
            productivityScore: 0,
            insights: <AnalyticsInsight>[],
            distribution: <DistributionSlice>[],
            weeklyTrend: <WeeklyTrendBar>[],
            smartInsights: <SmartInsight>[],
            totalTrackedLabel: 'Tracked',
            totalTrackedMinutes: 0,
          ),
        );

    final List<_TruthBlock> planned = <_TruthBlock>[
      const _TruthBlock('Physics', '08:00', 0.22),
      const _TruthBlock('Maths', '10:15', 0.48),
      const _TruthBlock('Chem', '13:00', 0.66),
      const _TruthBlock('Break', '15:00', 0.84),
    ];
    final List<_TruthBlock> actual = <_TruthBlock>[
      const _TruthBlock('Physics', '08:10', 0.18),
      const _TruthBlock('Maths', '10:45', 0.54),
      const _TruthBlock('Chem', '13:28', 0.74),
      const _TruthBlock('Idle', '15:26', 0.91),
    ];

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.28)),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(32),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Daily Truth',
                                style: AppTypography.heading(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            GlassButton(
                              label: 'Close',
                              icon: Icons.close_rounded,
                              onTap: () => Navigator.of(context).pop(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Total Idle Time',
                                value: '2h 14m',
                                accentColor: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                title: 'Time Drift',
                                value: '24m',
                                accentColor: AppColors.accentMaths,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Intent vs Reality',
                          style: AppTypography.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 320,
                          child:
                              _DriftTimeline(planned: planned, actual: actual),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Top Time Sinks',
                          style: AppTypography.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (int index = 0;
                            index < state.smartInsights.length;
                            index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SinkRow(
                              index: index + 1,
                              title: state.smartInsights[index].title,
                              detail: state.smartInsights[index].detail,
                              accentColor:
                                  state.smartInsights[index].accentColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.accentColor,
  });

  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(14),
      backgroundColor: accentColor.withValues(alpha: 0.07),
      borderColor: accentColor.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.mono(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TruthBlock {
  const _TruthBlock(this.title, this.timeLabel, this.yFactor);

  final String title;
  final String timeLabel;
  final double yFactor;
}

class _DriftTimeline extends StatelessWidget {
  const _DriftTimeline({required this.planned, required this.actual});

  final List<_TruthBlock> planned;
  final List<_TruthBlock> actual;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DriftPainter(
                  planned: planned,
                  actual: actual,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _TimelineHeader(
                          label: 'Planned',
                          accentColor: AppColors.primaryPurple),
                      const SizedBox(height: 10),
                      for (final _TruthBlock block in planned)
                        _TimelineBlock(
                          title: block.title,
                          timeLabel: block.timeLabel,
                          accentColor: AppColors.primaryPurple,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _TimelineHeader(
                          label: 'Actual', accentColor: AppColors.accentMaths),
                      const SizedBox(height: 10),
                      for (final _TruthBlock block in actual)
                        _TimelineBlock(
                          title: block.title,
                          timeLabel: block.timeLabel,
                          accentColor: AppColors.accentMaths,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.display(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _TimelineBlock extends StatelessWidget {
  const _TimelineBlock({
    required this.title,
    required this.timeLabel,
    required this.accentColor,
  });

  final String title;
  final String timeLabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.all(12),
        backgroundColor: accentColor.withValues(alpha: 0.08),
        borderColor: accentColor.withValues(alpha: 0.24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.display(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: AppTypography.display(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriftPainter extends CustomPainter {
  const _DriftPainter({
    required this.planned,
    required this.actual,
    required this.width,
    required this.height,
  });

  final List<_TruthBlock> planned;
  final List<_TruthBlock> actual;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = AppColors.accentMaths.withValues(alpha: 0.42);

    final double columnWidth = width / 2;
    final double blockGap =
        (height - 72) / math.max(planned.length, actual.length);

    for (int index = 0;
        index < math.min(planned.length, actual.length);
        index++) {
      final double startY = 56 + index * blockGap + 18;
      final double endY = 56 + index * blockGap + 30;
      final Path path = Path()
        ..moveTo(columnWidth - 18, startY)
        ..lineTo(columnWidth - 2, startY + 10)
        ..lineTo(columnWidth + 2, endY - 6)
        ..lineTo(columnWidth + 18, endY);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DriftPainter oldDelegate) {
    return oldDelegate.planned != planned ||
        oldDelegate.actual != actual ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}

class _SinkRow extends StatelessWidget {
  const _SinkRow({
    required this.index,
    required this.title,
    required this.detail,
    required this.accentColor,
  });

  final int index;
  final String title;
  final String detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: accentColor.withValues(alpha: 0.06),
      borderColor: accentColor.withValues(alpha: 0.2),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: accentColor.withValues(alpha: 0.16),
            child: Text(
              '$index',
              style: AppTypography.mono(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.display(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: AppTypography.display(
                    color: AppColors.textMuted,
                    fontSize: 11,
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
