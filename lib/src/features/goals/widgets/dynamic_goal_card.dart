import 'package:flutter/material.dart';
import 'package:study/src/features/goals/models/study_goal.dart';
import 'progress_bar.dart';

class DynamicGoalCard extends StatelessWidget {
  final StudyGoal goal;
  final VoidCallback? onTap;

  const DynamicGoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String progressLabel;
    double progress = goal.progress;
    Color accentColor = Theme.of(context).primaryColorLight;

    if (goal is WeeklyHoursGoal) {
      icon = Icons.flash_on;
      final g = goal as WeeklyHoursGoal;
      progressLabel =
          '${g.currentHours.toStringAsFixed(1)} / ${g.targetHours} hrs';
      accentColor = Colors.orangeAccent;
    } else if (goal is ChapterCompletionGoal) {
      icon = Icons.menu_book;
      final g = goal as ChapterCompletionGoal;
      progressLabel = '${g.completedSections} / ${g.targetSections} sections';
      accentColor = Colors.blueAccent;
    } else {
      icon = Icons.flag;
      progressLabel = '';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 32, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
        ),
      ),
    );
  }
}
