import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/app_database.dart';
import '../services/app_settings_service.dart';
import '../services/notification_service.dart';
import '../services/sensory_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

final databaseHelperProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  final SharedPreferences preferences = ref.watch(sharedPreferencesProvider);
  return AppSettingsService(preferences: preferences);
});

final sensoryServiceProvider = Provider<SensoryService>((ref) {
  return SensoryService(
    appSettingsService: ref.watch(appSettingsServiceProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
