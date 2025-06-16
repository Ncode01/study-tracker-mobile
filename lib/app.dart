import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';

/// Main Project Atlas application widget
/// Handles app configuration, theming, and routing
///
/// This is the root widget that defines the overall app structure,
/// theme configuration, and global app-wide behaviors like text scaling.
class ProjectAtlasApp extends StatelessWidget {
  const ProjectAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Atlas',
      debugShowCheckedModeBanner: false,

      // Use our custom traveler's diary theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Start with light theme
      // Set the AuthWrapper as home - it will handle routing based on auth state
      home: const AuthWrapper(),

      // Custom app-wide error handling and text scaling
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
