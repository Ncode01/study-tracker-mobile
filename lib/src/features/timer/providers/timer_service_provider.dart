import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/services/database_helper.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';

/// Enum representing the timer's mode (Focus, Short Break, Long Break).
enum TimerMode { focus, shortBreak, longBreak }

/// Enum representing the timer's running status.
enum TimerStatus { stopped, running, paused }

class TimerServiceProvider extends ChangeNotifier {
  // Session tracking variables (existing)
  String? _activeProjectId;
  DateTime? _timerStartTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _ticker;
  bool _disposed = false;

  // Pomodoro countdown variables (new)
  Timer? _countdownTimer;
  Duration _currentDuration = const Duration(minutes: 25);
  Duration _initialDuration = const Duration(minutes: 25);
  TimerMode _currentMode = TimerMode.focus;
  TimerStatus _status = TimerStatus.stopped;

  // Default durations for each mode
  static const Duration _focusDuration = Duration(minutes: 25);
  static const Duration _shortBreakDuration = Duration(minutes: 5);
  static const Duration _longBreakDuration = Duration(minutes: 15);

  // Public getters (existing)
  String? get activeProjectId => _activeProjectId;
  bool get isTimerRunning => _activeProjectId != null;
  Duration get elapsedTime => _elapsedTime;

  // Public getters (new Pomodoro)
  Duration get currentDuration => _currentDuration;
  Duration get initialDuration => _initialDuration;
  TimerMode get currentMode => _currentMode;
  TimerStatus get status => _status;
  void startTimer(Project project, BuildContext context) {
    if (_disposed) return;

    // If timer is already running for another project, stop it first
    if (isTimerRunning) {
      stopTimer(context);
    }

    // Start session tracking
    _activeProjectId = project.id;
    _timerStartTime = DateTime.now();
    _elapsedTime = Duration.zero;

    // Start visual countdown
    _status = TimerStatus.running;
    _startCountdown();

    // Start elapsed time ticker
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

  void pauseTimer() {
    if (_disposed || _status != TimerStatus.running) return;

    _status = TimerStatus.paused;
    _countdownTimer?.cancel();
    notifyListeners();
  }

  void resumeTimer() {
    if (_disposed || _status != TimerStatus.paused) return;

    _status = TimerStatus.running;
    _startCountdown();
    notifyListeners();
  }

  void selectMode(TimerMode newMode) {
    if (_disposed) return;

    // Stop any active timers
    _countdownTimer?.cancel();
    _status = TimerStatus.stopped;
    _currentMode = newMode;

    // Set initial duration based on mode
    switch (newMode) {
      case TimerMode.focus:
        _initialDuration = _focusDuration;
        break;
      case TimerMode.shortBreak:
        _initialDuration = _shortBreakDuration;
        break;
      case TimerMode.longBreak:
        _initialDuration = _longBreakDuration;
        break;
    }

    _currentDuration = _initialDuration;
    notifyListeners();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (_disposed) {
      timer.cancel();
      return;
    }

    if (_currentDuration.inSeconds <= 0) {
      // Timer completed
      timer.cancel();
      _status = TimerStatus.stopped;
      notifyListeners();
      return;
    }

    _currentDuration = Duration(seconds: _currentDuration.inSeconds - 1);
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
    _countdownTimer?.cancel();
    super.dispose();
  }
}
