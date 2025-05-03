import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Types of goals that can be tracked
@HiveType(typeId: 2)
enum GoalType {
  @HiveField(0)
  time, // Goal based on study hours

  @HiveField(1)
  task, // Goal based on completing tasks
}

/// Time periods for goals
@HiveType(typeId: 3)
enum GoalPeriod {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,
}

/// Model representing a study goal.
@HiveType(typeId: 4)
class Goal {
  /// Unique identifier for the goal
  @HiveField(0)
  final String id;

  /// Title of the goal
  @HiveField(1)
  final String title;

  /// ID of the project this goal is associated with (optional)
  @HiveField(2)
  final String? projectId;

  /// Type of goal (time-based or task-based)
  @HiveField(3)
  final GoalType type;

  /// Time period for the goal (daily, weekly, monthly)
  @HiveField(4)
  final GoalPeriod period;

  /// Target value to achieve (hours for time goals, count for task goals)
  @HiveField(5)
  final int targetValue;

  /// Current progress toward the goal
  @HiveField(6)
  final int currentValue;

  /// When the goal was created
  @HiveField(7)
  final DateTime createdAt;

  /// Deadline for the goal
  @HiveField(8)
  final DateTime deadline;

  /// Indicates if the goal is completed
  @HiveField(9)
  final bool isCompleted;

  const Goal({
    required this.id,
    required this.title,
    this.projectId,
    required this.type,
    required this.period,
    required this.targetValue,
    this.currentValue = 0,
    required this.createdAt,
    required this.deadline,
    this.isCompleted = false,
  });

  /// Create a new goal with a generated ID
  factory Goal.create({
    required String title,
    String? projectId,
    required GoalType type,
    required GoalPeriod period,
    required int targetValue,
    required DateTime deadline,
  }) {
    return Goal(
      id: const Uuid().v4(),
      title: title,
      projectId: projectId,
      type: type,
      period: period,
      targetValue: targetValue,
      currentValue: 0,
      createdAt: DateTime.now(),
      deadline: deadline,
      isCompleted: false,
    );
  }

  /// Create a copy of this goal with updated fields
  Goal copyWith({
    String? title,
    String? projectId,
    GoalType? type,
    GoalPeriod? period,
    int? targetValue,
    int? currentValue,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      period: period ?? this.period,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
      isCompleted:
          isCompleted ??
                  (currentValue != null &&
                      currentValue >= (targetValue ?? this.targetValue))
              ? true
              : this.isCompleted,
    );
  }

  /// Update progress toward the goal
  Goal updateProgress(int newValue) {
    final updatedValue = currentValue + newValue;
    final isNowCompleted = updatedValue >= targetValue;

    return copyWith(currentValue: updatedValue, isCompleted: isNowCompleted);
  }

  /// Set progress to a specific value
  Goal setProgress(int value) {
    final isNowCompleted = value >= targetValue;

    return copyWith(currentValue: value, isCompleted: isNowCompleted);
  }

  /// Calculate the percentage of progress toward the goal
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Get formatted progress text (e.g., "3/5 hours" or "2/4 tasks")
  String get progressText {
    final unit = type == GoalType.time ? 'hours' : 'tasks';
    return '$currentValue/$targetValue $unit';
  }

  /// Check if the goal is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(deadline);
  }

  /// Check if the goal is due today
  bool get isDueToday {
    final now = DateTime.now();
    return !isCompleted &&
        deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day;
  }
}
