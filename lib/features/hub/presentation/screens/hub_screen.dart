import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fading_skeleton.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_empty_state.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../application/hub_view_notifier.dart';
import '../../domain/models/hub_class_schedule.dart';
import '../providers/hub_providers.dart';

class HubScreen extends ConsumerStatefulWidget {
  const HubScreen({super.key});

  @override
  ConsumerState<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends ConsumerState<HubScreen> {
  Timer? _promptTicker;
  bool _promptSweepRunning = false;
  final Set<String> _promptedThisSession = <String>{};

  @override
  void initState() {
    super.initState();
    _promptTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }
      final AsyncValue<HubViewState> asyncState = ref.read(hubViewProvider);
      if (asyncState case AsyncData<HubViewState>()) {
        _scheduleWeeklyPromptSweep();
      }
    });
  }

  @override
  void dispose() {
    _promptTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<HubViewState> asyncState = ref.watch(hubViewProvider);
    final HubViewNotifier notifier = ref.read(hubViewProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          SafeArea(
            child: asyncState.when(
              data: (HubViewState state) {
                _scheduleWeeklyPromptSweep();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
                                'Class Hub',
                                style: AppTypography.heading(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Maths, Physics, Chemistry · attendance and recording flow',
                                style: AppTypography.display(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          GlassContainer(
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.school_rounded,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ).animate().fade(duration: 340.ms).slideY(begin: 0.04),
                      const SizedBox(height: 16),
                      for (int i = 0; i < state.subjects.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SubjectCard(
                                subject: state.subjects[i],
                                expanded:
                                    state.expandedSubjectId ==
                                    state.subjects[i].id,
                                onToggle:
                                    () => notifier.toggleSubjectExpansion(
                                      state.subjects[i].id,
                                    ),
                                onAddClass: () {
                                  unawaited(
                                    _handleAddClass(
                                      context: context,
                                      notifier: notifier,
                                      subject: state.subjects[i],
                                    ),
                                  );
                                },
                                onPlanRecording: (HubClassEntry entry) {
                                  unawaited(
                                    _handlePlanRecording(
                                      context: context,
                                      notifier: notifier,
                                      entry: entry,
                                    ),
                                  );
                                },
                                onToggleWatched: (
                                  HubClassEntry entry,
                                  bool watched,
                                ) {
                                  unawaited(
                                    _handleRecordingWatchedToggle(
                                      context: context,
                                      notifier: notifier,
                                      entry: entry,
                                      watched: watched,
                                    ),
                                  );
                                },
                                onDeleteClass: (HubClassEntry entry) {
                                  unawaited(
                                    _handleDeleteClass(
                                      context: context,
                                      notifier: notifier,
                                      entry: entry,
                                    ),
                                  );
                                },
                                onStopClass: (HubClassEntry entry) {
                                  unawaited(
                                    _handleStopClass(
                                      context: context,
                                      notifier: notifier,
                                      entry: entry,
                                    ),
                                  );
                                },
                              )
                              .animate(delay: (40 * i).ms)
                              .fade(duration: 320.ms)
                              .slideY(begin: 0.03),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const _HubLoadingSkeleton(),
              error: (Object error, StackTrace stackTrace) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: GlassEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Unable to load class hub',
                    message:
                        'Class schedules could not be loaded right now. Please try again.',
                    buttonLabel: 'Try Again',
                    onButtonTap: notifier.refresh,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddClass({
    required BuildContext context,
    required HubViewNotifier notifier,
    required HubSubject subject,
  }) async {
    final _AddClassPayload? payload =
        await showModalBottomSheet<_AddClassPayload>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.78,
              child: _AddClassSheet(subject: subject),
            );
          },
        );

    if (payload == null) {
      return;
    }

    try {
      final HubClassCreationOutcome outcome = await notifier.addClassSession(
        subjectId: subject.id,
        teacherName: payload.teacherName,
        startDate: payload.startDate,
        weekday: payload.weekday,
        startMinutes: payload.startMinutes,
        durationMinutes: payload.durationMinutes,
        historicalMissedSessions: payload.historicalMissedSessions,
        historicalWatchedSessions: payload.historicalWatchedSessions,
      );

      if (!context.mounted) {
        return;
      }

      if (outcome.pendingRecordings > 0) {
        final String warningPrefix = outcome.hasHeavyBacklog ? 'Warning: ' : '';
        _showMessage(
          context,
          '$warningPrefix${outcome.pendingRecordings} recording catch-up block(s) were auto-scheduled from your start date history.',
        );
      } else {
        _showMessage(
          context,
          'Class added. Weekly attendance prompts will help you backfill history.',
        );
      }

      _scheduleWeeklyPromptSweep();
    } on FormatException catch (error) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, error.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Could not add class right now.');
    }
  }

  Future<void> _handlePlanRecording({
    required BuildContext context,
    required HubViewNotifier notifier,
    required HubClassEntry entry,
  }) async {
    final _PlanRecordingPayload? payload =
        await showModalBottomSheet<_PlanRecordingPayload>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.66,
              child: _PlanRecordingSheet(entry: entry),
            );
          },
        );

    if (payload == null) {
      return;
    }

    try {
      await notifier.planRecording(
        classId: entry.id,
        plannedAt: payload.plannedAt,
        durationMinutes: payload.durationMinutes,
      );
    } on FormatException catch (error) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, error.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Could not plan recording right now.');
    }
  }

  Future<void> _handleRecordingWatchedToggle({
    required BuildContext context,
    required HubViewNotifier notifier,
    required HubClassEntry entry,
    required bool watched,
  }) async {
    try {
      await notifier.setRecordingCompleted(
        classId: entry.id,
        completed: watched,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Could not update recording status.');
    }
  }

  Future<void> _handleDeleteClass({
    required BuildContext context,
    required HubViewNotifier notifier,
    required HubClassEntry entry,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF11131A),
          title: const Text('Delete class?'),
          content: Text('This will remove ${entry.teacherName} class slot.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await notifier.deleteClassSession(classId: entry.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Could not delete class right now.');
    }
  }

  Future<void> _handleStopClass({
    required BuildContext context,
    required HubViewNotifier notifier,
    required HubClassEntry entry,
  }) async {
    final DateTime initialDate = entry.endDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: entry.startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }

    try {
      await notifier.stopClassSession(classId: entry.id, endDate: picked);
      if (!context.mounted) {
        return;
      }
      _showMessage(
        context,
        'Class stopped from ${DateFormat('EEE, MMM d').format(picked)}. Previous records are kept.',
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Could not stop class right now.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _scheduleWeeklyPromptSweep() {
    if (_promptSweepRunning || !mounted) {
      return;
    }

    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return;
    }

    _promptSweepRunning = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runWeeklyPromptSweep());
    });
  }

  Future<void> _runWeeklyPromptSweep() async {
    try {
      final HubViewNotifier notifier = ref.read(hubViewProvider.notifier);

      while (mounted) {
        final ModalRoute<dynamic>? route = ModalRoute.of(context);
        if (route != null && !route.isCurrent) {
          break;
        }

        final List<HubWeeklyAttendancePrompt> prompts = await notifier
            .loadDueWeeklyAttendancePrompts(limit: 16);
        HubWeeklyAttendancePrompt? nextPrompt;
        for (final HubWeeklyAttendancePrompt prompt in prompts) {
          if (_promptedThisSession.contains(prompt.occurrenceKey)) {
            continue;
          }
          nextPrompt = prompt;
          break;
        }

        if (nextPrompt == null) {
          break;
        }

        if (!mounted) {
          break;
        }

        final HubWeeklyAttendanceAction? action =
            await showDialog<HubWeeklyAttendanceAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return _WeeklyAttendancePromptDialog(prompt: nextPrompt!);
              },
            );

        if (!mounted) {
          break;
        }

        if (action == null) {
          _promptedThisSession.add(nextPrompt.occurrenceKey);
          break;
        }

        final HubWeeklyAttendanceResolveResult result = await notifier
            .resolveWeeklyAttendancePrompt(prompt: nextPrompt, action: action);
        _promptedThisSession.add(nextPrompt.occurrenceKey);

        if (!mounted) {
          break;
        }

        if (action == HubWeeklyAttendanceAction.missedNeedsCatchUp) {
          if (result.hasHeavyBacklog) {
            _showMessage(
              context,
              'Warning: ${result.pendingRecordings} recordings are pending for this class. Catch-up sessions were auto-booked in free time.',
            );
          } else {
            _showMessage(
              context,
              'Catch-up recording added automatically in your next free time.',
            );
          }
        }
      }
    } finally {
      if (mounted) {
        _promptSweepRunning = false;
      }
    }
  }
}

class _HubLoadingSkeleton extends StatelessWidget {
  const _HubLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          FadingSkeletonBlock(width: 170, height: 32, borderRadius: 12),
          SizedBox(height: 8),
          FadingSkeletonBlock(width: 250, height: 16, borderRadius: 10),
          SizedBox(height: 16),
          FadingSkeletonBlock(height: 170, borderRadius: 26),
          SizedBox(height: 12),
          FadingSkeletonBlock(height: 170, borderRadius: 26),
          SizedBox(height: 12),
          FadingSkeletonBlock(height: 170, borderRadius: 26),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.expanded,
    required this.onToggle,
    required this.onAddClass,
    required this.onPlanRecording,
    required this.onToggleWatched,
    required this.onDeleteClass,
    required this.onStopClass,
  });

  final HubSubject subject;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onAddClass;
  final ValueChanged<HubClassEntry> onPlanRecording;
  final ValueChanged2<HubClassEntry, bool> onToggleWatched;
  final ValueChanged<HubClassEntry> onDeleteClass;
  final ValueChanged<HubClassEntry> onStopClass;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(26),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      backgroundColor: subject.accentColor.withValues(alpha: 0.06),
      borderColor: subject.accentColor.withValues(alpha: 0.22),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: subject.accentColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    subject.icon,
                    color: subject.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.title,
                        style: AppTypography.heading(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${subject.classes.length} classes · ${subject.attendedCount} attended · ${subject.missedCount} missed',
                        style: AppTypography.display(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onAddClass,
                  icon: Icon(Icons.add_rounded, color: subject.accentColor),
                  tooltip: 'Add class',
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 10),
            if (subject.classes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  'No classes yet. Add teacher and weekly session time.',
                  style: AppTypography.display(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              )
            else
              for (final HubClassEntry entry in subject.classes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ClassTile(
                    subjectColor: subject.accentColor,
                    entry: entry,
                    onPlanRecording: onPlanRecording,
                    onToggleWatched: onToggleWatched,
                    onDeleteClass: onDeleteClass,
                    onStopClass: onStopClass,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  const _ClassTile({
    required this.subjectColor,
    required this.entry,
    required this.onPlanRecording,
    required this.onToggleWatched,
    required this.onDeleteClass,
    required this.onStopClass,
  });

  final Color subjectColor;
  final HubClassEntry entry;
  final ValueChanged<HubClassEntry> onPlanRecording;
  final ValueChanged2<HubClassEntry, bool> onToggleWatched;
  final ValueChanged<HubClassEntry> onDeleteClass;
  final ValueChanged<HubClassEntry> onStopClass;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      backgroundColor: Colors.white.withValues(alpha: 0.03),
      borderColor: AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.teacherName,
                      style: AppTypography.display(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_weekdayLabel(entry.weekday)} · ${_clockLabel(entry.startMinutes)} · ${entry.durationMinutes}m',
                      style: AppTypography.display(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _activeRangeLabel(entry),
                      style: AppTypography.display(
                        color:
                            entry.isStopped
                                ? const Color(0xFFFCA5A5)
                                : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onStopClass(entry),
                icon: Icon(
                  entry.isStopped
                      ? Icons.play_circle_outline_rounded
                      : Icons.stop_circle_outlined,
                  size: 18,
                ),
                tooltip: entry.isStopped ? 'Update stop date' : 'Stop class',
              ),
              IconButton(
                onPressed: () => onDeleteClass(entry),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: 'Delete class',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Attendance is captured via weekly prompt after class ends.',
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          if (entry.hasRecordingBacklog) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    entry.pendingRecordingCount >= 3
                        ? const Color(0xFF7C2D12).withValues(alpha: 0.32)
                        : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color:
                      entry.pendingRecordingCount >= 3
                          ? const Color(0xFFF97316)
                          : AppColors.glassBorder,
                ),
              ),
              child: Text(
                'Recording backlog: ${entry.pendingRecordingCount} pending · ${entry.completedRecordingCount} watched',
                style: AppTypography.display(
                  color:
                      entry.pendingRecordingCount >= 3
                          ? const Color(0xFFFED7AA)
                          : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (entry.canPlanRecording) ...[
            const SizedBox(height: 8),
            if (entry.recordingPlannedAt == null)
              TextButton.icon(
                onPressed: () => onPlanRecording(entry),
                icon: const Icon(Icons.video_call_rounded, size: 16),
                label: Text(
                  'Plan recording catch-up',
                  style: AppTypography.display(
                    color: AppColors.textMain,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording: ${DateFormat('EEE, MMM d · HH:mm').format(entry.recordingPlannedAt!)} · ${entry.recordingDurationMinutes ?? 0}m',
                    style: AppTypography.display(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        entry.pendingRecordingCount > 0
                            ? 'Next recording pending'
                            : (entry.recordingCompleted
                                ? 'Watched'
                                : 'Not watched yet'),
                        style: AppTypography.display(
                          color:
                              entry.pendingRecordingCount > 0
                                  ? const Color(0xFFFBBF24)
                                  : (entry.recordingCompleted
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFFBBF24)),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed:
                            () => onToggleWatched(
                              entry,
                              entry.pendingRecordingCount > 0,
                            ),
                        child: Text(
                          entry.pendingRecordingCount > 0
                              ? 'Mark next as watched'
                              : 'Mark as not watched',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _AddClassSheet extends StatefulWidget {
  const _AddClassSheet({required this.subject});

  final HubSubject subject;

  @override
  State<_AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<_AddClassSheet> {
  final TextEditingController _teacherController = TextEditingController();
  DateTime _startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  int _weekday = DateTime.now().weekday;
  TimeOfDay _startTime = TimeOfDay.now();
  int _durationMinutes = 60;
  String? _errorMessage;

  @override
  void dispose() {
    _teacherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int historicalSessions = _historicalSessionDates().length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add ${widget.subject.title} Class',
                            style: AppTypography.heading(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _teacherController,
                      decoration: const InputDecoration(
                        labelText: 'Teacher Name',
                        hintText: 'e.g. Mr. Ibrahim',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _pickStartDate,
                      icon: const Icon(Icons.event_available_rounded, size: 16),
                      label: Text(
                        'Starts on: ${DateFormat('EEE, MMM d, y').format(_startDate)}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _weekday,
                      decoration: const InputDecoration(
                        labelText: 'Weekly Day',
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Monday')),
                        DropdownMenuItem(value: 2, child: Text('Tuesday')),
                        DropdownMenuItem(value: 3, child: Text('Wednesday')),
                        DropdownMenuItem(value: 4, child: Text('Thursday')),
                        DropdownMenuItem(value: 5, child: Text('Friday')),
                        DropdownMenuItem(value: 6, child: Text('Saturday')),
                        DropdownMenuItem(value: 7, child: Text('Sunday')),
                      ],
                      onChanged: (int? value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _weekday = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    if (historicalSessions > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withValues(alpha: 0.03),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          'After adding, you will get a weekly popup from your start week to now ($historicalSessions session(s)) so we can sync attendance and auto-book missed recordings.',
                          style: AppTypography.display(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _pickStartTime,
                            icon: const Icon(Icons.schedule_rounded, size: 16),
                            label: Text('Start: ${_startTime.format(context)}'),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _pickDuration,
                            icon: const Icon(Icons.timelapse_rounded, size: 16),
                            label: Text('Duration: ${_durationMinutes}m'),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.display(
                            color: const Color(0xFFFCA5A5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Add Class'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(now.year - 4),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _startTime = picked;
    });
  }

  Future<void> _pickDuration() async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int selected = _durationMinutes;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF11131A),
              title: const Text('Select Duration'),
              content: DropdownButton<int>(
                value: selected,
                items: const <int>[30, 45, 60, 75, 90, 120, 180, 240]
                    .map(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value minutes'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (int? value) {
                  if (value == null) {
                    return;
                  }
                  setDialogState(() {
                    selected = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selected),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _durationMinutes = picked;
    });
  }

  void _submit() {
    final String teacher = _teacherController.text.trim();
    if (teacher.isEmpty) {
      setState(() {
        _errorMessage = 'Teacher name cannot be empty.';
      });
      return;
    }

    final int startMinutes = _startTime.hour * 60 + _startTime.minute;
    Navigator.of(context).pop(
      _AddClassPayload(
        teacherName: teacher,
        startDate: _startDate,
        weekday: _weekday,
        startMinutes: startMinutes,
        durationMinutes: _durationMinutes,
        historicalMissedSessions: 0,
        historicalWatchedSessions: 0,
      ),
    );
  }

  List<DateTime> _historicalSessionDates() {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (_startDate.isAfter(today)) {
      return const <DateTime>[];
    }

    final int offset = (_weekday - _startDate.weekday + 7) % 7;
    DateTime cursor = _startDate.add(Duration(days: offset));
    if (cursor.isAfter(today)) {
      return const <DateTime>[];
    }

    final List<DateTime> sessions = <DateTime>[];
    while (!cursor.isAfter(today)) {
      if (_hasOccurrenceFinished(cursor)) {
        sessions.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 7));
    }
    return sessions;
  }

  bool _hasOccurrenceFinished(DateTime day) {
    final DateTime now = DateTime.now();
    final int startMinutes = _startTime.hour * 60 + _startTime.minute;
    final DateTime startAt = DateTime(
      day.year,
      day.month,
      day.day,
    ).add(Duration(minutes: startMinutes));
    final DateTime endAt = startAt.add(Duration(minutes: _durationMinutes));
    return !endAt.isAfter(now);
  }
}

class _PlanRecordingSheet extends StatefulWidget {
  const _PlanRecordingSheet({required this.entry});

  final HubClassEntry entry;

  @override
  State<_PlanRecordingSheet> createState() => _PlanRecordingSheetState();
}

class _PlanRecordingSheetState extends State<_PlanRecordingSheet> {
  late DateTime _date;
  late TimeOfDay _time;
  int _durationMinutes = 60;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    _time = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Plan Recording Catch-up',
                            style: AppTypography.heading(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.entry.teacherName,
                      style: AppTypography.display(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                            ),
                            label: Text(DateFormat('EEE, MMM d').format(_date)),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.schedule_rounded, size: 16),
                            label: Text(_time.format(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickDuration,
                      icon: const Icon(Icons.timelapse_rounded, size: 16),
                      label: Text('Duration: ${_durationMinutes}m'),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.display(
                            color: const Color(0xFFFCA5A5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.video_call_rounded),
                label: const Text('Plan Recording'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _date = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _time = picked;
    });
  }

  Future<void> _pickDuration() async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int selected = _durationMinutes;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF11131A),
              title: const Text('Recording Duration'),
              content: DropdownButton<int>(
                value: selected,
                items: const <int>[20, 30, 45, 60, 90, 120, 180, 240]
                    .map(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value minutes'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (int? value) {
                  if (value == null) {
                    return;
                  }
                  setDialogState(() {
                    selected = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selected),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _durationMinutes = picked;
    });
  }

  void _submit() {
    final DateTime plannedAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    if (plannedAt.isBefore(
      DateTime.now().subtract(const Duration(minutes: 5)),
    )) {
      setState(() {
        _errorMessage = 'Please choose a current or future time.';
      });
      return;
    }

    Navigator.of(context).pop(
      _PlanRecordingPayload(
        plannedAt: plannedAt,
        durationMinutes: _durationMinutes,
      ),
    );
  }
}

class _WeeklyAttendancePromptDialog extends StatelessWidget {
  const _WeeklyAttendancePromptDialog({required this.prompt});

  final HubWeeklyAttendancePrompt prompt;

  @override
  Widget build(BuildContext context) {
    final DateTime day = DateTime(
      prompt.occurrenceDate.year,
      prompt.occurrenceDate.month,
      prompt.occurrenceDate.day,
    );

    return AlertDialog(
      backgroundColor: const Color(0xFF11131A),
      title: Text(
        'Weekly attendance check-in',
        style: AppTypography.heading(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${prompt.subjectTitle} · ${prompt.teacherName}',
            style: AppTypography.display(
              color: AppColors.textMain,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('EEE, MMM d, y').format(day)} · ${_clockLabel(prompt.startMinutes)} · ${prompt.durationMinutes}m',
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What happened this week?',
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(HubWeeklyAttendanceAction.attendedLive);
              },
              icon: const Icon(Icons.school_rounded),
              label: const Text('I Attended Live'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(HubWeeklyAttendanceAction.watchedRecording);
              },
              icon: const Icon(Icons.ondemand_video_rounded),
              label: const Text('Missed Live, Watched Recording'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(HubWeeklyAttendanceAction.missedNeedsCatchUp);
              },
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Missed It, Auto-Book Catch-up'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
      ],
    );
  }
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    1 => 'Mon',
    2 => 'Tue',
    3 => 'Wed',
    4 => 'Thu',
    5 => 'Fri',
    6 => 'Sat',
    _ => 'Sun',
  };
}

String _clockLabel(int minutes) {
  final int hour = (minutes ~/ 60).clamp(0, 23);
  final int minute = (minutes % 60).clamp(0, 59);
  final DateTime date = DateTime(2026, 1, 1, hour, minute);
  return DateFormat('HH:mm').format(date);
}

String _activeRangeLabel(HubClassEntry entry) {
  final DateFormat formatter = DateFormat('MMM d, y');
  if (entry.endDate == null) {
    return 'Active from ${formatter.format(entry.startDate)}';
  }
  return 'Active ${formatter.format(entry.startDate)} - ${formatter.format(entry.endDate!)}';
}

class _AddClassPayload {
  const _AddClassPayload({
    required this.teacherName,
    required this.startDate,
    required this.weekday,
    required this.startMinutes,
    required this.durationMinutes,
    required this.historicalMissedSessions,
    required this.historicalWatchedSessions,
  });

  final String teacherName;
  final DateTime startDate;
  final int weekday;
  final int startMinutes;
  final int durationMinutes;
  final int historicalMissedSessions;
  final int historicalWatchedSessions;
}

class _PlanRecordingPayload {
  const _PlanRecordingPayload({
    required this.plannedAt,
    required this.durationMinutes,
  });

  final DateTime plannedAt;
  final int durationMinutes;
}

typedef ValueChanged2<A, B> = void Function(A valueA, B valueB);
