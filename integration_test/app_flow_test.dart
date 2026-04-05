import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:study_tracker_mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and analytics screen is reachable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TimeFlowApp()));
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(Scaffold), findsWidgets);

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.text('Daily Truth'), findsOneWidget);
    expect(find.text('Export Data'), findsOneWidget);
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.textContaining('Error'), findsNothing);
  });
}
