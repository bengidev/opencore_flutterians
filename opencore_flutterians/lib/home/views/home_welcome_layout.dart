class HomeWelcomeLayoutMetrics {
  const HomeWelcomeLayoutMetrics({
    required this.topSpacerMinLength,
    required this.bottomSpacerMinLength,
    required this.orbHeight,
    required this.orbBottomPadding,
  });

  final double topSpacerMinLength;
  final double bottomSpacerMinLength;
  final double orbHeight;
  final double orbBottomPadding;

  static const heroTextBlockHeight = 66.0;
  static const minEdgeSpacing = 16.0;
  static const compactEdgeSpacing = 8.0;
  static const standardOrbHeight = 260.0;
  static const standardOrbPadding = 28.0;
  static const compactOrbHeight = 200.0;
  static const compactOrbPadding = 20.0;
  static const microOrbHeight = 140.0;
  static const microOrbPadding = 12.0;

  /// Resolves welcome metrics for [viewportHeight].
  ///
  /// Pass [textBlockHeight] from a measured greeting block (textScaler-aware).
  /// Falls through standard → compact → micro so short / landscape viewports
  /// still fit without relying solely on scroll.
  static HomeWelcomeLayoutMetrics resolve(
    double viewportHeight, {
    double textBlockHeight = heroTextBlockHeight,
  }) {
    final textHeight =
        textBlockHeight > 0 ? textBlockHeight : heroTextBlockHeight;

    if (viewportHeight <= 0) {
      return const HomeWelcomeLayoutMetrics(
        topSpacerMinLength: 72,
        bottomSpacerMinLength: 72,
        orbHeight: standardOrbHeight,
        orbBottomPadding: standardOrbPadding,
      );
    }

    final standard = _centered(
      viewportHeight: viewportHeight,
      orbHeight: standardOrbHeight,
      orbBottomPadding: standardOrbPadding,
      textBlockHeight: textHeight,
      minEdge: minEdgeSpacing,
    );
    if (standard != null) return standard;

    final compact = _centered(
      viewportHeight: viewportHeight,
      orbHeight: compactOrbHeight,
      orbBottomPadding: compactOrbPadding,
      textBlockHeight: textHeight,
      minEdge: minEdgeSpacing,
    );
    if (compact != null) return compact;

    final micro = _centered(
      viewportHeight: viewportHeight,
      orbHeight: microOrbHeight,
      orbBottomPadding: microOrbPadding,
      textBlockHeight: textHeight,
      minEdge: compactEdgeSpacing,
    );
    if (micro != null) return micro;

    // Still too short — pin micro orb with minimal edges; caller should scroll.
    final heroHeight = microOrbHeight + microOrbPadding + textHeight;
    final remaining = viewportHeight - heroHeight;
    final edge = remaining > 0
        ? (remaining / 2).clamp(0.0, compactEdgeSpacing)
        : 0.0;

    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: edge,
      bottomSpacerMinLength: edge,
      orbHeight: microOrbHeight,
      orbBottomPadding: microOrbPadding,
    );
  }

  static HomeWelcomeLayoutMetrics? _centered({
    required double viewportHeight,
    required double orbHeight,
    required double orbBottomPadding,
    required double textBlockHeight,
    required double minEdge,
  }) {
    final heroHeight = orbHeight + orbBottomPadding + textBlockHeight;
    if (heroHeight > viewportHeight) return null;
    final spacing = (viewportHeight - heroHeight) / 2;
    final edge = spacing < minEdge ? minEdge : spacing;
    if (heroHeight + (edge * 2) > viewportHeight + 0.5) {
      // Min edges push content over — reject this tier.
      if (heroHeight + (minEdge * 2) > viewportHeight) return null;
      final tight = (viewportHeight - heroHeight) / 2;
      return HomeWelcomeLayoutMetrics(
        topSpacerMinLength: tight,
        bottomSpacerMinLength: tight,
        orbHeight: orbHeight,
        orbBottomPadding: orbBottomPadding,
      );
    }
    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: edge,
      bottomSpacerMinLength: edge,
      orbHeight: orbHeight,
      orbBottomPadding: orbBottomPadding,
    );
  }

  /// Minimum height needed for the densest (micro) layout with [textBlockHeight].
  static double minContentHeight({
    double textBlockHeight = heroTextBlockHeight,
  }) {
    return microOrbHeight + microOrbPadding + textBlockHeight;
  }
}
