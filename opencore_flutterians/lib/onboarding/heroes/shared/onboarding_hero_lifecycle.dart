import 'package:flutter/material.dart';

/// Pauses looping hero animations when the page is off-screen.
mixin OnboardingHeroLifecycle<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  final List<_HeroControllerHandle> _handles = <_HeroControllerHandle>[];

  AnimationController createHeroController({
    required Duration duration,
    bool reverse = false,
  }) {
    final controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    final handle = _HeroControllerHandle(controller: controller, reverse: reverse);
    _handles.add(handle);
    _startIfNeeded(handle);
    return controller;
  }

  bool get heroActive {
    final widget = this.widget;
    if (widget is OnboardingHeroActive) {
      return widget.active;
    }
    return true;
  }

  bool get _shouldAnimate => heroActive && !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _syncControllers() {
    for (final handle in _handles) {
      if (_shouldAnimate) {
        _startIfNeeded(handle);
      } else {
        handle.controller.stop();
      }
    }
  }

  void _startIfNeeded(_HeroControllerHandle handle) {
    if (!handle.controller.isAnimating) {
      handle.controller.repeat(reverse: handle.reverse);
    }
  }

  @override
  void dispose() {
    for (final handle in _handles) {
      handle.controller.dispose();
    }
    super.dispose();
  }
}

class _HeroControllerHandle {
  const _HeroControllerHandle({required this.controller, required this.reverse});

  final AnimationController controller;
  final bool reverse;
}

abstract class OnboardingHeroActive extends StatefulWidget {
  const OnboardingHeroActive({super.key, required this.active});

  final bool active;
}
