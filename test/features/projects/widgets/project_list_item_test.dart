import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/projects/widgets/project_list_item.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';

void main() {
  testWidgets('ProjectListItem displays project info and play button', (
    WidgetTester tester,
  ) async {
    final project = Project(
      id: '1',
      name: 'Test Project',
      color: Colors.blue,
      goalMinutes: 120,
      loggedMinutes: 30,
      dueDate: null,
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(body: ProjectListItem(project: project)),
        ),
      ),
    );
    expect(find.text('Test Project'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.textContaining('30'), findsOneWidget);
  });
}
