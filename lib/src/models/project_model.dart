import 'package:flutter/material.dart';

/// Represents a project in the time tracker app.
class Project {
  /// Unique identifier for the project.
  final String id;

  /// Name of the project.
  final String name;

  /// Color used for the project's icon background.
  final Color color;

  /// Total minutes logged for this project.
  final int loggedMinutes;

  /// Goal minutes to be achieved for this project.
  final int goalMinutes;

  /// Optional due date for the project.
  final DateTime? dueDate;

  /// Creates a [Project] instance.
  const Project({
    required this.id,
    required this.name,
    required this.color,
    required this.loggedMinutes,
    required this.goalMinutes,
    this.dueDate,
  });

  /// Converts this [Project] to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'goalMinutes': goalMinutes,
      'loggedMinutes': loggedMinutes,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  /// Creates a [Project] from a map fetched from the database.
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      goalMinutes: map['goalMinutes'] as int,
      loggedMinutes: map['loggedMinutes'] as int? ?? 0,
      dueDate:
          map['dueDate'] != null && map['dueDate'] != ''
              ? DateTime.tryParse(map['dueDate'] as String)
              : null,
    );
  }

  // Add computed properties for goal progress
  int get completedTaskCount => 0; // TODO: Implement with real task data
  int get totalTaskCount => 0; // TODO: Implement with real task data
}
