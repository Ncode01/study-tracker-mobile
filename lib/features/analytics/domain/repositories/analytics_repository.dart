import 'package:flutter/material.dart';

import '../../../../core/data/local/app_database.dart';
import '../models/daily_study_stat.dart';

class AnalyticsRepository {
  AnalyticsRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<AnalyticsDataBundle> loadBundle({
    required String selectedPeriod,
    DateTime? since,
  }) async {
    final db = await _database.database;
    final String? sinceIso = since?.toIso8601String();

    final String whereClause = sinceIso == null ? '' : 'WHERE s.endedAt >= ?';
    final List<Object?> whereArgs =
        sinceIso == null ? const <Object?>[] : <Object?>[sinceIso];

    final List<Map<String, Object?>> sessionRows = await db.rawQuery('''
      SELECT
        s.categoryId,
        COALESCE(c.title, s.categoryId) AS categoryTitle,
        s.startedAt,
        s.endedAt,
        s.durationSeconds,
        s.isProductive
      FROM sessions s
      LEFT JOIN categories c ON c.id = s.categoryId
      $whereClause
      ORDER BY s.startedAt ASC
      ''', whereArgs);

    final List<Map<String, Object?>> dailyRows = await db.rawQuery('''
      SELECT
        DATE(s.endedAt) AS dayKey,
        SUM(s.durationSeconds) AS totalSeconds,
        SUM(
          CASE
            WHEN LOWER(COALESCE(c.title, s.categoryId)) IN ('break', 'idle')
              OR LOWER(s.categoryId) IN ('break', 'idle')
            THEN 0
            ELSE s.durationSeconds
          END
        ) AS productiveSeconds
      FROM sessions s
      LEFT JOIN categories c ON c.id = s.categoryId
      $whereClause
      GROUP BY DATE(s.endedAt)
      ORDER BY DATE(s.endedAt) ASC
      ''', whereArgs);

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    int totalSeconds = 0;
    int productiveSeconds = 0;

    final Map<String, int> byDayTotalSeconds = <String, int>{};
    final Map<String, int> byDayProductiveSeconds = <String, int>{};
    for (final Map<String, Object?> row in dailyRows) {
      final String dayKey = row['dayKey'] as String? ?? '';
      final int dayTotalSeconds = (row['totalSeconds'] as num?)?.toInt() ?? 0;
      final int dayProductiveSeconds =
          (row['productiveSeconds'] as num?)?.toInt() ?? 0;

      byDayTotalSeconds[dayKey] = dayTotalSeconds;
      byDayProductiveSeconds[dayKey] = dayProductiveSeconds;

      totalSeconds += dayTotalSeconds;
      productiveSeconds += dayProductiveSeconds;
    }

    final Map<String, int> byCategorySeconds = <String, int>{};
    final List<AnalyticsSessionEntry> sessions = <AnalyticsSessionEntry>[];
    for (final Map<String, Object?> row in sessionRows) {
      final String categoryId = row['categoryId'] as String? ?? 'idle';
      final String categoryTitle =
          row['categoryTitle'] as String? ?? _titleFromCategoryId(categoryId);
      final int durationSeconds =
          (row['durationSeconds'] as num?)?.toInt() ?? 0;
      if (durationSeconds <= 0) {
        continue;
      }

      final DateTime startedAt = DateTime.parse(row['startedAt'] as String);
      final DateTime endedAt = DateTime.parse(row['endedAt'] as String);
      final bool isProductive = !_isBreakOrIdle(categoryId, categoryTitle);

      byCategorySeconds[categoryId] =
          (byCategorySeconds[categoryId] ?? 0) + durationSeconds;

      sessions.add(
        AnalyticsSessionEntry(
          categoryId: categoryId,
          categoryTitle: categoryTitle,
          startedAt: startedAt,
          endedAt: endedAt,
          durationSeconds: durationSeconds,
          isProductive: isProductive,
        ),
      );
    }

    final List<DailyStudyStat> daily = <DailyStudyStat>[];
    for (int i = 6; i >= 0; i--) {
      final DateTime day = today.subtract(Duration(days: i));
      final String dayKey = _dayKey(day);

      daily.add(
        DailyStudyStat(
          day: day,
          totalMinutes: (byDayTotalSeconds[dayKey] ?? 0) ~/ 60,
          productiveMinutes: (byDayProductiveSeconds[dayKey] ?? 0) ~/ 60,
        ),
      );
    }

    final List<DistributionEntry> distribution = _buildDistribution(
      byCategorySeconds,
    );
    final int productivityScore =
        totalSeconds == 0
            ? 0
            : ((productiveSeconds / totalSeconds) * 100).round().clamp(0, 100);

    return AnalyticsDataBundle(
      selectedPeriod: selectedPeriod,
      daily: daily,
      distribution: distribution,
      totalTrackedMinutes: totalSeconds ~/ 60,
      productivityScore: productivityScore,
      smartInsightDetails: <String>[
        'Break blocks are ${(100 - productivityScore).clamp(0, 100)}% of tracked time.',
        'Most tracked minutes still cluster in your morning sessions.',
      ],
      sessions: sessions,
    );
  }

  Future<String> exportSessionsCsv() async {
    final db = await _database.database;
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT
        s.id,
        s.categoryId,
        COALESCE(c.title, s.categoryId) AS categoryTitle,
        s.startedAt,
        s.endedAt,
        s.durationSeconds,
        s.isProductive
      FROM sessions s
      LEFT JOIN categories c ON c.id = s.categoryId
      ORDER BY s.startedAt DESC
    ''');

    final StringBuffer buffer = StringBuffer(
      'id,category_id,category_title,started_at,ended_at,duration_seconds,is_productive\n',
    );

    for (final Map<String, Object?> row in rows) {
      buffer.writeln(
        <String>[
          '${row['id'] ?? ''}',
          _escapeCsvValue(row['categoryId']),
          _escapeCsvValue(row['categoryTitle']),
          _escapeCsvValue(row['startedAt']),
          _escapeCsvValue(row['endedAt']),
          '${row['durationSeconds'] ?? 0}',
          '${row['isProductive'] ?? 0}',
        ].join(','),
      );
    }

    return buffer.toString();
  }

  String _escapeCsvValue(Object? value) {
    final String text = (value ?? '').toString().replaceAll('"', '""');
    return '"$text"';
  }

  bool _isBreakOrIdle(String categoryId, String categoryTitle) {
    final String id = categoryId.toLowerCase();
    final String title = categoryTitle.toLowerCase();
    return id == 'break' || id == 'idle' || title == 'break' || title == 'idle';
  }

  String _dayKey(DateTime day) {
    final String month = day.month.toString().padLeft(2, '0');
    final String date = day.day.toString().padLeft(2, '0');
    return '${day.year}-$month-$date';
  }

  String _titleFromCategoryId(String categoryId) {
    if (categoryId.isEmpty) {
      return 'Study';
    }

    final String withSpaces = categoryId.replaceAll('-', ' ').trim();
    if (withSpaces.isEmpty) {
      return 'Study';
    }

    return withSpaces
        .split(' ')
        .map(
          (String part) =>
              part.isEmpty
                  ? ''
                  : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  List<DistributionEntry> _buildDistribution(Map<String, int> byCategory) {
    if (byCategory.isEmpty) {
      return const <DistributionEntry>[];
    }

    final int total = byCategory.values.fold<int>(0, (int a, int b) => a + b);
    final Map<String, ({String label, Color color})> metadata =
        <String, ({String label, Color color})>{
          'physics': (label: 'Physics', color: const Color(0xFF3B82F6)),
          'maths': (label: 'Maths', color: const Color(0xFFF43F5E)),
          'chemistry': (label: 'Chem', color: const Color(0xFF22C55E)),
          'break': (label: 'Break', color: const Color(0xFF8554F8)),
          'idle': (label: 'Idle', color: const Color(0xFF64748B)),
        };

    final List<DistributionEntry> entries = <DistributionEntry>[];
    byCategory.forEach((String key, int value) {
      final info =
          metadata[key] ?? (label: key, color: const Color(0xFF64748B));
      entries.add(
        DistributionEntry(
          label: info.label,
          value: total == 0 ? 0 : (value / total) * 100,
          color: info.color,
        ),
      );
    });

    return entries;
  }
}

class AnalyticsDataBundle {
  const AnalyticsDataBundle({
    required this.selectedPeriod,
    required this.daily,
    required this.distribution,
    required this.totalTrackedMinutes,
    required this.productivityScore,
    required this.smartInsightDetails,
    required this.sessions,
  });

  final String selectedPeriod;
  final List<DailyStudyStat> daily;
  final List<DistributionEntry> distribution;
  final int totalTrackedMinutes;
  final int productivityScore;
  final List<String> smartInsightDetails;
  final List<AnalyticsSessionEntry> sessions;
}

class DistributionEntry {
  const DistributionEntry({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class AnalyticsSessionEntry {
  const AnalyticsSessionEntry({
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
