import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fading_skeleton.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/analytics_view_notifier.dart';
import '../providers/analytics_providers.dart';

class DailyTruthSheet extends ConsumerWidget {
  const DailyTruthSheet({super.key});

  static const int _secondsPerDay = 24 * 60 * 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AnalyticsViewState> asyncState = ref.watch(
      analyticsViewProvider,
    );
    final AnalyticsViewState? loadedState = asyncState.valueOrNull;
    final bool isLoading = asyncState.isLoading && loadedState == null;
    final bool hasBlockingError = asyncState.hasError && loadedState == null;

    final List<AnalyticsSession> sessions =
        loadedState?.sessions ?? const <AnalyticsSession>[];

    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = startOfToday.add(const Duration(days: 1));

    final List<AnalyticsSession> todaySessions = sessions
      .where(
        (AnalyticsSession session) =>
            !session.startedAt.isBefore(startOfToday) &&
            session.startedAt.isBefore(endOfToday),
      )
      .toList(growable: false)..sort(
      (AnalyticsSession a, AnalyticsSession b) =>
          a.startedAt.compareTo(b.startedAt),
    );

    final int loggedSeconds = todaySessions.fold<int>(
      0,
      (int sum, AnalyticsSession session) => sum + session.durationSeconds,
    );
    final int inferredIdleSeconds = math.max(_secondsPerDay - loggedSeconds, 0);
    final int productiveSeconds = todaySessions
        .where((AnalyticsSession session) => !_isIdleOrBreak(session))
        .fold<int>(0, (int sum, AnalyticsSession s) => sum + s.durationSeconds);

    final int totalIdleSeconds =
        todaySessions
            .where((AnalyticsSession session) => _isIdleOrBreak(session))
            .fold<int>(
              0,
              (int sum, AnalyticsSession s) => sum + s.durationSeconds,
            ) +
        inferredIdleSeconds;

    final _TimelineData timeline = _buildTimelineData(todaySessions);
    final List<_SinkStat> topSinks = _buildTopSinks(
      sessions: todaySessions,
      inferredIdleSeconds: inferredIdleSeconds,
    );

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
                        if (isLoading)
                          const _DailyTruthLoadingContent()
                        else if (hasBlockingError)
                          _DailyTruthErrorContent(
                            onRetry:
                                () => ref.invalidate(analyticsViewProvider),
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  title: 'Total Idle Time',
                                  value: _formatDuration(totalIdleSeconds),
                                  accentColor: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  title: 'Productive Time',
                                  value: _formatDuration(productiveSeconds),
                                  accentColor: AppColors.primaryPurple,
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
                            child: _DriftTimeline(
                              planned: timeline.planned,
                              actual: timeline.actual,
                              hasData: todaySessions.isNotEmpty,
                            ),
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
                          if (topSinks.isEmpty)
                            GlassContainer(
                              borderRadius: BorderRadius.circular(20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Text(
                                'No sessions recorded today yet.',
                                style: AppTypography.display(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          else
                            for (
                              int index = 0;
                              index < topSinks.length;
                              index++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _SinkRow(
                                  index: index + 1,
                                  title: topSinks[index].title,
                                  detail: topSinks[index].detail,
                                  accentColor: topSinks[index].accentColor,
                                ),
                              ),
                        ],
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

  bool _isIdleOrBreak(AnalyticsSession session) {
    final String id = session.categoryId.toLowerCase();
    final String title = session.categoryTitle.toLowerCase();
    return id == 'break' ||
        id == 'idle' ||
        id == 'sleep' ||
        title == 'break' ||
        title == 'idle' ||
        title == 'sleep';
  }

  _TimelineData _buildTimelineData(List<AnalyticsSession> sessions) {
    final List<AnalyticsSession> productiveSessions = sessions
      .where((AnalyticsSession session) => !_isIdleOrBreak(session))
      .toList(growable: false)..sort(
      (AnalyticsSession a, AnalyticsSession b) =>
          a.startedAt.compareTo(b.startedAt),
    );

    final List<_TruthBlock> actual = sessions
        .map(
          (AnalyticsSession session) => _TruthBlock(
            title: session.categoryTitle,
            timeLabel: _clockLabel(session.startedAt),
          ),
        )
        .toList(growable: false);

    if (productiveSessions.isEmpty) {
      return _TimelineData(
        planned: const <_TruthBlock>[],
        actual: actual,
        driftSeconds: 0,
      );
    }

    final List<_TruthBlock> planned = <_TruthBlock>[];
    final List<DateTime> plannedStarts = <DateTime>[];

    DateTime cursor = productiveSessions.first.startedAt;
    for (final AnalyticsSession session in productiveSessions) {
      plannedStarts.add(cursor);
      planned.add(
        _TruthBlock(
          title: session.categoryTitle,
          timeLabel: _clockLabel(cursor),
        ),
      );
      cursor = cursor.add(Duration(seconds: session.durationSeconds));
    }

    int driftSeconds = 0;
    for (int i = 0; i < productiveSessions.length; i++) {
      driftSeconds +=
          productiveSessions[i].startedAt
              .difference(plannedStarts[i])
              .inSeconds
              .abs();
    }

    return _TimelineData(
      planned: planned,
      actual: actual,
      driftSeconds: driftSeconds,
    );
  }

  List<_SinkStat> _buildTopSinks({
    required List<AnalyticsSession> sessions,
    required int inferredIdleSeconds,
  }) {
    final Map<String, int> sinkSeconds = <String, int>{};

    for (final AnalyticsSession session in sessions) {
      if (!_isIdleOrBreak(session)) {
        continue;
      }
      sinkSeconds[session.categoryTitle] =
          (sinkSeconds[session.categoryTitle] ?? 0) + session.durationSeconds;
    }

    if (inferredIdleSeconds > 0) {
      sinkSeconds['Idle (Untracked)'] =
          (sinkSeconds['Idle (Untracked)'] ?? 0) + inferredIdleSeconds;
    }

    if (sinkSeconds.isEmpty) {
      for (final AnalyticsSession session in sessions) {
        sinkSeconds[session.categoryTitle] =
            (sinkSeconds[session.categoryTitle] ?? 0) + session.durationSeconds;
      }
    }

    final List<MapEntry<String, int>> sorted = sinkSeconds.entries.toList(
      growable: false,
    )..sort(
      (MapEntry<String, int> a, MapEntry<String, int> b) =>
          b.value.compareTo(a.value),
    );

    return sorted
        .take(3)
        .map((MapEntry<String, int> entry) {
          final String key = entry.key.toLowerCase();
          final bool idleLike =
              key == 'break' ||
              key == 'idle' ||
              key == 'sleep' ||
              key.contains('idle');
          final Color accent =
              idleLike ? AppColors.accentMaths : AppColors.primaryPurple;
          return _SinkStat(
            title: entry.key,
            detail: '${_formatDuration(entry.value)} today',
            accentColor: accent,
          );
        })
        .toList(growable: false);
  }

  static String _clockLabel(DateTime time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatDuration(int durationSeconds) {
    if (durationSeconds <= 0) {
      return '0m';
    }

    final Duration duration = Duration(seconds: durationSeconds);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
}

class _DailyTruthLoadingContent extends StatelessWidget {
  const _DailyTruthLoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: FadingSkeletonBlock(height: 96, borderRadius: 22)),
            SizedBox(width: 12),
            Expanded(child: FadingSkeletonBlock(height: 96, borderRadius: 22)),
          ],
        ),
        SizedBox(height: 18),
        FadingSkeletonBlock(width: 170, height: 28, borderRadius: 10),
        SizedBox(height: 12),
        FadingSkeletonBlock(height: 320, borderRadius: 22),
        SizedBox(height: 18),
        FadingSkeletonBlock(width: 160, height: 28, borderRadius: 10),
        SizedBox(height: 12),
        FadingSkeletonBlock(height: 76, borderRadius: 20),
        SizedBox(height: 10),
        FadingSkeletonBlock(height: 76, borderRadius: 20),
      ],
    );
  }
}

class _DailyTruthErrorContent extends StatelessWidget {
  const _DailyTruthErrorContent({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load daily truth',
            style: AppTypography.heading(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily analytics could not be fetched right now. Retry to refresh this report.',
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          GlassButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            onTap: onRetry,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ],
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

class _TimelineData {
  const _TimelineData({
    required this.planned,
    required this.actual,
    required this.driftSeconds,
  });

  final List<_TruthBlock> planned;
  final List<_TruthBlock> actual;
  final int driftSeconds;
}

class _TruthBlock {
  const _TruthBlock({required this.title, required this.timeLabel});

  final String title;
  final String timeLabel;
}

class _DriftTimeline extends StatelessWidget {
  const _DriftTimeline({
    required this.planned,
    required this.actual,
    required this.hasData,
  });

  final List<_TruthBlock> planned;
  final List<_TruthBlock> actual;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      return GlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Center(
          child: Text(
            'No timeline data for today yet.',
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DriftPainter(planned: planned, actual: actual),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const _TimelineHeader(
                        label: 'Planned',
                        accentColor: AppColors.primaryPurple,
                      ),
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
                      const _TimelineHeader(
                        label: 'Actual',
                        accentColor: AppColors.accentMaths,
                      ),
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
          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
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
  const _DriftPainter({required this.planned, required this.actual});

  final List<_TruthBlock> planned;
  final List<_TruthBlock> actual;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..color = AppColors.accentMaths.withValues(alpha: 0.42);

    final double columnWidth = size.width / 2;
    final int segmentCount = math.max(
      math.min(planned.length, actual.length),
      1,
    );
    final double blockGap = (size.height - 72) / segmentCount;

    for (
      int index = 0;
      index < math.min(planned.length, actual.length);
      index++
    ) {
      final double startY = 56 + index * blockGap + 18;
      final double endY = 56 + index * blockGap + 30;
      final Path path =
          Path()
            ..moveTo(columnWidth - 18, startY)
            ..lineTo(columnWidth - 2, startY + 10)
            ..lineTo(columnWidth + 2, endY - 6)
            ..lineTo(columnWidth + 18, endY);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DriftPainter oldDelegate) {
    return oldDelegate.planned != planned || oldDelegate.actual != actual;
  }
}

class _SinkStat {
  const _SinkStat({
    required this.title,
    required this.detail,
    required this.accentColor,
  });

  final String title;
  final String detail;
  final Color accentColor;
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
