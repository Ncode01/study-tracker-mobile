import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HubCountdown {
  const HubCountdown({
    required this.title,
    required this.daysRemaining,
    required this.accentColor,
  });

  final String title;
  final int daysRemaining;
  final Color accentColor;
}

class HubSession {
  const HubSession({
    required this.title,
    required this.timeLabel,
    required this.durationLabel,
  });

  final String title;
  final String timeLabel;
  final String durationLabel;
}

class HubSubject {
  const HubSubject({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.goalLabel,
    required this.progress,
    required this.sessions,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final String goalLabel;
  final double progress;
  final List<HubSession> sessions;
}

class HubViewState {
  const HubViewState({
    required this.countdowns,
    required this.subjects,
    required this.expandedSubjectId,
  });

  final List<HubCountdown> countdowns;
  final List<HubSubject> subjects;
  final String? expandedSubjectId;

  HubViewState copyWith({
    List<HubCountdown>? countdowns,
    List<HubSubject>? subjects,
    String? expandedSubjectId,
  }) {
    return HubViewState(
      countdowns: countdowns ?? this.countdowns,
      subjects: subjects ?? this.subjects,
      expandedSubjectId: expandedSubjectId ?? this.expandedSubjectId,
    );
  }
}

class HubViewNotifier extends Notifier<HubViewState> {
  @override
  HubViewState build() {
    return HubViewState(
      countdowns: const <HubCountdown>[
        HubCountdown(
          title: 'Physics',
          daysRemaining: 12,
          accentColor: Color(0xFF3B82F6),
        ),
        HubCountdown(
          title: 'Chem',
          daysRemaining: 5,
          accentColor: Color(0xFF22C55E),
        ),
        HubCountdown(
          title: 'Maths',
          daysRemaining: 20,
          accentColor: Color(0xFFF43F5E),
        ),
      ],
      subjects: const <HubSubject>[
        HubSubject(
          id: 'physics',
          title: 'Physics',
          icon: Icons.bolt_outlined,
          accentColor: Color(0xFF3B82F6),
          goalLabel: 'Daily goal 2h 30m',
          progress: 0.72,
          sessions: <HubSession>[
            HubSession(
              title: 'Vectors recap',
              timeLabel: 'Today · 08:10',
              durationLabel: '42m',
            ),
            HubSession(
              title: 'Paper 2 corrections',
              timeLabel: 'Yesterday · 19:20',
              durationLabel: '55m',
            ),
          ],
        ),
        HubSubject(
          id: 'chemistry',
          title: 'Chemistry',
          icon: Icons.science_outlined,
          accentColor: Color(0xFF22C55E),
          goalLabel: 'Daily goal 1h 45m',
          progress: 0.56,
          sessions: <HubSession>[
            HubSession(
              title: 'Organic mechanisms',
              timeLabel: 'Today · 11:45',
              durationLabel: '35m',
            ),
            HubSession(
              title: 'Practical prep',
              timeLabel: 'Yesterday · 16:05',
              durationLabel: '48m',
            ),
          ],
        ),
        HubSubject(
          id: 'maths',
          title: 'Maths',
          icon: Icons.calculate_outlined,
          accentColor: Color(0xFFF43F5E),
          goalLabel: 'Daily goal 3h 00m',
          progress: 0.64,
          sessions: <HubSession>[
            HubSession(
              title: 'Functions sprint',
              timeLabel: 'Today · 13:15',
              durationLabel: '1h 05m',
            ),
            HubSession(
              title: 'Series questions',
              timeLabel: 'Yesterday · 18:40',
              durationLabel: '38m',
            ),
          ],
        ),
      ],
      expandedSubjectId: 'physics',
    );
  }

  void toggleSubjectExpansion(String subjectId) {
    state = state.copyWith(
      expandedSubjectId:
          state.expandedSubjectId == subjectId ? null : subjectId,
    );
  }
}
