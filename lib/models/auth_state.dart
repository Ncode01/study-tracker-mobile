import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'auth_state.freezed.dart';

/// Authentication state for Project Atlas using freezed union types
/// Represents the different states of the user's authentication journey
@freezed
class AuthData with _$AuthData {
  /// Initial state when the app starts - checking authentication status
  const factory AuthData.initial() = _Initial;

  /// Loading state during authentication operations (login, signup, logout)
  const factory AuthData.loading() = _Loading;

  /// User is successfully authenticated and logged in
  const factory AuthData.authenticated(UserModel user) = _Authenticated;

  /// User is not authenticated (logged out or never logged in)
  const factory AuthData.unauthenticated() = _Unauthenticated;

  /// An error occurred during authentication
  const factory AuthData.error(String message, [Exception? exception]) = _Error;
}
