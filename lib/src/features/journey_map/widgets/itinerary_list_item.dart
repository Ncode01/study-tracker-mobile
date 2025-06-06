import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/study_plan_entry_model.dart';
import '../../../providers/project_provider.dart';

/// A list item widget for displaying study plan entries in the journey map.
///
/// This widget displays a single study plan entry with dynamic icon, title,
/// time information, and completion status. It uses the hand-drawn card
/// styling to maintain consistency with the journey map theme.
class ItineraryListItem extends StatelessWidget {
  /// The study plan entry to display.
  final StudyPlanEntry entry;

  /// Optional callback function when the item is tapped.
  final VoidCallback? onTap;

  /// Optional margin for the list item.
  final EdgeInsetsGeometry? margin;

  /// Creates an itinerary list item from a study plan entry.
  const ItineraryListItem({
    super.key,
    required this.entry,
    this.onTap,
    this.margin,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.withOpacity(0.6), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    _getIconForSubject(entry.subjectName),
                    color: _getIconColor(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Title and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.subjectName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              entry.isCompleted
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                          decoration:
                              entry.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTimeAndProjectInfo(context),
                    ],
                  ),
                ),
                // Trailing section
                _buildTrailingSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the time and project information row
  Widget _buildTimeAndProjectInfo(BuildContext context) {
    final timeText = _getTimeText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (timeText.isNotEmpty)
          Row(
            children: [
              Icon(
                entry.isAllDay ? Icons.event : Icons.access_time,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        if (entry.projectId != null)
          Consumer<ProjectProvider>(
            builder: (context, projectProvider, _) {
              final project =
                  projectProvider.projects
                      .where((p) => p.id == entry.projectId)
                      .firstOrNull;

              if (project == null) return const SizedBox.shrink();

              return Row(
                children: [
                  CircleAvatar(backgroundColor: project.color, radius: 6),
                  const SizedBox(width: 6),
                  Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  /// Builds the trailing section with completion status
  Widget _buildTrailingSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (entry.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (entry.isOverdue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.redAccent, width: 1),
            ),
            child: const Text(
              'LATE',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (entry.isToday)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            child: Text(
              'TODAY',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Icon(Icons.edit, size: 16, color: Theme.of(context).disabledColor),
      ],
    );
  }

  /// Gets the appropriate icon for a subject name
  IconData _getIconForSubject(String subjectName) {
    final subject = subjectName.toLowerCase();

    // Science subjects
    if (subject.contains('math') ||
        subject.contains('algebra') ||
        subject.contains('geometry') ||
        subject.contains('calculus')) {
      return Icons.calculate;
    }
    if (subject.contains('science') ||
        subject.contains('physics') ||
        subject.contains('chemistry') ||
        subject.contains('biology')) {
      return Icons.science;
    }
    if (subject.contains('computer') ||
        subject.contains('programming') ||
        subject.contains('coding') ||
        subject.contains('software')) {
      return Icons.computer;
    }

    // Language subjects
    if (subject.contains('english') ||
        subject.contains('literature') ||
        subject.contains('writing')) {
      return Icons.menu_book;
    }
    if (subject.contains('language') ||
        subject.contains('spanish') ||
        subject.contains('french') ||
        subject.contains('german')) {
      return Icons.translate;
    }

    // Arts subjects
    if (subject.contains('art') ||
        subject.contains('design') ||
        subject.contains('drawing')) {
      return Icons.palette;
    }
    if (subject.contains('music')) {
      return Icons.music_note;
    }

    // Social studies
    if (subject.contains('history') ||
        subject.contains('geography') ||
        subject.contains('social')) {
      return Icons.public;
    }

    // Default icon
    return Icons.school;
  }

  /// Gets the color for the icon
  Color _getIconColor(BuildContext context) {
    if (entry.isCompleted) {
      return Colors.green;
    } else if (entry.isOverdue) {
      return Colors.redAccent;
    } else if (entry.isToday) {
      return Theme.of(context).colorScheme.secondary;
    }
    return Theme.of(context).colorScheme.secondary;
  }

  /// Gets the formatted time text for the entry
  String _getTimeText() {
    if (entry.isAllDay) {
      return 'All Day';
    }

    final timeFormat = DateFormat.jm();
    if (entry.startTime != null && entry.endTime != null) {
      return '${timeFormat.format(entry.startTime!)} - ${timeFormat.format(entry.endTime!)}';
    } else if (entry.startTime != null) {
      return 'From ${timeFormat.format(entry.startTime!)}';
    } else if (entry.endTime != null) {
      return 'Until ${timeFormat.format(entry.endTime!)}';
    }

    return '';
  }
}
