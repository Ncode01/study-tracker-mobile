import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/utils/formatters.dart';

class SessionListItem extends StatelessWidget {
  final Session session;
  const SessionListItem({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    return ListTile(
      leading: const Icon(Icons.timer, color: Colors.white),
      title: Text(
        session.projectName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        '${formatDuration(session.durationMinutes)}  |  '
        '${timeFormat.format(session.startTime)} - ${timeFormat.format(session.endTime)}',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
