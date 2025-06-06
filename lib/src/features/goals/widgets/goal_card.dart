import 'package:flutter/material.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final double progress;
  final String progressLabel;

  const GoalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.progressLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).cardTheme.shadowColor ??
                  Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).cardTheme.shadowColor ??
                    Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 32,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              ProgressBar(progress: progress),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          progressLabel,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
