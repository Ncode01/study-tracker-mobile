import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_analytics.freezed.dart';
part 'study_analytics.g.dart';

/// Represents analytics data for study progress
@freezed
class StudyAnalytics with _$StudyAnalytics {
  const factory StudyAnalytics({
    required DateTime periodStart,
    required DateTime periodEnd,
    required Duration totalStudyTime,
    required List<DailyStudyData> dailyData,
    required List<SubjectAnalytics> subjectBreakdown,
    required StudyInsights insights,
    required List<Achievement> achievements,
  }) = _StudyAnalytics;

  factory StudyAnalytics.fromJson(Map<String, dynamic> json) =>
      _$StudyAnalyticsFromJson(json);
}

/// Daily study data point
@freezed
class DailyStudyData with _$DailyStudyData {
  const factory DailyStudyData({
    required DateTime date,
    required Duration studyTime,
    required int sessionsCompleted,
    required Map<String, Duration> subjectBreakdown, // subjectId -> duration
  }) = _DailyStudyData;

  factory DailyStudyData.fromJson(Map<String, dynamic> json) =>
      _$DailyStudyDataFromJson(json);
}

/// Analytics for a specific subject
@freezed
class SubjectAnalytics with _$SubjectAnalytics {
  const factory SubjectAnalytics({
    required String subjectId,
    required String subjectName,
    required Duration totalTime,
    required int sessionsCompleted,
    required double averageSessionDuration, // in minutes
    required DateTime lastStudied,
    required StudyTrend trend,
  }) = _SubjectAnalytics;

  factory SubjectAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SubjectAnalyticsFromJson(json);
}

/// Study insights and patterns
@freezed
class StudyInsights with _$StudyInsights {
  const factory StudyInsights({
    required StudyStreak currentStreak,
    required StudyStreak longestStreak,
    required TimeOfDay mostProductiveTime,
    required DayOfWeek mostProductiveDay,
    required double weeklyGoalProgress, // 0.0 to 1.0
    required Duration averageDailyStudyTime,
    required List<String> recommendedSubjects, // subject IDs
  }) = _StudyInsights;

  factory StudyInsights.fromJson(Map<String, dynamic> json) =>
      _$StudyInsightsFromJson(json);
}

/// Study streak information
@freezed
class StudyStreak with _$StudyStreak {
  const factory StudyStreak({
    required int days,
    required DateTime startDate,
    required DateTime? endDate, // null for ongoing streak
  }) = _StudyStreak;

  factory StudyStreak.fromJson(Map<String, dynamic> json) =>
      _$StudyStreakFromJson(json);
}

/// Time of day preference
@freezed
class TimeOfDay with _$TimeOfDay {
  const factory TimeOfDay({
    required int hour, // 0-23
    required int minute, // 0-59
  }) = _TimeOfDay;

  factory TimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayFromJson(json);
}

/// Day of week enum
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }
}

/// Study trend direction
enum StudyTrend {
  increasing,
  decreasing,
  stable;

  String get displayName {
    switch (this) {
      case StudyTrend.increasing:
        return 'Improving';
      case StudyTrend.decreasing:
        return 'Declining';
      case StudyTrend.stable:
        return 'Stable';
    }
  }
}

/// Achievement earned by the user
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required AchievementType type,
    required DateTime unlockedAt,
    required bool isNew, // for showing celebration
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Types of achievements
enum AchievementType {
  streak,
  studyTime,
  consistency,
  subject,
  milestone;

  String get displayName {
    switch (this) {
      case AchievementType.streak:
        return 'Streak';
      case AchievementType.studyTime:
        return 'Study Time';
      case AchievementType.consistency:
        return 'Consistency';
      case AchievementType.subject:
        return 'Subject Mastery';
      case AchievementType.milestone:
        return 'Milestone';
    }
  }
}

/// Time range for analytics
enum AnalyticsTimeRange {
  week,
  month,
  quarter,
  year;

  String get displayName {
    switch (this) {
      case AnalyticsTimeRange.week:
        return 'This Week';
      case AnalyticsTimeRange.month:
        return 'This Month';
      case AnalyticsTimeRange.quarter:
        return 'Last 3 Months';
      case AnalyticsTimeRange.year:
        return 'This Year';
    }
  }

  Duration get duration {
    switch (this) {
      case AnalyticsTimeRange.week:
        return const Duration(days: 7);
      case AnalyticsTimeRange.month:
        return const Duration(days: 30);
      case AnalyticsTimeRange.quarter:
        return const Duration(days: 90);
      case AnalyticsTimeRange.year:
        return const Duration(days: 365);
    }
  }
}
