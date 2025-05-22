import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/sessions/widgets/session_list_item.dart';
import 'package:study/src/utils/formatters.dart';

/// Placeholder screen for Sessions.
class SessionsScreen extends StatefulWidget {
  /// Creates a [SessionsScreen] widget.
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(DateFormat.yMMMM().format(provider.selectedDate)),
          ),
          body: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate:
                    (day) => isSameDay(day, provider.selectedDate),
                onDaySelected: (selectedDay, focusedDay) {
                  provider.fetchSessionsForDate(selectedDay);
                  setState(() => _focusedDay = focusedDay);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white70),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                calendarFormat: CalendarFormat.month,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white70),
                  weekendStyle: TextStyle(color: Colors.white70),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Worked: ${formatDuration(provider.totalWorkedMinutesOnSelectedDate)}',
                      style: TextStyle(color: Colors.white),
                    ),
                    Spacer(),
                    Text(
                      'Sessions: ${provider.sessionCountOnSelectedDate}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    provider.sessionsForSelectedDate.isEmpty
                        ? const Center(
                          child: Text(
                            'No sessions for this date.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : ListView.builder(
                          itemCount: provider.sessionsForSelectedDate.length,
                          itemBuilder:
                              (context, index) => SessionListItem(
                                session:
                                    provider.sessionsForSelectedDate[index],
                              ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
