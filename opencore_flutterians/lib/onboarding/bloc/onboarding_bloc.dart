import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../onboarding_completion_store.dart';
import '../onboarding_page_model.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// Complex onboarding flow — full Bloc with Hydrated mid-flow page index.
class OnboardingBloc extends HydratedBloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required List<OnboardingPageModel> pages,
    required this._store,
  })  : _pages = List.unmodifiable(pages),
        super(OnboardingState(pages: List.unmodifiable(pages))) {
    on<OnboardingNextPressed>(_onNext);
    on<OnboardingBackPressed>(_onBack);
    on<OnboardingSkipPressed>(_onSkip);
    on<OnboardingEnterPressed>(_onEnter);
  }

  final OnboardingCompletionStore _store;
  final List<OnboardingPageModel> _pages;

  void _onNext(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.isCta) return;
    emit(
      state.copyWith(
        index: (state.index + 1).clamp(0, state.pages.length - 1),
        clearEnterError: true,
      ),
    );
  }

  void _onBack(
    OnboardingBackPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.isFirst) return;
    emit(
      state.copyWith(
        index: (state.index - 1).clamp(0, state.pages.length - 1),
        clearEnterError: true,
      ),
    );
  }

  void _onSkip(
    OnboardingSkipPressed event,
    Emitter<OnboardingState> emit,
  ) {
    final target = state.ctaIndex;
    if (target < 0 || state.index == target) return;
    emit(
      state.copyWith(
        index: target,
        clearEnterError: true,
      ),
    );
  }

  Future<void> _onEnter(
    OnboardingEnterPressed event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.isCta || state.isEntering) return;
    emit(state.copyWith(isEntering: true, clearEnterError: true));
    try {
      await _store.markCompleted();
      await clear();
      emit(
        state.copyWith(
          isEntering: false,
          status: OnboardingStatus.completed,
          clearEnterError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isEntering: false,
          enterError: '[ERROR: COULD NOT SAVE]',
        ),
      );
    }
  }

  @override
  OnboardingState? fromJson(Map<String, dynamic> json) {
    final raw = json['index'];
    if (raw is! int) return null;
    return OnboardingState(
      pages: _pages,
      index: raw.clamp(0, _pages.length - 1),
    );
  }

  @override
  Map<String, dynamic>? toJson(OnboardingState state) {
    if (state.status == OnboardingStatus.completed) return null;
    return {'index': state.index};
  }
}
