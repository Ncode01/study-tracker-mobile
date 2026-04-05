import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/fading_skeleton.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/home_view_state.dart';
import '../providers/home_providers.dart';
import '../widgets/ambient_background.dart';
import '../widgets/category_hero_tag.dart';
import '../widgets/category_context_row.dart';
import '../widgets/onboarding_flow_sheet.dart';
import '../widgets/quick_switch_chips.dart';
import '../widgets/timer_ring.dart';
import '../widgets/top_stats_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _didAttemptOnboarding = false;

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

                          final Duration elapsed = state.timer.elapsed;
                          final int hours = elapsed.inHours;
                          final int minutes = elapsed.inMinutes.remainder(60);
                          final int seconds = elapsed.inSeconds.remainder(60);

                          String twoDigits(int value) =>
                              value.toString().padLeft(2, '0');
                          final String timerText =
                              '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';

                          final double timerProgress =
                              state.timer.target.inSeconds <= 0
                                  ? 0
                                  : (elapsed.inSeconds /
                                          state.timer.target.inSeconds)
                                      .clamp(0.0, 1.0);

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
                                        totalProductive:
                                            state.stats.totalProductive,
                                        streak: state.stats.streak,
                                        next: state.stats.next,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GlassContainer(
                                      borderRadius: BorderRadius.circular(16),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.settings_rounded,
                                          color: Colors.white,
                                        ),
                                        onPressed:
                                            () => context.push('/settings'),
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
                                        progress: timerProgress,
                                        accentColor:
                                            state.currentCategory.accentColor,
                                        size: ringSize,
                                        onTap:
                                            () => unawaited(
                                              notifier.toggleTimer(),
                                            ),
                                      ),
                                      SizedBox(height: verticalGap),
                                      QuickSwitchChips(
                                        onMathsTap:
                                            () => unawaited(
                                              notifier.quickSwitchToMaths(),
                                            ),
                                        onBreakTap:
                                            () => unawaited(
                                              notifier.quickSwitchToBreak(),
                                            ),
                                      ),
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
    return Center(
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Text(
          'Unable to load home data.\n$message',
          textAlign: TextAlign.center,
          style: AppTypography.display(fontSize: 12),
        ),
      ),
    );
  }
}
