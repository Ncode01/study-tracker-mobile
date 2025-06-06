import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import '../../../constants/app_theme.dart';
import '../providers/timer_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';

/// StudyTimerScreen: A dynamic, animated study timer UI connected to TimerProvider.
class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final duration = timerProvider.duration;
    final totalSeconds = timerProvider.initialDuration.inSeconds;
    final elapsedSeconds = totalSeconds - duration.inSeconds;
    final progress = totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;
    final liquidColor =
        (timerProvider.mode == TimerMode.focus
            ? Colors.blueAccent
            : timerProvider.mode == TimerMode.shortBreak
            ? Colors.orangeAccent
            : Colors.greenAccent);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen liquid fill animation
          Positioned.fill(
            child: LiquidLinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              valueColor: AlwaysStoppedAnimation(liquidColor),
              backgroundColor: appTheme.scaffoldBackgroundColor,
              direction: Axis.vertical,
              borderRadius: 0,
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated timer digits
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      key: ValueKey(
                        '${duration.inHours}:${duration.inMinutes}:${duration.inSeconds}',
                      ),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Control buttons row: Start/Resume & Stop
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Start/Resume
                      Expanded(
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _buttonScale = 0.96),
                          onTapUp: (_) => setState(() => _buttonScale = 1.0),
                          onTapCancel: () => setState(() => _buttonScale = 1.0),
                          child: AnimatedScale(
                            scale: _buttonScale,
                            duration: const Duration(milliseconds: 120),
                            child: ElevatedButton(
                              onPressed:
                                  timerProvider.status != TimerStatus.running
                                      ? () =>
                                          context
                                              .read<TimerProvider>()
                                              .startTimer()
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                timerProvider.status == TimerStatus.paused
                                    ? 'Resume'
                                    : 'Start',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Stop (replaces Pause)
                      Expanded(
                        child: GestureDetector(
                          onTapDown:
                              (_) => setState(() => _buttonScale2 = 0.96),
                          onTapUp: (_) => setState(() => _buttonScale2 = 1.0),
                          onTapCancel:
                              () => setState(() => _buttonScale2 = 1.0),
                          child: AnimatedScale(
                            scale: _buttonScale2,
                            duration: const Duration(milliseconds: 120),
                            child: ElevatedButton(
                              onPressed:
                                  timerProvider.status == TimerStatus.running
                                      ? () async {
                                        // Save session and update stats in real time
                                        final timerService =
                                            Provider.of<TimerServiceProvider>(
                                              context,
                                              listen: false,
                                            );
                                        await timerService.stopTimer(context);
                                        // Optionally, reset the timer UI
                                        context
                                            .read<TimerProvider>()
                                            .resetTimer();
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Stop',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
        ],
      ),
    );
  }

  double _buttonScale = 1.0;
  double _buttonScale2 = 1.0;
}
