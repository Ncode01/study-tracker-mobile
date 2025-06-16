import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Custom button with traveler's diary aesthetic
/// Designed to feel like a physical object with depth and texture
class AuthButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.padding,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    // Color scheme based on button type
    final backgroundColor =
        widget.isSecondary ? AppColors.surfaceLight : AppColors.primaryBrown;

    final foregroundColor =
        widget.isSecondary ? AppColors.primaryBrown : AppColors.textOnPrimary;

    final borderColor =
        widget.isSecondary ? AppColors.primaryBrown : Colors.transparent;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: widget.width,
              height: 56,
              decoration: BoxDecoration(
                // Parchment-like gradient for secondary, solid for primary
                gradient:
                    widget.isSecondary
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.parchmentWhite,
                            AppColors.surfaceLight,
                            AppColors.parchmentWhite.withAlpha(
                              (255 * 0.9).round(),
                            ),
                          ],
                        )
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            backgroundColor.withAlpha((255 * 0.9).round()),
                            backgroundColor,
                            backgroundColor.withAlpha((255 * 0.8).round()),
                          ],
                        ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isEnabled
                          ? borderColor.withAlpha(
                            (255 * (widget.isSecondary ? 0.8 : 0.0)).round(),
                          )
                          : AppColors.lightGray.withAlpha((255 * 0.5).round()),
                  width: widget.isSecondary ? 2.0 : 0.0,
                ),
                // Physical button effect with multiple shadows
                boxShadow:
                    isEnabled
                        ? [
                          // Main shadow for depth
                          BoxShadow(
                            color: AppColors.fadeGray.withAlpha(
                              (255 * 0.3).round(),
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          // Subtle highlight on top
                          BoxShadow(
                            color: Colors.white.withAlpha((255 * 0.5).round()),
                            blurRadius: 1,
                            offset: const Offset(0, -1),
                          ),
                          // Side shadow for dimensionality
                          BoxShadow(
                            color: AppColors.fadeGray.withAlpha(
                              (255 * 0.15).round(),
                            ),
                            blurRadius: 4,
                            offset: const Offset(2, 0),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: AppColors.lightGray.withAlpha(
                              (255 * 0.2).round(),
                            ),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: foregroundColor.withAlpha((255 * 0.1).round()),
                  highlightColor: foregroundColor.withAlpha(
                    (255 * 0.05).round(),
                  ),
                  child: Container(
                    padding:
                        widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                    child: _buildButtonContent(
                      theme,
                      foregroundColor,
                      isEnabled,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(
    ThemeData theme,
    Color foregroundColor,
    bool isEnabled,
  ) {
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: isEnabled ? foregroundColor : AppColors.fadeGray,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    if (widget.isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 12),
          Text('Loading...', style: textStyle),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: isEnabled ? foregroundColor : AppColors.fadeGray,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(widget.text, style: textStyle),
        ],
      );
    }

    return Center(child: Text(widget.text, style: textStyle));
  }
}

/// Primary action button for main actions (Sign In, Sign Up)
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isSecondary: false,
      icon: icon,
      width: width,
    );
  }
}

/// Secondary action button for alternative actions (Switch to Sign Up, etc.)
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isSecondary: true,
      icon: icon,
      width: width,
    );
  }
}

/// Text button for less prominent actions (Forgot Password, etc.)
class TextActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  const TextActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppColors.primaryBrown,
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: color ?? AppColors.primaryBrown,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text),
    );
  }
}
