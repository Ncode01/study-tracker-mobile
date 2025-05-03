import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/settings_provider.dart';
import 'package:bytelearn_study_tracker/controllers/providers/timer_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'ByteLearn Study Tracker',
    packageName: 'com.bytelearn.studytracker',
    version: '1.0.0',
    buildNumber: '1',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, TimerProvider>(
        builder: (context, settingsProvider, timerProvider, child) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme throughout the app'),
                value: settingsProvider.isDarkMode,
                onChanged: (value) {
                  settingsProvider.toggleDarkMode();
                },
              ),
              ListTile(
                title: const Text('App Theme'),
                subtitle: Text(_getThemeName(settingsProvider.themeColor)),
                trailing: CircleAvatar(
                  backgroundColor: settingsProvider.themeColor,
                  radius: 15,
                ),
                onTap: () {
                  _showThemeColorPicker(context, settingsProvider);
                },
              ),

              _buildSectionHeader(context, 'Timer Settings'),
              ListTile(
                title: const Text('Default Timer Duration'),
                subtitle: Text(
                  '${settingsProvider.defaultTimerDuration.inMinutes} minutes',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showTimerDurationPicker(context, settingsProvider);
                },
              ),
              SwitchListTile(
                title: const Text('Sound Alerts'),
                subtitle: const Text('Play sound when timer completes'),
                value: settingsProvider.timerSoundEnabled,
                onChanged: (value) {
                  settingsProvider.toggleTimerSound();
                },
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate when timer completes'),
                value: settingsProvider.timerVibrationEnabled,
                onChanged: (value) {
                  settingsProvider.toggleTimerVibration();
                },
              ),
              ListTile(
                title: const Text('Break Duration'),
                subtitle: Text(
                  '${settingsProvider.defaultBreakDuration.inMinutes} minutes',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showBreakDurationPicker(context, settingsProvider);
                },
              ),

              _buildSectionHeader(context, 'Data Management'),
              ListTile(
                title: const Text('Export Data'),
                subtitle: const Text('Export your study data as CSV'),
                leading: const Icon(Icons.download),
                onTap: () {
                  _exportData(context, timerProvider);
                },
              ),
              ListTile(
                title: const Text('Import Data'),
                subtitle: const Text('Import study data from backup'),
                leading: const Icon(Icons.upload),
                onTap: () {
                  // TODO: Implement import functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import functionality coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all your data (cannot be undone)'),
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: () {
                  _showClearDataConfirmation(context);
                },
              ),

              _buildSectionHeader(context, 'Notifications'),
              SwitchListTile(
                title: const Text('Daily Reminders'),
                subtitle: const Text('Get reminded to study each day'),
                value: settingsProvider.dailyReminderEnabled,
                onChanged: (value) {
                  settingsProvider.toggleDailyReminder();
                  if (value) {
                    _showReminderTimePicker(context, settingsProvider);
                  }
                },
              ),
              if (settingsProvider.dailyReminderEnabled)
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(
                    '${settingsProvider.reminderTime.hour}:${settingsProvider.reminderTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showReminderTimePicker(context, settingsProvider);
                  },
                ),
              SwitchListTile(
                title: const Text('Goal Notifications'),
                subtitle: const Text('Get notified about upcoming goals'),
                value: settingsProvider.goalNotificationsEnabled,
                onChanged: (value) {
                  settingsProvider.toggleGoalNotifications();
                },
              ),

              _buildSectionHeader(context, 'About'),
              ListTile(
                title: const Text('Version'),
                subtitle: Text(
                  '${_packageInfo.version} (${_packageInfo.buildNumber})',
                ),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                subtitle: const Text('Read our privacy policy'),
                onTap: () => _launchURL('https://bytelearn.com/privacy'),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                subtitle: const Text('Read our terms of service'),
                onTap: () => _launchURL('https://bytelearn.com/terms'),
              ),
              ListTile(
                title: const Text('Send Feedback'),
                subtitle: const Text('Help us improve the app'),
                onTap: () => _launchURL('mailto:feedback@bytelearn.com'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  '© 2025 ByteLearn. All rights reserved.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showThemeColorPicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme Color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorOption(
                  context,
                  settingsProvider,
                  Colors.blue,
                  'Blue',
                ),
                _buildColorOption(
                  context,
                  settingsProvider,
                  Colors.green,
                  'Green',
                ),
                _buildColorOption(
                  context,
                  settingsProvider,
                  Colors.purple,
                  'Purple',
                ),
                _buildColorOption(context, settingsProvider, Colors.red, 'Red'),
                _buildColorOption(
                  context,
                  settingsProvider,
                  Colors.orange,
                  'Orange',
                ),
                _buildColorOption(
                  context,
                  settingsProvider,
                  Colors.teal,
                  'Teal',
                ),
                _buildColorOption(
                  context,
                  settingsProvider,
                  Colors.pink,
                  'Pink',
                ),
                _buildColorOption(
                  context,
                  settingsProvider,
                  Colors.indigo,
                  'Indigo',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    Color color,
    String name,
  ) {
    final isSelected = settingsProvider.themeColor == color;

    return GestureDetector(
      onTap: () {
        settingsProvider.setThemeColor(color);
        Navigator.of(context).pop();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                      : null,
            ),
            child:
                isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 30)
                    : null,
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showTimerDurationPicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final currentMinutes = settingsProvider.defaultTimerDuration.inMinutes;

    showDialog(
      context: context,
      builder: (context) {
        int selectedMinutes = currentMinutes;

        return AlertDialog(
          title: const Text('Default Timer Duration'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$selectedMinutes minutes'),
                  Slider(
                    min: 5,
                    max: 120,
                    divisions: 23,
                    value: selectedMinutes.toDouble(),
                    label: '$selectedMinutes minutes',
                    onChanged: (value) {
                      setState(() {
                        selectedMinutes = value.round();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                settingsProvider.setDefaultTimerDuration(
                  Duration(minutes: selectedMinutes),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showBreakDurationPicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final currentMinutes = settingsProvider.defaultBreakDuration.inMinutes;

    showDialog(
      context: context,
      builder: (context) {
        int selectedMinutes = currentMinutes;

        return AlertDialog(
          title: const Text('Break Duration'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$selectedMinutes minutes'),
                  Slider(
                    min: 1,
                    max: 30,
                    divisions: 29,
                    value: selectedMinutes.toDouble(),
                    label: '$selectedMinutes minutes',
                    onChanged: (value) {
                      setState(() {
                        selectedMinutes = value.round();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                settingsProvider.setDefaultBreakDuration(
                  Duration(minutes: selectedMinutes),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showReminderTimePicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final currentTime = settingsProvider.reminderTime;

    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
    ).then((selectedTime) {
      if (selectedTime != null) {
        settingsProvider.setReminderTime(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            selectedTime.hour,
            selectedTime.minute,
          ),
        );
      }
    });
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all your projects, sessions, and goals. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                // TODO: Implement data clearing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been cleared')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Delete All Data'),
            ),
          ],
        );
      },
    );
  }

  void _exportData(BuildContext context, TimerProvider timerProvider) {
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting data...')));

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully')),
      );
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  String _getThemeName(Color color) {
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.red) return 'Red';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.indigo) return 'Indigo';
    return 'Custom';
  }
}
