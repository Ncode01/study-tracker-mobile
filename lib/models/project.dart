import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Model representing a student project or subject.
@HiveType(typeId: 0)
class Project {
  /// Unique identifier for the project
  @HiveField(0)
  final String id;

  /// Title of the project
  @HiveField(1)
  final String title;

  /// Detailed description of the project
  @HiveField(2)
  final String description;

  /// Optional deadline for the project
  @HiveField(3)
  final DateTime? deadline;

  /// Category or subject the project belongs to
  @HiveField(4)
  final String category;

  /// Indicates if the project is completed
  @HiveField(5)
  final bool isCompleted;

  /// When the project was created
  @HiveField(6)
  final DateTime createdAt;

  /// When the project was last updated
  @HiveField(7)
  final DateTime updatedAt;

  /// IDs of study sessions associated with this project
  @HiveField(8)
  final List<String> sessionIds;

  /// IDs of goals associated with this project
  @HiveField(9)
  final List<String> goalIds;

  /// Indicates if the project is archived
  @HiveField(10)
  final bool isArchived;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    this.deadline,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.sessionIds = const [],
    this.goalIds = const [],
    this.isArchived = false,
  });

  /// Create a new project with a generated ID
  factory Project.create({
    required String title,
    required String description,
    DateTime? deadline,
    required String category,
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      title: title,
      description: description,
      deadline: deadline,
      category: category,
      isCompleted: false,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
      sessionIds: [],
      goalIds: [],
    );
  }

  /// Create a copy of this project with updated fields
  Project copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    String? category,
    bool? isCompleted,
    bool? isArchived,
    DateTime? updatedAt,
    List<String>? sessionIds,
    List<String>? goalIds,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      sessionIds: sessionIds ?? this.sessionIds,
      goalIds: goalIds ?? this.goalIds,
    );
  }

  /// Add a session ID to this project
  Project addSession(String sessionId) {
    final updatedSessionIds = List<String>.from(sessionIds)..add(sessionId);
    return copyWith(sessionIds: updatedSessionIds, updatedAt: DateTime.now());
  }

  /// Add a goal ID to this project
  Project addGoal(String goalId) {
    final updatedGoalIds = List<String>.from(goalIds)..add(goalId);
    return copyWith(goalIds: updatedGoalIds, updatedAt: DateTime.now());
  }

  /// Remove a session ID from this project
  Project removeSession(String sessionId) {
    final updatedSessionIds = List<String>.from(sessionIds)..remove(sessionId);
    return copyWith(sessionIds: updatedSessionIds, updatedAt: DateTime.now());
  }

  /// Remove a goal ID from this project
  Project removeGoal(String goalId) {
    final updatedGoalIds = List<String>.from(goalIds)..remove(goalId);
    return copyWith(goalIds: updatedGoalIds, updatedAt: DateTime.now());
  }

  /// Mark this project as completed
  Project markAsCompleted() {
    return copyWith(isCompleted: true, updatedAt: DateTime.now());
  }

  /// Mark this project as not completed
  Project markAsNotCompleted() {
    return copyWith(isCompleted: false, updatedAt: DateTime.now());
  }
}
