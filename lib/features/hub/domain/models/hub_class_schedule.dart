enum HubAttendanceStatus { pending, attended, missed }

extension HubAttendanceStatusX on HubAttendanceStatus {
  String get dbValue {
    return switch (this) {
      HubAttendanceStatus.pending => 'pending',
      HubAttendanceStatus.attended => 'attended',
      HubAttendanceStatus.missed => 'missed',
    };
  }

  String get label {
    return switch (this) {
      HubAttendanceStatus.pending => 'Pending',
      HubAttendanceStatus.attended => 'Attended',
      HubAttendanceStatus.missed => 'Missed',
    };
  }

  static HubAttendanceStatus fromDb(String raw) {
    return switch (raw) {
      'attended' => HubAttendanceStatus.attended,
      'missed' => HubAttendanceStatus.missed,
      _ => HubAttendanceStatus.pending,
    };
  }
}

class HubClassSchedule {
  const HubClassSchedule({
    required this.id,
    required this.subjectId,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.weekday,
    required this.startMinutes,
    required this.durationMinutes,
    required this.attendanceStatus,
    required this.recordingPlannedAt,
    required this.recordingDurationMinutes,
    required this.recordingCompleted,
    required this.pendingRecordingCount,
    required this.completedRecordingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String subjectId;
  final String teacherName;
  final DateTime startDate;
  final DateTime? endDate;
  final int weekday;
  final int startMinutes;
  final int durationMinutes;
  final HubAttendanceStatus attendanceStatus;
  final DateTime? recordingPlannedAt;
  final int? recordingDurationMinutes;
  final bool recordingCompleted;
  final int pendingRecordingCount;
  final int completedRecordingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  HubClassSchedule copyWith({
    int? id,
    String? subjectId,
    String? teacherName,
    DateTime? startDate,
    DateTime? endDate,
    int? weekday,
    int? startMinutes,
    int? durationMinutes,
    HubAttendanceStatus? attendanceStatus,
    DateTime? recordingPlannedAt,
    int? recordingDurationMinutes,
    bool? recordingCompleted,
    int? pendingRecordingCount,
    int? completedRecordingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HubClassSchedule(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      teacherName: teacherName ?? this.teacherName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weekday: weekday ?? this.weekday,
      startMinutes: startMinutes ?? this.startMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      recordingPlannedAt: recordingPlannedAt ?? this.recordingPlannedAt,
      recordingDurationMinutes:
          recordingDurationMinutes ?? this.recordingDurationMinutes,
      recordingCompleted: recordingCompleted ?? this.recordingCompleted,
      pendingRecordingCount:
          pendingRecordingCount ?? this.pendingRecordingCount,
      completedRecordingCount:
          completedRecordingCount ?? this.completedRecordingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
