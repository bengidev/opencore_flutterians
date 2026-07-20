import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/hydrated_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(setUpHydratedStorage);

  Widget wrap(Widget child) {
    return MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: child,
    );
  }

  testWidgets('first launch shows onboarding continue', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(wrap(const OpenCoreApp()));
    // Bootstrap; avoid pumpAndSettle (page transitions may still be running).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('completed launch shows home shell', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding.completed': true});
    await tester.pumpWidget(wrap(const OpenCoreApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('CONTINUE'), findsNothing);
    expect(find.text(HomeTokens.greeting), findsOneWidget);
    expect(find.byKey(const Key('homeStickyTabBar')), findsOneWidget);
  });
}
