import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.start,
    required this.duration,
    required this.accentColor,
    required this.note,
    this.isCurrent = false,
  });

  final String title;
  final DateTime start;
  final Duration duration;
  final Color accentColor;
  final String note;
  final bool isCurrent;
}

class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.label,
    required this.events,
    this.isToday = false,
  });

  final DateTime date;
  final String label;
  final List<CalendarEvent> events;
  final bool isToday;
}

class CalendarViewState {
  const CalendarViewState({
    required this.days,
    required this.selectedDayIndex,
  });

  final List<CalendarDay> days;
  final int selectedDayIndex;

  CalendarDay get selectedDay => days[selectedDayIndex];

  CalendarViewState copyWith({
    List<CalendarDay>? days,
    int? selectedDayIndex,
  }) {
    return CalendarViewState(
      days: days ?? this.days,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
    );
  }
}

class CalendarViewNotifier extends Notifier<CalendarViewState> {
  @override
  CalendarViewState build() {
    final DateTime today = DateTime(2026, 4, 12);

    final List<CalendarDay> days = <CalendarDay>[
      CalendarDay(
        date: today,
        label: 'Mon 12',
        isToday: true,
        events: <CalendarEvent>[
          CalendarEvent(
            title: 'Physics Paper Review',
            start: DateTime(2026, 4, 12, 8, 0),
            duration: const Duration(minutes: 75),
            accentColor: const Color(0xFF3B82F6),
            note: 'Library pod · past papers',
          ),
          CalendarEvent(
            title: 'Maths Drill',
            start: DateTime(2026, 4, 12, 11, 0),
            duration: const Duration(minutes: 60),
            accentColor: const Color(0xFFF43F5E),
            note: 'Differentiation set',
          ),
          CalendarEvent(
            title: 'Chemistry Lab Prep',
            start: DateTime(2026, 4, 12, 15, 0),
            duration: const Duration(minutes: 90),
            accentColor: const Color(0xFF22C55E),
            note: 'Mock practical',
            isCurrent: true,
          ),
        ],
      ),
      CalendarDay(
        date: DateTime(2026, 4, 13),
        label: 'Tue 13',
        events: <CalendarEvent>[
          CalendarEvent(
            title: 'Tutor Check-in',
            start: DateTime(2026, 4, 13, 9, 0),
            duration: const Duration(minutes: 45),
            accentColor: const Color(0xFF8554F8),
            note: 'Revision plan review',
          ),
          CalendarEvent(
            title: 'Focus Block',
            start: DateTime(2026, 4, 13, 13, 30),
            duration: const Duration(minutes: 120),
            accentColor: const Color(0xFF3B82F6),
            note: 'Physics + Maths',
          ),
        ],
      ),
      CalendarDay(
        date: DateTime(2026, 4, 14),
        label: 'Wed 14',
        events: <CalendarEvent>[
          CalendarEvent(
            title: 'Club Meeting',
            start: DateTime(2026, 4, 14, 16, 0),
            duration: const Duration(minutes: 50),
            accentColor: const Color(0xFFF59E0B),
            note: 'Robotics stand-up',
          ),
        ],
      ),
    ];

    return CalendarViewState(days: days, selectedDayIndex: 0);
  }

  void selectDay(int index) {
    state = state.copyWith(selectedDayIndex: index);
  }
}
