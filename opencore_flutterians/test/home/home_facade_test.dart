import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HomeFacade.buildRoot shows sticky tab labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeFacade().buildRoot()),
    );
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });
}
