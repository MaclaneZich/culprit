import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';
import '../challenge/challenge_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';
import '../timeline/timeline_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          TimelineScreen(),
          InsightsScreen(),
          ChallengeScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          _destination('timeline', 'Timeline', tones),
          _destination('insights', 'Insights', tones),
          _destination('challenge', 'Challenges', tones),
          _destination('settings', 'Settings', tones),
        ],
      ),
    );
  }

  NavigationDestination _destination(
      String icon, String label, CulpritTones tones) {
    Widget svg(Color color) => SvgPicture.asset(
          'assets/icons/$icon.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
    return NavigationDestination(
      icon: svg(tones.inkSecondary),
      selectedIcon: svg(tones.accent),
      label: label,
    );
  }
}
