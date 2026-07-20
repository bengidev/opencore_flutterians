import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_baker.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_view.dart';
import 'package:opencore_flutterians/home/home_theme.dart';

class _OrbPaletteHarness extends StatefulWidget {
  const _OrbPaletteHarness({required this.colors});

  final HomeColors colors;

  @override
  State<_OrbPaletteHarness> createState() => _OrbPaletteHarnessState();
}

class _OrbPaletteHarnessState extends State<_OrbPaletteHarness> {
  late HomeColors _colors;

  @override
  void initState() {
    super.initState();
    _colors = widget.colors;
  }

  void swapPalette() {
    setState(() {
      _colors = HomeColors.light.copyWith(
        orbTint: const Color(0xFF222222),
        orbAccent: const Color(0xFF444444),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(extensions: [_colors]),
      child: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              onPressed: swapPalette,
              child: const Text('Swap palette'),
            ),
            const SizedBox(height: 260, child: HomeOrbView()),
          ],
        ),
      ),
    );
  }
}

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

  testWidgets('shows empty loading state while rebaking palette', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _OrbPaletteHarness(colors: HomeColors.light),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.byType(RawImage), findsWidgets);

    await tester.tap(find.text('Swap palette'));
    await tester.pump();

    expect(find.byType(RawImage), findsNothing);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.byType(RawImage), findsWidgets);
  });
}
