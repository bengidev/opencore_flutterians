import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_tab_shell.dart';

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

    expect(find.text('Settings'), findsWidgets);
    expect(find.byType(HomeTabShell), findsOneWidget);
    // Placeholder title appears in body
    expect(find.text('Settings'), findsAtLeastNWidgets(2));
  });
}
