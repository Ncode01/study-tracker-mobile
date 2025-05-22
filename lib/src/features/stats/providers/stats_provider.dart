import 'package:flutter/material.dart';
import 'package:study/src/services/database_helper.dart';

enum StatsPeriod { Week, Month, Year }

class StatsProvider extends ChangeNotifier {
  Map<String, int> _timePerDay = {};
  Map<String, int> _timePerProject = {};
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );
  StatsPeriod _selectedPeriod = StatsPeriod.Week;

  Map<String, int> get timePerDay => _timePerDay;
  Map<String, int> get timePerProject => _timePerProject;
  StatsPeriod get selectedPeriod => _selectedPeriod;
  DateTimeRange get selectedDateRange => _selectedDateRange;

  StatsProvider({DatabaseHelper? dbHelper}) {
    fetchStatsData();
  }

  void setSelectedPeriod(StatsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case StatsPeriod.Week:
        _selectedDateRange = DateTimeRange(
          start: now.subtract(Duration(days: now.weekday - 1)),
          end: now,
        );
        break;
      case StatsPeriod.Month:
        _selectedDateRange = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
        break;
      case StatsPeriod.Year:
        _selectedDateRange = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
        break;
    }
    _selectedPeriod = period;
    fetchStatsData();
    notifyListeners();
  }

  Future<void> fetchStatsData() async {
    _timePerDay = await DatabaseHelper.instance.getAggregatedTimePerDay(
      _selectedDateRange.start,
      _selectedDateRange.end,
    );
    _timePerProject = await DatabaseHelper.instance.getAggregatedTimePerProject(
      _selectedDateRange.start,
      _selectedDateRange.end,
    );
    notifyListeners();
  }
}
