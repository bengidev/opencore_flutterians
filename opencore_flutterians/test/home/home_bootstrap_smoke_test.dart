import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/onboarding/onboarding.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';

import '../helpers/hydrated_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(setUpHydratedStorage);

  testWidgets('completed onboarding shows home shell', (tester) async {
    final store = _DoneStore();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: OnboardingFacade(store: store).buildRoot(
          home: HomeFacade().buildRoot(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.greeting), findsOneWidget);
    expect(find.byKey(const Key('homeStickyTabBar')), findsOneWidget);
  });
}

class _DoneStore implements OnboardingCompletionStore {
  @override
  Future<bool> hasCompleted() async => true;

  @override
  Future<void> markCompleted() async {}
}
