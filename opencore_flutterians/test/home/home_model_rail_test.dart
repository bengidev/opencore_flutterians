import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_model_rail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selecting a model updates via callback', (tester) async {
    var model = HomeTokens.modelTitle;
    var speed = HomeTokens.speedTitle;

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return HomeModelRail(
                modelLabel: model,
                speedLabel: speed,
                onModelSelected: (v) => setState(() => model = v),
                onSpeedSelected: (v) => setState(() => speed = v),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('Gemma 4 26B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OpenCore: Local 7B'));
    await tester.pumpAndSettle();

    expect(find.text('OpenCore: Local 7B'), findsOneWidget);

    await tester.tap(find.text('Max'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fast'));
    await tester.pumpAndSettle();

    expect(find.text('Fast'), findsOneWidget);
  });

  testWidgets('context badge shows snackbar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeModelRail(
            modelLabel: HomeTokens.modelTitle,
            speedLabel: HomeTokens.speedTitle,
            onModelSelected: (_) {},
            onSpeedSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(HomeTokens.contextLabel));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.snackbarContext), findsOneWidget);
  });
}
