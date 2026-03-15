import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: l10n.play,
          ),
          NavigationDestination(
            icon: const Icon(Icons.face_rounded),
            label: l10n.character,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_rounded),
            label: l10n.progress,
          ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/character') || location.startsWith('/accessories')) return 1;
    if (location.startsWith('/progress')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/character');
      case 2:
        context.go('/progress');
    }
  }
}
