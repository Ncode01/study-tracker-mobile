import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/home_view_state.dart';
import '../providers/home_providers.dart';
import '../widgets/ambient_background.dart';
import '../widgets/category_context_row.dart';
import '../widgets/quick_switch_chips.dart';
import '../widgets/timer_ring.dart';
import '../widgets/top_stats_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeViewState> asyncState =
        ref.watch(homeViewNotifierProvider);
    final notifier = ref.read(homeViewNotifierProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          asyncState.when(
            data: (HomeViewState state) => SafeArea(
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
                      final double ringSize =
                          (constraints.maxHeight * 0.44).clamp(220.0, 280.0);

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
                            TopStatsBar(
                              totalProductive: state.stats.totalProductive,
                              streak: state.stats.streak,
                              next: state.stats.next,
                            ),
                            SizedBox(height: verticalGap),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CategoryContextRow(
                                    subject: state.currentCategory.title,
                                    dotColor: state.currentCategory.accentColor,
                                  ),
                                  SizedBox(height: verticalGap),
                                  TimerRing(
                                    timeText: timerText,
                                    progress: timerProgress,
                                    accentColor:
                                        state.currentCategory.accentColor,
                                    size: ringSize,
                                    onTap: () =>
                                        unawaited(notifier.toggleTimer()),
                                  ),
                                  SizedBox(height: verticalGap),
                                  QuickSwitchChips(
                                    onMathsTap: () => unawaited(
                                        notifier.quickSwitchToMaths()),
                                    onBreakTap: () => unawaited(
                                        notifier.quickSwitchToBreak()),
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
            error: (Object error, StackTrace stackTrace) =>
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
    return Center(
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: const CircularProgressIndicator(),
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
