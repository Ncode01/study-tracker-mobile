import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/providers/persistent_auth_provider.dart';

void main() {
  group('Enhanced Authentication Persistence Tests', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      // Initialize mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Create container with overrides
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() {
      container.dispose();
    });
    test('should persist user session after signup', () async {
      // Get the auth notifier
      final authNotifier = container.read(persistentAuthProvider.notifier);

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Sign up a new user
      await authNotifier.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test Explorer',
      );

      // Wait for state update to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify user is authenticated
      final authState = container.read(persistentAuthProvider);
      expect(
        authState.maybeWhen(
          authenticated: (user) => user.email,
          orElse: () => null,
        ),
        equals('test@example.com'),
      );

      // Verify session is persisted in SharedPreferences
      final userJson = prefs.getString('atlas_current_user');
      expect(userJson, isNotNull);

      final isLoggedIn = prefs.getBool('atlas_is_logged_in');
      expect(isLoggedIn, isTrue);
    });
    test('should restore session on app restart', () async {
      // Create user data and persist manually (simulating previous session)
      await prefs.setString(
        'atlas_current_user',
        '{"uid":"test-uid","email":"restored@example.com","displayName":"Restored Explorer","level":1,"xp":0,"createdAt":"2024-01-01T00:00:00.000Z","lastActiveAt":"2024-01-01T00:00:00.000Z"}',
      );
      await prefs.setBool('atlas_is_logged_in', true);

      // Create new container (simulating app restart)
      final newContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      // Wait for initialization and state changes (increased delay)
      await Future.delayed(const Duration(milliseconds: 800));

      // Verify session is restored
      final authState = newContainer.read(persistentAuthProvider);
      expect(
        authState.maybeWhen(
          authenticated: (user) => user.email,
          orElse: () => null,
        ),
        equals('restored@example.com'),
      );

      newContainer.dispose();
    });
    test('should clear session on sign out', () async {
      // Sign up and sign out
      final authNotifier = container.read(persistentAuthProvider.notifier);

      await authNotifier.signUpWithEmail(
        email: 'signout@example.com',
        password: 'password123',
        displayName: 'Sign Out Test',
      );

      // Wait for signup state update (increased delay)
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify user is authenticated
      var authState = container.read(persistentAuthProvider);
      expect(
        authState.maybeWhen(authenticated: (_) => true, orElse: () => false),
        isTrue,
      );

      // Sign out
      await authNotifier.signOut();

      // Wait for sign out state update (increased delay)
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify user is unauthenticated
      authState = container.read(persistentAuthProvider);
      expect(
        authState.maybeWhen(unauthenticated: () => true, orElse: () => false),
        isTrue,
      );

      // Verify session is cleared from SharedPreferences
      final isLoggedIn = prefs.getBool('atlas_is_logged_in');
      expect(isLoggedIn, isFalse);
    });
    test('should prevent duplicate emails during signup', () async {
      final authNotifier = container.read(persistentAuthProvider.notifier);

      // Sign up first user
      await authNotifier.signUpWithEmail(
        email: 'duplicate@example.com',
        password: 'password123',
        displayName: 'First User',
      );

      // Wait for first signup to complete (increased delay)
      await Future.delayed(const Duration(milliseconds: 200));

      // Clear any error state before attempting duplicate signup
      authNotifier.clearError();

      // Attempt to sign up with same email
      await authNotifier.signUpWithEmail(
        email: 'duplicate@example.com',
        password: 'password456',
        displayName: 'Second User',
      );

      // Wait for error state update (increased delay)
      await Future.delayed(const Duration(milliseconds: 200));

      // Should be in error state
      final authState = container.read(persistentAuthProvider);
      expect(
        authState.maybeWhen(
          error: (message, _) => message.contains('already exists'),
          orElse: () => false,
        ),
        isTrue,
      );
    });
    test('should validate credentials during signin', () async {
      final authNotifier = container.read(persistentAuthProvider.notifier);

      // Sign up a user
      await authNotifier.signUpWithEmail(
        email: 'signin@example.com',
        password: 'correctpassword',
        displayName: 'Sign In Test',
      );

      // Wait for signup to complete (increased delay)
      await Future.delayed(const Duration(milliseconds: 200));

      // Sign out to test sign in
      await authNotifier.signOut();
      await Future.delayed(const Duration(milliseconds: 200));

      // Clear any error state
      authNotifier.clearError();

      // Attempt sign in with wrong password
      await authNotifier.signInWithEmail(
        email: 'signin@example.com',
        password: 'wrongpassword',
      );

      // Wait for error state update (increased delay)
      await Future.delayed(const Duration(milliseconds: 200));

      // Should be in error state
      var authState = container.read(persistentAuthProvider);
      expect(
        authState.maybeWhen(
          error: (message, _) => message.contains('Incorrect password'),
          orElse: () => false,
        ),
        isTrue,
      );

      // Clear error and try with correct password
      authNotifier.clearError();
      await authNotifier.signInWithEmail(
        email: 'signin@example.com',
        password: 'correctpassword',
      );

      // Wait for successful signin state update (increased delay)
      await Future.delayed(const Duration(milliseconds: 200));

      // Should be authenticated
      authState = container.read(persistentAuthProvider);
      expect(
        authState.maybeWhen(
          authenticated: (user) => user.email,
          orElse: () => null,
        ),
        equals('signin@example.com'),
      );
    });
  });
}
