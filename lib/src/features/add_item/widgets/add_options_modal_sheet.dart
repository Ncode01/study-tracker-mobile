import 'package:flutter/material.dart';

/// Modal bottom sheet for add options (Project, Task).
class AddOptionsModalSheet extends StatelessWidget {
  /// Creates an [AddOptionsModalSheet].
  const AddOptionsModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: appTheme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Create New',
                style: appTheme.textTheme.titleLarge?.copyWith(
                  color: appTheme.colorScheme.onBackground,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.event_note,
                color: appTheme.colorScheme.primary,
              ),
              title: Text(
                'Study Plan',
                style: appTheme.textTheme.bodyLarge?.copyWith(
                  color: appTheme.colorScheme.onBackground,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/study-planner/add');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: appTheme.colorScheme.primary,
              ),
              title: Text(
                'Task',
                style: appTheme.textTheme.bodyLarge?.copyWith(
                  color: appTheme.colorScheme.onBackground,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/tasks/add');
              },
            ),
          ],
        ),
      ),
    );
  }
}
