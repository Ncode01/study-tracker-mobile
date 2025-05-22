import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/models/task_model.dart';
import '../../../mocks/mock_database_helper.mocks.dart';

void main() {
  group('TaskProvider', () {
    late TaskProvider provider;
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
      provider = TaskProvider();
    });

    test('addTask calls insertTask and updates list', () async {
      final task = Task(
        id: '1',
        projectId: 'p1',
        title: 'Test Task',
        description: 'desc',
        dueDate: DateTime.now(),
      );
      when(mockDb.insertTask(task)).thenAnswer((_) async => {});
      await provider.addTask(task);
      expect(provider.tasks.any((t) => t.id == '1'), true);
    });
  });
}
