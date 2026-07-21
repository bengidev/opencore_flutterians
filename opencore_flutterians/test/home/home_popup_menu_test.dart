import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_popup_menu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showHomePopupMenu returns selected value', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  selected = await showHomePopupMenu<String>(
                    context: context,
                    entries: const [
                      PopupMenuItem(value: 'a', child: Text('Alpha')),
                      PopupMenuItem(value: 'b', child: Text('Beta')),
                    ],
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(selected, 'b');
  });
}
