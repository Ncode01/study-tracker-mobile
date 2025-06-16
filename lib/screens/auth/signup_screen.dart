import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_state.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_screen_scaffold.dart';
import '../../theme/app_colors.dart';

/// Sign up screen with traveler's diary aesthetic
/// Allows new explorers to begin their adventure
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authProvider.notifier)
        .signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }
  String? _validateConfirmPassword(String? value) {
    return ValidationBuilder()
        .required('Please confirm your password')
        .add((value) {
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        })
        .build()(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return AuthScreenScaffold(
      titleLine1: 'Begin Your',
      titleLine2: 'Grand Adventure',
      subtitle:
          'Create your explorer profile and embark on a journey through knowledge. Every great adventure starts with a single step!',
      loadingMessage: 'Creating your explorer profile...',
      showBackButton: true,
      formKey: _formKey,
      formFields: [
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
          ),          validator: ValidationBuilder()
              .required('Every explorer needs a name')
              .minLength(2, 'Name must be at least 2 characters')
              .build(),
        ),
        const SizedBox(height: 24),        // Email field
        EmailTextField(
          controller: _emailController,
          errorText: authState.hasError ? authState.errorMessage : null,
        ),
        const SizedBox(height: 24),
        // Password field
        PasswordTextField(
          controller: _passwordController,
          label: 'Secret Password',
          hint: 'Create a strong password',          validator: ValidationBuilder()
              .required('A password is required for your journey')
              .minLength(6, 'Password must be at least 6 characters')
              .regExp(RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)'), 
                      'Password should contain letters and numbers')
              .build(),
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
            color: AppColors.surfaceLight.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
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
              children: const [
                TextSpan(
                  text:
                      'By creating an account, you agree to embark on this learning adventure responsibly and with dedication to your studies.',
                ),
              ],
            ),
          ),
        ),
      ],      primaryButton: PrimaryButton(
        text: 'Start My Journey',
        onPressed: _handleSignUp,
        isLoading: authState.isLoading,
        icon: Icons.rocket_launch_rounded,
      ),
      secondaryActions: [
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
    );
  }
}
