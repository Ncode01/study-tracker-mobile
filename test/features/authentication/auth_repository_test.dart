import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/features/authentication/data/repositories/local_auth_repository_impl.dart';
import 'package:study/models/user_model.dart';
import 'package:study/providers/auth_provider.dart';
import 'dart:convert';

void main() {
  group('AuthRepository Initialization', () {
    final testUser = UserModel.newUser(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
    );

    final userJson = jsonEncode(testUser.toJson());

    test('authRepositoryProvider rehydrates user from SharedPreferences', () async {
      // 1. Setup
      SharedPreferences.setMockInitialValues({
        'atlas_current_user': userJson,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 2. Act
      // The provider will be initialized asynchronously.
      // We need to wait for it to complete.
      final repository = await container.read(authRepositoryProvider.future);

      // 3. Assert
      // Check that the repository is initialized and the user is loaded.
      expect(repository, isA<LocalAuthRepositoryImpl>());
      
      // Listen to the authStateChanges stream to get the current user
      final user = await repository.authStateChanges.first;
      
      expect(user, isNotNull);
      expect(user!.uid, testUser.uid);
      expect(user.email, testUser.email);
    });
  });
}
