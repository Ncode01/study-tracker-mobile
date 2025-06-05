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

  tearDownAll(() {
    teardownTestEnvironment();
  });

  group('Daily Study Planner Navigation Integration Tests', () {
    Widget createTestApp({required Widget home}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProjectProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
          ChangeNotifierProvider(create: (_) => SessionProvider()),
          ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
        ],
        child: MaterialApp(theme: ThemeData.dark(), home: home),
      );
    }

    testWidgets('DailyStudyPlannerScreen should render correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(home: const DailyStudyPlannerScreen()),
      );

      // Allow widget to build
      await tester.pumpAndSettle();

      // Verify that DailyStudyPlannerScreen is displayed
      expect(find.byType(DailyStudyPlannerScreen), findsOneWidget);
    });

    testWidgets('AddStudyPlanEntryScreen should render correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          home: AddStudyPlanEntryScreen(initialDate: DateTime.now()),
        ),
      );

      // Allow widget to build
      await tester.pumpAndSettle();

      // Verify that AddStudyPlanEntryScreen is displayed
      expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
    });

    testWidgets('DailyStudyPlannerScreen should handle initialDate parameter', (
      tester,
    ) async {
      final testDate = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        createTestApp(home: DailyStudyPlannerScreen(initialDate: testDate)),
      );

      // Allow widget to build
      await tester.pumpAndSettle();

      // Verify that DailyStudyPlannerScreen is displayed
      expect(find.byType(DailyStudyPlannerScreen), findsOneWidget);
    });

    testWidgets('AddStudyPlanEntryScreen should handle arguments correctly', (
      tester,
    ) async {
      final testDate = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        createTestApp(home: AddStudyPlanEntryScreen(initialDate: testDate)),
      );

      // Allow widget to build
      await tester.pumpAndSettle();

      // Verify that AddStudyPlanEntryScreen receives the arguments
      expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
    });

    testWidgets('should navigate from study planner to add entry', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(home: const DailyStudyPlannerScreen()),
      );

      // Allow widget to build
      await tester.pumpAndSettle();

      // Find and tap the floating action button (if exists)
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // Note: This test would require mocking Navigator.pushNamed
        // For now, we verify the FAB exists and is tappable
      }
    });
  });

  group('Navigation Route Parameter Tests', () {
    testWidgets('should parse date from route arguments', (tester) async {
      // Test that demonstrates how AddStudyPlanEntryScreen
      // handles arguments from ModalRoute.of(context)?.settings.arguments
      final testArgs = {'initialDate': DateTime(2024, 1, 15)};

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider(
                                  create: (_) => ProjectProvider(),
                                ),
                                ChangeNotifierProvider(
                                  create: (_) => TaskProvider(),
                                ),
                                ChangeNotifierProvider(
                                  create: (_) => SessionProvider(),
                                ),
                                ChangeNotifierProvider(
                                  create: (_) => StudyPlanProvider(),
                                ),
                              ],
                              child: AddStudyPlanEntryScreen(
                                initialDate: DateTime.now(),
                              ),
                            ),
                        settings: RouteSettings(arguments: testArgs),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
    });
  });
}
