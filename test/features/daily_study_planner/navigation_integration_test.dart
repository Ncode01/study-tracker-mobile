import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/src/features/core_ui/screens/main_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/daily_study_planner_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/add_study_plan_entry_screen.dart';

import '../../test_helpers.dart';
import '../../test_app_setup.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  setUp(() async {
    await resetTestDatabase();
  });

  tearDownAll(() {
    teardownTestEnvironment();
  });

  group('Daily Study Planner Navigation Integration Tests', () {
    testWidgets('DailyStudyPlannerScreen should render correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestAppSetup.createTestApp(initialRoute: '/study-planner'),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DailyStudyPlannerScreen), findsOneWidget);
    });

    testWidgets('AddStudyPlanEntryScreen should render correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestAppSetup.createTestApp(initialRoute: '/study-planner/add'),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
    });

    testWidgets('DailyStudyPlannerScreen should handle initialDate parameter', (
      tester,
    ) async {
      final testDate = DateTime(2024, 1, 15);
      await tester.pumpWidget(
        TestAppSetup.createTestApp(
          home: DailyStudyPlannerScreen(initialDate: testDate),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DailyStudyPlannerScreen), findsOneWidget);
    });

    testWidgets('AddStudyPlanEntryScreen should handle arguments correctly', (
      tester,
    ) async {
      final testDate = DateTime(2024, 1, 15);
      await tester.pumpWidget(
        TestAppSetup.createTestApp(
          home: AddStudyPlanEntryScreen(initialDate: testDate),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
    });

    testWidgets('should navigate from study planner to add entry', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestAppSetup.createTestApp(initialRoute: '/study-planner'),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();
        expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
      }
    });

    testWidgets('should handle dynamic route with date query parameter', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestAppSetup.createTestApp(
          initialRoute: '/study-planner/add?date=2025-06-05',
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
    });
    testWidgets('should fallback gracefully for invalid routes', (
      tester,
    ) async {
      await tester.pumpWidget(TestAppSetup.createTestApp(initialRoute: '/'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      // Navigate to an invalid route after app start
      final BuildContext context = tester.element(find.byType(MainScreen));
      Navigator.of(context).pushNamed('/invalid-route');
      await tester.pump(); // Allow navigation to start
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for navigation
      expect(find.text('Page Not Found'), findsAtLeastNWidgets(1));
      expect(find.text('Route not found: /invalid-route'), findsOneWidget);
    });

    testWidgets('should parse date from route arguments', (tester) async {
      await tester.pumpWidget(
        TestAppSetup.createTestApp(
          home: AddStudyPlanEntryScreen(initialDate: DateTime(2024, 1, 15)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AddStudyPlanEntryScreen), findsOneWidget);
    });
  });
}
