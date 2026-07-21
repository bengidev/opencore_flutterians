import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_composer_view.dart';
import 'package:opencore_flutterians/home/views/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('composer and model rail render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView()),
      ),
    );
    await tester.pump();

    expect(find.text(HomeTokens.composerHint), findsOneWidget);
    expect(find.textContaining('Gemma'), findsOneWidget);
    expect(find.text(HomeTokens.speedTitle), findsOneWidget);
    expect(find.text(HomeTokens.contextLabel), findsOneWidget);
    expect(find.byTooltip('Voice input'), findsOneWidget);
    expect(find.byTooltip('Send'), findsNothing);
  });

  testWidgets('composer swaps mic for send when draft has text', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeComposerView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Voice input'), findsOneWidget);
    expect(find.byTooltip('Send'), findsNothing);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pumpAndSettle();

    expect(find.byTooltip('Send'), findsOneWidget);
    expect(find.byTooltip('Voice input'), findsNothing);
  });

  testWidgets('send clears draft and restores mic', (tester) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeComposerView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Send'), findsOneWidget);
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(controller.text, isEmpty);
    expect(find.byTooltip('Voice input'), findsOneWidget);
    expect(find.byTooltip('Send'), findsNothing);
  });

  testWidgets('mic shows coming-soon snackbar', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeComposerView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Voice input'));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.snackbarVoiceSoon), findsOneWidget);
  });

  testWidgets('attachment menu offers Photo File Camera', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeComposerView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add attachment'));
    await tester.pumpAndSettle();

    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.snackbarAttachment('File')), findsOneWidget);
  });
}
