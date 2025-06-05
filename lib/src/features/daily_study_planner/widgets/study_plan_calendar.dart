import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/src/constants/app_colors.dart';

/// A horizontal scrolling calendar widget for selecting dates in the study planner.
class StudyPlanCalendar extends StatefulWidget {
  /// The currently selected date.
  final DateTime selectedDate;

  /// Callback when a date is selected.
  final ValueChanged<DateTime> onDateChanged;

  /// Creates a [StudyPlanCalendar].
  const StudyPlanCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<StudyPlanCalendar> createState() => _StudyPlanCalendarState();
}

class _StudyPlanCalendarState extends State<StudyPlanCalendar> {
  late PageController _pageController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    _pageController = PageController(
      initialPage: _getInitialPage(),
      viewportFraction: 0.2, // Show 5 dates at once
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getInitialPage() {
    final today = DateTime.now();
    final selectedDate = widget.selectedDate;

    // Calculate days difference from today
    final difference = selectedDate.difference(today).inDays;
    return 50 + difference; // Start from middle of a large range
  }

  DateTime _getDateForPage(int page) {
    final today = DateTime.now();
    final daysDifference = page - 50; // 50 is our baseline (today)
    return today.add(Duration(days: daysDifference));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          final newDate = _getDateForPage(page);
          // Prevent infinite callbacks during tests
          if (mounted) {
            widget.onDateChanged(newDate);
          }
        },
        // Limit the number of pages to prevent infinite building in tests
        itemCount: 365, // One year worth of pages should be sufficient
        itemBuilder: (context, page) {
          final date = _getDateForPage(page);
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return _buildDateItem(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
          );
        },
      ),
    );
  }

  Widget _buildDateItem({
    required DateTime date,
    required bool isSelected,
    required bool isToday,
  }) {
    final dayFormatter = DateFormat('EEE');
    final dateFormatter = DateFormat('d');

    Color backgroundColor;
    Color textColor;
    Color dayTextColor;

    if (isSelected) {
      backgroundColor = AppColors.primaryColor;
      textColor = Colors.white;
      dayTextColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppColors.primaryColor.withOpacity(0.2);
      textColor = AppColors.primaryColor;
      dayTextColor = AppColors.primaryColor;
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.textColor;
      dayTextColor = AppColors.secondaryTextColor!;
    }
    return GestureDetector(
      onTap: () {
        if (mounted) {
          widget.onDateChanged(date);
          // Animate to selected page only if the controller is still attached
          final targetPage = _getPageForDate(date);
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 200), // Reduced duration
              curve: Curves.easeInOut,
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border:
              isToday && !isSelected
                  ? Border.all(color: AppColors.primaryColor, width: 1)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayFormatter.format(date),
              style: TextStyle(
                color: dayTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormatter.format(date),
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getPageForDate(DateTime date) {
    final today = DateTime.now();
    final difference = date.difference(today).inDays;
    return 50 + difference;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
