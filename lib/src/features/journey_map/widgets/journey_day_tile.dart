import 'package:flutter/material.dart';
import '../models/journey_day.dart';

class JourneyDayTile extends StatefulWidget {
  final JourneyDay journeyDay;
  const JourneyDayTile({super.key, required this.journeyDay});

  @override
  State<JourneyDayTile> createState() => _JourneyDayTileState();
}

class _JourneyDayTileState extends State<JourneyDayTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.journeyDay.status == JourneyDayStatus.current) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
        lowerBound: 0.95,
        upperBound: 1.15,
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.journeyDay.status == JourneyDayStatus.current) {
      _pulseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.journeyDay.status;
    final isCurrent = status == JourneyDayStatus.current;
    final isCompleted = status == JourneyDayStatus.completed;
    final isMissed = status == JourneyDayStatus.missed;
    final isUpcoming = status == JourneyDayStatus.upcoming;

    Color dotColor;
    Color borderColor;
    double dotSize;
    double borderWidth;
    Widget? icon;
    if (isCurrent) {
      dotColor = Theme.of(context).colorScheme.primary;
      borderColor = Theme.of(context).colorScheme.secondary;
      dotSize = 40;
      borderWidth = 4;
      icon = null;
    } else if (isCompleted) {
      dotColor = Theme.of(context).colorScheme.secondary.withOpacity(0.18);
      borderColor = Theme.of(context).colorScheme.secondary;
      dotSize = 24;
      borderWidth = 3;
      icon = null;
    } else if (isMissed) {
      dotColor = Colors.redAccent.withOpacity(0.12);
      borderColor = Colors.redAccent;
      dotSize = 24;
      borderWidth = 3;
      icon = const Icon(Icons.close, color: Colors.redAccent, size: 16);
    } else {
      dotColor = Colors.grey.withOpacity(0.10);
      borderColor = Colors.grey;
      dotSize = 20;
      borderWidth = 2;
      icon = null;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Column(
            children: [
              // Top connector
              Container(
                width: 2.5,
                height: 8,
                color:
                    isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
              ),
              // Central dot
              Stack(
                alignment: Alignment.center,
                children: [
                  isCurrent
                      ? ScaleTransition(
                        scale: _pulseController,
                        child: _buildDot(
                          dotColor,
                          borderColor,
                          dotSize,
                          borderWidth,
                          icon,
                        ),
                      )
                      : _buildDot(
                        dotColor,
                        borderColor,
                        dotSize,
                        borderWidth,
                        icon,
                      ),
                  if (isCurrent)
                    Positioned(
                      top: -28,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'YOU ARE HERE',
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Bottom connector
              Expanded(
                child: Container(
                  width: 2.5,
                  color:
                      isCompleted
                          ? Theme.of(context).colorScheme.secondary
                          : isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.journeyDay.title,
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : isMissed
                            ? Colors.redAccent
                            : isUpcoming
                            ? Colors.grey
                            : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.journeyDay.subtitle,
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 16,
                    color:
                        isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : isMissed
                            ? Colors.redAccent
                            : isUpcoming
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(
    Color color,
    Color border,
    double size,
    double borderWidth,
    Widget? icon,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: border, width: borderWidth),
        shape: BoxShape.circle,
        boxShadow: [
          if (border == Theme.of(context).colorScheme.primary)
            BoxShadow(
              color: Colors.orange.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: icon == null ? null : Center(child: icon),
    );
  }
}
