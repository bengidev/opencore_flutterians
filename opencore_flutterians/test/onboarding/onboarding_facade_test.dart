import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_facade.dart';

import '../helpers/hydrated_storage.dart';

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

  setUp(setUpHydratedStorage);

  Widget _wrap(Widget child) {
    return MaterialApp(
      builder: (context, nested) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: nested!,
      ),
      home: child,
    );
  }

  testWidgets('incomplete shows onboarding', (tester) async {
    final root = OnboardingFacade(store: _MemoryStore(false)).buildRoot(
      home: const Text('HOME'),
    );
    await tester.pumpWidget(_wrap(root));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('complete shows home', (tester) async {
    final root = OnboardingFacade(store: _MemoryStore(true)).buildRoot(
      home: const Text('HOME'),
    );
    await tester.pumpWidget(_wrap(root));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('HOME'), findsOneWidget);
  });
}
