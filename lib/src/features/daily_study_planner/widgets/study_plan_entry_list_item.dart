import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/projects/providers/project_provider.dart';
import 'package:study/src/models/study_plan_entry_model.dart';

/// A widget that displays a single study plan entry in the list.
class StudyPlanEntryListItem extends StatelessWidget {
  /// The study plan entry to display.
  final StudyPlanEntry entry;

  /// Callback when the entry is tapped.
  final VoidCallback? onTap;

  /// Callback when the completion status is toggled.
  final VoidCallback? onToggleCompleted;

  /// Callback when the entry is deleted.
  final VoidCallback? onDelete;

  /// Creates a [StudyPlanEntryListItem].
  const StudyPlanEntryListItem({
    super.key,
    required this.entry,
    this.onTap,
    this.onToggleCompleted,
    this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key('study_plan_entry_${entry.id}'),
        direction: DismissDirection.endToStart,
        background: _buildDeleteBackground(),
        confirmDismiss: (direction) => _confirmDelete(context),
        onDismissed: (direction) => onDelete?.call(),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBorderColor(), width: 1.5),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildSubjectAndProject(context),
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildNotes(),
                  ],
                  if (_shouldShowTimeInfo()) ...[
                    const SizedBox(height: 8),
                    _buildTimeInfo(),
                  ],
                  if (entry.reminderDateTime != null) ...[
                    const SizedBox(height: 8),
                    _buildReminderInfo(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Completion checkbox
        GestureDetector(
          onTap: onToggleCompleted,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    entry.isCompleted
                        ? AppColors.primaryColor
                        : AppColors.secondaryTextColor!,
                width: 2,
              ),
              color:
                  entry.isCompleted
                      ? AppColors.primaryColor
                      : Colors.transparent,
            ),
            padding: const EdgeInsets.all(2),
            child:
                entry.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : const SizedBox(width: 16, height: 16),
          ),
        ),
        const SizedBox(width: 12),

        // Status indicators
        Expanded(
          child: Row(
            children: [
              if (entry.isOverdue && !entry.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: const Text(
                    'OVERDUE',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (entry.isToday && !entry.isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primaryColor, width: 1),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (entry.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Edit indicator
        Icon(Icons.edit, size: 16, color: AppColors.secondaryTextColor),
      ],
    );
  }

  Widget _buildSubjectAndProject(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.subjectName,
                style: TextStyle(
                  color:
                      entry.isCompleted
                          ? AppColors.secondaryTextColor
                          : AppColors.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration:
                      entry.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              if (entry.projectId != null)
                Consumer<ProjectProvider>(
                  builder: (context, projectProvider, _) {
                    final project =
                        projectProvider.projects
                            .where((p) => p.id == entry.projectId)
                            .firstOrNull;

                    if (project == null) {
                      return const SizedBox.shrink();
                    }

                    return Row(
                      children: [
                        CircleAvatar(backgroundColor: project.color, radius: 6),
                        const SizedBox(width: 6),
                        Text(
                          project.name,
                          style: TextStyle(
                            color: AppColors.secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note, size: 16, color: AppColors.secondaryTextColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.notes!,
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    final timeFormat = DateFormat.jm();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            entry.isAllDay ? Icons.event : Icons.access_time,
            size: 16,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            _getTimeText(timeFormat),
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (entry.durationMinutes != null) ...[
            const Spacer(),
            Text(
              '${entry.durationMinutes} min',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderInfo() {
    final reminderFormat = DateFormat('MMM d, h:mm a');
    final isReminderPast = entry.reminderDateTime!.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isReminderPast
                ? Colors.orange.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications,
            size: 16,
            color: isReminderPast ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            'Reminder: ${reminderFormat.format(entry.reminderDateTime!)}',
            style: TextStyle(
              color: isReminderPast ? Colors.orange : Colors.blue,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeText(DateFormat timeFormat) {
    if (entry.isAllDay) {
      return 'All Day';
    } else if (entry.startTime != null && entry.endTime != null) {
      return '${timeFormat.format(entry.startTime!)} - ${timeFormat.format(entry.endTime!)}';
    } else if (entry.startTime != null) {
      return 'From ${timeFormat.format(entry.startTime!)}';
    } else if (entry.endTime != null) {
      return 'Until ${timeFormat.format(entry.endTime!)}';
    }
    return '';
  }

  bool _shouldShowTimeInfo() {
    return entry.isAllDay || entry.startTime != null || entry.endTime != null;
  }

  Color _getBorderColor() {
    if (entry.isCompleted) {
      return Colors.green.withOpacity(0.3);
    } else if (entry.isOverdue) {
      return Colors.redAccent.withOpacity(0.5);
    } else if (entry.isToday) {
      return AppColors.primaryColor.withOpacity(0.5);
    } else {
      return Colors.transparent;
    }
  }

  /// Builds the red delete background shown when swiping
  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the entry
  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          title: const Text(
            'Delete Study Plan',
            style: TextStyle(color: AppColors.textColor),
          ),
          content: Text(
            'Are you sure you want to delete "${entry.subjectName}"? This action cannot be undone.',
            style: TextStyle(color: AppColors.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
