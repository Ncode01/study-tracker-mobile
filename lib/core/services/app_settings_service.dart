import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.enableHaptics,
    required this.enableSound,
    required this.keepScreenAwake,
    required this.onboardingCompleted,
  });

  final bool enableHaptics;
  final bool enableSound;
  final bool keepScreenAwake;
  final bool onboardingCompleted;

  AppSettingsSnapshot copyWith({
    bool? enableHaptics,
    bool? enableSound,
    bool? keepScreenAwake,
    bool? onboardingCompleted,
  }) {
    return AppSettingsSnapshot(
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableSound: enableSound ?? this.enableSound,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

class AppSettingsService {
  AppSettingsService._();

  static final AppSettingsService instance = AppSettingsService._();

  static const String _enableHapticsKey = 'settings_enable_haptics';
  static const String _enableSoundKey = 'settings_enable_sound';
  static const String _keepScreenAwakeKey = 'settings_keep_screen_awake';
  static const String _onboardingCompletedKey = 'settings_onboarding_done';

  SharedPreferences? _preferences;
  AppSettingsSnapshot _snapshot = const AppSettingsSnapshot(
    enableHaptics: true,
    enableSound: true,
    keepScreenAwake: true,
    onboardingCompleted: false,
  );

  bool get enableHaptics => _snapshot.enableHaptics;
  bool get enableSound => _snapshot.enableSound;
  bool get keepScreenAwake => _snapshot.keepScreenAwake;
  bool get onboardingCompleted => _snapshot.onboardingCompleted;

  Future<AppSettingsSnapshot> init() async {
    final SharedPreferences prefs =
        _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;

    _snapshot = AppSettingsSnapshot(
      enableHaptics: prefs.getBool(_enableHapticsKey) ?? true,
      enableSound: prefs.getBool(_enableSoundKey) ?? true,
      keepScreenAwake: prefs.getBool(_keepScreenAwakeKey) ?? true,
      onboardingCompleted: prefs.getBool(_onboardingCompletedKey) ?? false,
    );

    return _snapshot;
  }

  Future<AppSettingsSnapshot> snapshot() async {
    if (_preferences == null) {
      await init();
    }
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

  Future<void> _update({
    required Future<bool> Function(SharedPreferences prefs) persist,
  }) async {
    final SharedPreferences prefs =
        _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;
    _snapshot = next;
    await persist(prefs);
  }
}
