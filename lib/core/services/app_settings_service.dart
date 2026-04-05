import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.enableHaptics,
    required this.enableSound,
    required this.keepScreenAwake,
    required this.onboardingCompleted,
    required this.defaultFocusMinutes,
  });

  final bool enableHaptics;
  final bool enableSound;
  final bool keepScreenAwake;
  final bool onboardingCompleted;
  final int defaultFocusMinutes;

  AppSettingsSnapshot copyWith({
    bool? enableHaptics,
    bool? enableSound,
    bool? keepScreenAwake,
    bool? onboardingCompleted,
    int? defaultFocusMinutes,
  }) {
    return AppSettingsSnapshot(
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableSound: enableSound ?? this.enableSound,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      defaultFocusMinutes: defaultFocusMinutes ?? this.defaultFocusMinutes,
    );
  }
}

class AppSettingsService {
  AppSettingsService({required SharedPreferences preferences})
    : _preferences = preferences {
    _snapshot = _loadSnapshotFromPrefs();
  }

  static const String _enableHapticsKey = 'settings_enable_haptics';
  static const String _enableSoundKey = 'settings_enable_sound';
  static const String _keepScreenAwakeKey = 'settings_keep_screen_awake';
  static const String _onboardingCompletedKey = 'settings_onboarding_done';
  static const String _defaultFocusMinutesKey =
      'settings_default_focus_minutes';

  final SharedPreferences _preferences;
  late AppSettingsSnapshot _snapshot;

  bool get enableHaptics => _snapshot.enableHaptics;
  bool get enableSound => _snapshot.enableSound;
  bool get keepScreenAwake => _snapshot.keepScreenAwake;
  bool get onboardingCompleted => _snapshot.onboardingCompleted;
  int get defaultFocusMinutes => _snapshot.defaultFocusMinutes;

  Future<AppSettingsSnapshot> init() async {
    _snapshot = _loadSnapshotFromPrefs();

    return _snapshot;
  }

  Future<AppSettingsSnapshot> snapshot() async {
    return _snapshot;
  }

  Future<void> setEnableHaptics(bool value) async {
    await _update(
      next: _snapshot.copyWith(enableHaptics: value),
      persist:
          (SharedPreferences prefs) => prefs.setBool(_enableHapticsKey, value),
    );
  }

  Future<void> setEnableSound(bool value) async {
    await _update(
      next: _snapshot.copyWith(enableSound: value),
      persist:
          (SharedPreferences prefs) => prefs.setBool(_enableSoundKey, value),
    );
  }

  Future<void> setKeepScreenAwake(bool value) async {
    await _update(
      next: _snapshot.copyWith(keepScreenAwake: value),
      persist:
          (SharedPreferences prefs) =>
              prefs.setBool(_keepScreenAwakeKey, value),
    );
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _update(
      next: _snapshot.copyWith(onboardingCompleted: value),
      persist:
          (SharedPreferences prefs) =>
              prefs.setBool(_onboardingCompletedKey, value),
    );
  }

  Future<void> setDefaultFocusMinutes(int minutes) async {
    final int normalizedMinutes = _normalizeFocusMinutes(minutes);
    await _update(
      next: _snapshot.copyWith(defaultFocusMinutes: normalizedMinutes),
      persist:
          (SharedPreferences prefs) =>
              prefs.setInt(_defaultFocusMinutesKey, normalizedMinutes),
    );
  }

  Future<void> resetAll() async {
    await _preferences.clear();
    _snapshot = _defaultSnapshot;
  }

  Future<void> _update({
    required AppSettingsSnapshot next,
    required Future<bool> Function(SharedPreferences prefs) persist,
  }) async {
    _snapshot = next;
    await persist(_preferences);
  }

  AppSettingsSnapshot _loadSnapshotFromPrefs() {
    return AppSettingsSnapshot(
      enableHaptics: _preferences.getBool(_enableHapticsKey) ?? true,
      enableSound: _preferences.getBool(_enableSoundKey) ?? true,
      keepScreenAwake: _preferences.getBool(_keepScreenAwakeKey) ?? true,
      onboardingCompleted:
          _preferences.getBool(_onboardingCompletedKey) ?? false,
      defaultFocusMinutes: _normalizeFocusMinutes(
        _preferences.getInt(_defaultFocusMinutesKey) ?? 60,
      ),
    );
  }

  static const AppSettingsSnapshot _defaultSnapshot = AppSettingsSnapshot(
    enableHaptics: true,
    enableSound: true,
    keepScreenAwake: true,
    onboardingCompleted: false,
    defaultFocusMinutes: 60,
  );

  int _normalizeFocusMinutes(int minutes) {
    const List<int> allowed = <int>[25, 60, 90];
    if (allowed.contains(minutes)) {
      return minutes;
    }
    return 60;
  }
}
