import 'package:flutter/material.dart';
import '../../../constants/journey_map_colors.dart';

/// A custom card widget with a hand-drawn border aesthetic.
///
/// This widget provides a consistent card layout with the journey map
/// theme styling, including rounded corners, custom colors, and elevation
/// that matches the whimsical hand-drawn design.
class HandDrawnBorderCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Optional padding for the card content.
  final EdgeInsetsGeometry? padding;

  /// Optional margin for the card positioning.
  final EdgeInsetsGeometry? margin;

  /// Optional background color override.
  final Color? backgroundColor;

  /// Optional border color override.
  final Color? borderColor;

  /// Optional border width override.
  final double? borderWidth;

  /// Optional border radius override.
  final double? borderRadius;

  /// Optional elevation override.
  final double? elevation;

  /// Creates a hand-drawn border card.
  const HandDrawnBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? JourneyMapColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
        border: Border.all(
          color: borderColor ?? JourneyMapColors.cardBorder,
          width: borderWidth ?? 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: JourneyMapColors.cardBorder.withOpacity(0.3),
            blurRadius: elevation ?? 4.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
