// This is a basic Flutter widget test for Project Atlas.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study/widgets/auth/custom_text_field.dart';
k
void main() {
  testWidgets('CustomTextField rendersj correctly', (WidgetTester tester) async {
    final controller = TextEditingController();

    // Build the CustomTextField widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: controller,
            label: 'Email',
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ),h
    );

    // Allow time for the widget to render
    await tester.pumpAndSettle();

    // Verify that the label and hint are displayed
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Enter your email address'), findsOneWidget);

    // Verify the text field is present
    expect(find.byType(TextFormField), findsOneWidget);

    // Test typing in the field
    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    expect(controller.text, 'test@example.com');
  });
}
