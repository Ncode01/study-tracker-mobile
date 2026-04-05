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
  static const String _timerElapsedKey = 'timer_elapsed_seconds';
  static const String _timerTargetKey = 'timer_target_seconds';
  static const String _timerRunningKey = 'timer_is_running';
  static const String _timerLastUpdateKey = 'timer_last_update_ms';
  static const String _timerSessionStartTimeKey = 'timer_session_start_time_ms';
  static const String _timerSessionStartElapsedKey =
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

  Future<TimerSnapshot> loadTimerSnapshot({
    required Duration defaultTarget,
  }) async {
    final int elapsedSeconds = _preferences.getInt(_timerElapsedKey) ?? 0;
    final int targetSeconds =
        _preferences.getInt(_timerTargetKey) ?? defaultTarget.inSeconds;
    final bool wasRunning = _preferences.getBool(_timerRunningKey) ?? false;
    final int? lastUpdateMs = _preferences.getInt(_timerLastUpdateKey);
    final DateTime? savedSessionStartTime = _loadDateTime(
      _timerSessionStartTimeKey,
    );
    final int sessionStartElapsedSeconds =
        _preferences.getInt(_timerSessionStartElapsedKey) ?? elapsedSeconds;

    Duration elapsed = Duration(seconds: elapsedSeconds);
    final Duration target = Duration(seconds: targetSeconds);
    Duration sessionStartElapsed = Duration(
      seconds: sessionStartElapsedSeconds,
    );

    DateTime? effectiveSessionStartTime = savedSessionStartTime;

    if (wasRunning) {
      if (savedSessionStartTime != null) {
        final Duration trueElapsed = DateTime.now().difference(
          savedSessionStartTime,
        );
        if (!trueElapsed.isNegative) {
          elapsed = trueElapsed;
        }
      } else if (lastUpdateMs != null) {
        final DateTime last = DateTime.fromMillisecondsSinceEpoch(lastUpdateMs);
        final Duration drift = DateTime.now().difference(last);
        if (!drift.isNegative) {
          elapsed += drift;
        }
      }

      effectiveSessionStartTime =
          savedSessionStartTime ?? DateTime.now().subtract(elapsed);
    }

    final bool completed = elapsed >= target;
    final Duration clampedElapsed = completed ? target : elapsed;
    if (sessionStartElapsed > clampedElapsed) {
      sessionStartElapsed = clampedElapsed;
    }

    final TimerSnapshot snapshot = TimerSnapshot(
      elapsed: clampedElapsed,
      target: target,
      isRunning: wasRunning && !completed,
      sessionStartTime:
          wasRunning && !completed ? effectiveSessionStartTime : null,
      sessionStartElapsed:
          wasRunning && !completed ? sessionStartElapsed : clampedElapsed,
    );

    await saveTimerSnapshot(snapshot);
    return snapshot;
  }

  Future<void> saveTimerSnapshot(TimerSnapshot snapshot) async {
    await _preferences.setInt(_timerElapsedKey, snapshot.elapsed.inSeconds);
    await _preferences.setInt(_timerTargetKey, snapshot.target.inSeconds);
    await _preferences.setBool(_timerRunningKey, snapshot.isRunning);
    await _preferences.setInt(
      _timerSessionStartElapsedKey,
      snapshot.sessionStartElapsed.inSeconds,
    );

    if (snapshot.isRunning && snapshot.sessionStartTime != null) {
      await _preferences.setInt(
        _timerSessionStartTimeKey,
        snapshot.sessionStartTime!.millisecondsSinceEpoch,
      );
    } else {
      await _preferences.remove(_timerSessionStartTimeKey);
    }

    await _preferences.setInt(
      _timerLastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
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
