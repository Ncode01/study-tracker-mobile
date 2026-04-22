import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fading_skeleton.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/home_stats.dart';
import '../../domain/models/home_view_state.dart';
import '../../domain/models/timer_snapshot.dart';
import '../providers/home_providers.dart';
import '../widgets/ambient_background.dart';
import '../widgets/category_hero_tag.dart';
import '../widgets/category_context_row.dart';
import '../widgets/onboarding_flow_sheet.dart';
import '../widgets/switch_context_sheet.dart';
import '../widgets/timer_ring.dart';
import '../widgets/top_stats_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _didAttemptOnboarding = false;

  void _showSwitchContextSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => const FractionallySizedBox(
            heightFactor: 0.82,
            child: SwitchContextSheet(),
          ),
    );
  }

  void _scheduleOnboardingIfNeeded(AsyncValue<HomeViewState> asyncState) {
    if (_didAttemptOnboarding || !asyncState.hasValue) {
      return;
    }

    _didAttemptOnboarding = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showOnboardingIfNeeded());
    });
  }

  Future<void> _showOnboardingIfNeeded() async {
    final settings = await ref.read(appSettingsServiceProvider).snapshot();
    if (!mounted || settings.onboardingCompleted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => FractionallySizedBox(
            heightFactor: 0.76,
            child: OnboardingFlowSheet(onFinished: () async {}),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<HomeViewState> asyncState = ref.watch(
      homeViewNotifierProvider,
    );
    final notifier = ref.read(homeViewNotifierProvider.notifier);

    _scheduleOnboardingIfNeeded(asyncState);

    return Scaffold(
      body: Stack(
        children: [
          asyncState.when(
            data:
                (HomeViewState state) => SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: AmbientBackground(
                            accentColor: state.currentCategory.accentColor,
                          ),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double verticalGap =
                              (constraints.maxHeight * 0.02).clamp(8.0, 20.0);
                          final double ringSize = (constraints.maxHeight * 0.44)
                              .clamp(220.0, 280.0);

                          final DateTime now = DateTime.now();
                          final Duration elapsed = state.timer.elapsedAt(now);
                          final Duration remaining = state.timer.remainingAt(
                            now,
                          );

                          String twoDigits(int value) =>
                              value.toString().padLeft(2, '0');

                          String formatClock(Duration duration) {
                            final int hours = duration.inHours;
                            final int minutes = duration.inMinutes.remainder(
                              60,
                            );
                            final int seconds = duration.inSeconds.remainder(
                              60,
                            );
                            if (hours <= 0) {
                              return '${twoDigits(minutes)}:${twoDigits(seconds)}';
                            }
                            return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
                          }

                          final String timerText = formatClock(remaining);

                          final String phaseLabel = switch (state.timer.phase) {
                            PomodoroPhase.focus =>
                              state.timer.isRunning
                                  ? 'FOCUS'
                                  : elapsed > Duration.zero
                                  ? 'FOCUS PAUSED'
                                  : 'READY',
                            PomodoroPhase.shortBreak =>
                              state.timer.isRunning
                                  ? 'SHORT BREAK'
                                  : 'BREAK PAUSED',
                            PomodoroPhase.longBreak =>
                              state.timer.isRunning
                                  ? 'LONG BREAK'
                                  : 'BREAK PAUSED',
                          };

                          final String detailText =
                              'Elapsed ${formatClock(elapsed)} · ${state.timer.completedFocusSessions} focus sessions';

                          final double timerProgress =
                              state.timer.phaseDuration.inSeconds <= 0
                                  ? 0
                                  : (elapsed.inSeconds /
                                          state.timer.phaseDuration.inSeconds)
                                      .clamp(0.0, 1.0);

                          final bool isRunning = state.timer.isRunning;
                          final bool isFocusPhase =
                              state.timer.phase == PomodoroPhase.focus;
                          final String primaryLabel =
                              isRunning
                                  ? 'Pause'
                                  : elapsed > Duration.zero
                                  ? 'Resume'
                                  : isFocusPhase
                                  ? 'Start Focus'
                                  : 'Start Break';

                          final VoidCallback onPrimaryTap =
                              isRunning
                                  ? () => unawaited(notifier.pauseTimer())
                                  : () =>
                                      unawaited(notifier.startOrResumeTimer());

                          final String tertiaryLabel =
                              isFocusPhase ? 'Rest' : 'Skip Break';
                          final VoidCallback onTertiaryTap =
                              isFocusPhase
                                  ? () => unawaited(notifier.startBreakNow())
                                  : () => unawaited(notifier.skipBreak());

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TopStatsBar(
                                        totalProductiveLabel:
                                            l10n.homeStatsTotalProd,
                                        streakLabel: l10n.homeStatsStreak,
                                        nextLabel: l10n.homeStatsNext,
                                        totalProductive:
                                            state.stats.totalProductive,
                                        streak: state.stats.streak,
                                        next: state.stats.next,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GlassContainer(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Semantics(
                                        button: true,
                                        label: l10n.openSettingsAction,
                                        child: IconButton(
                                          tooltip: l10n.openSettingsAction,
                                          icon: const Icon(
                                            Icons.settings_rounded,
                                            color: Colors.white,
                                          ),
                                          onPressed:
                                              () => context.push('/settings'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: verticalGap),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CategoryContextRow(
                                        subject: state.currentCategory.title,
                                        accentColor:
                                            state.currentCategory.accentColor,
                                        icon: state.currentCategory.icon,
                                        heroTag: categoryHeroTag(
                                          state.currentCategory.id,
                                        ),
                                      ),
                                      SizedBox(height: verticalGap),
                                      TimerRing(
                                        timeText: timerText,
                                        timeSpentLabel: phaseLabel,
                                        semanticsLabel: l10n
                                            .homeTimerSemanticsLabel(timerText),
                                        semanticsHint: null,
                                        progress: timerProgress,
                                        accentColor:
                                            state.currentCategory.accentColor,
                                        detailText: detailText,
                                        size: ringSize,
                                        onTap: _showSwitchContextSheet,
                                      ),
                                      SizedBox(height: verticalGap),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: GlassButton(
                                              label: primaryLabel,
                                              icon:
                                                  isRunning
                                                      ? Icons.pause_rounded
                                                      : Icons
                                                          .play_arrow_rounded,
                                              onTap: onPrimaryTap,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: GlassButton(
                                              label: 'Stop',
                                              icon: Icons.stop_rounded,
                                              onTap:
                                                  () => unawaited(
                                                    notifier.stopTimer(),
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                              iconColor: AppColors.idleGrey,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: GlassButton(
                                              label: tertiaryLabel,
                                              icon:
                                                  isFocusPhase
                                                      ? Icons
                                                          .free_breakfast_outlined
                                                      : Icons
                                                          .fast_forward_rounded,
                                              onTap: onTertiaryTap,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                              iconColor:
                                                  isFocusPhase
                                                      ? AppColors.idleGrey
                                                      : AppColors.accentMaths,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: verticalGap),
                                      _PomodoroMetricsCard(stats: state.stats),
                                    ],
                                  ),
                                ),
                                SizedBox(height: verticalGap),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            loading: () => const SafeArea(child: _AsyncBodyLoading()),
            error:
                (Object error, StackTrace stackTrace) =>
                    SafeArea(child: _AsyncBodyError(message: error.toString())),
          ),
        ],
      ),
    );
  }
}

class _PomodoroMetricsCard extends StatelessWidget {
  const _PomodoroMetricsCard({required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'WEEK TARGET',
              value: stats.weeklyTargetProgress,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Metric(label: 'AVG / DAY', value: stats.weeklyAverage),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Metric(label: 'PLAN HIT', value: stats.planAdherence),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.display(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.mono(
            color: AppColors.textMain,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AsyncBodyLoading extends StatelessWidget {
  const _AsyncBodyLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          FadingSkeletonBlock(height: 72, borderRadius: 20),
          SizedBox(height: 26),
          FadingSkeletonBlock(width: 220, height: 26, borderRadius: 14),
          SizedBox(height: 22),
          FadingSkeletonBlock(width: 280, height: 280, borderRadius: 180),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FadingSkeletonBlock(height: 44, borderRadius: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: FadingSkeletonBlock(height: 44, borderRadius: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AsyncBodyError extends StatelessWidget {
  const _AsyncBodyError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Center(
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Text(
          l10n.homeLoadError(message),
          textAlign: TextAlign.center,
          style: AppTypography.display(fontSize: 12),
        ),
      ),
    );
  }
}
