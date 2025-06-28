import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/auth_state.dart';
import '../../../models/user_model.dart';
import '../features/authentication/data/repositories/enhanced_local_auth_repository.dart';
import '../utils/app_logger.dart';

/// Enhanced authentication notifier with session persistence
class PersistentAuthNotifier extends StateNotifier<AuthData> {
  final EnhancedLocalAuthRepository _authRepository;
  VoidCallback? onSignUpSuccess;

  PersistentAuthNotifier(this._authRepository)
    : super(const AuthData.initial()) {
    _initializeAuth();
  }

  /// Initialize authentication and check for existing session
  Future<void> _initializeAuth() async {
    try {
      AppLogger.info('Initializing authentication with session check');
      state = const AuthData.loading();

      // Initialize the enhanced repository (this will restore session if exists)
      await _authRepository.initialize();

      // Listen to auth state changes
      _authRepository.authStateChanges.listen((user) {
        if (user != null) {
          AppLogger.info('Session restored for user: ${user.email}');
          state = AuthData.authenticated(user);
        } else {
          AppLogger.info('No active session found');
          state = const AuthData.unauthenticated();
        }
      });

      // Trigger initial state emission
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        AppLogger.info('Initial user found: ${currentUser.email}');
        state = AuthData.authenticated(currentUser);
      } else {
        AppLogger.info('No initial user found - setting unauthenticated state');
        state = const AuthData.unauthenticated();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize authentication', e, stackTrace);
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
      final userModel = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = AuthData.authenticated(userModel);
      AppLogger.info('User signed up successfully: ${userModel.displayName}');

      if (onSignUpSuccess != null) {
        onSignUpSuccess!();
      }
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
      final userModel = await _authRepository.signInWithEmail(
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
      await _authRepository.signOut();
      state = const AuthData.unauthenticated();
      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      state = AuthData.error(e.toString());
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

  /// Delete the current user's account permanently
  Future<void> deleteAccount() async {
    // Prevent multiple simultaneous requests
    if (state.maybeWhen(loading: () => true, orElse: () => false)) return;

    state = const AuthData.loading();

    try {
      AppLogger.info('Deleting user account');
      await _authRepository.deleteAccount();
      AppLogger.info('Account deleted successfully');
      // State will automatically become unauthenticated via stream listener
    } catch (e, stackTrace) {
      AppLogger.error('Account deletion failed', e, stackTrace);
      state = AuthData.error('Failed to delete account: ${e.toString()}');
    }
  }
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for Logger
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
});

/// Enhanced authentication repository provider
final enhancedAuthRepositoryProvider = Provider<EnhancedLocalAuthRepository>((
  ref,
) {
  final prefs = ref.read(sharedPreferencesProvider);
  final logger = ref.read(loggerProvider);
  return EnhancedLocalAuthRepository(prefs, logger);
});

/// Main authentication provider with persistence
final persistentAuthProvider =
    StateNotifierProvider<PersistentAuthNotifier, AuthData>((ref) {
      final repository = ref.read(enhancedAuthRepositoryProvider);
      return PersistentAuthNotifier(repository);
    });

/// Convenience providers for specific auth state checks
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref
          .watch(persistentAuthProvider)
          .whenOrNull(authenticated: (_) => true) ??
      false;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(persistentAuthProvider).whenOrNull(loading: () => true) ??
      false;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref
      .watch(persistentAuthProvider)
      .whenOrNull(authenticated: (user) => user);
});

final authErrorProvider = Provider<String?>((ref) {
  return ref
      .watch(persistentAuthProvider)
      .whenOrNull(error: (message, exception) => message);
});

/// Stream provider for real-time auth state changes
final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  final repository = ref.read(enhancedAuthRepositoryProvider);
  return repository.authStateChanges;
});
