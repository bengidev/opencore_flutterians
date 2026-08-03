import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_tab_shell.dart';
import 'package:opencore_flutterians/home/views/home_placeholder_page.dart';
import 'package:opencore_flutterians/home/views/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('tapping Settings shows placeholder page',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('About'), findsWidgets);

    await tester.tap(find.text('Settings').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byType(HomeTabShell), findsOneWidget);
    // The label appears in both the tab bar and the placeholder page.
    expect(find.text('Settings'), findsAtLeastNWidgets(2));
  });

  testWidgets('tab change under reduced motion still switches page',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: HomeTheme.light(),
          home: const HomeTabShell(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('About').first);
    await tester.pump();

    expect(find.byType(HomePlaceholderPage), findsWidgets);
    expect(find.text('About'), findsAtLeastNWidgets(2));
  });

  testWidgets('retapping active Home tab does not throw', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    await tester.tap(find.text('Home').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(tester.takeException(), isNull);
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('Android tab bar uses monochrome home palette', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    const colors = HomeColors.light;

    expect(navigationBar.backgroundColor, colors.surfaceRaised);
    expect(navigationBar.indicatorColor, colors.tabActiveFill);
    expect(navigationBar.destinations, hasLength(3));

    final homeDestination = navigationBar.destinations[0] as NavigationDestination;
    final homeSelectedIcon = homeDestination.selectedIcon as Icon;
    final homeIcon = homeDestination.icon as Icon;
    expect(homeSelectedIcon.color, colors.textPrimary);
    expect(homeIcon.color, colors.textSecondary);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS tab shell builds without casting errors', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(HomeTabShell), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
