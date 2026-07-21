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
  static const minEdgeSpacing = 12.0;
  static const compactEdgeSpacing = 6.0;
  static const standardOrbHeight = 220.0;
  static const standardOrbPadding = 20.0;
  static const compactOrbHeight = 172.0;
  static const compactOrbPadding = 14.0;
  static const microOrbHeight = 120.0;
  static const microOrbPadding = 10.0;

  /// Fraction of free vertical space placed above the hero.
  /// Below 0.5 sits the block higher and leaves more room for the composer.
  static const topBias = 0.32;

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
        topSpacerMinLength: 48,
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
    final edgeBudget = remaining > 0
        ? remaining.clamp(0.0, compactEdgeSpacing * 2)
        : 0.0;

    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: edgeBudget * topBias,
      bottomSpacerMinLength: edgeBudget * (1 - topBias),
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
    final free = viewportHeight - heroHeight;
    if (free < minEdge * 2) {
      if (heroHeight + (minEdge * 2) > viewportHeight) return null;
      return HomeWelcomeLayoutMetrics(
        topSpacerMinLength: free * topBias,
        bottomSpacerMinLength: free * (1 - topBias),
        orbHeight: orbHeight,
        orbBottomPadding: orbBottomPadding,
      );
    }
    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: free * topBias,
      bottomSpacerMinLength: free * (1 - topBias),
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
