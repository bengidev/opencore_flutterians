import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int? _previousIndex;

  static const _tabs = [
    _TabSpec(label: 'Home', icon: Icons.home_outlined),
    _TabSpec(label: 'Settings', icon: Icons.settings_outlined),
    _TabSpec(label: 'About', icon: Icons.info_outline),
  ];

  void _select(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _previousIndex = _index;
      _index = i;
    });
  }

  void _clearPreviousIndex(int i) {
    if (!mounted || _previousIndex != i) return;
    setState(() => _previousIndex = null);
  }

  Widget _buildPages(bool reduceMotion) {
    final pages = [
      HomeView(orbActive: _index == 0),
      const HomePlaceholderPage(title: 'Settings'),
      const HomePlaceholderPage(title: 'About'),
    ];

    if (reduceMotion) {
      return IndexedStack(index: _index, children: pages);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < pages.length; i++)
          Offstage(
            offstage: i != _index && i != _previousIndex,
            child: IgnorePointer(
              ignoring: i != _index,
              child: AnimatedOpacity(
                opacity: i == _index ? 1 : 0,
                duration: HomeTokens.durationTab,
                curve: HomeTokens.easeOut,
                onEnd: i == _previousIndex
                    ? () => _clearPreviousIndex(i)
                    : null,
                child: pages[i],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      // Keyboard inset is applied on HomeView so the sticky tab bar stays put.
      resizeToAvoidBottomInset: false,
      body: _buildPages(reduceMotion),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / _tabs.length;
                final duration =
                    reduceMotion ? Duration.zero : HomeTokens.durationTab;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: duration,
                      curve: HomeTokens.easeOut,
                      left: tabWidth * _index,
                      width: tabWidth,
                      top: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.tabActiveFill,
                          borderRadius:
                              BorderRadius.circular(HomeTokens.radiusTabActive),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _tabs.length; i++)
                          _TabBarItem(
                            spec: _tabs[i],
                            active: _index == i,
                            reduceMotion: reduceMotion,
                            onTap: () => _select(i),
                          ),
                      ],
                    ),
                  ],
                );
              },
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
    required this.reduceMotion,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool active;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final duration =
        reduceMotion ? Duration.zero : HomeTokens.durationTab;

    return Expanded(
      child: HomePressable(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TweenAnimationBuilder<Color?>(
            duration: duration,
            curve: HomeTokens.easeOut,
            tween: ColorTween(
              end: active ? colors.textPrimary : colors.textSecondary,
            ),
            builder: (context, color, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(spec.icon, size: 22, color: color),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    curve: HomeTokens.easeOut,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                    ),
                    child: Text(
                      spec.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
