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

  testWidgets('tapping Settings shows placeholder and keeps bar pinned',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    expect(find.byKey(const Key('homeStickyTabBar')), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byType(HomeTabShell), findsOneWidget);
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

    await tester.tap(find.text('About'));
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
}
