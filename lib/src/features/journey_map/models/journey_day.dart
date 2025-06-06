// filepath: lib/src/features/journey_map/models/journey_day.dart
import 'package:flutter/material.dart';

/// Enum representing the status of a day on the journey path.
enum JourneyDayStatus { completed, current, missed, upcoming }

/// Model representing a single day on the journey path.
class JourneyDay {
  final DateTime date;
  final int dayNumber;
  final String title;
  final String subtitle;
  final JourneyDayStatus status;

  JourneyDay({
    required this.date,
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.status,
  });
}
