import '../domain/models/study_session_model.dart';
import '../domain/repositories/study_session_repository.dart';
import 'hive_data_service.dart';

/// Persistent implementation of [StudySessionRepository] using Hive
/// Replaces the in-memory implementation with robust local storage
class HiveStudySessionRepositoryImpl implements StudySessionRepository {
  @override
  Future<List<StudySession>> getStudySessions() async {
    final box = HiveDataService.studySessionsBox;
    return box.values.toList();
  }

  @override
  Future<void> addStudySession(StudySession session) async {
    final box = HiveDataService.studySessionsBox;
    await box.put(session.id, session);
  }

  @override
  Future<void> updateStudySession(StudySession session) async {
    final box = HiveDataService.studySessionsBox;
    await box.put(session.id, session);
  }

  @override
  Future<void> deleteStudySession(String sessionId) async {
    final box = HiveDataService.studySessionsBox;
    await box.delete(sessionId);
  }

  /// Get study sessions for a specific subject
  Future<List<StudySession>> getStudySessionsBySubject(String subjectId) async {
    final box = HiveDataService.studySessionsBox;
    return box.values
        .where((session) => session.subjectId == subjectId)
        .toList();
  }

  /// Get study sessions within a date range
  Future<List<StudySession>> getStudySessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final box = HiveDataService.studySessionsBox;
    return box.values
        .where(
          (session) =>
              session.startTime.isAfter(startDate) &&
              session.startTime.isBefore(endDate),
        )
        .toList();
  }

  /// Get total study time for a subject (in minutes)
  Future<int> getTotalStudyTimeForSubject(String subjectId) async {
    final sessions = await getStudySessionsBySubject(subjectId);
    return sessions.fold<int>(
      0,
      (total, session) => total + session.durationMinutes,
    );
  }

  /// Get total study time for all subjects (in minutes)
  Future<int> getTotalStudyTime() async {
    final sessions = await getStudySessions();
    return sessions.fold<int>(
      0,
      (total, session) => total + session.durationMinutes,
    );
  }

  /// Get study sessions count for analytics
  Future<int> getStudySessionsCount() async {
    final box = HiveDataService.studySessionsBox;
    return box.length;
  }

  /// Get the most recent study session
  Future<StudySession?> getLastStudySession() async {
    final box = HiveDataService.studySessionsBox;
    if (box.isEmpty) return null;

    final sessions = box.values.toList();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions.first;
  }

  /// Clear all study sessions (useful for testing or reset functionality)
  Future<void> clearAllStudySessions() async {
    final box = HiveDataService.studySessionsBox;
    await box.clear();
  }

  /// Get study sessions by today
  Future<List<StudySession>> getTodaysStudySessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getStudySessionsByDateRange(startOfDay, endOfDay);
  }

  /// Get study sessions by current week
  Future<List<StudySession>> getThisWeeksStudySessions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return await getStudySessionsByDateRange(startOfWeek, endOfWeek);
  }
}
