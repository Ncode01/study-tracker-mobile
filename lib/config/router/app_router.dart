import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/auth_wrapper.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subjects/presentation/screens/subject_create_placeholder_screen.dart';
import '../../features/subjects/presentation/screens/subject_detail_placeholder_screen.dart';
import '../../features/study_session/presentation/screens/study_session_placeholder_screen.dart';
import '../../features/progress/presentation/screens/progress_placeholder_screen.dart';
import '../../features/goals/presentation/screens/goals_placeholder_screen.dart';
import '../../features/study/domain/models/subject_model.dart';

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
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const HomeScreen(),
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
      // Subject management routes
      GoRoute(
        path: '/subjects/create',
        name: 'subject-create',
        builder: (context, state) => const SubjectCreatePlaceholderScreen(),
      ),
      GoRoute(
        path: '/subjects/:id',
        name: 'subject-detail',
        builder: (context, state) {
          final subjectId = state.pathParameters['id']!;
          return SubjectDetailPlaceholderScreen(subjectId: subjectId);
        },
      ),
      // Study session routes
      GoRoute(
        path: '/study/session',
        name: 'study-session',
        builder: (context, state) {
          final subject = state.extra as Subject?;
          return StudySessionPlaceholderScreen(subject: subject);
        },
      ),

      // Progress/Analytics routes
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressPlaceholderScreen(),
      ),

      // Goals routes
      GoRoute(
        path: '/goals',
        name: 'goals',
        builder: (context, state) => const GoalsPlaceholderScreen(),
      ),

      // Legacy /home route redirects to /dashboard
      GoRoute(
        path: '/home',
        name: 'home',
        redirect: (context, state) => '/dashboard',
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
