import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/profile/presentation/screens/profile_screen.dart';
import 'package:study/models/auth_state.dart';
import 'package:study/models/user_model.dart';
import 'package:study/providers/auth_provider.dart';

// A mock of AuthNotifier for testing purposes
class MockAuthNotifier extends StateNotifier<AuthData> implements AuthNotifier {
  MockAuthNotifier(super.state);

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    // No-op
  }

  @override
  Future<void> signUpWithEmail(
      {required String email, required String password, required String displayName}) async {
    // No-op
  }

  @override
  Future<void> signOut() async {
    state = const AuthData.unauthenticated();
  }

  @override
  void clearError() {
    // No-op
  }

  @override
  Future<void> deleteAccount() async {
    state = const AuthData.unauthenticated();
  }

  @override
  UserModel? get currentUser => state.whenOrNull(authenticated: (user) => user);

  @override
  bool get isAuthenticated => state.whenOrNull(authenticated: (_) => true) ?? false;

  @override
  VoidCallback? onSignUpSuccess;
}

void main() {
  group('ProfileScreen', () {
    final testUser = UserModel.newUser(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
    );

    testWidgets('renders correctly and does not overflow', (tester) async {
      // Set the screen size to a small device to test for overflows
      tester.view.physicalSize = const Size(320 * 3, 640 * 3); // iPhone SE in logical pixels * device pixel ratio
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => MockAuthNotifier(AuthData.authenticated(testUser)),
            ),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Let the widget rebuild
      await tester.pumpAndSettle();

      // Verify that the profile content is displayed
      expect(find.text('Explorer Profile'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Novice Explorer'), findsOneWidget);

      // Verify that no overflow errors are reported
      final overflowErrors = tester.takeException();
      expect(overflowErrors, isNull);
    });
  });
}
