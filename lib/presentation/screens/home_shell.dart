import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/coach/coach_providers.dart';
import '../../features/coach/presentation/coach_screen.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

enum HomeTab { today, coach, analytics, settings }

class HomeTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.today;

  void select(HomeTab tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, HomeTab>(HomeTabNotifier.new);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    final pendingPlan = ref.watch(coachControllerProvider.select((s) => s.plan.length));

    return Scaffold(
      body: IndexedStack(
        index: tab.index,
        children: const [
          DashboardScreen(),
          CoachScreen(),
          AnalyticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (i) =>
            ref.read(homeTabProvider.notifier).select(HomeTab.values[i]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingPlan > 0,
              label: Text('$pendingPlan'),
              child: const Icon(Icons.auto_awesome_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingPlan > 0,
              label: Text('$pendingPlan'),
              child: const Icon(Icons.auto_awesome),
            ),
            label: 'Coach',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
