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
    final List<Map<String, Object?>> rows = await db.query(
      'sessions',
      where: sinceIso == null ? null : 'endedAt >= ?',
      whereArgs: sinceIso == null ? null : <Object?>[sinceIso],
      orderBy: 'endedAt ASC',
    );

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime weekStart = today.subtract(const Duration(days: 6));

    int totalMinutes = 0;
    int productiveMinutes = 0;

    final Map<String, int> byCategorySeconds = <String, int>{};
    final Map<String, int> byDaySeconds = <String, int>{};

    for (final row in rows) {
      final DateTime endedAt = DateTime.parse(row['endedAt'] as String);

      final int durationSeconds = row['durationSeconds'] as int? ?? 0;
      final bool productive = (row['isProductive'] as int? ?? 0) == 1;
      final String categoryId = row['categoryId'] as String? ?? 'idle';
      final DateTime day = DateTime(endedAt.year, endedAt.month, endedAt.day);

      totalMinutes += durationSeconds ~/ 60;
      if (productive) {
        productiveMinutes += durationSeconds ~/ 60;
      }

      byCategorySeconds[categoryId] =
          (byCategorySeconds[categoryId] ?? 0) + durationSeconds;
      if (!day.isBefore(weekStart)) {
        final String dayKey = day.toIso8601String();
        byDaySeconds[dayKey] = (byDaySeconds[dayKey] ?? 0) + durationSeconds;
      }
    }

    final List<DailyStudyStat> daily = <DailyStudyStat>[];
    for (int i = 6; i >= 0; i--) {
      final DateTime day = today.subtract(Duration(days: i));
      final int daySeconds = byDaySeconds[day.toIso8601String()] ?? 0;
      daily.add(
        DailyStudyStat(
          day: day,
          totalMinutes: daySeconds ~/ 60,
          productiveMinutes: daySeconds ~/ 60,
        ),
      );
    }

    final List<DistributionEntry> distribution =
        _buildDistribution(byCategorySeconds);
    final int productivityScore = totalMinutes == 0
        ? 0
        : ((productiveMinutes / totalMinutes) * 100).round().clamp(0, 100);

    return AnalyticsDataBundle(
      selectedPeriod: selectedPeriod,
      daily: daily,
      distribution: distribution,
      totalTrackedMinutes: totalMinutes,
      productivityScore: productivityScore,
      smartInsightDetails: <String>[
        'Break blocks are ${(100 - productivityScore).clamp(0, 100)}% of tracked time.',
        'Most tracked minutes still cluster in your morning sessions.',
      ],
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

  List<DistributionEntry> _buildDistribution(Map<String, int> byCategory) {
    if (byCategory.isEmpty) {
      return const <DistributionEntry>[
        DistributionEntry(
            label: 'Physics', value: 42, color: Color(0xFF3B82F6)),
        DistributionEntry(label: 'Maths', value: 30, color: Color(0xFFF43F5E)),
        DistributionEntry(label: 'Chem', value: 18, color: Color(0xFF22C55E)),
        DistributionEntry(label: 'Idle', value: 10, color: Color(0xFF64748B)),
      ];
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
  });

  final String selectedPeriod;
  final List<DailyStudyStat> daily;
  final List<DistributionEntry> distribution;
  final int totalTrackedMinutes;
  final int productivityScore;
  final List<String> smartInsightDetails;
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
