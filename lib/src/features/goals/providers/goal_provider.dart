import 'package:flutter/material.dart';
import 'package:study/src/features/goals/models/study_goal.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';

class GoalProvider extends ChangeNotifier {
  late SessionProvider sessionProvider;
  late StudyPlanProvider studyPlanProvider;

  GoalProvider({
    required SessionProvider sessionProvider,
    required StudyPlanProvider studyPlanProvider,
  }) {
    this.sessionProvider = sessionProvider;
    this.studyPlanProvider = studyPlanProvider;
  }

  final List<StudyGoal> _shortTermGoals = [];
  final List<StudyGoal> _longTermGoals = [];

  // Demo journey data and achievements
  final List<String> _journeyMilestones = [
    'Reached 10 study hours',
    'Completed 3 chapters',
    'Unlocked Paris background',
  ];
  final List<String> _achievements = [
    '🏆 Consistency Streak: 7 days',
    '🏅 Early Bird: Studied before 8am',
  ];

  List<StudyGoal> get shortTermGoals => _shortTermGoals;
  List<StudyGoal> get longTermGoals => _longTermGoals;
  List<String> get journeyMilestones => _journeyMilestones;
  List<String> get achievements => _achievements;

  Future<void> updateGoalProgress() async {
    // Example: update all goals' progress based on sessions/tasks
    final sessions = sessionProvider.sessions;
    final now = DateTime.now();
    for (final goal in _shortTermGoals) {
      if (goal is WeeklyHoursGoal) {
        final weekAgo = now.subtract(const Duration(days: 7));
        final totalMinutes = sessions
            .where((s) => s.startTime.isAfter(weekAgo))
            .fold<int>(0, (sum, s) => sum + s.durationMinutes);
        goal.currentHours = totalMinutes / 60.0;
      } else if (goal is ChapterCompletionGoal) {
        // Placeholder: set completedSections to a static value or fetch from tasks
        goal.completedSections = goal.completedSections;
      }
    }
    for (final goal in _longTermGoals) {
      if (goal is SemesterGPAGoal) {
        // Placeholder: set currentGPA to a static value or fetch from user profile
        goal.currentGPA = goal.currentGPA;
      } else if (goal is UnlockDestinationGoal) {
        // Nested WeeklyHoursGoal progress is updated above
        goal.hoursGoal.currentHours = goal.hoursGoal.currentHours;
      }
    }
    notifyListeners();
  }

  void addGoal(StudyGoal goal, {bool longTerm = false}) {
    if (longTerm) {
      _longTermGoals.add(goal);
    } else {
      _shortTermGoals.add(goal);
    }
    notifyListeners();
  }

  void updateGoal(StudyGoal goal) {
    // Find and update goal in the appropriate list
    final idxShort = _shortTermGoals.indexWhere((g) => g.id == goal.id);
    if (idxShort != -1) {
      _shortTermGoals[idxShort] = goal;
    }
    final idxLong = _longTermGoals.indexWhere((g) => g.id == goal.id);
    if (idxLong != -1) {
      _longTermGoals[idxLong] = goal;
    }
    notifyListeners();
  }

  void deleteGoal(String goalId) {
    _shortTermGoals.removeWhere((g) => g.id == goalId);
    _longTermGoals.removeWhere((g) => g.id == goalId);
    notifyListeners();
  }

  Future<void> fetchGoals() async {
    // Placeholder: In a real app, load from database
    if (_shortTermGoals.isEmpty && _longTermGoals.isEmpty) {
      _shortTermGoals.addAll([
        WeeklyHoursGoal(
          title: 'Weekly Study Hours',
          description: 'Complete 5 hours of study',
          targetHours: 5,
          currentHours: 3.4,
        ),
        ChapterCompletionGoal(
          title: 'Chapter Completion',
          description: 'Finish European history chapter',
          targetSections: 9,
          completedSections: 8,
        ),
      ]);
      _longTermGoals.addAll([
        SemesterGPAGoal(
          title: 'Semester GPA',
          description: 'Achieve a 3.8 GPA',
          targetGPA: 3.8,
          currentGPA: 3.5,
        ),
        UnlockDestinationGoal(
          title: 'Unlock New Destinations',
          description: "Unlock 'Paris' by studying 50 hours.",
          destinationName: 'Paris',
          hoursGoal: WeeklyHoursGoal(
            title: 'Unlock Paris',
            description: '',
            targetHours: 50,
            currentHours: 11.3,
          ),
        ),
      ]);
    }
    await updateGoalProgress();
  }
}
