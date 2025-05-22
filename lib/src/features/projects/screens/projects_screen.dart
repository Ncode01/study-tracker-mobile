import 'package:flutter/material.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/projects/widgets/date_scroller.dart';
import 'package:study/src/features/projects/widgets/project_list_item.dart';
import 'package:study/src/models/project_model.dart';

/// The main screen displaying all projects with filters and a date scroller.
class ProjectsScreen extends StatelessWidget {
  /// Creates a [ProjectsScreen] widget.
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Project> dummyProjects = [
      Project(
        id: '1',
        name: 'O/L',
        color: AppColors.primaryColor,
        loggedMinutes: 0,
        goalMinutes: 360,
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
      Project(
        id: '2',
        name: 'Physics',
        color: Colors.green,
        loggedMinutes: 0,
        goalMinutes: 120,
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      Project(
        id: '3',
        name: 'NOI',
        color: Colors.redAccent,
        loggedMinutes: 0,
        goalMinutes: 60,
      ),
    ];
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
                  label: const Text('All (3)'),
                  selected: true,
                  onSelected: (_) {},
                  selectedColor: AppColors.primaryColor,
                  labelStyle: const TextStyle(color: Colors.white),
                  backgroundColor: AppColors.cardColor,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Due (3)'),
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
                  '9h 00m',
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
            child: ListView.builder(
              itemCount: dummyProjects.length,
              itemBuilder: (context, index) {
                return ProjectListItem(project: dummyProjects[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
