import 'package:flutter/material.dart';

import '../../onboarding_tokens.dart';

/// Feed that grows item-by-item and pins to the bottom once it overflows the viewport.
class MiniGrowingFeed extends StatelessWidget {
  const MiniGrowingFeed({
    super.key,
    required this.visibleCount,
    required this.itemHeight,
    required this.itemBuilder,
    this.itemGap = 6,
    this.fadeExtent = 22,
    this.reduceMotion = false,
    this.revealScaled,
    this.entranceFraction = 0.32,
  });

  final int visibleCount;
  final double itemHeight;
  final double itemGap;
  final double fadeExtent;
  final bool reduceMotion;

  /// Continuous reveal progress (0 → item count). Drives per-row entrance and scroll.
  final double? revealScaled;

  /// Share of each item slot spent easing in; the remainder is a settled hold.
  final double entranceFraction;
  final Widget Function(BuildContext context, int index) itemBuilder;

  double get _rowStride => itemHeight + itemGap;

  static ({int count, double scaled}) reveal({
    required double t,
    required int itemCount,
    double buildPortion = 0.82,
    double entranceFraction = 0.32,
  }) {
    if (itemCount <= 0) return (count: 0, scaled: 0.0);

    // Reveal every item across [0, buildPortion), then hold the full list until loop reset.
    if (t >= buildPortion) {
      return (count: itemCount, scaled: itemCount.toDouble());
    }

    final scaled = ((t / buildPortion) * itemCount).clamp(0.0, itemCount.toDouble());
    if (scaled <= 0) return (count: 0, scaled: 0.0);

    // One slot per item; the next item waits until the previous slot finishes (entrance + dwell).
    final count = scaled.ceil().clamp(1, itemCount);
    return (count: count, scaled: scaled);
  }

  /// Per-row entrance in [0, 1]. Each item eases in during the first [entranceFraction]
  /// of its slot, then holds until the next item begins.
  static double rowEntrance(
    double scaled,
    int index, {
    double entranceFraction = 0.32,
  }) {
    final local = scaled - index;
    if (local <= 0) return 0;
    if (local >= entranceFraction) return 1;
    return OnboardingTokens.easeInOut.transform(local / entranceFraction);
  }

  static double rowTopFade(double top, double fadeExtent, {double scrollOffset = 0}) {
    // Rows at rest below the label should render fully; only fade when scrolling off the top.
    if (scrollOffset <= 0 && top >= 0) return 1.0;
    if (top >= fadeExtent) return 1.0;
    if (top <= -fadeExtent) return 0.0;
    if (top < 0) return (1 + top / fadeExtent).clamp(0.0, 1.0);
    return OnboardingTokens.easeOut.transform(top / fadeExtent);
  }

  @override
  Widget build(BuildContext context) {
    if (visibleCount <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        final viewportHeight = constraints.maxHeight;
        final count = visibleCount;
        final scaled = revealScaled ?? count.toDouble();
        final layoutScaled = _layoutScaled(scaled);
        final contentHeight = layoutScaled * itemHeight +
            (layoutScaled - 1).clamp(0.0, double.infinity) * itemGap;
        final maxVisible = (viewportHeight / _rowStride).floor().clamp(1, count);
        final scrollOffset = layoutScaled > maxVisible
            ? (contentHeight - viewportHeight).clamp(0.0, double.infinity)
            : 0.0;

        return SizedBox(
          height: viewportHeight,
          width: constraints.maxWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < count; i++)
                Positioned(
                  top: i * _rowStride - scrollOffset,
                  left: 0,
                  right: 0,
                  height: itemHeight,
                  child: _buildRow(
                    context,
                    index: i,
                    top: i * _rowStride - scrollOffset,
                    scaled: scaled,
                    scrollOffset: scrollOffset,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required int index,
    required double top,
    required double scaled,
    required double scrollOffset,
  }) {
    final entrance = reduceMotion ? 1.0 : rowEntrance(scaled, index, entranceFraction: entranceFraction);
    final edge = rowTopFade(top, fadeExtent, scrollOffset: scrollOffset);
    final opacity = (edge * entrance).clamp(0.0, 1.0);

    if (reduceMotion) {
      return Opacity(opacity: opacity, child: itemBuilder(context, index));
    }

    final slide = (1 - entrance) * 6;
    final scale = 0.98 + entrance * 0.02;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, slide),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.centerLeft,
          child: itemBuilder(context, index),
        ),
      ),
    );
  }

  /// Layout height grows during entrance, then holds through the dwell before the next item.
  double _layoutScaled(double scaled) {
    if (scaled <= 0) return 0;
    final base = scaled.floor();
    final local = scaled - base;
    if (local <= entranceFraction) {
      return base + rowEntrance(scaled, base, entranceFraction: entranceFraction);
    }
    return (base + 1).toDouble();
  }
}

/// Pinned text output — follows the typing caret and scrolls older lines up with a top fade.
class MiniPinnedTextFeed extends StatelessWidget {
  const MiniPinnedTextFeed({
    super.key,
    required this.text,
    required this.style,
    this.lineHeight = 14.5,
    this.fadeExtent = 20,
    this.reduceMotion = false,
  });

  final String text;
  final TextStyle style;
  final double lineHeight;
  final double fadeExtent;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    if (lines.isEmpty || (lines.length == 1 && lines.first.isEmpty)) {
      return const SizedBox.expand();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        final viewportHeight = constraints.maxHeight;
        final contentHeight = lines.length * lineHeight;
        final maxVisible = (viewportHeight / lineHeight).floor().clamp(1, lines.length);
        final scrollOffset = lines.length > maxVisible
            ? (contentHeight - viewportHeight).clamp(0.0, double.infinity)
            : 0.0;

        return SizedBox(
          height: viewportHeight,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (var i = 0; i < lines.length; i++)
                  Positioned(
                    top: i * lineHeight - scrollOffset,
                    left: 0,
                    right: 0,
                    height: lineHeight,
                    child: Opacity(
                      opacity: reduceMotion
                          ? 1.0
                          : MiniGrowingFeed.rowTopFade(i * lineHeight - scrollOffset, fadeExtent),
                      child: Text(
                        lines[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
