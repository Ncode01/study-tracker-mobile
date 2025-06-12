import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/projects/screens/project_detail_screen.dart';

/// Wrapper widget that fetches a project by ID and displays ProjectDetailScreen
class ProjectDetailWrapper extends StatelessWidget {
  /// The ID of the project to display
  final String projectId;

  /// Creates a [ProjectDetailWrapper].
  const ProjectDetailWrapper({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        // Find the project by ID
        final project = projectProvider.projects.firstWhere(
          (p) => p.id == projectId,
          orElse:
              () => Project(
                id: projectId,
                name: 'Unknown Project',
                color: Colors.blue,
                goalMinutes: 60,
                loggedMinutes: 0,
                dueDate: null,
              ),
        );

        // If projects haven't been loaded yet, show loading
        if (projectProvider.projects.isEmpty) {
          // Trigger loading
          WidgetsBinding.instance.addPostFrameCallback((_) {
            projectProvider.fetchProjects();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if project was not found
        if (project.name == 'Unknown Project' &&
            projectProvider.projects.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Project Not Found',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Project ID: $projectId',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return ProjectDetailScreen(project: project);
      },
    );
  }
}
