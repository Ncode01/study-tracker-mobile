import 'package:flutter/material.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/services/database_helper.dart';
import '../../journey_map/models/journey_day.dart';
import '../../daily_study_planner/providers/study_plan_provider.dart';

class SessionProvider extends ChangeNotifier {
  List<Session> _sessions = [];
  bool _disposed = false;
  List<Session> get sessions => _sessions;

  // --- Journey Path State ---
  List<JourneyDay> _journeyDays = [];
  int _consecutiveDays = 0;
  List<JourneyDay> get journeyDays => _journeyDays;
  int get consecutiveDays => _consecutiveDays;

  Future<void> fetchSessions() async {
    if (_disposed) return;
    _sessions = await DatabaseHelper.instance.getAllSessions();
    if (!_disposed) notifyListeners();
  }

  /// Calculates the journey path for the Daily Study Path feature.
  Future<void> calculateJourneyPath(StudyPlanProvider studyPlanProvider) async {
    // Fetch all sessions and study plans
    final allSessions = _sessions;
    final allPlans = studyPlanProvider.studyPlanEntries;
    if (allSessions.isEmpty && allPlans.isEmpty) {
      _journeyDays = [];
      _consecutiveDays = 0;
      notifyListeners();
      return;
    }
    // Find the earliest date
    DateTime? firstSessionDate =
        allSessions.isNotEmpty
            ? allSessions
                .map((s) => s.startTime)
                .reduce((a, b) => a.isBefore(b) ? a : b)
            : null;
    DateTime? firstPlanDate =
        allPlans.isNotEmpty
            ? allPlans
                .map((e) => e.date)
                .reduce((a, b) => a.isBefore(b) ? a : b)
            : null;
    DateTime firstDate;
    if (firstSessionDate != null && firstPlanDate != null) {
      firstDate =
          firstSessionDate.isBefore(firstPlanDate)
              ? firstSessionDate
              : firstPlanDate;
    } else {
      firstDate = firstSessionDate ?? firstPlanDate!;
    }
    final today = DateTime.now();
    final days = today.difference(firstDate).inDays + 1;
    final titles = [
      'Forest of Focus',
      'River of Reading',
      'Mountain of Math',
      'Valley of Vocabulary',
      'Caves of Coding',
      'Summit of Success',
    ];
    final List<JourneyDay> journeyDays = [];
    for (int i = 0; i < days; i++) {
      final date = firstDate.add(Duration(days: i));
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isFuture = date.isAfter(today);
      final hadSession = allSessions.any(
        (s) =>
            s.startTime.year == date.year &&
            s.startTime.month == date.month &&
            s.startTime.day == date.day,
      );
      final hadCompletedPlan = allPlans.any(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day &&
            e.isCompleted,
      );
      JourneyDayStatus status;
      if (isFuture) {
        status = JourneyDayStatus.upcoming;
      } else if (isToday) {
        status = JourneyDayStatus.current;
      } else if (hadSession || hadCompletedPlan) {
        status = JourneyDayStatus.completed;
      } else {
        status = JourneyDayStatus.missed;
      }
      final title = titles[i % titles.length];
      String subtitle;
      switch (status) {
        case JourneyDayStatus.completed:
          subtitle = 'Completed! You ventured bravely.';
          break;
        case JourneyDayStatus.current:
          subtitle = 'Your current challenge!';
          break;
        case JourneyDayStatus.missed:
          subtitle = 'Missed this stop.';
          break;
        case JourneyDayStatus.upcoming:
          subtitle = 'Awaits your exploration!';
          break;
      }
      journeyDays.add(
        JourneyDay(
          date: date,
          dayNumber: i + 1,
          title: title,
          subtitle: subtitle,
          status: status,
        ),
      );
    }
    // Calculate streak
    int streak = 0;
    for (int i = journeyDays.length - 2; i >= 0; i--) {
      if (journeyDays[i].status == JourneyDayStatus.completed) {
        streak++;
      } else {
        break;
      }
    }
    _journeyDays = journeyDays;
    _consecutiveDays = streak;
    notifyListeners();
  }

  /// TEST-ONLY: Allows setting sessions directly for unit tests.
  void setSessionsForTest(List<Session> sessions) {
    _sessions = sessions;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
