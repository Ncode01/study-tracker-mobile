import 'package:flutter/foundation.dart';
import '../../../models/session_model.dart';
import '../../../services/database_helper.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/study_averages.dart';

class AnalyticsProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper;
  final SettingsProvider _settingsProvider;

  StudyAverages? _studyAverages;
  bool _isLoading = false;
  String? _error;
  AnalyticsProvider(this._databaseHelper, this._settingsProvider) {
    _settingsProvider.addListener(_onSettingsChanged);
    _loadAnalytics();
  }

  StudyAverages? get studyAverages => _studyAverages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _onSettingsChanged() {
    // Recalculate analytics when settings change
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final sessions = await _databaseHelper.getAllSessions();
      final dailyTarget = _settingsProvider.dailyStudyTarget;
      _studyAverages = _calculateStudyAverages(sessions, dailyTarget);
    } catch (e) {
      _error = 'Failed to load analytics: $e';
      debugPrint('Analytics error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAnalytics() async {
    await _loadAnalytics();
  }

  StudyAverages _calculateStudyAverages(
    List<Session> sessions,
    double dailyTarget,
  ) {
    // Filter sessions by time periods
    final weeklyData = _filterSessionsByDays(sessions, 7);
    final monthlyData = _filterSessionsByDays(sessions, 30);
    final termlyData = _filterSessionsByDays(sessions, 90); // ~3 months

    return StudyAverages(
      weekly: _calculatePeriodAverage(weeklyData, 7, dailyTarget),
      monthly: _calculatePeriodAverage(monthlyData, 30, dailyTarget),
      termly: _calculatePeriodAverage(termlyData, 90, dailyTarget),
      dailyTarget: dailyTarget,
    );
  }

  List<Session> _filterSessionsByDays(List<Session> sessions, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return sessions
        .where((session) => session.startTime.isAfter(cutoff))
        .toList();
  }

  PeriodAverage _calculatePeriodAverage(
    List<Session> sessions,
    int periodDays,
    double dailyTarget,
  ) {
    if (sessions.isEmpty) {
      return PeriodAverage(
        averageHours: 0.0,
        totalHours: 0.0,
        targetHours: dailyTarget * periodDays,
        progressPercentage: 0.0,
        sessionCount: 0,
        activeDays: 0,
        streak: 0,
      );
    } // Calculate totals
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
    final totalHours = totalMinutes / 60.0;
    final targetHours = dailyTarget * periodDays;

    // Calculate unique study days
    final uniqueDates = sessions.map((s) => _dateOnly(s.startTime)).toSet();
    final activeDays = uniqueDates.length;

    // Calculate average per day studied (not per calendar day)
    final averageHours = activeDays > 0 ? totalHours / activeDays : 0.0;

    // Calculate progress percentage
    final progressPercentage =
        targetHours > 0
            ? (totalHours / targetHours * 100).clamp(0.0, 100.0)
            : 0.0;

    // Calculate current streak
    final streak = _calculateStreak(sessions);

    return PeriodAverage(
      averageHours: averageHours,
      totalHours: totalHours,
      targetHours: targetHours,
      progressPercentage: progressPercentage,
      sessionCount: sessions.length,
      activeDays: activeDays,
      streak: streak,
    );
  }

  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  int _calculateStreak(List<Session> sessions) {
    if (sessions.isEmpty) return 0;

    // Group sessions by date
    final sessionsByDate = <DateTime, List<Session>>{};
    for (final session in sessions) {
      final date = _dateOnly(session.startTime);
      sessionsByDate.putIfAbsent(date, () => []).add(session);
    }

    // Sort dates in descending order
    final sortedDates =
        sessionsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    int streak = 0;
    DateTime expectedDate = _dateOnly(DateTime.now());

    for (final date in sortedDates) {
      if (date == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(expectedDate)) {
        // Gap in the streak
        break;
      }
    }

    return streak;
  }

  // Get detailed breakdown for a specific period
  Map<String, double> getSubjectBreakdown(int periodDays) {
    if (_studyAverages == null) return {};

    final sessions = _getSessionsForPeriod(periodDays);
    final breakdown = <String, double>{};
    for (final session in sessions) {
      final subject = session.projectName;
      final hours = session.durationMinutes / 60.0;
      breakdown[subject] = (breakdown[subject] ?? 0) + hours;
    }

    return breakdown;
  }

  List<Session> _getSessionsForPeriod(int days) {
    // This would typically fetch from database, but for now return empty
    // In a real implementation, you'd store the filtered sessions
    return [];
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
