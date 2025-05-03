import 'package:hive/hive.dart';

/// Model representing user settings and preferences.
@HiveType(typeId: 5)
class Settings {
  /// Theme preference (true = dark mode, false = light mode)
  @HiveField(0)
  final bool darkMode;

  /// Whether notifications are enabled
  @HiveField(1)
  final bool notificationsEnabled;

  /// Specific notification types enabled
  @HiveField(2)
  final List<String> notificationTypes;

  /// Timer-specific settings
  @HiveField(3)
  final TimerSettings timerSettings;

  const Settings({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.notificationTypes = const [
      'goal_due',
      'goal_complete',
      'project_deadline',
      'daily_reminder',
    ],
    this.timerSettings = const TimerSettings(),
  });

  /// Default settings
  factory Settings.defaultSettings() {
    return const Settings();
  }

  /// Create a copy of this settings object with updated fields
  Settings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    List<String>? notificationTypes,
    TimerSettings? timerSettings,
  }) {
    return Settings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      timerSettings: timerSettings ?? this.timerSettings,
    );
  }

  /// Toggle the theme mode
  Settings toggleTheme() {
    return copyWith(darkMode: !darkMode);
  }

  /// Toggle notifications
  Settings toggleNotifications() {
    return copyWith(notificationsEnabled: !notificationsEnabled);
  }

  /// Add a notification type
  Settings addNotificationType(String type) {
    if (notificationTypes.contains(type)) return this;
    return copyWith(notificationTypes: [...notificationTypes, type]);
  }

  /// Remove a notification type
  Settings removeNotificationType(String type) {
    if (!notificationTypes.contains(type)) return this;
    final updatedTypes = List<String>.from(notificationTypes)..remove(type);
    return copyWith(notificationTypes: updatedTypes);
  }
}

/// Timer-specific settings
@HiveType(typeId: 6)
class TimerSettings {
  /// Whether to use Pomodoro technique
  @HiveField(0)
  final bool usePomodoroTimer;

  /// Length of work session in minutes (default 25 minutes)
  @HiveField(1)
  final int workDuration;

  /// Length of short break in minutes (default 5 minutes)
  @HiveField(2)
  final int shortBreakDuration;

  /// Length of long break in minutes (default 15 minutes)
  @HiveField(3)
  final int longBreakDuration;

  /// Number of work sessions before long break (default 4)
  @HiveField(4)
  final int sessionsBeforeLongBreak;

  /// Whether to keep timer running in background
  @HiveField(5)
  final bool runInBackground;

  /// Whether to play sound when timer completes
  @HiveField(6)
  final bool playSoundOnComplete;

  /// Whether to keep screen on during active timer
  @HiveField(7)
  final bool keepScreenOn;

  const TimerSettings({
    this.usePomodoroTimer = false,
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.runInBackground = true,
    this.playSoundOnComplete = true,
    this.keepScreenOn = false,
  });

  /// Create a copy of this timer settings object with updated fields
  TimerSettings copyWith({
    bool? usePomodoroTimer,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsBeforeLongBreak,
    bool? runInBackground,
    bool? playSoundOnComplete,
    bool? keepScreenOn,
  }) {
    return TimerSettings(
      usePomodoroTimer: usePomodoroTimer ?? this.usePomodoroTimer,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      runInBackground: runInBackground ?? this.runInBackground,
      playSoundOnComplete: playSoundOnComplete ?? this.playSoundOnComplete,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }

  /// Toggle Pomodoro timer
  TimerSettings togglePomodoroTimer() {
    return copyWith(usePomodoroTimer: !usePomodoroTimer);
  }

  /// Toggle background timer
  TimerSettings toggleBackgroundTimer() {
    return copyWith(runInBackground: !runInBackground);
  }

  /// Toggle sound on timer completion
  TimerSettings toggleSoundOnComplete() {
    return copyWith(playSoundOnComplete: !playSoundOnComplete);
  }

  /// Toggle screen wake lock
  TimerSettings toggleKeepScreenOn() {
    return copyWith(keepScreenOn: !keepScreenOn);
  }
}
