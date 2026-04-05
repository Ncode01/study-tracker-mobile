import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';

class OnboardingFlowSheet extends StatefulWidget {
  const OnboardingFlowSheet({super.key, required this.onFinished});

  final Future<void> Function() onFinished;

  @override
  State<OnboardingFlowSheet> createState() => _OnboardingFlowSheetState();
}

class _OnboardingFlowSheetState extends State<OnboardingFlowSheet> {
  late final PageController _controller;
  int _pageIndex = 0;
  bool _finishing = false;

  static const List<({IconData icon, String title, String detail})>
  _pages = <({IconData icon, String title, String detail})>[
    (
      icon: Icons.bolt_rounded,
      title: 'Focused Sessions',
      detail: 'Run distraction-free sessions and keep momentum with one tap.',
    ),
    (
      icon: Icons.calendar_month_rounded,
      title: 'Calendar Clarity',
      detail:
          'Every session appears in your timeline so progress is visible each day.',
    ),
    (
      icon: Icons.insights_rounded,
      title: 'Actionable Analytics',
      detail:
          'See your patterns, spot drift quickly, and optimize your study flow.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) {
      return;
    }

    setState(() {
      _finishing = true;
    });

    await AppSettingsService.instance.setOnboardingCompleted(true);
    await widget.onFinished();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _nextOrFinish() async {
    if (_pageIndex >= _pages.length - 1) {
      await _finish();
      return;
    }

    await _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Welcome to TimeFlow',
                  style: AppTypography.heading(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _finishing ? null : () => unawaited(_finish()),
                  child: Text(
                    'Skip',
                    style: AppTypography.display(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (int index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  final page = _pages[index];
                  return GlassContainer(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.white.withValues(alpha: 0.04),
                    borderColor: Colors.white.withValues(alpha: 0.10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            color: AppColors.textMain,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          page.title,
                          style: AppTypography.heading(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          page.detail,
                          style: AppTypography.display(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _pageIndex ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          i == _pageIndex
                              ? AppColors.primaryPurple
                              : AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GlassButton(
              label:
                  _pageIndex >= _pages.length - 1
                      ? (_finishing ? 'Preparing...' : 'Get Started')
                      : 'Next',
              icon:
                  _pageIndex >= _pages.length - 1
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
              onTap: _finishing ? () {} : () => unawaited(_nextOrFinish()),
              labelStyle: AppTypography.display(
                color: AppColors.primaryPurple,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              iconColor: AppColors.primaryPurple,
            ),
          ],
        ),
      ),
    );
  }
}
