import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'widgets/common/firebase_error_widget.dart';
import 'firebase_options.dart';
import 'utils/app_logger.dart';

/// Main entry point for Project Atlas
/// Initializes Firebase and sets up the app with Riverpod state management
void main() async {
  // Ensure widgets binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize our custom logger first
  AppLogger.initialize();

  try {
    // Initialize Firebase with secure configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppLogger.firebase('Firebase initialized successfully');

    // Run the main app with Riverpod
    runApp(const ProviderScope(child: ProjectAtlasApp()));  } catch (e) {
    AppLogger.fatal(
      'Firebase initialization failed',
      e,
    ); // Show Firebase error app
    runApp(FirebaseErrorApp(error: e));
  }
}
