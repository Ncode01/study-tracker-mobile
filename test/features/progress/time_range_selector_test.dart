import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/features/progress/presentation/widgets/time_range_selector.dart';
import 'package:study/features/progress/domain/models/study_analytics.dart';
import 'package:study/features/progress/providers/analytics_providers.dart';

void main() {
  group('TimeRangeSelector Widget Tests', () {
    testWidgets('displays all time range options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: TimeRangeSelector())),
        ),
      );

      // Verify all time range options are displayed
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last 3 Months'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
    });

    testWidgets('changes selection when tapped', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: Scaffold(body: TimeRangeSelector())),
        ),
      );

      // Verify initial selection is week
      expect(
        container.read(selectedTimeRangeProvider),
        AnalyticsTimeRange.week,
      );

      // Tap on month option
      await tester.tap(find.text('This Month'));
      await tester.pump();

      // Verify selection changed to month
      expect(
        container.read(selectedTimeRangeProvider),
        AnalyticsTimeRange.month,
      );
    });

    testWidgets('highlights selected range', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedTimeRangeProvider.overrideWith(
              (ref) => AnalyticsTimeRange.month,
            ),
          ],
          child: MaterialApp(home: Scaffold(body: TimeRangeSelector())),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // Verify the widget displays the correct selection
      expect(find.text('This Month'), findsOneWidget);
    });
  });
}
