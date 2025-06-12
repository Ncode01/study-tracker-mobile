import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/models/project_model.dart';

/// StudyTimerScreen: A modern Pomodoro timer UI connected to TimerServiceProvider.
class StudyTimerScreen extends StatefulWidget {
  final Project project;

  const StudyTimerScreen({super.key, required this.project});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerServiceProvider>().selectMode(TimerMode.focus);
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getModeText(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'Focus';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerServiceProvider>(
      builder: (context, timerProvider, child) {
        final progress =
            timerProvider.initialDuration.inSeconds > 0
                ? 1.0 -
                    (timerProvider.currentDuration.inSeconds /
                        timerProvider.initialDuration.inSeconds)
                : 0.0;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: _buildAppBar(),
          body: _buildBody(timerProvider, progress),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.project.name,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Tap to select a task',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TimerServiceProvider timerProvider, double progress) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildProgressBar(),
          const SizedBox(height: 40),
          Expanded(
            child: Center(child: _buildCircularTimer(timerProvider, progress)),
          ),
          const SizedBox(height: 40),
          _buildModeButtons(timerProvider),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progressPercent =
        widget.project.goalMinutes > 0
            ? (widget.project.loggedMinutes / widget.project.goalMinutes * 100)
                .clamp(0, 100)
            : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_formatDuration(Duration(minutes: widget.project.loggedMinutes))} / ${_formatDuration(Duration(minutes: widget.project.goalMinutes))}',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercent / 100,
            backgroundColor: AppColors.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTimer(
    TimerServiceProvider timerProvider,
    double progress,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularPercentIndicator(
          radius: 150.0,
          lineWidth: 12.0,
          percent: progress.clamp(0.0, 1.0),
          center: _buildTimerCenter(timerProvider),
          progressColor: AppColors.primaryColor,
          backgroundColor: AppColors.primaryColor.withAlpha(
            (0.1 * 255).round(),
          ),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        Positioned(top: 20, right: 20, child: _buildSessionIndicator()),
      ],
    );
  }

  Widget _buildTimerCenter(TimerServiceProvider timerProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Remaining',
          style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          _formatDuration(timerProvider.currentDuration),
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getModeText(timerProvider.currentMode),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        FloatingActionButton.large(
          onPressed: () => _handleTimerAction(timerProvider),
          backgroundColor: AppColors.primaryColor,
          child: Icon(
            _getControlIcon(timerProvider.status),
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: AppColors.primaryColor, size: 16),
          SizedBox(width: 4),
          Text(
            '1/4',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.settings, color: AppColors.secondaryTextColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildModeButtons(TimerServiceProvider timerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildModeButton(TimerMode.focus, 'Focus', timerProvider),
        _buildModeButton(TimerMode.shortBreak, 'Short Break', timerProvider),
        _buildModeButton(TimerMode.longBreak, 'Long Break', timerProvider),
      ],
    );
  }

  Widget _buildModeButton(
    TimerMode mode,
    String label,
    TimerServiceProvider timerProvider,
  ) {
    final isSelected = timerProvider.currentMode == mode;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => timerProvider.selectMode(mode),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? AppColors.primaryColor : AppColors.cardColor,
            foregroundColor: isSelected ? Colors.white : AppColors.textColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTimerAction(TimerServiceProvider timerProvider) {
    switch (timerProvider.status) {
      case TimerStatus.stopped:
        timerProvider.startTimer(widget.project, context);
        break;
      case TimerStatus.running:
        timerProvider.pauseTimer();
        break;
      case TimerStatus.paused:
        timerProvider.resumeTimer();
        break;
    }
  }

  IconData _getControlIcon(TimerStatus status) {
    switch (status) {
      case TimerStatus.stopped:
      case TimerStatus.paused:
        return Icons.play_arrow;
      case TimerStatus.running:
        return Icons.pause;
    }
  }
}
