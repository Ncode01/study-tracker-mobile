import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/journey_map_colors.dart';
import '../widgets/itinerary_list_item.dart';
import '../widgets/hand_drawn_border_card.dart';
import '../../daily_study_planner/providers/study_plan_provider.dart';
import '../../sessions/providers/session_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../models/study_plan_entry_model.dart';
import '../../study_timer/screens/study_timer_screen.dart';

/// The main Journey Map screen that displays the user's learning journey.
/// This is a dynamic implementation that connects to live study plan data.
class JourneyMapScreen extends StatefulWidget {
  const JourneyMapScreen({super.key});

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Use a post-frame callback to safely access providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use context.read for one-time calls in initState/callbacks
      // Fetch initial data for "Today's Quest" tab
      context.read<StudyPlanProvider>().refreshEntriesForDate(DateTime.now());
      // Fetch any data needed for the main "Journey Map" or "Achievements" tabs
      context.read<SessionProvider>().fetchSessions();
      context.read<TaskProvider>().fetchTasks();
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JourneyMapColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: JourneyMapColors.primaryText,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Journey Map',
          style: TextStyle(
            fontFamily: 'Caveat',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: JourneyMapColors.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.timer,
              color: JourneyMapColors.primaryText,
              size: 26,
            ),
            tooltip: 'Study Timer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const StudyTimerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelColor: JourneyMapColors.primaryText,
              unselectedLabelColor: JourneyMapColors.tabInactive,
              labelStyle: const TextStyle(
                fontFamily: 'Caveat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Caveat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: JourneyMapColors.tabIndicator,
                  width: 4.0,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              dividerHeight: 0,
              tabs: const [
                Tab(text: "Today's Quest"),
                Tab(text: 'Journey Progress'),
                Tab(text: 'Achievements'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Content Area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDayView(),
                _buildJourneyProgressView(),
                _buildAchievementsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Progress Summary Cards with Dynamic Data
          Consumer2<SessionProvider, StudyPlanProvider>(
            builder: (context, sessionProvider, studyPlanProvider, child) {
              final today = DateTime.now();

              // Calculate today's sessions
              final todaySessions =
                  sessionProvider.sessions.where((session) {
                    return session.startTime.year == today.year &&
                        session.startTime.month == today.month &&
                        session.startTime.day == today.day;
                  }).toList();

              // Calculate total study hours for today
              final totalMinutes = todaySessions.fold<int>(
                0,
                (sum, session) => sum + session.durationMinutes,
              );
              final hours = totalMinutes ~/ 60;
              final minutes = totalMinutes % 60;

              // Get today's entries
              final todayEntries = studyPlanProvider.getEntriesForDate(today);
              final completedQuests =
                  todayEntries.where((entry) => entry.isCompleted).length;

              return Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        title: 'Study Hours',
                        value: '${hours}h ${minutes}m',
                        subtitle: 'Today',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProgressCard(
                        title: 'Sessions',
                        value: '${todaySessions.length}',
                        subtitle: 'Completed',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProgressCard(
                        title: 'Quests',
                        value: '$completedQuests/${todayEntries.length}',
                        subtitle: 'Completed',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Map Visualization Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: JourneyMapColors.cardBackground,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: const Color(0xFFa0aec0).withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              height: 200,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 60,
                      color: JourneyMapColors.secondaryText,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Journey Map Visualization',
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: JourneyMapColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Today's Itinerary Section - Dynamic
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Itinerary",
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: JourneyMapColors.primaryText,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dynamic Itinerary Items
          Consumer<StudyPlanProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.error != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: JourneyMapColors.secondaryText,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load today\'s quests',
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 18,
                          color: JourneyMapColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final todayEntries = provider.getEntriesForDate(DateTime.now());

              if (todayEntries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: JourneyMapColors.secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No quests for today!',
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: JourneyMapColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add one to start your learning journey',
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 18,
                          color: JourneyMapColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort entries by start time, then by creation time
              final sortedEntries = List<StudyPlanEntry>.from(todayEntries);
              sortedEntries.sort((a, b) {
                if (a.startTime != null && b.startTime != null) {
                  return a.startTime!.compareTo(b.startTime!);
                } else if (a.startTime != null) {
                  return -1; // Timed entries come first
                } else if (b.startTime != null) {
                  return 1; // Timed entries come first
                } else {
                  return a.createdAt.compareTo(b.createdAt);
                }
              });

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  final entry = sortedEntries[index];
                  return ItineraryListItem(
                    entry: entry,
                    onTap: () => _editQuest(context, entry),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 32),

          // Add New Stop Button - Now Functional
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _addNewQuest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JourneyMapColors.buttonBackground,
                  foregroundColor: JourneyMapColors.buttonText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(
                      color: JourneyMapColors.buttonBorder,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Add New Stop',
                      style: const TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Helper method to build progress summary cards
  Widget _buildProgressCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return HandDrawnBorderCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: JourneyMapColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: JourneyMapColors.primaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 12,
                color: JourneyMapColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to edit an existing quest
  void _editQuest(BuildContext context, StudyPlanEntry entry) {
    Navigator.pushNamed(
      context,
      '/study-planner/add',
      arguments: {'initialDate': entry.date, 'editingEntry': entry},
    ).then((_) {
      // Refresh data after returning from edit screen
      context.read<StudyPlanProvider>().refreshEntriesForDate(DateTime.now());
    });
  }

  /// Navigates to add a new quest for today
  void _addNewQuest(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/study-planner/add',
      arguments: {'initialDate': DateTime.now()},
    ).then((_) {
      // Refresh data after returning from add screen
      context.read<StudyPlanProvider>().refreshEntriesForDate(DateTime.now());
    });
  }

  /// Journey Progress placeholder view
  Widget _buildJourneyProgressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.timeline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Journey Progress',
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Achievements placeholder view
  Widget _buildAchievementsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Your Achievements',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Journey Stats',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
