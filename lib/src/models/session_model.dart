import 'package:flutter/foundation.dart';

class Session {
  final String id;
  final String projectId;
  final String projectName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;

  Session({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      projectId: map['projectId'],
      projectName: map['projectName'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      durationMinutes: map['durationMinutes'],
    );
  }
}
