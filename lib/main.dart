import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';
import 'utils/app_logger.dart';

/// Main entry point for Project Atlas
/// Initializes Firebase and sets up the app with Riverpod state management
void main() async {
  // Ensure widgets binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (but continue even if it fails)
  final firebaseInitialized = await FirebaseService.initializeFirebase();

  if (firebaseInitialized) {
    AppLogger.firebase('Firebase initialized successfully');
  } else {
    AppLogger.warning('App running without Firebase features');
  }

  // Run the main app with Riverpod
  runApp(const ProviderScope(child: ProjectAtlasApp()));
}

/// Main Project Atlas application
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

/// Error app shown when Firebase initialization fails
class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Atlas - Error',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const FirebaseErrorScreen(),
    );
  }
}

/// Screen shown when Firebase fails to initialize
class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.red.shade300, width: 3),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 50,
                    color: Colors.red.shade600,
                  ),
                ),

                const SizedBox(height: 32),

                // Error title
                Text(
                  'Initialization Failed',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Error description
                Text(
                  'Project Atlas failed to initialize properly. This usually happens when Firebase configuration is missing or invalid.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Technical details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Technical Details:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check that Firebase is properly configured\n'
                        '• Ensure google-services.json is in android/app/\n'
                        '• Verify GoogleService-Info.plist is in ios/Runner/\n'
                        '• Check internet connection',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Retry button
                ElevatedButton(
                  onPressed: () {
                    // Restart the entire app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'Retry Initialization',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
