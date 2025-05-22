import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/tasks/widgets/task_list_item.dart';
import 'package:study/src/models/task_model.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';

void main() {
  testWidgets('TaskListItem displays task info and checkbox', (
    WidgetTester tester,
  ) async {
    final task = Task(
      id: '1',
      projectId: 'p1',
      title: 'Test Task',
      description: 'desc',
      dueDate: DateTime.now(),
      isCompleted: false,
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => TaskProvider())],
        child: MaterialApp(home: Scaffold(body: TaskListItem(task: task))),
      ),
    );
    expect(find.text('Test Task'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is Checkbox && w.value == false),
      findsOneWidget,
    );
  });
}
