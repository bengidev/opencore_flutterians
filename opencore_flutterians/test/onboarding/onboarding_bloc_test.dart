import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opencore_flutterians/onboarding/bloc/onboarding_bloc.dart';
import 'package:opencore_flutterians/onboarding/bloc/onboarding_event.dart';
import 'package:opencore_flutterians/onboarding/bloc/onboarding_state.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_catalog.dart';

import '../helpers/hydrated_storage.dart';

class _FakeStore implements OnboardingCompletionStore {
  bool completed = false;
  bool throwOnMark = false;

  @override
  Future<bool> hasCompleted() async => completed;

  @override
  Future<void> markCompleted() async {
    if (throwOnMark) throw StateError('write failed');
    completed = true;
  }
}

void main() {
  late _FakeStore store;
  late MockHydratedStorage storage;
  final pages = OnboardingPageCatalog.build();

  setUp(() {
    setUpHydratedStorage();
    storage = HydratedBloc.storage as MockHydratedStorage;
    store = _FakeStore();
  });

  OnboardingBloc buildBloc() => OnboardingBloc(pages: pages, store: store);

  group('OnboardingBloc', () {
    test('starts at index 0', () {
      final bloc = buildBloc();
      addTearDown(bloc.close);
      expect(bloc.state.index, 0);
      expect(bloc.state.isFirst, isTrue);
      expect(bloc.state.isCta, isFalse);
      expect(bloc.state.status, OnboardingStatus.inProgress);
    });

    test('restores hydrated page index', () {
      when(() => storage.read(any())).thenReturn({'index': 2});
      final bloc = buildBloc();
      addTearDown(bloc.close);
      expect(bloc.state.index, 2);
    });

    test('toJson/fromJson round-trip index', () {
      final bloc = buildBloc();
      addTearDown(bloc.close);
      final json = bloc.toJson(bloc.state.copyWith(index: 3));
      expect(json, {'index': 3});
      expect(bloc.fromJson(json!)?.index, 3);
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'next advances and clamps at cta',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const OnboardingNextPressed());
        for (var i = 0; i < 10; i++) {
          bloc.add(const OnboardingNextPressed());
        }
      },
      expect: () => [
        isA<OnboardingState>().having((s) => s.index, 'index', 1),
        isA<OnboardingState>().having((s) => s.index, 'index', 2),
        isA<OnboardingState>().having((s) => s.index, 'index', 3),
        isA<OnboardingState>()
            .having((s) => s.index, 'index', 4)
            .having((s) => s.isCta, 'isCta', isTrue),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'back retreats and clamps at 0',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const OnboardingNextPressed())
          ..add(const OnboardingBackPressed())
          ..add(const OnboardingBackPressed());
      },
      expect: () => [
        isA<OnboardingState>().having((s) => s.index, 'index', 1),
        isA<OnboardingState>().having((s) => s.index, 'index', 0),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'skip jumps to cta without persisting completion',
      build: buildBloc,
      act: (bloc) => bloc.add(const OnboardingSkipPressed()),
      expect: () => [
        isA<OnboardingState>()
            .having((s) => s.index, 'index', 4)
            .having((s) => s.isCta, 'isCta', isTrue),
      ],
      verify: (_) async {
        expect(await store.hasCompleted(), isFalse);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'enter persists and completes',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const OnboardingSkipPressed())
          ..add(const OnboardingEnterPressed());
      },
      expect: () => [
        isA<OnboardingState>().having((s) => s.index, 'index', 4),
        isA<OnboardingState>().having((s) => s.isEntering, 'isEntering', isTrue),
        isA<OnboardingState>()
            .having((s) => s.isEntering, 'isEntering', isFalse)
            .having((s) => s.status, 'status', OnboardingStatus.completed)
            .having((s) => s.enterError, 'enterError', isNull),
      ],
      verify: (_) {
        expect(store.completed, isTrue);
        verify(() => storage.delete(any())).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'enter failure sets inline error and does not complete',
      build: () {
        store.throwOnMark = true;
        return buildBloc();
      },
      act: (bloc) {
        bloc
          ..add(const OnboardingSkipPressed())
          ..add(const OnboardingEnterPressed());
      },
      expect: () => [
        isA<OnboardingState>().having((s) => s.index, 'index', 4),
        isA<OnboardingState>().having((s) => s.isEntering, 'isEntering', isTrue),
        isA<OnboardingState>()
            .having((s) => s.isEntering, 'isEntering', isFalse)
            .having((s) => s.status, 'status', OnboardingStatus.inProgress)
            .having(
              (s) => s.enterError,
              'enterError',
              '[ERROR: COULD NOT SAVE]',
            ),
      ],
      verify: (_) {
        expect(store.completed, isFalse);
      },
    );
  });
}
