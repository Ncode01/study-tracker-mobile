import 'package:flutter/material.dart';
import 'package:study/src/features/daily_study_planner/screens/daily_study_planner_screen.dart';
import 'package:study/src/features/goals/screens/study_goals_screen.dart';
import 'package:study/src/features/journey_map/screens/journey_map_screen.dart';
import 'package:study/src/features/study_timer/screens/study_timer_screen.dart';

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
    const DailyStudyPlannerScreen(),
    const StudyTimerScreen(),
    const StudyGoalsScreen(),
    const JourneyMapScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
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
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Journey',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
