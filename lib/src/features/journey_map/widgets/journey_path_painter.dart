import 'package:flutter/material.dart';
import '../../../constants/journey_map_colors.dart';

/// CustomPainter for the winding, whimsical path in the Daily Study Path UI.
class JourneyPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = JourneyMapColors.secondaryText.withOpacity(0.18)
          ..strokeWidth = 10.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    // Start at the top center
    path.moveTo(size.width * 0.18, 0);
    double y = 0;
    double step = 80;
    bool left = true;
    while (y < size.height) {
      final controlX = left ? size.width * 0.02 : size.width * 0.34;
      final endX = left ? size.width * 0.18 : size.width * 0.18;
      final nextY = (y + step).clamp(0, size.height).toDouble();
      path.quadraticBezierTo(controlX, (y + step / 2).toDouble(), endX, nextY);
      y += step;
      left = !left;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
