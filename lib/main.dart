import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bytelearn_study_tracker/models/project.dart';
import 'package:bytelearn_study_tracker/models/session.dart';
import 'package:bytelearn_study_tracker/models/goal.dart';
import 'package:bytelearn_study_tracker/models/settings.dart';
import 'package:bytelearn_study_tracker/controllers/providers/project_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/timer_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/goal_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/settings_provider.dart';
import 'package:bytelearn_study_tracker/utilities/app_theme.dart';
import 'package:bytelearn_study_tracker/utilities/app_router.dart';
import 'package:bytelearn_study_tracker/views/home_screen.dart' as views;
import 'package:bytelearn_study_tracker/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await initHive();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Box<Project> projectBox = Hive.box<Project>('projects');
  final Box<Session> sessionBox = Hive.box<Session>('sessions');
  final Box<Goal> goalBox = Hive.box<Goal>('goals');
  final Box<Settings> settingsBox = Hive.box<Settings>('settings');

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider(projectBox)),
        ChangeNotifierProvider(create: (_) => TimerProvider(sessionBox)),
        ChangeNotifierProvider(create: (_) => GoalProvider(goalBox)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(settingsBox)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'ByteLearn Study Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                settingsProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: AppRouter.generateRoute,
            home: const views.HomeScreen(),
          );
        },
      ),
    );
  }
}
