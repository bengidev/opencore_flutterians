import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_baker.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_view.dart';
import 'package:opencore_flutterians/home/home_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(HomeOrbBakeCache.clear);

  testWidgets('orb builds and respects reduce motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(
          body: SizedBox(height: 260, child: HomeOrbView()),
        ),
      ),
    );
    await tester.pump();
    // Allow bake future
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.byType(HomeOrbView), findsOneWidget);
  });
}
