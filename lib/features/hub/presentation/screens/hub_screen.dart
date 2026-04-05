import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fading_skeleton.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_empty_state.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../application/hub_view_notifier.dart';
import '../providers/hub_providers.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HubViewState> asyncState = ref.watch(hubViewProvider);
    final HubViewNotifier notifier = ref.read(hubViewProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          SafeArea(
            child: asyncState.when(
              data:
                  (HubViewState state) => SingleChildScrollView(
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
                                  'A/Level Hub',
                                  style: AppTypography.heading(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Countdowns and session flow',
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
                                Icons.more_vert_rounded,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ).animate().fade(duration: 400.ms).slideY(begin: 0.05),
                        const SizedBox(height: 18),
                        if (state.subjects.isEmpty) ...[
                          GlassEmptyState(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Hub is waiting for your first sprint',
                            message:
                                'No sessions logged today. Start a focus block to unlock your study hub timeline.',
                            buttonLabel: 'Start a Focus Session',
                            onButtonTap: () => context.go('/'),
                          ),
                        ] else ...[
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.countdowns.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 12),
                              itemBuilder: (BuildContext context, int index) {
                                final HubCountdown countdown =
                                    state.countdowns[index];
                                return _CountdownPill(countdown: countdown)
                                    .animate(delay: (50 * index).ms)
                                    .fade(duration: 280.ms)
                                    .scaleXY(begin: 0.94);
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          for (
                            int index = 0;
                            index < state.subjects.length;
                            index++
                          )
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _GlassExpansionTile(
                                    subject: state.subjects[index],
                                    expanded:
                                        state.expandedSubjectId ==
                                        state.subjects[index].id,
                                    onTap:
                                        () => notifier.toggleSubjectExpansion(
                                          state.subjects[index].id,
                                        ),
                                  )
                                  .animate(delay: (50 * index).ms)
                                  .fade(duration: 320.ms)
                                  .slideY(begin: 0.045),
                            ),
                        ],
                      ],
                    ),
                  ),
              loading: () => const _HubLoadingSkeleton(),
              error:
                  (Object error, StackTrace stackTrace) => Center(
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Text(
                        'Unable to load Hub. $error',
                        style: AppTypography.display(fontSize: 12),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
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
          FadingSkeletonBlock(width: 210, height: 16, borderRadius: 10),
          SizedBox(height: 18),
          Row(
            children: [
              FadingSkeletonBlock(width: 120, height: 72, borderRadius: 20),
              SizedBox(width: 12),
              FadingSkeletonBlock(width: 120, height: 72, borderRadius: 20),
              SizedBox(width: 12),
              FadingSkeletonBlock(width: 90, height: 72, borderRadius: 20),
            ],
          ),
          SizedBox(height: 18),
          FadingSkeletonBlock(height: 140, borderRadius: 26),
          SizedBox(height: 12),
          FadingSkeletonBlock(height: 140, borderRadius: 26),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.countdown});

  final HubCountdown countdown;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      backgroundColor: countdown.accentColor.withValues(alpha: 0.09),
      borderColor: countdown.accentColor.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: countdown.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                countdown.title,
                style: AppTypography.display(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${countdown.daysRemaining}d',
                style: AppTypography.mono(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassExpansionTile extends StatelessWidget {
  const _GlassExpansionTile({
    required this.subject,
    required this.expanded,
    required this.onTap,
  });

  final HubSubject subject;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (subject.progress * 100).round();

    return MergeSemantics(
      child: Semantics(
        button: true,
        container: true,
        label:
            '${subject.title}. ${subject.goalLabel}. $progressPercent percent of goal.',
        hint:
            expanded
                ? 'Double tap to collapse subject details.'
                : 'Double tap to expand subject details.',
        child: GestureDetector(
          onTap: onTap,
          child: GlassContainer(
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.all(16),
            backgroundColor: subject.accentColor.withValues(alpha: 0.05),
            borderColor: subject.accentColor.withValues(alpha: 0.18),
            child: AnimatedCrossFade(
              duration: 280.ms,
              crossFadeState:
                  expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              firstChild: _CollapsedSubject(subject: subject),
              secondChild: _ExpandedSubject(subject: subject),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedSubject extends StatelessWidget {
  const _CollapsedSubject({required this.subject});

  final HubSubject subject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SubjectRing(subject: subject),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.title,
                style: AppTypography.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subject.goalLabel,
                style: AppTypography.display(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(subject.progress * 100).round()}% of goal',
                style: AppTypography.mono(
                  color: subject.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textMuted,
        ),
      ],
    );
  }
}

class _ExpandedSubject extends StatelessWidget {
  const _ExpandedSubject({required this.subject});

  final HubSubject subject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SubjectRing(subject: subject),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.title,
                    style: AppTypography.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recent Sessions',
                    style: AppTypography.display(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final HubSession session in subject.sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MergeSemantics(
              child: Semantics(
                container: true,
                label:
                    '${session.title}. ${session.timeLabel}. Duration ${session.durationLabel}.',
                child: ExcludeSemantics(
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: subject.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.title,
                                style: AppTypography.display(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.timeLabel,
                                style: AppTypography.display(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          session.durationLabel,
                          style: AppTypography.mono(
                            color: AppColors.textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        GlassButton(
          label: 'Start Session',
          icon: Icons.play_arrow_rounded,
          onTap: () {},
          labelStyle: AppTypography.display(
            color: subject.accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          iconColor: subject.accentColor,
        ),
      ],
    );
  }
}

class _SubjectRing extends StatelessWidget {
  const _SubjectRing({required this.subject});

  final HubSubject subject;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _SubjectRingPainter(
            accentColor: subject.accentColor,
            progress: subject.progress,
          ),
          child: Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subject.accentColor.withValues(alpha: 0.12),
              ),
              child: Icon(subject.icon, color: subject.accentColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectRingPainter extends CustomPainter {
  const _SubjectRingPainter({
    required this.accentColor,
    required this.progress,
  });

  final Color accentColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.width / 2) - 10;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 7
          ..color = AppColors.glassBorder;

    final Paint progressPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 6
          ..color = accentColor;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SubjectRingPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.progress != progress;
  }
}
