import 'package:flutter/material.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/services/database_helper.dart';

class SessionProvider extends ChangeNotifier {
  List<Session> _sessions = [];
  bool _disposed = false; // Track disposal state
  List<Session> get sessions => _sessions;

  Future<void> fetchSessions() async {
    if (_disposed) return; // Prevent operations after disposal
    _sessions = await DatabaseHelper.instance.getAllSessions();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
