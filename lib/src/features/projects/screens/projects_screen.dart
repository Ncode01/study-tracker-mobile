import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/projects/widgets/date_scroller.dart';
import 'package:study/src/features/projects/widgets/project_list_item.dart';
import 'package:study/src/features/projects/providers/project_provider.dart';

/// The main screen displaying all projects with filters and a date scroller.
class ProjectsScreen extends StatelessWidget {
  /// Creates a [ProjectsScreen] widget.
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'All projects',
              style: TextStyle(color: AppColors.textColor),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.textColor,
            ),
            onPressed: () {},
            tooltip: 'Premium',
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textColor,
            ),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HorizontalDateScroller(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (_) {},
                  selectedColor: AppColors.primaryColor,
                  labelStyle: const TextStyle(color: Colors.white),
                  backgroundColor: AppColors.cardColor,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Due'),
                  selected: false,
                  onSelected: (_) {},
                  selectedColor: AppColors.primaryColor,
                  labelStyle: const TextStyle(color: Colors.white),
                  backgroundColor: AppColors.cardColor,
                ),
                const Spacer(),
                Text(
                  'Remaining',
                  style: TextStyle(color: AppColors.secondaryTextColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '', // Placeholder for remaining time
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                final projects = provider.projects;
                if (projects.isEmpty) {
                  return Center(
                    child: Text(
                      'No projects found',
                      style: TextStyle(color: AppColors.secondaryTextColor),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return ProjectListItem(project: projects[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
