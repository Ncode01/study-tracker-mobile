import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../theme/app_colors.dart';

/// Login screen with traveler's diary aesthetic
/// Allows explorers to continue their journey by signing in
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Professional form validation using form_validator
  late final String? Function(String?) _emailValidator;
  late final String? Function(String?) _passwordValidator;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize validators using ValidationBuilder
    _emailValidator =
        ValidationBuilder()
            .required('Every explorer needs an email address')
            .email('Please enter a valid email address')
            .build();

    _passwordValidator =
        ValidationBuilder()
            .required('A password is required for your journey')
            .minLength(6, 'Password must be at least 6 characters long')
            .build();

    // Slide animation for the form
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    // Fade animation for elements
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
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
    context.go('/signup');
  }

  void _showForgotPasswordDialog() {
    showDialog(context: context, builder: (context) => _ForgotPasswordDialog());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: LoadingOverlay(
        isVisible: authState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),
        message: 'Welcome back, Explorer!',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Welcome back header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fellow Explorer',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Continue your journey through the realms of knowledge. Your adventure awaits!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.fadeGray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Login form
                SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email field
                        EmailTextField(
                          controller: _emailController,
                          validator: _emailValidator,
                          errorText: authState.maybeWhen(
                            error: (message, exception) => message,
                            orElse: () => null,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Password field
                        PasswordTextField(
                          controller: _passwordController,
                          validator: _passwordValidator,
                        ),

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

                        const SizedBox(height: 32),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'Continue Journey',
                            onPressed: _handleSignIn,
                            isLoading: authState.maybeWhen(
                              loading: () => true,
                              orElse: () => false,
                            ),
                            icon: Icons.login_rounded,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider with text
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.lightGray),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.fadeGray,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.lightGray),
                            ),
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
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Footer quote
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
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
                ),
              ],
            ),
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

  // Professional form validation using form_validator
  late final String? Function(String?) _emailValidator;

  @override
  void initState() {
    super.initState();

    // Initialize email validator
    _emailValidator =
        ValidationBuilder()
            .required('Every explorer needs an email address')
            .email('Please enter a valid email address')
            .build();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // For local-only auth, just show a success message
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset instructions (simulated) sent to your email!',
            style: TextStyle(color: AppColors.parchmentWhite),
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
            EmailTextField(
              controller: _emailController,
              validator: _emailValidator,
            ),
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
