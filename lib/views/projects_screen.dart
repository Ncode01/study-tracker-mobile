import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/project_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/timer_provider.dart';
import 'package:bytelearn_study_tracker/models/project.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search projects...',
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                )
                : const Text('My Projects'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'name_asc':
                  Provider.of<ProjectProvider>(
                    context,
                    listen: false,
                  ).sortProjects(sortBy: ProjectSortOption.nameAsc);
                  break;
                case 'name_desc':
                  Provider.of<ProjectProvider>(
                    context,
                    listen: false,
                  ).sortProjects(sortBy: ProjectSortOption.nameDesc);
                  break;
                case 'date_newest':
                  Provider.of<ProjectProvider>(
                    context,
                    listen: false,
                  ).sortProjects(sortBy: ProjectSortOption.dateNewest);
                  break;
                case 'date_oldest':
                  Provider.of<ProjectProvider>(
                    context,
                    listen: false,
                  ).sortProjects(sortBy: ProjectSortOption.dateOldest);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'name_asc',
                    child: Text('Sort: Name (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: 'name_desc',
                    child: Text('Sort: Name (Z-A)'),
                  ),
                  const PopupMenuItem(
                    value: 'date_newest',
                    child: Text('Sort: Newest First'),
                  ),
                  const PopupMenuItem(
                    value: 'date_oldest',
                    child: Text('Sort: Oldest First'),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Archived')],
        ),
      ),
      body: Consumer2<ProjectProvider, TimerProvider>(
        builder: (context, projectProvider, timerProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Active Projects Tab
              _buildProjectsList(
                context,
                projectProvider.activeProjects
                    .where(
                      (project) =>
                          _searchQuery.isEmpty ||
                          project.title.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList(),
                timerProvider,
                isArchived: false,
              ),

              // Archived Projects Tab
              _buildProjectsList(
                context,
                projectProvider.archivedProjects
                    .where(
                      (project) =>
                          _searchQuery.isEmpty ||
                          project.title.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList(),
                timerProvider,
                isArchived: true,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-project');
        },
        tooltip: 'Create Project',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectsList(
    BuildContext context,
    List<Project> projects,
    TimerProvider timerProvider, {
    required bool isArchived,
  }) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isArchived ? Icons.archive : Icons.school,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isArchived ? 'No archived projects' : 'No active projects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (!isArchived)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create a Project'),
                onPressed: () {
                  Navigator.pushNamed(context, '/create-project');
                },
              ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final project = projects[index];
        final sessionCount = project.sessionIds.length;
        final totalTime = timerProvider.getTotalTimeForProject(project.id);

        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/project-details',
                arguments: {'projectId': project.id},
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (!isArchived)
                        IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.green,
                          ),
                          tooltip: 'Start Session',
                          onPressed: () {
                            // Start a timer session for this project
                            Provider.of<ProjectProvider>(
                              context,
                              listen: false,
                            ).selectProject(project.id);
                            Navigator.pushNamed(context, '/timer');
                          },
                        ),
                    ],
                  ),
                  if (project.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatistic(
                        context,
                        '${sessionCount}',
                        'Sessions',
                        Icons.timer_outlined,
                      ),
                      _buildStatistic(
                        context,
                        _formatDuration(totalTime),
                        'Total Time',
                        Icons.access_time,
                      ),
                      _buildStatistic(
                        context,
                        project.goalIds.length.toString(),
                        'Goals',
                        Icons.flag_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          isArchived ? Icons.unarchive : Icons.archive,
                          size: 18,
                        ),
                        label: Text(isArchived ? 'Unarchive' : 'Archive'),
                        onPressed: () {
                          _toggleArchiveStatus(context, project);
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit-project',
                            arguments: {'projectId': project.id},
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatistic(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _toggleArchiveStatus(BuildContext context, Project project) {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );

    if (project.isArchived) {
      projectProvider.unarchiveProject(project.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${project.title} unarchived'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              projectProvider.archiveProject(project.id);
            },
          ),
        ),
      );
    } else {
      projectProvider.archiveProject(project.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${project.title} archived'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              projectProvider.unarchiveProject(project.id);
            },
          ),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    return '${hours}h ${minutes}m';
  }
}
