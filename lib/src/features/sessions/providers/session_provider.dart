import 'package:flutter/material.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/services/database_helper.dart';

class SessionProvider extends ChangeNotifier {
  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  Future<void> fetchSessions() async {
    _sessions = await DatabaseHelper.instance.getAllSessions();
    notifyListeners();
  }
}
