import 'package:flutter/material.dart';
import 'package:study/src/models/task_model.dart';
import 'package:study/src/services/database_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _disposed = false; // Track disposal state

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    if (_disposed) return; // Prevent operations after disposal
    _isLoading = true;
    if (!_disposed) Future.microtask(() => notifyListeners());
    _tasks = await DatabaseHelper.instance.getAllTasks();
    _isLoading = false;
    if (!_disposed) Future.microtask(() => notifyListeners());
  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
    await fetchTasks();
  }

  Future<void> toggleTaskCompleted(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await DatabaseHelper.instance.updateTask(updatedTask);
    await fetchTasks();
  }

  List<Task> get openTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
