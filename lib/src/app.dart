import 'package:flutter/material.dart';
import 'package:study/src/constants/app_theme.dart';
import 'package:study/src/features/core_ui/screens/main_screen.dart';
import 'package:study/src/features/tasks/screens/add_task_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/add_study_plan_entry_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/daily_study_planner_screen.dart';
import 'package:study/src/features/journey_map/screens/journey_map_screen.dart';
import 'package:study/src/features/goals/screens/study_goals_screen.dart';
import 'package:study/src/features/projects/widgets/project_detail_wrapper.dart';
import 'package:study/src/features/projects/screens/add_project_screen.dart';
import 'package:study/src/models/study_plan_entry_model.dart';

/// The root widget of the application.
class AppRoot extends StatelessWidget {
  /// Creates an [AppRoot] widget.
  const AppRoot({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Tracker',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // Apply the new Study Goals theme
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/tasks/add': (context) => const AddTaskScreen(),
        '/projects/add': (context) => const AddProjectScreen(),
        '/study-planner': (context) => const DailyStudyPlannerScreen(),
        '/journey-map': (context) => const JourneyMapScreen(),
        '/goals': (context) => const StudyGoalsScreen(),
        '/study-planner/add': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final initialDate =
              args?['initialDate'] as DateTime? ?? DateTime.now();
          final editingEntry = args?['editingEntry'] as StudyPlanEntry?;
          return AddStudyPlanEntryScreen(
            initialDate: initialDate,
            editingEntry: editingEntry,
          );
        },
      },
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute:
          (settings) => MaterialPageRoute<bool?>(
            builder:
                (context) => Scaffold(
                  appBar: AppBar(title: const Text('Page Not Found')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Page Not Found',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Route not found: \\${settings.name}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => Navigator.of(
                                context,
                              ).pushReplacementNamed('/'),
                          child: const Text('Go Home'),
                        ),
                      ],
                    ),
                  ),
                ),
            settings: settings,
          ),
    );
  }

  /// Handles dynamic routes with parameters
  Route<bool?>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    final pathSegments = uri.pathSegments; // Handle project routes
    if (pathSegments.isNotEmpty && pathSegments[0] == 'projects') {
      if (pathSegments.length >= 2) {
        // Handle /projects/:projectId route
        final projectId = pathSegments[1];
        if (projectId != 'add') {
          return MaterialPageRoute<bool?>(
            builder: (context) => ProjectDetailWrapper(projectId: projectId),
            settings: settings,
          );
        }
      }
    }

    // Handle study planner routes with parameters
    if (pathSegments.length >= 2 && pathSegments[0] == 'study-planner') {
      switch (pathSegments[1]) {
        case 'add':
          // Parse query parameters for date and entry ID
          final queryParams = uri.queryParameters;
          final dateParam = queryParams['date'];
          final entryIdParam = queryParams['entryId'];

          DateTime initialDate = DateTime.now();
          if (dateParam != null) {
            try {
              initialDate = DateTime.parse(dateParam);
            } catch (e) {
              // Use current date if parsing fails
            }
          }
          return MaterialPageRoute<bool?>(
            builder:
                (context) => AddStudyPlanEntryScreen(
                  initialDate: initialDate,
                  editingEntryId: entryIdParam,
                ),
            settings: settings,
          );
        case 'date':
          // Handle /study-planner/date/2024-01-15 routes
          if (pathSegments.length >= 3) {
            try {
              final date = DateTime.parse(pathSegments[2]);
              return MaterialPageRoute<bool?>(
                builder:
                    (context) => DailyStudyPlannerScreen(initialDate: date),
                settings: settings,
              );
            } catch (e) {
              // Invalid date format, fall back to today
              return MaterialPageRoute<bool?>(
                builder: (context) => const DailyStudyPlannerScreen(),
                settings: settings,
              );
            }
          }
          break;
      }
    }

    // Handle task routes
    if (pathSegments.isNotEmpty && pathSegments[0] == 'tasks') {
      if (pathSegments.length == 2 && pathSegments[1] == 'add') {
        return MaterialPageRoute<bool?>(
          builder: (context) => const AddTaskScreen(),
          settings: settings,
        );
      }
    }

    // Default fallback - return null to use onUnknownRoute or default error page
    return null;
  }
}
