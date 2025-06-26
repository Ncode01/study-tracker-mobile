import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/common/loading_overlay.dart';

/// Settings screen - configuration and account management
/// Provides access to various app settings and account actions
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeleting = false;
  final _deleteConfirmController = TextEditingController();

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoadingOverlay(
      isVisible: _isDeleting,
      message: 'Deleting your explorer account...',
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBrown),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings Categories
              _buildSectionHeader(context, 'Account'),
              _buildSettingsTile(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your explorer information',
                onTap: () => _showComingSoonDialog(context, 'Edit Profile'),
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your account security',
                onTap:
                    () => _showComingSoonDialog(context, 'Privacy & Security'),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Preferences'),
              _buildSettingsTile(
                context,
                icon: Icons.palette_outlined,
                title: 'Theme Settings',
                subtitle: 'Customize your diary appearance',
                onTap: () => _showComingSoonDialog(context, 'Theme Settings'),
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage your journey reminders',
                onTap: () => _showComingSoonDialog(context, 'Notifications'),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Support'),
              _buildSettingsTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help with your adventure',
                onTap: () => _showComingSoonDialog(context, 'Help & Support'),
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Learn more about Project Atlas',
                onTap: () => _showComingSoonDialog(context, 'About'),
              ),

              const SizedBox(height: 48),

              // Danger Zone
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Zone',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Irreversible actions that will permanently affect your explorer account.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.fadeGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isDeleting
                                ? null
                                : () => _showDeleteAccountDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_forever, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primaryBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryBrown, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.fadeGray),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.fadeGray,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            title: Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '$feature will be available in a future update. Stay tuned for more exciting features on your exploration journey!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceLight,
              title: Text(
                'Delete Account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action is irreversible. To confirm, please type "DELETE" in the box below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deleteConfirmController,
                    decoration: const InputDecoration(
                      labelText: 'Type DELETE to confirm',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
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
                  onPressed: _deleteConfirmController.text == 'DELETE'
                      ? () {
                          Navigator.of(context).pop();
                          _deleteAccount();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.fadeGray,
                  ),
                  child: const Text('Delete Forever'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await ref.read(authProvider.notifier).deleteAccount();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to login after a brief delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
