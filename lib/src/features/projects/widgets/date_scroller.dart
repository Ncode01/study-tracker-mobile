import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/src/constants/app_colors.dart';

/// A horizontal date scroller widget for the Projects screen.
class HorizontalDateScroller extends StatefulWidget {
  /// Creates a [HorizontalDateScroller] widget.
  const HorizontalDateScroller({super.key});

  @override
  State<HorizontalDateScroller> createState() => _HorizontalDateScrollerState();
}

class _HorizontalDateScrollerState extends State<HorizontalDateScroller> {
  late PageController _pageController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Start from today with some buffer for past dates
    _pageController = PageController(initialPage: 365);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            // Calculate date based on page offset from today
            _selectedDate = DateTime.now().add(Duration(days: page - 365));
          });
        },
        itemBuilder: (context, page) {
          // Generate dates with today at page 365
          final date = DateTime.now().add(Duration(days: page - 365));
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return _buildDateItem(date, isSelected, isToday);
        },
      ),
    );
  }

  Widget _buildDateItem(DateTime date, bool isSelected, bool isToday) {
    final dayFormatter = DateFormat('d');
    final monthFormatter = DateFormat('MMM');

    Color backgroundColor;
    Color textColor;
    Color dayTextColor;

    if (isSelected) {
      backgroundColor = AppColors.primaryColor;
      textColor = Colors.white;
      dayTextColor = Colors.white;
    } else if (isToday) {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      textColor = AppColors.primaryColor;
      dayTextColor = AppColors.primaryColor;
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.textColor;
      dayTextColor = AppColors.secondaryTextColor!;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
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
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              monthFormatter.format(date),
              style: TextStyle(
                color: dayTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
