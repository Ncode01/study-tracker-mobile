import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/app.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
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
            if (previous == null) {
              previous = GoalProvider(
                sessionProvider,
                taskProvider,
                projectProvider,
              );
            } else {
              previous.sessionProvider = sessionProvider;
              previous.taskProvider = taskProvider;
              previous.projectProvider = projectProvider;
            }
            // Ensure goal progress is updated when dependent providers change.
            previous.updateGoalProgress();
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
            if (previous == null) {
              return AnalyticsProvider(
                DatabaseHelper.instance,
                settingsProvider,
              );
            }
            // When SessionProvider or SettingsProvider changes, refresh analytics.
            // AnalyticsProvider internally listens to settingsProvider for changes.
            // For SessionProvider changes, we explicitly call refreshAnalytics.
            previous.refreshAnalytics();
            return previous;
          },
        ),
      ],
      child: const AppRoot(),
    ),
  );
}
