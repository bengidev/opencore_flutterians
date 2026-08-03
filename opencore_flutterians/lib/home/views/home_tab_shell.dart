import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_theme.dart';
import '../home_tokens.dart';
import 'home_placeholder_page.dart';
import 'home_view.dart';

class HomeTabShell extends StatefulWidget {
  const HomeTabShell({super.key});

  @override
  State<HomeTabShell> createState() => _HomeTabShellState();
}

class _HomeTabShellState extends State<HomeTabShell> {
  int _index = 0;
  int? _previousIndex;

  List<AdaptiveNavigationDestination> _destinations(BuildContext context) {
    // Compute at build time so ThemeData.platform overrides (e.g. in tests or
    // tablet/desktop builds) are respected instead of caching at initState.
    final apple = Theme.of(context).platform == TargetPlatform.iOS;
    return [
      AdaptiveNavigationDestination(
        icon: apple ? 'house.fill' : Icons.home_outlined,
        selectedIcon: apple ? 'house.fill' : Icons.home,
        label: 'Home',
      ),
      AdaptiveNavigationDestination(
        icon: apple ? 'gear' : Icons.settings_outlined,
        selectedIcon: apple ? 'gear' : Icons.settings,
        label: 'Settings',
      ),
      AdaptiveNavigationDestination(
        icon: apple ? 'info.circle' : Icons.info_outline,
        selectedIcon: apple ? 'info.circle.fill' : Icons.info,
        label: 'About',
      ),
    ];
  }

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
      HomePlaceholderPage(title: 'Settings'),
      HomePlaceholderPage(title: 'About'),
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
                onEnd:
                    i == _previousIndex ? () => _clearPreviousIndex(i) : null,
                child: pages[i],
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the Android [NavigationBar] with the exact monochrome home palette.
  ///
  /// The package forwards [AdaptiveBottomNavigationBar.selectedItemColor] only
  /// as [NavigationBar.indicatorColor], which would make the active indicator
  /// background black. Providing a custom bar lets us keep the indicator
  /// background as [HomeColors.tabActiveFill] and the selected icon as
  /// [HomeColors.textPrimary]. This widget is ignored on iOS.
  Widget _androidBottomNavigationBar(BuildContext context) {
    final colors = HomeColors.of(context);
    final destinations = _destinations(context);

    return NavigationBar(
      backgroundColor: colors.surfaceRaised,
      indicatorColor: colors.tabActiveFill,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HomeTokens.radiusTabBar),
      ),
      selectedIndex: _index,
      onDestinationSelected: _select,
      destinations:
          destinations.map((dest) {
            final icon = dest.icon as IconData;
            final selectedIcon = dest.selectedIcon as IconData? ?? icon;
            return NavigationDestination(
              icon: Icon(icon, color: colors.textSecondary),
              selectedIcon: Icon(selectedIcon, color: colors.textPrimary),
              label: dest.label,
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // iOS 26+ native UITabBar floats over content (Liquid Glass). Pad the
    // body so the composer/footer clears the tab bar plus the home indicator
    // safe area. The package does not expose the native tab-bar height, so we
    // add a conservative estimated inset on top of the safe-area padding.
    final bottomPad = PlatformInfo.isIOS26OrHigher()
        ? MediaQuery.paddingOf(context).bottom + HomeTokens.nativeTabBarInset
        : 0.0;

    return ColoredBox(
      color: colors.surfaceBase,
      // The iOS 26+ native UITabBar reads its tint from
      // CupertinoTheme.of(context).primaryColor. Without a CupertinoTheme it
      // falls back to Material's deepPurple seed. Force the project's
      // monochrome palette so the tab bar matches the rest of the chrome.
      child: CupertinoTheme(
        data: CupertinoThemeData(
          primaryColor: colors.textPrimary,
          brightness: Theme.of(context).brightness,
        ),
        child: AdaptiveScaffold(
          resizeToAvoidBottomInset: false,
          // AdaptiveScaffold uses CupertinoPageScaffold on iOS, which lacks
          // a Material ancestor. Wrap the body so Material widgets
          // (TextField, IconButton, etc.) resolve correctly on every
          // platform.
          body: Padding(
            padding: EdgeInsets.only(bottom: bottomPad),
            child: Material(
              type: MaterialType.transparency,
              child: _buildPages(reduceMotion),
            ),
          ),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            // Renders a real iOS 26+ UITabBar via UiKitView. Hot restart can
            // trigger a Flutter engine regression where the native platform
            // view is not torn down before Dart restarts, causing
            // PlatformException(recreating_view, view id: '0'). If you hit
            // that, stop and run again (full restart), or temporarily set
            // useNativeBottomBar to false while iterating.
            useNativeBottomBar: true,
            selectedItemColor: colors.textPrimary,
            unselectedItemColor: colors.textSecondary,
            // Android: use a custom NavigationBar so the active indicator
            // background stays tabActiveFill instead of becoming textPrimary.
            // The package ignores this on iOS, but it is still evaluated, so
            // only build it on Android to avoid casting SF Symbol strings.
            bottomNavigationBar:
                Theme.of(context).platform == TargetPlatform.iOS
                    ? null
                    : _androidBottomNavigationBar(context),
            items: _destinations(context),
            selectedIndex: _index,
            onTap: _select,
          ),
        ),
      ),
    );
  }
}
