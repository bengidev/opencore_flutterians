import 'package:flutter/foundation.dart';

import 'onboarding_completion_store.dart';
import 'onboarding_page_model.dart';

class OnboardingFlowController extends ChangeNotifier {
  OnboardingFlowController({
    required List<OnboardingPageModel> pages,
    required OnboardingCompletionStore store,
    required VoidCallback onCompleted,
  })  : _pages = List.unmodifiable(pages),
        _store = store,
        _onCompleted = onCompleted;

  final List<OnboardingPageModel> _pages;
  final OnboardingCompletionStore _store;
  final VoidCallback _onCompleted;

  int _index = 0;
  String? _enterError;
  bool _entering = false;

  int get index => _index;
  String? get enterError => _enterError;
  bool get isEntering => _entering;
  bool get isFirst => _index == 0;
  bool get isCta => _pages[_index].kind == OnboardingPageKind.cta;
  OnboardingPageModel get currentPage => _pages[_index];
  List<OnboardingPageModel> get pages => _pages;
  int get ctaIndex => _pages.indexWhere((p) => p.kind == OnboardingPageKind.cta);

  void next() {
    if (isCta) return;
    _index = (_index + 1).clamp(0, _pages.length - 1);
    _enterError = null;
    notifyListeners();
  }

  void back() {
    if (isFirst) return;
    _index = (_index - 1).clamp(0, _pages.length - 1);
    _enterError = null;
    notifyListeners();
  }

  void skip() {
    final target = ctaIndex;
    if (target < 0 || _index == target) return;
    _index = target;
    _enterError = null;
    notifyListeners();
  }

  Future<void> enter() async {
    if (!isCta || _entering) return;
    _entering = true;
    _enterError = null;
    notifyListeners();
    try {
      await _store.markCompleted();
      _onCompleted();
    } catch (_) {
      _enterError = '[ERROR: COULD NOT SAVE]';
    } finally {
      _entering = false;
      notifyListeners();
    }
  }
}
