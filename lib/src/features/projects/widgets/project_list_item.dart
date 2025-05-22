import 'package:flutter/material.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/utils/formatters.dart';

/// A widget that displays a single project in the project list.
class ProjectListItem extends StatelessWidget {
  /// The project to display.
  final Project project;

  /// Creates a [ProjectListItem].
  const ProjectListItem({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percent =
        project.goalMinutes > 0
            ? (project.loggedMinutes / project.goalMinutes * 100).clamp(0, 100)
            : 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF232323), width: 1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: project.color,
            radius: 22,
            child: const Icon(Icons.play_arrow, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatDuration(project.loggedMinutes)} / ${formatDuration(project.goalMinutes)}',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
