import 'package:flutter/material.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/services/database_helper.dart';

/// Provider for managing the list of projects and database operations.
class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  bool _disposed = false; // Track disposal state
  List<Project> get projects => _projects;

  ProjectProvider() {
    Future.microtask(() => fetchProjects());
  }

  Future<void> fetchProjects() async {
    if (_disposed) return; // Prevent operations after disposal
    _projects = await DatabaseHelper.instance.getAllProjects();
    if (!_disposed) Future.microtask(() => notifyListeners());
  }

  Future<void> addProject(Project project) async {
    if (_disposed) return; // Prevent operations after disposal
    await DatabaseHelper.instance.insertProject(project);
    await fetchProjects();
  }

  Future<void> updateProjectLoggedTime({
    required String projectId,
    required int newLoggedMinutes,
  }) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index == -1) return;
    final old = _projects[index];
    final updated = Project(
      id: old.id,
      name: old.name,
      color: old.color,
      goalMinutes: old.goalMinutes,
      loggedMinutes: newLoggedMinutes,
      dueDate: old.dueDate,
    );
    await DatabaseHelper.instance.updateProject(updated);
    _projects[index] = updated;
    if (!_disposed) Future.microtask(() => notifyListeners());
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
