import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'shared/onboarding_hero_lifecycle.dart';

/// Brand CTA — command-center hub with orbiting specialist agents.
class BrandHero extends OnboardingHeroActive {
  const BrandHero({super.key, required super.active});

  @override
  State<BrandHero> createState() => _BrandHeroState();
}

class _BrandHeroState extends State<BrandHero>
    with TickerProviderStateMixin<BrandHero>, OnboardingHeroLifecycle<BrandHero> {
  late final AnimationController _orbit;

  static const _agents = [
    (icon: Icons.code_rounded, label: 'Code'),
    (icon: Icons.fact_check_rounded, label: 'Review'),
    (icon: Icons.science_rounded, label: 'Test'),
    (icon: Icons.rocket_launch_rounded, label: 'Ship'),
  ];

  @override
  void initState() {
    super.initState();
    _orbit = createHeroController(duration: const Duration(milliseconds: 8000));
  }

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _orbit,
      builder: (context, _) {
        final t = _orbit.value;
        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(300, 300),
                painter: _OrbitRingPainter(colors: colors),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'OpenCore',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 42),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI-native command center',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              ...List.generate(_agents.length, (index) {
                final angle = (index / _agents.length) * math.pi * 2 + t * math.pi * 2;
                const radius = 118.0;
                final dx = math.cos(angle) * radius;
                final dy = math.sin(angle) * radius;
                final agent = _agents[index];
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: _AgentNode(
                    icon: agent.icon,
                    label: agent.label,
                    highlighted: (t + index * 0.18) % 1.0 < 0.22,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _AgentNode extends StatelessWidget {
  const _AgentNode({
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return AnimatedContainer(
      duration: OnboardingTokens.durationUi,
      curve: OnboardingTokens.easeOut,
      width: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? colors.accent.withValues(alpha: 0.16) : colors.surface,
        borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
        border: Border.all(
          color: highlighted ? colors.accent.withValues(alpha: 0.55) : colors.borderVisible,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: highlighted ? colors.accent : colors.textPrimary),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 8,
              color: highlighted ? colors.textDisplay : colors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  _OrbitRingPainter({required this.colors});

  final OnboardingColorTokens colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ring = Paint()
      ..color = colors.borderVisible.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 118, ring);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) => false;
}
