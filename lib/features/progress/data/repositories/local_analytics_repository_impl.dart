import '../../../study/data/local_subject_repository_impl.dart';
import '../../../study/domain/models/study_session_model.dart';
import '../../domain/models/study_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../services/analytics_service.dart';

/// Local implementation of the analytics repository
class LocalAnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsService _analyticsService;
  final LocalSubjectRepositoryImpl _subjectRepository;

  LocalAnalyticsRepositoryImpl(this._analyticsService, this._subjectRepository);

  @override
  Future<StudyAnalytics> getAnalytics(AnalyticsTimeRange timeRange) async {
    // Get all subjects and study sessions
    final subjects = await _subjectRepository.getSubjects();
    final sessions = await _getAllStudySessions();

    return _analyticsService.calculateAnalytics(
      sessions: sessions,
      subjects: subjects,
      timeRange: timeRange,
      now: DateTime.now(),
    );
  }

  @override
  Future<List<DailyStudyData>> getDailyData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sessions = await _getAllStudySessions();
    final filteredSessions =
        sessions
            .where(
              (session) =>
                  session.startTime.isAfter(startDate) &&
                  session.startTime.isBefore(endDate),
            )
            .toList();

    // Use analytics service to generate daily data
    final analytics = _analyticsService.calculateAnalytics(
      sessions: filteredSessions,
      subjects: await _subjectRepository.getSubjects(),
      timeRange: AnalyticsTimeRange.month, // Dummy value
      now: DateTime.now(),
    );

    return analytics.dailyData;
  }

  @override
  Future<List<SubjectAnalytics>> getSubjectAnalytics(
    AnalyticsTimeRange timeRange,
  ) async {
    final analytics = await getAnalytics(timeRange);
    return analytics.subjectBreakdown;
  }

  @override
  Future<StudyInsights> getStudyInsights(AnalyticsTimeRange timeRange) async {
    final analytics = await getAnalytics(timeRange);
    return analytics.insights;
  }

  @override
  Future<List<Achievement>> getAchievements({
    AnalyticsTimeRange? timeRange,
    bool newOnly = false,
  }) async {
    final analytics = await getAnalytics(timeRange ?? AnalyticsTimeRange.year);
    var achievements = analytics.achievements;

    if (newOnly) {
      achievements = achievements.where((a) => a.isNew).toList();
    }

    return achievements;
  }

  @override
  Future<void> markAchievementsAsViewed(List<String> achievementIds) async {
    // TODO: Implement achievement persistence
    // For now, this is a no-op since we generate achievements dynamically
  }

  @override
  Future<void> recordStudySession({
    required String subjectId,
    required DateTime startTime,
    required DateTime endTime,
    required Duration duration,
  }) async {
    // TODO: Implement study session persistence
    // This would save the session to local storage/database
    // For now, this is a no-op since we're using mock data
  }

  @override
  Future<StudyStreak> getCurrentStreak() async {
    final insights = await getStudyInsights(AnalyticsTimeRange.year);
    return insights.currentStreak;
  }

  @override
  Future<double> getWeeklyGoalProgress() async {
    final insights = await getStudyInsights(AnalyticsTimeRange.week);
    return insights.weeklyGoalProgress;
  }

  /// Get all study sessions from storage
  /// TODO: Replace with actual implementation once session persistence is added
  Future<List<StudySession>> _getAllStudySessions() async {
    // For now, return mock data for demonstration
    final now = DateTime.now();
    return [
      // Week 1
      StudySession(
        id: '1',
        subjectId: '1',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1, hours: -1)),
        durationMinutes: 60,
        notes: 'Studied chapter 1',
      ),
      StudySession(
        id: '2',
        subjectId: '2',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.subtract(const Duration(days: 2, hours: -2)),
        durationMinutes: 120,
        notes: 'Practice problems',
      ),
      StudySession(
        id: '3',
        subjectId: '1',
        startTime: now.subtract(const Duration(days: 3)),
        endTime: now.subtract(const Duration(days: 3, hours: -1, minutes: -30)),
        durationMinutes: 90,
        notes: 'Review and notes',
      ),
      // Week 2
      StudySession(
        id: '4',
        subjectId: '3',
        startTime: now.subtract(const Duration(days: 8)),
        endTime: now.subtract(const Duration(days: 8, hours: -2)),
        durationMinutes: 120,
        notes: 'Lab work',
      ),
      StudySession(
        id: '5',
        subjectId: '1',
        startTime: now.subtract(const Duration(days: 10)),
        endTime: now.subtract(const Duration(days: 10, hours: -3)),
        durationMinutes: 180,
        notes: 'Deep study session',
      ),
      // Month ago
      StudySession(
        id: '6',
        subjectId: '2',
        startTime: now.subtract(const Duration(days: 25)),
        endTime: now.subtract(const Duration(days: 25, hours: -1)),
        durationMinutes: 60,
        notes: 'Quick review',
      ),
    ];
  }
}
