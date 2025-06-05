import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/app.dart';
import 'package:study/src/features/projects/providers/project_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';

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
      ],
      child: const AppRoot(),
    ),
  );
}
