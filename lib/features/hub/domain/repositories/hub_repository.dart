import 'package:sqflite/sqflite.dart';

import '../../../../core/data/local/app_database.dart';
import '../models/hub_class_schedule.dart';

class HubHistoricalAttendanceSeedResult {
  const HubHistoricalAttendanceSeedResult({
    required this.historicalSessions,
    required this.missedSessions,
    required this.watchedSessions,
    required this.pendingRecordings,
  });

  final int historicalSessions;
  final int missedSessions;
  final int watchedSessions;
  final int pendingRecordings;

  bool get hasHeavyBacklog => pendingRecordings >= 3;
}

abstract class HubRepository {
  Future<List<HubClassSchedule>> loadClassSchedules();
  Future<int> addClassSchedule({
    required String subjectId,
    required String teacherName,
    required DateTime startDate,
    required int weekday,
    required int startMinutes,
    required int durationMinutes,
  });
  Future<HubHistoricalAttendanceSeedResult> seedHistoricalAttendance({
    required int classId,
    required int missedSessions,
    required int watchedSessions,
  });
  Future<void> updateClassAttendance({
    required int classId,
    required HubAttendanceStatus status,
  });
  Future<void> stopClassSchedule({
    required int classId,
    required DateTime endDate,
  });
  Future<void> scheduleRecording({
    required int classId,
    required DateTime plannedAt,
    required int durationMinutes,
  });
  Future<int> scheduleAutomaticRecordingCatchUp({
    required int classId,
    required DateTime occurrenceDate,
  });
  Future<void> setRecordingCompleted({
    required int classId,
    required bool completed,
  });
  Future<void> deleteClassSchedule(int classId);
}

class SqliteHubRepository implements HubRepository {
  SqliteHubRepository({required AppDatabase database}) : _database = database;

  static const int _recordingCooldownMinutes = 45;

  final AppDatabase _database;

  @override
  Future<List<HubClassSchedule>> loadClassSchedules() async {
    final db = await _database.database;
    final bool hasRecordingBacklogTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );

    final Map<int, _RecordingRollup> rollupByClassId =
        hasRecordingBacklogTable
            ? await _loadRecordingRollups(db)
            : <int, _RecordingRollup>{};

    final List<Map<String, Object?>> rows = await db.query(
      'hub_classes',
      orderBy: 'subjectId ASC, weekday ASC, startMinutes ASC, id ASC',
    );

    final List<HubClassSchedule> classes = <HubClassSchedule>[];
    for (final Map<String, Object?> row in rows) {
      final String subjectId = row['subjectId'] as String? ?? '';
      if (subjectId.isEmpty) {
        continue;
      }

      final DateTime now = DateTime.now();
      final int classId = (row['id'] as num?)?.toInt() ?? 0;
      if (classId <= 0) {
        continue;
      }

      final String createdAtRaw = row['createdAt'] as String? ?? '';
      final DateTime createdAt = DateTime.tryParse(createdAtRaw) ?? now;
      final String updatedAtRaw = row['updatedAt'] as String? ?? '';
      final DateTime updatedAt = DateTime.tryParse(updatedAtRaw) ?? createdAt;

      final DateTime startDate =
          DateTime.tryParse(row['startDate'] as String? ?? '') ??
          _dateOnly(createdAt);
      final DateTime? endDate = DateTime.tryParse(
        row['endDate'] as String? ?? '',
      );

      final String? recordingRaw = row['recordingPlannedAt'] as String?;
      DateTime? recordingPlannedAt =
          recordingRaw == null || recordingRaw.isEmpty
              ? null
              : DateTime.tryParse(recordingRaw);
      int? recordingDurationMinutes =
          (row['recordingDurationMinutes'] as num?)?.toInt();
      final bool legacyRecordingCompleted =
          (row['recordingCompleted'] as num?)?.toInt() == 1;

      int pendingRecordingCount = 0;
      int completedRecordingCount = 0;
      final _RecordingRollup? rollup = rollupByClassId[classId];
      if (rollup != null) {
        pendingRecordingCount = rollup.pendingCount;
        completedRecordingCount = rollup.completedCount;
        if (rollup.nextPendingAt != null) {
          recordingPlannedAt = rollup.nextPendingAt;
          recordingDurationMinutes = rollup.nextPendingDurationMinutes;
        }
      }

      // Preserve legacy one-off recording state for rows that predate backlog rows.
      if (pendingRecordingCount == 0 && recordingPlannedAt != null) {
        pendingRecordingCount = legacyRecordingCompleted ? 0 : 1;
        completedRecordingCount += legacyRecordingCompleted ? 1 : 0;
      }

      classes.add(
        HubClassSchedule(
          id: classId,
          subjectId: subjectId,
          teacherName: row['teacherName'] as String? ?? 'Unknown Teacher',
          startDate: _dateOnly(startDate),
          endDate: endDate == null ? null : _dateOnly(endDate),
          weekday: ((row['weekday'] as num?)?.toInt() ?? 1).clamp(1, 7),
          startMinutes: ((row['startMinutes'] as num?)?.toInt() ?? 0).clamp(
            0,
            1439,
          ),
          durationMinutes: (row['durationMinutes'] as num?)?.toInt() ?? 60,
          attendanceStatus: HubAttendanceStatusX.fromDb(
            row['attendanceStatus'] as String? ?? 'pending',
          ),
          recordingPlannedAt: recordingPlannedAt,
          recordingDurationMinutes: recordingDurationMinutes,
          recordingCompleted:
              pendingRecordingCount == 0 &&
              (completedRecordingCount > 0 || legacyRecordingCompleted),
          pendingRecordingCount: pendingRecordingCount,
          completedRecordingCount: completedRecordingCount,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
    }

    return classes;
  }

  Future<Map<int, _RecordingRollup>> _loadRecordingRollups(dynamic db) async {
    final List<Map<String, Object?>> rows = await db.query(
      'hub_recordings',
      columns: const <String>[
        'classId',
        'plannedAt',
        'durationMinutes',
        'completed',
      ],
      orderBy: 'classId ASC, plannedAt ASC, id ASC',
    );

    final Map<int, _RecordingRollup> byClass = <int, _RecordingRollup>{};
    for (final Map<String, Object?> row in rows) {
      final int classId = (row['classId'] as num?)?.toInt() ?? 0;
      if (classId <= 0) {
        continue;
      }

      final _RecordingRollup rollup = byClass.putIfAbsent(
        classId,
        _RecordingRollup.new,
      );
      final bool completed = (row['completed'] as num?)?.toInt() == 1;

      if (completed) {
        rollup.completedCount += 1;
        continue;
      }

      rollup.pendingCount += 1;
      if (rollup.nextPendingAt != null) {
        continue;
      }

      final DateTime? plannedAt = DateTime.tryParse(
        row['plannedAt'] as String? ?? '',
      );
      if (plannedAt != null) {
        rollup.nextPendingAt = plannedAt;
        rollup.nextPendingDurationMinutes =
            (row['durationMinutes'] as num?)?.toInt();
      }
    }

    return byClass;
  }

  @override
  Future<int> addClassSchedule({
    required String subjectId,
    required String teacherName,
    required DateTime startDate,
    required int weekday,
    required int startMinutes,
    required int durationMinutes,
  }) async {
    final db = await _database.database;
    final DateTime now = DateTime.now();

    return db.insert('hub_classes', <String, Object?>{
      'subjectId': subjectId,
      'teacherName': teacherName.trim(),
      'startDate': _dateOnly(startDate).toIso8601String(),
      'endDate': null,
      'weekday': weekday,
      'startMinutes': startMinutes,
      'durationMinutes': durationMinutes,
      'attendanceStatus': HubAttendanceStatus.pending.dbValue,
      'recordingPlannedAt': null,
      'recordingDurationMinutes': null,
      'recordingCompleted': 0,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  @override
  Future<HubHistoricalAttendanceSeedResult> seedHistoricalAttendance({
    required int classId,
    required int missedSessions,
    required int watchedSessions,
  }) async {
    final db = await _database.database;
    final List<Map<String, Object?>> classRows = await db.query(
      'hub_classes',
      columns: const <String>[
        'id',
        'subjectId',
        'weekday',
        'durationMinutes',
        'startDate',
        'createdAt',
      ],
      where: 'id = ?',
      whereArgs: <Object?>[classId],
      limit: 1,
    );

    if (classRows.isEmpty) {
      return const HubHistoricalAttendanceSeedResult(
        historicalSessions: 0,
        missedSessions: 0,
        watchedSessions: 0,
        pendingRecordings: 0,
      );
    }

    final Map<String, Object?> row = classRows.first;
    final DateTime now = DateTime.now();
    final DateTime startDate =
        DateTime.tryParse(row['startDate'] as String? ?? '') ??
        _dateOnly(DateTime.tryParse(row['createdAt'] as String? ?? '') ?? now);
    final int weekday = ((row['weekday'] as num?)?.toInt() ?? 1).clamp(1, 7);
    final int durationMinutes =
        ((row['durationMinutes'] as num?)?.toInt() ?? 60).clamp(15, 360);
    final String subjectId = row['subjectId'] as String? ?? 'study';

    final List<DateTime> historicalSessions = _occurrenceDaysUntilToday(
      startDate: _dateOnly(startDate),
      weekday: weekday,
      today: _dateOnly(now),
    );

    final int boundedMissed = missedSessions.clamp(
      0,
      historicalSessions.length,
    );
    final int boundedWatched = watchedSessions.clamp(0, boundedMissed);
    final int pending = boundedMissed - boundedWatched;

    if (pending <= 0) {
      return HubHistoricalAttendanceSeedResult(
        historicalSessions: historicalSessions.length,
        missedSessions: boundedMissed,
        watchedSessions: boundedWatched,
        pendingRecordings: 0,
      );
    }

    final bool hasRecordingBacklogTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );
    if (!hasRecordingBacklogTable) {
      return HubHistoricalAttendanceSeedResult(
        historicalSessions: historicalSessions.length,
        missedSessions: boundedMissed,
        watchedSessions: boundedWatched,
        pendingRecordings: pending,
      );
    }

    final List<DateTime> recentMissed = historicalSessions.reversed
        .take(boundedMissed)
        .toList(growable: false)
      ..sort((DateTime a, DateTime b) => a.compareTo(b));
    final List<DateTime> pendingOccurrences = recentMissed
        .skip(boundedWatched)
        .toList(growable: false);

    DateTime nextSearchStart = _roundToQuarterHour(
      now.add(const Duration(minutes: 20)),
    );

    for (final DateTime occurrenceDay in pendingOccurrences) {
      final DateTime plannedAt = await _findNextFreeSlot(
        db: db,
        searchStart: nextSearchStart,
        durationMinutes: durationMinutes,
      );
      // Keep auto catch-up sessions spread out so they are manageable.
      nextSearchStart = _dateOnly(
        plannedAt,
      ).add(const Duration(days: 1, hours: 7));

      await db.insert('hub_recordings', <String, Object?>{
        'classId': classId,
        'subjectId': subjectId,
        'occurrenceDate': _dateOnly(occurrenceDay).toIso8601String(),
        'plannedAt': plannedAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'completed': 0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
    }

    return HubHistoricalAttendanceSeedResult(
      historicalSessions: historicalSessions.length,
      missedSessions: boundedMissed,
      watchedSessions: boundedWatched,
      pendingRecordings: pending,
    );
  }

  @override
  Future<void> stopClassSchedule({
    required int classId,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'hub_classes',
      columns: const <String>['startDate'],
      where: 'id = ?',
      whereArgs: <Object?>[classId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return;
    }

    final DateTime normalizedEndDate = _dateOnly(endDate);
    final DateTime classStart =
        DateTime.tryParse(rows.first['startDate'] as String? ?? '') ??
        normalizedEndDate;
    final DateTime clampedEnd =
        normalizedEndDate.isBefore(classStart)
            ? _dateOnly(classStart)
            : normalizedEndDate;

    await db.update(
      'hub_classes',
      <String, Object?>{
        'endDate': clampedEnd.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[classId],
    );
  }

  @override
  Future<void> updateClassAttendance({
    required int classId,
    required HubAttendanceStatus status,
  }) async {
    final db = await _database.database;
    final DateTime now = DateTime.now();

    final Map<String, Object?> payload = <String, Object?>{
      'attendanceStatus': status.dbValue,
      'updatedAt': now.toIso8601String(),
    };

    if (status != HubAttendanceStatus.missed) {
      payload['recordingPlannedAt'] = null;
      payload['recordingDurationMinutes'] = null;
      payload['recordingCompleted'] = 0;
    }

    await db.update(
      'hub_classes',
      payload,
      where: 'id = ?',
      whereArgs: <Object?>[classId],
    );
  }

  @override
  Future<void> scheduleRecording({
    required int classId,
    required DateTime plannedAt,
    required int durationMinutes,
  }) async {
    final db = await _database.database;
    final DateTime now = DateTime.now();

    final List<Map<String, Object?>> rows = await db.query(
      'hub_classes',
      columns: const <String>['subjectId'],
      where: 'id = ?',
      whereArgs: <Object?>[classId],
      limit: 1,
    );
    final String subjectId =
        rows.isEmpty ? 'study' : rows.first['subjectId'] as String? ?? 'study';

    final bool hasRecordingBacklogTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );
    if (hasRecordingBacklogTable) {
      await db.insert('hub_recordings', <String, Object?>{
        'classId': classId,
        'subjectId': subjectId,
        'occurrenceDate': _dateOnly(plannedAt).toIso8601String(),
        'plannedAt': plannedAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'completed': 0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
    }

    await db.update(
      'hub_classes',
      <String, Object?>{
        'attendanceStatus': HubAttendanceStatus.missed.dbValue,
        'recordingPlannedAt': plannedAt.toIso8601String(),
        'recordingDurationMinutes': durationMinutes,
        'recordingCompleted': 0,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[classId],
    );
  }

  @override
  Future<int> scheduleAutomaticRecordingCatchUp({
    required int classId,
    required DateTime occurrenceDate,
  }) async {
    final db = await _database.database;
    final DateTime now = DateTime.now();

    final List<Map<String, Object?>> classRows = await db.query(
      'hub_classes',
      columns: const <String>['subjectId', 'durationMinutes'],
      where: 'id = ?',
      whereArgs: <Object?>[classId],
      limit: 1,
    );
    if (classRows.isEmpty) {
      return 0;
    }

    final Map<String, Object?> classRow = classRows.first;
    final String subjectId = classRow['subjectId'] as String? ?? 'study';
    final int durationMinutes =
        ((classRow['durationMinutes'] as num?)?.toInt() ?? 60).clamp(15, 360);

    final bool hasRecordingBacklogTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );
    if (!hasRecordingBacklogTable) {
      final DateTime fallbackPlannedAt = _roundToQuarterHour(
        now.add(const Duration(minutes: 20)),
      );
      await scheduleRecording(
        classId: classId,
        plannedAt: fallbackPlannedAt,
        durationMinutes: durationMinutes,
      );
      return 1;
    }

    DateTime searchStart = _roundToQuarterHour(
      now.add(const Duration(minutes: 20)),
    );
    final List<Map<String, Object?>> latestPendingRows = await db.query(
      'hub_recordings',
      columns: const <String>['plannedAt'],
      where: 'classId = ? AND completed = 0',
      whereArgs: <Object?>[classId],
      orderBy: 'plannedAt DESC, id DESC',
      limit: 1,
    );
    if (latestPendingRows.isNotEmpty) {
      final DateTime? latestPendingAt = DateTime.tryParse(
        latestPendingRows.first['plannedAt'] as String? ?? '',
      );
      if (latestPendingAt != null) {
        final DateTime dayAfterLatest = _dateOnly(
          latestPendingAt,
        ).add(const Duration(days: 1, hours: 7));
        if (dayAfterLatest.isAfter(searchStart)) {
          searchStart = dayAfterLatest;
        }
      }
    }

    final DateTime plannedAt = await _findNextFreeSlot(
      db: db,
      searchStart: searchStart,
      durationMinutes: durationMinutes,
    );

    await db.insert('hub_recordings', <String, Object?>{
      'classId': classId,
      'subjectId': subjectId,
      'occurrenceDate': _dateOnly(occurrenceDate).toIso8601String(),
      'plannedAt': plannedAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': 0,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    await db.update(
      'hub_classes',
      <String, Object?>{
        'attendanceStatus': HubAttendanceStatus.missed.dbValue,
        'recordingPlannedAt': plannedAt.toIso8601String(),
        'recordingDurationMinutes': durationMinutes,
        'recordingCompleted': 0,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[classId],
    );

    final int pendingCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM hub_recordings WHERE classId = ? AND completed = 0',
            <Object?>[classId],
          ),
        ) ??
        0;
    return pendingCount;
  }

  @override
  Future<void> setRecordingCompleted({
    required int classId,
    required bool completed,
  }) async {
    final db = await _database.database;
    final DateTime now = DateTime.now();

    final bool hasRecordingBacklogTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );

    if (hasRecordingBacklogTable) {
      if (completed) {
        final List<Map<String, Object?>> pendingRows = await db.query(
          'hub_recordings',
          columns: const <String>['id'],
          where: 'classId = ? AND completed = 0',
          whereArgs: <Object?>[classId],
          orderBy: 'plannedAt ASC, id ASC',
          limit: 1,
        );
        if (pendingRows.isNotEmpty) {
          await db.update(
            'hub_recordings',
            <String, Object?>{
              'completed': 1,
              'updatedAt': now.toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: <Object?>[(pendingRows.first['id'] as num?)?.toInt()],
          );
        }
      } else {
        final List<Map<String, Object?>> watchedRows = await db.query(
          'hub_recordings',
          columns: const <String>['id'],
          where: 'classId = ? AND completed = 1',
          whereArgs: <Object?>[classId],
          orderBy: 'updatedAt DESC, id DESC',
          limit: 1,
        );
        if (watchedRows.isNotEmpty) {
          await db.update(
            'hub_recordings',
            <String, Object?>{
              'completed': 0,
              'updatedAt': now.toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: <Object?>[(watchedRows.first['id'] as num?)?.toInt()],
          );
        }
      }
    }

    await db.update(
      'hub_classes',
      <String, Object?>{
        'recordingCompleted': completed ? 1 : 0,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[classId],
    );
  }

  @override
  Future<void> deleteClassSchedule(int classId) async {
    final db = await _database.database;
    final bool hasRecordingBacklogTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );

    await db.transaction((txn) async {
      if (hasRecordingBacklogTable) {
        await txn.delete(
          'hub_recordings',
          where: 'classId = ?',
          whereArgs: <Object?>[classId],
        );
      }

      await txn.delete(
        'hub_classes',
        where: 'id = ?',
        whereArgs: <Object?>[classId],
      );
    });
  }

  Future<DateTime> _findNextFreeSlot({
    required dynamic db,
    required DateTime searchStart,
    required int durationMinutes,
  }) async {
    final DateTime normalizedStart = _roundToQuarterHour(searchStart);
    final int boundedDuration = durationMinutes.clamp(15, 360);

    for (int dayOffset = 0; dayOffset < 120; dayOffset += 1) {
      final DateTime day = _dateOnly(
        normalizedStart,
      ).add(Duration(days: dayOffset));
      DateTime windowStart = day.add(const Duration(hours: 6));
      final DateTime windowEnd = day.add(
        const Duration(hours: 22, minutes: 30),
      );

      if (dayOffset == 0 && normalizedStart.isAfter(windowStart)) {
        windowStart = normalizedStart;
      }
      if (!windowEnd.isAfter(windowStart)) {
        continue;
      }

      final DateTime latestStart = windowEnd.subtract(
        Duration(minutes: boundedDuration),
      );
      if (latestStart.isBefore(windowStart)) {
        continue;
      }

      final List<_BusyRange> busy = await _busyRangesForDay(db: db, day: day);
      DateTime candidate = _roundToQuarterHour(windowStart);
      while (!candidate.isAfter(latestStart)) {
        final DateTime end = candidate.add(Duration(minutes: boundedDuration));
        if (!_overlapsAny(start: candidate, end: end, busy: busy)) {
          return candidate;
        }
        candidate = candidate.add(const Duration(minutes: 15));
      }
    }

    return normalizedStart;
  }

  Future<List<_BusyRange>> _busyRangesForDay({
    required dynamic db,
    required DateTime day,
  }) async {
    final DateTime dayStart = _dateOnly(day);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));
    final List<_BusyRange> busy = <_BusyRange>[];

    final List<Map<String, Object?>> plannedRows = await db.rawQuery(
      '''
      SELECT startAt, endAt
      FROM planned_items
      WHERE startAt < ?
        AND endAt > ?
      ''',
      <Object?>[dayEnd.toIso8601String(), dayStart.toIso8601String()],
    );
    for (final Map<String, Object?> row in plannedRows) {
      final DateTime? start = DateTime.tryParse(
        row['startAt'] as String? ?? '',
      );
      final DateTime? end = DateTime.tryParse(row['endAt'] as String? ?? '');
      if (start == null || end == null || !end.isAfter(start)) {
        continue;
      }
      busy.add(_BusyRange(start: start, end: end));
    }

    final bool hasRecordingBacklogTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );
    if (hasRecordingBacklogTable) {
      final List<Map<String, Object?>> recordingRows = await db.rawQuery(
        '''
        SELECT plannedAt, durationMinutes
        FROM hub_recordings
        WHERE completed = 0
          AND plannedAt >= ?
          AND plannedAt < ?
        ''',
        <Object?>[dayStart.toIso8601String(), dayEnd.toIso8601String()],
      );
      for (final Map<String, Object?> row in recordingRows) {
        final DateTime? plannedAt = DateTime.tryParse(
          row['plannedAt'] as String? ?? '',
        );
        final int durationMinutes =
            (row['durationMinutes'] as num?)?.toInt() ?? 0;
        if (plannedAt == null || durationMinutes <= 0) {
          continue;
        }
        final DateTime start = plannedAt.subtract(
          const Duration(minutes: _recordingCooldownMinutes),
        );
        final DateTime end = plannedAt.add(
          Duration(minutes: durationMinutes + _recordingCooldownMinutes),
        );
        busy.add(_BusyRange(start: start, end: end));
      }
    }

    final List<Map<String, Object?>> classRows = await db.query(
      'hub_classes',
      columns: const <String>[
        'weekday',
        'startMinutes',
        'durationMinutes',
        'startDate',
        'endDate',
      ],
    );
    for (final Map<String, Object?> row in classRows) {
      final int weekday = ((row['weekday'] as num?)?.toInt() ?? 1).clamp(1, 7);
      if (weekday != dayStart.weekday) {
        continue;
      }

      final DateTime? startDate = DateTime.tryParse(
        row['startDate'] as String? ?? '',
      );
      final DateTime? endDate = DateTime.tryParse(
        row['endDate'] as String? ?? '',
      );
      if (!_isDateWithinClassRange(
        day: dayStart,
        startDate: startDate,
        endDate: endDate,
      )) {
        continue;
      }

      final int startMinutes = ((row['startMinutes'] as num?)?.toInt() ?? 0)
          .clamp(0, 1439);
      final int durationMinutes =
          ((row['durationMinutes'] as num?)?.toInt() ?? 0).clamp(0, 600);
      if (durationMinutes <= 0) {
        continue;
      }

      final DateTime start = dayStart.add(Duration(minutes: startMinutes));
      final DateTime end = start.add(Duration(minutes: durationMinutes));
      busy.add(_BusyRange(start: start, end: end));
    }

    busy.sort((a, b) => a.start.compareTo(b.start));
    return busy;
  }

  bool _overlapsAny({
    required DateTime start,
    required DateTime end,
    required List<_BusyRange> busy,
  }) {
    for (final _BusyRange slot in busy) {
      final bool overlaps = start.isBefore(slot.end) && end.isAfter(slot.start);
      if (overlaps) {
        return true;
      }
    }
    return false;
  }

  List<DateTime> _occurrenceDaysUntilToday({
    required DateTime startDate,
    required int weekday,
    required DateTime today,
  }) {
    final DateTime normalizedStart = _dateOnly(startDate);
    final DateTime normalizedToday = _dateOnly(today);
    if (normalizedStart.isAfter(normalizedToday)) {
      return const <DateTime>[];
    }

    final int offset = (weekday - normalizedStart.weekday + 7) % 7;
    DateTime first = normalizedStart.add(Duration(days: offset));
    if (first.isAfter(normalizedToday)) {
      return const <DateTime>[];
    }

    final List<DateTime> days = <DateTime>[];
    while (!first.isAfter(normalizedToday)) {
      days.add(first);
      first = first.add(const Duration(days: 7));
    }
    return days;
  }

  bool _isDateWithinClassRange({
    required DateTime day,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    final DateTime normalizedDay = _dateOnly(day);
    if (startDate != null && normalizedDay.isBefore(_dateOnly(startDate))) {
      return false;
    }
    if (endDate != null && normalizedDay.isAfter(_dateOnly(endDate))) {
      return false;
    }
    return true;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _roundToQuarterHour(DateTime value) {
    int minute = value.minute;
    int remainder = minute % 15;
    DateTime rounded = value;
    if (remainder != 0) {
      rounded = rounded.add(Duration(minutes: 15 - remainder));
    }
    return DateTime(
      rounded.year,
      rounded.month,
      rounded.day,
      rounded.hour,
      rounded.minute,
    );
  }

  Future<bool> _tableExists({
    required dynamic db,
    required String tableName,
  }) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      <Object?>['table', tableName],
    );
    return rows.isNotEmpty;
  }
}

class _RecordingRollup {
  int pendingCount = 0;
  int completedCount = 0;
  DateTime? nextPendingAt;
  int? nextPendingDurationMinutes;
}

class _BusyRange {
  const _BusyRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
