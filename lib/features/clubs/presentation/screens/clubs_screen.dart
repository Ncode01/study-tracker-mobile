import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../application/clubs_view_notifier.dart';
import '../providers/clubs_providers.dart';

class ClubsScreen extends ConsumerWidget {
  const ClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ClubsViewState> asyncState = ref.watch(clubsViewProvider);
    final ClubsViewNotifier notifier = ref.read(clubsViewProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          asyncState.when(
            data: (ClubsViewState state) {
              List<ClubTask> tasksForStatus(ClubTaskStatus status) {
                return state.tasks
                    .where(
                      (ClubTask task) =>
                          task.clubId == state.selectedClubId &&
                          task.status == status,
                    )
                    .toList(growable: false);
              }

              final List<ClubTaskStatus> visibleStatuses = ClubTaskStatus.values
                  .where(
                    (ClubTaskStatus status) =>
                        tasksForStatus(status).isNotEmpty,
                  )
                  .toList(growable: false);

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
                              constraints.maxWidth >= 860 &&
                              visibleStatuses.length > 1;

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
            loading:
                () => const SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (Object error, StackTrace stackTrace) => SafeArea(
                  child: Center(
                    child: Text(
                      'Unable to load clubs. $error',
                      style: AppTypography.display(fontSize: 12),
                    ),
                  ),
                ),
          ),
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
            const SizedBox(height: 8),
            Text(
              club.title,
              style: AppTypography.display(
                color: selected ? AppColors.textMain : AppColors.textMuted,
                fontSize: 12,
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
  });

  final ClubTaskStatus status;
  final Color accentColor;
  final List<ClubTask> tasks;

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

    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

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
            ],
          ),
          const SizedBox(height: 12),
          for (final ClubTask task in tasks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskCard(task: task, accentColor: accentColor)
                  .animate(delay: 40.ms)
                  .fade(duration: 280.ms)
                  .slideX(begin: 0.04),
            ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.accentColor});

  final ClubTask task;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (task.progress * 100).round();

    return MergeSemantics(
      child: Semantics(
        container: true,
        label:
            'Task ${task.title}. Due ${task.dueLabel}. Estimate ${task.estimateLabel}. Progress $progressPercent percent.',
        child: ExcludeSemantics(
          child: GlassContainer(
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            backgroundColor: accentColor.withValues(alpha: 0.05),
            borderColor: accentColor.withValues(alpha: 0.16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.display(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}
