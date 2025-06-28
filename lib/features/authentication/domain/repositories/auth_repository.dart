import '../../../../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();

  Future<void> deleteAccount();

  Stream<UserModel?> get authStateChanges;
}
