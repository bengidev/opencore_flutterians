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
  static const standardOrbHeight = 260.0;
  static const standardOrbPadding = 28.0;
  static const compactOrbHeight = 200.0;
  static const compactOrbPadding = 20.0;

  static HomeWelcomeLayoutMetrics resolve(double viewportHeight) {
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
    );
    if (standard != null) return standard;

    final compactHero =
        compactOrbHeight + compactOrbPadding + heroTextBlockHeight;
    final spacing = (viewportHeight - compactHero) / 2;
    final edge = spacing < minEdgeSpacing ? minEdgeSpacing : spacing;

    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: edge,
      bottomSpacerMinLength: edge,
      orbHeight: compactOrbHeight,
      orbBottomPadding: compactOrbPadding,
    );
  }

  static HomeWelcomeLayoutMetrics? _centered({
    required double viewportHeight,
    required double orbHeight,
    required double orbBottomPadding,
  }) {
    final heroHeight = orbHeight + orbBottomPadding + heroTextBlockHeight;
    if (heroHeight > viewportHeight) return null;
    final spacing = (viewportHeight - heroHeight) / 2;
    final edge = spacing < minEdgeSpacing ? minEdgeSpacing : spacing;
    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: edge,
      bottomSpacerMinLength: edge,
      orbHeight: orbHeight,
      orbBottomPadding: orbBottomPadding,
    );
  }
}
