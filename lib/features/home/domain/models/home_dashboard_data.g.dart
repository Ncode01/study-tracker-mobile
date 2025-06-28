// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeDashboardDataImpl _$$HomeDashboardDataImplFromJson(
        Map<String, dynamic> json) =>
    _$HomeDashboardDataImpl(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      subjectProgress: (json['subjectProgress'] as List<dynamic>)
          .map((e) => StudyProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: ExplorerStats.fromJson(json['stats'] as Map<String, dynamic>),
      recentSessions: (json['recentSessions'] as List<dynamic>)
          .map((e) => StudySession.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasActiveSession: json['hasActiveSession'] as bool,
      lastRefreshed: DateTime.parse(json['lastRefreshed'] as String),
    );

Map<String, dynamic> _$$HomeDashboardDataImplToJson(
        _$HomeDashboardDataImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'subjectProgress': instance.subjectProgress,
      'stats': instance.stats,
      'recentSessions': instance.recentSessions,
      'hasActiveSession': instance.hasActiveSession,
      'lastRefreshed': instance.lastRefreshed.toIso8601String(),
    };
