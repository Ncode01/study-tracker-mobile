import 'package:flutter/foundation.dart';
import 'package:bytelearn_study_tracker/models/settings.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  final Box<Settings> _settingsBox;
  late Settings _settings;
  static const String _settingsKey = 'app_settings';

  // Theme color preference
  Color _themeColor = Colors.blue;

  // Time-related preferences
  DateTime _reminderTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    20,
    0,
  ); // 8:00 PM default
  Duration _defaultTimerDuration = const Duration(minutes: 25);
  Duration _defaultBreakDuration = const Duration(minutes: 5);

  // Notification preferences
  bool _dailyReminderEnabled = false;
  bool _goalNotificationsEnabled = true;

  // Timer preferences
  bool _timerSoundEnabled = true;
  bool _timerVibrationEnabled = true;

  SettingsProvider(this._settingsBox) {
    _loadSettings();
  }

  // Getters
  Settings get settings => _settings;
  bool get darkMode => _settings.darkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  List<String> get notificationTypes => _settings.notificationTypes;
  TimerSettings get timerSettings => _settings.timerSettings;

  // Additional getters for settings screen
  bool get isDarkMode => _settings.darkMode;
  Color get themeColor => _themeColor;
  Duration get defaultTimerDuration => _defaultTimerDuration;
  Duration get defaultBreakDuration => _defaultBreakDuration;
  bool get timerSoundEnabled => _timerSoundEnabled;
  bool get timerVibrationEnabled => _timerVibrationEnabled;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  DateTime get reminderTime => _reminderTime;
  bool get goalNotificationsEnabled => _goalNotificationsEnabled;

  // Load settings from Hive box
  Future<void> _loadSettings() async {
    if (_settingsBox.containsKey(_settingsKey)) {
      _settings = _settingsBox.get(_settingsKey)!;
    } else {
      // Initialize with default settings if not found
      _settings = Settings.defaultSettings();
      await _settingsBox.put(_settingsKey, _settings);
    }
    notifyListeners();
  }

  // Save settings to Hive box
  Future<void> _saveSettings() async {
    await _settingsBox.put(_settingsKey, _settings);
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _settings = _settings.toggleTheme();
    await _saveSettings();
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final bool isDark = themeMode == ThemeMode.dark;
    if (isDark != _settings.darkMode) {
      _settings = _settings.copyWith(darkMode: isDark);
      await _saveSettings();
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    _settings = _settings.toggleNotifications();
    await _saveSettings();
  }

  // Add notification type
  Future<void> addNotificationType(String type) async {
    _settings = _settings.addNotificationType(type);
    await _saveSettings();
  }

  // Remove notification type
  Future<void> removeNotificationType(String type) async {
    _settings = _settings.removeNotificationType(type);
    await _saveSettings();
  }

  // Update timer settings
  Future<void> updateTimerSettings(TimerSettings timerSettings) async {
    _settings = _settings.copyWith(timerSettings: timerSettings);
    await _saveSettings();
  }

  // Toggle Pomodoro timer
  Future<void> togglePomodoroTimer() async {
    final updatedTimerSettings = _settings.timerSettings.togglePomodoroTimer();
    await updateTimerSettings(updatedTimerSettings);
  }

  // Toggle background timer
  Future<void> toggleBackgroundTimer() async {
    final updatedTimerSettings =
        _settings.timerSettings.toggleBackgroundTimer();
    await updateTimerSettings(updatedTimerSettings);
  }

  // Toggle sound on timer completion
  Future<void> toggleSoundOnComplete() async {
    final updatedTimerSettings =
        _settings.timerSettings.toggleSoundOnComplete();
    await updateTimerSettings(updatedTimerSettings);
  }

  // Toggle screen wake lock
  Future<void> toggleKeepScreenOn() async {
    final updatedTimerSettings = _settings.timerSettings.toggleKeepScreenOn();
    await updateTimerSettings(updatedTimerSettings);
  }

  // Update work duration for Pomodoro timer
  Future<void> updateWorkDuration(int minutes) async {
    final updatedTimerSettings = _settings.timerSettings.copyWith(
      workDuration: minutes,
    );
    await updateTimerSettings(updatedTimerSettings);
  }

  // Update short break duration for Pomodoro timer
  Future<void> updateShortBreakDuration(int minutes) async {
    final updatedTimerSettings = _settings.timerSettings.copyWith(
      shortBreakDuration: minutes,
    );
    await updateTimerSettings(updatedTimerSettings);
  }

  // Update long break duration for Pomodoro timer
  Future<void> updateLongBreakDuration(int minutes) async {
    final updatedTimerSettings = _settings.timerSettings.copyWith(
      longBreakDuration: minutes,
    );
    await updateTimerSettings(updatedTimerSettings);
  }

  // Update sessions before long break for Pomodoro timer
  Future<void> updateSessionsBeforeLongBreak(int count) async {
    final updatedTimerSettings = _settings.timerSettings.copyWith(
      sessionsBeforeLongBreak: count,
    );
    await updateTimerSettings(updatedTimerSettings);
  }

  // Additional methods for settings screen
  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    notifyListeners();
  }

  Future<void> setDefaultTimerDuration(Duration duration) async {
    _defaultTimerDuration = duration;
    // Also update the work duration in timer settings
    await updateWorkDuration(duration.inMinutes);
    notifyListeners();
  }

  Future<void> setDefaultBreakDuration(Duration duration) async {
    _defaultBreakDuration = duration;
    // Also update the short break duration in timer settings
    await updateShortBreakDuration(duration.inMinutes);
    notifyListeners();
  }

  Future<void> toggleTimerSound() async {
    _timerSoundEnabled = !_timerSoundEnabled;
    // Also update the sound setting in timer settings
    await toggleSoundOnComplete();
    notifyListeners();
  }

  Future<void> toggleTimerVibration() async {
    _timerVibrationEnabled = !_timerVibrationEnabled;
    notifyListeners();
  }

  Future<void> toggleDailyReminder() async {
    _dailyReminderEnabled = !_dailyReminderEnabled;
    notifyListeners();
  }

  Future<void> setReminderTime(DateTime time) async {
    _reminderTime = time;
    notifyListeners();
  }

  Future<void> toggleGoalNotifications() async {
    _goalNotificationsEnabled = !_goalNotificationsEnabled;
    notifyListeners();
  }
}
