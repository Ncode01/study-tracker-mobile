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
        // Add GoalProvider, wiring dependencies
        ChangeNotifierProxyProvider2<
          SessionProvider,
          StudyPlanProvider,
          GoalProvider
        >(
          create:
              (context) => GoalProvider(
                sessionProvider: Provider.of<SessionProvider>(
                  context,
                  listen: false,
                ),
                studyPlanProvider: Provider.of<StudyPlanProvider>(
                  context,
                  listen: false,
                ),
              ),
          update: (context, sessionProvider, studyPlanProvider, goalProvider) {
            goalProvider ??= GoalProvider(
              sessionProvider: sessionProvider,
              studyPlanProvider: studyPlanProvider,
            );
            goalProvider.sessionProvider = sessionProvider;
            goalProvider.studyPlanProvider = studyPlanProvider;
            return goalProvider;
          },
        ),
      ],
      child: const AppRoot(),
    ),
  );
}
