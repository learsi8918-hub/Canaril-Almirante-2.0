import 'package:flutter/material.dart';

import '../core/theme_controller.dart';
import 'dashboard_screen.dart';
import 'plantel_screen.dart';
import 'reproduction_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class NavigationScreen extends StatefulWidget {
  final AppThemeController theme;

  const NavigationScreen({
    super.key,
    required this.theme,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      DashboardScreen(
        theme: widget.theme,
      ),
      PlantelScreen(
        theme: widget.theme,
      ),
      ReproductionScreen(
        theme: widget.theme,
      ),
      ReportsScreen(
        theme: widget.theme,
      ),
      SettingsScreen(
        theme: widget.theme,
      ),
    ];
  }

  void _changePage(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: theme.surface,
          indicatorColor: theme.secondary.withValues(alpha: 0.20),

          elevation: 8,

          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) {
              final selected = states.contains(
                WidgetState.selected,
              );

              return TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? theme.primary
                    : Colors.grey.shade700,
              );
            },
          ),

          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) {
              final selected = states.contains(
                WidgetState.selected,
              );

              return IconThemeData(
                size: selected ? 25 : 23,
                color: selected
                    ? theme.primary
                    : Colors.grey.shade700,
              );
            },
          ),
        ),

        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _changePage,

          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.dashboard_outlined,
              ),
              selectedIcon: Icon(
                Icons.dashboard,
              ),
              label: 'Início',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.flutter_dash_outlined,
              ),
              selectedIcon: Icon(
                Icons.flutter_dash,
              ),
              label: 'Plantel',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.favorite_border,
              ),
              selectedIcon: Icon(
                Icons.favorite,
              ),
              label: 'Reprodução',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.analytics_outlined,
              ),
              selectedIcon: Icon(
                Icons.analytics,
              ),
              label: 'Relatórios',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
              ),
              selectedIcon: Icon(
                Icons.settings,
              ),
              label: 'Config.',
            ),
          ],
        ),
      ),
    );
  }
}
