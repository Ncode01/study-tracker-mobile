import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication data class that holds both state and user information
class AuthData {
  final AuthState state;
  final UserModel? user;
  final String? errorMessage;

  const AuthData({
    required this.state,
    this.user,
    this.errorMessage,
  });

  /// Create AuthData with initial state
  const AuthData.initial()
      : state = AuthState.initial,
        user = null,
        errorMessage = null;

  /// Create AuthData with loading state
  const AuthData.loading()
      : state = AuthState.loading,
        user = null,
        errorMessage = null;

  /// Create AuthData with authenticated state
  const AuthData.authenticated(UserModel user)
      : state = AuthState.authenticated,
        user = user,
        errorMessage = null;

  /// Create AuthData with unauthenticated state
  const AuthData.unauthenticated()
      : state = AuthState.unauthenticated,
        user = null,
        errorMessage = null;

  /// Create AuthData with error state
  const AuthData.error(String message)
      : state = AuthState.error,
        user = null,
        errorMessage = message;

  /// Create a copy with updated values
  AuthData copyWith({
    AuthState? state,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthData(
      state: state ?? this.state,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthData(state: $state, user: ${user?.displayName}, error: $errorMessage)';
  }
}

/// Authentication notifier that manages the authentication state
class AuthNotifier extends StateNotifier<AuthData> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthData.initial()) {
    _initialize();
  }

  /// Initialize authentication state by checking current user
  Future<void> _initialize() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // User is signed in, get their profile
        final userProfile = await _authService.getUserProfile(currentUser.uid);
        state = AuthData.authenticated(userProfile);
      } else {
        // No user signed in
        state = const AuthData.unauthenticated();
      }
    } catch (e) {
      state = AuthData.error(
          'Failed to initialize authentication: ${e.toString()}');
    }
  }

  /// Sign up a new explorer with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (state.state.isLoading) return; // Prevent multiple simultaneous requests

    state = const AuthData.loading();

    try {
      final userModel = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = AuthData.authenticated(userModel);
    } catch (e) {
      state = AuthData.error(e.toString());
    }
  }

  /// Sign in an existing explorer with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (state.state.isLoading) return; // Prevent multiple simultaneous requests

    state = const AuthData.loading();

    try {
      final userModel = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      state = AuthData.authenticated(userModel);
    } catch (e) {
      state = AuthData.error(e.toString());
    }
  }

  /// Sign out the current explorer
  Future<void> signOut() async {
    if (state.state.isLoading) return; // Prevent multiple simultaneous requests

    state = const AuthData.loading();

    try {
      await _authService.signOut();
      state = const AuthData.unauthenticated();
    } catch (e) {
      state = AuthData.error(e.toString());
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    if (state.state.isLoading) return; // Prevent multiple simultaneous requests

    state = const AuthData.loading();

    try {
      await _authService.resetPassword(email);
      // Return to previous state after successful reset email
      if (state.user != null) {
        state = AuthData.authenticated(state.user!);
      } else {
        state = const AuthData.unauthenticated();
      }
    } catch (e) {
      state = AuthData.error(e.toString());
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      await _authService.updateUserProfile(updatedUser);
      state = AuthData.authenticated(updatedUser);
    } catch (e) {
      state = AuthData.error('Failed to update profile: ${e.toString()}');
    }
  }

  /// Clear error state
  void clearError() {
    if (state.state.hasError) {
      if (state.user != null) {
        state = AuthData.authenticated(state.user!);
      } else {
        state = const AuthData.unauthenticated();
      }
    }
  }

  /// Get current user (convenience getter)
  UserModel? get currentUser => state.user;

  /// Check if user is authenticated (convenience getter)
  bool get isAuthenticated => state.state.isAuthenticated;
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
    final currentAppUser = ref.read(authProvider).user;

    // If Firebase user is null but app thinks user is authenticated, sign out
    if (firebaseUser == null && currentAppUser != null) {
      authNotifier.signOut();
    }
    // If Firebase user exists but app thinks user is not authenticated, initialize
    else if (firebaseUser != null && currentAppUser == null) {
      // This will be handled by the AuthNotifier initialization
    }
  });

  return null;
});

/// Convenience providers for specific auth state checks
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).state.isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).state.isLoading;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});
