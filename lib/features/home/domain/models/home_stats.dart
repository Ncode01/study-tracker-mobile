class HomeStats {
  const HomeStats({
    required this.totalProductive,
    required this.streak,
    required this.next,
  });

  final String totalProductive;
  final String streak;
  final String next;

  HomeStats copyWith({
    String? totalProductive,
    String? streak,
    String? next,
  }) {
    return HomeStats(
      totalProductive: totalProductive ?? this.totalProductive,
      streak: streak ?? this.streak,
      next: next ?? this.next,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'totalProductive': totalProductive,
      'streak': streak,
      'next': next,
    };
  }

  factory HomeStats.fromMap(Map<String, Object?> map) {
    return HomeStats(
      totalProductive: map['totalProductive'] as String? ?? '0m',
      streak: map['streak'] as String? ?? '0m',
      next: map['next'] as String? ?? '-',
    );
  }
}
