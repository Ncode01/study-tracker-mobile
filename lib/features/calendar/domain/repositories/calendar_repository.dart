import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/local/app_database.dart';
import '../models/planned_item.dart';

abstract class CalendarRepository {
  Future<List<CalendarCategoryOption>> loadCategories();
  Future<List<CalendarActualSession>> loadActualSessions({
    required DateTime selectedDate,
  });
  Future<List<PlannedItem>> loadPlannedItems({required DateTime selectedDate});
  Future<int> createPlannedItem(PlannedItemDraft draft);
  Future<void> updatePlannedItem(PlannedItem item);
  Future<void> deletePlannedItem(int id);
}

class SqliteCalendarRepository implements CalendarRepository {
  SqliteCalendarRepository({
    required AppDatabase database,
    required SharedPreferences preferences,
  }) : _database = database,
       _preferences = preferences;

  static const String _selectedCategoryKey = 'selected_category_id';
  static const String _timerSessionStartTimeKey = 'timer_session_start_time_ms';

  final AppDatabase _database;
  final SharedPreferences _preferences;

  @override
  Future<List<CalendarCategoryOption>> loadCategories() async {
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'categories',
      columns: const <String>['id', 'title', 'accentColorValue'],
      orderBy: 'rowid ASC',
    );

    return rows
        .map(
          (Map<String, Object?> row) => CalendarCategoryOption(
            id: row['id'] as String? ?? 'study',
            title: row['title'] as String? ?? 'Study',
            accentColor: Color(row['accentColorValue'] as int? ?? 0xFF64748B),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<CalendarActualSession>> loadActualSessions({
    required DateTime selectedDate,
  }) async {
    final Database db = await _database.database;
    final DateTime startOfDay = _startOfDay(selectedDate);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT
        s.categoryId,
        s.startedAt,
        s.endedAt,
        c.title AS categoryTitle,
        c.accentColorValue AS accentColorValue
      FROM sessions s
      LEFT JOIN categories c ON c.id = s.categoryId
      WHERE s.startedAt < ?
        AND (s.endedAt IS NULL OR s.endedAt > ?)
      ORDER BY s.startedAt ASC
      ''',
      <Object?>[endOfDay.toIso8601String(), startOfDay.toIso8601String()],
    );

    final List<CalendarActualSession> sessions = <CalendarActualSession>[];
    for (final Map<String, Object?> row in rows) {
      final String startedAtRaw = row['startedAt'] as String? ?? '';
      if (startedAtRaw.isEmpty) {
        continue;
      }

      final DateTime? startedAt = DateTime.tryParse(startedAtRaw);
      if (startedAt == null) {
        continue;
      }

      final String? endedAtRaw = row['endedAt'] as String?;
      final DateTime? endedAt =
          endedAtRaw == null || endedAtRaw.isEmpty
              ? null
              : DateTime.tryParse(endedAtRaw);
      if (endedAt != null && !endedAt.isAfter(startedAt)) {
        continue;
      }

      final String categoryId = row['categoryId'] as String? ?? 'study';
      final String categoryTitle =
          row['categoryTitle'] as String? ?? _titleFromCategoryId(categoryId);
      final Color accentColor = Color(
        row['accentColorValue'] as int? ?? 0xFF64748B,
      );

      sessions.add(
        CalendarActualSession(
          categoryId: categoryId,
          categoryTitle: categoryTitle,
          accentColor: accentColor,
          startedAt: startedAt,
          endedAt: endedAt,
          isLive: false,
        ),
      );
    }

    final CalendarActualSession? activeSession = await _loadActiveSession(
      db: db,
      startOfDay: startOfDay,
      endOfDay: endOfDay,
    );
    if (activeSession != null) {
      sessions.add(activeSession);
    }

    sessions.sort(
      (CalendarActualSession a, CalendarActualSession b) =>
          a.startedAt.compareTo(b.startedAt),
    );
    return sessions;
  }

  Future<CalendarActualSession?> _loadActiveSession({
    required Database db,
    required DateTime startOfDay,
    required DateTime endOfDay,
  }) async {
    final String? activeCategoryId = _preferences.getString(
      _selectedCategoryKey,
    );
    final int? activeSessionStartMs = _preferences.getInt(
      _timerSessionStartTimeKey,
    );

    if (activeCategoryId == null || activeSessionStartMs == null) {
      return null;
    }

    final DateTime sessionStart = DateTime.fromMillisecondsSinceEpoch(
      activeSessionStartMs,
    );
    final DateTime now = DateTime.now();

    if (!sessionStart.isBefore(endOfDay) || !now.isAfter(startOfDay)) {
      return null;
    }

    final List<Map<String, Object?>> rows = await db.query(
      'categories',
      columns: const <String>['title', 'accentColorValue'],
      where: 'id = ?',
      whereArgs: <Object?>[activeCategoryId],
      limit: 1,
    );

    final Map<String, Object?>? row = rows.isEmpty ? null : rows.first;
    final String categoryTitle =
        row?['title'] as String? ?? _titleFromCategoryId(activeCategoryId);
    final Color accentColor = Color(
      row?['accentColorValue'] as int? ?? 0xFF64748B,
    );

    return CalendarActualSession(
      categoryId: activeCategoryId,
      categoryTitle: categoryTitle,
      accentColor: accentColor,
      startedAt: sessionStart,
      endedAt: null,
      isLive: true,
    );
  }

  @override
  Future<List<PlannedItem>> loadPlannedItems({
    required DateTime selectedDate,
  }) async {
    final Database db = await _database.database;
    final DateTime startOfDay = _startOfDay(selectedDate);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT
        p.id,
        p.categoryId,
        p.title,
        p.startAt,
        p.endAt,
        p.notes,
        p.createdAt,
        p.updatedAt,
        c.title AS categoryTitle,
        c.accentColorValue AS accentColorValue
      FROM planned_items p
      LEFT JOIN categories c ON c.id = p.categoryId
      WHERE p.startAt < ?
        AND p.endAt > ?
      ORDER BY p.startAt ASC
      ''',
      <Object?>[endOfDay.toIso8601String(), startOfDay.toIso8601String()],
    );

    final List<PlannedItem> items = <PlannedItem>[];
    for (final Map<String, Object?> row in rows) {
      final String startAtRaw = row['startAt'] as String? ?? '';
      final String endAtRaw = row['endAt'] as String? ?? '';
      if (startAtRaw.isEmpty || endAtRaw.isEmpty) {
        continue;
      }

      final DateTime? startAt = DateTime.tryParse(startAtRaw);
      final DateTime? endAt = DateTime.tryParse(endAtRaw);
      if (startAt == null || endAt == null || !endAt.isAfter(startAt)) {
        continue;
      }

      final String categoryId = row['categoryId'] as String? ?? 'study';
      final String categoryTitle =
          row['categoryTitle'] as String? ?? _titleFromCategoryId(categoryId);
      final DateTime createdAt =
          DateTime.tryParse(row['createdAt'] as String? ?? '') ?? startAt;
      final DateTime updatedAt =
          DateTime.tryParse(row['updatedAt'] as String? ?? '') ?? createdAt;

      items.add(
        PlannedItem(
          id: (row['id'] as num?)?.toInt() ?? 0,
          categoryId: categoryId,
          categoryTitle: categoryTitle,
          accentColor: Color(row['accentColorValue'] as int? ?? 0xFF64748B),
          title: row['title'] as String? ?? 'Planned Block',
          startAt: startAt,
          endAt: endAt,
          notes: row['notes'] as String?,
          createdAt: createdAt,
          updatedAt: updatedAt,
          source: PlannedItemSource.manual,
          isEditable: true,
        ),
      );
    }

    final bool hasHubClassesTable = await _tableExists(
      db: db,
      tableName: 'hub_classes',
    );
    if (hasHubClassesTable) {
      final List<PlannedItem> hubItems = await _loadHubGeneratedPlannedItems(
        db: db,
        selectedDate: selectedDate,
      );
      items.addAll(hubItems);
    }

    items.sort(
      (PlannedItem a, PlannedItem b) => a.startAt.compareTo(b.startAt),
    );
    return items;
  }

  Future<List<PlannedItem>> _loadHubGeneratedPlannedItems({
    required Database db,
    required DateTime selectedDate,
  }) async {
    final bool hasStartDate = await _columnExists(
      db: db,
      tableName: 'hub_classes',
      columnName: 'startDate',
    );
    final bool hasEndDate = await _columnExists(
      db: db,
      tableName: 'hub_classes',
      columnName: 'endDate',
    );

    final String startDateSelect =
        hasStartDate ? 'h.startDate AS startDate,' : 'NULL AS startDate,';
    final String endDateSelect =
        hasEndDate ? 'h.endDate AS endDate,' : 'NULL AS endDate,';

    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT
        h.id,
        h.subjectId,
        h.teacherName,
        $startDateSelect
        $endDateSelect
        h.weekday,
        h.startMinutes,
        h.durationMinutes,
        h.attendanceStatus,
        h.recordingPlannedAt,
        h.recordingDurationMinutes,
        h.recordingCompleted,
        h.createdAt,
        h.updatedAt,
        c.title AS categoryTitle,
        c.accentColorValue AS accentColorValue
      FROM hub_classes h
      LEFT JOIN categories c ON c.id = h.subjectId
      ORDER BY h.subjectId ASC, h.weekday ASC, h.startMinutes ASC
    ''');

    final DateTime dayStart = _startOfDay(selectedDate);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));
    final DateTime now = DateTime.now();
    final bool hasHubRecordingsTable = await _tableExists(
      db: db,
      tableName: 'hub_recordings',
    );
    final List<PlannedItem> generated = <PlannedItem>[];

    for (final Map<String, Object?> row in rows) {
      final int classId = (row['id'] as num?)?.toInt() ?? 0;
      if (classId <= 0) {
        continue;
      }

      final String subjectId = row['subjectId'] as String? ?? 'study';
      final String categoryTitle =
          row['categoryTitle'] as String? ?? _titleFromCategoryId(subjectId);
      final Color accentColor = Color(
        row['accentColorValue'] as int? ?? 0xFF64748B,
      );
      final String teacherName = row['teacherName'] as String? ?? 'Teacher';

      final int weekday = ((row['weekday'] as num?)?.toInt() ?? 1).clamp(1, 7);
      final int startMinutes = ((row['startMinutes'] as num?)?.toInt() ?? 0)
          .clamp(0, 1439);
      final int durationMinutes =
          (row['durationMinutes'] as num?)?.toInt() ?? 60;
      final String attendanceStatus =
          row['attendanceStatus'] as String? ?? 'pending';
      final DateTime? startDate = DateTime.tryParse(
        row['startDate'] as String? ?? '',
      );
      final DateTime? endDate = DateTime.tryParse(
        row['endDate'] as String? ?? '',
      );

      final DateTime createdAt =
          DateTime.tryParse(row['createdAt'] as String? ?? '') ?? now;
      final DateTime updatedAt =
          DateTime.tryParse(row['updatedAt'] as String? ?? '') ?? createdAt;

      if (selectedDate.weekday == weekday &&
          durationMinutes > 0 &&
          _isDateWithinClassRange(
            date: selectedDate,
            startDate: startDate,
            endDate: endDate,
          )) {
        final DateTime startAt = dayStart.add(Duration(minutes: startMinutes));
        final DateTime endAt = startAt.add(Duration(minutes: durationMinutes));

        generated.add(
          PlannedItem(
            id: _virtualHubLiveId(classId: classId, day: selectedDate),
            categoryId: subjectId,
            categoryTitle: categoryTitle,
            accentColor: accentColor,
            title: '$categoryTitle Live Class',
            startAt: startAt,
            endAt: endAt,
            notes:
                'Teacher: $teacherName · Live status: ${_hubStatusLabel(attendanceStatus)}',
            createdAt: createdAt,
            updatedAt: updatedAt,
            source: PlannedItemSource.hubLiveClass,
            isEditable: false,
          ),
        );
      }

      if (hasHubRecordingsTable) {
        continue;
      }

      final String? recordingRaw = row['recordingPlannedAt'] as String?;
      final DateTime? recordingPlannedAt =
          recordingRaw == null || recordingRaw.isEmpty
              ? null
              : DateTime.tryParse(recordingRaw);
      final int? recordingDurationMinutes =
          (row['recordingDurationMinutes'] as num?)?.toInt();

      if (recordingPlannedAt != null &&
          recordingDurationMinutes != null &&
          recordingDurationMinutes > 0 &&
          _isSameDate(recordingPlannedAt, selectedDate)) {
        final bool recordingCompleted =
            (row['recordingCompleted'] as num?)?.toInt() == 1;
        generated.add(
          PlannedItem(
            id: _virtualHubRecordingId(recordingId: classId),
            categoryId: subjectId,
            categoryTitle: categoryTitle,
            accentColor: accentColor,
            title: 'Watch $categoryTitle Recording',
            startAt: recordingPlannedAt,
            endAt: recordingPlannedAt.add(
              Duration(minutes: recordingDurationMinutes),
            ),
            notes:
                'Teacher: $teacherName · ${recordingCompleted ? 'Marked watched' : 'Recording catch-up planned'}',
            createdAt: createdAt,
            updatedAt: updatedAt,
            source: PlannedItemSource.hubRecording,
            isEditable: false,
          ),
        );
      }
    }

    if (hasHubRecordingsTable) {
      final List<Map<String, Object?>> recordingRows = await db.rawQuery(
        '''
        SELECT
          r.id,
          r.classId,
          r.subjectId,
          r.plannedAt,
          r.durationMinutes,
          r.completed,
          r.createdAt,
          r.updatedAt,
          h.teacherName,
          c.title AS categoryTitle,
          c.accentColorValue AS accentColorValue
        FROM hub_recordings r
        LEFT JOIN hub_classes h ON h.id = r.classId
        LEFT JOIN categories c ON c.id = r.subjectId
        WHERE r.plannedAt >= ?
          AND r.plannedAt < ?
        ORDER BY r.plannedAt ASC
      ''',
        <Object?>[dayStart.toIso8601String(), dayEnd.toIso8601String()],
      );

      for (final Map<String, Object?> row in recordingRows) {
        final int recordingId = (row['id'] as num?)?.toInt() ?? 0;
        if (recordingId <= 0) {
          continue;
        }

        final DateTime? plannedAt = DateTime.tryParse(
          row['plannedAt'] as String? ?? '',
        );
        final int durationMinutes =
            (row['durationMinutes'] as num?)?.toInt() ?? 0;
        if (plannedAt == null || durationMinutes <= 0) {
          continue;
        }

        final String subjectId = row['subjectId'] as String? ?? 'study';
        final String categoryTitle =
            row['categoryTitle'] as String? ?? _titleFromCategoryId(subjectId);
        final Color accentColor = Color(
          row['accentColorValue'] as int? ?? 0xFF64748B,
        );
        final String teacherName = row['teacherName'] as String? ?? 'Teacher';
        final bool completed = (row['completed'] as num?)?.toInt() == 1;
        final DateTime createdAt =
            DateTime.tryParse(row['createdAt'] as String? ?? '') ?? now;
        final DateTime updatedAt =
            DateTime.tryParse(row['updatedAt'] as String? ?? '') ?? createdAt;

        generated.add(
          PlannedItem(
            id: _virtualHubRecordingId(recordingId: recordingId),
            categoryId: subjectId,
            categoryTitle: categoryTitle,
            accentColor: accentColor,
            title: 'Watch $categoryTitle Recording',
            startAt: plannedAt,
            endAt: plannedAt.add(Duration(minutes: durationMinutes)),
            notes:
                'Teacher: $teacherName · ${completed ? 'Marked watched' : 'Recording catch-up planned'}',
            createdAt: createdAt,
            updatedAt: updatedAt,
            source: PlannedItemSource.hubRecording,
            isEditable: false,
          ),
        );
      }
    }

    return generated;
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

  Future<bool> _columnExists({
    required Database db,
    required String tableName,
    required String columnName,
  }) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'PRAGMA table_info($tableName)',
    );
    return rows.any((Map<String, Object?> row) {
      return (row['name'] as String?) == columnName;
    });
  }

  int _virtualHubLiveId({required int classId, required DateTime day}) {
    final int compactDate = day.year * 10000 + day.month * 100 + day.day;
    return -(classId * 1000000 + compactDate);
  }

  int _virtualHubRecordingId({required int recordingId}) {
    return -(recordingId * 1000000 + 999999);
  }

  bool _isDateWithinClassRange({
    required DateTime date,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    final DateTime day = _startOfDay(date);
    if (startDate != null && day.isBefore(_startOfDay(startDate))) {
      return false;
    }
    if (endDate != null && day.isAfter(_startOfDay(endDate))) {
      return false;
    }
    return true;
  }

  String _hubStatusLabel(String raw) {
    return switch (raw) {
      'attended' => 'attended',
      'missed' => 'missed',
      _ => 'pending',
    };
  }

  @override
  Future<int> createPlannedItem(PlannedItemDraft draft) async {
    final Database db = await _database.database;
    final DateTime now = DateTime.now();
    final String normalizedTitle = draft.title.trim();

    return db.insert('planned_items', <String, Object?>{
      'categoryId': draft.categoryId,
      'title': normalizedTitle,
      'startAt': draft.startAt.toIso8601String(),
      'endAt': draft.endAt.toIso8601String(),
      'notes': draft.notes?.trim().isEmpty ?? true ? null : draft.notes!.trim(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  @override
  Future<void> updatePlannedItem(PlannedItem item) async {
    if (!item.isEditable || item.id <= 0) {
      return;
    }

    final Database db = await _database.database;
    final DateTime now = DateTime.now();

    await db.update(
      'planned_items',
      <String, Object?>{
        'categoryId': item.categoryId,
        'title': item.title.trim(),
        'startAt': item.startAt.toIso8601String(),
        'endAt': item.endAt.toIso8601String(),
        'notes': item.notes?.trim().isEmpty ?? true ? null : item.notes!.trim(),
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[item.id],
    );
  }

  @override
  Future<void> deletePlannedItem(int id) async {
    if (id <= 0) {
      return;
    }

    final Database db = await _database.database;
    await db.delete('planned_items', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  DateTime _startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
}
