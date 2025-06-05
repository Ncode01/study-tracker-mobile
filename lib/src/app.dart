import 'package:flutter/material.dart';
import 'package:study/src/constants/app_theme.dart';
import 'package:study/src/features/core_ui/screens/main_screen.dart';
import 'package:study/src/features/projects/screens/add_project_screen.dart';
import 'package:study/src/features/tasks/screens/add_task_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/add_study_plan_entry_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/daily_study_planner_screen.dart';

/// The root widget of the application.
class AppRoot extends StatelessWidget {
  /// Creates an [AppRoot] widget.
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/projects/add': (context) => const AddProjectScreen(),
        '/tasks/add': (context) => const AddTaskScreen(),
        '/study-planner': (context) => const DailyStudyPlannerScreen(),
        '/study-planner/add':
            (context) => AddStudyPlanEntryScreen(initialDate: DateTime.now()),
      },
      onGenerateRoute: _onGenerateRoute,
    );
  }

  /// Handles dynamic routes with parameters
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    final pathSegments = uri.pathSegments;

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
          } // For editing entries, we'll need to pass the entry ID
          // and let the screen handle loading the entry data
          return MaterialPageRoute<bool>(
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
              return MaterialPageRoute<bool>(
                builder:
                    (context) => DailyStudyPlannerScreen(initialDate: date),
                settings: settings,
              );
            } catch (e) {
              // Invalid date format, fall back to today
              return MaterialPageRoute<bool>(
                builder: (context) => const DailyStudyPlannerScreen(),
                settings: settings,
              );
            }
          }
          break;
      }
    }

    // Handle project routes
    if (pathSegments.isNotEmpty && pathSegments[0] == 'projects') {
      if (pathSegments.length == 2 && pathSegments[1] == 'add') {
        return MaterialPageRoute(
          builder: (context) => const AddProjectScreen(),
          settings: settings,
        );
      }
    }

    // Handle task routes
    if (pathSegments.isNotEmpty && pathSegments[0] == 'tasks') {
      if (pathSegments.length == 2 && pathSegments[1] == 'add') {
        return MaterialPageRoute(
          builder: (context) => const AddTaskScreen(),
          settings: settings,
        );
      }
    }

    // Default fallback - return null to use onUnknownRoute or default error page
    return null;
  }
}
