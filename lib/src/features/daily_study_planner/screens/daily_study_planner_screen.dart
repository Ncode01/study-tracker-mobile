import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/features/daily_study_planner/widgets/study_plan_entry_list_item.dart';
import 'package:study/src/features/daily_study_planner/widgets/daily_study_overview.dart';
import 'package:study/src/features/daily_study_planner/widgets/study_plan_calendar.dart';

/// Main screen for the Daily Study Planner feature.
///
/// Displays a calendar date picker, daily overview stats, and list of
/// study plan entries for the selected date.
class DailyStudyPlannerScreen extends StatefulWidget {
  /// Optional initial date to display
  final DateTime? initialDate;

  /// Creates a [DailyStudyPlannerScreen].
  const DailyStudyPlannerScreen({super.key, this.initialDate});

  @override
  State<DailyStudyPlannerScreen> createState() =>
      _DailyStudyPlannerScreenState();
}

class _DailyStudyPlannerScreenState extends State<DailyStudyPlannerScreen> {
  late DateTime _selectedDate;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _pageController = PageController();

    // Load data for current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyPlanProvider>().refreshEntriesForDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    context.read<StudyPlanProvider>().refreshEntriesForDate(newDate);
  }

  Future<void> _addNewEntry() async {
    final result = await Navigator.of(context).pushNamed<bool>(
      '/study-planner/add',
      arguments: {'initialDate': _selectedDate},
    );

    if (result == true) {
      // Refresh entries after adding a new one
      context.read<StudyPlanProvider>().refreshEntriesForDate(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Daily Study Planner'),
      actions: [
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () => _onDateChanged(DateTime.now()),
          tooltip: 'Go to Today',
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: _showFullCalendar,
          tooltip: 'Calendar View',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<StudyPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider);
        }

        return _buildSuccessState(provider);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }

  Widget _buildErrorState(StudyPlanProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            provider.error!,
            style: const TextStyle(color: AppColors.textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              provider.refreshEntriesForDate(_selectedDate);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(StudyPlanProvider provider) {
    final dateEntries =
        provider.studyPlanEntries.where((entry) {
          return entry.date.year == _selectedDate.year &&
              entry.date.month == _selectedDate.month &&
              entry.date.day == _selectedDate.day;
        }).toList();

    return Column(
      children: [
        // Calendar navigation
        StudyPlanCalendar(
          selectedDate: _selectedDate,
          onDateChanged: _onDateChanged,
        ),

        // Daily overview stats
        DailyStudyOverview(selectedDate: _selectedDate, entries: dateEntries),

        // List of entries
        Expanded(child: _buildEntriesList(dateEntries)),
      ],
    );
  }

  Widget _buildEntriesList(List entries) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    // Sort entries by start time, then by creation time
    entries.sort((a, b) {
      if (a.startTime != null && b.startTime != null) {
        return a.startTime!.compareTo(b.startTime!);
      } else if (a.startTime != null) {
        return -1; // Timed entries come first
      } else if (b.startTime != null) {
        return 1;
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return StudyPlanEntryListItem(
          entry: entries[index],
          onTap: () => _editEntry(entries[index]),
          onToggleCompleted: () => _toggleEntryCompleted(entries[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final formatter = DateFormat('EEEE, MMMM d');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppColors.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No study plans for',
            style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 16),
          ),
          Text(
            formatter.format(_selectedDate),
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addNewEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add Study Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _addNewEntry,
      backgroundColor: AppColors.primaryColor,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _editEntry(entry) async {
    final result = await Navigator.of(context).pushNamed<bool>(
      '/study-planner/add',
      arguments: {'initialDate': _selectedDate, 'editingEntry': entry},
    );

    if (result == true) {
      // Refresh entries after editing
      context.read<StudyPlanProvider>().refreshEntriesForDate(_selectedDate);
    }
  }

  Future<void> _toggleEntryCompleted(entry) async {
    await context.read<StudyPlanProvider>().toggleEntryCompleted(entry);
  }

  Future<void> _showFullCalendar() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.primaryColor,
                surface: AppColors.cardColor,
                onSurface: AppColors.textColor,
              ),
            ),
            child: child!,
          ),
    );

    if (selectedDate != null) {
      _onDateChanged(selectedDate);
    }
  }
}
