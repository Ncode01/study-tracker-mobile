import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'study_session_model.freezed.dart';
part 'study_session_model.g.dart';

/// Represents a single study session for a subject with Hive persistence
@freezed
@HiveType(typeId: 1)
class StudySession with _$StudySession {
  const factory StudySession({
    @HiveField(0) required String id,
    @HiveField(1) required String subjectId,
    @HiveField(2) required DateTime startTime,
    @HiveField(3) required DateTime endTime,
    @HiveField(4) required int durationMinutes,
    @HiveField(5) @Default('') String notes,
  }) = _StudySession;

  factory StudySession.fromJson(Map<String, dynamic> json) =>
      _$StudySessionFromJson(json);
}
