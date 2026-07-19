import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'shared/mini_chat_primitives.dart';
import 'shared/onboarding_hero_frame.dart';
import 'shared/onboarding_hero_lifecycle.dart';

/// AI workspace surface — prompt streams into draft, refactor, and research panes.
class WorkspaceHero extends OnboardingHeroActive {
  const WorkspaceHero({super.key, required super.active});

  @override
  State<WorkspaceHero> createState() => _WorkspaceHeroState();
}

class _WorkspaceHeroState extends State<WorkspaceHero>
    with TickerProviderStateMixin<WorkspaceHero>, OnboardingHeroLifecycle<WorkspaceHero> {
  late final AnimationController _loop;

  static const _tabs = ['Draft', 'Refactor', 'Research'];
  static const _snippets = [
    'Outline the onboarding copy…',
    'Extract a reusable widget…',
    'Compare layout patterns…',
  ];
  static const _responses = [
    '• Hero copy stays task-focused\n• Pairing explains E2E first',
    '- split OnboardingHero\n+ OnboardingHeroRegistry',
    'Sources: HIG motion, product UI density',
  ];

  @override
  void initState() {
    super.initState();
    _loop = createHeroController(duration: const Duration(milliseconds: 5400));
  }

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = _loop.value;
        final tabIndex = (t * _tabs.length).floor() % _tabs.length;
        final local = (t * _tabs.length) % 1.0;
        final typedChars = (_responses[tabIndex].length * (local / 0.72).clamp(0.0, 1.0)).floor();
        final response = _responses[tabIndex].substring(0, typedChars);

        return OnboardingHeroFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiniChatHeader(title: 'OpenCore workspace'),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_tabs.length, (index) {
                  final selected = index == tabIndex;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 6),
                      child: AnimatedContainer(
                        duration: OnboardingTokens.durationUi,
                        curve: OnboardingTokens.easeOut,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? colors.textDisplay : colors.surfaceRaised,
                          borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
                          border: Border.all(
                            color: selected ? colors.textDisplay : colors.border,
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            color: selected ? colors.black : colors.textSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              OnboardingMiniPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Prompt',
                      style: GoogleFonts.spaceMono(fontSize: 8, color: colors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _snippets[tabIndex],
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: OnboardingMiniPanel(
                  accentBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 12, color: colors.accent),
                          const SizedBox(width: 4),
                          Text(
                            'Model output',
                            style: GoogleFonts.spaceMono(fontSize: 8, color: colors.textSecondary),
                          ),
                          const Spacer(),
                          if (typedChars < _responses[tabIndex].length)
                            MiniTypingDots(phase: local),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            response.isEmpty ? ' ' : response,
                            style: GoogleFonts.spaceMono(
                              fontSize: 10,
                              height: 1.45,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
