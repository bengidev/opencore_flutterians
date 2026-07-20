import 'package:flutter/material.dart';
import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_placeholder_page.dart';
import 'home_pressable.dart';
import 'home_view.dart';

class HomeTabShell extends StatefulWidget {
  const HomeTabShell({super.key});

  @override
  State<HomeTabShell> createState() => _HomeTabShellState();
}

class _HomeTabShellState extends State<HomeTabShell> {
  int _index = 0;

  static const _tabs = [
    _TabSpec(label: 'Home', icon: Icons.home_outlined),
    _TabSpec(label: 'Settings', icon: Icons.settings_outlined),
    _TabSpec(label: 'About', icon: Icons.info_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final pages = [
      HomeView(orbActive: _index == 0),
      const HomePlaceholderPage(title: 'Settings'),
      const HomePlaceholderPage(title: 'About'),
    ];

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      // Keyboard inset is applied on HomeView so the sticky tab bar stays put.
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            key: const Key('homeStickyTabBar'),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(HomeTokens.radiusTabBar),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  _TabBarItem(
                    spec: _tabs[i],
                    active: _index == i,
                    onTap: () => setState(() => _index = i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _TabBarItem extends StatelessWidget {
  const _TabBarItem({
    required this.spec,
    required this.active,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);

    return Expanded(
      child: HomePressable(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: HomeTokens.durationTab,
          curve: HomeTokens.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? colors.tabActiveFill : Colors.transparent,
            borderRadius: BorderRadius.circular(HomeTokens.radiusTabActive),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                spec.icon,
                size: 22,
                color: active ? colors.textPrimary : colors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
