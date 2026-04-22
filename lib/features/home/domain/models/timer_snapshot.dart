enum PomodoroPhase { focus, shortBreak, longBreak }

class TimerSnapshot {
  const TimerSnapshot({
    required this.phase,
    required this.phaseDuration,
    required this.elapsed,
    required this.isRunning,
    required this.completedFocusSessions,
    this.runningSince,
  });

  final PomodoroPhase phase;
  final Duration phaseDuration;
  final Duration elapsed;
  final bool isRunning;
  final int completedFocusSessions;
  final DateTime? runningSince;

  bool get isBreak => phase != PomodoroPhase.focus;

  DateTime get sessionStartTime {
    final DateTime? runningAnchor = runningSince;
    if (runningAnchor != null) {
      return runningAnchor;
    }
    return DateTime.now().subtract(elapsed);
  }

  Duration elapsedAt(DateTime now) {
    if (!isRunning || runningSince == null) {
      return _normalizeDuration(elapsed);
    }

    final Duration delta = now.difference(runningSince!);
    return _normalizeDuration(
      elapsed + (delta.isNegative ? Duration.zero : delta),
    );
  }

  Duration remainingAt(DateTime now) {
    final Duration remaining = phaseDuration - elapsedAt(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isPhaseCompleteAt(DateTime now) {
    return elapsedAt(now) >= phaseDuration;
  }

  TimerSnapshot materializeAt(DateTime now) {
    return copyWith(
      elapsed: elapsedAt(now),
      runningSince: isRunning ? now : null,
    );
  }

  TimerSnapshot copyWith({
    PomodoroPhase? phase,
    Duration? phaseDuration,
    Duration? elapsed,
    bool? isRunning,
    int? completedFocusSessions,
    DateTime? runningSince,
    bool clearRunningSince = false,
  }) {
    return TimerSnapshot(
      phase: phase ?? this.phase,
      phaseDuration: _normalizePhaseDuration(
        phaseDuration ?? this.phaseDuration,
      ),
      elapsed: _normalizeDuration(elapsed ?? this.elapsed),
      isRunning: isRunning ?? this.isRunning,
      completedFocusSessions:
          completedFocusSessions ?? this.completedFocusSessions,
      runningSince:
          clearRunningSince ? null : (runningSince ?? this.runningSince),
    );
  }

  factory TimerSnapshot.idleFocus({
    required Duration focusDuration,
    int completedFocusSessions = 0,
  }) {
    return TimerSnapshot(
      phase: PomodoroPhase.focus,
      phaseDuration: _normalizePhaseDuration(focusDuration),
      elapsed: Duration.zero,
      isRunning: false,
      completedFocusSessions:
          completedFocusSessions < 0 ? 0 : completedFocusSessions,
      runningSince: null,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'phase': _phaseToStorage(phase),
      'phaseDurationSeconds': phaseDuration.inSeconds,
      'elapsedSeconds': elapsed.inSeconds,
      'isRunning': isRunning ? 1 : 0,
      'runningSinceMs': runningSince?.millisecondsSinceEpoch,
      'completedFocusSessions': completedFocusSessions,
    };
  }

  factory TimerSnapshot.fromMap(Map<String, Object?> map) {
    final String? phaseRaw = map['phase'] as String?;

    // Legacy fallback from the old always-running timer shape.
    if (phaseRaw == null && map.containsKey('sessionStartTimeMs')) {
      final Duration legacyElapsed = _toDuration(map['elapsedSeconds']);
      return TimerSnapshot(
        phase: PomodoroPhase.focus,
        phaseDuration: const Duration(minutes: 25),
        elapsed: _normalizeDuration(legacyElapsed),
        isRunning: false,
        completedFocusSessions: 0,
        runningSince: null,
      );
    }

    return TimerSnapshot(
      phase: _phaseFromStorage(phaseRaw),
      phaseDuration: _normalizePhaseDuration(
        _toDuration(map['phaseDurationSeconds']),
      ),
      elapsed: _normalizeDuration(_toDuration(map['elapsedSeconds'])),
      isRunning: _toBool(map['isRunning']),
      completedFocusSessions:
          _toInt(map['completedFocusSessions']) < 0
              ? 0
              : _toInt(map['completedFocusSessions']),
      runningSince: _toDateTime(map['runningSinceMs']),
    );
  }

  static String _phaseToStorage(PomodoroPhase phase) {
    return switch (phase) {
      PomodoroPhase.focus => 'focus',
      PomodoroPhase.shortBreak => 'short_break',
      PomodoroPhase.longBreak => 'long_break',
    };
  }

  static PomodoroPhase _phaseFromStorage(String? value) {
    return switch (value) {
      'short_break' => PomodoroPhase.shortBreak,
      'long_break' => PomodoroPhase.longBreak,
      _ => PomodoroPhase.focus,
    };
  }

  static Duration _normalizePhaseDuration(Duration value) {
    if (value <= Duration.zero) {
      return const Duration(minutes: 1);
    }
    return value;
  }

  static Duration _normalizeDuration(Duration value) {
    return value.isNegative ? Duration.zero : value;
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

  static bool _toBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value != 0;
    }
    if (value is num) {
      return value.toInt() != 0;
    }
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true';
    }
    return false;
  }

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
