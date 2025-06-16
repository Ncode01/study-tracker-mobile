import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_state.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_screen_scaffold.dart';
import '../../theme/app_colors.dart';
import 'signup_screen.dart';

/// Login screen with traveler's diary aesthetic
/// Allows explorers to continue their journey by signing in
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authProvider.notifier)
        .signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(context: context, builder: (context) => _ForgotPasswordDialog());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return AuthScreenScaffold(
      titleLine1: 'Welcome Back,',
      titleLine2: 'Fellow Explorer',
      subtitle:
          'Continue your journey through the realms of knowledge. Your adventure awaits!',
      loadingMessage: 'Welcome back, Explorer!',
      formKey: _formKey,
      formFields: [        // Email field
        EmailTextField(
          controller: _emailController,
          errorText: authState.hasError ? authState.errorMessage : null,
        ),
        const SizedBox(height: 24),
        // Password field
        PasswordTextField(controller: _passwordController),
        const SizedBox(height: 16),
        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextActionButton(
            text: 'Forgot your map?',
            onPressed: _showForgotPasswordDialog,
            color: AppColors.primaryGold,
          ),
        ),
      ],      primaryButton: PrimaryButton(
        text: 'Continue Journey',
        onPressed: _handleSignIn,
        isLoading: authState.isLoading,
        icon: Icons.login_rounded,
      ),
      secondaryActions: [
        // Divider with text
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.lightGray)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.fadeGray,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.lightGray)),
          ],
        ),
        const SizedBox(height: 24),
        // Sign up button
        SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            text: 'Begin New Adventure',
            onPressed: _navigateToSignUp,
            icon: Icons.explore_rounded,
          ),
        ),
      ],
      footer: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '"Every expert was once a beginner.\\nEvery journey starts with a single step."',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.fadeGray,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '— Explorer\'s Wisdom',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Forgot password dialog
class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(_emailController.text.trim());

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset instructions sent to your email!',
              style: TextStyle(color: AppColors.parchmentWhite),
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send reset email. Please try again.',
              style: TextStyle(color: AppColors.parchmentWhite),
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: AppColors.parchmentWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Reset Your Password',
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.primaryBrown,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you instructions to reset your password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.fadeGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            EmailTextField(controller: _emailController),
          ],
        ),
      ),
      actions: [
        TextActionButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.fadeGray,
        ),
        PrimaryButton(text: 'Send Reset Email', onPressed: _sendResetEmail),
      ],
    );
  }
}
