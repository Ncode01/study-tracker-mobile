import 'package:flutter/material.dart';
import 'package:bytelearn_study_tracker/views/home_screen.dart';
import 'package:bytelearn_study_tracker/views/timer_screen.dart';
import 'package:bytelearn_study_tracker/views/projects_screen.dart';
import 'package:bytelearn_study_tracker/views/statistics_screen.dart';
import 'package:bytelearn_study_tracker/views/settings_screen.dart';

/// Manages app-wide navigation and routing.
class AppRouter {
  /// Named routes for the application
  static const String home = '/';
  static const String timer = '/timer';
  static const String projects = '/projects';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String projectDetails = '/project-details';
  static const String createProject = '/create-project';
  static const String createGoal = '/create-goal';

  /// Route generation function to be used with [MaterialApp.onGenerateRoute]
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routes = {
      home: () => MaterialPageRoute(builder: (_) => const HomeScreen()),
      timer: () => MaterialPageRoute(builder: (_) => const TimerScreen()),
      projects: () => MaterialPageRoute(builder: (_) => const ProjectsScreen()),
      statistics:
          () => MaterialPageRoute(builder: (_) => const StatisticsScreen()),
      settings: () => MaterialPageRoute(builder: (_) => const SettingsScreen()),
    };

    // Use the matching route handler if it exists
    if (routes.containsKey(settings.name)) {
      return routes[settings.name]!();
    }

    // Handle routes with arguments
    if (settings.name == projectDetails) {
      final args = settings.arguments as Map<String, dynamic>?;
      final projectId = args?['projectId'] as String?;
      return MaterialPageRoute(
        builder: (_) => ProjectDetailsScreen(projectId: projectId ?? ''),
      );
    }

    if (settings.name == createProject) {
      return MaterialPageRoute(builder: (_) => const CreateProjectScreen());
    }

    if (settings.name == createGoal) {
      final args = settings.arguments as Map<String, dynamic>?;
      final projectId = args?['projectId'] as String?;
      return MaterialPageRoute(
        builder: (_) => CreateGoalScreen(projectId: projectId),
      );
    }

    // Default case for undefined routes
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
    );
  }
}

// Placeholder screens - To be implemented in separate files
class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Project Details for $projectId')),
    );
  }
}

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Create Project Screen')));
  }
}

class CreateGoalScreen extends StatelessWidget {
  final String? projectId;

  const CreateGoalScreen({super.key, this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Create Goal Screen for project $projectId')),
    );
  }
}
