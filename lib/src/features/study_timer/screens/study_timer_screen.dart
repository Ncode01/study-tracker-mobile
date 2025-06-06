import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import '../../../constants/app_theme.dart';
import '../providers/timer_provider.dart';

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
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final isRunning = timerProvider.status == TimerStatus.running;
    final isPaused = timerProvider.status == TimerStatus.paused;
    final isStopped = timerProvider.status == TimerStatus.stopped;
    final mode = timerProvider.mode; // Dynamic background selection
    String bgUrl;
    Color liquidColor;
    switch (mode) {
      case TimerMode.focus:
        bgUrl = 'https://images.unsplash.com/photo-1519681393784-d120267933ba';
        liquidColor = Colors.blueAccent;
        break;
      case TimerMode.shortBreak:
        bgUrl = 'https://images.unsplash.com/photo-1501854140801-50d01698950b';
        liquidColor = Colors.orangeAccent;
        break;
      case TimerMode.longBreak:
        bgUrl = 'https://images.unsplash.com/photo-1469474968028-56623f02e42e';
        liquidColor = Colors.greenAccent;
        break;
    }

    // Progress calculation
    final totalSeconds = timerProvider.initialDuration.inSeconds;
    final elapsedSeconds = totalSeconds - duration.inSeconds;
    final progress = totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic background with network image
          Image.network(
            bgUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: appTheme.scaffoldBackgroundColor,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: appTheme.scaffoldBackgroundColor,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              );
            },
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated timer digits
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (child, anim) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                    child: Text(
                      '$hours:$minutes:$seconds',
                      key: ValueKey('$hours:$minutes:$seconds'),
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
                  // Liquid progress indicator
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: LiquidCircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      valueColor: AlwaysStoppedAnimation(liquidColor),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      borderColor: Colors.white,
                      borderWidth: 2.0,
                      direction: Axis.vertical,
                      center: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons Row 1 (Start/Resume, Pause, Reset)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isStopped || isPaused ? 1.0 : 0.0,
                            child: ElevatedButton(
                              onPressed:
                                  isStopped || isPaused
                                      ? () =>
                                          context
                                              .read<TimerProvider>()
                                              .startTimer()
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appTheme.primaryColor,
                                foregroundColor: Colors.black,
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                isPaused ? 'Resume' : 'Start',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isRunning ? 1.0 : 0.0,
                            child: ElevatedButton(
                              onPressed:
                                  isRunning
                                      ? () =>
                                          context
                                              .read<TimerProvider>()
                                              .pauseTimer()
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appTheme.cardColor,
                                foregroundColor: Colors.black,
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Pause',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: !isStopped ? 1.0 : 0.0,
                            child: ElevatedButton(
                              onPressed:
                                  !isStopped
                                      ? () =>
                                          context
                                              .read<TimerProvider>()
                                              .resetTimer()
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appTheme.cardColor,
                                foregroundColor: Colors.black,
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Reset',
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
                  // Overtime display
                  if (timerProvider.overtime != null && !timerProvider.isBreak)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '+${timerProvider.overtime!.inMinutes.toString().padLeft(2, '0')}:${(timerProvider.overtime!.inSeconds % 60).toString().padLeft(2, '0')} overtime',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
