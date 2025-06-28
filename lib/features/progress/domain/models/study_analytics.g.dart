// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyAnalyticsImpl _$$StudyAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$StudyAnalyticsImpl(
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalStudyTime:
          Duration(microseconds: (json['totalStudyTime'] as num).toInt()),
      dailyData: (json['dailyData'] as List<dynamic>)
          .map((e) => DailyStudyData.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjectBreakdown: (json['subjectBreakdown'] as List<dynamic>)
          .map((e) => SubjectAnalytics.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights:
          StudyInsights.fromJson(json['insights'] as Map<String, dynamic>),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$StudyAnalyticsImplToJson(
        _$StudyAnalyticsImpl instance) =>
    <String, dynamic>{
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'totalStudyTime': instance.totalStudyTime.inMicroseconds,
      'dailyData': instance.dailyData,
      'subjectBreakdown': instance.subjectBreakdown,
      'insights': instance.insights,
      'achievements': instance.achievements,
    };

_$DailyStudyDataImpl _$$DailyStudyDataImplFromJson(Map<String, dynamic> json) =>
    _$DailyStudyDataImpl(
      date: DateTime.parse(json['date'] as String),
      studyTime: Duration(microseconds: (json['studyTime'] as num).toInt()),
      sessionsCompleted: (json['sessionsCompleted'] as num).toInt(),
      subjectBreakdown: (json['subjectBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Duration(microseconds: (e as num).toInt())),
      ),
    );

Map<String, dynamic> _$$DailyStudyDataImplToJson(
        _$DailyStudyDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'studyTime': instance.studyTime.inMicroseconds,
      'sessionsCompleted': instance.sessionsCompleted,
      'subjectBreakdown': instance.subjectBreakdown
          .map((k, e) => MapEntry(k, e.inMicroseconds)),
    };

_$SubjectAnalyticsImpl _$$SubjectAnalyticsImplFromJson(
        Map<String, dynamic> json) =>
    _$SubjectAnalyticsImpl(
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      totalTime: Duration(microseconds: (json['totalTime'] as num).toInt()),
      sessionsCompleted: (json['sessionsCompleted'] as num).toInt(),
      averageSessionDuration:
          (json['averageSessionDuration'] as num).toDouble(),
      lastStudied: DateTime.parse(json['lastStudied'] as String),
      trend: $enumDecode(_$StudyTrendEnumMap, json['trend']),
    );

Map<String, dynamic> _$$SubjectAnalyticsImplToJson(
        _$SubjectAnalyticsImpl instance) =>
    <String, dynamic>{
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'totalTime': instance.totalTime.inMicroseconds,
      'sessionsCompleted': instance.sessionsCompleted,
      'averageSessionDuration': instance.averageSessionDuration,
      'lastStudied': instance.lastStudied.toIso8601String(),
      'trend': _$StudyTrendEnumMap[instance.trend]!,
    };

const _$StudyTrendEnumMap = {
  StudyTrend.increasing: 'increasing',
  StudyTrend.decreasing: 'decreasing',
  StudyTrend.stable: 'stable',
};

_$StudyInsightsImpl _$$StudyInsightsImplFromJson(Map<String, dynamic> json) =>
    _$StudyInsightsImpl(
      currentStreak:
          StudyStreak.fromJson(json['currentStreak'] as Map<String, dynamic>),
      longestStreak:
          StudyStreak.fromJson(json['longestStreak'] as Map<String, dynamic>),
      mostProductiveTime: TimeOfDay.fromJson(
          json['mostProductiveTime'] as Map<String, dynamic>),
      mostProductiveDay:
          $enumDecode(_$DayOfWeekEnumMap, json['mostProductiveDay']),
      weeklyGoalProgress: (json['weeklyGoalProgress'] as num).toDouble(),
      averageDailyStudyTime: Duration(
          microseconds: (json['averageDailyStudyTime'] as num).toInt()),
      recommendedSubjects: (json['recommendedSubjects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$StudyInsightsImplToJson(_$StudyInsightsImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'mostProductiveTime': instance.mostProductiveTime,
      'mostProductiveDay': _$DayOfWeekEnumMap[instance.mostProductiveDay]!,
      'weeklyGoalProgress': instance.weeklyGoalProgress,
      'averageDailyStudyTime': instance.averageDailyStudyTime.inMicroseconds,
      'recommendedSubjects': instance.recommendedSubjects,
    };

const _$DayOfWeekEnumMap = {
  DayOfWeek.monday: 'monday',
  DayOfWeek.tuesday: 'tuesday',
  DayOfWeek.wednesday: 'wednesday',
  DayOfWeek.thursday: 'thursday',
  DayOfWeek.friday: 'friday',
  DayOfWeek.saturday: 'saturday',
  DayOfWeek.sunday: 'sunday',
};

_$StudyStreakImpl _$$StudyStreakImplFromJson(Map<String, dynamic> json) =>
    _$StudyStreakImpl(
      days: (json['days'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$StudyStreakImplToJson(_$StudyStreakImpl instance) =>
    <String, dynamic>{
      'days': instance.days,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };

_$TimeOfDayImpl _$$TimeOfDayImplFromJson(Map<String, dynamic> json) =>
    _$TimeOfDayImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeOfDayImplToJson(_$TimeOfDayImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      isNew: json['isNew'] as bool,
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'unlockedAt': instance.unlockedAt.toIso8601String(),
      'isNew': instance.isNew,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.streak: 'streak',
  AchievementType.studyTime: 'studyTime',
  AchievementType.consistency: 'consistency',
  AchievementType.subject: 'subject',
  AchievementType.milestone: 'milestone',
};
