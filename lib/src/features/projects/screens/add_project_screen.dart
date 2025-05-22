import 'package:flutter/material.dart';

/// Placeholder form screen for creating a new project.
class AddProjectScreen extends StatelessWidget {
  /// Creates an [AddProjectScreen].
  const AddProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Project')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Project Name (TextField Placeholder)'),
                const SizedBox(height: 16),
                const Text('Goal Time (Input Placeholder)'),
                const SizedBox(height: 16),
                const Text('Color Picker (Placeholder)'),
                const SizedBox(height: 16),
                const Text('Due Date (Placeholder)'),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Project'),
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
