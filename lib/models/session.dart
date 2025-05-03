import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Model representing a study session.
@HiveType(typeId: 1)
class Session {
  /// Unique identifier for the session
  @HiveField(0)
  final String id;

  /// ID of the project this session belongs to
  @HiveField(1)
  final String projectId;

  /// When the session started
  @HiveField(2)
  final DateTime startTime;

  /// When the session ended (null if session is ongoing)
  @HiveField(3)
  final DateTime? endTime;

  /// Total duration of the session
  @HiveField(4)
  final Duration duration;

  /// Optional notes about the session
  @HiveField(5)
  final String notes;

  /// Indicates if the session is completed
  @HiveField(6)
  final bool isCompleted;

  const Session({
    required this.id,
    required this.projectId,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.notes = '',
    this.isCompleted = false,
  });

  /// Create a new session with a generated ID
  factory Session.start({required String projectId, String notes = ''}) {
    return Session(
      id: const Uuid().v4(),
      projectId: projectId,
      startTime: DateTime.now(),
      duration: Duration.zero,
      notes: notes,
      isCompleted: false,
    );
  }

  /// Create a completed session with all details
  factory Session.create({
    required String projectId,
    required DateTime startTime,
    required DateTime endTime,
    required Duration duration,
    String notes = '',
  }) {
    return Session(
      id: const Uuid().v4(),
      projectId: projectId,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      notes: notes,
      isCompleted: true,
    );
  }

  /// Create a copy of this session with updated fields
  Session copyWith({
    String? projectId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? notes,
    bool? isCompleted,
  }) {
    return Session(
      id: id,
      projectId: projectId ?? this.projectId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// End this session
  Session end({DateTime? endTime, String? notes}) {
    final now = endTime ?? DateTime.now();
    return copyWith(
      endTime: now,
      duration: now.difference(startTime),
      notes: notes ?? this.notes,
      isCompleted: true,
    );
  }

  /// Update the duration of this session based on current time (for active sessions)
  Session updateDuration() {
    if (isCompleted) return this;
    return copyWith(duration: DateTime.now().difference(startTime));
  }

  /// Format the duration as a string (HH:MM:SS)
  String get formattedDuration {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Get the date of this session (based on start time)
  DateTime get date => DateTime(startTime.year, startTime.month, startTime.day);
}
