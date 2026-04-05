import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/data/local/app_database.dart';
import '../domain/repositories/analytics_repository.dart';

class AnalyticsInsight {
  const AnalyticsInsight({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.segments,
  });

  final String title;
  final String subtitle;
  final double progress;
  final List<Color> segments;
}

class DistributionSlice {
  const DistributionSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class WeeklyTrendBar {
  const WeeklyTrendBar({
    required this.day,
    required this.value,
  });

  final String day;
  final double value;
}

class SmartInsight {
  const SmartInsight({
    required this.title,
    required this.detail,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final String detail;
  final Color accentColor;
  final IconData icon;
}

class AnalyticsViewState {
  const AnalyticsViewState({
    required this.periods,
    required this.selectedPeriod,
    required this.productivityScore,
    required this.insights,
    required this.distribution,
    required this.weeklyTrend,
    required this.smartInsights,
    required this.totalTrackedLabel,
    required this.totalTrackedMinutes,
  });

  final List<String> periods;
  final String selectedPeriod;
  final int productivityScore;
  final List<AnalyticsInsight> insights;
  final List<DistributionSlice> distribution;
  final List<WeeklyTrendBar> weeklyTrend;
  final List<SmartInsight> smartInsights;
  final String totalTrackedLabel;
  final int totalTrackedMinutes;

  AnalyticsViewState copyWith({
    List<String>? periods,
    String? selectedPeriod,
    int? productivityScore,
    List<AnalyticsInsight>? insights,
    List<DistributionSlice>? distribution,
    List<WeeklyTrendBar>? weeklyTrend,
    List<SmartInsight>? smartInsights,
    String? totalTrackedLabel,
    int? totalTrackedMinutes,
  }) {
    return AnalyticsViewState(
      periods: periods ?? this.periods,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      productivityScore: productivityScore ?? this.productivityScore,
      insights: insights ?? this.insights,
      distribution: distribution ?? this.distribution,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      smartInsights: smartInsights ?? this.smartInsights,
      totalTrackedLabel: totalTrackedLabel ?? this.totalTrackedLabel,
      totalTrackedMinutes: totalTrackedMinutes ?? this.totalTrackedMinutes,
    );
  }
}

class AnalyticsViewNotifier extends AsyncNotifier<AnalyticsViewState> {
  late final AnalyticsRepository _repository;

  @override
  Future<AnalyticsViewState> build() async {
    _repository = AnalyticsRepository(database: AppDatabase.instance);
    const String defaultPeriod = 'This Week';
    final AnalyticsDataBundle bundle = await _repository.loadBundle(
      selectedPeriod: defaultPeriod,
      since: _sinceForPeriod(defaultPeriod),
    );

    return AnalyticsViewState(
      periods: <String>['This Week', 'This Month', 'Term'],
      selectedPeriod: bundle.selectedPeriod,
      productivityScore: bundle.productivityScore,
      insights: const <AnalyticsInsight>[
        AnalyticsInsight(
          title: 'Focus',
          subtitle: 'Recent productive streaks are compounding well.',
          progress: 0.84,
          segments: <Color>[
            Color(0xFF3B82F6),
            Color(0xFF22C55E),
            Color(0xFFF59E0B),
          ],
        ),
        AnalyticsInsight(
          title: 'Drift',
          subtitle: 'Context switching still consumes key minutes.',
          progress: 0.42,
          segments: <Color>[
            Color(0xFFF43F5E),
            Color(0xFF8554F8),
            Color(0xFF3B82F6),
          ],
        ),
        AnalyticsInsight(
          title: 'Balance',
          subtitle: 'Subject spread remains mostly healthy this week.',
          progress: 0.69,
          segments: <Color>[
            Color(0xFF22C55E),
            Color(0xFF3B82F6),
            Color(0xFF8554F8),
          ],
        ),
      ],
      distribution: bundle.distribution
          .map(
            (DistributionEntry entry) => DistributionSlice(
              label: entry.label,
              value: entry.value,
              color: entry.color,
            ),
          )
          .toList(growable: false),
      weeklyTrend: bundle.daily
          .map(
            (stat) => WeeklyTrendBar(
              day: _weekdayLabel(stat.day.weekday),
              value: stat.totalMinutes / 60,
            ),
          )
          .toList(growable: false),
      smartInsights: <SmartInsight>[
        SmartInsight(
          title: 'Schedule Drift',
          detail: bundle.smartInsightDetails.first,
          accentColor: const Color(0xFFF43F5E),
          icon: Icons.trending_down_rounded,
        ),
        SmartInsight(
          title: 'Physics Focus',
          detail: bundle.smartInsightDetails.last,
          accentColor: const Color(0xFF3B82F6),
          icon: Icons.bolt_outlined,
        ),
      ],
      totalTrackedLabel: _trackedLabelForPeriod(defaultPeriod),
      totalTrackedMinutes: bundle.totalTrackedMinutes,
    );
  }

  Future<void> selectPeriod(String period) async {
    final AnalyticsViewState? current = state.valueOrNull;
    if (current == null || period == current.selectedPeriod) {
      return;
    }

    state = const AsyncLoading<AnalyticsViewState>().copyWithPrevious(state);
    final AnalyticsDataBundle bundle = await _repository.loadBundle(
      selectedPeriod: period,
      since: _sinceForPeriod(period),
    );

    state = AsyncData(
      current.copyWith(
        selectedPeriod: period,
        productivityScore: bundle.productivityScore,
        distribution: bundle.distribution
            .map(
              (DistributionEntry entry) => DistributionSlice(
                label: entry.label,
                value: entry.value,
                color: entry.color,
              ),
            )
            .toList(growable: false),
        weeklyTrend: bundle.daily
            .map(
              (stat) => WeeklyTrendBar(
                day: _weekdayLabel(stat.day.weekday),
                value: stat.totalMinutes / 60,
              ),
            )
            .toList(growable: false),
        smartInsights: <SmartInsight>[
          SmartInsight(
            title: 'Schedule Drift',
            detail: bundle.smartInsightDetails.first,
            accentColor: const Color(0xFFF43F5E),
            icon: Icons.trending_down_rounded,
          ),
          SmartInsight(
            title: 'Physics Focus',
            detail: bundle.smartInsightDetails.last,
            accentColor: const Color(0xFF3B82F6),
            icon: Icons.bolt_outlined,
          ),
        ],
        totalTrackedLabel: _trackedLabelForPeriod(period),
        totalTrackedMinutes: bundle.totalTrackedMinutes,
      ),
    );
  }

  Future<String> exportToTempCsv() async {
    final String csv = await _repository.exportSessionsCsv();
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = p.join(
      tempDir.path,
      'timeflow-analytics-${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    final File file = File(filePath);
    await file.writeAsString(csv, flush: true);
    return file.path;
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'M',
      DateTime.tuesday => 'T',
      DateTime.wednesday => 'W',
      DateTime.thursday => 'T',
      DateTime.friday => 'F',
      DateTime.saturday => 'S',
      _ => 'S',
    };
  }

  DateTime? _sinceForPeriod(String period) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return switch (period) {
      'This Week' => today.subtract(const Duration(days: 6)),
      'This Month' => DateTime(now.year, now.month, 1),
      'Term' => _termStartFor(now),
      _ => null,
    };
  }

  DateTime _termStartFor(DateTime now) {
    if (now.month >= 9) {
      return DateTime(now.year, 9, 1);
    }
    if (now.month >= 4) {
      return DateTime(now.year, 4, 1);
    }
    return DateTime(now.year, 1, 1);
  }

  String _trackedLabelForPeriod(String period) {
    return switch (period) {
      'This Week' => 'Tracked this week',
      'This Month' => 'Tracked this month',
      'Term' => 'Tracked this term',
      _ => 'Tracked',
    };
  }
}
