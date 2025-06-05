import 'package:uuid/uuid.dart';

/// Represents a scheduled study entry in the daily planner.
///
/// A [StudyPlanEntry] defines a planned study session for a specific subject
/// or topic on a particular date. It can optionally include time slots,
/// reminders, and be associated with an existing project for color coding
/// and organization purposes.
class StudyPlanEntry {
  /// Unique identifier for the study plan entry (UUID v4).
  final String id;

  /// Name of the subject or topic to be studied.
  /// This field is required and represents the main content of the study session.
  final String subjectName;

  /// Optional foreign key reference to an existing project.
  /// When linked to a project, the entry can inherit the project's color
  /// and contribute to overall project tracking statistics.
  final String? projectId;

  /// The specific date for which the study session is planned.
  /// Stored as DateTime but serialized to ISO8601 string for database storage.
  final DateTime date;

  /// Optional start time for the study session.
  /// If null, the session is considered to not have a specific start time.
  final DateTime? startTime;

  /// Optional end time for the study session.
  /// If null, the session is considered to not have a specific end time.
  /// Should be after [startTime] if both are provided.
  final DateTime? endTime;

  /// Indicates whether this is an all-day study plan entry.
  /// When true, [startTime] and [endTime] may be ignored or represent
  /// the full day's boundaries. Defaults to false.
  final bool isAllDay;

  /// Optional additional notes or details for the study session.
  /// Can include specific topics, resources, or reminders.
  final String? notes;

  /// Optional date and time for a reminder notification.
  /// Should be before the planned study session time.
  final DateTime? reminderDateTime;

  /// Tracks whether the planned study session was actually completed.
  /// Defaults to false. Can be used for analytics and progress tracking.
  final bool isCompleted;

  /// Timestamp when this entry was created.
  /// Automatically set during creation and used for audit purposes.
  final DateTime createdAt;

  /// Timestamp when this entry was last updated.
  /// Updated whenever the entry is modified.
  final DateTime updatedAt;

  /// Creates a new [StudyPlanEntry] instance.
  ///
  /// [id] is automatically generated if not provided.
  /// [createdAt] and [updatedAt] are set to current time if not provided.
  StudyPlanEntry({
    String? id,
    required this.subjectName,
    this.projectId,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.notes,
    this.reminderDateTime,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of this [StudyPlanEntry] with optionally updated values.
  ///
  /// This method maintains immutability by creating a new instance
  /// with modified fields while preserving unchanged values.
  /// The [updatedAt] timestamp is automatically updated to the current time.
  StudyPlanEntry copyWith({
    String? id,
    String? subjectName,
    String? projectId,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? notes,
    DateTime? reminderDateTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyPlanEntry(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      notes: notes ?? this.notes,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converts this [StudyPlanEntry] to a Map for database storage.
  ///
  /// All DateTime fields are converted to ISO8601 strings for SQLite compatibility.
  /// Boolean fields are converted to integers (0 for false, 1 for true).
  /// Null values are preserved for optional fields.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectName': subjectName,
      'projectId': projectId,
      'date': date.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isAllDay': isAllDay ? 1 : 0,
      'notes': notes,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [StudyPlanEntry] from a database Map.
  ///
  /// Handles type conversions from SQLite storage format:
  /// - ISO8601 strings are parsed to DateTime objects
  /// - Integer values (0/1) are converted to boolean
  /// - Null values are handled appropriately for optional fields
  factory StudyPlanEntry.fromMap(Map<String, dynamic> map) {
    return StudyPlanEntry(
      id: map['id'] as String,
      subjectName: map['subjectName'] as String,
      projectId: map['projectId'] as String?,
      date: DateTime.parse(map['date'] as String),
      startTime:
          map['startTime'] != null
              ? DateTime.parse(map['startTime'] as String)
              : null,
      endTime:
          map['endTime'] != null
              ? DateTime.parse(map['endTime'] as String)
              : null,
      isAllDay: (map['isAllDay'] as int) == 1,
      notes: map['notes'] as String?,
      reminderDateTime:
          map['reminderDateTime'] != null
              ? DateTime.parse(map['reminderDateTime'] as String)
              : null,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Returns a string representation of this [StudyPlanEntry].
  /// Useful for debugging and logging purposes.
  @override
  String toString() {
    return 'StudyPlanEntry{id: $id, subjectName: $subjectName, date: $date, isCompleted: $isCompleted}';
  }

  /// Determines equality based on the unique [id] field.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyPlanEntry && other.id == id;
  }

  /// Hash code based on the unique [id] field.
  @override
  int get hashCode => id.hashCode;

  /// Calculates the duration of the study session in minutes.
  /// Returns null if either [startTime] or [endTime] is not set.
  /// Returns 0 if [endTime] is before [startTime].
  int? get durationMinutes {
    if (startTime == null || endTime == null) return null;
    final duration = endTime!.difference(startTime!);
    return duration.inMinutes.clamp(0, double.infinity).toInt();
  }

  /// Determines if this entry has a specific time slot (both start and end times).
  bool get hasTimeSlot => startTime != null && endTime != null;

  /// Determines if this entry is scheduled for today.
  bool get isToday {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Determines if this entry is overdue (past due date and not completed).
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();

    // If there's a specific end time, use that for comparison
    if (endTime != null) {
      return endTime!.isBefore(now);
    }

    // Otherwise, consider overdue if the date has passed
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return endOfDay.isBefore(now);
  }
}
