import 'package:flutter/material.dart';

/// Placeholder form screen for creating a new task.
class AddTaskScreen extends StatelessWidget {
  /// Creates an [AddTaskScreen].
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Task Name (TextField Placeholder)'),
                const SizedBox(height: 16),
                const Text('Assign to Project (Dropdown Placeholder)'),
                const SizedBox(height: 16),
                const Text('Due Date (Placeholder)'),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
