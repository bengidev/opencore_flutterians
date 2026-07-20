# Home Welcome GUI + Particle Orb Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a Flutter `home` module that visually replicates the OpenCore Swifters home welcome GUI, with a near-exact bake-to-layers particle orb (`home_orb_*`) and a sticky bottom tab shell wired as the post-onboarding root.

**Architecture:** UI-only `lib/home/` module. Particles are baked once into 7 `ui.Image` layers plus orbit/spark sprites, then animated with transform/opacity only. Shell uses lightweight local state. `HomeFacade.buildRoot()` replaces the placeholder counter page after onboarding.

**Tech Stack:** Flutter 3 / Dart 3.12, `google_fonts` (Space Mono / monospace greeting), existing `OnboardingFacade` wiring, `flutter_test`.

## Global Constraints

- Package root: `opencore_flutterians/` (all `lib/` and `test/` paths below are relative to this).
- Orb files must use `home_orb_*` prefix under `lib/home/home_orb/`.
- Bottom nav is a **sticky** tab bar (pinned; content inset above it).
- Do **not** redraw ~1,100 particles every frame; bake-then-animate only.
- Orb tint `#141414`, accent `#2B2B2B` (Swift light palette).
- Shell press feedback: scale `0.97`, 140–160ms ease-out; tab morph ≤220ms ease-out; no bounce.
- UI-only: no chat/API/model catalog.
- Tests: `GoogleFonts.config.allowRuntimeFetching = false` in `setUpAll`.
- Prefer `MediaQuery.disableAnimations: true` in widget tests that host the orb.
- Commit after each task.

## File map

| Path | Responsibility |
| --- | --- |
| `lib/home/home.dart` | Public exports |
| `lib/home/home_facade.dart` | `buildRoot()` → tab shell |
| `lib/home/home_tokens.dart` | Radii, durations, curves, copy strings |
| `lib/home/home_theme.dart` | Grayscale palette + `ThemeExtension` |
| `lib/home/views/home_tab_shell.dart` | Sticky bottom tabs + page host |
| `lib/home/views/home_view.dart` | Top bar + welcome + composer + rail |
| `lib/home/views/home_welcome_view.dart` | Orb host + greeting + encryption copy |
| `lib/home/views/home_composer_view.dart` | Prompt card chrome |
| `lib/home/views/home_model_rail.dart` | Model / Max / context chips |
| `lib/home/views/home_placeholder_page.dart` | Settings & About stubs |
| `lib/home/views/home_pressable.dart` | Shared scale-0.97 press wrapper |
| `lib/home/home_orb/home_orb_math.dart` | Deterministic noise + gaussian |
| `lib/home/home_orb/home_orb_metrics.dart` | Canvas metrics + glyph ramp |
| `lib/home/home_orb/home_orb_layout.dart` | Particle/seed factories |
| `lib/home/home_orb/home_orb_layer_pack.dart` | Layer/orbit/spark descriptors + pack |
| `lib/home/home_orb/home_orb_baker.dart` | Bake pack → images (isolate-friendly) |
| `lib/home/home_orb/home_orb_animator.dart` | Controllers + sample functions |
| `lib/home/home_orb/home_orb_view.dart` | Layered animated orb widget |
| `lib/main.dart` | Wire `HomeFacade` as onboarding home |
| `test/home/...` | Matching tests |

---

### Task 1: Home theme, tokens, facade scaffold

**Files:**
- Create: `lib/home/home_tokens.dart`
- Create: `lib/home/home_theme.dart`
- Create: `lib/home/home_facade.dart`
- Create: `lib/home/home.dart`
- Create: `lib/home/views/home_placeholder_page.dart`
- Create: `lib/home/views/home_tab_shell.dart` (minimal stub: single child for now)
- Test: `test/home/home_facade_test.dart`

**Interfaces:**
- Produces: `HomeFacade.buildRoot() → Widget`
- Produces: `HomeTokens`, `HomeColors`, `HomeTheme`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HomeFacade.buildRoot shows sticky tab labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeFacade().buildRoot()),
    );
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_facade_test.dart`

Expected: FAIL — `home.dart` / `HomeFacade` not found.

- [ ] **Step 3: Implement tokens, theme, placeholder, minimal shell, facade**

`lib/home/home_tokens.dart`:

```dart
import 'package:flutter/material.dart';

class HomeTokens {
  static const radiusPill = 999.0;
  static const radiusComposer = 28.0;
  static const radiusTabBar = 28.0;
  static const radiusTabActive = 16.0;

  static const durationPress = Duration(milliseconds: 150);
  static const durationTab = Duration(milliseconds: 200);
  static const durationUi = Duration(milliseconds: 220);

  static const easeOut = Cubic(0.23, 1, 0.32, 1);
  static const easeInOut = Cubic(0.77, 0, 0.175, 1);

  static const pressScale = 0.97;

  static const greeting = 'Hi! How can I help you?';
  static const encryptionLine1 = 'Chats are end-to-end encrypted.';
  static const encryptionLine2 = 'Your data is safe.';
  static const composerHint = 'Ask anything... @files, \$skills, /commands';
  static const modelTitle = 'Google: Gemma 4 26B A4B';
  static const speedTitle = 'Max';
  static const contextLabel = '0';

  static const orbTint = Color(0xFF141414);
  static const orbAccent = Color(0xFF2B2B2B);
}
```

Fix import: use `package:flutter/material.dart` instead of animation-only so `Color` resolves.

`lib/home/home_theme.dart`:

```dart
import 'package:flutter/material.dart';

@immutable
class HomeColors extends ThemeExtension<HomeColors> {
  const HomeColors({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.tabActiveFill,
    required this.orbTint,
    required this.orbAccent,
  });

  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color tabActiveFill;
  final Color orbTint;
  final Color orbAccent;

  static const light = HomeColors(
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF7F7F7),
    surfaceMuted: Color(0xFFEEEEEE),
    textPrimary: Color(0xFF141414),
    textSecondary: Color(0xFF6B6B6B),
    textTertiary: Color(0xFF9A9A9A),
    border: Color(0xFFE6E6E6),
    tabActiveFill: Color(0xFFE8E8E8),
    orbTint: Color(0xFF141414),
    orbAccent: Color(0xFF2B2B2B),
  );

  static HomeColors of(BuildContext context) =>
      Theme.of(context).extension<HomeColors>() ?? light;

  @override
  HomeColors copyWith({
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? tabActiveFill,
    Color? orbTint,
    Color? orbAccent,
  }) {
    return HomeColors(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      tabActiveFill: tabActiveFill ?? this.tabActiveFill,
      orbTint: orbTint ?? this.orbTint,
      orbAccent: orbAccent ?? this.orbAccent,
    );
  }

  @override
  HomeColors lerp(ThemeExtension<HomeColors>? other, double t) {
    if (other is! HomeColors) return this;
    return HomeColors(
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      tabActiveFill: Color.lerp(tabActiveFill, other.tabActiveFill, t)!,
      orbTint: Color.lerp(orbTint, other.orbTint, t)!,
      orbAccent: Color.lerp(orbAccent, other.orbAccent, t)!,
    );
  }
}

class HomeTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: HomeColors.light.surfaceBase,
      extensions: const [HomeColors.light],
    );
  }
}
```

`lib/home/views/home_placeholder_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../home_theme.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    return Center(
      child: Text(
        title,
        style: TextStyle(color: colors.textSecondary, fontSize: 16),
      ),
    );
  }
}
```

`lib/home/views/home_tab_shell.dart` (minimal — full sticky chrome in Task 2):

```dart
import 'package:flutter/material.dart';
import '../home_theme.dart';
import 'home_placeholder_page.dart';

class HomeTabShell extends StatefulWidget {
  const HomeTabShell({super.key});

  @override
  State<HomeTabShell> createState() => _HomeTabShellState();
}

class _HomeTabShellState extends State<HomeTabShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final pages = const [
      ColoredBox(color: Colors.white, child: SizedBox.expand()),
      HomePlaceholderPage(title: 'Settings'),
      HomePlaceholderPage(title: 'About'),
    ];

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => setState(() => _index = 0),
              child: const Text('Home'),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 1),
              child: const Text('Settings'),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 2),
              child: const Text('About'),
            ),
          ],
        ),
      ),
    );
  }
}
```

`lib/home/home_facade.dart`:

```dart
import 'package:flutter/material.dart';
import 'home_theme.dart';
import 'views/home_tab_shell.dart';

class HomeFacade {
  Widget buildRoot() {
    return Theme(
      data: HomeTheme.light(),
      child: const HomeTabShell(),
    );
  }
}
```

`lib/home/home.dart`:

```dart
export 'home_facade.dart';
export 'home_theme.dart';
export 'home_tokens.dart';
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_facade_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home opencore_flutterians/test/home/home_facade_test.dart
git commit -m "$(cat <<'EOF'
Add home module scaffold with facade and theme.

EOF
)"
```

---

### Task 2: Sticky bottom tab bar polish

**Files:**
- Modify: `lib/home/views/home_tab_shell.dart`
- Create: `lib/home/views/home_pressable.dart`
- Test: `test/home/home_tab_shell_test.dart`

**Interfaces:**
- Consumes: `HomeColors`, `HomeTokens`
- Produces: sticky pill tab bar; `IndexedStack` keeps pages alive (orb cache later)

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_tab_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('tapping Settings shows placeholder and keeps bar pinned',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('Settings'), findsWidgets);
    expect(find.byType(HomeTabShell), findsOneWidget);
    // Placeholder title appears in body
    expect(find.text('Settings'), findsAtLeastNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails / tighten assertion**

Run: `cd opencore_flutterians && flutter test test/home/home_tab_shell_test.dart`

If the minimal shell already passes, proceed to replace chrome and keep the test green with a key assertion:

Add `Key('homeStickyTabBar')` on the sticky bar container and assert `find.byKey(const Key('homeStickyTabBar'))`.

- [ ] **Step 3: Implement pressable + sticky pill bar**

`lib/home/views/home_pressable.dart`:

```dart
import 'package:flutter/material.dart';
import '../home_tokens.dart';

class HomePressable extends StatefulWidget {
  const HomePressable({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<HomePressable> createState() => _HomePressableState();
}

class _HomePressableState extends State<HomePressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? HomeTokens.pressScale : 1,
        duration: HomeTokens.durationPress,
        curve: HomeTokens.easeOut,
        child: widget.child,
      ),
    );
  }
}
```

Rewrite `home_tab_shell.dart` bottom bar as a pinned `SafeArea` + rounded container (`Key('homeStickyTabBar')`), three items with icon+label, active fill `tabActiveFill`, `AnimatedContainer` ≤200ms `easeOut`. Keep `IndexedStack`. Body pages stay stubs until Task 3.

Icons: `Icons.home_outlined` / `Icons.settings_outlined` / `Icons.info_outline`.

- [ ] **Step 4: Run tests**

Run: `cd opencore_flutterians && flutter test test/home/home_tab_shell_test.dart test/home/home_facade_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/views/home_tab_shell.dart \
  opencore_flutterians/lib/home/views/home_pressable.dart \
  opencore_flutterians/test/home/home_tab_shell_test.dart
git commit -m "$(cat <<'EOF'
Polish sticky home tab bar with press feedback.

EOF
)"
```

---

### Task 3: Home view chrome (top bar + welcome copy, orb placeholder)

**Files:**
- Create: `lib/home/views/home_view.dart`
- Create: `lib/home/views/home_welcome_view.dart`
- Create: `lib/home/views/home_welcome_layout.dart`
- Modify: `lib/home/views/home_tab_shell.dart` (Home tab → `HomeView`)
- Modify: `lib/home/home.dart` (export views if needed)
- Test: `test/home/home_welcome_view_test.dart`

**Interfaces:**
- Produces: `HomeWelcomeLayoutMetrics.resolve(viewportHeight) → {topSpacer, bottomSpacer, orbHeight, orbBottomPadding}`
- Produces: greeting + encryption copy visible

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('home welcome shows greeting and encryption copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView()),
      ),
    );
    await tester.pump();

    expect(find.text(HomeTokens.greeting), findsOneWidget);
    expect(find.text(HomeTokens.encryptionLine1), findsOneWidget);
    expect(find.text(HomeTokens.encryptionLine2), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test — expect FAIL**

Run: `cd opencore_flutterians && flutter test test/home/home_welcome_view_test.dart`

- [ ] **Step 3: Implement layout metrics + welcome + home view**

`lib/home/views/home_welcome_layout.dart` — port Swift metrics:

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
```

`home_welcome_view.dart`: `LayoutBuilder` → metrics → `Column` with spacers, `SizedBox(height: orbHeight)` placeholder (`ColoredBox` or empty `SizedBox` with `Key('homeOrbSlot')`), greeting (GoogleFonts spaceMono / monospaced, 28 semibold), encryption lines.

`home_view.dart`: white scaffold body `Column`: top bar (`Icons.menu` / `Icons.add` via `HomePressable`), `Expanded(child: HomeWelcomeView())`. Composer/rail come in Task 4 — leave bottom empty for now **or** include empty `SizedBox` reserved area.

Update tab shell Home page to `const HomeView()`.

- [ ] **Step 4: Run tests — expect PASS**

Run: `cd opencore_flutterians && flutter test test/home/home_welcome_view_test.dart test/home/home_facade_test.dart`

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/views opencore_flutterians/test/home/home_welcome_view_test.dart
git commit -m "$(cat <<'EOF'
Add home welcome chrome with greeting copy.

EOF
)"
```

---

### Task 4: Composer + model rail

**Files:**
- Create: `lib/home/views/home_composer_view.dart`
- Create: `lib/home/views/home_model_rail.dart`
- Modify: `lib/home/views/home_view.dart`
- Test: `test/home/home_composer_test.dart`

**Interfaces:**
- Produces: visual composer + model/Max/0 chips; local `TextEditingController` only

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('composer and model rail render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView()),
      ),
    );
    await tester.pump();

    expect(find.text(HomeTokens.composerHint), findsOneWidget);
    expect(find.textContaining('Gemma'), findsOneWidget);
    expect(find.text(HomeTokens.speedTitle), findsOneWidget);
    expect(find.text(HomeTokens.contextLabel), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement composer + rail; attach under welcome in `HomeView`**

Layout for `HomeView` body:

```dart
Column(
  children: [
    topBar,
    Expanded(child: HomeWelcomeView()),
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          HomeComposerView(controller: _draft),
          const SizedBox(height: 10),
          const HomeModelRail(),
        ],
      ),
    ),
  ],
)
```

Composer: rounded container (`HomeTokens.radiusComposer`), `TextField` with hint, bottom row `+` / mic / send circle. All actions no-op. Use `HomePressable` on icon buttons.

Model rail: `Row` with expanded model chip, Max chip, circular `0`.

- [ ] **Step 4: Run tests — PASS**

Run: `cd opencore_flutterians && flutter test test/home/home_composer_test.dart`

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/views/home_composer_view.dart \
  opencore_flutterians/lib/home/views/home_model_rail.dart \
  opencore_flutterians/lib/home/views/home_view.dart \
  opencore_flutterians/test/home/home_composer_test.dart
git commit -m "$(cat <<'EOF'
Add home composer chrome and model rail.

EOF
)"
```

---

### Task 5: `home_orb` math

**Files:**
- Create: `lib/home/home_orb/home_orb_math.dart`
- Test: `test/home/home_orb/home_orb_math_test.dart`

**Interfaces:**
- Produces: `HomeOrbMath.noise(double value, double seed) → double` in `[0,1)`
- Produces: `HomeOrbMath.gaussian2D({x,y,sigmaX,sigmaY}) → double`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_math.dart';

void main() {
  test('noise is deterministic and in unit range', () {
    final a = HomeOrbMath.noise(12, 3);
    final b = HomeOrbMath.noise(12, 3);
    expect(a, b);
    expect(a, greaterThanOrEqualTo(0));
    expect(a, lessThan(1));
  });

  test('gaussian2D peaks at origin', () {
    final peak = HomeOrbMath.gaussian2D(x: 0, y: 0, sigmaX: 0.3, sigmaY: 0.3);
    final side = HomeOrbMath.gaussian2D(x: 1, y: 1, sigmaX: 0.3, sigmaY: 0.3);
    expect(peak, greaterThan(side));
    expect(peak, closeTo(1.0, 1e-9));
  });
}
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement**

```dart
import 'dart:math' as math;

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
  }) {
    return math.exp(-0.5 * (math.pow(x / sigmaX, 2) + math.pow(y / sigmaY, 2)));
  }
}
```

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb/home_orb_math.dart \
  opencore_flutterians/test/home/home_orb/home_orb_math_test.dart
git commit -m "$(cat <<'EOF'
Add home_orb deterministic math helpers.

EOF
)"
```

---

### Task 6: `home_orb` metrics + layout factories

**Files:**
- Create: `lib/home/home_orb/home_orb_metrics.dart`
- Create: `lib/home/home_orb/home_orb_layout.dart`
- Test: `test/home/home_orb/home_orb_layout_test.dart`

**Interfaces:**
- Produces particle model types: `HomeOrbDot`, `HomeOrbBlock`, `HomeOrbOrbitDotSeed`, `HomeOrbSparkSeed`
- Produces layout factories matching Swift counts

Port layout methods **verbatim** from Swift `ParticleOrbLayoutFactory` (already captured in brainstorming / `/tmp/HomeParticleOrbView.swift`). Include `coreDensity` and `snap`.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_layout.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';

void main() {
  test('layout factories return Swift particle counts', () {
    expect(HomeOrbLayout.makeOuterDots(seedOffset: 0, count: 138, radiusBias: 0.72), hasLength(138));
    expect(HomeOrbLayout.makeOuterDots(seedOffset: 1200, count: 126, radiusBias: 0.66), hasLength(126));
    expect(HomeOrbLayout.makePulseDots(seedOffset: 1800, count: 86), hasLength(86));
    expect(HomeOrbLayout.makeOrbDust(seedOffset: 9600, count: 132), hasLength(132));
    expect(HomeOrbLayout.makeCoreBlocks(seedOffset: 2400, count: 236, prominence: 0.96), hasLength(236));
    expect(HomeOrbLayout.makeCoreBlocks(seedOffset: 4800, count: 220, prominence: 0.78), hasLength(220));
    expect(HomeOrbLayout.makeCoreBlocks(seedOffset: 7200, count: 158, prominence: 0.58), hasLength(158));
    expect(HomeOrbLayout.makeOuterOrbitDotSeeds(seedOffset: 12800, count: 42), hasLength(42));
    expect(HomeOrbLayout.makeSparkSeeds(seedOffset: 11200, count: 28), hasLength(28));
  });

  test('metrics match Swift canvas', () {
    expect(HomeOrbMetrics.canvasSize, const Size(360, 240));
    expect(HomeOrbMetrics.glyphRamp, ['░', '▒', '▓', '█']);
  });
}
```

Add `import 'package:flutter/material.dart';` for `Size`.

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement metrics + full layout port**

`home_orb_metrics.dart`:

```dart
import 'dart:ui';

class HomeOrbMetrics {
  static const canvasSize = Size(360, 240);
  static const center = Offset(180, 120);
  static const outerField = Size(324, 204);
  static const coreField = Size(156, 146);
  static const renderScale = 2.0;
  static const snapGrid = 3.0;
  static const glyphRamp = ['░', '▒', '▓', '█'];
}
```

Implement `home_orb_layout.dart` by translating the Swift factory methods line-for-line (use `Offset` instead of `CGPoint`, `double` throughout). Put seed/dot/block classes in the same file or in `home_orb_layer_pack.dart` if preferred — keep types accessible to baker.

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb \
  opencore_flutterians/test/home/home_orb/home_orb_layout_test.dart
git commit -m "$(cat <<'EOF'
Port home_orb particle layout factories from Swift.

EOF
)"
```

---

### Task 7: Layer pack + baker

**Files:**
- Create: `lib/home/home_orb/home_orb_layer_pack.dart`
- Create: `lib/home/home_orb/home_orb_baker.dart`
- Test: `test/home/home_orb/home_orb_baker_test.dart`

**Interfaces:**
- Produces: `HomeOrbLayerPack` with `layers` (7), `outerOrbitDots` (42), `sparks` (28)
- Produces: `Future<HomeOrbLayerPack> HomeOrbBaker.bake({required Color tint, required Color accent})`
- Layer descriptor fields match Swift table (opacity/scale/rotation/drift + `ui.Image image`)

**Optimization:** bake pixel buffers with `PictureRecorder` at `canvasSize * devicePixelRatio` (use `2.0` min like Swift `renderScale`). Cache:

```dart
class HomeOrbBakeCache {
  static HomeOrbLayerPack? _pack;
  static int? _key;
  static Future<HomeOrbLayerPack> obtain({required Color tint, required Color accent}) async {
    final key = Object.hash(tint.toARGB32(), accent.toARGB32());
    if (_pack != null && _key == key) return _pack!;
    final pack = await HomeOrbBaker.bake(tint: tint, accent: accent);
    _pack = pack;
    _key = key;
    return pack;
  }

  @visibleForTesting
  static void clear() {
    _pack = null;
    _key = null;
  }
}
```

If `toARGB32` unavailable on SDK, use `tint.value`.

Seven layer specs (exact):

1. outer 138 — tint — op 0.36±0.05/6.8 — scale 1±0.018/8.4 — rot 0.09/21 — phase 0 — drift 5/0.72/16  
2. outer 126 — tint — 0.28±0.05/7.6 — 0.98±0.022/9.2 — 0.07/17.5 — 1.9 — 7/0.56/19  
3. pulse 86 — tint — 0.20±0.10/5.2 — 0.78±0.12/5.8 — 0.04/13 — 0.4 — 2/0.70/11  
4. core 236 p0.96 — accent — 0.78±0.10/5.8 — 1±0.028/6.6 — 0.10/12 — 0.8 — crisp — 4/0.74/8.5  
5. core 220 p0.78 — accent — 0.52±0.09/6.4 — 1.02±0.024/6.1 — 0.14/9.8 — 2.2 — crisp — 5/0.68/7.8  
6. core 158 p0.58 — accent — 0.30±0.06/6.4 — 1.04±0.018/6.1 — 0.18/7.4 — 3.1 — crisp — 6/0.64/6.9  
7. dust 132 — tint — 0.30±0.08/4.4 — 1.01±0.032/5.6 — 0.12/10.6 — 1.5 — 8/0.62/12.4  

- [ ] **Step 1: Write the failing test**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_baker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(HomeOrbBakeCache.clear);

  test('bake produces 7 layers, 42 orbit dots, 28 sparks', () async {
    final pack = await HomeOrbBaker.bake(
      tint: const Color(0xFF141414),
      accent: const Color(0xFF2B2B2B),
    );
    expect(pack.layers, hasLength(7));
    expect(pack.outerOrbitDots, hasLength(42));
    expect(pack.sparks, hasLength(28));
    for (final layer in pack.layers) {
      expect(layer.image.width, greaterThan(0));
      expect(layer.image.height, greaterThan(0));
    }
  });
}
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement baker**

Bake helpers:

- `renderDots` — fill circles  
- `renderBlocks` — draw glyph strings with monospace `ParagraphBuilder` / `TextPainter`  
- `renderOrbitDot` — 10×10 soft circle  
- `renderSpark` — 18×18 glyph  

Dispose images only when replacing cache.

Prefer baking on the main isolate first for correctness in tests; wrap heavy work in `compute` only if isolate transfer of `ui.Image` is awkward — acceptable optimization path: generate particle lists in isolate, rasterize on UI isolate. Document chosen approach in code comment.

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb \
  opencore_flutterians/test/home/home_orb/home_orb_baker_test.dart
git commit -m "$(cat <<'EOF'
Add home_orb layer bake pipeline and cache.

EOF
)"
```

---

### Task 8: `home_orb` animator + view

**Files:**
- Create: `lib/home/home_orb/home_orb_animator.dart`
- Create: `lib/home/home_orb/home_orb_view.dart`
- Test: `test/home/home_orb/home_orb_view_test.dart`

**Interfaces:**
- Produces: `HomeOrbView({bool animate})` widget
- Animator samples drift/orbit/opacity/scale given `elapsed` + descriptor (pure functions preferred for testability)

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_view.dart';
import 'package:opencore_flutterians/home/home_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('orb builds and respects reduce motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(
          body: SizedBox(height: 260, child: HomeOrbView()),
        ),
      ),
    );
    await tester.pump();
    // Allow bake future
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.byType(HomeOrbView), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement animator + view**

`HomeOrbView` responsibilities:

1. Read tint/accent from `HomeColors.of(context)`  
2. `HomeOrbBakeCache.obtain` in `initState` / didChangeDependencies  
3. While loading: empty `SizedBox`  
4. When ready: `RepaintBoundary` → `Stack` of 7 `RawImage` layers + orbit dots + sparks  
5. Single `AnimationController(duration: ~20s)..repeat()` driving rebuilds **only inside** the orb subtree  
6. If `MediaQuery.disableAnimations` or `widget.active == false`: freeze at rest poses  
7. `WidgetsBindingObserver` → pause when app not resumed  
8. Fit canvas 360×240 into parent with `FittedBox` / manual scale like Swift `min(xScale,yScale)`

Animate using elapsed seconds from controller; implement Swift keyframe curves for opacity/scale (values at 0, 0.26–0.28, 0.52–0.56, 0.78–0.80, 1.0) and paced elliptical drift/orbit.

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/home_orb \
  opencore_flutterians/test/home/home_orb/home_orb_view_test.dart
git commit -m "$(cat <<'EOF'
Add animated home_orb view with reduce-motion pause.

EOF
)"
```

---

### Task 9: Integrate orb into welcome + tab visibility

**Files:**
- Modify: `lib/home/views/home_welcome_view.dart`
- Modify: `lib/home/views/home_tab_shell.dart` (pass `active` / pause orb off-tab)
- Test: `test/home/home_welcome_view_test.dart` (extend)

**Interfaces:**
- `HomeOrbView(active: homeTabSelected && appResumed)`

- [ ] **Step 1: Extend welcome test**

```dart
expect(find.byKey(const Key('homeOrbSlot')), findsOneWidget);
// after integration, slot contains HomeOrbView:
expect(find.byType(HomeOrbView), findsOneWidget);
```

Import `home_orb_view.dart`. Disable animations in harness.

- [ ] **Step 2: Run — FAIL on `HomeOrbView` until wired**

- [ ] **Step 3: Replace placeholder with `HomeOrbView`; keep bake cache across tab switches via `IndexedStack` + `active` flag**

In tab shell:

```dart
HomeView(orbActive: _index == 0),
```

Thread `orbActive` to welcome → orb.

- [ ] **Step 4: Run home widget tests — PASS**

Run: `cd opencore_flutterians && flutter test test/home`

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home opencore_flutterians/test/home
git commit -m "$(cat <<'EOF'
Integrate home_orb into welcome and pause off-tab.

EOF
)"
```

---

### Task 10: Wire post-onboarding root + smoke

**Files:**
- Modify: `lib/main.dart`
- Delete: unused `OpenCoreHomePage` counter if fully replaced
- Test: `test/home/home_bootstrap_smoke_test.dart`

**Interfaces:**
- `OnboardingFacade().buildRoot(home: HomeFacade().buildRoot())`

- [ ] **Step 1: Write smoke test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/onboarding/onboarding.dart';

import '../helpers/hydrated_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(setUpHydratedStorage);

  testWidgets('completed onboarding shows home shell', (tester) async {
    final store = _DoneStore();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: OnboardingFacade(store: store).buildRoot(
          home: HomeFacade().buildRoot(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.greeting), findsOneWidget);
    expect(find.byKey(const Key('homeStickyTabBar')), findsOneWidget);
  });
}

class _DoneStore implements OnboardingCompletionStore {
  @override
  Future<bool> hasCompleted() async => true;
  @override
  Future<void> markCompleted() async {}
}
```

If `OnboardingFacade` constructor / store API differs, match `onboarding_facade.dart` exactly.

- [ ] **Step 2: Run — FAIL until main wiring exists (smoke can pass before main if it constructs facade directly); still update main**

- [ ] **Step 3: Update `main.dart`**

```dart
import 'package:opencore_flutterians/home/home.dart';
// ...
home: OnboardingFacade().buildRoot(
  home: HomeFacade().buildRoot(),
),
```

Remove `OpenCoreHomePage` class from `main.dart`.

- [ ] **Step 4: Run full relevant suite**

Run:

```bash
cd opencore_flutterians && flutter test test/home test/onboarding
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/main.dart \
  opencore_flutterians/test/home/home_bootstrap_smoke_test.dart
git commit -m "$(cat <<'EOF'
Wire home facade as post-onboarding root.

EOF
)"
```

---

## Self-review (plan vs spec)

| Spec requirement | Task |
| --- | --- |
| Full visual shell | 2–4, 10 |
| Bake-to-layers orb + counts | 5–8 |
| `home_orb_*` naming | 5–9 |
| Sticky tab bar | 2 |
| Emil press/tab motion | 2, 4 |
| Reduce-motion / lifecycle pause | 8–9 |
| Cache across tab return | 7, 9 (`IndexedStack` + bake cache) |
| Post-onboarding wiring | 10 |
| UI-only / out of scope respected | all tasks |
| Tests listed in spec | 1–10 |

No TBD placeholders. Layer timings match Swift table. Types consistently use `HomeOrb*` / `Home*` prefixes.
