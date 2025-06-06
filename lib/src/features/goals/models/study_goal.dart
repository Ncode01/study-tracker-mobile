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
  final String projectId;
  int targetSections;
  int completedSections;

  ChapterCompletionGoal({
    String? id,
    required String title,
    required String description,
    required this.projectId,
    required this.targetSections,
    this.completedSections = 0,
  }) : super(
         id: id,
         title: title,
         description: description,
         goalType: GoalType.chapterCompletion,
       );

  @override
  double get progress =>
      (targetSections == 0)
          ? 0.0
          : (completedSections / targetSections).clamp(0.0, 1.0);

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'goalType': goalType.index,
    'projectId': projectId,
    'targetSections': targetSections,
    'completedSections': completedSections,
  };

  factory ChapterCompletionGoal.fromMap(Map<String, dynamic> map) =>
      ChapterCompletionGoal(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        projectId: map['projectId'],
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

/// Template for long-term goal creation
class GoalTemplate {
  final String title;
  final String description;
  final GoalType goalType;
  final Map<String, dynamic> presetData;
  final String? iconAsset;

  const GoalTemplate({
    required this.title,
    required this.description,
    required this.goalType,
    this.presetData = const {},
    this.iconAsset,
  });
}

/// Predefined creative goal templates
const List<GoalTemplate> kLongTermGoalTemplates = [
  GoalTemplate(
    title: 'Publish a Research Paper',
    description: 'Complete all steps to publish a paper in your field.',
    goalType: GoalType.unlockDestination,
    iconAsset: 'assets/images/paper_icon.png',
  ),
  GoalTemplate(
    title: 'Complete Certification',
    description: 'Finish all modules and pass the final exam.',
    goalType: GoalType.unlockDestination,
    iconAsset: 'assets/images/certificate_icon.png',
  ),
  GoalTemplate(
    title: 'Achieve 4.0 GPA',
    description: 'Maintain a perfect GPA this semester.',
    goalType: GoalType.semesterGPA,
    iconAsset: 'assets/images/gpa_icon.png',
  ),
  GoalTemplate(
    title: 'Finish All Textbook Chapters',
    description: 'Read and complete every chapter in your main textbook.',
    goalType: GoalType.chapterCompletion,
    iconAsset: 'assets/images/book_icon.png',
  ),
];
