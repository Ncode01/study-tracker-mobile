import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsString = prefs.getString(_settingsKey);
    if (settingsString != null) {
      try {
        return AppSettings.fromJson(
          jsonDecode(settingsString) as Map<String, dynamic>,
        );
      } catch (e) {
        // If decoding fails, return default settings
        print('Error loading settings: $e');
        return AppSettings();
      }
    }
    return AppSettings(); // Return default if no settings found
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsString = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsString);
  }
}
