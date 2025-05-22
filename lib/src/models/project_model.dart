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
}
