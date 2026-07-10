import 'package:flutter/material.dart';

import '../../onboarding_tokens.dart';
import 'ascii_glyph.dart';
import 'pixel_cell_role.dart';
import 'pixel_pattern.dart';
import 'pixel_swarm.dart';

/// Renders a [PixelPattern] with swarm assembly, morph, and pulse.
class PixelGrid extends StatelessWidget {
  const PixelGrid({
    super.key,
    required this.pattern,
    required this.colors,
    this.cellSize = 3,
    this.gap = 1,
    this.enter,
    this.morph,
    this.morphTarget,
    this.pulse,
    this.pulseRoles = const {PixelCellRole.accent},
    this.staggerCells = true,
    this.totalStaggerCells,
    this.transformOrigin = Alignment.center,
    this.scaleX,
    this.opacity = 1,
    this.swarm = true,
    this.swarmSeed = 0,
    this.swarmSpread = 44,
  });

  final PixelPattern pattern;
  final OnboardingColorTokens colors;
  final double cellSize;
  final double gap;
  final Animation<double>? enter;
  final Animation<double>? morph;
  final PixelPattern? morphTarget;
  final Animation<double>? pulse;
  final Set<PixelCellRole> pulseRoles;
  final bool staggerCells;
  final int? totalStaggerCells;
  final Alignment transformOrigin;
  final double? scaleX;
  final double opacity;
  final bool swarm;
  final int swarmSeed;
  final double swarmSpread;

  @override
  Widget build(BuildContext context) {
    final useSwarm = swarm && enter != null;
    final fontSize = cellSize * 1.5;
    final charW = fontSize * 0.58;
    final charH = cellSize * 1.15;
    final gridW = pattern.width * charW + (pattern.width - 1) * gap;
    final gridH = pattern.height * charH + (pattern.height - 1) * gap;

    Widget grid = _PixelGridBody(
      pattern: pattern,
      colors: colors,
      cellSize: cellSize,
      fontSize: fontSize,
      charW: charW,
      charH: charH,
      gap: gap,
      enter: enter,
      morph: morph,
      morphTarget: morphTarget,
      pulse: pulse,
      pulseRoles: pulseRoles,
      staggerCells: staggerCells,
      totalStaggerCells: totalStaggerCells,
      opacity: opacity,
      swarm: useSwarm,
      swarmSeed: swarmSeed,
      swarmSpread: swarmSpread,
    );

    grid = SizedBox(
      width: gridW,
      height: gridH,
      child: grid,
    );

    if (scaleX != null) {
      return Transform.scale(
        scaleX: scaleX!.clamp(0.0, 1.0),
        alignment: transformOrigin,
        child: grid,
      );
    }
    return grid;
  }
}

class _PixelGridBody extends AnimatedWidget {
  const _PixelGridBody({
    required this.pattern,
    required this.colors,
    required this.cellSize,
    required this.fontSize,
    required this.charW,
    required this.charH,
    required this.gap,
    this.enter,
    this.morph,
    this.morphTarget,
    this.pulse,
    required this.pulseRoles,
    required this.staggerCells,
    this.totalStaggerCells,
    required this.opacity,
    required this.swarm,
    required this.swarmSeed,
    required this.swarmSpread,
  }) : super(listenable: enter ?? morph ?? pulse ?? kAlwaysCompleteAnimation);

  final PixelPattern pattern;
  final OnboardingColorTokens colors;
  final double cellSize;
  final double fontSize;
  final double charW;
  final double charH;
  final double gap;
  final Animation<double>? enter;
  final Animation<double>? morph;
  final PixelPattern? morphTarget;
  final Animation<double>? pulse;
  final Set<PixelCellRole> pulseRoles;
  final bool staggerCells;
  final int? totalStaggerCells;
  final double opacity;
  final bool swarm;
  final int swarmSeed;
  final double swarmSpread;

  double get _enterT => enter?.value ?? 1;
  double get _morphT => morph?.value ?? 0;
  double get _pulseT => pulse?.value ?? 1;
  double get _assembleT => PixelSwarmMath.assembleProgress(_enterT);

  @override
  Widget build(BuildContext context) {
    final staggerTotal = totalStaggerCells ?? pattern.cellCount;

    if (swarm) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          for (var y = 0; y < pattern.height; y++)
            for (var x = 0; x < pattern.width; x++)
              _positionedCell(x, y, staggerTotal),
        ],
      );
    }

    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var y = 0; y < pattern.height; y++)
            Padding(
              padding: EdgeInsets.only(bottom: y < pattern.height - 1 ? gap : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var x = 0; x < pattern.width; x++) ...[
                    if (x > 0) SizedBox(width: gap),
                    _cell(x, y, staggerTotal),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _positionedCell(int x, int y, int staggerTotal) {
    final left = x * (charW + gap);
    final top = y * (charH + gap);
    return Positioned(
      left: left,
      top: top,
      child: _cell(x, y, staggerTotal),
    );
  }

  Widget _cell(int x, int y, int staggerTotal) {
    final fromRole = pattern.at(x, y);
    final toRole = morphTarget?.at(x, y) ?? fromRole;

    final fromFilled = fromRole != PixelCellRole.empty;
    final toFilled = toRole != PixelCellRole.empty;
    final morphFill = fromFilled
        ? 1 - _morphT * (fromFilled && !toFilled ? 1 : 0)
        : _morphT * (toFilled ? 1 : 0);
    final filled = morph != null && morphTarget != null
        ? (fromFilled || toFilled) && morphFill > 0.05
        : fromFilled;

    if (!filled) {
      return SizedBox(width: charW, height: charH);
    }

    final staggerIndex = pattern.staggerIndexFor(x, y) ?? 0;
    final role = morph != null && morphTarget != null && _morphT > 0.5
        ? toRole
        : fromRole;

    var cellOpacity = opacity;

    if (swarm && enter != null) {
      final cellT = PixelSwarmMath.cellAssemble(
        assembleProgress: _assembleT,
        staggerIndex: staggerIndex,
        staggerTotal: staggerTotal,
      );
      cellOpacity *= PixelSwarmMath.cellOpacity(_enterT, cellT);
    } else if (staggerCells && enter != null) {
      final idx = pattern.staggerIndexFor(x, y);
      if (idx != null && staggerTotal > 0) {
        final slot = idx / staggerTotal;
        final window = 1 / staggerTotal;
        final local = ((_enterT - slot) / window).clamp(0.0, 1.0);
        cellOpacity *= Curves.easeOut.transform(local);
      }
    }

    if (pulse != null && pulseRoles.contains(role)) {
      cellOpacity *= 0.45 + 0.55 * _pulseT;
    }

    if (morph != null && morphTarget != null) {
      cellOpacity *= morphFill.clamp(0.0, 1.0);
    }

    Widget cell = SizedBox(
      width: charW,
      height: charH,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AsciiGlyph(
          char: asciiCharForRole(role),
          colors: colors,
          role: role,
          fontSize: fontSize,
          glow: role == PixelCellRole.accent && swarm && _assembleT < 0.5,
        ),
      ),
    );

    if (swarm && enter != null) {
      final cellT = PixelSwarmMath.cellAssemble(
        assembleProgress: _assembleT,
        staggerIndex: staggerIndex,
        staggerTotal: staggerTotal,
      );
      final scatter = PixelSwarmMath.scatter(
        seed: swarmSeed,
        cellIndex: staggerIndex + swarmSeed * 17,
        spread: swarmSpread,
      );
      final drift = _assembleT < 0.12
          ? PixelSwarmMath.drift(
              seed: swarmSeed,
              cellIndex: staggerIndex,
              phase: _enterT * 2.5,
              amplitude: 5,
            )
          : Offset.zero;
      final offset = scatter * (1 - cellT) + drift * (1 - _assembleT);
      final scale = PixelSwarmMath.cellScale(cellT);

      cell = Transform.translate(
        offset: offset,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: cell,
        ),
      );
    }

    return Opacity(
      opacity: cellOpacity.clamp(0.0, 1.0),
      child: cell,
    );
  }
}

/// Panel chrome — border reveals after swarm assembles. Never clips swarm motion.
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.width,
    this.reveal,
  });

  final OnboardingColorTokens colors;
  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final Animation<double>? reveal;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border.all(color: colors.borderVisible),
        borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
      ),
      child: child,
    );

    if (reveal == null) {
      return panel;
    }

    return AnimatedBuilder(
      animation: reveal!,
      builder: (context, child) {
        final t = PixelSwarmMath.assembleProgress(reveal!.value);
        final borderOpacity = Curves.easeOut.transform(
          ((t - 0.5) / 0.5).clamp(0.0, 1.0),
        );
        final fillOpacity = Curves.easeOut.transform(
          ((t - 0.62) / 0.38).clamp(0.0, 1.0),
        );
        return SizedBox(
          width: width,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceRaised.withValues(alpha: fillOpacity * 0.95),
              border: Border.all(
                color: colors.borderVisible.withValues(alpha: borderOpacity),
              ),
              borderRadius:
                  BorderRadius.circular(OnboardingTokens.radiusControl),
            ),
            child: Padding(padding: padding, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

/// Monospace status label — fades in after swarm settles.
class PixelAsciiLabel extends StatelessWidget {
  const PixelAsciiLabel({
    super.key,
    required this.text,
    required this.colors,
    this.accent = false,
    this.fontSize = 10,
    this.reveal,
  });

  final String text;
  final OnboardingColorTokens colors;
  final bool accent;
  final double fontSize;
  final Animation<double>? reveal;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: fontSize,
          color: accent ? colors.accent : colors.textSecondary,
          letterSpacing: 0.6,
        );

    if (reveal == null) {
      return Text(text, style: style);
    }

    return AnimatedBuilder(
      animation: reveal!,
      builder: (context, _) {
        final t = PixelSwarmMath.assembleProgress(reveal!.value);
        final labelOpacity =
            Curves.easeOut.transform(((t - 0.75) / 0.25).clamp(0, 1));
        return Opacity(
          opacity: labelOpacity,
          child: Text(text, style: style),
        );
      },
    );
  }
}

/// Horizontal progress made of discrete pixel blocks.
class PixelProgressBar extends AnimatedWidget {
  PixelProgressBar({
    super.key,
    required this.colors,
    required this.animation,
    this.blockCount = 8,
    this.blockSize = 3,
    this.gap = 1,
    this.height = 4,
    this.live = true,
    this.swarmSeed = 0,
    this.enter,
  }) : super(
          listenable: enter != null
              ? Listenable.merge([animation, enter as Animation<double>])
              : animation,
        );

  final OnboardingColorTokens colors;
  final Animation<double> animation;
  final int blockCount;
  final double blockSize;
  final double gap;
  final double height;
  final bool live;
  final int swarmSeed;
  final Animation<double>? enter;

  @override
  Widget build(BuildContext context) {
    final fill = live ? animation.value : 0.45;
    final filledBlocks = (blockCount * fill).round().clamp(0, blockCount);
    final enterT = enter?.value ?? 1;
    final assemble = PixelSwarmMath.assembleProgress(enterT);
    final fontSize = blockSize * 1.5;
    final charW = fontSize * 0.58;
    final totalW = blockCount * charW + (blockCount - 1) * gap;

    return SizedBox(
      width: totalW,
      height: blockSize * 1.15,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < blockCount; i++)
            Positioned(
              left: i * (charW + gap),
              top: 0,
              child: _progressBlock(
                i,
                filledBlocks,
                assemble,
                enterT,
                fontSize,
              ),
            ),
        ],
      ),
    );
  }

  Widget _progressBlock(
    int i,
    int filledBlocks,
    double assemble,
    double enterT,
    double fontSize,
  ) {
    final cellT = PixelSwarmMath.cellAssemble(
      assembleProgress: assemble,
      staggerIndex: i,
      staggerTotal: blockCount,
    );
    final scatter = PixelSwarmMath.scatter(
      seed: swarmSeed,
      cellIndex: i + 40,
      spread: 28,
    );
    final offset = scatter * (1 - cellT);
    final isFilled = i < filledBlocks;

    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: PixelSwarmMath.cellOpacity(enterT, cellT),
        child: AsciiGlyph(
          char: isFilled
              ? (i.isEven ? '█' : '!')
              : (i.isEven ? '░' : '-'),
          colors: colors,
          role: isFilled ? PixelCellRole.accent : PixelCellRole.muted,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

/// Status dot built from a 2×2 pixel cluster.
class PixelStatusDot extends AnimatedWidget {
  PixelStatusDot({
    super.key,
    required this.colors,
    required this.animation,
    this.accent = false,
    this.live = true,
    this.enter,
    this.swarmSeed = 0,
  }) : super(
          listenable: enter != null
              ? Listenable.merge([animation, enter as Animation<double>])
              : animation,
        );

  final OnboardingColorTokens colors;
  final Animation<double> animation;
  final bool accent;
  final bool live;
  final Animation<double>? enter;
  final int swarmSeed;

  @override
  Widget build(BuildContext context) {
    final opacity = accent && live ? animation.value : 1.0;
    final pattern = accent
        ? PixelPattern.fromAscii('!!\n!!')
        : PixelPattern.fromAscii('--\n--');
    return Opacity(
      opacity: opacity,
      child: PixelGrid(
        pattern: pattern,
        colors: colors,
        cellSize: 2.5,
        gap: 0.5,
        enter: enter,
        swarmSeed: swarmSeed,
        swarmSpread: 32,
        pulseRoles: const {},
      ),
    );
  }
}
