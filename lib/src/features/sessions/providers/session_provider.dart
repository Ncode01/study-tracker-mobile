import 'package:flutter/material.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/services/database_helper.dart';

class SessionProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  List<Session> _sessionsForSelectedDate = [];
  List<Session> _sessions = [];

  DateTime get selectedDate => _selectedDate;
  List<Session> get sessions => _sessions;
  List<Session> get sessionsForSelectedDate => _sessionsForSelectedDate;

  int get totalWorkedMinutesOnSelectedDate =>
      _sessionsForSelectedDate.fold(0, (sum, s) => sum + s.durationMinutes);
  int get sessionCountOnSelectedDate => _sessionsForSelectedDate.length;

  SessionProvider() {
    fetchSessionsForDate(_selectedDate);
  }

  Future<void> fetchSessions() async {
    _sessions = await DatabaseHelper.instance.getAllSessions();
    notifyListeners();
  }

  Future<void> fetchSessionsForDate(DateTime date) async {
    _selectedDate = date;
    _sessionsForSelectedDate = await DatabaseHelper.instance.getSessionsForDate(
      date,
    );
    notifyListeners();
  }
}
