import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'shared/mini_chat_primitives.dart';
import 'shared/onboarding_hero_frame.dart';
import 'shared/onboarding_hero_lifecycle.dart';

/// Animated encrypted chat — messages scramble in transit, E2E badge pulses.
class PairingHero extends OnboardingHeroActive {
  const PairingHero({super.key, required super.active});

  @override
  State<PairingHero> createState() => _PairingHeroState();
}

class _PairingHeroState extends State<PairingHero>
    with TickerProviderStateMixin<PairingHero>, OnboardingHeroLifecycle<PairingHero> {
  late final AnimationController _loop;

  static const _plain = 'Ship the pairing flow tonight';
  static const _cipherGlyphs = r'§∆◊⊗λ9#k∑π¤';

  @override
  void initState() {
    super.initState();
    _loop = createHeroController(duration: const Duration(milliseconds: 4200));
  }

  String _scrambledText(double t) {
    if (t < 0.18) return _plain.substring(0, (_plain.length * (t / 0.18)).floor().clamp(0, _plain.length));
    if (t > 0.82) {
      final reveal = ((t - 0.82) / 0.18).clamp(0.0, 1.0);
      return _plain.substring(0, (_plain.length * reveal).floor().clamp(0, _plain.length));
    }
    final buffer = StringBuffer();
    for (var i = 0; i < _plain.length; i++) {
      final seed = (i * 17 + (t * 120).floor()) % _cipherGlyphs.length;
      buffer.write(_cipherGlyphs[seed]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = _loop.value;
        final pulse = (math.sin(t * math.pi * 2) + 1) / 2;
        final streamPhase = (t * 3) % 1.0;
        return OnboardingHeroFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiniChatHeader(
                title: 'Trusted workspace chat',
                trailing: MiniE2EBadge(pulse: pulse),
              ),
              const SizedBox(height: 12),
              MiniChatBubble(
                text: 'Pair my laptop when you get a sec',
                alignEnd: true,
              ),
              const SizedBox(height: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  MiniChatBubble(
                    text: '',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _scrambledText(t),
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            height: 1.35,
                            color: t > 0.18 && t < 0.82 ? colors.accent : colors.textPrimary,
                            letterSpacing: t > 0.18 && t < 0.82 ? 0.8 : 0,
                          ),
                        ),
                        if (t > 0.18 && t < 0.82) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.enhanced_encryption_rounded, size: 12, color: colors.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Encrypting in transit',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 9,
                                  color: colors.textSecondary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  ...List.generate(4, (index) {
                    final offset = (streamPhase + index * 0.18) % 1.0;
                    return Positioned(
                      right: 8 + offset * 28,
                      top: -6 + math.sin(offset * math.pi * 2) * 4,
                      child: Opacity(
                        opacity: (1 - offset).clamp(0.0, 1.0) * 0.85,
                        child: Icon(
                          Icons.key_rounded,
                          size: 10,
                          color: colors.accent.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TrustedDeviceChip(label: 'Phone', trusted: true, pulse: pulse),
                      const SizedBox(width: 8),
                      _TrustedDeviceChip(label: 'Desktop', trusted: t > 0.55, pulse: pulse),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Workspace context stays on device',
                    style: GoogleFonts.spaceMono(
                      fontSize: 8,
                      color: colors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrustedDeviceChip extends StatelessWidget {
  const _TrustedDeviceChip({
    required this.label,
    required this.trusted,
    required this.pulse,
  });

  final String label;
  final bool trusted;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return AnimatedContainer(
      duration: OnboardingTokens.durationUi,
      curve: OnboardingTokens.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: trusted ? colors.accent.withValues(alpha: 0.1 + pulse * 0.04) : colors.border,
        borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
        border: Border.all(
          color: trusted ? colors.accent.withValues(alpha: 0.5) : colors.borderVisible,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trusted ? Icons.verified_user_rounded : Icons.radio_button_unchecked_rounded,
            size: 11,
            color: trusted ? colors.accent : colors.textDisabled,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              color: trusted ? colors.textPrimary : colors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
