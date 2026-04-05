class DailyStudyStat {
  const DailyStudyStat({
    required this.day,
    required this.totalMinutes,
    required this.productiveMinutes,
  });

  final DateTime day;
  final int totalMinutes;
  final int productiveMinutes;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'day': DateTime(day.year, day.month, day.day).toIso8601String(),
      'totalMinutes': totalMinutes,
      'productiveMinutes': productiveMinutes,
    };
  }

  factory DailyStudyStat.fromMap(Map<String, Object?> map) {
    return DailyStudyStat(
      day: DateTime.parse(map['day'] as String),
      totalMinutes: map['totalMinutes'] as int? ?? 0,
      productiveMinutes: map['productiveMinutes'] as int? ?? 0,
    );
  }
}
