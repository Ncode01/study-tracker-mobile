import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../application/calendar_time_math.dart';
import '../../application/calendar_view_notifier.dart';
import '../../domain/models/planned_item.dart';
import '../providers/calendar_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const double _hourHeight = 96;
  static const double _timelineHeight = 24 * _hourHeight;
  static const double _gutterWidth = 58;

  late final ScrollController _timelineController;
  Timer? _minuteTicker;

  DateTime _now = DateTime.now();
  DateTime? _lastAutoScrolledDay;
  DateTime? _lastRenderedDay;

  final Map<String, _EventTimeOverride> _overrideByEventId =
      <String, _EventTimeOverride>{};
  final Map<String, double> _dragOffsetByEventId = <String, double>{};

  @override
  void initState() {
    super.initState();
    _timelineController = ScrollController();
    _startMinuteTicker();
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    _timelineController.dispose();
    super.dispose();
  }

  void _startMinuteTicker() {
    _minuteTicker?.cancel();
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _now = DateTime.now();
      });

      final CalendarViewState? state =
          ref.read(calendarViewProvider).valueOrNull;
      if (state != null && _isSameDay(state.selectedDate, dayKey(_now))) {
        unawaited(ref.read(calendarViewProvider.notifier).refresh());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CalendarViewState> calendar = ref.watch(
      calendarViewProvider,
    );

    return Scaffold(
      floatingActionButton: calendar.maybeWhen(
        data: (CalendarViewState state) {
          return SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton.small(
              heroTag: 'calendar_plan_add',
              onPressed: () {
                _openPlanEditor(
                  selectedDate: state.selectedDate,
                  categories: state.categories,
                );
              },
              backgroundColor: AppColors.primaryPurple,
              child: const Icon(Icons.add, size: 20),
            ),
          );
        },
        orElse: () => null,
      ),
      body: Stack(
        children: <Widget>[
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          SafeArea(
            child: calendar.when(
              data: _buildLoaded,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) {
                return Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Failed to load calendar.',
                          style: AppTypography.heading(fontSize: 17),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$error',
                          style: AppTypography.display(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            ref.read(calendarViewProvider.notifier).refresh();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(CalendarViewState state) {
    _clearTransientWhenDayChanged(state.selectedDate);
    _scheduleAutoScrollIfNeeded(state.selectedDate);

    final List<CalendarEvent> events = state.selectedDay.eventsForMode(
      CalendarTimelineMode.both,
    );

    final List<_MinuteBand> plannedBands = <_MinuteBand>[];
    final List<_MinuteBand> actualBands = <_MinuteBand>[];

    for (final CalendarEvent event in events) {
      final _EventTimeOverride? range = _effectiveRangeForEvent(
        event: event,
        selectedDate: state.selectedDate,
      );
      if (range == null) {
        continue;
      }

      final _MinuteBand band = _MinuteBand(
        startMinute: _minutesSinceMidnight(range.start),
        endMinute: _minutesSinceMidnight(range.end),
      );

      if (event.type == CalendarEventType.planned) {
        plannedBands.add(band);
      } else {
        actualBands.add(band);
      }
    }

    final bool isToday = _isSameDay(state.selectedDate, dayKey(_now));

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: <Widget>[
          _DateCarousel(
            selectedDate: state.selectedDate,
            now: _now,
            onSelectDate: (DateTime date) {
              ref.read(calendarViewProvider.notifier).selectDate(date);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GlassContainer(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SingleChildScrollView(
                  controller: _timelineController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 110),
                  child: SizedBox(
                    height: _timelineHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTapDown: (TapDownDetails details) {
                        _openQuickPlannerFromTimelineTap(
                          localPosition: details.localPosition,
                          selectedDate: state.selectedDate,
                          categories: state.categories,
                        );
                      },
                      child: Stack(
                        children: <Widget>[
                          const _TimelineGridBackground(
                            hourHeight: _hourHeight,
                            gutterWidth: _gutterWidth,
                          ),
                          _TimelinePlanActualOverlay(
                            hourHeight: _hourHeight,
                            gutterWidth: _gutterWidth,
                            plannedBands: plannedBands,
                            actualBands: actualBands,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _TimelineLegend(isToday: isToday),
                          ),
                          ...events
                              .map(
                                (CalendarEvent event) => _buildDraggableBlock(
                                  event: event,
                                  selectedDate: state.selectedDate,
                                  state: state,
                                ),
                              )
                              .whereType<Widget>(),
                          if (events.isEmpty)
                            Positioned(
                              top: 140,
                              left: _gutterWidth + 10,
                              right: 10,
                              child: Text(
                                'Double-tap empty timeline to quick-add a task.',
                                style: AppTypography.display(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          if (isToday)
                            _CurrentTimeIndicator(
                              top:
                                  _minutesSinceMidnight(_now) *
                                  (_hourHeight / 60),
                              gutterWidth: _gutterWidth,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildDraggableBlock({
    required CalendarEvent event,
    required DateTime selectedDate,
    required CalendarViewState state,
  }) {
    final _EventFrame? frame = _frameForEvent(
      event: event,
      selectedDate: selectedDate,
      includeDragOffset: true,
    );
    if (frame == null) {
      return null;
    }

    final Color accent = event.isLive ? Colors.redAccent : event.accentColor;
    final bool isPlanned = event.type == CalendarEventType.planned;

    final String tag = _eventTag(event);
    final Color background =
        isPlanned
            ? accent.withValues(alpha: 0.20)
            : accent.withValues(alpha: 0.12);
    final bool isTinyBlock = frame.height < 28;
    final bool isCompactBlock = frame.height < 44;
    final EdgeInsetsGeometry blockPadding =
        isTinyBlock
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
            : isCompactBlock
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 5)
            : const EdgeInsets.all(10);

    final String timeLabel =
        '${_formatHourMinute(frame.renderStart)} - ${_formatHourMinute(frame.renderEnd)}';

    Widget card = GlassContainer(
      borderRadius: BorderRadius.circular(14),
      backgroundColor: background,
      borderColor: accent.withValues(alpha: 0.62),
      padding: blockPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: isTinyBlock ? 2 : 3,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTypography.heading(
                          fontSize: isTinyBlock ? 11 : 13,
                          fontWeight: FontWeight.w700,
                        ).copyWith(height: isTinyBlock ? 1 : null),
                        maxLines: isCompactBlock ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isTinyBlock) ...<Widget>[
                      const SizedBox(width: 6),
                      _EventTag(label: tag, color: accent),
                    ],
                  ],
                ),
                if (frame.height >= 46) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: AppTypography.mono(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (frame.height >= 64 &&
                    event.note.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    event.note,
                    style: AppTypography.display(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (event.isLive) {
      card = card
          .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
          .fade(begin: 0.72, end: 1, duration: 1100.ms);
    }

    return Positioned(
      top: frame.top,
      left: _gutterWidth + 8,
      right: 8,
      child: SizedBox(
        height: frame.height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBlockTap(event: event, state: state),
          onPanStart: (_) {
            setState(() {
              _dragOffsetByEventId[event.id] = 0;
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            final _EventFrame? baseFrame = _frameForEvent(
              event: event,
              selectedDate: selectedDate,
              includeDragOffset: false,
            );
            if (baseFrame == null) {
              return;
            }

            final double current = _dragOffsetByEventId[event.id] ?? 0;
            final double next = current + details.delta.dy;
            final double minOffset = -baseFrame.top;
            final double maxOffset =
                _timelineHeight - (baseFrame.top + baseFrame.height);

            setState(() {
              _dragOffsetByEventId[event.id] = next.clamp(minOffset, maxOffset);
            });
          },
          onPanEnd: (_) {
            final double deltaPixels = _dragOffsetByEventId[event.id] ?? 0;
            setState(() {
              _dragOffsetByEventId.remove(event.id);
            });

            if (deltaPixels.abs() < 2) {
              return;
            }

            unawaited(
              _commitDragPlacement(
                event: event,
                state: state,
                selectedDate: selectedDate,
                deltaPixels: deltaPixels,
              ),
            );
          },
          child: card,
        ),
      ),
    );
  }

  Future<void> _onBlockTap({
    required CalendarEvent event,
    required CalendarViewState state,
  }) async {
    if (event.plannedItemId == null || !event.isEditable) {
      return;
    }

    PlannedItem? item;
    for (final PlannedItem candidate in state.plannedItems) {
      if (candidate.id == event.plannedItemId) {
        item = candidate;
        break;
      }
    }

    if (item == null) {
      return;
    }

    await _openPlanEditor(
      selectedDate: state.selectedDate,
      categories: state.categories,
      existing: item,
    );
  }

  Future<void> _commitDragPlacement({
    required CalendarEvent event,
    required CalendarViewState state,
    required DateTime selectedDate,
    required double deltaPixels,
  }) async {
    final _EventTimeOverride? currentRange = _effectiveRangeForEvent(
      event: event,
      selectedDate: selectedDate,
    );
    if (currentRange == null) {
      return;
    }

    final int minuteDelta = ((deltaPixels / _hourHeight) * 60).round();
    if (minuteDelta == 0) {
      return;
    }

    final _EventTimeOverride shifted = _shiftAndClampRange(
      range: currentRange,
      selectedDate: selectedDate,
      minuteDelta: minuteDelta,
    );

    setState(() {
      _overrideByEventId[event.id] = shifted;
    });

    if (event.isEditable && event.plannedItemId != null) {
      PlannedItem? target;
      for (final PlannedItem item in state.plannedItems) {
        if (item.id == event.plannedItemId) {
          target = item;
          break;
        }
      }

      if (target != null) {
        try {
          await ref
              .read(calendarViewProvider.notifier)
              .updatePlannedItem(
                target.copyWith(startAt: shifted.start, endAt: shifted.end),
              );
          if (!mounted) {
            return;
          }
          setState(() {
            _overrideByEventId.remove(event.id);
          });
        } catch (_) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save block position.')),
          );
        }
      }
      return;
    }

    if (!mounted) {
      return;
    }

    final String message = switch (event.type) {
      CalendarEventType.actual =>
        'Actual session moved visually for this view. Source timing is unchanged.',
      CalendarEventType.planned =>
        event.plannedSource == PlannedItemSource.hubLiveClass
            ? 'Class block moved visually. Hub auto-sync remains active.'
            : event.plannedSource == PlannedItemSource.hubRecording
            ? 'Recording block moved visually. Hub auto-sync remains active.'
            : 'Block moved visually.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _openQuickPlannerFromTimelineTap({
    required Offset localPosition,
    required DateTime selectedDate,
    required List<CalendarCategoryOption> categories,
  }) {
    final double y = localPosition.dy.clamp(0, _timelineHeight - 1);
    final double rawMinutes = y * (60 / _hourHeight);

    int startMinutes = ((rawMinutes / 15).round() * 15).clamp(0, 1439);
    int endMinutes = (startMinutes + 45).clamp(1, 1440);
    if (endMinutes <= startMinutes) {
      endMinutes = math.min(1440, startMinutes + 30);
    }

    final DateTime day = dayKey(selectedDate);
    final DateTime startAt = day.add(Duration(minutes: startMinutes));
    final DateTime endAt = day.add(Duration(minutes: endMinutes));

    _openPlanEditor(
      selectedDate: selectedDate,
      categories: categories,
      initialStartAt: startAt,
      initialEndAt: endAt,
    );
  }

  _EventFrame? _frameForEvent({
    required CalendarEvent event,
    required DateTime selectedDate,
    required bool includeDragOffset,
  }) {
    final _EventTimeOverride? range = _effectiveRangeForEvent(
      event: event,
      selectedDate: selectedDate,
    );
    if (range == null) {
      return null;
    }

    final double baseTop =
        _minutesSinceMidnight(range.start) * (_hourHeight / 60);
    final double bottom = _minutesSinceMidnight(range.end) * (_hourHeight / 60);

    if (baseTop >= _timelineHeight) {
      return null;
    }

    double height = math.max(18, bottom - baseTop);
    if (baseTop + height > _timelineHeight) {
      height = _timelineHeight - baseTop;
    }

    double top = baseTop;
    if (includeDragOffset) {
      final double dragOffset = _dragOffsetByEventId[event.id] ?? 0;
      top = (baseTop + dragOffset).clamp(0, _timelineHeight - height);
    }

    return _EventFrame(
      event: event,
      renderStart: range.start,
      renderEnd: range.end,
      top: top,
      height: height,
    );
  }

  _EventTimeOverride? _effectiveRangeForEvent({
    required CalendarEvent event,
    required DateTime selectedDate,
  }) {
    final DateTime dayStart = dayKey(selectedDate);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));

    DateTime start = event.start;
    DateTime end = event.end;

    if (event.isLive && _isSameDay(selectedDate, dayKey(_now))) {
      end = _now;
    }

    final _EventTimeOverride? override = _overrideByEventId[event.id];
    if (override != null) {
      start = override.start;
      end = override.end;
    }

    if (start.isBefore(dayStart)) {
      start = dayStart;
    }
    if (end.isAfter(dayEnd)) {
      end = dayEnd;
    }

    if (!end.isAfter(start)) {
      end = start.add(const Duration(minutes: 1));
    }

    if (!start.isBefore(dayEnd) || !end.isAfter(dayStart)) {
      return null;
    }

    return _EventTimeOverride(start: start, end: end);
  }

  _EventTimeOverride _shiftAndClampRange({
    required _EventTimeOverride range,
    required DateTime selectedDate,
    required int minuteDelta,
  }) {
    final DateTime dayStart = dayKey(selectedDate);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));

    DateTime start = range.start.add(Duration(minutes: minuteDelta));
    DateTime end = range.end.add(Duration(minutes: minuteDelta));

    Duration duration = end.difference(start);
    if (duration <= Duration.zero) {
      duration = const Duration(minutes: 1);
    }

    if (start.isBefore(dayStart)) {
      start = dayStart;
      end = start.add(duration);
    }

    if (end.isAfter(dayEnd)) {
      end = dayEnd;
      start = end.subtract(duration);
    }

    if (start.isBefore(dayStart)) {
      start = dayStart;
    }

    if (!end.isAfter(start)) {
      end = start.add(const Duration(minutes: 1));
    }

    return _EventTimeOverride(start: start, end: end);
  }

  Future<void> _openPlanEditor({
    required DateTime selectedDate,
    required List<CalendarCategoryOption> categories,
    PlannedItem? existing,
    DateTime? initialStartAt,
    DateTime? initialEndAt,
  }) async {
    if (categories.isEmpty && existing == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a category first before planning.'),
        ),
      );
      return;
    }

    final CalendarViewNotifier notifier = ref.read(
      calendarViewProvider.notifier,
    );

    final DateTime seedStart =
        existing?.startAt ??
        initialStartAt ??
        selectedDate.add(const Duration(hours: 9));
    final DateTime seedEnd =
        existing?.endAt ??
        initialEndAt ??
        seedStart.add(const Duration(hours: 1));

    String categoryId = existing?.categoryId ?? categories.first.id;
    String title = existing?.title ?? '';
    String notes = existing?.notes ?? '';
    TimeOfDay start = TimeOfDay.fromDateTime(seedStart);
    TimeOfDay end = TimeOfDay.fromDateTime(seedEnd);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setModalState,
          ) {
            Future<void> pickTime({required bool isStart}) async {
              final TimeOfDay initial = isStart ? start : end;
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: initial,
              );
              if (picked == null) {
                return;
              }

              setModalState(() {
                if (isStart) {
                  start = picked;
                } else {
                  end = picked;
                }
              });
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      existing == null ? 'Add Plan Block' : 'Edit Plan Block',
                      style: AppTypography.heading(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (existing == null)
                      DropdownButtonFormField<String>(
                        value: categoryId,
                        dropdownColor: AppColors.backgroundDark,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map(
                              (CalendarCategoryOption category) =>
                                  DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Text(category.title),
                                  ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() {
                            categoryId = value;
                          });
                        },
                      ),
                    if (existing == null) const SizedBox(height: 12),
                    TextFormField(
                      initialValue: title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String value) => title = value,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: notes,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String value) => notes = value,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => pickTime(isStart: true),
                            icon: const Icon(Icons.schedule),
                            label: Text('Start ${_formatTimeOfDay(start)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => pickTime(isStart: false),
                            icon: const Icon(Icons.schedule_outlined),
                            label: Text('End ${_formatTimeOfDay(end)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        if (existing != null)
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await notifier.deletePlannedItem(
                                  plannedItemId: existing.id,
                                  preferredDay: selectedDate,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final String trimmedTitle = title.trim();
                              if (trimmedTitle.isEmpty) {
                                if (!mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Title is required.'),
                                  ),
                                );
                                return;
                              }

                              DateTime compose(TimeOfDay value) {
                                return DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  value.hour,
                                  value.minute,
                                );
                              }

                              final DateTime startAt = compose(start);
                              final DateTime endAt = compose(end);
                              if (!endAt.isAfter(startAt)) {
                                if (!mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('End must be after start.'),
                                  ),
                                );
                                return;
                              }

                              Navigator.of(context).pop();

                              if (existing == null) {
                                await notifier.createPlannedItem(
                                  PlannedItemDraft(
                                    categoryId: categoryId,
                                    title: trimmedTitle,
                                    startAt: startAt,
                                    endAt: endAt,
                                    notes:
                                        notes.trim().isEmpty
                                            ? null
                                            : notes.trim(),
                                  ),
                                );
                              } else {
                                await notifier.updatePlannedItem(
                                  existing.copyWith(
                                    title: trimmedTitle,
                                    startAt: startAt,
                                    endAt: endAt,
                                    notes:
                                        notes.trim().isEmpty
                                            ? null
                                            : notes.trim(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              existing == null ? 'Save Plan' : 'Save Changes',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _clearTransientWhenDayChanged(DateTime selectedDate) {
    if (_lastRenderedDay != null &&
        _isSameDay(_lastRenderedDay!, selectedDate)) {
      return;
    }

    _overrideByEventId.clear();
    _dragOffsetByEventId.clear();
    _lastRenderedDay = selectedDate;
  }

  void _scheduleAutoScrollIfNeeded(DateTime selectedDate) {
    final DateTime today = dayKey(_now);
    if (!_isSameDay(selectedDate, today)) {
      _lastAutoScrolledDay = null;
      return;
    }

    if (_lastAutoScrolledDay != null &&
        _isSameDay(_lastAutoScrolledDay!, selectedDate)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_timelineController.hasClients) {
        return;
      }

      final double centerOffset =
          (_minutesSinceMidnight(_now) * (_hourHeight / 60)) - 220;
      final double clamped = centerOffset.clamp(
        0,
        _timelineController.position.maxScrollExtent,
      );
      _timelineController.jumpTo(clamped);
      _lastAutoScrolledDay = selectedDate;
    });
  }

  String _eventTag(CalendarEvent event) {
    if (event.type == CalendarEventType.actual) {
      return event.isLive ? 'LIVE' : 'REAL';
    }

    return switch (event.plannedSource) {
      PlannedItemSource.hubLiveClass => 'CLASS',
      PlannedItemSource.hubRecording => 'REC',
      _ => 'PLAN',
    };
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  double _minutesSinceMidnight(DateTime time) {
    return (time.hour * 60) + time.minute + (time.second / 60);
  }

  static String _formatHourMinute(DateTime time) {
    final String hh = time.hour.toString().padLeft(2, '0');
    final String mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String _formatTimeOfDay(TimeOfDay value) {
    final String hh = value.hour.toString().padLeft(2, '0');
    final String mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _DateCarousel extends StatelessWidget {
  const _DateCarousel({
    required this.selectedDate,
    required this.now,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final DateTime now;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final DateTime center = dayKey(selectedDate);

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 15,
        itemBuilder: (BuildContext context, int index) {
          final int delta = index - 7;
          final DateTime date = center.add(Duration(days: delta));
          final bool selected = _isSameDay(date, selectedDate);
          final bool isToday = _isSameDay(date, now);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelectDate(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 66,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      selected
                          ? AppColors.primaryPurple.withValues(alpha: 0.26)
                          : AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        selected
                            ? AppColors.primaryPurple.withValues(alpha: 0.80)
                            : AppColors.glassBorder,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _shortWeekday(date.weekday),
                      style: AppTypography.display(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? AppColors.textMain : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${date.day}',
                      style: AppTypography.heading(
                        fontSize: selected ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color:
                            selected ? AppColors.textMain : AppColors.textMuted,
                      ),
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 7),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _shortWeekday(int weekday) {
    const List<String> labels = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return labels[weekday - 1];
  }
}

class _EventTag extends StatelessWidget {
  const _EventTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Text(
        label,
        style: AppTypography.mono(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _TimelineLegend extends StatelessWidget {
  const _TimelineLegend({required this.isToday});

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GlassContainer(
        borderRadius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.32),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _LegendDot(
              color: AppColors.primaryPurple.withValues(alpha: 0.86),
              label: 'Plan',
            ),
            const SizedBox(width: 8),
            _LegendDot(
              color: AppColors.accentPhysics.withValues(alpha: 0.86),
              label: 'Real',
            ),
            if (isToday) ...<Widget>[
              const SizedBox(width: 8),
              _LegendDot(
                color: Colors.redAccent.withValues(alpha: 0.86),
                label: 'Now',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.mono(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _TimelineGridBackground extends StatelessWidget {
  const _TimelineGridBackground({
    required this.hourHeight,
    required this.gutterWidth,
  });

  final double hourHeight;
  final double gutterWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List<Widget>.generate(25, (int hour) {
        final double top = hour * hourHeight;
        final bool isBoundary = hour == 0 || hour == 24;

        return Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: gutterWidth,
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: Text(
                    hour == 24 ? '' : '${hour.toString().padLeft(2, '0')}:00',
                    textAlign: TextAlign.right,
                    style: AppTypography.mono(
                      fontSize: 10,
                      color: AppColors.textMuted.withValues(alpha: 0.74),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: isBoundary ? 1.2 : 1,
                  color: AppColors.glassBorder.withValues(
                    alpha: isBoundary ? 0.58 : 0.25,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TimelinePlanActualOverlay extends StatelessWidget {
  const _TimelinePlanActualOverlay({
    required this.hourHeight,
    required this.gutterWidth,
    required this.plannedBands,
    required this.actualBands,
  });

  final double hourHeight;
  final double gutterWidth;
  final List<_MinuteBand> plannedBands;
  final List<_MinuteBand> actualBands;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _TimelinePlanActualPainter(
            hourHeight: hourHeight,
            gutterWidth: gutterWidth,
            plannedBands: plannedBands,
            actualBands: actualBands,
          ),
        ),
      ),
    );
  }
}

class _TimelinePlanActualPainter extends CustomPainter {
  _TimelinePlanActualPainter({
    required this.hourHeight,
    required this.gutterWidth,
    required this.plannedBands,
    required this.actualBands,
  });

  final double hourHeight;
  final double gutterWidth;
  final List<_MinuteBand> plannedBands;
  final List<_MinuteBand> actualBands;

  @override
  void paint(Canvas canvas, Size size) {
    final double left = gutterWidth + 8;
    final double width = size.width - left - 8;
    if (width <= 0) {
      return;
    }

    final Paint plannedPaint =
        Paint()..color = AppColors.primaryPurple.withValues(alpha: 0.08);
    final Paint actualPaint =
        Paint()..color = AppColors.accentPhysics.withValues(alpha: 0.08);
    final Paint overlapPaint =
        Paint()..color = Colors.greenAccent.withValues(alpha: 0.11);

    final List<_MinuteBand> mergedPlanned = _mergeBands(plannedBands);
    final List<_MinuteBand> mergedActual = _mergeBands(actualBands);

    for (final _MinuteBand band in mergedPlanned) {
      final Rect rect = _rectForBand(band: band, left: left, width: width);
      canvas.drawRect(rect, plannedPaint);
    }

    for (final _MinuteBand band in mergedActual) {
      final Rect rect = _rectForBand(band: band, left: left, width: width);
      canvas.drawRect(rect, actualPaint);
    }

    final List<_MinuteBand> overlapBands = _intersections(
      mergedPlanned,
      mergedActual,
    );
    for (final _MinuteBand band in overlapBands) {
      final Rect rect = _rectForBand(band: band, left: left, width: width);
      canvas.drawRect(rect, overlapPaint);
    }
  }

  Rect _rectForBand({
    required _MinuteBand band,
    required double left,
    required double width,
  }) {
    final double top = (band.startMinute * (hourHeight / 60)).clamp(
      0,
      24 * hourHeight,
    );
    final double bottom = (band.endMinute * (hourHeight / 60)).clamp(
      0,
      24 * hourHeight,
    );
    final double height = math.max(1, bottom - top);

    return Rect.fromLTWH(left, top, width, height);
  }

  List<_MinuteBand> _mergeBands(List<_MinuteBand> bands) {
    if (bands.isEmpty) {
      return const <_MinuteBand>[];
    }

    final List<_MinuteBand> sorted = List<_MinuteBand>.from(bands)
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));

    final List<_MinuteBand> merged = <_MinuteBand>[];
    _MinuteBand current = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      final _MinuteBand next = sorted[i];
      if (next.startMinute <= current.endMinute) {
        current = _MinuteBand(
          startMinute: current.startMinute,
          endMinute: math.max(current.endMinute, next.endMinute).toDouble(),
        );
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }

  List<_MinuteBand> _intersections(
    List<_MinuteBand> planned,
    List<_MinuteBand> actual,
  ) {
    final List<_MinuteBand> intersections = <_MinuteBand>[];

    int i = 0;
    int j = 0;

    while (i < planned.length && j < actual.length) {
      final _MinuteBand p = planned[i];
      final _MinuteBand a = actual[j];

      final double start = math.max(p.startMinute, a.startMinute).toDouble();
      final double end = math.min(p.endMinute, a.endMinute).toDouble();

      if (end > start) {
        intersections.add(_MinuteBand(startMinute: start, endMinute: end));
      }

      if (p.endMinute < a.endMinute) {
        i++;
      } else {
        j++;
      }
    }

    return intersections;
  }

  @override
  bool shouldRepaint(covariant _TimelinePlanActualPainter oldDelegate) {
    if (oldDelegate.hourHeight != hourHeight ||
        oldDelegate.gutterWidth != gutterWidth) {
      return true;
    }
    if (oldDelegate.plannedBands.length != plannedBands.length ||
        oldDelegate.actualBands.length != actualBands.length) {
      return true;
    }

    for (int i = 0; i < plannedBands.length; i++) {
      if (plannedBands[i] != oldDelegate.plannedBands[i]) {
        return true;
      }
    }

    for (int i = 0; i < actualBands.length; i++) {
      if (actualBands[i] != oldDelegate.actualBands[i]) {
        return true;
      }
    }

    return false;
  }
}

class _CurrentTimeIndicator extends StatelessWidget {
  const _CurrentTimeIndicator({required this.top, required this.gutterWidth});

  final double top;
  final double gutterWidth;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top.clamp(0, 24 * 96),
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: gutterWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(
                      onPlay:
                          (AnimationController c) => c.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.12, 1.12),
                      duration: 900.ms,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 2, color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}

class _EventFrame {
  const _EventFrame({
    required this.event,
    required this.renderStart,
    required this.renderEnd,
    required this.top,
    required this.height,
  });

  final CalendarEvent event;
  final DateTime renderStart;
  final DateTime renderEnd;
  final double top;
  final double height;
}

class _EventTimeOverride {
  const _EventTimeOverride({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class _MinuteBand {
  const _MinuteBand({required this.startMinute, required this.endMinute});

  final double startMinute;
  final double endMinute;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _MinuteBand &&
        other.startMinute == startMinute &&
        other.endMinute == endMinute;
  }

  @override
  int get hashCode => Object.hash(startMinute, endMinute);
}
