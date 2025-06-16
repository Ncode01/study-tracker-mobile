import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Loading overlay with traveler's diary aesthetic
/// Shows a compass-inspired loading spinner over a semi-transparent backdrop
class LoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String? message;
  final Widget? child;

  const LoadingOverlay({
    super.key,
    required this.isVisible,
    this.message,
    this.child,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for the compass
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade animation for smooth show/hide
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    if (widget.isVisible) {
      _showLoading();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _showLoading();
      } else {
        _hideLoading();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showLoading() {
    _fadeController.forward();
    _rotationController.repeat();
  }

  void _hideLoading() {
    _fadeController.reverse();
    _rotationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        if (widget.child != null) widget.child!,

        // Loading overlay
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            if (_fadeAnimation.value == 0.0) {
              return const SizedBox.shrink();
            }

            return Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                color: AppColors.inkBlack.withAlpha((255 * 0.7).round()),
                child: Center(child: _buildLoadingContent(context)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.parchmentWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkBlack.withAlpha((255 * 0.3).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compass loading spinner
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: _buildCompassSpinner(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Loading message
          Text(
            widget.message ?? 'Charting your course...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.inkBlack,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Please wait while we prepare your journey',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.fadeGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompassSpinner() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryGold.withAlpha((255 * 0.8).round()),
            AppColors.primaryBrown,
            AppColors.primaryBrown.withAlpha((255 * 0.7).round()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withAlpha((255 * 0.3).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring with direction markers
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.parchmentWhite.withAlpha((255 * 0.8).round()),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // North marker
                Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.parchmentWhite,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // South marker
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.parchmentWhite.withAlpha(
                          (255 * 0.6).round(),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ), // East marker
                Positioned(
                  right: 2,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.parchmentWhite.withAlpha(
                          (255 * 0.6).round(),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ), // West marker
                Positioned(
                  left: 2,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.parchmentWhite.withAlpha(
                          (255 * 0.6).round(),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center compass needle
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.compassRed, AppColors.parchmentWhite],
              ),
            ),
          ),

          // Center dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.parchmentWhite,
              border: Border.all(color: AppColors.primaryBrown, width: 1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple loading overlay for quick operations
class SimpleLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final Widget? child;

  const SimpleLoadingOverlay({super.key, required this.isVisible, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        if (isVisible)
          Container(
            color: AppColors.inkBlack.withAlpha((255 * 0.5).round()),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold,
                ),
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }
}

/// Loading button that shows loading state inline
class LoadingButton extends StatelessWidget {
  final String text;
  final String loadingText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const LoadingButton({
    super.key,
    required this.text,
    this.loadingText = 'Loading...',
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isSecondary ? AppColors.surfaceLight : AppColors.primaryBrown,
        borderRadius: BorderRadius.circular(16),
        border:
            isSecondary
                ? Border.all(color: AppColors.primaryBrown, width: 2)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child:
                isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSecondary
                                  ? AppColors.primaryBrown
                                  : AppColors.parchmentWhite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          loadingText,
                          style: TextStyle(
                            color:
                                isSecondary
                                    ? AppColors.primaryBrown
                                    : AppColors.parchmentWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      text,
                      style: TextStyle(
                        color:
                            isSecondary
                                ? AppColors.primaryBrown
                                : AppColors.parchmentWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
