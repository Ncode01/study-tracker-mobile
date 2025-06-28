import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/persistent_auth_provider.dart';
import '../../../../screens/auth/login_screen.dart';
import '../screens/splash_screen.dart';

/// Enhanced authentication wrapper with session persistence
///
/// This widget handles automatic session restoration and smart routing
/// based on the user's authentication state
class EnhancedAuthWrapper extends ConsumerWidget {
  final Widget child;

  const EnhancedAuthWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(persistentAuthProvider);

    return authState.when(
      initial: () => const SplashScreen(), // Show splash while initializing
      loading: () => const SplashScreen(), // Show splash while checking session
      authenticated: (user) {
        // User is logged in - show main app
        return child;
      },
      unauthenticated: () {
        // No user session - show login screen
        return const LoginScreen();
      },
      error: (message, exception) {
        // Handle auth error - show login screen
        return const LoginScreen();
      },
    );
  }
}
