import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/models/project_model.dart';
import 'package:flutter/material.dart';
import '../../../mocks/mock_database_helper.mocks.dart';

void main() {
  group('TimerServiceProvider', () {
    late TimerServiceProvider provider;
    late MockDatabaseHelper mockDb;
    late Project project;

    setUp(() {
      mockDb = MockDatabaseHelper();
      provider = TimerServiceProvider();
      project = Project(
        id: '1',
        name: 'Test',
        color: const Color(0xFF000000),
        goalMinutes: 60,
        loggedMinutes: 0,
        dueDate: null,
      );
    });

    test('startTimer sets state', () {
      provider.startTimer(project, BuildContextFake());
      expect(provider.isTimerRunning, true);
      expect(provider.activeProjectId, '1');
    });
  });
}

class BuildContextFake extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
