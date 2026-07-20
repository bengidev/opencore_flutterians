# Home Welcome Shell & Particle Orb Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a Flutter `home` welcome shell (top bar + progressive particle orb + greeting) as the post-onboarding screen, with viewport-responsive layout for home and onboarding, without frame-time spikes.

**Architecture:** New `lib/home/` module mirrors `onboarding`. The hero uses Swift-parity pre-rasterized `ui.Image` layers (`lib/home/home_orb/`) animated with transform/opacity only, revealed core→outer. `HomeWelcomeLayoutMetrics` and `OnboardingLayoutMetrics` drive sizes from viewport.

**Tech Stack:** Flutter 3 / Dart 3.12, `google_fonts`, `flutter_test`, no new packages. Source of truth for orb math: `/Users/beng/Documents/iOS Projects/opencore_swifters/OpenCore/OpenCore/Features/Home/Views/HomeParticleOrbView.swift`.

**Spec:** `docs/superpowers/specs/2026-07-20-home-welcome-orb-design.md`

## Global Constraints

- Package root for Dart code: `opencore_flutterians/` (app package name `opencore_flutterians`)
- Module path: `lib/home/`; orb under `lib/home/home_orb/` (never a bare `orb/` folder)
- Type prefix: `Home` / `HomeOrb`
- Scope: welcome shell only — no composer, bottom tabs, chat, or API
- Orb: bake bitmaps once; animate transform + opacity only; never per-particle paint each frame
- Stage-in: core first; enter from scale ~0.95 + opacity (never `scale(0)`); ease-out ~180–250ms; stagger ~40–70ms
- Emil polish: press scale ~0.97 / ~160ms ease-out on top-bar buttons; pause motion on reduce-motion / inactive
- Responsiveness: home **and** onboarding use viewport metrics; hit targets ≥ 44 logical px
- Light monochrome home theme; do not leave Material purple seed styling on `HomePage`
- Tests run from `opencore_flutterians/`: `flutter test …`
- Prefer small focused files; do not dump the entire Swift port into one 1k+ line file

## File structure

| File | Responsibility |
| --- | --- |
| `lib/home/home.dart` | Barrel exports |
| `lib/home/home_tokens.dart` | Light color / motion tokens |
| `lib/home/home_theme.dart` | `ThemeData` + `HomeThemeColors` |
| `lib/home/home_welcome_layout_metrics.dart` | Viewport → spacers / orb height / padding |
| `lib/home/home_top_bar.dart` | Menu + new-chat visual buttons |
| `lib/home/home_welcome_view.dart` | Orb + greeting block |
| `lib/home/home_page.dart` | Scaffold root |
| `lib/home/home_orb/home_orb_metrics.dart` | Canvas / field / glyph constants |
| `lib/home/home_orb/home_orb_math.dart` | Noise + gaussian |
| `lib/home/home_orb/home_orb_layout.dart` | Deterministic particle seeds |
| `lib/home/home_orb/home_orb_renderer.dart` | Bake `ui.Image`s |
| `lib/home/home_orb/home_orb_asset_pack.dart` | Pack + cache |
| `lib/home/home_orb/home_orb_stage.dart` | Stage enum / ordering |
| `lib/home/home_orb/home_orb_view.dart` | Widget + progressive animation |
| `lib/onboarding/onboarding_layout_metrics.dart` | Onboarding viewport metrics |
| `lib/main.dart` | Wire `HomePage` |
| Tests under `test/home/` and extend `test/onboarding/` | |

---

### Task 1: Home welcome layout metrics

**Files:**
- Create: `opencore_flutterians/lib/home/home_welcome_layout_metrics.dart`
- Test: `opencore_flutterians/test/home/home_welcome_layout_metrics_test.dart`

**Interfaces:**
- Produces: `HomeWelcomeLayoutMetrics.resolve(double viewportHeight)` → `HomeWelcomeLayoutMetrics` with `topSpacerMinLength`, `bottomSpacerMinLength`, `orbHeight`, `orbBottomPadding`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_welcome_layout_metrics.dart';

void main() {
  test('zero viewport uses standard defaults', () {
    final m = HomeWelcomeLayoutMetrics.resolve(0);
    expect(m.orbHeight, 260);
    expect(m.orbBottomPadding, 28);
    expect(m.topSpacerMinLength, 72);
    expect(m.bottomSpacerMinLength, 72);
  });

  test('tall viewport keeps standard orb and centers', () {
    final m = HomeWelcomeLayoutMetrics.resolve(700);
    expect(m.orbHeight, 260);
    expect(m.topSpacerMinLength, greaterThanOrEqualTo(16));
    expect(m.bottomSpacerMinLength, m.topSpacerMinLength);
  });

  test('short viewport falls back to compact orb', () {
    final m = HomeWelcomeLayoutMetrics.resolve(280);
    expect(m.orbHeight, 200);
    expect(m.orbBottomPadding, 20);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_welcome_layout_metrics_test.dart`

Expected: FAIL (library/file not found)

- [ ] **Step 3: Write minimal implementation**

Port Swift `HomeWelcomeLayoutMetrics` from `HomeWelcomeView.swift` (heroTextBlockHeight 66, minEdgeSpacing 16, standard 260/28, compact 200/20).

```dart
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
    final spacing =
        (viewportHeight - compactHero) / 2 < minEdgeSpacing
            ? minEdgeSpacing
            : (viewportHeight - compactHero) / 2;
    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: spacing,
      bottomSpacerMinLength: spacing,
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
    final spacing = (viewportHeight - heroHeight) / 2 < minEdgeSpacing
        ? minEdgeSpacing
        : (viewportHeight - heroHeight) / 2;
    return HomeWelcomeLayoutMetrics(
      topSpacerMinLength: spacing,
      bottomSpacerMinLength: spacing,
      orbHeight: orbHeight,
      orbBottomPadding: orbBottomPadding,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_welcome_layout_metrics_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_welcome_layout_metrics.dart \
  opencore_flutterians/test/home/home_welcome_layout_metrics_test.dart
git commit -m "$(cat <<'EOF'
Add home welcome layout metrics with compact fallback.

EOF
)"
```

---

### Task 2: Home tokens and theme

**Files:**
- Create: `opencore_flutterians/lib/home/home_tokens.dart`
- Create: `opencore_flutterians/lib/home/home_theme.dart`
- Test: `opencore_flutterians/test/home/home_theme_test.dart`

**Interfaces:**
- Produces: `HomeTokens.light` colors; `HomeTheme.light()`; `HomeThemeColors.of(context)`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_theme.dart';
import 'package:opencore_flutterians/home/home_tokens.dart';

void main() {
  testWidgets('HomeThemeColors exposes light surface and primary text', (tester) async {
    late HomeColorTokens colors;
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Builder(
          builder: (context) {
            colors = HomeThemeColors.of(context).colors;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors.surface, HomeTokens.light.surface);
    expect(colors.textPrimary, HomeTokens.light.textPrimary);
    expect(ThemeData.estimateBrightnessForColor(colors.surface), Brightness.light);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_theme_test.dart`

Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

`home_tokens.dart`:

```dart
import 'package:flutter/material.dart';

class HomeColorTokens {
  const HomeColorTokens({
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
}

class HomeTokens {
  static const pressScale = 0.97;
  static const durationPress = Duration(milliseconds: 160);
  static const durationStage = Duration(milliseconds: 220);
  static const stageStagger = Duration(milliseconds: 55);
  static const easeOut = Cubic(0.23, 1, 0.32, 1);
  static const easeInOut = Cubic(0.77, 0, 0.175, 1);

  static const light = HomeColorTokens(
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF666666),
    accent: Color(0xFF111111),
  );
}
```

`home_theme.dart`: Build `ThemeData` with white scaffold, Space Mono / Space Grotesk via `google_fonts` for greeting styles (`headlineMedium` monospaced ~28 semibold, `bodySmall` ~11 secondary). Provide:

```dart
class HomeThemeColors extends InheritedWidget {
  const HomeThemeColors({super.key, required this.colors, required super.child});
  final HomeColorTokens colors;
  static HomeThemeColors of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeThemeColors>()!;
  @override
  bool updateShouldNotify(HomeThemeColors old) => colors != old.colors;
}

class HomeTheme {
  static ThemeData light() { /* ThemeData + wrap usage via HomePage */ }
}
```

Also export a helper widget or document that `HomePage` wraps children in `HomeThemeColors(colors: HomeTokens.light, child: …)` and `Theme(data: HomeTheme.light(), child: …)`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_theme_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_tokens.dart \
  opencore_flutterians/lib/home/home_theme.dart \
  opencore_flutterians/test/home/home_theme_test.dart
git commit -m "$(cat <<'EOF'
Add light home tokens and theme for welcome shell.

EOF
)"
```

---

### Task 3: Top bar + welcome shell + HomePage wired

**Files:**
- Create: `opencore_flutterians/lib/home/home_top_bar.dart`
- Create: `opencore_flutterians/lib/home/home_welcome_view.dart`
- Create: `opencore_flutterians/lib/home/home_page.dart`
- Create: `opencore_flutterians/lib/home/home.dart`
- Create: `opencore_flutterians/lib/home/home_orb/home_orb_view.dart` (stub placeholder only)
- Modify: `opencore_flutterians/lib/main.dart`
- Test: `opencore_flutterians/test/home/home_page_test.dart`

**Interfaces:**
- Produces: `HomePage`, `HomeTopBar`, `HomeWelcomeView`, stub `HomeOrbView({Key? key, required double height})`
- Consumes: `HomeWelcomeLayoutMetrics`, `HomeTheme`, `HomeTokens`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('HomePage shows greeting and top bar icons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();

    expect(find.text('Hi! How can I help you?'), findsOneWidget);
    expect(find.textContaining('end-to-end encrypted'), findsOneWidget);
    expect(find.textContaining('Your data is safe'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('HomePage does not overflow on narrow phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_page_test.dart`

Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

Stub `HomeOrbView`:

```dart
class HomeOrbView extends StatelessWidget {
  const HomeOrbView({super.key, required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(height: height, width: double.infinity);
}
```

`HomeTopBar`: `SafeArea` + `Padding` horizontal from width (clamp 16–24); two `IconButton`s (menu, add) with min 44×44; wrap icons in a small press scale using `GestureDetector`/`InkWell` + `AnimatedScale` to `HomeTokens.pressScale` on tap down / up (160ms `HomeTokens.easeOut`). No real navigation.

`HomeWelcomeView`: `LayoutBuilder` → `HomeWelcomeLayoutMetrics.resolve(constraints.maxHeight)` → column with spacers, `HomeOrbView(height: layout.orbHeight)`, greeting `FittedBox`/`Text` monospaced 28 semibold, two secondary lines matching Swift copy:
- `Chats are end-to-end encrypted.`
- `Your data is safe.`

`HomePage`:

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HomeTheme.light(),
      child: HomeThemeColors(
        colors: HomeTokens.light,
        child: Scaffold(
          backgroundColor: HomeTokens.light.surface,
          body: const Column(
            children: [
              HomeTopBar(),
              Expanded(child: HomeWelcomeView()),
            ],
          ),
        ),
      ),
    );
  }
}
```

`home.dart` exports public types. In `main.dart` replace `OpenCoreHomePage` with `HomePage` and remove the unused counter page (or leave unused class deleted).

- [ ] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_page_test.dart`

Expected: PASS

Also run: `cd opencore_flutterians && flutter test`

Expected: existing onboarding tests still PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home opencore_flutterians/lib/main.dart \
  opencore_flutterians/test/home/home_page_test.dart
git commit -m "$(cat <<'EOF'
Wire home welcome shell as post-onboarding destination.

EOF
)"
```

---

### Task 4: Orb math and metrics

**Files:**
- Create: `opencore_flutterians/lib/home/home_orb/home_orb_metrics.dart`
- Create: `opencore_flutterians/lib/home/home_orb/home_orb_math.dart`
- Test: `opencore_flutterians/test/home/home_orb_math_test.dart`

**Interfaces:**
- Produces: `HomeOrbMetrics` constants; `HomeOrbMath.noise`, `HomeOrbMath.gaussian2D`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_math.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';

void main() {
  test('noise is deterministic and in 0..1', () {
    final a = HomeOrbMath.noise(12, 3);
    final b = HomeOrbMath.noise(12, 3);
    expect(a, b);
    expect(a, inInclusiveRange(0.0, 1.0));
  });

  test('metrics match Swift canvas', () {
    expect(HomeOrbMetrics.canvasSize, const Size(360, 240));
    expect(HomeOrbMetrics.glyphRamp, ['░', '▒', '▓', '█']);
  });
}
```

(Import `Size` from `dart:ui` or `package:flutter/material.dart`.)

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_orb_math_test.dart`

Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

Port `ParticleOrbMetrics` and `ParticleOrbMath` from Swift verbatim (same formulas).

```dart
class HomeOrbMetrics {
  static const canvasSize = Size(360, 240);
  static final center = Offset(canvasSize.width * 0.5, canvasSize.height * 0.5);
  static const outerField = Size(324, 204);
  static const coreField = Size(156, 146);
  static const renderScale = 2.0;
  static const snapGrid = 3.0;
  static const glyphRamp = ['░', '▒', '▓', '█'];
}

class HomeOrbMath {
  static double noise(double value, double seed) {
    final mixed = math.sin(value * 12.9898 + seed * 78.233) * 43758.5453;
    return mixed - mixed.floorToDouble();
  }

  static double gaussian2D({
    required double x,
    required double y,
    required double sigmaX,
    required double sigmaY,
  }) =>
      math.exp(-0.5 * (math.pow(x / sigmaX, 2) + math.pow(y / sigmaY, 2)));
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_orb_math_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb/home_orb_metrics.dart \
  opencore_flutterians/lib/home/home_orb/home_orb_math.dart \
  opencore_flutterians/test/home/home_orb_math_test.dart
git commit -m "$(cat <<'EOF'
Port home orb metrics and deterministic noise helpers.

EOF
)"
```

---

### Task 5: Orb layout factory

**Files:**
- Create: `opencore_flutterians/lib/home/home_orb/home_orb_layout.dart`
- Test: `opencore_flutterians/test/home/home_orb_layout_test.dart`

**Interfaces:**
- Consumes: `HomeOrbMath`, `HomeOrbMetrics`
- Produces: particle model classes + `HomeOrbLayout` static makers matching Swift counts:
  - `makeOuterDots(seedOffset, count, radiusBias)`
  - `makeOrbDust(seedOffset, count)`
  - `makePulseDots(seedOffset, count)`
  - `makeCoreBlocks(seedOffset, count, prominence)`
  - `makeSparkSeeds(seedOffset, count)`
  - `makeOuterOrbitDotSeeds(seedOffset, count)`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_layout.dart';

void main() {
  test('core blocks are deterministic and non-empty', () {
    final a = HomeOrbLayout.makeCoreBlocks(seedOffset: 2400, count: 236, prominence: 0.96);
    final b = HomeOrbLayout.makeCoreBlocks(seedOffset: 2400, count: 236, prominence: 0.96);
    expect(a.length, greaterThan(0));
    expect(a.length, b.length);
    expect(a.first.point, b.first.point);
    expect(a.first.glyph, isIn(['░', '▒', '▓', '█']));
  });

  test('outer dots respect requested count', () {
    final dots = HomeOrbLayout.makeOuterDots(seedOffset: 0, count: 138, radiusBias: 0.72);
    expect(dots, hasLength(138));
  });

  test('spark and orbit seed counts match Swift pack', () {
    expect(HomeOrbLayout.makeSparkSeeds(seedOffset: 11200, count: 28), hasLength(28));
    expect(HomeOrbLayout.makeOuterOrbitDotSeeds(seedOffset: 12800, count: 42), hasLength(42));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_orb_layout_test.dart`

Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

Port Swift `ParticleOrbLayoutFactory` and particle structs into `home_orb_layout.dart` as `HomeOrbLayout` + `HomeOrbDot` / `HomeOrbBlock` / `HomeOrbSparkSeed` / `HomeOrbOrbitDotSeed`. Keep formulas identical (including `coreDensity` and `snap`).

- [ ] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_orb_layout_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb/home_orb_layout.dart \
  opencore_flutterians/test/home/home_orb_layout_test.dart
git commit -m "$(cat <<'EOF'
Port deterministic home orb particle layout factory.

EOF
)"
```

---

### Task 6: Orb renderer and asset pack with staged bake

**Files:**
- Create: `opencore_flutterians/lib/home/home_orb/home_orb_renderer.dart`
- Create: `opencore_flutterians/lib/home/home_orb/home_orb_asset_pack.dart`
- Create: `opencore_flutterians/lib/home/home_orb/home_orb_stage.dart`
- Test: `opencore_flutterians/test/home/home_orb_asset_pack_test.dart`

**Interfaces:**
- Produces:
  - `enum HomeOrbStage { corePrimary, coreRest, mid, outer, orbit }` with ordered `values`
  - `HomeOrbColors({required Color tint, required Color accent})`
  - `HomeOrbAssetPack` holding layer images + orbit/spark descriptors
  - `HomeOrbAssetStore.bakeStage(HomeOrbStage stage, HomeOrbColors colors)` / `bakeAll` / cache by colors
  - Layer descriptors include rest opacity/scale, ranges, durations, phase, crispEdges, drift — match Swift `ParticleOrbAssetFactory.makePack` numbers

- [ ] **Step 1: Write the failing test**

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_asset_pack.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_stage.dart';
import 'package:opencore_flutterians/home/home_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final colors = HomeOrbColors(
    tint: HomeTokens.light.textPrimary,
    accent: HomeTokens.light.accent,
  );

  test('stage order starts with core', () {
    expect(HomeOrbStage.values.first, HomeOrbStage.corePrimary);
    expect(HomeOrbStage.values.last, HomeOrbStage.orbit);
  });

  test('baking corePrimary yields a non-zero image', () async {
    final slice = await HomeOrbAssetStore.bakeStage(HomeOrbStage.corePrimary, colors);
    expect(slice.layers, isNotEmpty);
    final img = slice.layers.first.image;
    expect(img.width, greaterThan(0));
    expect(img.height, greaterThan(0));
  });

  test('bakeAll caches by color', () async {
    final a = await HomeOrbAssetStore.bakeAll(colors);
    final b = await HomeOrbAssetStore.bakeAll(colors);
    expect(identical(a, b), isTrue);
    expect(a.layers.length, greaterThanOrEqualTo(7));
    expect(a.outerOrbitDots.length, 42);
    expect(a.sparks.length, 28);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_orb_asset_pack_test.dart`

Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

Renderer: use `PictureRecorder` + `Canvas` at `HomeOrbMetrics.canvasSize * devicePixelRatio` (use `HomeOrbMetrics.renderScale` floor). Draw ellipses for dots; draw monospaced glyphs for blocks/sparks (`TextPainter` with `fontFamily: 'Courier'` or `GoogleFonts.spaceMono` — prefer a bundled-safe monospace that works in tests without network; with `allowRuntimeFetching = false`, use `fontFamily: 'monospace'` / platform monospace).

`HomeOrbAssetStore`:
- Map stages to which Swift layers they include:
  - `corePrimary`: first core blocks layer (seed 2400)
  - `coreRest`: remaining two core layers
  - `mid`: pulse + dust
  - `outer`: two outer dot layers
  - `orbit`: orbit dots + sparks
- `bakeStage` can return a partial pack slice; `bakeAll` builds full pack matching Swift factory descriptors exactly (opacities, durations, drift radii from Swift lines ~496–666).
- Cache `Map<String, HomeOrbAssetPack>` keyed by tint/accent ARGB.

Dispose: document that cached images live for app lifetime; optional `clearCache()` for tests.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_orb_asset_pack_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb/home_orb_renderer.dart \
  opencore_flutterians/lib/home/home_orb/home_orb_asset_pack.dart \
  opencore_flutterians/lib/home/home_orb/home_orb_stage.dart \
  opencore_flutterians/test/home/home_orb_asset_pack_test.dart
git commit -m "$(cat <<'EOF'
Add staged home orb image bake and asset pack cache.

EOF
)"
```

---

### Task 7: HomeOrbView progressive reveal + motion

**Files:**
- Replace stub: `opencore_flutterians/lib/home/home_orb/home_orb_view.dart`
- Test: `opencore_flutterians/test/home/home_orb_view_test.dart`
- Modify: ensure `home.dart` exports `HomeOrbView`

**Interfaces:**
- Consumes: `HomeOrbAssetStore`, `HomeOrbStage`, `HomeTokens`, `HomeThemeColors`
- Produces: `HomeOrbView({Key? key, required double height})` — StatefulWidget

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_view.dart';
import 'package:opencore_flutterians/home/home_theme.dart';
import 'package:opencore_flutterians/home/home_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('HomeOrbView mounts and completes staged bake without throwing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: HomeThemeColors(
          colors: HomeTokens.light,
          child: const Scaffold(
            body: Center(child: HomeOrbView(height: 260)),
          ),
        ),
      ),
    );

    await tester.pump();
    // Allow progressive stages to complete.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
    expect(find.byType(HomeOrbView), findsOneWidget);
  });

  testWidgets('reduce motion still shows orb without continuous controllers crashing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        theme: HomeTheme.light(),
        home: HomeThemeColors(
          colors: HomeTokens.light,
          child: const Scaffold(body: HomeOrbView(height: 200)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_orb_view_test.dart`

Expected: FAIL (stub has no bake / or incomplete)

- [ ] **Step 3: Write minimal implementation**

`HomeOrbView` state machine:

1. On init / color change: start baking stages in order (`corePrimary` first on microtask; subsequent stages after previous completes — prefer `compute`/`Isolate.run` for heavy canvas work if UI janks; otherwise async chunking is acceptable if stages remain progressive).
2. As each stage’s images arrive, insert corresponding `RawImage`/`CustomPaint` layer widgets into a `Stack`, wrapping each new stage in `TweenAnimationBuilder` or `AnimationController` that animates opacity 0→rest and scale 0.95→restScale with `HomeTokens.easeOut` / `durationStage`, staggered by `stageStagger`.
3. After `HomeOrbStage.orbit` is visible, start a looping master `AnimationController` (duration ~20s or multiple controllers) that drives drift/orbit/opacity/scale using the descriptor keyframes (sample positions from descriptor orbit/drift point functions). **Only** apply `Transform.translate` / `Transform.rotate` / `Transform.scale` / `Opacity` on pre-baked images.
4. If `MediaQuery.disableAnimations` or `TickerMode` off: skip looping controllers; still show baked layers (snap or opacity-only stage-in).
5. Aspect: child sized to `height` with width `height * (360/240)` capped by parent; center in box.
6. Bake failure: show a small dark circle placeholder; `debugPrint` error.

Do **not** CustomPaint individual particles each frame.

- [ ] **Step 4: Run tests**

Run:

```bash
cd opencore_flutterians && flutter test test/home/home_orb_view_test.dart test/home/home_page_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb/home_orb_view.dart \
  opencore_flutterians/test/home/home_orb_view_test.dart
git commit -m "$(cat <<'EOF'
Animate home orb with progressive core-to-outer reveal.

EOF
)"
```

---

### Task 8: Onboarding layout metrics + apply responsiveness

**Files:**
- Create: `opencore_flutterians/lib/onboarding/onboarding_layout_metrics.dart`
- Modify: `opencore_flutterians/lib/onboarding/heroes/shared/onboarding_hero_frame.dart`
- Modify: `opencore_flutterians/lib/onboarding/widgets/onboarding_page_shell.dart`
- Modify: `opencore_flutterians/lib/onboarding/heroes/brand_hero.dart` (and any hero with hard-coded 300/280 that overflows — at minimum frame + brand)
- Modify: `opencore_flutterians/lib/onboarding/onboarding_entry.dart` if it needs a top-level `LayoutBuilder` to pass metrics
- Test: `opencore_flutterians/test/onboarding/onboarding_layout_metrics_test.dart`
- Test: extend or add `opencore_flutterians/test/onboarding/onboarding_responsive_test.dart`

**Interfaces:**
- Produces: `OnboardingLayoutMetrics.resolve({required double width, required double height})` with fields such as `heroFrameHeight`, `heroFrameMaxWidth`, `pageHorizontalPadding`, `sectionGap`, `brandHeroSize`

Suggested breakpoints (shortest side / height):

| Tier | When | heroFrameHeight | brandHeroSize | pageHorizontalPadding |
| --- | --- | --- | --- | --- |
| compact | height < 700 or width < 360 | 220 | 240 | 16 |
| standard | default | 280 | 300 | 24 |
| roomy | height >= 900 && width >= 400 | 320 | 320 | 28 |

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_layout_metrics.dart';

void main() {
  test('compact on short viewport', () {
    final m = OnboardingLayoutMetrics.resolve(width: 320, height: 568);
    expect(m.heroFrameHeight, 220);
    expect(m.pageHorizontalPadding, 16);
  });

  test('standard on common phone', () {
    final m = OnboardingLayoutMetrics.resolve(width: 390, height: 844);
    expect(m.heroFrameHeight, 280);
    expect(m.pageHorizontalPadding, 24);
  });
}
```

Responsive widget test: pump `OnboardingEntry` at `Size(320, 568)` with `disableAnimations: true` and assert `tester.takeException() == null` and `ENTER`/`SKIP` still findable after skip path (reuse patterns from `onboarding_entry_test.dart`).

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/onboarding/onboarding_layout_metrics_test.dart`

Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

Implement metrics. Update `OnboardingHeroFrame` to read metrics via `LayoutBuilder` or inherited `OnboardingLayoutScope`. Update `OnboardingPageShell` padding/gaps from metrics. Update `BrandHero` outer `SizedBox` to `metrics.brandHeroSize`. Keep motion tokens unchanged.

Provide:

```dart
class OnboardingLayoutScope extends InheritedWidget {
  const OnboardingLayoutScope({super.key, required this.metrics, required super.child});
  final OnboardingLayoutMetrics metrics;
  static OnboardingLayoutMetrics of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnboardingLayoutScope>()!.metrics;
  @override
  bool updateShouldNotify(OnboardingLayoutScope old) => metrics != old.metrics;
}
```

Wrap onboarding pages once in `onboarding_entry.dart` with `LayoutBuilder` → `OnboardingLayoutScope`.

- [ ] **Step 4: Run tests**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/
```

Expected: PASS (including prior onboarding tests)

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding opencore_flutterians/test/onboarding
git commit -m "$(cat <<'EOF'
Make onboarding chrome and heroes viewport-responsive.

EOF
)"
```

---

### Task 9: Full verification + polish pass

**Files:**
- Possibly tweak: `home_orb_view.dart`, `home_welcome_view.dart`, `home_top_bar.dart` for Emil polish only (press scale, greeting fade after core)
- Test: ensure suite green

- [ ] **Step 1: Add greeting reveal smoke assertion (optional small test)**

In `home_page_test.dart`, after pumps, greeting remains visible (already covered). Manually verify press scale exists on top bar via `AnimatedScale` finder if implemented with a key `ValueKey('home-top-bar-menu')`.

- [ ] **Step 2: Run full suite**

```bash
cd opencore_flutterians && flutter test
```

Expected: All PASS

- [ ] **Step 3: Analyze**

```bash
cd opencore_flutterians && dart analyze lib/home lib/onboarding lib/main.dart
```

Expected: No issues

- [ ] **Step 4: Commit only if polish edits were needed**

```bash
git add -u opencore_flutterians/lib/home opencore_flutterians/test/home
git commit -m "$(cat <<'EOF'
Polish home welcome motion and verify suite.

EOF
)"
```

---

## Spec coverage checklist

| Spec requirement | Task |
| --- | --- |
| Welcome shell (top bar, orb, greeting) | 3, 7 |
| Wire as post-onboarding home | 3 |
| Pre-rasterized layered orb | 5–7 |
| Progressive core→outer reveal | 6–7 |
| `home_orb/` naming + `Home` prefix | all home tasks |
| Transform/opacity-only animation | 7 |
| Emil polish (scale 0.95 enter, ease-out, press 0.97) | 2–3, 7, 9 |
| Home viewport metrics | 1, 3 |
| Onboarding viewport metrics | 8 |
| Light monochrome theme | 2–3 |
| Reduce-motion / pause | 7 |
| Tests narrow + large | 3, 8, 9 |
| No composer/tabs/API | honored by non-goals / no tasks |

## Plan self-review notes

- No TBD placeholders left in task steps.
- `HomeOrbView(height:)` signature consistent across Tasks 3 and 7.
- Asset stage enum names (`corePrimary`…`orbit`) consistent across Tasks 6–7.
- Onboarding metrics field names introduced in Task 8 and used in the same task’s widget updates.
