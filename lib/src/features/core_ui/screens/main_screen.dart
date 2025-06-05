import 'package:flutter/material.dart';
import 'package:study/src/features/add_item/widgets/add_options_modal_sheet.dart';
import 'package:study/src/features/projects/screens/projects_screen.dart';
import 'package:study/src/features/daily_study_planner/screens/daily_study_planner_screen.dart';
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
    const DailyStudyPlannerScreen(),
    const TasksScreen(),
    const StatsScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddOptionsModalSheet(),
      );
      // Do not change _currentIndex for Add button
      return;
    }
    // Adjust index for screens since Add is not in _screens
    setState(() {
      _currentIndex = index > 2 ? index - 1 : index;
    });
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
        currentIndex: _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_outlined),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Planner',
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
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
