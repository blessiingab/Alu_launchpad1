import 'package:flutter/material.dart';

import '../../opportunities/screens/manage_opportunities_screen.dart';
import 'startup_account_profile_screen.dart';
import 'startup_dashboard_screen.dart';
import 'startup_hub_screen.dart';

/// Bottom-nav container for the startup admin experience — mirrors
/// StudentShellScreen's IndexedStack pattern so each tab keeps its own
/// scroll position and AppBar.
///
/// Tabs: Home (overview), Opportunities (browse/manage), Startup (add a
/// startup / post an opportunity), Profile (account + everything you've
/// added). The notification bell lives in the Home AppBar instead of its
/// own tab — see StartupDashboardScreen.
class StartupShellScreen extends StatefulWidget {
  const StartupShellScreen({super.key});

  @override
  State<StartupShellScreen> createState() => _StartupShellScreenState();
}

class _StartupShellScreenState extends State<StartupShellScreen> {
  int _index = 0;

  static const _tabs = [
    StartupDashboardScreen(),
    ManageOpportunitiesScreen(),
    StartupHubScreen(),
    StartupAccountProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Opportunities',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Startup',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
