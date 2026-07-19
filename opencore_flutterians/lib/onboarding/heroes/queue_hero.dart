import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../onboarding_theme.dart';
import 'shared/mini_chat_primitives.dart';
import 'shared/onboarding_hero_frame.dart';
import 'shared/onboarding_hero_lifecycle.dart';

/// Queue follow-ups while the current model turn is still streaming.
class QueueHero extends OnboardingHeroActive {
  const QueueHero({super.key, required super.active});

  @override
  State<QueueHero> createState() => _QueueHeroState();
}

class _QueueHeroState extends State<QueueHero>
    with TickerProviderStateMixin<QueueHero>, OnboardingHeroLifecycle<QueueHero> {
  late final AnimationController _loop;

  static const _activeResponse =
      'Refactoring the onboarding hero registry so each page can mount its own animated illustration…';
  static const _queued = [
    'Add reduced-motion fallback',
    'Write widget tests for queue state',
    'Ship when CI is green',
  ];

  @override
  void initState() {
    super.initState();
    _loop = createHeroController(duration: const Duration(milliseconds: 4800));
  }

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = _loop.value;
        final streamChars = (_activeResponse.length * ((t * 1.4) % 1.0)).floor();
        final visibleQueued = ((t * 3.2).floor()).clamp(0, _queued.length);
        final progress = (t * 1.4) % 1.0;

        return OnboardingHeroFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiniChatHeader(
                title: 'Agent turn in progress',
                trailing: _RunningPill(progress: progress),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: OnboardingMiniPanel(
                  accentBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: progress,
                              color: colors.accent,
                              backgroundColor: colors.border,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Streaming response',
                            style: GoogleFonts.spaceMono(fontSize: 8, color: colors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          _activeResponse.substring(0, streamChars),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            height: 1.4,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: MiniTypingDots(phase: progress),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Queued next',
                style: GoogleFonts.spaceMono(fontSize: 8, color: colors.textSecondary),
              ),
              const SizedBox(height: 6),
              Expanded(
                flex: 2,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleQueued,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    return _QueueRow(
                      index: index + 1,
                      label: _queued[index],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RunningPill extends StatelessWidget {
  const _RunningPill({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        '${(progress * 100).round()}%',
        style: GoogleFonts.spaceMono(
          fontSize: 9,
          color: colors.accent,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.index, required this.label});

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return OnboardingMiniPanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$index',
              style: GoogleFonts.spaceMono(fontSize: 9, color: colors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: colors.textPrimary),
            ),
          ),
          Icon(Icons.schedule_rounded, size: 12, color: colors.textDisabled),
        ],
      ),
    );
  }
}
