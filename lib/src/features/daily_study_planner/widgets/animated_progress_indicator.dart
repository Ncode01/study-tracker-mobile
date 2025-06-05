import 'package:flutter/material.dart';
import 'package:study/src/constants/app_colors.dart';

/// An animated circular progress indicator for study completion.
class AnimatedProgressIndicator extends StatefulWidget {
  /// The completion percentage (0.0 to 1.0)
  final double progress;

  /// The color of the progress indicator
  final Color color;

  /// The size of the indicator
  final double size;

  /// The duration of the animation
  final Duration animationDuration;

  /// Creates an [AnimatedProgressIndicator].
  const AnimatedProgressIndicator({
    super.key,
    required this.progress,
    this.color = AppColors.primaryColor,
    this.size = 60.0,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4.0,
                  backgroundColor: AppColors.backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.backgroundColor,
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 4.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                ),
              ),
              // Percentage text
              Text(
                '${(_progressAnimation.value * 100).round()}%',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: widget.size * 0.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
