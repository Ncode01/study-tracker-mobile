import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../providers/home_providers.dart';

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  AppSettingsSnapshot? _settings;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final AppSettingsSnapshot snapshot =
        await AppSettingsService.instance.snapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = snapshot;
    });
  }

  Future<void> _setHaptics(bool value) async {
    setState(() {
      _settings = _settings?.copyWith(enableHaptics: value);
    });
    await AppSettingsService.instance.setEnableHaptics(value);
  }

  Future<void> _setSound(bool value) async {
    setState(() {
      _settings = _settings?.copyWith(enableSound: value);
    });
    await AppSettingsService.instance.setEnableSound(value);
  }

  Future<void> _setKeepScreenAwake(bool value) async {
    setState(() {
      _settings = _settings?.copyWith(keepScreenAwake: value);
    });
    await ref
        .read(homeViewNotifierProvider.notifier)
        .setKeepScreenAwakeEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    final AppSettingsSnapshot? settings = _settings;

    return SafeArea(
      top: false,
      child: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child:
            settings == null
                ? const _SettingsLoading()
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.glassBorder,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Settings',
                      style: AppTypography.heading(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tune sensory feedback and battery behavior.',
                      style: AppTypography.display(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsToggleTile(
                      title: 'Enable Haptics',
                      subtitle: 'Vibration feedback on taps and timer events.',
                      value: settings.enableHaptics,
                      onChanged: (bool value) => unawaited(_setHaptics(value)),
                    ),
                    const SizedBox(height: 10),
                    _SettingsToggleTile(
                      title: 'Enable Sound',
                      subtitle:
                          'Play audio cues when sessions start or complete.',
                      value: settings.enableSound,
                      onChanged: (bool value) => unawaited(_setSound(value)),
                    ),
                    const SizedBox(height: 10),
                    _SettingsToggleTile(
                      title: 'Keep Screen Awake',
                      subtitle:
                          'Prevent screen sleep while deep-work sessions run.',
                      value: settings.keepScreenAwake,
                      onChanged:
                          (bool value) => unawaited(_setKeepScreenAwake(value)),
                    ),
                  ],
                ),
      ),
    );
  }
}

class _SettingsLoading extends StatelessWidget {
  const _SettingsLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Text(
          'Loading settings...',
          style: AppTypography.display(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.display(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.display(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeColor: AppColors.primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
