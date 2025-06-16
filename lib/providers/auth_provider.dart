import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_logger.dart';

/// Global provider for authentication state
/// 
/// This provider manages the entire authentication flow using the new
/// freezed AuthState union type, eliminating the need for separate AuthData class.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

/// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Authentication state notifier using freezed union types
/// 
/// This notifier now works directly with the AuthState union type,
/// making the code cleaner and more type-safe.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    _init();
  }

  /// Initialize auth state by checking current user
  Future<void> _init() async {
    try {
      AppLogger.auth('Initializing authentication state');
      
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        AppLogger.auth('Found existing user: ${currentUser.email}');
        final userModel = await _authService.getUserProfile(currentUser.uid);
        state = AuthState.authenticated(userModel);
      } else {
        AppLogger.auth('No existing user found');
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      AppLogger.error('Failed to initialize auth state', e);
      state = AuthState.error('Failed to initialize authentication: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    
    try {
      AppLogger.auth('Attempting sign in for: $email');
      final userModel = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      AppLogger.auth('Sign in successful for: ${userModel.displayName}');
      state = AuthState.authenticated(userModel);
    } catch (e) {
      AppLogger.error('Sign in failed for: $email', e);
      state = AuthState.error(e.toString());
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading();
    
    try {
      AppLogger.auth('Attempting sign up for: $email');
      final userModel = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      AppLogger.auth('Sign up successful for: ${userModel.displayName}');
      state = AuthState.authenticated(userModel);
    } catch (e) {
      AppLogger.error('Sign up failed for: $email', e);
      state = AuthState.error(e.toString());
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.auth('Sending password reset for: $email');
      await _authService.resetPassword(email);
      AppLogger.auth('Password reset sent successfully for: $email');
    } catch (e) {
      AppLogger.error('Password reset failed for: $email', e);
      rethrow; // Re-throw to let UI handle the error
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      AppLogger.auth('Signing out user');
      await _authService.signOut();
      state = const AuthState.unauthenticated();
      AppLogger.auth('Sign out successful');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      state = AuthState.error('Failed to sign out: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    state.when(
      initial: () {},
      loading: () {},
      authenticated: (currentUser) async {
        try {
          AppLogger.data('Updating user profile for: ${updatedUser.uid}');
          await _authService.updateUserProfile(updatedUser);
          state = AuthState.authenticated(updatedUser);
          AppLogger.data('User profile updated successfully');
        } catch (e) {
          AppLogger.error('Failed to update user profile', e);
          state = AuthState.error('Failed to update profile: ${e.toString()}');
        }
      },
      unauthenticated: () {
        AppLogger.warning('Attempted to update profile while unauthenticated');
      },
      error: (message) {
        AppLogger.warning('Attempted to update profile while in error state: $message');
      },
    );
  }

  /// Get current user from state (helper method)
  UserModel? get currentUser {
    return state.when(
      initial: () => null,
      loading: () => null,
      authenticated: (user) => user,
      unauthenticated: () => null,
      error: (message) => null,
    );
  }

  /// Check if user is authenticated (helper method)
  bool get isAuthenticated {
    return state.when(
      initial: () => false,
      loading: () => false,
      authenticated: (user) => true,
      unauthenticated: () => false,
      error: (message) => false,
    );
  }

  /// Get error message if in error state (helper method)
  String? get errorMessage {
    return state.when(
      initial: () => null,
      loading: () => null,
      authenticated: (user) => null,
      unauthenticated: () => null,
      error: (message) => message,
    );
  }

  /// Check if currently loading (helper method)
  bool get isLoading {
    return state.when(
      initial: () => false,
      loading: () => true,
      authenticated: (user) => false,
      unauthenticated: () => false,
      error: (message) => false,
    );
  }
}