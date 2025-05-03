import 'package:flutter/foundation.dart';
import 'package:bytelearn_study_tracker/models/goal.dart';
import 'package:hive/hive.dart';

class GoalProvider with ChangeNotifier {
  final Box<Goal> _goalBox;
  List<Goal> _goals = [];

  GoalProvider(this._goalBox) {
    _loadGoals();
  }

  // Getters
  List<Goal> get goals => _goals;

  // Load goals from Hive box
  Future<void> _loadGoals() async {
    _goals = _goalBox.values.toList();
    notifyListeners();
  }

  // Create a new goal
  Future<Goal> createGoal({
    required String title,
    String? projectId,
    required GoalType type,
    required GoalPeriod period,
    required int targetValue,
    required DateTime deadline,
  }) async {
    final goal = Goal.create(
      title: title,
      projectId: projectId,
      type: type,
      period: period,
      targetValue: targetValue,
      deadline: deadline,
    );

    await _goalBox.put(goal.id, goal);
    _goals.add(goal);
    notifyListeners();
    return goal;
  }

  // Update an existing goal
  Future<void> updateGoal(Goal goal) async {
    await _goalBox.put(goal.id, goal);

    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      notifyListeners();
    }
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _goalBox.delete(goalId);

    _goals.removeWhere((g) => g.id == goalId);
    notifyListeners();
  }

  // Get goal by ID
  Goal? getGoalById(String goalId) {
    try {
      return _goals.firstWhere((g) => g.id == goalId);
    } catch (e) {
      return null;
    }
  }

  // Get goals for a specific project
  List<Goal> getGoalsForProject(String projectId) {
    return _goals.where((g) => g.projectId == projectId).toList();
  }

  // Get active (not completed) goals
  List<Goal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();

  // Get completed goals
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  // Update progress for a goal
  Future<void> updateGoalProgress(String goalId, int newValue) async {
    final goal = getGoalById(goalId);
    if (goal != null) {
      final updatedGoal = goal.updateProgress(newValue);
      await updateGoal(updatedGoal);
    }
  }

  // Set specific progress value for a goal
  Future<void> setGoalProgress(String goalId, int value) async {
    final goal = getGoalById(goalId);
    if (goal != null) {
      final updatedGoal = goal.setProgress(value);
      await updateGoal(updatedGoal);
    }
  }

  // Get goals by period
  List<Goal> getGoalsByPeriod(GoalPeriod period) {
    return _goals.where((g) => g.period == period).toList();
  }

  // Get goals by type
  List<Goal> getGoalsByType(GoalType type) {
    return _goals.where((g) => g.type == type).toList();
  }

  // Get goals due today
  List<Goal> get goalsDueToday => _goals.where((g) => g.isDueToday).toList();

  // Get overdue goals
  List<Goal> get overdueGoals => _goals.where((g) => g.isOverdue).toList();
}
