import 'package:flutter/material.dart';
import 'package:study/src/constants/app_colors.dart';

/// A horizontally scrolling date selector for the Projects screen.
class HorizontalDateScroller extends StatelessWidget {
  /// Creates a [HorizontalDateScroller].
  const HorizontalDateScroller({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_DateScrollerItemData> items = const [
      _DateScrollerItemData(day: 'Sat', date: '17', time: '5:54'),
      _DateScrollerItemData(day: 'Sun', date: '18', time: '1:24'),
      _DateScrollerItemData(day: 'Mon', date: '19'),
      _DateScrollerItemData(day: 'Tue', date: '20', time: '5:42'),
      _DateScrollerItemData(day: 'Wed', date: '21', time: '1:13'),
      _DateScrollerItemData(day: 'Thu', date: '22', selected: true),
    ];
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return DateScrollerItem(
            day: item.day,
            date: item.date,
            time: item.time,
            selected: item.selected,
          );
        },
      ),
    );
  }
}

/// Data for a single date scroller item.
class _DateScrollerItemData {
  final String day;
  final String date;
  final String? time;
  final bool selected;
  const _DateScrollerItemData({
    required this.day,
    required this.date,
    this.time,
    this.selected = false,
  });
}

/// A widget representing a single date in the horizontal date scroller.
class DateScrollerItem extends StatelessWidget {
  /// Day abbreviation (e.g., "Sat").
  final String day;

  /// Date number (e.g., "17").
  final String date;

  /// Optional time worked (e.g., "5:54").
  final String? time;

  /// Whether this item is selected.
  final bool selected;

  /// Creates a [DateScrollerItem].
  const DateScrollerItem({
    super.key,
    required this.day,
    required this.date,
    this.time,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        selected ? AppColors.primaryColor : AppColors.cardColor;
    final Color textColor = selected ? Colors.white : AppColors.textColor;
    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(color: textColor, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (time != null) ...[
            const SizedBox(height: 4),
            Text(
              time!,
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
