import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_facade.dart';

class _MemoryStore implements OnboardingCompletionStore {
  _MemoryStore(this.completed);
  bool completed;
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

  testWidgets('incomplete shows onboarding', (tester) async {
    final root = await OnboardingFacade(store: _MemoryStore(false)).buildRoot(
      home: const Text('HOME'),
    );
    await tester.pumpWidget(MaterialApp(home: root));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('complete shows home', (tester) async {
    final root = await OnboardingFacade(store: _MemoryStore(true)).buildRoot(
      home: const Text('HOME'),
    );
    await tester.pumpWidget(MaterialApp(home: root));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
