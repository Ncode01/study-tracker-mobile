import 'package:firebase_core/firebase_core.dart';

/// Service class for Firebase initialization and configuration
class FirebaseService {
  /// Initialize Firebase for the application
  ///
  /// This should be called before runApp() in main.dart
  /// Returns true if initialization was successful
  static Future<bool> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      return true;
    } catch (e) {
      // Log error in production, you might want to use a logging service
      print('Firebase initialization failed: $e');
      return false;
    }
  }
}
