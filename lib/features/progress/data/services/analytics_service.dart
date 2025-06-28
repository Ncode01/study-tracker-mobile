import '../../../study/domain/models/subject_model.dart';
import '../../../study/domain/models/study_session_model.dart';
import '../../domain/models/study_analytics.dart';

/// Service for calculating analytics from raw study session data
class AnalyticsService {
  /// Calculate analytics for the given time range
  StudyAnalytics calculateAnalytics({
    required List<StudySession> sessions,
    required List<Subject> subjects,
    required AnalyticsTimeRange timeRange,
    required DateTime now,
  }) {
    final periodEnd = now;
    final periodStart = periodEnd.subtract(timeRange.duration);

    // Filter sessions to the time range
    final filteredSessions =
        sessions
            .where(
              (session) =>
                  session.startTime.isAfter(periodStart) &&
                  session.startTime.isBefore(periodEnd),
            )
            .toList();

    // Calculate total study time
    final totalStudyTime = filteredSessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + Duration(minutes: session.durationMinutes),
    );

    // Generate daily data (simplified for now)
    final dailyData = <DailyStudyData>[];
    for (var i = 0; i < 7; i++) {
      final date = periodStart.add(Duration(days: i));
      final dayDuration = i * 30; // Mock data: increasing study time
      dailyData.add(
        DailyStudyData(
          date: date,
          studyTime: Duration(minutes: dayDuration),
          sessionsCompleted: i == 0 ? 0 : 1,
          subjectBreakdown:
              i == 0 ? {} : {'subject_1': Duration(minutes: dayDuration)},
        ),
      );
    }

    // Calculate subject breakdown (simplified)
    final subjectBreakdown =
        subjects.take(3).map((subject) {
          final subjectSessions =
              filteredSessions
                  .where((session) => session.subjectId == subject.id)
                  .toList();

          final totalTime = subjectSessions.fold<Duration>(
            Duration.zero,
            (sum, session) => sum + Duration(minutes: session.durationMinutes),
          );

          return SubjectAnalytics(
            subjectId: subject.id,
            subjectName: subject.name,
            totalTime: totalTime,
            sessionsCompleted: subjectSessions.length,
            averageSessionDuration:
                subjectSessions.isNotEmpty
                    ? totalTime.inMinutes / subjectSessions.length
                    : 0,
            lastStudied:
                subjectSessions.isNotEmpty
                    ? subjectSessions.last.startTime
                    : DateTime.now().subtract(const Duration(days: 30)),
            trend: StudyTrend.stable,
          );
        }).toList(); // Calculate insights (simplified)
    final insights = StudyInsights(
      currentStreak: StudyStreak(
        days: 5,
        startDate: now.subtract(const Duration(days: 4)),
        endDate: null, // null for ongoing streak
      ),
      longestStreak: StudyStreak(
        days: 12,
        startDate: now.subtract(const Duration(days: 20)),
        endDate: now.subtract(const Duration(days: 8)),
      ),
      mostProductiveTime: const TimeOfDay(hour: 14, minute: 0),
      mostProductiveDay: DayOfWeek.tuesday,
      weeklyGoalProgress: 0.75,
      averageDailyStudyTime: const Duration(hours: 2),
      recommendedSubjects: subjects.take(2).map((s) => s.id).toList(),
    );

    // Generate achievements (simplified)
    final achievements = <Achievement>[
      Achievement(
        id: 'streak_5',
        title: 'Study Streak',
        description: 'Studied for 5 days in a row!',
        type: AchievementType.streak,
        unlockedAt: now,
        isNew: true,
      ),
      Achievement(
        id: 'time_10h',
        title: 'Time Explorer',
        description: 'Completed 10 hours of study!',
        type: AchievementType.studyTime,
        unlockedAt: now.subtract(const Duration(days: 3)),
        isNew: false,
      ),
    ];

    return StudyAnalytics(
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalStudyTime: totalStudyTime,
      dailyData: dailyData,
      subjectBreakdown: subjectBreakdown,
      insights: insights,
      achievements: achievements,
    );
  }
}
