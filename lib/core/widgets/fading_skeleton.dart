import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import 'glass_container.dart';

class FadingSkeletonBlock extends StatelessWidget {
  const FadingSkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 14,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: width,
          height: height,
          child: GlassContainer(
            borderRadius: BorderRadius.circular(borderRadius),
            backgroundColor: Colors.white.withValues(alpha: 0.045),
            borderColor: AppColors.glassBorder,
            child: const SizedBox.expand(),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(begin: 0.32, end: 0.9, duration: 820.ms);
  }
}
