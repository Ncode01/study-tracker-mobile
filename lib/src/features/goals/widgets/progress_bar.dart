import 'package:flutter/material.dart';
import 'package:study/src/constants/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          height: 14,
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: width * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
