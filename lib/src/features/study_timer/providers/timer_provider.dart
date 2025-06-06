import 'dart:async';
import 'package:flutter/foundation.dart';

/// Enum representing the timer's mode (Focus, Short Break, Long Break).
enum TimerMode { focus, shortBreak, longBreak }

/// Enum representing the timer's running status.
enum TimerStatus { stopped, running, paused }

/// A provider that manages the state and logic for the Study Timer.
///
/// Handles starting, pausing, resetting, and switching between timer modes.
/// Notifies listeners on every tick and when state changes.
class TimerProvider extends ChangeNotifier {
  // --- Private State ---
  Timer? _timer;
  Duration _duration;
  TimerMode _mode;
  TimerStatus _status;

  // Default durations for each mode
  final Duration _initialFocusDuration = const Duration(minutes: 25);
  final Duration _initialShortBreakDuration = const Duration(minutes: 5);
  final Duration _initialLongBreakDuration = const Duration(minutes: 15);

  Duration? _overtime;
  bool _isBreak = false;

  /// Creates a TimerProvider with default state (Focus mode, stopped, 25:00).
  TimerProvider()
    : _duration = const Duration(minutes: 25),
      _mode = TimerMode.focus,
      _status = TimerStatus.stopped;

  // --- Public Getters ---

  /// The current time remaining on the timer.
  Duration get duration => _duration;

  /// The current timer mode (focus, short break, long break).
  TimerMode get mode => _mode;

  /// The current running status (stopped, running, paused).
  TimerStatus get status => _status;

  /// The default duration for the current mode.
  Duration get initialDuration {
    switch (_mode) {
      case TimerMode.focus:
        return _initialFocusDuration;
      case TimerMode.shortBreak:
        return _initialShortBreakDuration;
      case TimerMode.longBreak:
        return _initialLongBreakDuration;
    }
  }

  Duration? get overtime => _overtime;
  bool get isBreak => _isBreak;

  // --- Public Methods ---

  /// Starts or resumes the timer. If already running, does nothing.
  void startTimer() {
    if (_status == TimerStatus.running) return;
    _status = TimerStatus.running;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  /// Pauses the timer if it is running.
  void pauseTimer() {
    if (_status != TimerStatus.running) return;
    _status = TimerStatus.paused;
    _timer?.cancel();
    notifyListeners();
  }

  /// Resets the timer to the initial duration for the current mode and stops it.
  void resetTimer() {
    _status = TimerStatus.stopped;
    _timer?.cancel();
    _isBreak = false;
    _mode = TimerMode.focus;
    _duration = _initialFocusDuration;
    _overtime = null;
    notifyListeners();
  }

  // --- Private Methods ---

  /// Called every second by the periodic timer. Decrements the duration.
  void _tick(Timer timer) {
    if (!_isBreak) {
      if (_duration.inSeconds > 0) {
        _duration -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        // Focus finished, start break
        _isBreak = true;
        _overtime = Duration.zero;
        _duration = _initialShortBreakDuration;
        _mode = TimerMode.shortBreak;
        notifyListeners();
      }
    } else {
      // Break mode
      if (_duration.inSeconds > 0) {
        _duration -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        // Break finished, stop timer
        _timer?.cancel();
        _status = TimerStatus.stopped;
        _isBreak = false;
        _mode = TimerMode.focus;
        _duration = _initialFocusDuration;
        notifyListeners();
      }
    }
    // Overtime calculation
    if (!_isBreak && _duration.isNegative) {
      _overtime = -_duration;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
