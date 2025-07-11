import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'config/router/app_router.dart';
import 'providers/persistent_auth_provider.dart';
import 'features/study/data/hive_data_service.dart';

/// Main entry point for Project Atlas
/// Sets up the app with persistent authentication, Hive storage, and Riverpod state management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database for persistent storage
  await HiveDataService.initialize();

  // Initialize SharedPreferences for legacy storage support
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ProjectAtlasApp(),
    ),
  );
}

/// Main Project Atlas application
class ProjectAtlasApp extends ConsumerWidget {
  const ProjectAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Project Atlas',
      debugShowCheckedModeBanner: false,
      // Use our custom traveler's diary theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Start with light theme
      routerConfig: router,
      // Custom app-wide error handling
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling doesn't break our UI
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
