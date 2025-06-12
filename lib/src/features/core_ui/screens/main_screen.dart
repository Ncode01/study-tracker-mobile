import 'package:flutter/material.dart';
import 'package:study/src/features/projects/screens/projects_screen.dart';
import 'package:study/src/features/sessions/screens/sessions_screen.dart';
import 'package:study/src/features/tasks/screens/tasks_screen.dart';
import 'package:study/src/features/analytics/screens/detailed_analytics_screen.dart';

/// The main screen of the application, hosting the bottom navigation bar.
class MainScreen extends StatefulWidget {
  /// Creates a [MainScreen] widget.
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ProjectsScreen(),
    const SessionsScreen(),
    Container(), // Placeholder for FAB - this will be the middle item
    const TasksScreen(),
    const DetailedAnalyticsScreen(),
  ];
  void _onTabTapped(int index) {
    if (index == 2) {
      // Handle FAB tap - show modal
      _showAddOptionsModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showAddOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.folder_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Project',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/projects/add');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.event_note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Study Plan',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Task',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // Use IndexedStack to preserve state of screens
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
