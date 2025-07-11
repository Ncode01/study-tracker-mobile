import 'package:flutter/material.dart';

/// Shared loading skeleton for list UIs.
/// Use for consistent loading states across the app.
class SharedLoadingSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const SharedLoadingSkeleton({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: EdgeInsets.only(bottom: spacing),
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Shared error state widget for consistent error display.
class SharedErrorState extends StatelessWidget {
  final Object error;
  const SharedErrorState(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('Error: $error'),
    );
  }
}
