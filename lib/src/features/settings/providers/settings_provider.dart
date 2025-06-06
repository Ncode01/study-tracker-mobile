import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService;
  AppSettings _settings = AppSettings();
  bool _isLoading = false;

  SettingsProvider(this._settingsService) {
    _loadSettings();
  }

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  double get dailyStudyTarget => _settings.dailyStudyTarget;

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _settingsService.loadSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _settings = AppSettings(); // Fallback to defaults
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDailyStudyTarget(double hours) async {
    if (hours <= 0) return; // Don't allow negative or zero targets

    final newSettings = _settings.copyWith(dailyStudyTarget: hours);

    try {
      await _settingsService.saveSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving settings: $e');
      rethrow; // Let the UI handle the error
    }
  }

  Future<void> resetToDefaults() async {
    final defaultSettings = AppSettings();

    try {
      await _settingsService.saveSettings(defaultSettings);
      _settings = defaultSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      rethrow;
    }
  }
}
