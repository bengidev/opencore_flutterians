import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('home welcome shows greeting and encryption copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView()),
      ),
    );
    await tester.pump();

    expect(find.text(HomeTokens.greeting), findsOneWidget);
    expect(find.text(HomeTokens.encryptionLine1), findsOneWidget);
    expect(find.text(HomeTokens.encryptionLine2), findsOneWidget);
  });
}
