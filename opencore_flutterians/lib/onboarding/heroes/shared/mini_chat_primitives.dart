import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../onboarding_theme.dart';
import '../../onboarding_tokens.dart';

class MiniChatHeader extends StatelessWidget {
  const MiniChatHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textPrimary,
              letterSpacing: 0.04 * 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class MiniChatBubble extends StatelessWidget {
  const MiniChatBubble({
    super.key,
    required this.text,
    this.alignEnd = false,
    this.muted = false,
    this.child,
  });

  final String text;
  final bool alignEnd;
  final bool muted;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    final bg = alignEnd ? colors.textDisplay : colors.surfaceRaised;
    final fg = alignEnd ? colors.black : colors.textPrimary;
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: muted ? colors.border : bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(OnboardingTokens.radiusControl),
            topRight: const Radius.circular(OnboardingTokens.radiusControl),
            bottomLeft: Radius.circular(alignEnd ? OnboardingTokens.radiusControl : 2),
            bottomRight: Radius.circular(alignEnd ? 2 : OnboardingTokens.radiusControl),
          ),
        ),
        child: child ??
            Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                height: 1.35,
                color: muted ? colors.textSecondary : fg,
              ),
            ),
      ),
    );
  }
}

class MiniTypingDots extends StatelessWidget {
  const MiniTypingDots({super.key, required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final t = ((phase + index * 0.22) % 1.0);
        final scale = 0.55 + (t < 0.5 ? t : 1 - t) * 0.9;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: colors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class MiniE2EBadge extends StatelessWidget {
  const MiniE2EBadge({super.key, this.pulse = 0});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    final glow = 0.25 + pulse * 0.35;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12 + pulse * 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.accent.withValues(alpha: 0.35 + glow * 0.2)),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: glow * 0.25),
            blurRadius: 8 * pulse,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 10, color: colors.accent),
          const SizedBox(width: 3),
          Text(
            'E2E',
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: colors.accent,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
