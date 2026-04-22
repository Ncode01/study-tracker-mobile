import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
  static const String _activeSessionCategoryKey = 'active_session_category_id';
  static const String _activeSessionStartTimeKey =
      'timer_session_start_time_ms';

  static const String _pomodoroPhaseKey = 'pomodoro_phase';
  static const String _pomodoroPhaseDurationSecondsKey =
      'pomodoro_phase_duration_seconds';
  static const String _pomodoroElapsedSecondsKey = 'pomodoro_elapsed_seconds';
  static const String _pomodoroIsRunningKey = 'pomodoro_is_running';
  static const String _pomodoroRunningSinceMsKey = 'pomodoro_running_since_ms';
  static const String _pomodoroCompletedFocusSessionsKey =
      'pomodoro_completed_focus_sessions';

  // Legacy keys kept temporarily for migration cleanup from pre-continuous flow builds.
  static const String _legacyTimerTargetKey = 'timer_target_seconds';
  static const String _legacyTimerRunningKey = 'timer_is_running';
  static const String _legacyTimerLastUpdateKey = 'timer_last_update_ms';
  static const String _legacyTimerSessionStartElapsedKey =
      'timer_session_start_elapsed_seconds';
  static const String _legacyTimerElapsedKey = 'timer_elapsed_seconds';

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

  Future<TimerSnapshot> loadTimerSnapshot({required int focusMinutes}) async {
    final Duration focusDuration = Duration(minutes: focusMinutes);

    final String? phaseRaw = _preferences.getString(_pomodoroPhaseKey);
    final TimerSnapshot fallback = TimerSnapshot.idleFocus(
      focusDuration: focusDuration,
    );

    if (phaseRaw == null || phaseRaw.trim().isEmpty) {
      await saveTimerSnapshot(fallback);
      await _removeLegacyTimerKeys();
      return fallback;
    }

    final TimerSnapshot persisted = TimerSnapshot.fromMap(<String, Object?>{
      'phase': phaseRaw,
      'phaseDurationSeconds':
          _preferences.getInt(_pomodoroPhaseDurationSecondsKey) ??
          focusDuration.inSeconds,
      'elapsedSeconds': _preferences.getInt(_pomodoroElapsedSecondsKey) ?? 0,
      'isRunning': _preferences.getBool(_pomodoroIsRunningKey) ?? false,
      'runningSinceMs': _preferences.getInt(_pomodoroRunningSinceMsKey),
      'completedFocusSessions':
          _preferences.getInt(_pomodoroCompletedFocusSessionsKey) ?? 0,
    });

    final DateTime now = DateTime.now();
    final TimerSnapshot normalized = persisted.materializeAt(now);
    await saveTimerSnapshot(normalized);
    await _removeLegacyTimerKeys();
    return normalized;
  }

  Future<void> saveTimerSnapshot(TimerSnapshot snapshot) async {
    final Map<String, Object?> map = snapshot.toMap();

    await _preferences.setString(_pomodoroPhaseKey, map['phase']! as String);
    await _preferences.setInt(
      _pomodoroPhaseDurationSecondsKey,
      map['phaseDurationSeconds']! as int,
    );
    await _preferences.setInt(
      _pomodoroElapsedSecondsKey,
      map['elapsedSeconds']! as int,
    );
    await _preferences.setBool(
      _pomodoroIsRunningKey,
      (map['isRunning'] as int? ?? 0) == 1,
    );

    final int? runningSinceMs = map['runningSinceMs'] as int?;
    if (runningSinceMs == null) {
      await _preferences.remove(_pomodoroRunningSinceMsKey);
    } else {
      await _preferences.setInt(_pomodoroRunningSinceMsKey, runningSinceMs);
    }

    await _preferences.setInt(
      _pomodoroCompletedFocusSessionsKey,
      map['completedFocusSessions']! as int,
    );
  }

  Future<void> saveActiveSession({
    required String categoryId,
    required DateTime sessionStartTime,
  }) async {
    await _preferences.setString(_activeSessionCategoryKey, categoryId);
    await _preferences.setInt(
      _activeSessionStartTimeKey,
      sessionStartTime.millisecondsSinceEpoch,
    );
  }

  Future<void> clearActiveSession() async {
    await _preferences.remove(_activeSessionCategoryKey);
    await _preferences.remove(_activeSessionStartTimeKey);
  }

  Future<void> _removeLegacyTimerKeys() async {
    await _preferences.remove(_legacyTimerTargetKey);
    await _preferences.remove(_legacyTimerRunningKey);
    await _preferences.remove(_legacyTimerLastUpdateKey);
    await _preferences.remove(_legacyTimerSessionStartElapsedKey);
    await _preferences.remove(_legacyTimerElapsedKey);
  }

  Future<void> saveSession({
    required String categoryId,
    required DateTime startedAt,
    required DateTime endedAt,
    required Duration duration,
    required bool isProductive,
  }) async {
    final Duration normalizedDuration =
        duration.isNegative ? Duration.zero : duration;
    if (normalizedDuration <= Duration.zero) {
      return;
    }

    final DateTime normalizedEndedAt =
        endedAt.isAfter(startedAt)
            ? endedAt
            : startedAt.add(normalizedDuration);

    final db = await _database.database;
    await db.insert('sessions', <String, Object?>{
      'categoryId': categoryId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': normalizedEndedAt.toIso8601String(),
      'durationSeconds': normalizedDuration.inSeconds,
      'isProductive': isProductive ? 1 : 0,
    });
  }

  Future<HomeStats> loadHomeStats({
    required List<SubjectCategory> categories,
    required String currentCategoryId,
    required int weeklyTargetMinutes,
  }) async {
    final db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'sessions',
      columns: const <String>[
        'categoryId',
        'startedAt',
        'endedAt',
        'durationSeconds',
        'isProductive',
      ],
    );

    int totalProductiveSeconds = 0;
    int todayProductiveSeconds = 0;
    final DateTime now = DateTime.now();
    final DateTime weekStart = _startOfWeek(now);
    final DateTime weekEnd = weekStart.add(const Duration(days: 7));

    final List<_TimeRange> productiveWeekRanges = <_TimeRange>[];

    for (final Map<String, Object?> row in rows) {
      final int durationSeconds = row['durationSeconds'] as int? ?? 0;
      final bool productive = (row['isProductive'] as int? ?? 0) == 1;
      if (!productive) {
        continue;
      }

      final DateTime? startAt = DateTime.tryParse(
        row['startedAt'] as String? ?? '',
      );
      final DateTime? endedAt = DateTime.tryParse(
        row['endedAt'] as String? ?? '',
      );

      if (startAt == null || endedAt == null || !endedAt.isAfter(startAt)) {
        continue;
      }

      final int normalizedDurationSeconds =
          durationSeconds > 0
              ? durationSeconds
              : endedAt.difference(startAt).inSeconds;
      totalProductiveSeconds += normalizedDurationSeconds;

      if (_isSameDate(endedAt, now)) {
        todayProductiveSeconds += normalizedDurationSeconds;
      }

      final _TimeRange? weekRange = _clampRange(
        start: startAt,
        end: endedAt,
        windowStart: weekStart,
        windowEnd: weekEnd,
      );
      if (weekRange != null) {
        productiveWeekRanges.add(weekRange);
      }
    }

    final int weeklyProductiveSeconds = _totalMergedSeconds(
      productiveWeekRanges,
    );
    final int safeWeeklyTargetMinutes =
        weeklyTargetMinutes <= 0 ? 10 * 60 : weeklyTargetMinutes;
    final int weeklyTargetSeconds =
        Duration(minutes: safeWeeklyTargetMinutes).inSeconds;
    final int elapsedWeekDays = now.difference(weekStart).inDays + 1;
    final int weeklyAverageSeconds =
        elapsedWeekDays <= 0
            ? 0
            : (weeklyProductiveSeconds / elapsedWeekDays).round();

    final bool hasPlannedItemsTable = await _tableExists(
      db: db,
      tableName: 'planned_items',
    );
    final List<_TimeRange> plannedWeekRanges = <_TimeRange>[];

    if (hasPlannedItemsTable) {
      final List<Map<String, Object?>> plannedRows = await db.rawQuery(
        '''
        SELECT startAt, endAt
        FROM planned_items
        WHERE startAt < ?
          AND endAt > ?
      ''',
        <Object?>[weekEnd.toIso8601String(), weekStart.toIso8601String()],
      );

      for (final Map<String, Object?> row in plannedRows) {
        final DateTime? startAt = DateTime.tryParse(
          row['startAt'] as String? ?? '',
        );
        final DateTime? endedAt = DateTime.tryParse(
          row['endAt'] as String? ?? '',
        );

        if (startAt == null || endedAt == null || !endedAt.isAfter(startAt)) {
          continue;
        }

        final _TimeRange? weekRange = _clampRange(
          start: startAt,
          end: endedAt,
          windowStart: weekStart,
          windowEnd: weekEnd,
        );
        if (weekRange != null) {
          plannedWeekRanges.add(weekRange);
        }
      }
    }

    final int plannedWeekSeconds = _totalMergedSeconds(plannedWeekRanges);
    final int overlapWeekSeconds = _totalMergedOverlapSeconds(
      first: plannedWeekRanges,
      second: productiveWeekRanges,
    );

    final String adherenceLabel =
        plannedWeekSeconds <= 0
            ? 'No planned slots yet'
            : '${((overlapWeekSeconds / plannedWeekSeconds) * 100).round().clamp(0, 100)}% on-plan';

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
      weeklyTargetProgress:
          '${_formatDuration(weeklyProductiveSeconds)} / ${_formatDuration(weeklyTargetSeconds)}',
      weeklyAverage: '${_formatDuration(weeklyAverageSeconds)}/day',
      planAdherence: adherenceLabel,
    );
  }

  Future<bool> _tableExists({
    required Database db,
    required String tableName,
  }) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      <Object?>['table', tableName],
    );
    return rows.isNotEmpty;
  }

  DateTime _startOfWeek(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  _TimeRange? _clampRange({
    required DateTime start,
    required DateTime end,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    if (!end.isAfter(start)) {
      return null;
    }

    final DateTime clampedStart =
        start.isBefore(windowStart) ? windowStart : start;
    final DateTime clampedEnd = end.isAfter(windowEnd) ? windowEnd : end;

    if (!clampedEnd.isAfter(clampedStart)) {
      return null;
    }

    return _TimeRange(start: clampedStart, end: clampedEnd);
  }

  int _totalMergedSeconds(List<_TimeRange> ranges) {
    if (ranges.isEmpty) {
      return 0;
    }

    final List<_TimeRange> merged = _mergeRanges(ranges);
    int total = 0;
    for (final _TimeRange range in merged) {
      total += range.durationSeconds;
    }
    return total;
  }

  int _totalMergedOverlapSeconds({
    required List<_TimeRange> first,
    required List<_TimeRange> second,
  }) {
    if (first.isEmpty || second.isEmpty) {
      return 0;
    }

    final List<_TimeRange> left = _mergeRanges(first);
    final List<_TimeRange> right = _mergeRanges(second);

    int i = 0;
    int j = 0;
    int overlapSeconds = 0;

    while (i < left.length && j < right.length) {
      final _TimeRange a = left[i];
      final _TimeRange b = right[j];

      final DateTime overlapStart =
          a.start.isAfter(b.start) ? a.start : b.start;
      final DateTime overlapEnd = a.end.isBefore(b.end) ? a.end : b.end;

      if (overlapEnd.isAfter(overlapStart)) {
        overlapSeconds += overlapEnd.difference(overlapStart).inSeconds;
      }

      if (a.end.isBefore(b.end)) {
        i++;
      } else {
        j++;
      }
    }

    return overlapSeconds;
  }

  List<_TimeRange> _mergeRanges(List<_TimeRange> ranges) {
    if (ranges.length <= 1) {
      return List<_TimeRange>.from(ranges);
    }

    final List<_TimeRange> sorted = List<_TimeRange>.from(ranges)
      ..sort((_TimeRange a, _TimeRange b) => a.start.compareTo(b.start));

    final List<_TimeRange> merged = <_TimeRange>[];
    _TimeRange current = sorted.first;

    for (int index = 1; index < sorted.length; index++) {
      final _TimeRange next = sorted[index];

      if (!next.start.isAfter(current.end)) {
        final DateTime end =
            next.end.isAfter(current.end) ? next.end : current.end;
        current = _TimeRange(start: current.start, end: end);
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
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

class _TimeRange {
  const _TimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get durationSeconds => end.difference(start).inSeconds;
}
