import '../models/study_analytics.dart';

/// Repository interface for analytics data
abstract class AnalyticsRepository {
  /// Get analytics data for the specified time range
  Future<StudyAnalytics> getAnalytics(AnalyticsTimeRange timeRange);

  /// Get daily study data for a date range
  Future<List<DailyStudyData>> getDailyData(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get subject analytics for all subjects
  Future<List<SubjectAnalytics>> getSubjectAnalytics(
    AnalyticsTimeRange timeRange,
  );

  /// Get study insights based on historical data
  Future<StudyInsights> getStudyInsights(AnalyticsTimeRange timeRange);

  /// Get achievements earned in the specified time range
  Future<List<Achievement>> getAchievements({
    AnalyticsTimeRange? timeRange,
    bool newOnly = false,
  });

  /// Mark achievements as viewed (removes "new" status)
  Future<void> markAchievementsAsViewed(List<String> achievementIds);

  /// Record a study session for analytics
  Future<void> recordStudySession({
    required String subjectId,
    required DateTime startTime,
    required DateTime endTime,
    required Duration duration,
  });

  /// Get study streak information
  Future<StudyStreak> getCurrentStreak();

  /// Get weekly study goal progress (0.0 to 1.0)
  Future<double> getWeeklyGoalProgress();
}
