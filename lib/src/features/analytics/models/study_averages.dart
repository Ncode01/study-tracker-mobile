class StudyAverages {
  final PeriodAverage weekly;
  final PeriodAverage monthly;
  final PeriodAverage termly;
  final double dailyTarget;

  StudyAverages({
    required this.weekly,
    required this.monthly,
    required this.termly,
    required this.dailyTarget,
  });

  @override
  String toString() {
    return 'StudyAverages(weekly: $weekly, monthly: $monthly, termly: $termly, dailyTarget: $dailyTarget)';
  }
}

class PeriodAverage {
  final double averageHours; // Average hours per active study day
  final double totalHours; // Total hours in period
  final double targetHours; // Target hours for period
  final double progressPercentage; // Progress towards target (0-100)
  final int sessionCount; // Number of study sessions
  final int activeDays; // Number of days with study sessions
  final int streak; // Current consecutive study days

  PeriodAverage({
    required this.averageHours,
    required this.totalHours,
    required this.targetHours,
    required this.progressPercentage,
    required this.sessionCount,
    required this.activeDays,
    required this.streak,
  });

  // Helper getters for formatted display
  String get averageHoursFormatted => averageHours.toStringAsFixed(1);
  String get totalHoursFormatted => totalHours.toStringAsFixed(1);
  String get targetHoursFormatted => targetHours.toStringAsFixed(1);
  String get progressPercentageFormatted =>
      '${progressPercentage.toStringAsFixed(0)}%';

  // Status indicators
  bool get isOnTrack => progressPercentage >= 80.0;
  bool get isExceeding => progressPercentage > 100.0;
  bool get needsImprovement => progressPercentage < 60.0;

  String get statusText {
    if (isExceeding) return 'Exceeding target!';
    if (isOnTrack) return 'On track';
    if (needsImprovement) return 'Needs improvement';
    return 'Below target';
  }

  // Color coding for UI
  String get statusColor {
    if (isExceeding) return 'green';
    if (isOnTrack) return 'blue';
    if (needsImprovement) return 'red';
    return 'orange';
  }

  @override
  String toString() {
    return 'PeriodAverage(averageHours: $averageHours, totalHours: $totalHours, '
        'targetHours: $targetHours, progressPercentage: $progressPercentage, '
        'sessionCount: $sessionCount, activeDays: $activeDays, streak: $streak)';
  }
}
