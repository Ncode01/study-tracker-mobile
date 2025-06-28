import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../features/authentication/data/repositories/local_auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../utils/app_logger.dart';

/// Authentication notifier that manages the authentication state using freezed union types
class AuthNotifier extends StateNotifier<AuthData> {
  final AuthRepository? _authRepository;
  VoidCallback? onSignUpSuccess;

  AuthNotifier(this._authRepository) : super(const AuthData.initial()) {
    if (_authRepository != null) {
      // Immediately set to unauthenticated on startup
      state = const AuthData.unauthenticated();
      _authRepository.authStateChanges.listen((user) {
        if (user != null) {
          state = AuthData.authenticated(user);
        } else {
          state = const AuthData.unauthenticated();
        }
      });
    } else {
      // Repository not ready yet, stay in initial state
      state = const AuthData.initial();
    }
  }

  /// Sign up a new explorer with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_authRepository == null) {
      state = const AuthData.error('Authentication service not ready');
      return;
    }

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
    if (_authRepository == null) {
      state = const AuthData.error('Authentication service not ready');
      return;
    }

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
    if (_authRepository == null) {
      state = const AuthData.error('Authentication service not ready');
      return;
    }

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
    if (_authRepository == null) {
      state = const AuthData.error('Authentication service not ready');
      return;
    }

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

/// Provide the repository
final authRepositoryProvider = FutureProvider<LocalAuthRepositoryImpl>((
  ref,
) async {
  final repo = LocalAuthRepositoryImpl();
  await repo.ensureInitialized();
  return repo;
});

/// Main authentication provider - manages authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthData>((ref) {
  final repoAsync = ref.watch(authRepositoryProvider);
  return repoAsync.when(
    data: (repo) => AuthNotifier(repo),
    loading: () => AuthNotifier(null), // Temporary null until repo is ready
    error: (error, stack) => AuthNotifier(null), // Handle error gracefully
  );
});

/// Stream provider that listens to auth state changes
final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref
      .watch(authRepositoryProvider)
      .maybeWhen(data: (r) => r, orElse: () => null);
  return repo?.authStateChanges ?? const Stream.empty();
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
