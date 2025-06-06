import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/constants/app_theme.dart';
import 'package:study/src/features/core_ui/screens/main_screen.dart';
import 'package:study/src/features/tasks/screens/add_task_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/add_study_plan_entry_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/daily_study_planner_screen.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/models/study_plan_entry_model.dart';

class TestAppSetup {
  static Widget createTestApp({Widget? home, String? initialRoute}) {
    final routes = {
      '/': (context) => const MainScreen(),
      '/tasks/add': (context) => const AddTaskScreen(),
      '/study-planner': (context) => const DailyStudyPlannerScreen(),
      '/study-planner/add': (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final initialDate = args?['initialDate'] as DateTime? ?? DateTime.now();
        final editingEntry = args?['editingEntry'] as StudyPlanEntry?;
        return AddStudyPlanEntryScreen(
          initialDate: initialDate,
          editingEntry: editingEntry,
        );
      },
    };
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme, // Changed from darkTheme to appTheme
        initialRoute: initialRoute,
        home: initialRoute == null ? home : null,
        routes: initialRoute == null && home != null ? {} : routes,
        onGenerateRoute: _onGenerateRoute,
        onUnknownRoute: _onUnknownRoute,
      ),
    );
  }

  static Route<bool?>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    final pathSegments = uri.pathSegments;
    if (pathSegments.length >= 2 && pathSegments[0] == 'study-planner') {
      switch (pathSegments[1]) {
        case 'add':
          final queryParams = uri.queryParameters;
          final dateParam = queryParams['date'];
          final entryIdParam = queryParams['entryId'];
          DateTime initialDate = DateTime.now();
          if (dateParam != null) {
            try {
              initialDate = DateTime.parse(dateParam);
            } catch (_) {}
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
          if (pathSegments.length >= 3) {
            try {
              final date = DateTime.parse(pathSegments[2]);
              return MaterialPageRoute<bool?>(
                builder:
                    (context) => DailyStudyPlannerScreen(initialDate: date),
                settings: settings,
              );
            } catch (_) {
              return MaterialPageRoute<bool?>(
                builder: (context) => const DailyStudyPlannerScreen(),
                settings: settings,
              );
            }
          }
          break;
      }
    }
    if (pathSegments.isNotEmpty && pathSegments[0] == 'tasks') {
      if (pathSegments.length == 2 && pathSegments[1] == 'add') {
        return MaterialPageRoute<bool?>(
          builder: (context) => const AddTaskScreen(),
          settings: settings,
        );
      }
    }
    return null;
  }

  static Route<bool?> _onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<bool?>(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Page Not Found', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    'Route not found: ${settings.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.of(context).pushReplacementNamed('/'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
      settings: settings,
    );
  }
}
