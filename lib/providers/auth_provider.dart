import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_logger.dart';

/// Authentication notifier that manages the authentication state using freezed union types
class AuthNotifier extends StateNotifier<AuthData> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthData.initial()) {
    _initialize();
  }

  /// Initialize authentication state by checking current user
  Future<void> _initialize() async {
    try {
      AppLogger.info('Initializing authentication state');
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // User is signed in, get their profile
        final userProfile = await _authService.getUserProfile(currentUser.uid);
        state = AuthData.authenticated(userProfile);
        AppLogger.info('User authenticated: ${userProfile.displayName}');
      } else {
        // No user signed in
        state = const AuthData.unauthenticated();
        AppLogger.info('No user authenticated');
      }
    } catch (e) {
      AppLogger.error('Failed to initialize authentication', e);
      state = AuthData.error(
        'Failed to initialize authentication: ${e.toString()}',
      );
    }
  }

  /// Sign up a new explorer with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Prevent multiple simultaneous requests
    if (state.maybeWhen(loading: () => true, orElse: () => false)) return;

    state = const AuthData.loading();

    try {
      AppLogger.info('Signing up new user: $email');
      final userModel = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = AuthData.authenticated(userModel);
      AppLogger.info('User signed up successfully: ${userModel.displayName}');
    } catch (e) {
      AppLogger.error('Sign up failed', e);
      state = AuthData.error(e.toString());
    }
  }

  /// Sign in an existing explorer with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Prevent multiple simultaneous requests
    if (state.maybeWhen(loading: () => true, orElse: () => false)) return;

    state = const AuthData.loading();

    try {
      AppLogger.info('Signing in user: $email');
      final userModel = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      state = AuthData.authenticated(userModel);
      AppLogger.info('User signed in successfully: ${userModel.displayName}');
    } catch (e) {
      AppLogger.error('Sign in failed', e);
      state = AuthData.error(e.toString());
    }
  }

  /// Sign out the current explorer
  Future<void> signOut() async {
    // Prevent multiple simultaneous requests
    if (state.maybeWhen(loading: () => true, orElse: () => false)) return;

    state = const AuthData.loading();

    try {
      AppLogger.info('Signing out user');
      await _authService.signOut();
      state = const AuthData.unauthenticated();
      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      state = AuthData.error(e.toString());
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    // Prevent multiple simultaneous requests
    if (state.maybeWhen(loading: () => true, orElse: () => false)) return;

    state = const AuthData.loading();

    try {
      AppLogger.info('Sending password reset email to: $email');
      await _authService.resetPassword(email);

      // Return to previous state after successful reset email
      state.whenOrNull(
            authenticated: (user) => state = AuthData.authenticated(user),
          ) ??
          (state = const AuthData.unauthenticated());

      AppLogger.info('Password reset email sent successfully');
    } catch (e) {
      AppLogger.error('Password reset failed', e);
      state = AuthData.error(e.toString());
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      AppLogger.info('Updating user profile: ${updatedUser.displayName}');
      await _authService.updateUserProfile(updatedUser);
      state = AuthData.authenticated(updatedUser);
      AppLogger.info('User profile updated successfully');
    } catch (e) {
      AppLogger.error('Profile update failed', e);
      state = AuthData.error('Failed to update profile: ${e.toString()}');
    }
  }

  /// Clear error state
  void clearError() {
    state.whenOrNull(
      error: (message, exception) {
        // Return to unauthenticated state when clearing error
        state = const AuthData.unauthenticated();
        AppLogger.info('Error state cleared');
      },
    );
  }

  /// Get current user (convenience getter)
  UserModel? get currentUser => state.whenOrNull(authenticated: (user) => user);

  /// Check if user is authenticated (convenience getter)
  bool get isAuthenticated =>
      state.whenOrNull(authenticated: (_) => true) ?? false;
}

/// AuthService provider - creates a singleton instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Main authentication provider - manages authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthData>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

/// Stream provider that listens to Firebase auth state changes
/// This ensures our app stays in sync with Firebase authentication
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider that combines auth state changes with our app's auth state
/// This helps detect external auth changes (like sign out from another device)
final authSyncProvider = Provider<void>((ref) {
  final authStateChanges = ref.watch(authStateChangesProvider);
  final authNotifier = ref.read(authProvider.notifier);

  authStateChanges.whenData((firebaseUser) {
    final currentAppUser = ref
        .read(authProvider)
        .whenOrNull(authenticated: (user) => user);

    // If Firebase user is null but app thinks user is authenticated, sign out
    if (firebaseUser == null && currentAppUser != null) {
      authNotifier.signOut();
    } // If Firebase user exists but app thinks user is not authenticated, initialize
    else if (firebaseUser != null && currentAppUser == null) {
      // This will be handled by the AuthNotifier initialization
    }
  });
});

/// Convenience providers for specific auth state checks
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).whenOrNull(authenticated: (_) => true) ??
      false;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).whenOrNull(loading: () => true) ?? false;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).whenOrNull(authenticated: (user) => user);
});

final authErrorProvider = Provider<String?>((ref) {
  return ref
      .watch(authProvider)
      .whenOrNull(error: (message, exception) => message);
});
