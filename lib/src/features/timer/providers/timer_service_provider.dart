import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/services/database_helper.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';

class TimerServiceProvider extends ChangeNotifier {
  String? _activeProjectId;
  DateTime? _timerStartTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _ticker;
  bool _disposed = false;

  String? get activeProjectId => _activeProjectId;
  bool get isTimerRunning => _activeProjectId != null;
  Duration get elapsedTime => _elapsedTime;

  void startTimer(Project project, BuildContext context) {
    if (_disposed) return;
    if (isTimerRunning) {
      stopTimer(context);
    }
    _activeProjectId = project.id;
    _timerStartTime = DateTime.now();
    _elapsedTime = Duration.zero;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      _elapsedTime = DateTime.now().difference(_timerStartTime!);
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> stopTimer(BuildContext context) async {
    if (_disposed) return;
    if (!isTimerRunning || _timerStartTime == null) return;
    _ticker?.cancel();
    final endTime = DateTime.now();
    final durationMinutes =
        _elapsedTime.inMinutes > 0 ? _elapsedTime.inMinutes : 1;
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final project = projectProvider.projects.firstWhere(
      (p) => p.id == _activeProjectId,
    );
    final newLoggedMinutes = project.loggedMinutes + durationMinutes;
    await projectProvider.updateProjectLoggedTime(
      projectId: _activeProjectId!,
      newLoggedMinutes: newLoggedMinutes,
    );
    final session = Session(
      id: const Uuid().v4(),
      projectId: _activeProjectId!,
      projectName: project.name,
      startTime: _timerStartTime!,
      endTime: endTime,
      durationMinutes: durationMinutes,
    );
    await DatabaseHelper.instance.insertSession(session);
    // Immediately refresh sessions in provider so analytics and goals update live
    await Provider.of<SessionProvider>(context, listen: false).fetchSessions();
    _activeProjectId = null;
    _timerStartTime = null;
    _elapsedTime = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
