import 'package:flutter/material.dart';
import 'package:study/src/features/goals/models/study_goal.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/models/project_model.dart';

class GoalProvider extends ChangeNotifier {
  late SessionProvider sessionProvider;
  late TaskProvider taskProvider;
  late ProjectProvider projectProvider;

  GoalProvider(this.sessionProvider, this.taskProvider, this.projectProvider);

  final List<StudyGoal> _shortTermGoals = [];
  final List<StudyGoal> _longTermGoals = [];
  final List<StudyGoal> _dynamicShortTermGoals = [];

  List<StudyGoal> get shortTermGoals => _shortTermGoals;
  List<StudyGoal> get longTermGoals => _longTermGoals;
  List<StudyGoal> get dynamicShortTermGoals => _dynamicShortTermGoals;

  // Long-term goal templates
  List<GoalTemplate> get longTermGoalTemplates => kLongTermGoalTemplates;

  Future<void> fetchGoals() async {
    // TODO: Load from database. For now, add a default goal for demo.
    if (_shortTermGoals.isEmpty && _longTermGoals.isEmpty) {
      _shortTermGoals.add(
        WeeklyHoursGoal(
          title: 'Weekly Study Hours',
          description: 'Complete 5 hours of study this week',
          targetHours: 5,
        ),
      );
    }
    await updateGoalProgress();
  }

  Future<void> updateGoalProgress() async {
    final now = DateTime.now();
    final weekStart = now.subtract(
      Duration(days: now.weekday % 7),
    ); // Assuming Sunday is the first day (0)

    final allGoals = [..._shortTermGoals, ..._longTermGoals];

    for (final goal in allGoals) {
      switch (goal.goalType) {
        case GoalType.weeklyHours:
          final whg = goal as WeeklyHoursGoal;
          final sessions = sessionProvider.sessions.where(
            (s) =>
                s.startTime.isAfter(weekStart) &&
                s.startTime.isBefore(
                  now.add(const Duration(days: 1)),
                ), // up to end of current day
          );
          final totalMinutes = sessions.fold<int>(
            0,
            (sum, s) => sum + s.durationMinutes,
          );
          whg.currentHours = totalMinutes / 60.0;
          break;
        case GoalType.chapterCompletion:
          final ccg = goal as ChapterCompletionGoal;
          final projectTasks =
              taskProvider.tasks
                  .where((t) => t.projectId == ccg.projectId)
                  .toList();
          ccg.completedSections =
              projectTasks.where((t) => t.isCompleted).length;
          // If targetSections wasn't set on the goal, try to get it from the project's total tasks, or default.
          ccg.targetSections =
              ccg.targetSections > 0
                  ? ccg.targetSections
                  : (projectTasks.isNotEmpty ? projectTasks.length : 1);
          break;
        case GoalType.semesterGPA:
          // final sgag = goal as SemesterGPAGoal;
          // No auto update for GPA based on sessions/tasks; user sets currentGPA manually.
          break;
        case GoalType.unlockDestination:
          final udg = goal as UnlockDestinationGoal;
          final totalProjectMinutes = projectProvider.projects.fold<int>(
            0,
            (sum, p) => sum + p.loggedMinutes,
          );
          udg.hoursGoal.currentHours = totalProjectMinutes / 60.0;
          break;
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
    updateGoalProgress();
    notifyListeners();
  }

  void updateGoal(StudyGoal goal) {
    final idxShort = _shortTermGoals.indexWhere((g) => g.id == goal.id);
    if (idxShort != -1) _shortTermGoals[idxShort] = goal;
    final idxLong = _longTermGoals.indexWhere((g) => g.id == goal.id);
    if (idxLong != -1) _longTermGoals[idxLong] = goal;
    updateGoalProgress();
    notifyListeners();
  }

  void deleteGoal(String goalId) {
    _shortTermGoals.removeWhere((g) => g.id == goalId);
    _longTermGoals.removeWhere((g) => g.id == goalId);
    updateGoalProgress();
    notifyListeners();
  }

  void generateDynamicShortTermGoals() {
    _dynamicShortTermGoals.clear();
    // 1. Focus on a Weak Project
    final weakProject = projectProvider.projects
        .where((p) => p.loggedMinutes < 120)
        .toList()
        .cast<Project?>()
        .firstWhere((p) => p != null, orElse: () => null);
    if (weakProject != null) {
      _dynamicShortTermGoals.add(
        ChapterCompletionGoal(
          title: 'Conquer ${weakProject.name}',
          description: 'Spend 2h on ${weakProject.name}',
          projectId: weakProject.id,
          targetSections: 2,
        ),
      );
    }
    // 2. Build a Streak
    final streak = sessionProvider.consecutiveDays;
    if (streak < 3) {
      _dynamicShortTermGoals.add(
        WeeklyHoursGoal(
          title: '${streak + 1}-Day Streak!',
          description: 'Study ${streak + 1} days in a row',
          targetHours: 1,
        ),
      );
    }
    // 3. Complete Overdue Tasks
    final overdueTasks = taskProvider.tasks.where((t) => t.isOverdue).toList();
    if (overdueTasks.isNotEmpty) {
      _dynamicShortTermGoals.add(
        WeeklyHoursGoal(
          title: 'Clear Overdue Tasks',
          description: 'Complete ${overdueTasks.length} overdue tasks',
          targetHours: overdueTasks.length.toDouble(),
        ),
      );
    }
    notifyListeners();
  }

  /// Create and add a new long-term goal from a template
  void addGoalFromTemplate(GoalTemplate template) {
    StudyGoal newGoal;
    switch (template.goalType) {
      case GoalType.weeklyHours:
        newGoal = WeeklyHoursGoal(
          title: template.title,
          description: template.description,
          targetHours: template.presetData['targetHours'] ?? 10,
        );
        break;
      case GoalType.chapterCompletion:
        newGoal = ChapterCompletionGoal(
          title: template.title,
          description: template.description,
          projectId: template.presetData['projectId'] ?? '',
          targetSections: template.presetData['targetSections'] ?? 10,
          completedSections: 0,
        );
        break;
      case GoalType.semesterGPA:
        newGoal = SemesterGPAGoal(
          title: template.title,
          description: template.description,
          targetGPA: template.presetData['targetGPA'] ?? 4.0,
        );
        break;
      case GoalType.unlockDestination:
        newGoal = UnlockDestinationGoal(
          title: template.title,
          description: template.description,
          destinationName:
              template.presetData['destinationName'] ?? template.title,
          hoursGoal: WeeklyHoursGoal(
            title: 'Milestone Hours',
            description: 'Complete milestone hours for this destination',
            targetHours: template.presetData['targetHours'] ?? 20,
          ),
        );
        break;
    }
    _longTermGoals.add(newGoal);
    notifyListeners();
  }
}
