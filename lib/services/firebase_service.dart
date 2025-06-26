import 'package:firebase_core/firebase_core.dart';
import '../utils/app_logger.dart';

/// Service class for Firebase initialization and configuration
class FirebaseService {
  /// Initialize Firebase for the application
  ///
  /// This should be called before runApp() in main.dart
  /// Returns true if initialization was successful
  static Future<bool> initializeFirebase() async {
    try {
      await Firebase.initializeApp();

      AppLogger.firebase('Firebase initialized successfully');
      return true;
    } catch (e) {
      AppLogger.error('Firebase initialization failed', e);
      AppLogger.warning('App will continue without Firebase features');
      return false;
    }
  }

  /// Check if Firebase is available and initialized
  static bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
