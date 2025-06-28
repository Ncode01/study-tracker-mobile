// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyProgressImpl _$$StudyProgressImplFromJson(Map<String, dynamic> json) =>
    _$StudyProgressImpl(
      subject: Subject.fromJson(json['subject'] as Map<String, dynamic>),
      weeklyTime: Duration(microseconds: (json['weeklyTime'] as num).toInt()),
      targetTime: Duration(microseconds: (json['targetTime'] as num).toInt()),
      sessionsThisWeek: (json['sessionsThisWeek'] as num).toInt(),
      lastStudied: DateTime.parse(json['lastStudied'] as String),
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      nextSuggestedTopic: json['nextSuggestedTopic'] as String,
      continentEmoji: json['continentEmoji'] as String,
      level: (json['level'] as num).toInt(),
      xpEarned: (json['xpEarned'] as num).toInt(),
    );

Map<String, dynamic> _$$StudyProgressImplToJson(_$StudyProgressImpl instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'weeklyTime': instance.weeklyTime.inMicroseconds,
      'targetTime': instance.targetTime.inMicroseconds,
      'sessionsThisWeek': instance.sessionsThisWeek,
      'lastStudied': instance.lastStudied.toIso8601String(),
      'completionPercentage': instance.completionPercentage,
      'nextSuggestedTopic': instance.nextSuggestedTopic,
      'continentEmoji': instance.continentEmoji,
      'level': instance.level,
      'xpEarned': instance.xpEarned,
    };
