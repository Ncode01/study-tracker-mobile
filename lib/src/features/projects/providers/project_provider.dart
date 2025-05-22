import 'package:flutter/material.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/services/database_helper.dart';

/// Provider for managing the list of projects and database operations.
class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Project> get projects => _projects;

  ProjectProvider() {
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    _projects = await DatabaseHelper.instance.getAllProjects();
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    await DatabaseHelper.instance.insertProject(project);
    await fetchProjects();
  }
}
