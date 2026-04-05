import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key, required this.accentColor});

  final Color accentColor;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: ColoredBox(color: AppColors.backgroundDark),
          ),
          Positioned.fill(
            child: Center(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    final double t = Curves.easeInOut.transform(
                      _controller.value,
                    );
                    final double scale = 0.92 + (0.14 * t);
                    final double opacity = 0.18 + (0.16 * t);

                    return Transform.scale(
                      scale: scale,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 70 + (22 * t),
                          sigmaY: 70 + (22 * t),
                        ),
                        child: Container(
                          width: 310,
                          height: 310,
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(
                              alpha: opacity,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
