import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/journey_map_colors.dart';
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
    final borderColor = const Color(0xFFD2B48C);
    final timerBgColor = const Color(0xFFF0E6DB);
    final startButtonColor = const Color(0xFFD2E2F3);
    final isRunning = timerProvider.status == TimerStatus.running;
    final isPaused = timerProvider.status == TimerStatus.paused;
    final isStopped = timerProvider.status == TimerStatus.stopped;

    return Scaffold(
      backgroundColor: JourneyMapColors.background,
      appBar: AppBar(
        backgroundColor: JourneyMapColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: JourneyMapColors.primaryText,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Study Timer',
          style: TextStyle(
            fontFamily: 'Caveat',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: JourneyMapColors.primaryText,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Timer Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimerSection(
                      value: hours,
                      label: 'Hours',
                      bgColor: timerBgColor,
                      borderColor: borderColor,
                      fontFamily: 'Caveat',
                    ),
                    const SizedBox(width: 16),
                    _TimerSection(
                      value: minutes,
                      label: 'Minutes',
                      bgColor: timerBgColor,
                      borderColor: borderColor,
                      fontFamily: 'Caveat',
                    ),
                    const SizedBox(width: 16),
                    _TimerSection(
                      value: seconds,
                      label: 'Seconds',
                      bgColor: timerBgColor,
                      borderColor: borderColor,
                      fontFamily: 'Caveat',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Animated Focus/Break Label
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child: Text(
                    timerProvider.isBreak ? 'Break Time' : 'Focus Time',
                    key: ValueKey<bool>(timerProvider.isBreak),
                    style: const TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: null, // color set below
                    ).copyWith(
                      color:
                          timerProvider.isBreak
                              ? Colors.green
                              : JourneyMapColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                // Creative animated element instead of image
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          timerProvider.isBreak
                              ? Colors.green.withOpacity(0.12)
                              : JourneyMapColors.accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color:
                            timerProvider.isBreak
                                ? Colors.green
                                : JourneyMapColors.accent,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (timerProvider.isBreak
                                  ? Colors.green
                                  : JourneyMapColors.accent)
                              .withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final double scale =
                              1.0 + 0.08 * _pulseController.value;
                          return Transform.scale(
                            scale: scale,
                            child: Icon(
                              timerProvider.isBreak
                                  ? Icons.spa
                                  : Icons.local_fire_department,
                              color:
                                  timerProvider.isBreak
                                      ? Colors.green
                                      : JourneyMapColors.accent,
                              size: 64,
                            ),
                          );
                        },
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
                              backgroundColor: startButtonColor,
                              foregroundColor: Colors.black,
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              isPaused ? 'Resume' : 'Start',
                              style: const TextStyle(
                                fontFamily: 'Caveat',
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
                              backgroundColor: timerBgColor,
                              foregroundColor: Colors.black,
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Pause',
                              style: TextStyle(
                                fontFamily: 'Caveat',
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
                              backgroundColor: timerBgColor,
                              foregroundColor: Colors.black,
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontFamily: 'Caveat',
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
                        fontFamily: 'Caveat',
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
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  final String value;
  final String label;
  final Color bgColor;
  final Color borderColor;
  final String fontFamily;
  const _TimerSection({
    required this.value,
    required this.label,
    required this.bgColor,
    required this.borderColor,
    this.fontFamily = 'Caveat',
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: JourneyMapColors.primaryText,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            color: JourneyMapColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
