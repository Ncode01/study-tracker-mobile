import 'package:flutter_test/flutter_test.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/journey_map/models/journey_day.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/models/study_plan_entry_model.dart';

class MockStudyPlanProvider extends StudyPlanProvider {
  @override
  List<StudyPlanEntry> get studyPlanEntries => _mockEntries;
  List<StudyPlanEntry> _mockEntries = [];
  set mockEntries(List<StudyPlanEntry> entries) => _mockEntries = entries;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionProvider.calculateJourneyPath', () {
    test('generates correct journey days and streak', () async {
      final sessionProvider = SessionProvider();
      final mockPlanProvider = MockStudyPlanProvider();
      // Simulate 3 days: 2 completed, 1 missed, 1 current (today)
      final today = DateTime.now();
      final day1 = today.subtract(const Duration(days: 3));
      final day2 = today.subtract(const Duration(days: 2));
      // Sessions for day1 and day2
      sessionProvider.setSessionsForTest([
        Session(
          id: '1',
          projectId: 'p1',
          projectName: 'Test',
          startTime: day1,
          endTime: day1.add(const Duration(hours: 1)),
          durationMinutes: 60,
        ),
        Session(
          id: '2',
          projectId: 'p1',
          projectName: 'Test',
          startTime: day2,
          endTime: day2.add(const Duration(hours: 1)),
          durationMinutes: 60,
        ),
      ]);
      // Study plan for today (not completed)
      mockPlanProvider.mockEntries = [
        StudyPlanEntry(
          id: 'sp1',
          subjectName: 'Math',
          projectId: null,
          date: today,
          startTime: null,
          endTime: null,
          isAllDay: true,
          notes: null,
          reminderDateTime: null,
          isCompleted: false,
          createdAt: today,
        ),
      ];
      await sessionProvider.calculateJourneyPath(mockPlanProvider);
      final journeyDays = sessionProvider.journeyDays;
      expect(journeyDays.length, 4);
      expect(journeyDays[0].status, JourneyDayStatus.completed);
      expect(journeyDays[1].status, JourneyDayStatus.completed);
      expect(journeyDays[2].status, JourneyDayStatus.missed);
      expect(journeyDays[3].status, JourneyDayStatus.current);
      expect(sessionProvider.consecutiveDays, 0);
    });
  });
}
