import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_panel.dart';

class BottomActionsNav extends StatelessWidget {
  const BottomActionsNav({
    super.key,
    required this.selectedIndex,
    required this.onSwitchCategoryTap,
    required this.onSelectNav,
  });

  final int selectedIndex;
  final VoidCallback onSwitchCategoryTap;
  final ValueChanged<int> onSelectNav;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            label: 'Switch Category...',
            icon: Icons.swap_horiz_rounded,
            onTap: onSwitchCategoryTap,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
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
                selected: selectedIndex == 0,
                onTap: () => onSelectNav(0),
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                selected: selectedIndex == 1,
                onTap: () => onSelectNav(1),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                selected: selectedIndex == 2,
                onTap: () => onSelectNav(2),
              ),
              _NavItem(
                icon: Icons.groups_outlined,
                selected: selectedIndex == 3,
                onTap: () => onSelectNav(3),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
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
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}
