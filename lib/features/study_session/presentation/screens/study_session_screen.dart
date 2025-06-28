import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../theme/app_colors.dart';
import '../../../study/domain/models/subject_model.dart';

/// Full study session screen with Pomodoro timer and progress tracking
class StudySessionScreen extends ConsumerStatefulWidget {
  final Subject? subject;

  const StudySessionScreen({super.key, this.subject});

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen>
    with TickerProviderStateMixin {
  // Timer variables
  Timer? _timer;
  int _totalSeconds = 25 * 60; // 25 minutes default
  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;

  // Session configuration
  final List<int> _timerOptions = [5, 15, 25, 45, 60]; // minutes
  int _selectedDuration = 25;

  // Progress tracking
  int _xpEarned = 0;
  int _completedCycles = 0;
  // Animations
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      _isPaused = false;
    } else {
      _currentSeconds = _selectedDuration * 60;
      _totalSeconds = _selectedDuration * 60;
    }

    _isRunning = true;
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
        } else {
          _completeSession();
        }
      });
    });

    setState(() {});
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _currentSeconds = _selectedDuration * 60;
    _totalSeconds = _selectedDuration * 60;
    _progressController.reset();
    setState(() {});
  }

  void _completeSession() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _completedCycles++;

    // Calculate XP based on study duration
    final earnedXP = (_selectedDuration * 2); // 2 XP per minute
    _xpEarned += earnedXP;

    _showCompletionDialog(earnedXP);
    setState(() {});
  }

  void _showCompletionDialog(int earnedXP) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.celebration, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                const Text('Quest Complete!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.treasureGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 48,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '+$earnedXP XP',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: AppColors.treasureGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Excellent work on your ${widget.subject?.name ?? 'study'} adventure!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetTimer();
                },
                child: const Text('Study More'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.treasureGreen,
                  foregroundColor: AppColors.parchmentWhite,
                ),
                child: const Text('Return to Map'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalSeconds > 0
            ? (_totalSeconds - _currentSeconds) / _totalSeconds
            : 0.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.subject?.name ?? 'Study Session'),
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: AppColors.parchmentWhite,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _resetTimer,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Timer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header with subject info
            _buildSubjectHeader(),
            const SizedBox(height: 32),

            // Timer display
            _buildTimerDisplay(progress),
            const SizedBox(height: 32),

            // Duration selector
            if (!_isRunning && !_isPaused) _buildDurationSelector(),
            if (!_isRunning && !_isPaused) const SizedBox(height: 32),

            // Control buttons
            _buildControlButtons(),
            const SizedBox(height: 32),

            // Session stats
            _buildSessionStats(),
            const SizedBox(height: 32),

            // Study tips
            _buildStudyTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGold.withValues(alpha: 0.1),
            AppColors.skyBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school,
              color: AppColors.primaryGold,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject?.name ?? 'General Study',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current Quest Session',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.fadeGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(double progress) {
    final minutes = _currentSeconds ~/ 60;
    final seconds = _currentSeconds % 60;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGold, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Progress indicator
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isRunning
                          ? AppColors.treasureGreen
                          : AppColors.primaryGold,
                    ),
                  ),
                ),
                // Timer text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRunning
                            ? 'Studying...'
                            : _isPaused
                            ? 'Paused'
                            : 'Ready to Start',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.fadeGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      children: [
        Text(
          'Select Study Duration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              _timerOptions.map((duration) {
                final isSelected = duration == _selectedDuration;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                      _currentSeconds = duration * 60;
                      _totalSeconds = duration * 60;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primaryGold
                              : AppColors.parchmentWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primaryGold
                                : AppColors.lightGray,
                      ),
                    ),
                    child: Text(
                      '${duration}m',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? AppColors.parchmentWhite
                                : AppColors.primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!_isRunning) ...[
          ElevatedButton.icon(
            onPressed: _startTimer,
            icon: const Icon(Icons.play_arrow),
            label: Text(_isPaused ? 'Resume' : 'Start Quest'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.treasureGreen,
              foregroundColor: AppColors.parchmentWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: _pauseTimer,
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningOrange,
              foregroundColor: AppColors.parchmentWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
        OutlinedButton.icon(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.map),
          label: const Text('Return to Map'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBrown,
            side: const BorderSide(color: AppColors.primaryBrown),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.parchmentWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        children: [
          Text(
            'Session Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Cycles', '$_completedCycles', Icons.refresh),
              _buildStatItem('XP Earned', '$_xpEarned', Icons.star),
              _buildStatItem(
                'Focus Time',
                '${(_completedCycles * _selectedDuration)}m',
                Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.fadeGray),
        ),
      ],
    );
  }

  Widget _buildStudyTips() {
    final tips = [
      '💡 Take notes during your study session',
      '🎯 Focus on one topic at a time',
      '⏰ Take breaks between study cycles',
      '📚 Review what you learned after each session',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.skyBlue),
              const SizedBox(width: 8),
              Text(
                'Study Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.skyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                tip,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.fadeGray),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
