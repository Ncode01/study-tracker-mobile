import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_panel.dart';

class BottomActionsNav extends StatelessWidget {
  const BottomActionsNav({
    super.key,
    required this.selectedIndex,
    required this.switchCategoryLabel,
    required this.homeLabel,
    required this.calendarLabel,
    required this.hubLabel,
    required this.clubsLabel,
    required this.analyticsLabel,
    required this.onSwitchCategoryTap,
    required this.onSelectNav,
  });

  final int selectedIndex;
  final String switchCategoryLabel;
  final String homeLabel;
  final String calendarLabel;
  final String hubLabel;
  final String clubsLabel;
  final String analyticsLabel;
  final VoidCallback onSwitchCategoryTap;
  final ValueChanged<int> onSelectNav;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: switchCategoryLabel,
            child: GlassButton(
              label: switchCategoryLabel,
              icon: Icons.swap_horiz_rounded,
              onTap: onSwitchCategoryTap,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                semanticsLabel: homeLabel,
                selected: selectedIndex == 0,
                onTap: () => onSelectNav(0),
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                semanticsLabel: calendarLabel,
                selected: selectedIndex == 1,
                onTap: () => onSelectNav(1),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                semanticsLabel: hubLabel,
                selected: selectedIndex == 2,
                onTap: () => onSelectNav(2),
              ),
              _NavItem(
                icon: Icons.groups_outlined,
                semanticsLabel: clubsLabel,
                selected: selectedIndex == 3,
                onTap: () => onSelectNav(3),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                semanticsLabel: analyticsLabel,
                selected: selectedIndex == 4,
                onTap: () => onSelectNav(4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: Tooltip(
        message: semanticsLabel,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: selected ? const Color(0x26FFFFFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? AppColors.textMain : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
