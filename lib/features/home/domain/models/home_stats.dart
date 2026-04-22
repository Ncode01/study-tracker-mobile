class HomeStats {
  const HomeStats({
    required this.totalProductive,
    required this.streak,
    required this.next,
    required this.weeklyTargetProgress,
    required this.weeklyAverage,
    required this.planAdherence,
  });

  final String totalProductive;
  final String streak;
  final String next;
  final String weeklyTargetProgress;
  final String weeklyAverage;
  final String planAdherence;

  HomeStats copyWith({
    String? totalProductive,
    String? streak,
    String? next,
    String? weeklyTargetProgress,
    String? weeklyAverage,
    String? planAdherence,
  }) {
    return HomeStats(
      totalProductive: totalProductive ?? this.totalProductive,
      streak: streak ?? this.streak,
      next: next ?? this.next,
      weeklyTargetProgress: weeklyTargetProgress ?? this.weeklyTargetProgress,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      planAdherence: planAdherence ?? this.planAdherence,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'totalProductive': totalProductive,
      'streak': streak,
      'next': next,
      'weeklyTargetProgress': weeklyTargetProgress,
      'weeklyAverage': weeklyAverage,
      'planAdherence': planAdherence,
    };
  }

  factory HomeStats.fromMap(Map<String, Object?> map) {
    return HomeStats(
      totalProductive: map['totalProductive'] as String? ?? '0m',
      streak: map['streak'] as String? ?? '0m',
      next: map['next'] as String? ?? '-',
      weeklyTargetProgress:
          map['weeklyTargetProgress'] as String? ?? '0m / 10h',
      weeklyAverage: map['weeklyAverage'] as String? ?? '0m/day',
      planAdherence: map['planAdherence'] as String? ?? 'No plan yet',
    );
  }
}
