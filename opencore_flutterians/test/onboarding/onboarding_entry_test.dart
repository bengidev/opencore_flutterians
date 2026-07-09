import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_entry.dart';

class _MemoryStore implements OnboardingCompletionStore {
  bool completed = false;
  @override
  Future<bool> hasCompleted() async => completed;
  @override
  Future<void> markCompleted() async => completed = true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('skip jumps to CTA Enter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingEntry(
          store: _MemoryStore(),
          onCompleted: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();
    expect(find.text('ENTER'), findsOneWidget);
    expect(find.text('OpenCore'), findsWidgets);
  });

  testWidgets('enter completes and calls onCompleted', (tester) async {
    final store = _MemoryStore();
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingEntry(
          store: store,
          onCompleted: () => done = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENTER'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(store.completed, isTrue);
  });
}
