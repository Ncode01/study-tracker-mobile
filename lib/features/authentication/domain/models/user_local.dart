/// Result wrapper for authentication operations
sealed class AuthResult<T> {
  const AuthResult();
}

class AuthSuccess<T> extends AuthResult<T> {
  final T data;
  const AuthSuccess(this.data);
}

class AuthFailure<T> extends AuthResult<T> {
  final String error;
  const AuthFailure(this.error);
}

extension AuthResultExtension<T> on AuthResult<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    return switch (this) {
      AuthSuccess<T> s => success(s.data),
      AuthFailure<T> f => failure(f.error),
    };
  }
}
