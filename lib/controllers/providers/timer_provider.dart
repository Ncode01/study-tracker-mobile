import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bytelearn_study_tracker/models/session.dart';
import 'package:bytelearn_study_tracker/models/settings.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

enum TimerMode { focus, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  final Box<Session> _sessionBox;
  List<Session> _sessions = [];
  Session? _activeSession;
  bool _isRunning = false;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  String? _projectId;
  String _notes = '';

  // Pomodoro specific properties
  TimerMode _currentMode = TimerMode.focus;
  int _completedFocusSessions = 0;
  int _targetDuration = 25 * 60; // Default 25 minutes in seconds
  Timer? _timer;
  int _remainingSeconds = 25 * 60;
  double _progress = 0.0;

  // Background task identifier
  static const String _backgroundTaskKey = 'bytelearn_timer_background';

  // Notification setup
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TimerProvider(this._sessionBox) {
    _loadSessions();
    _initializeNotifications();
    _restoreTimerState();
  }

  // Getters
  List<Session> get sessions => _sessions;
  Session? get activeSession => _activeSession;
  bool get isRunning => _isRunning;
  Duration get elapsedTime => _elapsedTime;
  String? get projectId => _projectId;
  String get notes => _notes;
  TimerMode get currentMode => _currentMode;
  int get completedFocusSessions => _completedFocusSessions;
  int get remainingSeconds => _remainingSeconds;
  double get progress => _progress;
  int get targetDuration => _targetDuration;

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Restore timer state if app was closed
  Future<void> _restoreTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunningInBackground =
        prefs.getBool('isRunningInBackground') ?? false;

    if (isRunningInBackground) {
      final projectId = prefs.getString('projectId');
      final notes = prefs.getString('notes') ?? '';
      final startTimeMillis = prefs.getInt('startTime');
      final modeIndex = prefs.getInt('timerMode') ?? 0;
      final completedSessions = prefs.getInt('completedSessions') ?? 0;

      if (projectId != null && startTimeMillis != null) {
        _projectId = projectId;
        _notes = notes;
        _startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
        _currentMode = TimerMode.values[modeIndex];
        _completedFocusSessions = completedSessions;
        _isRunning = true;

        _activeSession = Session.start(projectId: projectId, notes: notes);
        _updateTimer();
      }
    }
  }

  // Save timer state for background execution
  Future<void> _saveTimerState() async {
    if (_isRunning && _startTime != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRunningInBackground', true);
      await prefs.setString('projectId', _projectId!);
      await prefs.setString('notes', _notes);
      await prefs.setInt('startTime', _startTime!.millisecondsSinceEpoch);
      await prefs.setInt('timerMode', _currentMode.index);
      await prefs.setInt('completedSessions', _completedFocusSessions);
    }
  }

  // Clear background timer state
  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRunningInBackground', false);
    await prefs.remove('projectId');
    await prefs.remove('notes');
    await prefs.remove('startTime');
    await prefs.remove('timerMode');
    await prefs.remove('completedSessions');
  }

  // Load sessions from Hive box
  Future<void> _loadSessions() async {
    _sessions = _sessionBox.values.toList();
    notifyListeners();
  }

  // Configure timer for different modes (focus, short break, long break)
  void configureTimer(TimerSettings settings) {
    switch (_currentMode) {
      case TimerMode.focus:
        _targetDuration = settings.workDuration * 60;
        break;
      case TimerMode.shortBreak:
        _targetDuration = settings.shortBreakDuration * 60;
        break;
      case TimerMode.longBreak:
        _targetDuration = settings.longBreakDuration * 60;
        break;
    }
    _remainingSeconds = _targetDuration;
    _progress = 0.0;
    notifyListeners();
  }

  // Start timer
  void startTimer(
    String projectId, {
    String notes = '',
    TimerSettings? settings,
  }) {
    if (_isRunning) return;

    _projectId = projectId;
    _notes = notes;
    _startTime = DateTime.now();
    _elapsedTime = Duration.zero;
    _isRunning = true;

    // Configure the timer based on mode and settings
    if (settings != null && settings.usePomodoroTimer) {
      configureTimer(settings);
      _startPomodoroTimer();
    }

    _activeSession = Session.start(projectId: projectId, notes: notes);

    // Save timer state for background execution
    _saveTimerState();

    // Register a background task for the timer
    Workmanager().registerOneOffTask(
      _backgroundTaskKey,
      _backgroundTaskKey,
      inputData: {
        'projectId': projectId,
        'notes': notes,
        'startTime': _startTime!.millisecondsSinceEpoch,
        'timerMode': _currentMode.index,
        'targetDuration': _targetDuration,
      },
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    notifyListeners();

    // Start timer update loop
    _updateTimer();
  }

  // Start Pomodoro timer with precise seconds counting
  void _startPomodoroTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;

      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _progress = 1 - (_remainingSeconds / _targetDuration);
        notifyListeners();
      } else {
        _handleTimerCompletion();
      }
    });
  }

  // Handle timer completion (session end or transition to break)
  void _handleTimerCompletion() {
    _timer?.cancel();

    // Trigger notification and vibration
    _showTimerCompletionNotification();
    _triggerHapticFeedback();

    // Handle mode transitions
    if (_currentMode == TimerMode.focus) {
      _completedFocusSessions++;

      // Save the completed session
      if (_activeSession != null) {
        stopTimer(autoStart: true);
      }

      // Determine if we should take a short or long break
      if (_completedFocusSessions % 4 == 0) {
        _currentMode = TimerMode.longBreak;
      } else {
        _currentMode = TimerMode.shortBreak;
      }
    } else {
      // After a break, go back to focus mode
      _currentMode = TimerMode.focus;
    }

    // Update timer for the new mode
    _isRunning = false;
    notifyListeners();
  }

  // Show notification when timer completes
  Future<void> _showTimerCompletionNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'timer_completion',
          'Timer Completion',
          channelDescription: 'Notifications for timer completion',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('timer_complete'),
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    String title;
    String body;

    if (_currentMode == TimerMode.focus) {
      title = 'Focus Session Complete!';
      body = 'Great job! Time for a break.';
    } else if (_currentMode == TimerMode.shortBreak) {
      title = 'Break Time Over';
      body = 'Ready to get back to work?';
    } else {
      title = 'Long Break Complete';
      body = 'Time to start a new focus cycle!';
    }

    await _notificationsPlugin.show(0, title, body, platformDetails);
  }

  // Trigger haptic feedback on timer completion
  void _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 300, 100, 300]);
    }
  }

  // Update timer elapsed time
  void _updateTimer() {
    if (!_isRunning) return;

    final now = DateTime.now();
    _elapsedTime = now.difference(_startTime!);
    notifyListeners();

    // Schedule next update
    Future.delayed(const Duration(milliseconds: 1000), _updateTimer);
  }

  // Pause timer
  void pauseTimer() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer?.cancel();

    // Cancel background task
    Workmanager().cancelByUniqueName(_backgroundTaskKey);

    notifyListeners();
  }

  // Resume timer
  void resumeTimer() {
    if (_isRunning || _activeSession == null) return;

    // Adjust start time to maintain the elapsed time
    _startTime = DateTime.now().subtract(_elapsedTime);
    _isRunning = true;

    // Restart the Pomodoro timer if needed
    if (_timer == null) {
      _startPomodoroTimer();
    }

    // Re-register background task
    _saveTimerState();

    notifyListeners();

    // Restart timer update loop
    _updateTimer();
  }

  // Skip current timer interval (move to next phase)
  void skipInterval(TimerSettings settings) {
    _timer?.cancel();
    _handleTimerCompletion();
    configureTimer(settings);
  }

  // Reset timer (cancel current session)
  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _activeSession = null;
    _elapsedTime = Duration.zero;
    _startTime = null;
    _progress = 0.0;
    _remainingSeconds = _targetDuration;

    // Cancel background task
    Workmanager().cancelByUniqueName(_backgroundTaskKey);
    _clearTimerState();

    notifyListeners();
  }

  // Stop timer and save session
  Future<Session> stopTimer({
    String? updatedNotes,
    bool autoStart = false,
  }) async {
    if (_activeSession == null) {
      throw Exception('No active session to stop');
    }

    _isRunning = false;
    _timer?.cancel();

    // Cancel background task
    Workmanager().cancelByUniqueName(_backgroundTaskKey);
    _clearTimerState();

    // Create completed session
    final completedSession = _activeSession!.end(notes: updatedNotes ?? _notes);

    // Save to storage
    await _sessionBox.put(completedSession.id, completedSession);

    // Add to sessions list
    _sessions.add(completedSession);

    // Reset state
    final savedSession = completedSession;
    _activeSession = null;
    _elapsedTime = Duration.zero;
    _startTime = null;

    if (!autoStart) {
      _currentMode = TimerMode.focus;
      _progress = 0.0;
      _remainingSeconds = _targetDuration;
    }

    notifyListeners();
    return savedSession;
  }

  // Format elapsed time as HH:MM:SS
  String get formattedElapsedTime {
    final hours = _elapsedTime.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsedTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsedTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // Format remaining time as MM:SS
  String get formattedRemainingTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Update notes for active session
  void updateNotes(String notes) {
    _notes = notes;
    _saveTimerState();
    notifyListeners();
  }

  // Set project for active session
  void setProject(String projectId) {
    _projectId = projectId;
    _saveTimerState();
    notifyListeners();
  }

  // Get sessions for a specific project
  List<Session> getSessionsForProject(String projectId) {
    return _sessions.where((s) => s.projectId == projectId).toList();
  }

  // Get total study time for a project
  Duration getTotalTimeForProject(String projectId) {
    return getSessionsForProject(
      projectId,
    ).fold(Duration.zero, (total, session) => total + session.duration);
  }

  // Get sessions for a specific date
  List<Session> getSessionsForDate(DateTime date) {
    return _sessions.where((s) {
      final sessionDate = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return sessionDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Get total study time for a date
  Duration getTotalTimeForDate(DateTime date) {
    return getSessionsForDate(
      date,
    ).fold(Duration.zero, (total, session) => total + session.duration);
  }

  // Get sessions for a date range
  List<Session> getSessionsForDateRange(DateTime start, DateTime end) {
    return _sessions.where((s) {
      final sessionDate = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      return sessionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          sessionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Delete a session
  Future<void> deleteSession(String sessionId) async {
    await _sessionBox.delete(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
