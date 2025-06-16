import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';

/// Authentication wrapper that routes users based on their auth state
/// Acts as the gatekeeper between authenticated and unauthenticated screens
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Handle different authentication states using freezed union methods
    return authState.when(
      initial: () => _buildLoadingScreen(context),
      loading: () => _buildLoadingScreen(context),
      authenticated: (user) => _buildHomeScreen(context, user.displayName),
      unauthenticated: () => const LoginScreen(),
      error: (message) => _buildErrorScreen(context, message),
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
                    color: AppColors.fadeGray.withAlpha((255 * 0.3).round()),
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
                          color: AppColors.primaryBrown.withAlpha(
                            (255 * 0.3).round(),
                          ),
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
                    color: AppColors.errorRed.withAlpha((255 * 0.1).round()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.errorRed.withAlpha((255 * 0.3).round()),
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

  /// Placeholder home screen for authenticated users
  Widget _buildHomeScreen(BuildContext context, String displayName) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Welcome, $displayName!',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.parchmentWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryBrown,
        elevation: 2,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: AppColors.parchmentWhite,
                ),
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [AppColors.primaryGold, AppColors.primaryBrown],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBrown.withAlpha(
                        (255 * 0.3).round(),
                      ),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.celebration_rounded,
                  size: 50,
                  color: AppColors.parchmentWhite,
                ),
              ),

              const SizedBox(height: 32),

              // Welcome message
              Text(
                'Welcome to Project Atlas!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Your authentication is working perfectly! 🎉\n\nThis is a placeholder for the main app. The study tracking features will be built next.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.fadeGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Feature coming soon card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGold.withAlpha((255 * 0.3).round()),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fadeGray.withAlpha((255 * 0.1).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 32,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Study Features Coming Soon',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subject creation, study timer, XP system, and progress tracking will be added in the next phase.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.fadeGray,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
