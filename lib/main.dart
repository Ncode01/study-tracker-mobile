import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'config/router/app_router.dart';

/// Main entry point for Project Atlas
/// Sets up the app with Riverpod state management (no Firebase)
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ProjectAtlasApp()));
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
