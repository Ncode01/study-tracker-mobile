import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/widgets/bottom_actions_nav.dart';
import '../../features/home/presentation/widgets/switch_context_sheet.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _showSwitchContextSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => const FractionallySizedBox(
            heightFactor: 0.82,
            child: SwitchContextSheet(),
          ),
    );
  }

  void _selectBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 600;
          if (compact) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 148),
                    child: navigationShell,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: BottomActionsNav(
                        selectedIndex: navigationShell.currentIndex,
                        switchCategoryLabel: l10n.switchCategoryAction,
                        homeLabel: l10n.navHome,
                        calendarLabel: l10n.navCalendar,
                        hubLabel: l10n.navHub,
                        clubsLabel: l10n.navClubs,
                        analyticsLabel: l10n.navAnalytics,
                        onSwitchCategoryTap:
                            () => _showSwitchContextSheet(context),
                        onSelectNav: _selectBranch,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final bool extendedRail = constraints.maxWidth >= 900;

          return Row(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  child: NavigationRail(
                    extended: extendedRail,
                    labelType:
                        extendedRail ? null : NavigationRailLabelType.all,
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _selectBranch,
                    leading: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Semantics(
                        button: true,
                        label: l10n.switchCategoryAction,
                        child: Tooltip(
                          message: l10n.switchCategoryAction,
                          child:
                              extendedRail
                                  ? FilledButton.tonalIcon(
                                    onPressed:
                                        () => _showSwitchContextSheet(context),
                                    icon: const Icon(Icons.swap_horiz_rounded),
                                    label: Text(l10n.switchCategoryAction),
                                  )
                                  : IconButton.filledTonal(
                                    onPressed:
                                        () => _showSwitchContextSheet(context),
                                    icon: const Icon(Icons.swap_horiz_rounded),
                                  ),
                        ),
                      ),
                    ),
                    destinations: [
                      _destination(l10n.navHome, Icons.home_outlined),
                      _destination(
                        l10n.navCalendar,
                        Icons.calendar_month_outlined,
                      ),
                      _destination(l10n.navHub, Icons.menu_book_outlined),
                      _destination(l10n.navClubs, Icons.groups_outlined),
                      _destination(l10n.navAnalytics, Icons.bar_chart_outlined),
                    ],
                  ),
                ),
              ),
              Container(width: 1, color: Colors.white.withValues(alpha: 0.1)),
              Expanded(child: navigationShell),
            ],
          );
        },
      ),
    );
  }

  NavigationRailDestination _destination(String label, IconData icon) {
    return NavigationRailDestination(
      icon: Tooltip(message: label, child: Icon(icon)),
      selectedIcon: Tooltip(message: label, child: Icon(icon)),
      label: Text(label),
    );
  }
}
