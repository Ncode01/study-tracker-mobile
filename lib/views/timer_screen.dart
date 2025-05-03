import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wakelock/wakelock.dart';
import 'package:bytelearn_study_tracker/controllers/providers/project_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/timer_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/settings_provider.dart';
import 'package:bytelearn_study_tracker/models/project.dart';
import 'package:bytelearn_study_tracker/models/settings.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedProjectId;
  bool _isSettingsExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Start pulsing animation if timer is already running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );

      if (timerProvider.isRunning) {
        _animationController.repeat(reverse: true);
        _notesController.text = timerProvider.notes;
        _selectedProjectId = timerProvider.projectId;

        // Enable wakelock if configured
        if (settingsProvider.settings.timerSettings.keepScreenOn) {
          Wakelock.enable();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProjectProvider, TimerProvider, SettingsProvider>(
      builder: (
        context,
        projectProvider,
        timerProvider,
        settingsProvider,
        child,
      ) {
        final isRunning = timerProvider.isRunning;
        final isPomodoroEnabled =
            settingsProvider.settings.timerSettings.usePomodoroTimer;
        final timerMode = timerProvider.currentMode;

        // Update animation controller based on timer state
        if (isRunning && !_animationController.isAnimating) {
          _animationController.repeat(reverse: true);

          // Enable wakelock if configured
          if (settingsProvider.settings.timerSettings.keepScreenOn) {
            Wakelock.enable();
          }
        } else if (!isRunning && _animationController.isAnimating) {
          _animationController.stop();
          _animationController.reset();

          // Disable wakelock when timer is not running
          Wakelock.disable();
        }

        // Determine timer color based on current mode
        Color timerColor;
        String modeText;
        IconData modeIcon;

        switch (timerMode) {
          case TimerMode.focus:
            timerColor = Theme.of(context).colorScheme.primary;
            modeText = "Focus Time";
            modeIcon = Icons.psychology;
            break;
          case TimerMode.shortBreak:
            timerColor = Colors.teal;
            modeText = "Short Break";
            modeIcon = Icons.coffee;
            break;
          case TimerMode.longBreak:
            timerColor = Colors.purple;
            modeText = "Long Break";
            modeIcon = Icons.self_improvement;
            break;
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and help button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Study Timer',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          // Settings toggle button
                          IconButton(
                            icon: Icon(
                              _isSettingsExpanded
                                  ? Icons.settings
                                  : Icons.settings_outlined,
                              color:
                                  _isSettingsExpanded
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _isSettingsExpanded = !_isSettingsExpanded;
                              });
                            },
                            tooltip: 'Timer Settings',
                          ),
                          IconButton(
                            icon: const Icon(Icons.help_outline),
                            onPressed: _showTimerHelp,
                            tooltip: 'Timer Help',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Quick Timer Settings (Expandable)
                  AnimatedCrossFade(
                    firstChild: const SizedBox(height: 0),
                    secondChild: _buildQuickSettings(settingsProvider),
                    crossFadeState:
                        _isSettingsExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  const SizedBox(height: 16),

                  // Current Mode Indicator (if Pomodoro is enabled)
                  if (isPomodoroEnabled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: timerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(modeIcon, color: timerColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            modeText,
                            style: TextStyle(
                              color: timerColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (timerMode == TimerMode.focus)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: timerColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Session ${timerProvider.completedFocusSessions + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Project selection card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Project',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildProjectSelection(
                            context,
                            projectProvider,
                            enabled:
                                !isRunning ||
                                timerProvider.activeSession == null,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Timer display with circular progress
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final pulseFactor =
                            isRunning
                                ? 1.0 + (_animationController.value * 0.03)
                                : 1.0;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow and shadow
                            Container(
                              height: 240,
                              width: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                boxShadow:
                                    isRunning
                                        ? [
                                          BoxShadow(
                                            color: timerColor.withOpacity(0.2),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                        : null,
                              ),
                            ).animate().scale(
                              duration: 300.ms,
                              curve: Curves.easeOut,
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.0, 1.0),
                            ),

                            // Progress circle
                            Transform.scale(
                              scale: pulseFactor,
                              child: SizedBox(
                                height: 220,
                                width: 220,
                                child: CircularProgressIndicator(
                                  value:
                                      isPomodoroEnabled
                                          ? timerProvider.progress
                                          : null,
                                  strokeWidth: 8,
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  color: timerColor,
                                ),
                              ),
                            ),

                            // Inner timer container
                            Transform.scale(
                              scale: pulseFactor,
                              child: Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                            isPomodoroEnabled
                                                ? timerProvider
                                                    .formattedRemainingTime
                                                : timerProvider
                                                    .formattedElapsedTime,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.displaySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: timerColor,
                                            ),
                                          )
                                          .animate(target: isRunning ? 1 : 0)
                                          .shimmer(
                                            duration: 1000.ms,
                                            delay: 200.ms,
                                            curve: Curves.easeInOut,
                                          )
                                          .then()
                                          .fadeIn(duration: 200.ms),
                                      if (isRunning)
                                        Text(
                                          isPomodoroEnabled
                                              ? 'Remaining'
                                              : 'Elapsed Time',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            color: timerColor.withOpacity(0.8),
                                          ),
                                        ).animate().fadeIn(duration: 300.ms),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timer controls
                  Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        if (!isRunning && timerProvider.activeSession == null)
                          _buildTimerButton(
                            icon: Icons.play_arrow,
                            label: 'Start',
                            color: Colors.green,
                            onPressed:
                                _selectedProjectId == null
                                    ? null
                                    : () => _startTimer(
                                      timerProvider,
                                      settingsProvider,
                                    ),
                          ),
                        if (isRunning)
                          _buildTimerButton(
                            icon: Icons.pause,
                            label: 'Pause',
                            color: Colors.orange,
                            onPressed: () => timerProvider.pauseTimer(),
                          ),
                        if (!isRunning && timerProvider.activeSession != null)
                          _buildTimerButton(
                            icon: Icons.play_arrow,
                            label: 'Resume',
                            color: Colors.green,
                            onPressed: () => timerProvider.resumeTimer(),
                          ),
                        if (timerProvider.activeSession != null)
                          _buildTimerButton(
                            icon: Icons.stop,
                            label: 'Stop',
                            color: Colors.red,
                            onPressed:
                                () => _stopTimer(
                                  context,
                                  timerProvider,
                                  projectProvider,
                                ),
                          ),
                        if (isPomodoroEnabled && isRunning)
                          _buildTimerButton(
                            icon: Icons.skip_next,
                            label: 'Skip',
                            color: Colors.blueGrey,
                            onPressed:
                                () => _skipInterval(
                                  timerProvider,
                                  settingsProvider,
                                ),
                          ),
                        if (timerProvider.activeSession != null)
                          _buildTimerButton(
                            icon: Icons.refresh,
                            label: 'Reset',
                            color: Colors.grey,
                            onPressed:
                                () => _resetTimer(context, timerProvider),
                          ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),
                  ),

                  const SizedBox(height: 24),

                  // Notes field
                  Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Session Notes',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'What are you working on?',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                onChanged: (value) {
                                  if (timerProvider.activeSession != null) {
                                    timerProvider.updateNotes(value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(
                        duration: 300.ms,
                        curve: Curves.easeOut,
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                      ),

                  // Pomodoro Status
                  if (isPomodoroEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pomodoro Cycle',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: timerColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${timerProvider.completedFocusSessions} / ${settingsProvider.timerSettings.sessionsBeforeLongBreak}',
                                      style: TextStyle(
                                        color: timerColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildPomodoroSetting(
                                    'Focus',
                                    '${settingsProvider.timerSettings.workDuration}m',
                                    Icons.psychology,
                                    Theme.of(context).colorScheme.primary,
                                    isActive: timerMode == TimerMode.focus,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildPomodoroSetting(
                                    'Short Break',
                                    '${settingsProvider.timerSettings.shortBreakDuration}m',
                                    Icons.coffee,
                                    Colors.teal,
                                    isActive: timerMode == TimerMode.shortBreak,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildPomodoroSetting(
                                    'Long Break',
                                    '${settingsProvider.timerSettings.longBreakDuration}m',
                                    Icons.self_improvement,
                                    Colors.purple,
                                    isActive: timerMode == TimerMode.longBreak,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSettings(SettingsProvider settingsProvider) {
    final timerSettings = settingsProvider.timerSettings;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timer Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Pomodoro toggle
            SwitchListTile(
              title: const Text('Use Pomodoro Technique'),
              subtitle: const Text(
                'Alternate between focus and break intervals',
              ),
              value: timerSettings.usePomodoroTimer,
              onChanged: (value) {
                settingsProvider.updateTimerSettings(
                  timerSettings.copyWith(usePomodoroTimer: value),
                );
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),

            const Divider(),

            // Keep screen on toggle
            SwitchListTile(
              title: const Text('Keep Screen On'),
              subtitle: const Text(
                'Prevent screen from turning off during active sessions',
              ),
              value: timerSettings.keepScreenOn,
              onChanged: (value) {
                settingsProvider.updateTimerSettings(
                  timerSettings.copyWith(keepScreenOn: value),
                );

                // Apply setting immediately
                if (value) {
                  Wakelock.enable();
                } else {
                  Wakelock.disable();
                }
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),

            const Divider(),

            // Sound notification toggle
            SwitchListTile(
              title: const Text('Sound Notifications'),
              subtitle: const Text('Play sound when timer completes'),
              value: timerSettings.playSoundOnComplete,
              onChanged: (value) {
                settingsProvider.updateTimerSettings(
                  timerSettings.copyWith(playSoundOnComplete: value),
                );
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),

            // Duration settings
            if (timerSettings.usePomodoroTimer) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Interval Durations',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Focus Duration slider
              _buildDurationSlider(
                'Focus Duration',
                timerSettings.workDuration,
                (value) {
                  settingsProvider.updateTimerSettings(
                    timerSettings.copyWith(workDuration: value),
                  );
                },
                min: 1,
                max: 60,
                icon: Icons.psychology,
                color: Theme.of(context).colorScheme.primary,
              ),

              // Short Break Duration slider
              _buildDurationSlider(
                'Short Break',
                timerSettings.shortBreakDuration,
                (value) {
                  settingsProvider.updateTimerSettings(
                    timerSettings.copyWith(shortBreakDuration: value),
                  );
                },
                min: 1,
                max: 15,
                icon: Icons.coffee,
                color: Colors.teal,
              ),

              // Long Break Duration slider
              _buildDurationSlider(
                'Long Break',
                timerSettings.longBreakDuration,
                (value) {
                  settingsProvider.updateTimerSettings(
                    timerSettings.copyWith(longBreakDuration: value),
                  );
                },
                min: 5,
                max: 30,
                icon: Icons.self_improvement,
                color: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildDurationSlider(
    String label,
    int value,
    Function(int) onChanged, {
    required int min,
    required int max,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value min',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: color,
          onChanged: (double value) {
            onChanged(value.round());
          },
        ),
      ],
    );
  }

  Widget _buildProjectSelection(
    BuildContext context,
    ProjectProvider projectProvider, {
    bool enabled = true,
  }) {
    final projects = projectProvider.activeProjects;

    if (projects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No active projects found. Create a project first.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
            onPressed: () {
              Navigator.of(context).pushNamed('/create-project');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedProjectId ?? projects.first.id,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
          ),
          items:
              projects.map((project) {
                return DropdownMenuItem<String>(
                  value: project.id,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getProjectColor(project.category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          project.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged:
              enabled
                  ? (value) {
                    setState(() {
                      _selectedProjectId = value;
                    });
                    HapticFeedback.selectionClick();
                  }
                  : null,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
        ),
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Cannot change project during an active session',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
        elevation: 2,
      ),
      onPressed:
          onPressed == null
              ? null
              : () {
                HapticFeedback.mediumImpact();
                onPressed();
              },
    ).animate().scale(duration: 200.ms);
  }

  Widget _buildPomodoroSetting(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isActive = false,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              isActive
                  ? Border.all(color: color, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProjectColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'study':
        return Colors.purple;
      case 'personal':
        return Colors.green;
      case 'fitness':
        return Colors.orange;
      case 'reading':
        return Colors.red;
      default:
        // Generate a color based on the hash of the category name
        final hash = category.hashCode;
        return Color((hash & 0xFFFFFF) | 0xFF000000);
    }
  }

  void _startTimer(
    TimerProvider timerProvider,
    SettingsProvider settingsProvider,
  ) {
    if (_selectedProjectId == null) return;

    HapticFeedback.mediumImpact();

    timerProvider.startTimer(
      _selectedProjectId!,
      notes: _notesController.text,
      settings: settingsProvider.timerSettings,
    );
  }

  void _skipInterval(
    TimerProvider timerProvider,
    SettingsProvider settingsProvider,
  ) {
    HapticFeedback.mediumImpact();
    timerProvider.skipInterval(settingsProvider.timerSettings);
  }

  void _resetTimer(BuildContext context, TimerProvider timerProvider) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Timer?'),
          content: const Text(
            'This will cancel your current session without saving. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      timerProvider.resetTimer();
      _notesController.clear();
    }
  }

  Future<void> _stopTimer(
    BuildContext context,
    TimerProvider timerProvider,
    ProjectProvider projectProvider,
  ) async {
    // Show confirmation dialog
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Stop Session?'),
          content: const Text(
            'This will end your current study session. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Stop Session'),
            ),
          ],
        );
      },
    );

    if (shouldStop != true) return;

    // Stop the timer and save session
    final session = await timerProvider.stopTimer(
      updatedNotes: _notesController.text,
    );

    // Update the project with this session
    await projectProvider.addSessionToProject(session.projectId, session.id);

    // Reset notes controller
    _notesController.clear();

    // Show completion snackbar
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Study session saved'),
                  Text(
                    'Duration: ${session.formattedDuration}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showTimerHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Timer Help'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem(
                  '1',
                  'Select a project you\'re working on',
                  Icons.folder_outlined,
                ),
                _buildHelpItem(
                  '2',
                  'Add optional notes about your session',
                  Icons.note_alt_outlined,
                ),
                _buildHelpItem(
                  '3',
                  'Press "Start" to begin timing your study session',
                  Icons.play_arrow,
                ),
                _buildHelpItem(
                  '4',
                  'You can pause/resume if needed',
                  Icons.pause,
                ),
                _buildHelpItem(
                  '5',
                  'When finished, press "Stop" to save your session',
                  Icons.stop,
                ),
                const Divider(height: 32),
                const Text(
                  'Pomodoro Timer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The Pomodoro Technique is a time management method that uses alternate focus and break intervals to improve productivity.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  'Focus',
                  'Work on a task with full concentration',
                  Icons.psychology,
                ),
                _buildHelpItem(
                  'Short Break',
                  'Take a short rest between focus sessions',
                  Icons.coffee,
                ),
                _buildHelpItem(
                  'Long Break',
                  'Enjoy a longer break after completing four focus sessions',
                  Icons.self_improvement,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your study sessions will be tracked and appear in your project details and statistics.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(String label, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
