import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'auth_state.freezed.dart';

/// Authentication state for Project Atlas using freezed union types
/// 
/// This represents the different states of the user's authentication journey
/// as immutable union types, making state management more predictable and safe.
@freezed
class AuthState with _$AuthState {
  /// Initial state when the app starts - checking authentication status
  const factory AuthState.initial() = Initial;

  /// Loading state during authentication operations (login, signup, logout)
  const factory AuthState.loading() = Loading;

  /// User is successfully authenticated and logged in
  const factory AuthState.authenticated(UserModel user) = Authenticated;

  /// User is not authenticated (logged out or never logged in)
  const factory AuthState.unauthenticated() = Unauthenticated;

  /// An error occurred during authentication
  const factory AuthState.error(String message) = Error;
}

/// Extension methods for convenient access to AuthState properties
extension AuthStateExtension on AuthState {
  /// Check if the current state is loading
  bool get isLoading => when(
        initial: () => false,
        loading: () => true,
        authenticated: (_) => false,
        unauthenticated: () => false,
        error: (_) => false,
      );

  /// Check if the current state is authenticated
  bool get isAuthenticated => when(
        initial: () => false,
        loading: () => false,
        authenticated: (_) => true,
        unauthenticated: () => false,
        error: (_) => false,
      );

  /// Check if the current state has an error
  bool get hasError => when(
        initial: () => false,
        loading: () => false,
        authenticated: (_) => false,
        unauthenticated: () => false,
        error: (_) => true,
      );

  /// Get the user if authenticated, null otherwise
  UserModel? get user => when(
        initial: () => null,
        loading: () => null,
        authenticated: (user) => user,
        unauthenticated: () => null,
        error: (_) => null,
      );

  /// Get the error message if in error state, null otherwise
  String? get errorMessage => when(
        initial: () => null,
        loading: () => null,
        authenticated: (_) => null,
        unauthenticated: () => null,
        error: (message) => message,
      );
}
