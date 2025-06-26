import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';

/// Authentication wrapper that routes users based on their auth state
/// Acts as the gatekeeper between authenticated and unauthenticated screens
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authData = ref.watch(authProvider);

    // Handle different authentication states using the freezed union pattern
    return authData.when(
      initial: () => _buildLoadingScreen(context),
      loading: () => _buildLoadingScreen(context),
      authenticated: (user) {
        // This should not happen due to router redirect, but just in case
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/profile');
        });
        return _buildLoadingScreen(context);
      },
      unauthenticated: () => const LoginScreen(),
      error: (message, exception) => _buildErrorScreen(context, message),
    );
  }

  /// Loading screen with traveler's diary aesthetic
  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/title area
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.parchmentWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fadeGray.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // App icon placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [AppColors.primaryGold, AppColors.primaryBrown],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBrown.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.explore_rounded,
                      size: 40,
                      color: AppColors.parchmentWhite,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App name
                  Text(
                    'Project Atlas',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.primaryBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Your Study Adventure Awaits',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.fadeGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Loading indicator
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGold,
                    ),
                    strokeWidth: 3,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Preparing your journey...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.fadeGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error screen with retry option
  Widget _buildErrorScreen(BuildContext context, String? errorMessage) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: AppColors.errorRed,
                  ),
                ),

                const SizedBox(height: 24),

                // Error title
                Text(
                  'Oops! Something went wrong',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Error message
                Text(
                  errorMessage ?? 'An unexpected error occurred',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.fadeGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Retry button
                ElevatedButton(
                  onPressed: () {
                    // Restart the app by forcing a rebuild
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const AuthWrapper(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    foregroundColor: AppColors.parchmentWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded),
                      const SizedBox(width: 8),
                      Text('Try Again'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
