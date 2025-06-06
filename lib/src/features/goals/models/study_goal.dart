import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Enum for different types of study goals.
enum GoalType { weeklyHours, chapterCompletion, semesterGPA, unlockDestination }

/// Abstract base class for all study goals.
abstract class StudyGoal {
  final String id;
  final String title;
  final String description;
  final GoalType goalType;

  StudyGoal({
    String? id,
    required this.title,
    required this.description,
    required this.goalType,
  }) : id = id ?? const Uuid().v4();

  double get progress;

  Map<String, dynamic> toMap();
}

class WeeklyHoursGoal extends StudyGoal {
  final double targetHours;
  double currentHours;

  WeeklyHoursGoal({
    String? id,
    required String title,
    required String description,
    required this.targetHours,
    this.currentHours = 0,
  }) : super(
         id: id,
         title: title,
         description: description,
         goalType: GoalType.weeklyHours,
       );

  @override
  double get progress => (currentHours / targetHours).clamp(0.0, 1.0);

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'goalType': goalType.index,
    'targetHours': targetHours,
    'currentHours': currentHours,
  };

  factory WeeklyHoursGoal.fromMap(Map<String, dynamic> map) => WeeklyHoursGoal(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    targetHours: map['targetHours'],
    currentHours: map['currentHours'],
  );
}

class ChapterCompletionGoal extends StudyGoal {
  final int targetSections;
  int completedSections;

  ChapterCompletionGoal({
    String? id,
    required String title,
    required String description,
    required this.targetSections,
    this.completedSections = 0,
  }) : super(
         id: id,
         title: title,
         description: description,
         goalType: GoalType.chapterCompletion,
       );

  @override
  double get progress => (completedSections / targetSections).clamp(0.0, 1.0);

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'goalType': goalType.index,
    'targetSections': targetSections,
    'completedSections': completedSections,
  };

  factory ChapterCompletionGoal.fromMap(Map<String, dynamic> map) =>
      ChapterCompletionGoal(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        targetSections: map['targetSections'],
        completedSections: map['completedSections'],
      );
}

class SemesterGPAGoal extends StudyGoal {
  final double targetGPA;
  double currentGPA;

  SemesterGPAGoal({
    String? id,
    required String title,
    required String description,
    required this.targetGPA,
    this.currentGPA = 0,
  }) : super(
         id: id,
         title: title,
         description: description,
         goalType: GoalType.semesterGPA,
       );

  @override
  double get progress => (currentGPA / targetGPA).clamp(0.0, 1.0);

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'goalType': goalType.index,
    'targetGPA': targetGPA,
    'currentGPA': currentGPA,
  };

  factory SemesterGPAGoal.fromMap(Map<String, dynamic> map) => SemesterGPAGoal(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    targetGPA: map['targetGPA'],
    currentGPA: map['currentGPA'],
  );
}

class UnlockDestinationGoal extends StudyGoal {
  final String destinationName;
  final WeeklyHoursGoal hoursGoal;

  UnlockDestinationGoal({
    String? id,
    required String title,
    required String description,
    required this.destinationName,
    required this.hoursGoal,
  }) : super(
         id: id,
         title: title,
         description: description,
         goalType: GoalType.unlockDestination,
       );

  @override
  double get progress => hoursGoal.progress;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'goalType': goalType.index,
    'destinationName': destinationName,
    'hoursGoal': hoursGoal.toMap(),
  };

  factory UnlockDestinationGoal.fromMap(Map<String, dynamic> map) =>
      UnlockDestinationGoal(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        destinationName: map['destinationName'],
        hoursGoal: WeeklyHoursGoal.fromMap(map['hoursGoal']),
      );
}
