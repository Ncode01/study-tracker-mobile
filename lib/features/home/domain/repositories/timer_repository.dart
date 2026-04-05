import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/local/app_database.dart';
import '../models/home_stats.dart';
import '../models/subject_category.dart';
import '../models/timer_snapshot.dart';

class TimerRepository {
  TimerRepository({
    required AppDatabase database,
    required SharedPreferences preferences,
  }) : _database = database,
       _preferences = preferences;

  static const String _selectedCategoryKey = 'selected_category_id';
  static const String _timerSessionStartTimeKey = 'timer_session_start_time_ms';
  static const String _timerElapsedKey = 'timer_elapsed_seconds';

  // Legacy keys kept temporarily for migration cleanup from pre-continuous flow builds.
  static const String _legacyTimerTargetKey = 'timer_target_seconds';
  static const String _legacyTimerRunningKey = 'timer_is_running';
  static const String _legacyTimerLastUpdateKey = 'timer_last_update_ms';
  static const String _legacyTimerSessionStartElapsedKey =
      'timer_session_start_elapsed_seconds';

  final AppDatabase _database;
  final SharedPreferences _preferences;

  Future<List<SubjectCategory>> loadCategories() async {
    final db = await _database.database;
    final rows = await db.query('categories', orderBy: 'rowid ASC');
    return rows
        .map((Map<String, Object?> row) => SubjectCategory.fromMap(row))
        .toList(growable: false);
  }

  Future<void> insertCategory(SubjectCategory category) async {
    final db = await _database.database;
    await db.insert('categories', <String, Object?>{
      ...category.toMap(),
      'isDefault': 0,
    });
  }

  Future<bool> categoryIdExists(String categoryId) async {
    final db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'categories',
      columns: const <String>['id'],
      where: 'id = ?',
      whereArgs: <Object?>[categoryId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<String?> loadSelectedCategoryId() async {
    return _preferences.getString(_selectedCategoryKey);
  }

  Future<void> saveSelectedCategoryId(String categoryId) async {
    await _preferences.setString(_selectedCategoryKey, categoryId);
  }

  Future<TimerSnapshot> loadTimerSnapshot() async {
    final DateTime now = DateTime.now();
    final DateTime? savedSessionStartTime = _loadDateTime(
      _timerSessionStartTimeKey,
    );
    final int elapsedSeconds = _preferences.getInt(_timerElapsedKey) ?? 0;

    final DateTime sessionStartTime =
        savedSessionStartTime ??
        now.subtract(Duration(seconds: elapsedSeconds));
    final Duration elapsed = now.difference(sessionStartTime);

    final TimerSnapshot snapshot = TimerSnapshot(
      sessionStartTime: sessionStartTime,
      elapsed: elapsed.isNegative ? Duration.zero : elapsed,
    );

    await saveTimerSnapshot(snapshot);
    await _removeLegacyTimerKeys();
    return snapshot;
  }

  Future<void> saveTimerSnapshot(TimerSnapshot snapshot) async {
    await _preferences.setInt(
      _timerSessionStartTimeKey,
      snapshot.sessionStartTime.millisecondsSinceEpoch,
    );
    await _preferences.setInt(_timerElapsedKey, snapshot.elapsed.inSeconds);
  }

  Future<void> saveActiveSession({
    required String categoryId,
    required DateTime sessionStartTime,
  }) async {
    await saveSelectedCategoryId(categoryId);
    await saveTimerSnapshot(
      TimerSnapshot(sessionStartTime: sessionStartTime, elapsed: Duration.zero),
    );
  }

  Future<void> _removeLegacyTimerKeys() async {
    await _preferences.remove(_legacyTimerTargetKey);
    await _preferences.remove(_legacyTimerRunningKey);
    await _preferences.remove(_legacyTimerLastUpdateKey);
    await _preferences.remove(_legacyTimerSessionStartElapsedKey);
  }

  DateTime? _loadDateTime(String key) {
    final int? milliseconds = _preferences.getInt(key);
    if (milliseconds == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  Future<void> saveSession({
    required String categoryId,
    required DateTime startedAt,
    required DateTime endedAt,
    required Duration duration,
    required bool isProductive,
  }) async {
    final db = await _database.database;
    await db.insert('sessions', <String, Object?>{
      'categoryId': categoryId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'isProductive': isProductive ? 1 : 0,
    });
  }

  Future<HomeStats> loadHomeStats({
    required List<SubjectCategory> categories,
    required String currentCategoryId,
  }) async {
    final db = await _database.database;
    final rows = await db.query('sessions');

    int totalProductiveSeconds = 0;
    int todayProductiveSeconds = 0;
    final DateTime now = DateTime.now();

    for (final row in rows) {
      final int durationSeconds = row['durationSeconds'] as int? ?? 0;
      final bool productive = (row['isProductive'] as int? ?? 0) == 1;
      if (!productive) {
        continue;
      }

      totalProductiveSeconds += durationSeconds;
      final DateTime end = DateTime.parse(row['endedAt'] as String);
      if (_isSameDate(end, now)) {
        todayProductiveSeconds += durationSeconds;
      }
    }

    final SubjectCategory fallback =
        categories.isNotEmpty
            ? categories.first
            : const SubjectCategory(
              id: 'physics',
              title: 'Physics',
              icon: Icons.bolt_outlined,
              accentColor: Color(0xFF3B82F6),
              section: 'A/LEVELS',
            );

    final SubjectCategory nextCategory =
        categories
            .where(
              (SubjectCategory c) =>
                  c.id != currentCategoryId && c.section == 'A/LEVELS',
            )
            .cast<SubjectCategory?>()
            .firstWhere(
              (SubjectCategory? c) => c != null,
              orElse: () => fallback,
            )!;

    return HomeStats(
      totalProductive: _formatDuration(totalProductiveSeconds),
      streak: _formatDuration(todayProductiveSeconds),
      next: nextCategory.title,
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours == 0 && minutes == 0) {
      return '0m';
    }

    if (hours == 0) {
      return '${minutes}m';
    }

    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}m';
  }
}
