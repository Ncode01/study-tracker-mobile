import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fading_skeleton.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_empty_state.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../application/clubs_view_notifier.dart';
import '../providers/clubs_providers.dart';

class ClubsScreen extends ConsumerWidget {
  const ClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ClubsViewState> asyncState = ref.watch(clubsViewProvider);
    final ClubsViewNotifier notifier = ref.read(clubsViewProvider.notifier);

    Future<void> handleCreateTask(
      ClubsViewState state,
      ClubTaskStatus status,
    ) async {
      final _CreateTaskPayload? payload = await showDialog<_CreateTaskPayload>(
        context: context,
        builder: (BuildContext context) {
          return _CreateTaskDialog(status: status);
        },
      );

      if (payload == null) {
        return;
      }

      try {
        await notifier.createTask(
          clubId: state.selectedClubId,
          status: status,
          title: payload.title,
          dueLabel: payload.dueLabel,
          estimateMinutes: payload.estimateMinutes,
        );
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to create task. Please retry.'),
            ),
          );
        }
      }
    }

    Future<void> handleTaskActions(ClubTask task) async {
      final _TaskAction? action = await showModalBottomSheet<_TaskAction>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return _TaskActionSheet(task: task);
        },
      );

      if (action == null || task.id == null) {
        return;
      }

      try {
        switch (action) {
          case _TaskAction.moveTodo:
            await notifier.updateTaskStatus(
              taskId: task.id!,
              status: ClubTaskStatus.todo,
            );
          case _TaskAction.moveDoing:
            await notifier.updateTaskStatus(
              taskId: task.id!,
              status: ClubTaskStatus.doing,
            );
          case _TaskAction.moveDone:
            await notifier.updateTaskStatus(
              taskId: task.id!,
              status: ClubTaskStatus.done,
            );
          case _TaskAction.delete:
            await notifier.deleteTask(task.id!);
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to update task. Please retry.'),
            ),
          );
        }
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          asyncState.when(
            data: (ClubsViewState state) {
              if (state.clubs.isEmpty) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: GlassEmptyState(
                      icon: Icons.groups_outlined,
                      title: 'No clubs available yet',
                      message:
                          'Create your first club lane to start tracking tasks and deadlines.',
                      buttonLabel: 'Refresh Clubs',
                      onButtonTap: () => ref.invalidate(clubsViewProvider),
                    ),
                  ),
                );
              }

              List<ClubTask> tasksForStatus(ClubTaskStatus status) {
                return state.tasks
                    .where(
                      (ClubTask task) =>
                          task.clubId == state.selectedClubId &&
                          task.status == status,
                    )
                    .toList(growable: false);
              }

              final List<ClubTaskStatus> visibleStatuses =
                  ClubTaskStatus.values;

              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clubs',
                        style: AppTypography.heading(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fade(duration: 380.ms).slideY(begin: 0.05),
                      const SizedBox(height: 4),
                      Text(
                        'Kanban flow for extracurricular work',
                        style: AppTypography.display(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.clubs.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 14),
                          itemBuilder: (BuildContext context, int index) {
                            final ClubOption club = state.clubs[index];
                            final bool selected =
                                club.id == state.selectedClubId;
                            return _ClubSelector(
                                  club: club,
                                  selected: selected,
                                  onTap: () => notifier.selectClub(club.id),
                                )
                                .animate(delay: (45 * index).ms)
                                .scaleXY(begin: 0.94);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                        ) {
                          final bool useAdaptiveBoard =
                              constraints.maxWidth >= 860;

                          if (!useAdaptiveBoard) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final ClubTaskStatus status
                                    in visibleStatuses)
                                  _KanbanSection(
                                    status: status,
                                    accentColor: state.selectedClub.accentColor,
                                    tasks: tasksForStatus(status),
                                    onAddTask:
                                        () => handleCreateTask(state, status),
                                    onTaskMenuTap: handleTaskActions,
                                  ),
                              ],
                            );
                          }

                          final int columns =
                              constraints.maxWidth >= 1240 ? 3 : 2;
                          const double spacing = 12;
                          final double sectionWidth =
                              (constraints.maxWidth -
                                  ((columns - 1) * spacing)) /
                              columns;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              for (final ClubTaskStatus status
                                  in visibleStatuses)
                                SizedBox(
                                  width: sectionWidth,
                                  child: _KanbanSection(
                                    status: status,
                                    accentColor: state.selectedClub.accentColor,
                                    tasks: tasksForStatus(status),
                                    onAddTask:
                                        () => handleCreateTask(state, status),
                                    onTaskMenuTap: handleTaskActions,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SafeArea(child: _ClubsLoadingSkeleton()),
            error:
                (Object error, StackTrace stackTrace) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: GlassEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Unable to load clubs',
                      message:
                          'Something went wrong while loading your task board. Please try again.',
                      buttonLabel: 'Try Again',
                      onButtonTap: () => ref.invalidate(clubsViewProvider),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _ClubsLoadingSkeleton extends StatelessWidget {
  const _ClubsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          FadingSkeletonBlock(width: 120, height: 32, borderRadius: 12),
          SizedBox(height: 8),
          FadingSkeletonBlock(width: 220, height: 16, borderRadius: 10),
          SizedBox(height: 18),
          Row(
            children: [
              FadingSkeletonBlock(width: 72, height: 96, borderRadius: 20),
              SizedBox(width: 14),
              FadingSkeletonBlock(width: 72, height: 96, borderRadius: 20),
              SizedBox(width: 14),
              FadingSkeletonBlock(width: 72, height: 96, borderRadius: 20),
            ],
          ),
          SizedBox(height: 20),
          FadingSkeletonBlock(height: 190, borderRadius: 22),
          SizedBox(height: 12),
          FadingSkeletonBlock(height: 190, borderRadius: 22),
          SizedBox(height: 12),
          FadingSkeletonBlock(height: 190, borderRadius: 22),
        ],
      ),
    );
  }
}

class _ClubSelector extends StatelessWidget {
  const _ClubSelector({
    required this.club,
    required this.selected,
    required this.onTap,
  });

  final ClubOption club;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: club.title,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: 220.ms,
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected
                        ? club.accentColor.withValues(alpha: 0.20)
                        : AppColors.glassBackground,
                border: Border.all(
                  color: selected ? club.accentColor : AppColors.glassBorder,
                  width: selected ? 1.3 : 1,
                ),
                boxShadow:
                    selected
                        ? <BoxShadow>[
                          BoxShadow(
                            color: club.accentColor.withValues(alpha: 0.28),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ]
                        : null,
              ),
              child: Icon(club.icon, color: club.accentColor, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              club.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(
                color: selected ? AppColors.textMain : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanSection extends StatelessWidget {
  const _KanbanSection({
    required this.status,
    required this.accentColor,
    required this.tasks,
    required this.onAddTask,
    required this.onTaskMenuTap,
  });

  final ClubTaskStatus status;
  final Color accentColor;
  final List<ClubTask> tasks;
  final VoidCallback onAddTask;
  final ValueChanged<ClubTask> onTaskMenuTap;

  @override
  Widget build(BuildContext context) {
    final ({String title, Color dotColor}) meta = switch (status) {
      ClubTaskStatus.doing => (
        title: 'Doing',
        dotColor: const Color(0xFF8B5CF6),
      ),
      ClubTaskStatus.todo => (title: 'Todo', dotColor: AppColors.textMuted),
      ClubTaskStatus.done => (title: 'Done', dotColor: const Color(0xFF22C55E)),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: meta.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                meta.title,
                style: AppTypography.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${tasks.length})',
                style: AppTypography.display(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            GlassContainer(
              borderRadius: BorderRadius.circular(18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                'No tasks yet in this lane.',
                style: AppTypography.display(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          for (final ClubTask task in tasks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskCard(
                    task: task,
                    accentColor: accentColor,
                    onMoreTap: () => onTaskMenuTap(task),
                  )
                  .animate(delay: 40.ms)
                  .fade(duration: 280.ms)
                  .slideX(begin: 0.04),
            ),
          const SizedBox(height: 2),
          _DashedAddTaskButton(onTap: onAddTask),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.accentColor,
    required this.onMoreTap,
  });

  final ClubTask task;
  final Color accentColor;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (task.progress * 100).round();

    return Semantics(
      container: true,
      label:
          'Task ${task.title}. Due ${task.dueLabel}. Estimate ${task.estimateLabel}. Progress $progressPercent percent.',
      child: GlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        backgroundColor: accentColor.withValues(alpha: 0.05),
        borderColor: accentColor.withValues(alpha: 0.16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTypography.display(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onMoreTap,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  tooltip: 'Task actions',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  task.dueLabel,
                  style: AppTypography.display(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  task.estimateLabel,
                  style: AppTypography.mono(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: task.progress,
                backgroundColor: AppColors.glassBorder,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedAddTaskButton extends StatelessWidget {
  const _DashedAddTaskButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.glassBorder,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'Add Task',
                style: AppTypography.display(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.borderRadius});

  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = borderRadius.toRRect(Offset.zero & size);
    final Path path = Path()..addRRect(rrect);

    const double dashWidth = 6;
    const double dashSpace = 4;

    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}

enum _TaskAction { moveTodo, moveDoing, moveDone, delete }

class _TaskActionSheet extends StatelessWidget {
  const _TaskActionSheet({required this.task});

  final ClubTask task;

  @override
  Widget build(BuildContext context) {
    final List<
      ({_TaskAction action, String label, IconData icon, bool destructive})
    >
    actions =
        <({_TaskAction action, String label, IconData icon, bool destructive})>[
          (
            action: _TaskAction.moveTodo,
            label: 'Move to Todo',
            icon: Icons.inbox_outlined,
            destructive: false,
          ),
          (
            action: _TaskAction.moveDoing,
            label: 'Move to Doing',
            icon: Icons.run_circle_outlined,
            destructive: false,
          ),
          (
            action: _TaskAction.moveDone,
            label: 'Move to Done',
            icon: Icons.check_circle_outline,
            destructive: false,
          ),
          (
            action: _TaskAction.delete,
            label: 'Delete Task',
            icon: Icons.delete_outline_rounded,
            destructive: true,
          ),
        ];

    return SafeArea(
      top: false,
      child: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            for (final action in actions)
              if (!_isRedundantMove(task.status, action.action))
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    action.icon,
                    color:
                        action.destructive
                            ? Colors.redAccent
                            : AppColors.textMain,
                  ),
                  title: Text(
                    action.label,
                    style: AppTypography.display(
                      color:
                          action.destructive
                              ? Colors.redAccent
                              : AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(action.action),
                ),
          ],
        ),
      ),
    );
  }

  bool _isRedundantMove(ClubTaskStatus current, _TaskAction action) {
    return switch (action) {
      _TaskAction.moveTodo => current == ClubTaskStatus.todo,
      _TaskAction.moveDoing => current == ClubTaskStatus.doing,
      _TaskAction.moveDone => current == ClubTaskStatus.done,
      _TaskAction.delete => false,
    };
  }
}

class _CreateTaskPayload {
  const _CreateTaskPayload({
    required this.title,
    required this.dueLabel,
    required this.estimateMinutes,
  });

  final String title;
  final String dueLabel;
  final int estimateMinutes;
}

class _CreateTaskDialog extends StatefulWidget {
  const _CreateTaskDialog({required this.status});

  final ClubTaskStatus status;

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dueController = TextEditingController(
    text: 'Due Soon',
  );
  final TextEditingController _estimateController = TextEditingController(
    text: '30',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _dueController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String laneTitle = switch (widget.status) {
      ClubTaskStatus.todo => 'Todo',
      ClubTaskStatus.doing => 'Doing',
      ClubTaskStatus.done => 'Done',
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Task',
                style: AppTypography.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Adding to $laneTitle lane.',
                style: AppTypography.display(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration('Task title'),
                style: AppTypography.display(color: AppColors.textMain),
                validator: (String? value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter a task title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dueController,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration('Due label (e.g., Due Fri)'),
                style: AppTypography.display(color: AppColors.textMain),
                validator: (String? value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter a due label.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _estimateController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Estimate minutes'),
                style: AppTypography.display(color: AppColors.textMain),
                validator: (String? value) {
                  final int? minutes = int.tryParse((value ?? '').trim());
                  if (minutes == null || minutes <= 0) {
                    return 'Enter a valid number of minutes.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTypography.display(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(
                        'Create',
                        style: AppTypography.display(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.display(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryPurple),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final int estimateMinutes =
        int.tryParse(_estimateController.text.trim()) ?? 30;

    Navigator.of(context).pop(
      _CreateTaskPayload(
        title: _titleController.text.trim(),
        dueLabel: _dueController.text.trim(),
        estimateMinutes: estimateMinutes.clamp(1, 480),
      ),
    );
  }
}
