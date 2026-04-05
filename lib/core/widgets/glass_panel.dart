import 'package:flutter/material.dart';

import 'glass_container.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      blurSigma: 24,
      child: child,
    );
  }
}
