import 'package:flutter/material.dart';
import 'package:study/src/constants/app_theme.dart';
import 'progress_bar.dart';

class DestinationCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final String progressLabel;
  final String destinationName;
  final List<String> journeyMilestones;
  final List<String> achievements;

  const DestinationCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.progressLabel,
    required this.destinationName,
    this.journeyMilestones = const [],
    this.achievements = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).cardTheme.shadowColor ?? Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).cardTheme.shadowColor?.withOpacity(0.10) ??
                Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 32,
                color: Theme.of(context).primaryColorDark,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ProgressBar(progress: progress),
          const SizedBox(height: 8),
          Text(
            progressLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'New destination scenery will be unlocked upon completion!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          // Journey milestones and achievements
          if (journeyMilestones.isNotEmpty) ...[
            Text(
              'Journey Milestones:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  journeyMilestones
                      .map(
                        (m) => Text(
                          '• $m',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 8),
          ],
          if (achievements.isNotEmpty) ...[
            Text(
              'Achievements:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  achievements
                      .map(
                        (a) => Text(
                          a,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
