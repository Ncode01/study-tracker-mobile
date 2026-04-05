import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/calendar_view_notifier.dart';

final calendarViewProvider =
    NotifierProvider<CalendarViewNotifier, CalendarViewState>(
  CalendarViewNotifier.new,
);

final selectedCalendarDayProvider = Provider<CalendarDay>((ref) {
  return ref.watch(
    calendarViewProvider.select((CalendarViewState state) => state.selectedDay),
  );
});

final calendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  return ref.watch(
    calendarViewProvider.select((CalendarViewState state) => state.days),
  );
});
