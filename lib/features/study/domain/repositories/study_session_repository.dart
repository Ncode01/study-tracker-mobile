import '../models/study_session_model.dart';

/// Abstract repository for managing study sessions.
abstract class StudySessionRepository {
  Future<List<StudySession>> getStudySessions();
  Future<void> addStudySession(StudySession session);
  Future<void> updateStudySession(StudySession session);
  Future<void> deleteStudySession(String sessionId);
}
