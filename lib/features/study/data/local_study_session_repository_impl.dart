import '../domain/models/study_session_model.dart';
import '../domain/repositories/study_session_repository.dart';

/// Local in-memory implementation of [StudySessionRepository].
class LocalStudySessionRepositoryImpl implements StudySessionRepository {
  final List<StudySession> _sessions = [];

  @override
  Future<List<StudySession>> getStudySessions() async {
    return _sessions;
  }

  @override
  Future<void> addStudySession(StudySession session) async {
    _sessions.add(session);
  }

  @override
  Future<void> updateStudySession(StudySession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    }
  }

  @override
  Future<void> deleteStudySession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
  }
}
