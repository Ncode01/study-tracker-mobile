import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/providers/core_providers.dart';
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
  const WeeklyTrendBar({required this.day, required this.value});

  final String day;
  final double value;
}

class AnalyticsSession {
  const AnalyticsSession({
    required this.categoryId,
    required this.categoryTitle,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.isProductive,
  });

  final String categoryId;
  final String categoryTitle;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final bool isProductive;
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
    required this.sessions,
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
  final List<AnalyticsSession> sessions;
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
    List<AnalyticsSession>? sessions,
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
      sessions: sessions ?? this.sessions,
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
    _repository = AnalyticsRepository(database: ref.read(databaseProvider));
    const String defaultPeriod = 'This Week';
    final AnalyticsDataBundle bundle = await _repository.loadBundle(
      selectedPeriod: defaultPeriod,
      since: _sinceForPeriod(defaultPeriod),
    );

    final List<AnalyticsSession> sessions = bundle.sessions
        .map(_mapSession)
        .toList(growable: false);

    return AnalyticsViewState(
      periods: <String>['This Week', 'This Month', 'Term'],
      selectedPeriod: bundle.selectedPeriod,
      productivityScore: bundle.productivityScore,
      sessions: sessions,
      insights: _buildInsights(bundle: bundle, sessions: sessions),
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
      smartInsights: _buildSmartInsights(
        selectedPeriod: defaultPeriod,
        bundle: bundle,
        sessions: sessions,
      ),
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

    final List<AnalyticsSession> sessions = bundle.sessions
        .map(_mapSession)
        .toList(growable: false);

    state = AsyncData(
      current.copyWith(
        selectedPeriod: period,
        productivityScore: bundle.productivityScore,
        sessions: sessions,
        insights: _buildInsights(bundle: bundle, sessions: sessions),
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
        smartInsights: _buildSmartInsights(
          selectedPeriod: period,
          bundle: bundle,
          sessions: sessions,
        ),
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
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      _ => 'Sun',
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

  AnalyticsSession _mapSession(AnalyticsSessionEntry session) {
    return AnalyticsSession(
      categoryId: session.categoryId,
      categoryTitle: session.categoryTitle,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      durationSeconds: session.durationSeconds,
      isProductive: session.isProductive,
    );
  }

  List<AnalyticsInsight> _buildInsights({
    required AnalyticsDataBundle bundle,
    required List<AnalyticsSession> sessions,
  }) {
    final int totalTrackedSeconds = sessions.fold<int>(
      0,
      (int sum, AnalyticsSession session) => sum + session.durationSeconds,
    );

    final int productiveSeconds = sessions
        .where((AnalyticsSession session) => session.isProductive)
        .fold<int>(
          0,
          (int sum, AnalyticsSession session) => sum + session.durationSeconds,
        );
    final int driftSeconds = math.max(
      totalTrackedSeconds - productiveSeconds,
      0,
    );

    final double focusProgress =
        totalTrackedSeconds == 0 ? 0 : productiveSeconds / totalTrackedSeconds;
    final double driftProgress =
        totalTrackedSeconds == 0 ? 0 : driftSeconds / totalTrackedSeconds;

    final Map<String, int> productiveByCategorySeconds = <String, int>{};
    for (final AnalyticsSession session in sessions) {
      if (!session.isProductive) {
        continue;
      }
      productiveByCategorySeconds[session.categoryTitle] =
          (productiveByCategorySeconds[session.categoryTitle] ?? 0) +
          session.durationSeconds;
    }

    int topCategorySeconds = 0;
    String topCategoryTitle = 'No productive sessions yet';
    productiveByCategorySeconds.forEach((String title, int seconds) {
      if (seconds > topCategorySeconds) {
        topCategorySeconds = seconds;
        topCategoryTitle = title;
      }
    });

    final double dominantShare =
        productiveSeconds == 0 ? 1 : topCategorySeconds / productiveSeconds;
    final double balanceProgress =
        productiveByCategorySeconds.isEmpty
            ? 0
            : (1 - dominantShare).clamp(0.0, 1.0);

    final List<Color> fallbackColors = <Color>[
      const Color(0xFF3B82F6),
      const Color(0xFF22C55E),
      const Color(0xFF8554F8),
    ];

    final List<Color> palette = bundle.distribution
        .map((DistributionEntry entry) => entry.color)
        .toSet()
        .toList(growable: true);
    while (palette.length < 3) {
      palette.add(fallbackColors[palette.length]);
    }

    final String trackedLabel = _durationLabel(totalTrackedSeconds);
    final String productiveLabel = _durationLabel(productiveSeconds);
    final String driftLabel = _durationLabel(driftSeconds);

    final String balanceSubtitle;
    if (productiveByCategorySeconds.isEmpty) {
      balanceSubtitle = 'Add productive sessions to unlock subject balance.';
    } else {
      balanceSubtitle =
          '$topCategoryTitle currently leads ${_percentLabel(dominantShare)} of productive time.';
    }

    return <AnalyticsInsight>[
      AnalyticsInsight(
        title: 'Focus',
        subtitle: '$productiveLabel productive out of $trackedLabel tracked.',
        progress: focusProgress.clamp(0.0, 1.0),
        segments: <Color>[palette[0], palette[1], palette[2]],
      ),
      AnalyticsInsight(
        title: 'Drift',
        subtitle: '$driftLabel spent in break or idle blocks.',
        progress: driftProgress.clamp(0.0, 1.0),
        segments: <Color>[
          const Color(0xFFF43F5E),
          const Color(0xFF8554F8),
          palette[0],
        ],
      ),
      AnalyticsInsight(
        title: 'Balance',
        subtitle: balanceSubtitle,
        progress: balanceProgress,
        segments: <Color>[palette[1], palette[0], palette[2]],
      ),
    ];
  }

  List<SmartInsight> _buildSmartInsights({
    required String selectedPeriod,
    required AnalyticsDataBundle bundle,
    required List<AnalyticsSession> sessions,
  }) {
    final int totalTrackedSeconds = sessions.fold<int>(
      0,
      (int sum, AnalyticsSession session) => sum + session.durationSeconds,
    );
    final int productiveSeconds = sessions
        .where((AnalyticsSession session) => session.isProductive)
        .fold<int>(
          0,
          (int sum, AnalyticsSession session) => sum + session.durationSeconds,
        );
    final int driftSeconds = math.max(
      totalTrackedSeconds - productiveSeconds,
      0,
    );

    final double driftShare =
        totalTrackedSeconds == 0 ? 0 : driftSeconds / totalTrackedSeconds;

    final Map<String, int> productiveByCategory = <String, int>{};
    for (final AnalyticsSession session in sessions) {
      if (!session.isProductive) {
        continue;
      }
      productiveByCategory[session.categoryTitle] =
          (productiveByCategory[session.categoryTitle] ?? 0) +
          session.durationSeconds;
    }

    String topCategoryTitle = 'No focus channel yet';
    int topCategorySeconds = 0;
    productiveByCategory.forEach((String title, int seconds) {
      if (seconds > topCategorySeconds) {
        topCategoryTitle = title;
        topCategorySeconds = seconds;
      }
    });

    final String scheduleDriftDetail =
        '${_percentLabel(driftShare)} of tracked time was break/idle in ${selectedPeriod.toLowerCase()}.';
    final String focusChannelDetail =
        topCategorySeconds <= 0
            ? 'No productive sessions were logged in this period yet.'
            : '$topCategoryTitle leads with ${_durationLabel(topCategorySeconds)} productive time.';

    final List<SmartInsight> insights = <SmartInsight>[
      SmartInsight(
        title: 'Schedule Drift',
        detail: scheduleDriftDetail,
        accentColor: const Color(0xFFF43F5E),
        icon: Icons.trending_down_rounded,
      ),
      SmartInsight(
        title: 'Top Focus Channel',
        detail: focusChannelDetail,
        accentColor: const Color(0xFF3B82F6),
        icon: Icons.bolt_outlined,
      ),
    ];

    if (bundle.smartInsightDetails.isNotEmpty && sessions.isEmpty) {
      return <SmartInsight>[
        insights.first,
        SmartInsight(
          title: 'Top Focus Channel',
          detail: bundle.smartInsightDetails.last,
          accentColor: const Color(0xFF3B82F6),
          icon: Icons.bolt_outlined,
        ),
      ];
    }

    return insights;
  }

  String _durationLabel(int seconds) {
    if (seconds <= 0) {
      return '0m';
    }

    final Duration duration = Duration(seconds: seconds);
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

  String _percentLabel(double ratio) {
    final int percent = (ratio * 100).round().clamp(0, 100);
    return '$percent%';
  }
}
