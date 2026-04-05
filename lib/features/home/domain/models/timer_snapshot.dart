class TimerSnapshot {
  const TimerSnapshot({
    required this.elapsed,
    required this.target,
    required this.isRunning,
    this.sessionStartTime,
    this.sessionStartElapsed = Duration.zero,
  });

  final Duration elapsed;
  final Duration target;
  final bool isRunning;
  final DateTime? sessionStartTime;
  final Duration sessionStartElapsed;

  TimerSnapshot copyWith({
    Duration? elapsed,
    Duration? target,
    bool? isRunning,
    DateTime? sessionStartTime,
    bool clearSessionStartTime = false,
    Duration? sessionStartElapsed,
  }) {
    return TimerSnapshot(
      elapsed: elapsed ?? this.elapsed,
      target: target ?? this.target,
      isRunning: isRunning ?? this.isRunning,
      sessionStartTime: clearSessionStartTime
          ? null
          : sessionStartTime ?? this.sessionStartTime,
      sessionStartElapsed: sessionStartElapsed ?? this.sessionStartElapsed,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'elapsedSeconds': elapsed.inSeconds,
      'targetSeconds': target.inSeconds,
      'isRunning': isRunning ? 1 : 0,
      'sessionStartTimeMs': sessionStartTime?.millisecondsSinceEpoch,
      'sessionStartElapsedSeconds': sessionStartElapsed.inSeconds,
    };
  }

  factory TimerSnapshot.fromMap(Map<String, Object?> map) {
    return TimerSnapshot(
      elapsed: Duration(seconds: map['elapsedSeconds'] as int? ?? 0),
      target: Duration(seconds: map['targetSeconds'] as int? ?? 0),
      isRunning: (map['isRunning'] as int? ?? 0) == 1,
      sessionStartTime: _toDateTime(map['sessionStartTimeMs']),
      sessionStartElapsed:
          Duration(seconds: map['sessionStartElapsedSeconds'] as int? ?? 0),
    );
  }

  static DateTime? _toDateTime(Object? value) {
    final int? milliseconds = value as int?;
    if (milliseconds == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}
