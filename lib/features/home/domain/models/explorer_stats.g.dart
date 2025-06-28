// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExplorerStatsImpl _$$ExplorerStatsImplFromJson(Map<String, dynamic> json) =>
    _$ExplorerStatsImpl(
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      totalSessionsThisWeek: (json['totalSessionsThisWeek'] as num).toInt(),
      totalTimeThisWeek:
          Duration(microseconds: (json['totalTimeThisWeek'] as num).toInt()),
      recentAchievements: (json['recentAchievements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      progressToNextLevel: (json['progressToNextLevel'] as num).toDouble(),
      currentRank: json['currentRank'] as String,
      totalXP: (json['totalXP'] as num).toInt(),
      xpToNextLevel: (json['xpToNextLevel'] as num).toInt(),
    );

Map<String, dynamic> _$$ExplorerStatsImplToJson(_$ExplorerStatsImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalSessionsThisWeek': instance.totalSessionsThisWeek,
      'totalTimeThisWeek': instance.totalTimeThisWeek.inMicroseconds,
      'recentAchievements': instance.recentAchievements,
      'progressToNextLevel': instance.progressToNextLevel,
      'currentRank': instance.currentRank,
      'totalXP': instance.totalXP,
      'xpToNextLevel': instance.xpToNextLevel,
    };
