import 'pixel_cell_role.dart';

/// Immutable grid of pixel cells, built from compact ASCII art.
class PixelPattern {
  const PixelPattern(this.rows);

  final List<List<PixelCellRole>> rows;

  int get height => rows.length;
  int get width => rows.isEmpty ? 0 : rows.first.length;

  int get cellCount {
    var n = 0;
    for (final row in rows) {
      for (final cell in row) {
        if (cell != PixelCellRole.empty) n++;
      }
    }
    return n;
  }

  PixelCellRole at(int x, int y) {
    if (y < 0 || y >= height || x < 0 || x >= width) {
      return PixelCellRole.empty;
    }
    return rows[y][x];
  }

  /// Linear index over non-empty cells only (for stagger orchestration).
  int? staggerIndexFor(int x, int y) {
    var index = 0;
    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        final role = rows[row][col];
        if (role == PixelCellRole.empty) continue;
        if (row == y && col == x) return index;
        index++;
      }
    }
    return null;
  }

  static PixelPattern fromAscii(
    String art, {
    String empty = '.',
    String muted = '-',
    String primary = '#',
    String accent = '!',
  }) {
    final map = <String, PixelCellRole>{
      empty: PixelCellRole.empty,
      muted: PixelCellRole.muted,
      primary: PixelCellRole.primary,
      accent: PixelCellRole.accent,
    };
    final lines = art
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final parsed = <List<PixelCellRole>>[];
    for (final line in lines) {
      parsed.add([
        for (final char in line.split(''))
          map[char] ?? PixelCellRole.empty,
      ]);
    }
    return PixelPattern(parsed);
  }
}

/// Shared pixel motifs for onboarding heroes.
abstract final class OnboardingPixelPatterns {
  static final device = PixelPattern.fromAscii('''
    ########
    #......#
    #......#
    #......#
    #......#
    ########
  ''');

  static final deviceScreen = PixelPattern.fromAscii('''
    ........
    ..#-#-#.
    ..#-#-#.
    ..#-#-#.
    ........
  ''');

  static final lockOpen = PixelPattern.fromAscii('''
    ..####..
    .#....#.
    #..##..#
    #..##..#
    .#....#.
    ..####..
  ''');

  static final lockClosed = PixelPattern.fromAscii('''
    ..####..
    .######.
    .######.
    .######.
    .######.
    ..####..
  ''');

  static final link = PixelPattern.fromAscii('''
    !!!!!!!!
  ''');

  static final badgeE2e = PixelPattern.fromAscii('''
    !.#.
    !.#.
    !...
    .#..
  ''');

  static final badgeAi = PixelPattern.fromAscii('''
    !.#.
    !.#.
    !...
  ''');

  static final badgeOc = PixelPattern.fromAscii('''
    !.#.
    !.#.
    !...
  ''');

  static final chevron = PixelPattern.fromAscii('''
    ...
    .!.
    ..!
    .!.
    ...
  ''');

  static final caret = PixelPattern.fromAscii('''
    .
    !
    .
  ''');

  static final outputLine = PixelPattern.fromAscii('''
    #######
  ''');

  static final outputLineShort = PixelPattern.fromAscii('''
    #####
  ''');

  static final outputLineShorter = PixelPattern.fromAscii('''
    ###
  ''');

  static final barFast = PixelPattern.fromAscii('''
    ##
  ''');

  static final barBalanced = PixelPattern.fromAscii('''
    !!!!
  ''');

  static final barDeep = PixelPattern.fromAscii('''
    ######
  ''');

  static final barFastMuted = PixelPattern.fromAscii('''
    --
  ''');

  static final barBalancedMuted = PixelPattern.fromAscii('''
    ----
  ''');

  static final barDeepMuted = PixelPattern.fromAscii('''
    ------
  ''');

  /// Outgoing user request bubble (right-biased body).
  static final chatRequest = PixelPattern.fromAscii('''
    ..######
    .#----##
    .#----##
    ..######
  ''');

  /// Model response bubble with accent live cells.
  static final chatResponse = PixelPattern.fromAscii('''
    ########..
    ##!!!!##..
    ##----##..
    ########..
  ''');

  /// Muted queued follow-up request.
  static final chatQueued = PixelPattern.fromAscii('''
    ..------
    .-------
    ..------
  ''');
}
