import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _targetController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _targetController = TextEditingController(
      text: settings.dailyStudyTarget.toString(),
    );
    _targetController.addListener(_onTargetChanged);
  }

  @override
  void dispose() {
    _targetController.removeListener(_onTargetChanged);
    _targetController.dispose();
    super.dispose();
  }

  void _onTargetChanged() {
    final currentValue = context.read<SettingsProvider>().dailyStudyTarget;
    final newValue = double.tryParse(_targetController.text) ?? currentValue;
    setState(() {
      _hasChanges = newValue != currentValue;
    });
  }

  Future<void> _saveSettings() async {
    final provider = context.read<SettingsProvider>();
    final newTarget = double.tryParse(_targetController.text);

    if (newTarget == null || newTarget <= 0) {
      _showErrorSnackBar(
        'Please enter a valid study target (greater than 0 hours)',
      );
      return;
    }

    try {
      await provider.updateDailyStudyTarget(newTarget);
      setState(() => _hasChanges = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save settings. Please try again.');
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await _showResetConfirmation();
    if (!confirmed) return;

    try {
      final provider = context.read<SettingsProvider>();
      await provider.resetToDefaults();
      _targetController.text = provider.dailyStudyTarget.toString();
      setState(() => _hasChanges = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to reset settings. Please try again.');
    }
  }

  Future<bool> _showResetConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Reset Settings'),
                content: const Text(
                  'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reset'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Study Target Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Study Target',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set your daily study time goal. This will be used to calculate your study averages and progress.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _targetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Daily Study Target (hours)',
                            hintText: 'e.g., 2.5',
                            prefixIcon: Icon(Icons.schedule),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Current target: ${provider.dailyStudyTarget} hours per day',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.blue[600]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Presets Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Presets',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose from common study targets:',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPresetChip(0.5, '30 min'),
                            _buildPresetChip(1.0, '1 hour'),
                            _buildPresetChip(1.5, '1.5 hours'),
                            _buildPresetChip(2.0, '2 hours'),
                            _buildPresetChip(3.0, '3 hours'),
                            _buildPresetChip(4.0, '4 hours'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _resetToDefaults,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset to Defaults'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChip(double hours, String label) {
    final isSelected = _targetController.text == hours.toString();

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _targetController.text = hours.toString();
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
