import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/project_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/timer_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/goal_provider.dart';
import 'package:bytelearn_study_tracker/models/project.dart';
import 'package:bytelearn_study_tracker/models/session.dart';
import 'package:bytelearn_study_tracker/models/goal.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ByteLearn Study Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildHomeContent(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/timer');
        },
        tooltip: 'Start Study Session',
        child: const Icon(Icons.timer),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, '/projects');
              break;
            case 2:
              Navigator.pushNamed(context, '/timer');
              break;
            case 3:
              Navigator.pushNamed(context, '/statistics');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Consumer3<ProjectProvider, TimerProvider, GoalProvider>(
      builder: (context, projectProvider, timerProvider, goalProvider, child) {
        final activeProjects = projectProvider.activeProjects;
        final recentSessions = timerProvider.sessions.take(5).toList();
        final upcomingGoals =
            goalProvider.goals
                .where((g) => !g.isCompleted && !g.isOverdue)
                .take(3)
                .toList();

        // Calculate today's study time
        final todaySessions = timerProvider.getSessionsForDate(DateTime.now());
        final todayStudyTime = todaySessions.fold(
          Duration.zero,
          (prev, session) => prev + session.duration,
        );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDailyProgressCard(
                context,
                todayStudyTime,
                todaySessions.length,
              ),
              const SizedBox(height: 20),

              // Today's sessions
              if (todaySessions.isNotEmpty) ...[
                _buildSectionHeader(context, 'Today\'s Sessions'),
                Card(
                  elevation: 2,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: todaySessions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final session = todaySessions[index];
                      final project = projectProvider.getProjectById(
                        session.projectId,
                      );

                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.access_time),
                        ),
                        title: Text(project?.title ?? 'Unknown Project'),
                        subtitle: Text(
                          session.notes.isNotEmpty ? session.notes : 'No notes',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              session.formattedDuration,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat.jm().format(session.startTime),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Active projects
              _buildSectionHeader(context, 'Current Projects'),
              if (activeProjects.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No active projects. Create one to get started!',
                    ),
                  ),
                )
              else
                Card(
                  elevation: 2,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        activeProjects.length > 3 ? 3 : activeProjects.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final project = activeProjects[index];
                      final sessionCount = project.sessionIds.length;
                      final totalTime = timerProvider.getTotalTimeForProject(
                        project.id,
                      );

                      return ListTile(
                        title: Text(project.title),
                        subtitle: Text(
                          '${sessionCount.toString()} sessions · ${_formatDuration(totalTime)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            projectProvider.selectProject(project.id);
                            Navigator.pushNamed(context, '/timer');
                          },
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/project-details',
                            arguments: {'projectId': project.id},
                          );
                        },
                      );
                    },
                  ),
                ),
              if (activeProjects.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/projects');
                      },
                      child: const Text('See all projects →'),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Upcoming goals
              _buildSectionHeader(context, 'Upcoming Goals'),
              if (upcomingGoals.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No upcoming goals. Create one to track your progress!',
                    ),
                  ),
                )
              else
                Card(
                  elevation: 2,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: upcomingGoals.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final goal = upcomingGoals[index];
                      final project =
                          goal.projectId != null
                              ? projectProvider.getProjectById(goal.projectId!)
                              : null;

                      return ListTile(
                        title: Text(goal.title),
                        subtitle: Text(
                          project != null
                              ? 'Project: ${project.title}'
                              : 'General Goal',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              goal.progressText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Due: ${DateFormat.MMMd().format(goal.deadline)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        leading: CircularProgressIndicator(
                          value: goal.progressPercentage,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      );
                    },
                  ),
                ),
              if (goalProvider.goals.length > upcomingGoals.length)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to goals page (via projects for now)
                        Navigator.pushNamed(context, '/projects');
                      },
                      child: const Text('See all goals →'),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Quick Actions
              _buildSectionHeader(context, 'Quick Actions'),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      title: 'New Project',
                      icon: Icons.add_box,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, '/create-project');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      title: 'New Goal',
                      icon: Icons.flag,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, '/create-goal');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      title: 'Start Timer',
                      icon: Icons.timer,
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/timer');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyProgressCard(
    BuildContext context,
    Duration todayStudyTime,
    int sessionCount,
  ) {
    final hours = todayStudyTime.inHours;
    final minutes = (todayStudyTime.inMinutes % 60);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMMd().format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${hours}h ${minutes}m',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Study Time',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Container(width: 1, height: 50, color: Colors.grey.shade300),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionCount.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Sessions',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                if (todayStudyTime.inMinutes > 0)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Session'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/timer');
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    return '${hours}h ${minutes}m';
  }
}
