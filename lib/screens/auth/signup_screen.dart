import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_state.dart';
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

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation for the form
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Fade animation for elements
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

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

    await ref.read(authProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primaryBrown,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LoadingOverlay(
        isVisible: authState.state.isLoading,
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
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.fadeGray,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Every explorer needs a name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Email field
                        EmailTextField(
                          controller: _emailController,
                          errorText: authState.state.hasError
                              ? authState.errorMessage
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // Password field
                        PasswordTextField(
                          controller: _passwordController,
                          label: 'Secret Password',
                          hint: 'Create a strong password',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'A password is required for your journey';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)')
                                .hasMatch(value)) {
                              return 'Password should contain letters and numbers';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Confirm password field
                        PasswordTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your secret password',
                          validator: _validateConfirmPassword,
                        ),

                        const SizedBox(height: 32),

                        // Terms and conditions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryGold.withOpacity(0.3),
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
                            isLoading: authState.state.isLoading,
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
                        color: AppColors.surfaceLight.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3),
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
