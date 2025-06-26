import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_session_model.freezed.dart';
part 'study_session_model.g.dart';

/// Represents a single study session for a subject.
@freezed
class StudySession with _$StudySession {
  const factory StudySession({
    required String id,
    required String subjectId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    @Default('') String notes,
  }) = _StudySession;

  factory StudySession.fromJson(Map<String, dynamic> json) =>
      _$StudySessionFromJson(json);
}
