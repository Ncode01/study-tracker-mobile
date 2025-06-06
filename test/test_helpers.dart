import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/services/database_helper.dart';

/// Sets up the test environment with proper database factory and platform channel mocking
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite_common_ffi for testing with isolated databases
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Setup platform channel mocking for path_provider
  const MethodChannel(
    'plugins.flutter.io/path_provider',
  ).setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getApplicationDocumentsDirectory':
        return '/tmp/test_documents_${DateTime.now().millisecondsSinceEpoch}';
      case 'getApplicationSupportDirectory':
        return '/tmp/test_support_${DateTime.now().millisecondsSinceEpoch}';
      case 'getTemporaryDirectory':
        return '/tmp/test_temp_${DateTime.now().millisecondsSinceEpoch}';
      default:
        return null;
    }
  });
}

/// Wraps a widget with all necessary providers for testing
Widget createTestApp({required Widget child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
      ChangeNotifierProvider(create: (_) => SessionProvider()),
      ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
    ],
    child: MaterialApp(
      home: child,
      // Disable animations in tests to prevent timeouts
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
    ),
  );
}

/// Wraps a widget with all necessary providers and routing for testing
Widget createTestAppWithRouting({required Widget child, String? initialRoute}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
      ChangeNotifierProvider(create: (_) => SessionProvider()),
      ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
    ],
    child: MaterialApp(
      initialRoute: initialRoute ?? '/',
      routes: {
        '/': (context) => child,
        '/study-planner/add':
            (context) => Container(), // Mock route for testing
      },
      onGenerateRoute: (settings) {
        // Mock route generation for testing
        switch (settings.name) {
          case '/study-planner/add':
            return MaterialPageRoute(
              builder: (context) => Container(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (context) => child,
              settings: settings,
            );
        }
      },
    ),
  );
}

/// Cleans up after test execution
void teardownTestEnvironment() {
  // Reset platform channel mocking
  const MethodChannel(
    'plugins.flutter.io/path_provider',
  ).setMockMethodCallHandler(null);
}

/// Resets database state for individual tests
Future<void> resetTestDatabase() async {
  try {
    // Reset database singleton state
    await DatabaseHelper.resetDatabase();
  } catch (e) {
    // Ignore errors during test cleanup
  }
}
