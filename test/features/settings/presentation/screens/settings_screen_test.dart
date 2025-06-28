import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:study/features/settings/presentation/screens/settings_screen.dart';
import 'package:study/models/user_model.dart';
import 'package:study/providers/auth_provider.dart';
import 'package:study/models/auth_state.dart';

// Mock AuthNotifier for testing
class MockAuthNotifier extends StateNotifier<AuthData> implements AuthNotifier {
  MockAuthNotifier(super.state);

  @override
  Future<void> deleteAccount() async {
    state = const AuthData.unauthenticated();
  }

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {}

  @override
  Future<void> signUpWithEmail(
      {required String email, required String password, required String displayName}) async {}

  @override
  Future<void> signOut() async {}

  @override
  void clearError() {}

  @override
  UserModel? get currentUser => state.whenOrNull(authenticated: (user) => user);

  @override
  bool get isAuthenticated => state.whenOrNull(authenticated: (_) => true) ?? false;

  @override
  VoidCallback? onSignUpSuccess;
}

void main() {
  group('SettingsScreen', () {
    testWidgets('back button pops the router', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings',
              routes: [
                GoRoute(path: '/profile', builder: (context, state) => const Scaffold()),
                GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
              ],
            ),
          ),
        ),
      );

      // Tap the back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify that we've navigated back to the profile screen
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets('delete account dialog requires confirmation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier(const AuthData.unauthenticated())),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Tap the delete account button
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Delete Account'), findsWidgets);

      // Verify the confirm button is disabled
      final deleteButton = find.widgetWithText(ElevatedButton, 'Delete Forever');
      expect(tester.widget<ElevatedButton>(deleteButton).onPressed, isNull);

      // Type "DELETE" into the text field
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pumpAndSettle();

      // Verify the confirm button is now enabled
      expect(tester.widget<ElevatedButton>(deleteButton).onPressed, isNotNull);

      // Tap the delete button
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Verify the dialog is closed
      expect(find.text('Delete Account'), findsNothing);
    });
  });
}
