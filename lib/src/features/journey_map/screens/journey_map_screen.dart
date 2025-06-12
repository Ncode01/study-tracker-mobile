import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../widgets/itinerary_list_item.dart';
import '../../daily_study_planner/providers/study_plan_provider.dart';
import '../../sessions/providers/session_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../models/study_plan_entry_model.dart';
import 'package:study/src/features/timer/screens/study_timer_screen.dart';
import '../widgets/journey_day_tile.dart';
import '../widgets/journey_path_painter.dart';
import '../../analytics/widgets/horizontal_averages_widget.dart';

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
      backgroundColor: appTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appTheme.appBarTheme.iconTheme?.color,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Journey Map', style: appTheme.appBarTheme.titleTextStyle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer, size: 26),
            tooltip: 'Study Timer',
            onPressed: () {
              final project =
                  Provider.of<ProjectProvider>(
                    context,
                    listen: false,
                  ).projects.first;
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return StudyTimerScreen(project: project);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: appTheme.scaffoldBackgroundColor,
          // Optionally add pencil-texture background here if using PNG
        ),
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: appTheme.textTheme.titleLarge?.color,
                unselectedLabelColor: appTheme.textTheme.bodyMedium?.color
                    ?.withAlpha((0.5 * 255).round()),
                labelStyle: appTheme.textTheme.titleMedium,
                unselectedLabelStyle: appTheme.textTheme.titleMedium,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: appTheme.primaryColor,
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
                color: appTheme.cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: const Color(0xFFa0aec0).withAlpha((0.6 * 255).round()),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
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
                      color: appTheme.secondaryHeaderColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Journey Map Visualization',
                      style: appTheme.textTheme.titleMedium?.copyWith(
                        color: appTheme.secondaryHeaderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Study Averages Section
          const HorizontalAveragesWidget(),

          const SizedBox(height: 24),

          // Today's Itinerary Section - Dynamic
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Itinerary",
                style: appTheme.textTheme.headlineMedium?.copyWith(
                  color: appTheme.primaryColor,
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
                        color: appTheme.secondaryHeaderColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load today\'s quests',
                        style: appTheme.textTheme.titleMedium?.copyWith(
                          color: appTheme.secondaryHeaderColor,
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
                        color: appTheme.secondaryHeaderColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No quests for today!',
                        style: appTheme.textTheme.headlineSmall?.copyWith(
                          color: appTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add one to start your learning journey',
                        style: appTheme.textTheme.bodyMedium?.copyWith(
                          color: appTheme.secondaryHeaderColor,
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
                  backgroundColor: appTheme.primaryColor,
                  foregroundColor: appTheme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: appTheme.primaryColor, width: 2.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 28),
                    const SizedBox(width: 12),
                    Text('Add New Stop', style: appTheme.textTheme.titleMedium),
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
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFa0aec0).withAlpha((0.6 * 255).round()),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: appTheme.textTheme.bodyMedium?.copyWith(
                color: appTheme.secondaryHeaderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: appTheme.textTheme.headlineSmall?.copyWith(
                color: appTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: appTheme.textTheme.bodySmall?.copyWith(
                color: appTheme.secondaryHeaderColor,
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
    return Consumer2<SessionProvider, StudyPlanProvider>(
      builder: (context, sessionProvider, studyPlanProvider, child) {
        final isLoading =
            sessionProvider.sessions.isEmpty && studyPlanProvider.isLoading;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (sessionProvider.journeyDays.isEmpty) {
          return Center(
            child: Text(
              'No journey data yet!',
              style: appTheme.textTheme.titleMedium?.copyWith(
                color: appTheme.secondaryHeaderColor,
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: JourneyPathPainter()),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 16,
                    ),
                    itemCount: sessionProvider.journeyDays.length,
                    itemBuilder: (context, index) {
                      return JourneyDayTile(
                        journeyDay: sessionProvider.journeyDays[index],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24,
              ),
              child: Column(
                children: [
                  Text(
                    "You've journeyed for " +
                        sessionProvider.consecutiveDays.toString() +
                        " consecutive days...",
                    style: appTheme.textTheme.titleMedium?.copyWith(
                      color: appTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appTheme.primaryColor,
                        foregroundColor: appTheme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // Navigate to StudyTimerScreen or Today's Quest tab
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) {
                              final project =
                                  Provider.of<ProjectProvider>(
                                    context,
                                    listen: false,
                                  ).projects.first;
                              return StudyTimerScreen(project: project);
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Continue Your Journey!',
                        style: appTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Achievements placeholder view
  Widget _buildAchievementsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Achievements', style: appTheme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Journey Stats', style: appTheme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
