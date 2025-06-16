/// Authentication state for Project Atlas
/// Represents the different states of the user's authentication journey
enum AuthState {
  /// Initial state when the app starts - checking authentication status
  initial,

  /// Loading state during authentication operations (login, signup, logout)
  loading,

  /// User is successfully authenticated and logged in
  authenticated,

  /// User is not authenticated (logged out or never logged in)
  unauthenticated,

  /// An error occurred during authentication
  error,
}

/// Extension to provide helpful methods for AuthState
extension AuthStateExtension on AuthState {
  /// Check if the current state is loading
  bool get isLoading => this == AuthState.loading;

  /// Check if the user is authenticated
  bool get isAuthenticated => this == AuthState.authenticated;

  /// Check if the user is unauthenticated
  bool get isUnauthenticated => this == AuthState.unauthenticated;

  /// Check if there's an error
  bool get hasError => this == AuthState.error;

  /// Check if the state is initial
  bool get isInitial => this == AuthState.initial;

  /// Get a human-readable description of the state
  String get description {
    switch (this) {
      case AuthState.initial:
        return 'Checking authentication status...';
      case AuthState.loading:
        return 'Processing authentication...';
      case AuthState.authenticated:
        return 'Welcome back, Explorer!';
      case AuthState.unauthenticated:
        return 'Ready to begin your journey';
      case AuthState.error:
        return 'Authentication error occurred';
    }
  }
}
