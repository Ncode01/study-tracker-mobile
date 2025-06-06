import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/app.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/features/study_timer/providers/timer_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/features/goals/providers/goal_provider.dart';
import 'package:study/src/features/settings/providers/settings_provider.dart';
import 'package:study/src/features/settings/services/settings_service.dart';
import 'package:study/src/features/analytics/providers/analytics_provider.dart';
import 'package:study/src/services/database_helper.dart';

void main() async {
  // Ensure Flutter bindings are initialized before accessing platform channels
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        // Settings Provider
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(SettingsService()),
        ),
        // Update GoalProvider to use ChangeNotifierProxyProvider3 for SessionProvider, TaskProvider, and ProjectProvider
        ChangeNotifierProxyProvider3<
          SessionProvider,
          TaskProvider,
          ProjectProvider,
          GoalProvider
        >(
          create:
              (context) => GoalProvider(
                Provider.of<SessionProvider>(context, listen: false),
                Provider.of<TaskProvider>(context, listen: false),
                Provider.of<ProjectProvider>(context, listen: false),
              ),
          update: (
            context,
            sessionProvider,
            taskProvider,
            projectProvider,
            previous,
          ) {
            previous ??= GoalProvider(
              sessionProvider,
              taskProvider,
              projectProvider,
            );
            previous.sessionProvider = sessionProvider;
            previous.taskProvider = taskProvider;
            previous.projectProvider = projectProvider;
            return previous;
          },
        ),
        // Analytics Provider
        ChangeNotifierProxyProvider2<
          SettingsProvider,
          SessionProvider,
          AnalyticsProvider
        >(
          create:
              (context) => AnalyticsProvider(
                DatabaseHelper.instance,
                Provider.of<SettingsProvider>(context, listen: false),
              ),
          update: (context, settingsProvider, sessionProvider, previous) {
            return previous ??
                AnalyticsProvider(DatabaseHelper.instance, settingsProvider);
          },
        ),
      ],
      child: const AppRoot(),
    ),
  );
}
