class TimerSnapshot {
  const TimerSnapshot({DateTime? sessionStartTime, required this.elapsed})
    : _sessionStartTime = sessionStartTime;

  final DateTime? _sessionStartTime;
  final Duration elapsed;

  DateTime get sessionStartTime {
    final DateTime? saved = _sessionStartTime;
    if (saved != null) {
      return saved;
    }
    return DateTime.now().subtract(elapsed);
  }

  TimerSnapshot copyWith({DateTime? sessionStartTime, Duration? elapsed}) {
    return TimerSnapshot(
      sessionStartTime: sessionStartTime ?? _sessionStartTime,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sessionStartTimeMs': sessionStartTime.millisecondsSinceEpoch,
      'elapsedSeconds': elapsed.inSeconds,
    };
  }

  factory TimerSnapshot.fromMap(Map<String, Object?> map) {
    final DateTime now = DateTime.now();
    final DateTime? parsedSessionStart = _toDateTime(map['sessionStartTimeMs']);
    final Duration parsedElapsed = _toDuration(map['elapsedSeconds']);

    final DateTime sessionStartTime =
        parsedSessionStart ?? now.subtract(parsedElapsed);

    final Duration elapsed = now.difference(sessionStartTime);

    return TimerSnapshot(
      sessionStartTime: sessionStartTime,
      elapsed: elapsed.isNegative ? Duration.zero : elapsed,
    );
  }

  static DateTime? _toDateTime(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed);
      }
    }
    return null;
  }

  static Duration _toDuration(Object? value) {
    if (value is int) {
      return Duration(seconds: value);
    }
    if (value is num) {
      return Duration(seconds: value.toInt());
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) {
        return Duration(seconds: parsed);
      }
    }
    return Duration.zero;
  }
}
