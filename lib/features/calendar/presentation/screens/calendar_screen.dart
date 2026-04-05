import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../application/calendar_view_notifier.dart';
import '../providers/calendar_providers.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CalendarDay selectedDay = ref.watch(selectedCalendarDayProvider);
    final List<CalendarDay> days = ref.watch(calendarDaysProvider);
    final CalendarViewNotifier notifier =
        ref.read(calendarViewProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calendar',
                            style: AppTypography.heading(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMM d').format(selectedDay.date),
                            style: AppTypography.display(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      GlassContainer(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.view_week_rounded,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.06),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: days.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final CalendarDay day = days[index];
                        final bool selected = index ==
                            ref.watch(calendarViewProvider.select(
                              (CalendarViewState state) =>
                                  state.selectedDayIndex,
                            ));
                        return _DayChip(
                          day: day,
                          selected: selected,
                          onTap: () => notifier.selectDay(index),
                        ).animate(delay: (40 * index).ms).scaleXY(begin: 0.96);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(28),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Timeline',
                                style: AppTypography.heading(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${selectedDay.events.length} blocks',
                                style: AppTypography.display(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                height: 16 * 84,
                                child:
                                    _TimelineGrid(events: selectedDay.events),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 450.ms).slideY(begin: 0.05),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final CalendarDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 220.ms,
        width: 94,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: selected
              ? LinearGradient(
                  colors: <Color>[
                    AppColors.primaryPurple.withValues(alpha: 0.48),
                    AppColors.primaryPurple.withValues(alpha: 0.14),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppColors.glassBackground,
          border: Border.all(
            color: selected ? AppColors.primaryPurple : AppColors.glassBorder,
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day.label,
                style: AppTypography.display(
                  color: selected ? AppColors.textMain : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                DateFormat('MMM').format(day.date),
                style: AppTypography.display(
                  color: selected ? AppColors.textMain : AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              if (day.isToday)
                Text(
                  'TODAY',
                  style: AppTypography.display(
                    color: selected ? AppColors.textMain : AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineGrid extends StatelessWidget {
  const _TimelineGrid({required this.events});

  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    const int startHour = 7;
    const int endHour = 22;
    const double hourHeight = 84;

    return Stack(
      children: [
        for (int hour = startHour; hour <= endHour; hour++)
          Positioned(
            top: (hour - startHour) * hourHeight,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: AppTypography.display(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 1,
                    color: AppColors.glassBorder,
                  ),
                ),
              ],
            ),
          ),
        for (final CalendarEvent event in events)
          Positioned(
            top: ((event.start.hour + event.start.minute / 60) - startHour) *
                    hourHeight +
                6,
            left: 58,
            right: 0,
            height: math.max(
              64,
              (event.duration.inMinutes / 60) * hourHeight - 8,
            ),
            child: _TimelineBlock(event: event),
          ),
      ],
    );
  }
}

class _TimelineBlock extends StatelessWidget {
  const _TimelineBlock({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final Widget block = GlassContainer(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(14),
      backgroundColor: event.accentColor.withValues(alpha: 0.10),
      borderColor: event.accentColor.withValues(alpha: 0.38),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: event.accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.title,
                  style: AppTypography.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.note,
                  style: AppTypography.display(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!event.isCurrent) {
      return block;
    }

    return block
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scaleXY(
          begin: 0.99,
          end: 1.02,
          duration: 1400.ms,
        );
  }
}
