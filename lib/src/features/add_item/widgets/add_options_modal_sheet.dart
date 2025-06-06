import 'package:flutter/material.dart';

/// Modal bottom sheet for add options (Project, Task).
class AddOptionsModalSheet extends StatelessWidget {
  /// Creates an [AddOptionsModalSheet].
  const AddOptionsModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_note, color: Colors.white),
              title: const Text(
                'Study Plan',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/study-planner/add');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
              title: const Text('Task', style: TextStyle(color: Colors.white)),
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
