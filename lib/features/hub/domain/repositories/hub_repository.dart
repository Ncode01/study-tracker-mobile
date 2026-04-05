import '../../../../core/data/local/app_database.dart';
import '../models/hub_class_schedule.dart';

abstract class HubRepository {
  Future<List<HubClassSchedule>> loadClassSchedules();
  Future<int> addClassSchedule({
    required String subjectId,
    required String teacherName,
    required int weekday,
    required int startMinutes,
    required int durationMinutes,
  });
  Future<void> updateClassAttendance({
    required int classId,
    required HubAttendanceStatus status,
  });
  Future<void> scheduleRecording({
    required int classId,
    required DateTime plannedAt,
    required int durationMinutes,
  });
  Future<void> setRecordingCompleted({
    required int classId,
    required bool completed,
  });
  Future<void> deleteClassSchedule(int classId);
}

class SqliteHubRepository implements HubRepository {
  SqliteHubRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  @override
  Future<List<HubClassSchedule>> loadClassSchedules() async {
    final db = await _database.database;
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
      final String? recordingRaw = row['recordingPlannedAt'] as String?;
      final DateTime? recordingPlannedAt =
          recordingRaw == null || recordingRaw.isEmpty
              ? null
              : DateTime.tryParse(recordingRaw);

      classes.add(
        HubClassSchedule(
          id: (row['id'] as num?)?.toInt() ?? 0,
          subjectId: subjectId,
          teacherName: row['teacherName'] as String? ?? 'Unknown Teacher',
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
          recordingDurationMinutes:
              (row['recordingDurationMinutes'] as num?)?.toInt(),
          recordingCompleted: (row['recordingCompleted'] as num?)?.toInt() == 1,
          createdAt:
              DateTime.tryParse(row['createdAt'] as String? ?? '') ?? now,
          updatedAt:
              DateTime.tryParse(row['updatedAt'] as String? ?? '') ?? now,
        ),
      );
    }

    return classes;
  }

  @override
  Future<int> addClassSchedule({
    required String subjectId,
    required String teacherName,
    required int weekday,
    required int startMinutes,
    required int durationMinutes,
  }) async {
    final db = await _database.database;
    final DateTime now = DateTime.now();

    return db.insert('hub_classes', <String, Object?>{
      'subjectId': subjectId,
      'teacherName': teacherName.trim(),
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
  Future<void> setRecordingCompleted({
    required int classId,
    required bool completed,
  }) async {
    final db = await _database.database;
    final DateTime now = DateTime.now();

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
    await db.delete(
      'hub_classes',
      where: 'id = ?',
      whereArgs: <Object?>[classId],
    );
  }
}
