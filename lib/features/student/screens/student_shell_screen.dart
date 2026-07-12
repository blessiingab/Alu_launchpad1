import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../applications/screens/application_screen.dart';
import '../../opportunities/screens/student_home_screen.dart';
import 'bookmarks_screen.dart';
import 'student_profile_screen.dart';

/// Bottom-nav container for the student experience. Kept as plain
/// widget-level tab state (IndexedStack) rather than nested go_router
/// routes — the tabs don't need independent deep-linkable URLs, and
/// this keeps the router in app_router.dart simple.
class StudentShellScreen extends StatefulWidget {
  const StudentShellScreen({super.key});

  @override
  State<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends State<StudentShellScreen> {
  int _index = 0;

  static const _tabs = [
    StudentHomeScreen(),
    ApplicationScreen(),
    BookmarksScreen(),
    StudentProfileScreen(),
  ];

  static const _destinations = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.send_outlined, selectedIcon: Icons.send_rounded, label: 'Applications'),
    (icon: Icons.bookmark_border_rounded, selectedIcon: Icons.bookmark_rounded, label: 'Saved'),
    (icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      // Floating pill nav bar with room above it for the selected tab's
      // bubble to lift out of the bar entirely.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md,
          ),
          child: SizedBox(
            height: 78,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppShadows.raised(colors.shadow),
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < _destinations.length; i++)
                        Expanded(
                          child: _NavItem(
                            icon: _destinations[i].icon,
                            selectedIcon: _destinations[i].selectedIcon,
                            label: _destinations[i].label,
                            selected: _index == i,
                            onTap: () => setState(() => _index = i),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: SizedBox(
        height: 60,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Bubble that lifts up and out of the bar when selected —
            // the "unexpected shape" of this nav bar.
            AnimatedPositioned(
              duration: AppMotion.medium,
              curve: Curves.easeOutBack,
              top: selected ? -18 : 14,
              child: AnimatedContainer(
                duration: AppMotion.medium,
                width: selected ? 48 : 22,
                height: selected ? 48 : 22,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.duskGradient : null,
                  shape: BoxShape.circle,
                  boxShadow: selected ? AppShadows.raised(colors.shadow) : null,
                ),
                alignment: Alignment.center,
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: selected ? 22 : 20,
                  color: selected ? Colors.white : colors.onSurfaceVariant,
                ),
              ),
            ),
            // Label fades in low in the bar once the bubble has lifted
            // clear of it.
            Positioned(
              bottom: 6,
              child: AnimatedOpacity(
                duration: AppMotion.fast,
                opacity: selected ? 1 : 0,
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}