import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import '../../providers/persistent_auth_provider.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../theme/app_colors.dart';

/// Sign up screen with traveler's diary aesthetic
/// Allows new explorers to begin their adventure
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Professional form validation using form_validator
  late final String? Function(String?) _nameValidator;
  late final String? Function(String?) _emailValidator;
  late final String? Function(String?) _passwordValidator;
  late final String? Function(String?) _confirmPasswordValidator;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize validators using ValidationBuilder
    _nameValidator =
        ValidationBuilder()
            .required('Every explorer needs a name')
            .minLength(2, 'Name must be at least 2 characters long')
            .maxLength(50, 'Name must be less than 50 characters')
            .build();

    _emailValidator =
        ValidationBuilder()
            .required('Every explorer needs an email address')
            .email('Please enter a valid email address')
            .build();

    _passwordValidator =
        ValidationBuilder()
            .required('A secret password is required for your journey')
            .minLength(6, 'Password must be at least 6 characters long')
            .regExp(
              RegExp(r'^(?=.*[A-Za-z])(?=.*\d)'),
              'Password must contain at least one letter and one number',
            )
            .build();

    _confirmPasswordValidator =
        ValidationBuilder().required('Please confirm your password').add((
          value,
        ) {
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        }).build();

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(persistentAuthProvider.notifier)
        .signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(persistentAuthProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.primaryBrown),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: LoadingOverlay(
        isVisible: authState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),
        message: 'Creating your explorer profile...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Welcome header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Begin Your',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Grand Adventure',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create your explorer profile and embark on a journey through knowledge. Every great adventure starts with a single step!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.fadeGray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Sign up form
                SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Display name field
                        CustomTextField(
                          label: 'Explorer Name',
                          hint: 'What shall we call you?',
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          validator: _nameValidator,
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.fadeGray,
                            size: 20,
                          ),
                        ),

                        const SizedBox(height: 24), // Email field
                        EmailTextField(
                          controller: _emailController,
                          validator: _emailValidator,
                          errorText: authState.maybeWhen(
                            error: (message, exception) => message,
                            orElse: () => null,
                          ),
                        ),

                        const SizedBox(height: 24), // Password field
                        PasswordTextField(
                          controller: _passwordController,
                          label: 'Secret Password',
                          hint: 'Create a strong password',
                          validator: _passwordValidator,
                        ),

                        const SizedBox(height: 24), // Confirm password field
                        PasswordTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your secret password',
                          validator: _confirmPasswordValidator,
                        ),

                        const SizedBox(height: 32), // Terms and conditions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.fadeGray,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'By creating an account, you agree to embark on this learning adventure responsibly and with dedication to your studies.',
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Create account button
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'Start My Journey',
                            onPressed: _handleSignUp,
                            isLoading: authState.maybeWhen(
                              loading: () => true,
                              orElse: () => false,
                            ),
                            icon: Icons.rocket_launch_rounded,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sign in link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have a map? ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.fadeGray,
                                ),
                              ),
                              TextActionButton(
                                text: 'Continue Journey',
                                onPressed: () => Navigator.of(context).pop(),
                                color: AppColors.primaryBrown,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Footer inspiration
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
                            '"The future belongs to those who\\nbelieve in the beauty of their dreams."',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.fadeGray,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '— Eleanor Roosevelt',
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
