import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../onboarding_motion.dart';
import '../onboarding_theme.dart';
import '../onboarding_tokens.dart' show OnboardingColorTokens, OnboardingTokens;
import 'shared/onboarding_hero_frame.dart';
import 'shared/onboarding_hero_lifecycle.dart';

enum _DepthMode { fast, balanced, deep }

/// Thinking-depth control — fast, balanced, and deep reasoning visualized as node depth.
class DepthHero extends OnboardingHeroActive {
  const DepthHero({super.key, required super.active});

  @override
  State<DepthHero> createState() => _DepthHeroState();
}

class _DepthHeroState extends State<DepthHero>
    with TickerProviderStateMixin<DepthHero>, OnboardingHeroLifecycle<DepthHero> {
  late final AnimationController _loop;

  static const _modes = [
    (mode: _DepthMode.fast, label: 'Fast', nodes: 1),
    (mode: _DepthMode.balanced, label: 'Balanced', nodes: 3),
    (mode: _DepthMode.deep, label: 'Deep', nodes: 7),
  ];

  /// Mode segment phases — enter crossfade, staggered build, calm hold, soft exit.
  static const _enterEnd = 0.08;
  static const _buildEnd = 0.88;
  static const _holdEnd = 0.94;

  @override
  void initState() {
    super.initState();
    _loop = createHeroController(duration: const Duration(milliseconds: 10500));
  }

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    final reduceMotion = OnboardingMotion.reduceMotionOf(context);

    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = _loop.value;
        final modeIndex = (t * _modes.length).floor() % _modes.length;
        final local = (t * _modes.length) % 1.0;
        final current = _modes[modeIndex];
        final previous = _modes[(modeIndex - 1 + _modes.length) % _modes.length];

        final enterT = (local / _enterEnd).clamp(0.0, 1.0);
        final crossfade = reduceMotion ? 1.0 : OnboardingTokens.easeInOut.transform(enterT);

        final buildLocal = local <= _enterEnd
            ? 0.0
            : ((local - _enterEnd) / (_buildEnd - _enterEnd)).clamp(0.0, 1.0);
        final buildProgress = reduceMotion ? 1.0 : buildLocal;

        final inHold = local >= _buildEnd && local < _holdEnd;
        final inExit = local >= _holdEnd;
        final holdPhase = inHold ? ((local - _buildEnd) / (_holdEnd - _buildEnd)).clamp(0.0, 1.0) : 0.0;
        final exitPhase = inExit ? ((local - _holdEnd) / (1 - _holdEnd)).clamp(0.0, 1.0) : 0.0;

        final pulse = reduceMotion
            ? 0.0
            : inHold
                ? (math.sin(holdPhase * math.pi * 2) + 1) / 2 * 0.55
                : inExit
                    ? (1 - exitPhase) * 0.25
                    : crossfade * 0.15;

        final nodeActivations = _nodeActivations(
          current.mode,
          buildProgress: buildProgress,
          reduceMotion: reduceMotion,
        );

        return OnboardingHeroFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reasoning depth',
                style: GoogleFonts.spaceMono(fontSize: 9, color: colors.textSecondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_modes.length, (index) {
                  final selected = index == modeIndex;
                  final entering = selected && local < _enterEnd;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == _modes.length - 1 ? 0 : 6),
                      child: AnimatedContainer(
                        duration: OnboardingTokens.durationUi,
                        curve: OnboardingTokens.easeOut,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.accent.withValues(alpha: entering ? 0.08 + crossfade * 0.06 : 0.14)
                              : colors.surfaceRaised,
                          borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
                          border: Border.all(
                            color: selected
                                ? colors.accent.withValues(alpha: entering ? 0.25 + crossfade * 0.3 : 0.55)
                                : colors.border,
                          ),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: OnboardingTokens.durationUi,
                          curve: OnboardingTokens.easeOut,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: selected ? colors.textDisplay : colors.textSecondary,
                          ),
                          child: Text(
                            _modes[index].label,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _DepthGraphPainter(
                        colors: colors,
                        mode: current.mode,
                        fadeFromMode: crossfade < 1 ? previous.mode : null,
                        crossfade: crossfade,
                        nodeActivations: nodeActivations,
                        pulse: pulse,
                        exitDim: inExit ? exitPhase * 0.35 : 0.0,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: OnboardingTokens.durationUi,
                switchInCurve: OnboardingTokens.easeOut,
                switchOutCurve: OnboardingTokens.easeOut,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ...previousChildren,
                      ?currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  return OnboardingMotion.fadeSlide(
                    child,
                    animation: animation,
                    offsetY: 0.03,
                  );
                },
                child: Text(
                  _subtitleFor(current.mode),
                  key: ValueKey(current.mode),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    height: 1.35,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<double> _nodeActivations(
    _DepthMode mode, {
    required double buildProgress,
    required bool reduceMotion,
  }) {
    final order = _activationOrder(mode);
    if (reduceMotion) {
      return List<double>.filled(order.length, 1.0);
    }

    // One node at a time — each gets a slot with ramp + dwell before the next starts.
    final activations = List<double>.filled(order.length, 0.0);
    final slot = 1.0 / order.length;
    const rampFraction = 0.72;

    for (var step = 0; step < order.length; step++) {
      final node = order[step];
      final slotStart = step * slot;
      final ramp = slot * rampFraction;
      final local = ((buildProgress - slotStart) / ramp).clamp(0.0, 1.0);
      activations[node] = OnboardingTokens.easeInOut.transform(local);
    }

    return activations;
  }

  static List<int> _activationOrder(_DepthMode mode) {
    final childMap = _childrenFor(mode);
    final visited = <int>{};
    final order = <int>[];
    void visit(int node) {
      if (visited.contains(node)) return;
      visited.add(node);
      order.add(node);
      for (final child in childMap[node] ?? const <int>[]) {
        visit(child);
      }
    }

    visit(0);
    return order;
  }

  static Map<int, List<int>> _childrenFor(_DepthMode mode) => switch (mode) {
        _DepthMode.fast => {},
        _DepthMode.balanced => {0: [1, 2]},
        _DepthMode.deep => {
            0: [1, 2],
            1: [3, 4],
            2: [5, 6],
          },
      };

  String _subtitleFor(_DepthMode mode) => switch (mode) {
        _DepthMode.fast => 'Quick answers with minimal planning overhead',
        _DepthMode.balanced => 'Plans before committing compute to the task',
        _DepthMode.deep => 'Explores branches before the model responds',
      };
}

class _DepthGraphPainter extends CustomPainter {
  _DepthGraphPainter({
    required this.colors,
    required this.mode,
    required this.fadeFromMode,
    required this.crossfade,
    required this.nodeActivations,
    required this.pulse,
    required this.exitDim,
  });

  final OnboardingColorTokens colors;
  final _DepthMode mode;
  final _DepthMode? fadeFromMode;
  final double crossfade;
  final List<double> nodeActivations;
  final double pulse;
  final double exitDim;

  static const _inactiveScale = 0.92;

  @override
  void paint(Canvas canvas, Size size) {
    if (fadeFromMode != null && crossfade < 1) {
      _paintGraph(
        canvas,
        size,
        fadeFromMode!,
        List<double>.filled(_nodeCount(fadeFromMode!), 1.0),
        opacity: (1 - crossfade) * (1 - exitDim * 0.5),
        pulse: pulse * 0.35,
      );
    }

    _paintGraph(
      canvas,
      size,
      mode,
      nodeActivations,
      opacity: crossfade * (1 - exitDim),
      pulse: pulse,
    );
  }

  void _paintGraph(
    Canvas canvas,
    Size size,
    _DepthMode graphMode,
    List<double> activations, {
    required double opacity,
    required double pulse,
  }) {
    if (opacity <= 0.01) return;

    final nodes = _layoutNodes(size, graphMode);
    final edgePaint = Paint()
      ..color = colors.borderVisible.withValues(alpha: colors.borderVisible.a * opacity)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < nodes.length; i++) {
      for (final child in _children(i, graphMode)) {
        if (child >= nodes.length) continue;
        final edgeStrength = math.min(activations[i], activations[child]);
        if (edgeStrength <= 0.02) continue;
        edgePaint.color = Color.lerp(
          colors.border.withValues(alpha: colors.border.a * opacity),
          colors.accent.withValues(alpha: 0.45 * opacity),
          edgeStrength,
        )!;
        canvas.drawLine(nodes[i], nodes[child], edgePaint);
      }
    }

    for (var i = 0; i < nodes.length; i++) {
      final activation = activations[i].clamp(0.0, 1.0);
      if (activation <= 0.01) continue;

      final scale = _inactiveScale + (1 - _inactiveScale) * activation;
      final radius = (5.5 + activation * 2.5 + pulse * activation * 1.2) * scale;
      final center = nodes[i];

      final ringAlpha = (0.18 + pulse * 0.22) * activation * opacity;
      if (ringAlpha > 0.01) {
        final ring = Paint()
          ..color = colors.accent.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * scale;
        canvas.drawCircle(center, radius + 4, ring);
      }

      final fill = Paint()
        ..color = Color.lerp(
          colors.border.withValues(alpha: colors.border.a * opacity),
          colors.accent.withValues(alpha: 0.85 * opacity),
          activation,
        )!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fill);
    }
  }

  int _nodeCount(_DepthMode graphMode) => switch (graphMode) {
        _DepthMode.fast => 1,
        _DepthMode.balanced => 3,
        _DepthMode.deep => 7,
      };

  List<Offset> _layoutNodes(Size size, _DepthMode mode) {
    final cx = size.width / 2;
    final top = 12.0;
    final mid = size.height * 0.42;
    final bottom = size.height - 12;
    return switch (mode) {
      _DepthMode.fast => [Offset(cx, mid)],
      _DepthMode.balanced => [
          Offset(cx, top),
          Offset(cx * 0.55, bottom),
          Offset(cx * 1.45, bottom),
        ],
      _DepthMode.deep => [
          Offset(cx, top),
          Offset(cx * 0.35, mid),
          Offset(cx * 1.65, mid),
          Offset(cx * 0.2, bottom),
          Offset(cx * 0.75, bottom),
          Offset(cx * 1.25, bottom),
          Offset(cx * 1.8, bottom),
        ],
    };
  }

  List<int> _children(int index, _DepthMode mode) => switch (mode) {
        _DepthMode.fast => <int>[],
        _DepthMode.balanced => switch (index) {
            0 => [1, 2],
            _ => <int>[],
          },
        _DepthMode.deep => switch (index) {
            0 => [1, 2],
            1 => [3, 4],
            2 => [5, 6],
            _ => <int>[],
          },
      };

  @override
  bool shouldRepaint(covariant _DepthGraphPainter oldDelegate) =>
      oldDelegate.mode != mode ||
      oldDelegate.fadeFromMode != fadeFromMode ||
      oldDelegate.crossfade != crossfade ||
      oldDelegate.pulse != pulse ||
      oldDelegate.exitDim != exitDim ||
      !_listEquals(oldDelegate.nodeActivations, nodeActivations);

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.001) return false;
    }
    return true;
  }
}
