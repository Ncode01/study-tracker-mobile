import 'package:flutter/material.dart';
import 'package:study/src/features/goals/models/study_goal.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  final StudyGoal goal;
  final VoidCallback? onTap;

  const GoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String progressLabel;
    double progress = goal.progress;
    if (goal is WeeklyHoursGoal) {
      icon = Icons.access_time;
      final g = goal as WeeklyHoursGoal;
      progressLabel =
          '${g.currentHours.toStringAsFixed(1)} / ${g.targetHours} hrs';
    } else if (goal is ChapterCompletionGoal) {
      icon = Icons.menu_book;
      final g = goal as ChapterCompletionGoal;
      progressLabel = '${g.completedSections} / ${g.targetSections} sections';
    } else if (goal is SemesterGPAGoal) {
      icon = Icons.school;
      final g = goal as SemesterGPAGoal;
      progressLabel = 'Current: ${g.currentGPA.toStringAsFixed(2)} GPA';
    } else {
      icon = Icons.flag;
      progressLabel = '';
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
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
    );
  }
}
