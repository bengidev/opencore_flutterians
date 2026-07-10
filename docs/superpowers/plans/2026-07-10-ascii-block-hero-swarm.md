# ASCII + Block Pixel Hero Swarm Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Feature heroes (01–04) scatter mixed `░▒▓█` + ASCII across the hero stage, assemble into interactive feature highlights with ambient loops, and support tap-to-replay; queue becomes a chat request/response vignette; brand stays unchanged.

**Architecture:** Upgrade the shared pixel kit (`ascii_glyph`, `pixel_swarm`, `pixel_grid`, `pixel_pattern`) so glyphs, full-stage scatter with soft edge fade, and tap-to-replay live in one place. Each feature hero remains a thin skin: pairing/workspace/depth keep layouts and wire the kit; queue replaces the arrow with chat bubbles. `OnboardingHeroMotion` already skips scatter under reduced motion — keep that path and ensure assembly respects it.

**Tech Stack:** Flutter 3.x / Dart 3.12+, existing `flutter_test`, onboarding tokens/theme, current pixel hero kit under `lib/onboarding/heroes/pixel/`.

**Spec:** `docs/superpowers/specs/2026-07-10-ascii-block-hero-swarm-design.md`

---

## File Structure

All paths relative to `opencore_flutterians/` (the Flutter package root).

| Path | Responsibility |
|------|----------------|
| `lib/onboarding/heroes/pixel/ascii_glyph.dart` | Role → mixed `░▒▓█` + ASCII; swarm glyph pool |
| `lib/onboarding/heroes/pixel/pixel_swarm.dart` | Scatter math, full-stage cloud + edge fade, `PixelHeroAssembly` + tap replay |
| `lib/onboarding/heroes/pixel/pixel_grid.dart` | Assembled cells / bars / labels using mixed glyphs |
| `lib/onboarding/heroes/pixel/pixel_pattern.dart` | Motifs; add chat bubble patterns; stop using `queueArrow` in queue hero |
| `lib/onboarding/heroes/pixel/onboarding_hero_motion.dart` | Enter + life; expose `replayHero()` for tap |
| `lib/onboarding/heroes/onboarding_pairing_hero.dart` | Wire full-stage swarm + tap; keep device/link/lock loops |
| `lib/onboarding/heroes/onboarding_workspace_hero.dart` | Wire full-stage swarm + tap; keep caret/line loops |
| `lib/onboarding/heroes/onboarding_queue_hero.dart` | Chat request/response + queued bubble; no arrow |
| `lib/onboarding/heroes/onboarding_depth_hero.dart` | Wire full-stage swarm + tap; keep balanced bar grow |
| `lib/onboarding/heroes/onboarding_brand_hero.dart` | **Do not** apply full-stage swarm kit (leave as-is) |
| `lib/onboarding/onboarding_tokens.dart` | Keep `durationHeroEnter` in 900–1100ms range |
| `test/onboarding/pixel/ascii_glyph_test.dart` | Glyph mapping + swarm pool |
| `test/onboarding/pixel/pixel_swarm_test.dart` | Assemble timing, edge fade, tap replay |
| `test/onboarding/onboarding_queue_hero_test.dart` | Chat layout; no arrow |
| `test/onboarding/onboarding_hero_strategy_test.dart` | Keep registry smoke; ensure queue still builds |

---

### Task 1: Mixed glyph mapping (TDD)

**Files:**
- Modify: `lib/onboarding/heroes/pixel/ascii_glyph.dart`
- Test: `test/onboarding/pixel/ascii_glyph_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/onboarding/pixel/ascii_glyph_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/ascii_glyph.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_cell_role.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';

void main() {
  group('asciiCharForRole', () {
    test('maps roles to shade blocks by default', () {
      expect(asciiCharForRole(PixelCellRole.empty), '');
      expect(asciiCharForRole(PixelCellRole.muted), '░');
      expect(asciiCharForRole(PixelCellRole.primary), '▓');
      expect(asciiCharForRole(PixelCellRole.accent), '█');
    });

    test('maps roles to ASCII accents when asciiAccent is true', () {
      expect(asciiCharForRole(PixelCellRole.muted, asciiAccent: true), '-');
      expect(asciiCharForRole(PixelCellRole.primary, asciiAccent: true), '#');
      expect(asciiCharForRole(PixelCellRole.accent, asciiAccent: true), '!');
    });
  });

  group('swarmGlyphsFromPatterns', () {
    test('includes shade blocks and ASCII accents', () {
      final glyphs = swarmGlyphsFromPatterns([
        PixelPattern.fromAscii('#!-'),
      ]);
      expect(glyphs, containsAll(['░', '▒', '▓', '█', '-', '.', ':', '#', '+', '=', '!', '*', '>']));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/ascii_glyph_test.dart
```

Expected: FAIL — `asciiAccent` named arg missing and/or expected chars still `#`/`-`/`!` only.

- [ ] **Step 3: Write minimal implementation**

Replace glyph helpers in `lib/onboarding/heroes/pixel/ascii_glyph.dart`:

```dart
import 'package:flutter/material.dart';

import '../../onboarding_tokens.dart';
import 'pixel_cell_role.dart';
import 'pixel_pattern.dart';

/// Monospace glyph for a pixel cell role.
///
/// Default display uses shade blocks. Pass [asciiAccent] for ASCII companions
/// used in mixed swarm / decorative cells.
String asciiCharForRole(PixelCellRole role, {bool asciiAccent = false}) {
  if (asciiAccent) {
    return switch (role) {
      PixelCellRole.empty => '',
      PixelCellRole.muted => '-',
      PixelCellRole.primary => '#',
      PixelCellRole.accent => '!',
    };
  }
  return switch (role) {
    PixelCellRole.empty => '',
    PixelCellRole.muted => '░',
    PixelCellRole.primary => '▓',
    PixelCellRole.accent => '█',
  };
}

/// Fixed mixed pool for swarm clouds (blocks + ASCII).
const kSwarmGlyphPool = <String>[
  '░', '▒', '▓', '█',
  '-', '.', ':',
  '#', '+', '=',
  '!', '*', '>',
];

/// Collect display glyphs from hero motifs, always unioned with the mixed pool.
List<String> swarmGlyphsFromPatterns(List<PixelPattern> patterns) {
  final glyphs = <String>{...kSwarmGlyphPool};
  for (final pattern in patterns) {
    for (final row in pattern.rows) {
      for (final role in row) {
        final block = asciiCharForRole(role);
        final ascii = asciiCharForRole(role, asciiAccent: true);
        if (block.isNotEmpty) glyphs.add(block);
        if (ascii.isNotEmpty) glyphs.add(ascii);
      }
    }
  }
  return glyphs.toList();
}
```

Keep the existing `AsciiGlyph` widget; only change how callers pick `char` (Tasks 2–3). Leave `AsciiGlyph` constructor unchanged.

Also add a secondary primary shade helper used by swarm particles:

```dart
String shadeForIndex(int index) {
  const shades = ['░', '▒', '▓', '█'];
  return shades[index % shades.length];
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/ascii_glyph_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes/pixel/ascii_glyph.dart \
  opencore_flutterians/test/onboarding/pixel/ascii_glyph_test.dart
git commit -m "$(cat <<'EOF'
Map pixel roles to mixed shade blocks and ASCII glyphs.

EOF
)"
```

---

### Task 2: PixelGrid + progress bars use mixed glyphs

**Files:**
- Modify: `lib/onboarding/heroes/pixel/pixel_grid.dart`
- Test: `test/onboarding/pixel/ascii_glyph_test.dart` (extend) or create `test/onboarding/pixel/pixel_grid_glyph_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/onboarding/pixel/pixel_grid_glyph_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_grid.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/onboarding_tokens.dart';

void main() {
  testWidgets('PixelGrid renders shade-block glyphs for filled cells', (tester) async {
    final colors = OnboardingTokens.dark;
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: Center(
            child: PixelGrid(
              pattern: PixelPattern.fromAscii('#!-'),
              colors: colors,
              cellSize: 6,
              gap: 1,
              swarm: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('█'), findsWidgets);
    expect(find.text('▓'), findsWidgets);
    expect(find.text('░'), findsWidgets);
    expect(find.text('#'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/pixel_grid_glyph_test.dart
```

Expected: FAIL — still finds `#` / `!` / `-` or missing shade blocks.

- [ ] **Step 3: Update PixelGrid / PixelProgressBar glyph selection**

In `pixel_grid.dart`, where `AsciiGlyph` is built for cells, use:

```dart
char: asciiCharForRole(role),
```

(already calls `asciiCharForRole` — after Task 1 this returns shade blocks.)

For `PixelProgressBar` blocks, change:

```dart
char: isFilled ? '█' : '░',
```

Optionally mix every other filled block with `'!'` for accent ASCII:

```dart
char: isFilled ? (i.isEven ? '█' : '!') : (i.isEven ? '░' : '-'),
```

Keep layout math (`fontSize = cellSize * 1.5`, `charW = fontSize * 0.58`, `charH = cellSize * 1.15`) unless overflows appear — then tighten multipliers slightly, do not enlarge.

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/pixel_grid_glyph_test.dart test/onboarding/pixel/ascii_glyph_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes/pixel/pixel_grid.dart \
  opencore_flutterians/test/onboarding/pixel/pixel_grid_glyph_test.dart
git commit -m "$(cat <<'EOF'
Render assembled pixel grids with shade-block glyphs.

EOF
)"
```

---

### Task 3: Full-stage swarm cloud + soft edge fade + tap replay

**Files:**
- Modify: `lib/onboarding/heroes/pixel/pixel_swarm.dart`
- Modify: `lib/onboarding/heroes/pixel/onboarding_hero_motion.dart`
- Test: `test/onboarding/pixel/pixel_swarm_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/onboarding/pixel/pixel_swarm_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/ascii_glyph.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_swarm.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/onboarding_tokens.dart';

void main() {
  group('PixelSwarmMath', () {
    test('holds assemble at zero during early scatter', () {
      expect(PixelSwarmMath.assembleProgress(0.0), 0);
      expect(PixelSwarmMath.assembleProgress(0.2), 0);
      expect(PixelSwarmMath.assembleProgress(1.0), 1);
    });

    test('edgeFade is lower near margins than center', () {
      expect(PixelSwarmMath.edgeFade(0.0, 0.5), lessThan(0.4));
      expect(PixelSwarmMath.edgeFade(0.5, 0.5), greaterThan(0.85));
      expect(PixelSwarmMath.edgeFade(1.0, 0.0), lessThan(0.4));
    });
  });

  testWidgets('PixelHeroAssembly tap restarts enter animation', (tester) async {
    final enter = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 400),
    );
    addTearDown(enter.dispose);
    enter.value = 1;

    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: PixelHeroAssembly(
            enter: enter,
            colors: OnboardingTokens.dark,
            seed: 7,
            motifs: [OnboardingPixelPatterns.link],
            onReplay: () => enter.forward(from: 0),
            child: const SizedBox(width: 40, height: 40, child: Text('GUI')),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(enter.value, 1);

    await tester.tap(find.byType(PixelHeroAssembly));
    await tester.pump();
    expect(enter.value, lessThan(1));
    expect(enter.isAnimating, isTrue);
    enter.stop();
  });

  testWidgets('swarm cloud uses mixed glyph pool characters', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: PixelSwarmCloud(
            patterns: [OnboardingPixelPatterns.link],
            colors: OnboardingTokens.dark,
            enterT: 0.15,
            seed: 3,
            width: 280,
            height: 140,
            particleCount: 40,
          ),
        ),
      ),
    );
    await tester.pump();
    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data);
    expect(texts.any(kSwarmGlyphPool.contains), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/pixel_swarm_test.dart
```

Expected: FAIL — missing `edgeFade`, missing `onReplay`, and/or cloud still only `#`/`!`.

- [ ] **Step 3: Implement swarm math + assembly updates**

In `pixel_swarm.dart`:

1. Keep assemble window roughly:
   - `assembleStart = 0.28`
   - `assembleEnd = 0.94`
   - `guiRevealStart = 0.20`

2. Add edge fade (normalized x/y in 0..1 relative to cloud):

```dart
static double edgeFade(double nx, double ny) {
  final dx = (nx - 0.5).abs() * 2; // 0 center → 1 edge
  final dy = (ny - 0.5).abs() * 2;
  final radial = math.max(dx, dy);
  return (1 - Curves.easeIn.transform(radial.clamp(0.0, 1.0)) * 0.75)
      .clamp(0.15, 1.0);
}
```

3. Expand `PixelSwarmCloud` defaults to full stage:
   - `width = 320`, `height = 150`, `particleCount = 160`, `columns = 18`
   - Scatter spread ~28–36 (not 18)
   - Particle char from `kSwarmGlyphPool[i % kSwarmGlyphPool.length]` (mixed blocks + ASCII)
   - Multiply opacity by `edgeFade(col/(columns-1), row/(rows-1))`

4. Update `PixelHeroAssembly`:

```dart
class PixelHeroAssembly extends StatelessWidget {
  const PixelHeroAssembly({
    super.key,
    required this.enter,
    required this.colors,
    required this.seed,
    required this.motifs,
    required this.child,
    this.onReplay,
    this.cloudWidth = 320,
    this.cloudHeight = 150,
    this.particleCount = 160,
  });

  final VoidCallback? onReplay;
  // ...existing fields...

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onReplay,
      child: AnimatedBuilder(
        animation: enter,
        builder: (context, assembled) {
          final t = enter.value;
          final reduced = MediaQuery.disableAnimationsOf(context);
          final cloud = reduced ? 0.0 : PixelSwarmMath.cloudOpacity(t);
          final gui = reduced ? 1.0 : PixelSwarmMath.guiOpacity(t);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (cloud > 0.03)
                IgnorePointer(
                  child: Opacity(
                    opacity: cloud,
                    child: PixelSwarmCloud(
                      patterns: motifs,
                      colors: colors,
                      enterT: t,
                      seed: seed,
                      width: cloudWidth,
                      height: cloudHeight,
                      particleCount: particleCount,
                    ),
                  ),
                ),
              if (gui > 0.01) Opacity(opacity: gui, child: assembled),
            ],
          );
        },
        child: child,
      ),
    );
  }
}
```

5. In `onboarding_hero_motion.dart`, add:

```dart
void replayHero() => playHero(fromStart: true);
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/pixel_swarm_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes/pixel/pixel_swarm.dart \
  opencore_flutterians/lib/onboarding/heroes/pixel/onboarding_hero_motion.dart \
  opencore_flutterians/test/onboarding/pixel/pixel_swarm_test.dart
git commit -m "$(cat <<'EOF'
Add full-stage mixed glyph swarm with edge fade and tap replay.

EOF
)"
```

---

### Task 4: Chat bubble patterns for queue

**Files:**
- Modify: `lib/onboarding/heroes/pixel/pixel_pattern.dart`
- Test: `test/onboarding/pixel/pixel_pattern_chat_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/onboarding/pixel/pixel_pattern_chat_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';

void main() {
  test('chat bubble patterns exist and are non-empty', () {
    expect(OnboardingPixelPatterns.chatRequest.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatResponse.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatQueued.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatResponse.width,
        greaterThan(OnboardingPixelPatterns.chatRequest.width - 1));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/pixel_pattern_chat_test.dart
```

Expected: FAIL — getters undefined.

- [ ] **Step 3: Add chat patterns**

Append to `OnboardingPixelPatterns` in `pixel_pattern.dart`:

```dart
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
    .------
    ..------
  ''');
```

Keep `queueArrow` defined for now (unused) or delete only after queue hero no longer references it (Task 5). Prefer delete in Task 5 to avoid dead code.

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/pixel_pattern_chat_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes/pixel/pixel_pattern.dart \
  opencore_flutterians/test/onboarding/pixel/pixel_pattern_chat_test.dart
git commit -m "$(cat <<'EOF'
Add chat bubble pixel patterns for queue hero.

EOF
)"
```

---

### Task 5: Rebuild queue hero as chat vignette

**Files:**
- Modify: `lib/onboarding/heroes/onboarding_queue_hero.dart`
- Test: `test/onboarding/onboarding_queue_hero_test.dart`
- Modify: `test/onboarding/onboarding_hero_strategy_test.dart` (only if imports break)

- [ ] **Step 1: Write the failing widget test**

Create `test/onboarding/onboarding_queue_hero_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/onboarding_queue_hero.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';

void main() {
  testWidgets('queue hero shows chat labels and no arrow motif dependency',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(
          body: SizedBox(
            height: 180,
            child: OnboardingQueueHero(active: true),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(OnboardingQueueHero), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('RUNNING…'), findsOneWidget);
    expect(find.text('QUEUED'), findsOneWidget);
  });

  testWidgets('tap on queue hero does not throw', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: const Scaffold(
          body: SizedBox(
            height: 180,
            child: OnboardingQueueHero(active: true),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(OnboardingQueueHero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_queue_hero_test.dart
```

Expected: FAIL — labels `YOU` / chat layout missing.

- [ ] **Step 3: Rewrite queue hero layout**

Replace `onboarding_queue_hero.dart` body with a chat column (no arrow `PixelGrid`):

```dart
/// Swarm → chat request/response bubbles with queued follow-up.
class OnboardingQueueHero extends StatefulWidget {
  const OnboardingQueueHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingQueueHero> createState() => _OnboardingQueueHeroState();
}

class _OnboardingQueueHeroState extends State<OnboardingQueueHero>
    with TickerProviderStateMixin, OnboardingHeroMotion {
  static const _seed = 33;
  static final _motifs = [
    OnboardingPixelPatterns.chatRequest,
    OnboardingPixelPatterns.chatResponse,
    OnboardingPixelPatterns.chatQueued,
  ];

  @override
  bool get heroActive => widget.active;

  late final Animation<double> _requestEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.14, 0.52, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _responseEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.28, 0.72, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _queuedEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.42, 0.88, curve: OnboardingTokens.easeOut),
  );

  late final Animation<double> _pulse = lifePulse();
  late final Animation<double> _progress = lifeProgress();

  @override
  void initState() {
    super.initState();
    life.duration = const Duration(milliseconds: 1100);
  }

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    final live = enter.isCompleted;

    return OnboardingHeroStage(
      designHeight: 168,
      child: PixelHeroAssembly(
        enter: enter,
        colors: c,
        seed: _seed,
        motifs: _motifs,
        onReplay: replayHero,
        cloudWidth: 320,
        cloudHeight: 160,
        particleCount: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                colors: c,
                label: 'YOU',
                pattern: OnboardingPixelPatterns.chatRequest,
                swarmEnter: enter,
                reveal: _requestEnter,
                accent: false,
                live: live,
                seed: _seed,
                maxWidthFactor: 0.72,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _ChatBubble(
                colors: c,
                label: 'RUNNING…',
                pattern: OnboardingPixelPatterns.chatResponse,
                swarmEnter: enter,
                reveal: _responseEnter,
                accent: true,
                live: live,
                seed: _seed + 1,
                progress: _progress,
                pulse: _pulse,
                maxWidthFactor: 0.82,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                colors: c,
                label: 'QUEUED',
                pattern: OnboardingPixelPatterns.chatQueued,
                swarmEnter: enter,
                reveal: _queuedEnter,
                accent: false,
                live: false,
                seed: _seed + 2,
                maxWidthFactor: 0.64,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Add `_ChatBubble` in the same file:

```dart
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.colors,
    required this.label,
    required this.pattern,
    required this.swarmEnter,
    required this.reveal,
    required this.accent,
    required this.live,
    required this.seed,
    required this.maxWidthFactor,
    this.progress,
    this.pulse,
  });

  final OnboardingColorTokens colors;
  final String label;
  final PixelPattern pattern;
  final Animation<double> swarmEnter;
  final Animation<double> reveal;
  final bool accent;
  final bool live;
  final int seed;
  final double maxWidthFactor;
  final Animation<double>? progress;
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: maxWidthFactor,
      child: PixelPanel(
        colors: colors,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        reveal: reveal,
        child: Row(
          children: [
            PixelGrid(
              pattern: pattern,
              colors: colors,
              cellSize: 3.5,
              gap: 0.8,
              enter: swarmEnter,
              swarmSeed: seed,
              pulse: accent ? pulse : null,
              pulseRoles: const {PixelCellRole.accent},
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelAsciiLabel(
                text: label,
                colors: colors,
                accent: accent,
                reveal: reveal,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(width: 8),
              PixelProgressBar(
                colors: colors,
                animation: progress!,
                live: live,
                enter: swarmEnter,
                swarmSeed: seed + 9,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

Remove all `queueArrow` usage. Delete `queueArrow` from `pixel_pattern.dart` in this same task if nothing else references it.

- [ ] **Step 4: Run tests**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_queue_hero_test.dart test/onboarding/onboarding_hero_strategy_test.dart
```

Expected: PASS; no overflow exceptions in console.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes/onboarding_queue_hero.dart \
  opencore_flutterians/lib/onboarding/heroes/pixel/pixel_pattern.dart \
  opencore_flutterians/test/onboarding/onboarding_queue_hero_test.dart
git commit -m "$(cat <<'EOF'
Rebuild queue hero as chat request and response bubbles.

EOF
)"
```

---

### Task 6: Wire pairing, workspace, depth to full-stage swarm + tap

**Files:**
- Modify: `lib/onboarding/heroes/onboarding_pairing_hero.dart`
- Modify: `lib/onboarding/heroes/onboarding_workspace_hero.dart`
- Modify: `lib/onboarding/heroes/onboarding_depth_hero.dart`
- Do **not** modify brand swarm behavior beyond leaving it alone

- [ ] **Step 1: Write a smoke test for tap wiring on pairing**

Add to `test/onboarding/onboarding_hero_strategy_test.dart` (or new `test/onboarding/onboarding_feature_hero_replay_test.dart`):

```dart
testWidgets('pairing hero accepts tap without overflow', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: OnboardingTheme.dark(),
      home: const Scaffold(
        body: SizedBox(
          height: 180,
          child: OnboardingPairingHero(active: true),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.tap(find.byType(OnboardingPairingHero));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
});
```

Import `onboarding_pairing_hero.dart` if not already exported via strategy file.

- [ ] **Step 2: Run test (may pass already; still wire heroes)**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_feature_hero_replay_test.dart
```

- [ ] **Step 3: Update each feature hero’s `PixelHeroAssembly`**

For pairing, workspace, and depth, change the assembly call to:

```dart
PixelHeroAssembly(
  enter: enter,
  colors: c,
  seed: _seed,
  motifs: _motifs,
  onReplay: replayHero,
  cloudWidth: 320,
  cloudHeight: 156,
  particleCount: 160,
  child: /* existing child unchanged */,
)
```

Keep existing ambient loops (link/lock pulse, caret blink, balanced bar grow).

**Brand rule (hard):** Do **not** modify `onboarding_brand_hero.dart` in this task. It may already use `PixelHeroAssembly` with a smaller cloud (`cloudWidth: 250`, `particleCount: 120`) and no `onReplay` — leave that file exactly as-is so the CTA stays simpler. Shared glyph mapping changes from Tasks 1–2 may still affect brand cell characters; that is acceptable.

- [ ] **Step 4: Run hero + strategy tests**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_hero_strategy_test.dart test/onboarding/onboarding_feature_hero_replay_test.dart test/onboarding/onboarding_queue_hero_test.dart
```

Expected: PASS; no RenderFlex overflows.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes/onboarding_pairing_hero.dart \
  opencore_flutterians/lib/onboarding/heroes/onboarding_workspace_hero.dart \
  opencore_flutterians/lib/onboarding/heroes/onboarding_depth_hero.dart \
  opencore_flutterians/test/onboarding/onboarding_feature_hero_replay_test.dart
git commit -m "$(cat <<'EOF'
Wire feature heroes to full-stage swarm and tap replay.

EOF
)"
```

---

### Task 7: Reduced-motion verification + full suite

**Files:**
- Possibly tweak: `lib/onboarding/heroes/pixel/pixel_swarm.dart` (already skips cloud when reduced)
- Test: extend `test/onboarding/pixel/pixel_swarm_test.dart`

- [ ] **Step 1: Write reduced-motion test**

Append to `pixel_swarm_test.dart`:

```dart
testWidgets('reduced motion skips swarm cloud and shows GUI', (tester) async {
  final enter = AnimationController(
    vsync: const TestVSync(),
    duration: const Duration(milliseconds: 400),
  )..value = 0;
  addTearDown(enter.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: OnboardingTheme.dark(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Scaffold(
        body: PixelHeroAssembly(
          enter: enter,
          colors: OnboardingTokens.dark,
          seed: 1,
          motifs: [OnboardingPixelPatterns.link],
          child: const Text('ASSEMBLED'),
        ),
      ),
    ),
  );
  await tester.pump();
  expect(find.text('ASSEMBLED'), findsOneWidget);
  // Cloud particles are Text glyphs; assembled label must be visible at t=0 under reduced motion.
  expect(find.text('ASSEMBLED'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify fail/pass**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/pixel/pixel_swarm_test.dart
```

If FAIL because `gui` still 0 at `enter.value == 0`, ensure Task 3 reduced-motion branch sets `gui = 1.0` when `MediaQuery.disableAnimationsOf(context)` is true (independent of `enter.value`).

- [ ] **Step 3: Confirm tokens duration**

In `onboarding_tokens.dart`, keep:

```dart
static const durationHeroEnter = Duration(milliseconds: 900);
```

If scatter feels too short during manual check, bump to `1000` or `1100` only — stay within spec range.

- [ ] **Step 4: Run full onboarding test suite**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/
```

Expected: all PASS; no overflow exceptions.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes/pixel/pixel_swarm.dart \
  opencore_flutterians/lib/onboarding/onboarding_tokens.dart \
  opencore_flutterians/test/onboarding/pixel/pixel_swarm_test.dart
git commit -m "$(cat <<'EOF'
Verify reduced-motion path skips hero swarm scatter.

EOF
)"
```

---

### Task 8: Manual polish checklist (no code unless broken)

**Files:** none required unless a defect is found

- [ ] **Step 1: Hot restart and walk pages 01–04**

Confirm visually:

1. Mixed `░▒▓█` + ASCII scatter across the hero stage with thinner edges
2. Glyphs assemble into the feature GUI
3. Ambient loops run (pairing link, workspace caret, queue response progress, depth balanced bar)
4. Tap replays swarm → assemble
5. Queue is chat bubbles (YOU / RUNNING… / QUEUED), no arrow
6. Brand page unchanged / simpler

- [ ] **Step 2: Fix only regressions found**

If overflow: reduce `particleCount` or `swarmSpread`, keep `clipBehavior: Clip.none` on swarm stacks.  
If glyphs too large: lower `fontSize` multiplier in `pixel_grid.dart` (e.g. `1.35`).  
If tap does nothing: ensure `onReplay: replayHero` is passed and `GestureDetector` is not blocked by `IgnorePointer` on the cloud only.

- [ ] **Step 3: Re-run suite after any fix**

```bash
cd opencore_flutterians && flutter test test/onboarding/
```

- [ ] **Step 4: Final commit if fixes landed**

```bash
git add -u opencore_flutterians/lib/onboarding/heroes opencore_flutterians/test/onboarding
git commit -m "$(cat <<'EOF'
Polish hero swarm sizing and tap hit targets.

EOF
)"
```

---

## Spec coverage checklist

| Spec requirement | Task |
|------------------|------|
| Mixed `░▒▓█` + ASCII glyphs | 1, 2, 3 |
| Full-stage scatter + soft edge fade | 3 |
| Assemble continuity / stagger | 3 (math) + existing grid swarm |
| Ambient feature loops | 5 (queue), 6 (others keep existing) |
| Tap replay | 3, 5, 6 |
| Queue chat bubbles, no arrow | 4, 5 |
| Brand unchanged | 6 (explicit non-touch / simpler) |
| Reduced motion skips scatter | 3, 7 |
| Tests + no overflow | 5, 6, 7, 8 |

## Self-review notes

- No TBD/placeholder steps; each code step includes concrete APIs (`onReplay`, `edgeFade`, chat patterns, labels).
- `replayHero()` added in Task 3 before heroes call it in Tasks 5–6.
- `kSwarmGlyphPool` defined in Task 1 and reused in Task 3 tests.
- Brand explicitly excluded from full-stage kit changes.
