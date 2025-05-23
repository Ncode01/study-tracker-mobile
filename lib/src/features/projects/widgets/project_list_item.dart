import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/utils/formatters.dart';

/// A widget that displays a single project in the project list.
class ProjectListItem extends StatelessWidget {
  /// The project to display.
  final Project project;

  /// Creates a [ProjectListItem].
  const ProjectListItem({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerServiceProvider>(context);
    final isActive =
        timerProvider.isTimerRunning &&
        timerProvider.activeProjectId == project.id;
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
          IconButton(
            icon: Icon(
              isActive ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              if (isActive) {
                timerProvider.stopTimer(context);
              } else {
                timerProvider.startTimer(project, context);
              }
            },
            tooltip: isActive ? 'Stop Timer' : 'Start Timer',
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: project.color,
            radius: 22,
            child: Icon(Icons.folder, color: Colors.white),
          ),
          SizedBox(width: 16),
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
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${formatDuration(project.loggedMinutes)} / ${formatDuration(project.goalMinutes)}',
                    style: TextStyle(
                      color: AppColors.secondaryTextColor,
                      fontSize: 13,
                    ),
                  ),
                  if (isActive) ...[
                    SizedBox(width: 8),
                    Text(
                      formatDuration(timerProvider.elapsedTime.inMinutes),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
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
              SizedBox(height: 4),
              Icon(
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
