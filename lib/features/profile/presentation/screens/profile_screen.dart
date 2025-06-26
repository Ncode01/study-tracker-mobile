import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study/models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/auth/auth_button.dart';

/// Profile screen - the explorer's personal dashboard
/// Displays user information and provides navigation to settings
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Explorer Profile',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: authState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        authenticated: (user) => _buildProfileContent(context, ref, user),
        unauthenticated:
            () =>
                const Center(child: Text('Please log in to view your profile')),
        error:
            (message, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, WidgetRef ref, UserModel user) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBrown, width: 3),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 24),

            // User Name
            Text(
              user.displayName,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryBrown,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Explorer Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGold),
              ),
              child: Text(
                user.explorerTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
            ),
          ),
          const SizedBox(height: 24),

          // User Stats Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.lightGray.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBrown.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Explorer Stats',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(context, 'Level', user.level.toString()),
                    _buildStatItem(context, 'XP', user.xp.toString()),
                  ],
                ),
                const SizedBox(height: 8),
                // XP Progress
                LinearProgressIndicator(
                  value: user.xpProgress,
                  backgroundColor: AppColors.lightGray,
                  color: AppColors.primaryGold,
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.xp} / ${user.xpForNextLevel} XP to next level',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.fadeGray,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.email, color: AppColors.primaryBrown, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.fadeGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          AuthButton(
            text: 'Settings',
            icon: Icons.settings,
            onPressed: () => context.go('/settings'),
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          AuthButton(
            text: 'Sign Out',
            icon: Icons.logout,
            isSecondary: true,
            onPressed: () => _showSignOutDialog(context, ref),
            width: double.infinity,
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.fadeGray,
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            title: Text(
              'Sign Out',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to sign out of your explorer account?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.fadeGray),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(authProvider.notifier).signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }
}
