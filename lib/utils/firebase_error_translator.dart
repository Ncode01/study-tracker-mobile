import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for translating Firebase errors to user-friendly messages
/// Provides consistent error messaging across the app with context-aware translations
class FirebaseErrorTranslator {
  FirebaseErrorTranslator._(); // Private constructor

  /// Translate Firebase Auth exceptions to user-friendly messages
  static String translateAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      // Email/Password errors
      case 'user-not-found':
        return 'No explorer found with this email. Ready to start a new journey?';
      case 'wrong-password':
        return 'Incorrect password. Check your credentials and try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in instead.';
      case 'weak-password':
        return 'Password should be at least 6 characters long with letters and numbers.';
      case 'invalid-email':
        return 'Please enter a valid email address.';

      // Account status errors
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';

      // Security errors
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment before trying again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not currently enabled. Please contact support.';

      // Network errors
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';

      // Session errors
      case 'requires-recent-login':
        return 'For security, please sign in again to complete this action.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different account.';

      // Generic fallback
      default:
        return 'Authentication failed: ${exception.message ?? 'Unknown error'}';
    }
  }

  /// Translate Firestore exceptions to user-friendly messages
  static String translateFirestoreError(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data.';
      case 'not-found':
        return 'The requested data could not be found.';
      case 'already-exists':
        return 'This data already exists and cannot be created again.';
      case 'resource-exhausted':
        return 'Service temporarily overloaded. Please try again later.';
      case 'failed-precondition':
        return 'The operation failed due to a conflict. Please refresh and try again.';
      case 'aborted':
        return 'The operation was aborted due to a conflict. Please try again.';
      case 'out-of-range':
        return 'Invalid data range provided.';
      case 'unimplemented':
        return 'This feature is not yet available.';
      case 'internal':
        return 'An internal error occurred. Please try again later.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later.';
      case 'data-loss':
        return 'Data corruption detected. Please contact support.';
      case 'unauthenticated':
        return 'You must be signed in to perform this action.';
      case 'deadline-exceeded':
        return 'Operation timed out. Please check your connection and try again.';
      case 'cancelled':
        return 'Operation was cancelled.';
      case 'invalid-argument':
        return 'Invalid data provided. Please check your input.';
      default:
        return 'Database error: ${exception.message ?? 'Unknown error'}';
    }
  }

  /// Translate generic exceptions to user-friendly messages
  static String translateGenericError(Object error) {
    if (error is FirebaseAuthException) {
      return translateAuthError(error);
    } else if (error is FirebaseException) {
      return translateFirestoreError(error);
    } else if (error is FormatException) {
      return 'Invalid data format. Please check your input.';
    } else if (error is TypeError) {
      return 'Data type error occurred. Please try again.';
    } else if (error.toString().contains('SocketException')) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Operation timed out. Please check your connection and try again.';
    } else if (error.toString().contains('HandshakeException')) {
      return 'Secure connection failed. Please check your internet connection.';
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }

  /// Get user-friendly error category for logging/analytics
  static String getErrorCategory(Object error) {
    if (error is FirebaseAuthException) {
      return 'auth_error';
    } else if (error is FirebaseException) {
      return 'firestore_error';
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return 'network_error';
    } else {
      return 'app_error';
    }
  }

  /// Check if error is retryable (user can try again)
  static bool isRetryableError(Object error) {
    if (error is FirebaseAuthException) {
      return const [
        'network-request-failed',
        'too-many-requests',
      ].contains(error.code);
    } else if (error is FirebaseException) {
      return const [
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'aborted',
      ].contains(error.code);
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return true;
    }
    return false;
  }

  /// Get suggested action for the user based on error type
  static String getSuggestedAction(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Try creating a new account or check your email spelling.';
        case 'wrong-password':
          return 'Check your password or use "Forgot Password" to reset it.';
        case 'email-already-in-use':
          return 'Sign in with this email or use a different email address.';
        case 'weak-password':
          return 'Create a stronger password with at least 6 characters.';
        case 'too-many-requests':
          return 'Wait a few minutes before trying again.';
        case 'network-request-failed':
          return 'Check your internet connection and try again.';
        default:
          return 'Please try again or contact support if the problem persists.';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Make sure you\'re signed in with the correct account.';
        case 'unavailable':
          return 'Please try again in a few moments.';
        case 'unauthenticated':
          return 'Please sign in again and try the operation.';
        default:
          return 'Please try again or contact support if the problem persists.';
      }
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return 'Check your internet connection and try again.';
    }
    return 'Please try again or contact support if the problem persists.';
  }
}
