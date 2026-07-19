import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';

/// Shared press feedback — scale down on touch so controls feel responsive.
class OnboardingTactileShell extends StatefulWidget {
  const OnboardingTactileShell({
    super.key,
    required this.onPressed,
    required this.builder,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool enabled;
  final Widget Function(BuildContext context, bool pressed) builder;

  @override
  State<OnboardingTactileShell> createState() => _OnboardingTactileShellState();
}

class _OnboardingTactileShellState extends State<OnboardingTactileShell> {
  bool _pressed = false;

  bool get _enabled => widget.enabled && widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => _setPressed(true) : null,
      onTapUp: _enabled ? (_) => _setPressed(false) : null,
      onTapCancel: _enabled ? () => _setPressed(false) : null,
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: _pressed ? OnboardingTokens.durationFast : OnboardingTokens.durationRelease,
        curve: OnboardingTokens.easeOut,
        child: widget.builder(context, _pressed && _enabled),
      ),
    );
  }
}

class OnboardingFilledButton extends StatelessWidget {
  const OnboardingFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    final isEnabled = enabled && onPressed != null;

    return OnboardingTactileShell(
      onPressed: onPressed,
      enabled: isEnabled,
      builder: (context, pressed) {
        return AnimatedContainer(
          duration: pressed ? OnboardingTokens.durationFast : OnboardingTokens.durationRelease,
          curve: OnboardingTokens.easeOut,
          constraints: const BoxConstraints(minWidth: 120, minHeight: 48),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !isEnabled
                ? c.textDisabled.withValues(alpha: 0.35)
                : pressed
                    ? c.textPrimary
                    : c.textDisplay,
            borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
          ),
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: isEnabled ? c.black : c.textDisabled,
                  fontWeight: FontWeight.w500,
                ),
            child: child,
          ),
        );
      },
    );
  }
}

class OnboardingOutlinedButton extends StatelessWidget {
  const OnboardingOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;

    return OnboardingTactileShell(
      onPressed: onPressed,
      builder: (context, pressed) {
        return AnimatedContainer(
          duration: pressed ? OnboardingTokens.durationFast : OnboardingTokens.durationRelease,
          curve: OnboardingTokens.easeOut,
          constraints: const BoxConstraints(minWidth: 120, minHeight: 48),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pressed ? c.textPrimary.withValues(alpha: 0.08) : Colors.transparent,
            border: Border.all(
              color: pressed ? c.textPrimary : c.borderVisible,
              width: pressed ? 1.25 : 1,
            ),
            borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: pressed ? c.textDisplay : c.textPrimary),
            child: child,
          ),
        );
      },
    );
  }
}

class OnboardingTextButton extends StatelessWidget {
  const OnboardingTextButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;

    return OnboardingTactileShell(
      onPressed: onPressed,
      builder: (context, pressed) {
        return AnimatedContainer(
          duration: pressed ? OnboardingTokens.durationFast : OnboardingTokens.durationRelease,
          curve: OnboardingTokens.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: pressed ? c.textPrimary.withValues(alpha: 0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
          ),
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: pressed ? c.textDisplay : c.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
            child: child,
          ),
        );
      },
    );
  }
}
