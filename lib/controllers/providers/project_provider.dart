import 'package:flutter/foundation.dart';
import 'package:bytelearn_study_tracker/models/project.dart';
import 'package:hive/hive.dart';

/// Enum for project sorting options
enum ProjectSortOption { nameAsc, nameDesc, dateNewest, dateOldest }

class ProjectProvider with ChangeNotifier {
  final Box<Project> _projectBox;
  List<Project> _projects = [];
  String? _selectedProjectId;

  ProjectProvider(this._projectBox) {
    _loadProjects();
  }

  // Getters
  List<Project> get projects => _projects;

  Project get selectedProject {
    if (_selectedProjectId != null) {
      try {
        return _projects.firstWhere((p) => p.id == _selectedProjectId);
      } catch (_) {
        if (_projects.isNotEmpty) {
          return _projects.first;
        }
      }
    } else if (_projects.isNotEmpty) {
      return _projects.first;
    }

    return Project.create(
      title: "Untitled Project",
      description: "Please select or create a project",
      category: "General",
    );
  }

  // Get active projects (not archived)
  List<Project> get activeProjects =>
      _projects.where((p) => !p.isArchived && !p.isCompleted).toList();

  // Get completed projects
  List<Project> get completedProjects =>
      _projects.where((p) => !p.isArchived && p.isCompleted).toList();

  // Get archived projects
  List<Project> get archivedProjects =>
      _projects.where((p) => p.isArchived).toList();

  // Load projects from Hive box
  Future<void> _loadProjects() async {
    _projects = _projectBox.values.toList();
    notifyListeners();
  }

  // Create a new project
  Future<Project> createProject({
    required String title,
    required String description,
    DateTime? deadline,
    required String category,
  }) async {
    final project = Project.create(
      title: title,
      description: description,
      deadline: deadline,
      category: category,
    );

    await _projectBox.put(project.id, project);
    _projects.add(project);
    notifyListeners();
    return project;
  }

  // Update an existing project
  Future<void> updateProject(Project project) async {
    await _projectBox.put(project.id, project);

    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  // Delete a project
  Future<void> deleteProject(String projectId) async {
    await _projectBox.delete(projectId);

    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  // Archive a project
  Future<void> archiveProject(String projectId) async {
    final project = getProjectById(projectId);
    if (project != null) {
      final updatedProject = project.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );
      await updateProject(updatedProject);
    }
  }

  // Unarchive a project
  Future<void> unarchiveProject(String projectId) async {
    final project = getProjectById(projectId);
    if (project != null) {
      final updatedProject = project.copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
      );
      await updateProject(updatedProject);
    }
  }

  // Sort projects by different criteria
  void sortProjects({required ProjectSortOption sortBy}) {
    switch (sortBy) {
      case ProjectSortOption.nameAsc:
        _projects.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ProjectSortOption.nameDesc:
        _projects.sort((a, b) => b.title.compareTo(a.title));
        break;
      case ProjectSortOption.dateNewest:
        _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProjectSortOption.dateOldest:
        _projects.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    notifyListeners();
  }

  // Set selected project
  void selectProject(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  // Get project by ID
  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Get projects by category
  List<Project> getProjectsByCategory(String category) {
    return _projects.where((p) => p.category == category).toList();
  }

  // Mark project as completed
  Future<void> markProjectAsCompleted(String projectId) async {
    final project = getProjectById(projectId);
    if (project != null) {
      final updatedProject = project.markAsCompleted();
      await updateProject(updatedProject);
    }
  }

  // Mark project as not completed
  Future<void> markProjectAsNotCompleted(String projectId) async {
    final project = getProjectById(projectId);
    if (project != null) {
      final updatedProject = project.markAsNotCompleted();
      await updateProject(updatedProject);
    }
  }

  // Add a session to a project
  Future<void> addSessionToProject(String projectId, String sessionId) async {
    final project = getProjectById(projectId);
    if (project != null) {
      final updatedProject = project.addSession(sessionId);
      await updateProject(updatedProject);
    }
  }

  // Add a goal to a project
  Future<void> addGoalToProject(String projectId, String goalId) async {
    final project = getProjectById(projectId);
    if (project != null) {
      final updatedProject = project.addGoal(goalId);
      await updateProject(updatedProject);
    }
  }
}
