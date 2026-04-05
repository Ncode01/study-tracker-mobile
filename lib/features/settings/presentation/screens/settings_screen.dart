import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../../clubs/presentation/providers/clubs_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/ambient_background.dart';
import '../../../hub/presentation/providers/hub_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AppSettingsSnapshot? _settings;
  bool _isWipingData = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    final AppSettingsSnapshot snapshot =
        await ref.read(appSettingsServiceProvider).snapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = snapshot;
    });
  }

  Future<void> _toggleHaptics(bool value) async {
    setState(() {
      _settings = _settings?.copyWith(enableHaptics: value);
    });
    await ref.read(appSettingsServiceProvider).setEnableHaptics(value);
  }

  Future<void> _toggleAudio(bool value) async {
    setState(() {
      _settings = _settings?.copyWith(enableSound: value);
    });
    await ref.read(appSettingsServiceProvider).setEnableSound(value);
  }

  Future<void> _toggleKeepAwake(bool value) async {
    setState(() {
      _settings = _settings?.copyWith(keepScreenAwake: value);
    });
    await ref
        .read(homeViewNotifierProvider.notifier)
        .setKeepScreenAwakeEnabled(value);
  }

  Future<void> _setFocusMinutes(int minutes) async {
    setState(() {
      _settings = _settings?.copyWith(defaultFocusMinutes: minutes);
    });

    await ref
        .read(homeViewNotifierProvider.notifier)
        .updateDefaultFocusDurationMinutes(minutes);
  }

  Future<void> _wipeAllData() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF11131A),
          title: Text(l10n.settingsDialogWipeTitle),
          content: Text(l10n.settingsDialogWipeMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.settingsWipe),
            ),
          ],
        );
      },
    );

    if (confirmed != true || _isWipingData) {
      return;
    }

    setState(() {
      _isWipingData = true;
    });

    await ref.read(databaseHelperProvider).wipeAllData();
    await ref.read(appSettingsServiceProvider).resetAll();

    ref.invalidate(homeViewNotifierProvider);
    ref.invalidate(analyticsViewProvider);
    ref.invalidate(hubViewProvider);
    ref.invalidate(calendarViewProvider);
    ref.invalidate(clubsViewProvider);

    if (!mounted) {
      return;
    }

    setState(() {
      _isWipingData = false;
    });

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final AppSettingsSnapshot settings =
        _settings ??
        const AppSettingsSnapshot(
          enableHaptics: true,
          enableSound: true,
          keepScreenAwake: true,
          onboardingCompleted: false,
          defaultFocusMinutes: 60,
        );

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(accentColor: AppColors.primaryPurple),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GlassContainer(
                        borderRadius: BorderRadius.circular(14),
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.settingsTitle,
                        style: AppTypography.heading(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GlassContainer(
                    borderRadius: BorderRadius.circular(26),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF8554F8),
                                Color(0xFF3B82F6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'T',
                              style: AppTypography.heading(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.settingsProfilePlanTitle,
                                style: AppTypography.heading(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.settingsProfileSubtitle,
                                style: AppTypography.display(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _GroupCard(
                    title: l10n.settingsGroupPreferences,
                    child: Column(
                      children: [
                        _PreferenceRow(
                          title: l10n.settingsHapticsTitle,
                          subtitle: l10n.settingsHapticsSubtitle,
                          value: settings.enableHaptics,
                          onChanged:
                              (bool value) => unawaited(_toggleHaptics(value)),
                        ),
                        const SizedBox(height: 10),
                        _PreferenceRow(
                          title: l10n.settingsAudioTitle,
                          subtitle: l10n.settingsAudioSubtitle,
                          value: settings.enableSound,
                          onChanged:
                              (bool value) => unawaited(_toggleAudio(value)),
                        ),
                        const SizedBox(height: 10),
                        _PreferenceRow(
                          title: l10n.settingsKeepAwakeTitle,
                          subtitle: l10n.settingsKeepAwakeSubtitle,
                          value: settings.keepScreenAwake,
                          onChanged:
                              (bool value) =>
                                  unawaited(_toggleKeepAwake(value)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _GroupCard(
                    title: l10n.settingsGroupPomodoroDefaults,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsDefaultFocusDuration,
                          style: AppTypography.display(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final int minutes in const <int>[25, 60, 90])
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: minutes == 90 ? 0 : 10,
                                  ),
                                  child: _FocusMinutesChip(
                                    label: l10n.settingsMinutesShort(minutes),
                                    selected:
                                        settings.defaultFocusMinutes == minutes,
                                    onTap:
                                        () => unawaited(
                                          _setFocusMinutes(minutes),
                                        ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _GroupCard(
                    title: l10n.settingsGroupDataManagement,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsDangerZone,
                          style: AppTypography.display(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.settingsDangerZoneDescription,
                          style: AppTypography.display(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassButton(
                          label:
                              _isWipingData
                                  ? l10n.settingsWiping
                                  : l10n.settingsWipeAllData,
                          icon: Icons.delete_forever_rounded,
                          onTap:
                              _isWipingData
                                  ? () {}
                                  : () => unawaited(_wipeAllData()),
                          labelStyle: AppTypography.display(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          iconColor: Colors.redAccent,
                        ),
                      ],
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

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(26),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.heading(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
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
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FocusMinutesChip extends StatelessWidget {
  const _FocusMinutesChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color:
              selected
                  ? AppColors.primaryPurple.withValues(alpha: 0.24)
                  : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color:
                selected
                    ? AppColors.primaryPurple.withValues(alpha: 0.7)
                    : AppColors.glassBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.mono(
              color: selected ? AppColors.textMain : AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
