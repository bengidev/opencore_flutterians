import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_tokens.dart';

/// Shared press feedback — scale to [HomeTokens.pressScale] on touch so
/// controls feel responsive (Emil: buttons must feel like they listen).
class HomePressable extends StatefulWidget {
  const HomePressable({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.semanticLabel,
    this.enableHaptics = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final String? semanticLabel;
  final bool enableHaptics;

  @override
  State<HomePressable> createState() => _HomePressableState();
}

class _HomePressableState extends State<HomePressable> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_enabled) return;
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Asymmetric timing: press settles quickly, release is snappier.
    final duration = reduceMotion
        ? Duration.zero
        : (_pressed ? HomeTokens.durationPress : HomeTokens.durationRelease);

    Widget child = Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        onTap: _enabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _pressed ? HomeTokens.pressScale : 1,
          duration: duration,
          curve: HomeTokens.easeOut,
          child: widget.child,
        ),
      ),
    );

    final tooltip = widget.tooltip;
    if (tooltip != null && tooltip.isNotEmpty) {
      child = Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: child,
      );
    }

    return child;
  }
}
