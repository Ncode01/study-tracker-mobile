import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/auth_wrapper.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // Legacy /home route redirects to /profile
      GoRoute(
        path: '/home',
        name: 'home',
        redirect: (context, state) => '/profile',
      ),
    ],
    redirect: (context, state) {
      final isAuth = auth.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final protectedRoutes = ['/home', '/profile', '/settings'];
      final currentPath = state.uri.toString();

      // Redirect unauthenticated users trying to access protected routes
      if (!isAuth && protectedRoutes.contains(currentPath)) {
        return '/login';
      }

      return null;
    },
  );
});
