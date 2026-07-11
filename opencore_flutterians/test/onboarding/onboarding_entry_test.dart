import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/onboarding/bloc/onboarding_bootstrap_cubit.dart';
import 'package:opencore_flutterians/onboarding/bloc/onboarding_bootstrap_state.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_entry.dart';

import '../helpers/hydrated_storage.dart';

class _MemoryStore implements OnboardingCompletionStore {
  bool completed = false;
  @override
  Future<bool> hasCompleted() async => completed;
  @override
  Future<void> markCompleted() async => completed = true;
}

Widget _wrapEntry(OnboardingCompletionStore store) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: BlocProvider(
      create: (_) => OnboardingBootstrapCubit(store: store),
      child: OnboardingEntry(store: store),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(setUpHydratedStorage);

  testWidgets('skip jumps to CTA Enter', (tester) async {
    await tester.pumpWidget(_wrapEntry(_MemoryStore()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('SKIP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('ENTER'), findsOneWidget);
    expect(find.text('OpenCore'), findsWidgets);
  });

  testWidgets('enter completes and marks store', (tester) async {
    final store = _MemoryStore();
    await tester.pumpWidget(_wrapEntry(store));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('SKIP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('ENTER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(store.completed, isTrue);
    final bootstrap = BlocProvider.of<OnboardingBootstrapCubit>(
      tester.element(find.byType(OnboardingEntry)),
    );
    expect(bootstrap.state, isA<OnboardingBootstrapShowHome>());
  });
}
