import 'package:flutter/material.dart';
import 'package:study/src/features/add_item/screens/add_item_screen.dart';
import 'package:study/src/features/projects/screens/projects_screen.dart';
import 'package:study/src/features/sessions/screens/sessions_screen.dart';
import 'package:study/src/features/stats/screens/stats_screen.dart';
import 'package:study/src/features/tasks/screens/tasks_screen.dart';

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
    const AddItemScreen(), // Placeholder for Add functionality
    const TasksScreen(),
    const StatsScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Handle "Add" button tap - for now, just print or navigate to a placeholder
      print("Add button tapped");
      // You could also navigate to a modal or a different screen for adding items.
      // For this example, we'll switch to the AddItemScreen placeholder.
      setState(() {
        _currentIndex = index;
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
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
            icon: Icon(Icons.folder_copy_outlined),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36), // Prominent Add button
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
