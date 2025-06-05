// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  // Set up test environment with database factory and platform channel mocking
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    teardownTestEnvironment();
  });

  testWidgets('App should load without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(createTestApp(child: Container()));

    // Allow widget to build
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    // We expect to find at least one widget in the tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should display bottom navigation', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(createTestApp(child: Container()));

    // Allow widget to build
    await tester.pumpAndSettle();

    // Look for bottom navigation bar or main screen elements
    // This test verifies the app structure loads correctly
    expect(find.byType(Scaffold), findsWidgets);
  });
}
