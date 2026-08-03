import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_theme.dart';
import 'package:opencore_flutterians/home/home_tokens.dart';
import 'package:opencore_flutterians/home/views/home_sidebar.dart';

void main() {
  testWidgets('opens and lists stub chat titles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    HomeSidebar.open(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);
    for (final title in HomeTokens.stubChatTitles) {
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('tapping scrim closes the sidebar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    HomeSidebar.open(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);

    await tester.tapAt(const Offset(350, 300));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsNothing);
  });

  testWidgets('tapping close button closes the sidebar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    HomeSidebar.open(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeSidebarCloseButton')));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsNothing);
  });

  testWidgets('tapping drawer panel does not close the sidebar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    HomeSidebar.open(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);
  });

  testWidgets('swiping left closes the sidebar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    HomeSidebar.open(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);

    await tester.drag(find.text('Chats'), const Offset(-50, 0));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsNothing);
  });

  testWidgets('selecting a chat invokes callback and closes', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    HomeSidebar.open(
      tester.element(find.byType(Scaffold)),
      onChatSelected: (title) => selected = title,
    );
    await tester.pumpAndSettle();

    final firstTitle = HomeTokens.stubChatTitles.first;
    await tester.tap(find.text(firstTitle));
    await tester.pumpAndSettle();

    expect(selected, firstTitle);
    expect(find.text('Chats'), findsNothing);
  });

  testWidgets('respects reduced motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          devicePixelRatio: 1,
          disableAnimations: true,
        ),
        child: MaterialApp(
          theme: HomeTheme.light(),
          home: const Scaffold(body: SizedBox.expand()),
        ),
      ),
    );

    HomeSidebar.open(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);
  });
}
