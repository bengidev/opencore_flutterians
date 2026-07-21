import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('add clears draft and shows new-chat snackbar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView(orbActive: false)),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'keep me');
    await tester.pump();

    await tester.tap(find.byKey(const Key('homeNewChatButton')));
    await tester.pumpAndSettle();

    expect(find.text('keep me'), findsNothing);
    expect(find.text(HomeTokens.snackbarNewChat), findsOneWidget);
  });

  testWidgets('menu shows stub chat titles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView(orbActive: false)),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();

    for (final title in HomeTokens.stubChatTitles) {
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('model selection from rail updates chip label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView(orbActive: false)),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('Gemma 4 26B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Google: Gemma 4 9B'));
    await tester.pumpAndSettle();

    expect(find.text('Google: Gemma 4 9B'), findsOneWidget);
  });
}
