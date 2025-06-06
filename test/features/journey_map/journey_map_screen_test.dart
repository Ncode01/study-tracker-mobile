import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/journey_map/screens/journey_map_screen.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import '../../test_helpers.dart';

void main() {
  // Set up test environment
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    teardownTestEnvironment();
  });

  group('Journey Map Screen', () {
    testWidgets('should display without crashing', (WidgetTester tester) async {
      // Build the Journey Map screen with all required providers
      await tester.pumpWidget(
        createTestApp(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
              ChangeNotifierProvider(create: (_) => ProjectProvider()),
              ChangeNotifierProvider(create: (_) => SessionProvider()),
              ChangeNotifierProvider(create: (_) => TaskProvider()),
            ],
            child: const JourneyMapScreen(),
          ),
        ),
      ); // Allow the widget to build with multiple pump calls to avoid infinite rebuild timeout
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the screen loads without errors
      expect(find.byType(JourneyMapScreen), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('should display all three tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
              ChangeNotifierProvider(create: (_) => ProjectProvider()),
              ChangeNotifierProvider(create: (_) => SessionProvider()),
              ChangeNotifierProvider(create: (_) => TaskProvider()),
            ],
            child: const JourneyMapScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Verify all three tabs are present
      expect(find.text('Journey Map'), findsOneWidget);
      expect(find.text("Today's Quest"), findsOneWidget);
      expect(find.text('Journey Progress'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
    });
    testWidgets('should display Add New Stop button in Day tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
              ChangeNotifierProvider(create: (_) => ProjectProvider()),
              ChangeNotifierProvider(create: (_) => SessionProvider()),
              ChangeNotifierProvider(create: (_) => TaskProvider()),
            ],
            child: const JourneyMapScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // The Today's Quest tab should be selected by default
      expect(find.text("Today's Quest"), findsOneWidget);

      // Verify Add New Stop button is present
      expect(find.text('Add New Stop'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('should display dynamic data sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => StudyPlanProvider()),
              ChangeNotifierProvider(create: (_) => ProjectProvider()),
              ChangeNotifierProvider(create: (_) => SessionProvider()),
              ChangeNotifierProvider(create: (_) => TaskProvider()),
            ],
            child: const JourneyMapScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Verify progress summary sections in Today's Quest tab
      expect(find.text('Study Hours'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Quests'), findsOneWidget);

      // Verify Today's Itinerary section
      expect(find.text('Today\'s Itinerary'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);

      // Tap on Achievements tab
      await tester.tap(find.text('Achievements'));
      await tester.pumpAndSettle();

      // Verify Achievements section
      expect(find.text('Your Achievements'), findsOneWidget);
      expect(find.text('Journey Stats'), findsOneWidget);
    });
  });
}
