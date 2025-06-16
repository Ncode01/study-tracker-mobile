import 'package:firebase_auth/firebase_auth.dart';

/// Centralized Firebase error translation utility
///
/// This class provides a single source of truth for converting Firebase
/// error codes into user-friendly, themed messages that match the
/// Project Atlas traveler's diary aesthetic.
class FirebaseErrorTranslator {
  /// Convert Firebase Auth exceptions to user-friendly messages
  ///
  /// Takes a [FirebaseAuthException] and returns a themed error message
  /// that aligns with our explorer/traveler narrative.
  static String translateAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No explorer found with this email. Ready to start a new journey?';

      case 'wrong-password':
        return 'Incorrect password. Check your credentials and try again.';

      case 'email-already-in-use':
        return 'An explorer with this email already exists. Try signing in instead.';

      case 'weak-password':
        return 'Password is too weak. Choose a stronger password for your journey.';

      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';

      case 'user-disabled':
        return 'This explorer account has been disabled. Contact support.';

      case 'too-many-requests':
        return 'Too many attempts. Take a break and try again later.';

      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';

      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';

      case 'requires-recent-login':
        return 'This action requires recent authentication. Please sign in again.';

      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';

      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again.';

      case 'invalid-verification-id':
        return 'Invalid verification ID. Please restart the verification process.';

      case 'missing-verification-code':
        return 'Please enter the verification code.';

      case 'missing-verification-id':
        return 'Verification ID is missing. Please restart the process.';

      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';

      case 'captcha-check-failed':
        return 'CAPTCHA verification failed. Please try again.';

      case 'app-not-authorized':
        return 'App not authorized to use Firebase Authentication.';

      case 'expired-action-code':
        return 'This verification link has expired. Please request a new one.';

      case 'invalid-action-code':
        return 'Invalid verification link. Please check and try again.';

      case 'missing-email':
        return 'Email address is required.';

      case 'missing-password':
        return 'Password is required.';

      default:
        // For unknown errors, provide the original message if available
        return exception.message ??
            'An unexpected error occurred. Please try again.';
    }
  }

  /// Convert any generic error to a user-friendly message
  ///
  /// For errors that aren't specifically Firebase Auth exceptions,
  /// this provides a fallback translation.
  static String translateGenericError(Object error) {
    if (error is FirebaseAuthException) {
      return translateAuthError(error);
    }

    // For other types of errors, extract a clean message
    final errorString = error.toString();

    // Remove common technical prefixes
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }

    if (errorString.startsWith('firebase_auth/')) {
      return 'Authentication error: ${errorString.substring(14)}';
    }

    return errorString;
  }
}
