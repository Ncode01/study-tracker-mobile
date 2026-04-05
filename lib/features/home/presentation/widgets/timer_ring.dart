import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.timeText,
    required this.timeSpentLabel,
    required this.semanticsLabel,
    required this.progress,
    required this.accentColor,
    this.onTap,
    this.size = 280,
    this.semanticsHint,
  });

  final String timeText;
  final String timeSpentLabel;
  final String semanticsLabel;
  final double progress;
  final Color accentColor;
  final VoidCallback? onTap;
  final double size;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      hint: onTap != null ? semanticsHint : null,
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: SizedBox(
            width: size,
            height: size,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _TimerRingPainter(
                  progress: progress.clamp(0, 1),
                  accentColor: accentColor,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder, width: 1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeSpentLabel,
                          style: AppTypography.display(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          timeText,
                          style: AppTypography.mono(
                            color: AppColors.textMain,
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({required this.progress, required this.accentColor});

  final double progress;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.width / 2) - 10;

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * progress;

    final Paint trackPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 8
          ..color = AppColors.glassBorder;

    final Paint glowPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 9
          ..color = accentColor.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final Paint arcPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 6
          ..color = accentColor;

    canvas.drawArc(arcRect, 0, 2 * pi, false, trackPaint);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
