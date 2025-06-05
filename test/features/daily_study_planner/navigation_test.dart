import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/features/daily_study_planner/screens/daily_study_planner_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/add_study_plan_entry_screen.dart';
import 'package:study/src/features/projects/providers/project_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';

import '../../test_helpers.dart';

void main() {
  // Set up test environment with database factory and platform channel mocking
  setUpAll(() {
    setupTestEnvironment();
  });

  // Reset database state between tests to prevent locking
  setUp(() async {
    await resetTestDatabase();
  });

  tearDownAll(() {
    teardownTestEnvironment();
  });

  group('Daily Study Planner Navigation Tests', () {
    Widget createTestApp({String? initialRoute, Object? arguments}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProjectProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
          ChangeNotifierProvider(create: (_) => SessionProvider()),
          ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
        ],
        child: MaterialApp(
          title: 'Study Tracker',
          theme: ThemeData.dark(),
          initialRoute: initialRoute ?? '/',
          onGenerateRoute: (settings) {
            // Simple route generation for testing
            switch (settings.name) {
              case '/study-planner':
                return MaterialPageRoute(
                  builder: (_) => const DailyStudyPlannerScreen(),
                  settings: settings,
                );
              case '/study-planner/add':
                return MaterialPageRoute(
                  builder:
                      (_) =>
                          AddStudyPlanEntryScreen(initialDate: DateTime.now()),
                  settings: settings,
                );
              default:
                return MaterialPageRoute(
                  builder:
                      (_) => const Scaffold(
                        body: Center(child: Text('Study Tracker')),
                      ),
                );
            }
          },
        ),
      );
    }

    testWidgets('should navigate to study planner screen via named route', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(initialRoute: '/study-planner'));

      // Allow widget to build with shorter timeout
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that DailyStudyPlannerScreen is displayed
      expect(find.byType(DailyStudyPlannerScreen), findsOneWidget);
    });
    testWidgets(
      'should navigate to add study plan entry screen via named route',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/study-planner/add'),
        );

        // Allow widget to build with shorter timeout
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify that AddStudyPlanEntryScreen is displayed
        expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
      },
    );

    testWidgets('should fallback gracefully for invalid routes', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(initialRoute: '/invalid-route'));

      // Allow widget to build with shorter timeout
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should fallback to home screen
      expect(find.text('Study Tracker'), findsOneWidget);
    });
  });
}
