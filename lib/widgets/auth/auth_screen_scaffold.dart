import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_state.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../theme/app_colors.dart';

/// Unified scaffold for authentication screens
///
/// This widget consolidates all the common UI elements and behaviors
/// shared between login and signup screens, eliminating duplication
/// and ensuring consistent UX across all auth flows.
class AuthScreenScaffold extends ConsumerStatefulWidget {
  /// The main title text (e.g., "Welcome Back," or "Begin Your")
  final String titleLine1;

  /// The secondary title text (e.g., "Fellow Explorer" or "Grand Adventure")
  final String titleLine2;

  /// The descriptive subtitle below the title
  final String subtitle;

  /// The loading message to show during authentication
  final String loadingMessage;

  /// Whether to show the back button in the app bar
  final bool showBackButton;

  /// The form fields to display (email, password, etc.)
  final List<Widget> formFields;

  /// The primary action button (Sign In, Sign Up, etc.)
  final Widget primaryButton;

  /// Optional secondary actions (like "Forgot Password" link)
  final List<Widget> secondaryActions;

  /// Optional footer content (like inspirational quote)
  final Widget? footer;

  /// Callback for form submission
  final VoidCallback? onSubmit;

  /// Form key for validation
  final GlobalKey<FormState> formKey;

  const AuthScreenScaffold({
    super.key,
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
    required this.loadingMessage,
    required this.formFields,
    required this.primaryButton,
    required this.formKey,
    this.showBackButton = false,
    this.secondaryActions = const [],
    this.footer,
    this.onSubmit,
  });

  @override
  ConsumerState<AuthScreenScaffold> createState() => _AuthScreenScaffoldState();
}

class _AuthScreenScaffoldState extends ConsumerState<AuthScreenScaffold>
    with TickerProviderStateMixin {
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
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar:
          widget.showBackButton
              ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryBrown,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
              : null,      body: LoadingOverlay(
        isVisible: authState.isLoading,
        message: widget.loadingMessage,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adjust spacing based on whether we have an app bar
                SizedBox(height: widget.showBackButton ? 20 : 40),

                // Animated header section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.titleLine1,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.titleLine2,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.fadeGray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Animated form section
                SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      children: [
                        // Form fields
                        ...widget.formFields,

                        const SizedBox(height: 32),

                        // Primary action button
                        SizedBox(
                          width: double.infinity,
                          child: widget.primaryButton,
                        ),

                        // Secondary actions (if any)
                        if (widget.secondaryActions.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          ...widget.secondaryActions,
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer content (if provided)
                if (widget.footer != null) ...[
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: widget.footer!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
