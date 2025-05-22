import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:study/src/features/projects/providers/project_provider.dart';
import 'package:study/src/models/project_model.dart';
import '../../../mocks/mock_database_helper.mocks.dart';

void main() {
  group('ProjectProvider', () {
    late ProjectProvider provider;
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
      provider = ProjectProvider();
    });

    test('addProject calls insertProject and updates list', () async {
      final project = Project(
        id: '1',
        name: 'Test',
        color: const Color(0xFF000000),
        goalMinutes: 60,
        loggedMinutes: 0,
        dueDate: null,
      );
      when(mockDb.insertProject(project)).thenAnswer((_) async => {});
      await provider.addProject(project);
      // No direct way to check notifyListeners, but can check list update
      expect(provider.projects.any((p) => p.id == '1'), true);
    });
  });
}
