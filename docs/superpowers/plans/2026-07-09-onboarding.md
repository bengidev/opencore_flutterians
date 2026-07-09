# Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a first-run 5-page Nothing-styled onboarding module (4 feature pages + CTA) with persisted completion, internal abstractions, and app-root gating.

**Architecture:** Internal module at `opencore_flutterians/lib/onboarding/` behind a public barrel. `OnboardingFacade` bootstraps completion; `OnboardingFlowController` owns page intents; `OnboardingHeroStrategy` renders per-page heroes; `OnboardingCompletionStore` hides SharedPreferences. App root shows onboarding or the existing demo home.

**Tech Stack:** Flutter 3.x / Dart 3.12+, `shared_preferences`, `google_fonts` (Doto, Space Grotesk, Space Mono), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-07-09-onboarding-design.md`

---

## File Structure

All paths relative to `opencore_flutterians/` (the Flutter package root).

| Path | Responsibility |
|------|----------------|
| `pubspec.yaml` | Add `shared_preferences`, `google_fonts` |
| `lib/onboarding/onboarding.dart` | Public barrel — exports facade + entry only |
| `lib/onboarding/onboarding_completion_store.dart` | Abstract persistence port |
| `lib/onboarding/onboarding_shared_preferences_store.dart` | SharedPreferences implementation |
| `lib/onboarding/onboarding_page_model.dart` | Page kind + copy + hero id |
| `lib/onboarding/onboarding_page_catalog.dart` | Immutable 5-page factory |
| `lib/onboarding/onboarding_flow_controller.dart` | Index, intents, enter/error |
| `lib/onboarding/onboarding_tokens.dart` | Dark/light color + radius tokens |
| `lib/onboarding/onboarding_theme.dart` | ThemeData from tokens + fonts |
| `lib/onboarding/heroes/onboarding_hero_strategy.dart` | Strategy interface + registry |
| `lib/onboarding/heroes/onboarding_pairing_hero.dart` | Page 1 hero |
| `lib/onboarding/heroes/onboarding_workspace_hero.dart` | Page 2 hero |
| `lib/onboarding/heroes/onboarding_queue_hero.dart` | Page 3 hero |
| `lib/onboarding/heroes/onboarding_depth_hero.dart` | Page 4 hero |
| `lib/onboarding/heroes/onboarding_brand_hero.dart` | CTA hero |
| `lib/onboarding/widgets/onboarding_page_shell.dart` | Three-layer page layout |
| `lib/onboarding/widgets/onboarding_progress_indicator.dart` | Step marks (6pt) |
| `lib/onboarding/widgets/onboarding_skip_control.dart` | Tertiary Skip |
| `lib/onboarding/widgets/onboarding_nav_bar.dart` | Continue / Back+Next / Enter |
| `lib/onboarding/onboarding_entry.dart` | Flow shell: theme, gestures, pages |
| `lib/onboarding/onboarding_facade.dart` | Bootstrap API |
| `lib/main.dart` | Wire facade; keep demo home as post-onboarding |
| `test/onboarding/onboarding_flow_controller_test.dart` | Controller unit tests |
| `test/onboarding/onboarding_completion_store_test.dart` | Store unit tests |
| `test/onboarding/onboarding_entry_test.dart` | Chrome + skip + enter widget tests |
| `test/onboarding/onboarding_facade_test.dart` | Bootstrap widget tests |
| `test/widget_test.dart` | Update smoke test for gated root |

---

### Task 1: Dependencies

**Files:**
- Modify: `opencore_flutterians/pubspec.yaml`

- [ ] **Step 1: Add dependencies**

Under `dependencies:`, add:

```yaml
  shared_preferences: ^2.5.3
  google_fonts: ^6.2.1
```

Keep existing `cupertino_icons`. Do not change SDK constraints.

- [ ] **Step 2: Resolve packages**

Run:

```bash
cd opencore_flutterians && flutter pub get
```

Expected: exit 0; `.dart_tool/package_config.json` lists `shared_preferences` and `google_fonts`.

- [ ] **Step 3: Commit**

```bash
git add opencore_flutterians/pubspec.yaml opencore_flutterians/pubspec.lock
git commit -m "$(cat <<'EOF'
Add shared_preferences and google_fonts for onboarding.

EOF
)"
```

---

### Task 2: Completion store (TDD)

**Files:**
- Create: `opencore_flutterians/lib/onboarding/onboarding_completion_store.dart`
- Create: `opencore_flutterians/lib/onboarding/onboarding_shared_preferences_store.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_completion_store_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/onboarding/onboarding_completion_store_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_shared_preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingSharedPreferencesStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('hasCompleted is false by default', () async {
      final store = OnboardingSharedPreferencesStore();
      expect(await store.hasCompleted(), isFalse);
    });

    test('markCompleted makes hasCompleted true', () async {
      final store = OnboardingSharedPreferencesStore();
      await store.markCompleted();
      expect(await store.hasCompleted(), isTrue);
    });

    test('uses namespaced key onboarding.completed', () async {
      final store = OnboardingSharedPreferencesStore();
      await store.markCompleted();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding.completed'), isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_completion_store_test.dart
```

Expected: FAIL — target library / types not found.

- [ ] **Step 3: Write minimal implementation**

`lib/onboarding/onboarding_completion_store.dart`:

```dart
abstract class OnboardingCompletionStore {
  Future<bool> hasCompleted();
  Future<void> markCompleted();
}
```

`lib/onboarding/onboarding_shared_preferences_store.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_completion_store.dart';

class OnboardingSharedPreferencesStore implements OnboardingCompletionStore {
  static const completedKey = 'onboarding.completed';

  @override
  Future<bool> hasCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(completedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(completedKey, true);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_completion_store_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/onboarding_completion_store.dart \
  opencore_flutterians/lib/onboarding/onboarding_shared_preferences_store.dart \
  opencore_flutterians/test/onboarding/onboarding_completion_store_test.dart
git commit -m "$(cat <<'EOF'
Add onboarding completion store with SharedPreferences.

EOF
)"
```

---

### Task 3: Page model + catalog

**Files:**
- Create: `opencore_flutterians/lib/onboarding/onboarding_page_model.dart`
- Create: `opencore_flutterians/lib/onboarding/onboarding_page_catalog.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_page_catalog_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_catalog.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';

void main() {
  test('catalog has 4 feature pages then 1 cta', () {
    final pages = OnboardingPageCatalog.build();
    expect(pages, hasLength(5));
    expect(pages.take(4).every((p) => p.kind == OnboardingPageKind.feature), isTrue);
    expect(pages.last.kind, OnboardingPageKind.cta);
    expect(pages[0].headline, contains('encrypted'));
    expect(pages.last.headline, 'OpenCore');
    expect(pages.map((p) => p.heroId).toSet(), hasLength(5));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_page_catalog_test.dart
```

Expected: FAIL — missing libraries.

- [ ] **Step 3: Write minimal implementation**

`lib/onboarding/onboarding_page_model.dart`:

```dart
enum OnboardingPageKind { feature, cta }

enum OnboardingHeroId { pairing, workspace, queue, depth, brand }

class OnboardingPageModel {
  const OnboardingPageModel({
    required this.kind,
    required this.heroId,
    required this.headline,
    required this.body,
    required this.featureStepLabel,
  });

  final OnboardingPageKind kind;
  final OnboardingHeroId heroId;
  final String headline;
  final String body;

  /// Null on CTA. Feature pages use values like `01 / 04`.
  final String? featureStepLabel;
}
```

`lib/onboarding/onboarding_page_catalog.dart`:

```dart
import 'onboarding_page_model.dart';

class OnboardingPageCatalog {
  const OnboardingPageCatalog._();

  static List<OnboardingPageModel> build() => const [
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.pairing,
          headline: 'End-to-end encrypted pairing and chats',
          body:
              'Pair trusted devices, keep local workspace context private, and open AI chats without leaking the conversation boundary.',
          featureStepLabel: '01 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.workspace,
          headline: 'Ask, write, and explore with AI models',
          body:
              'OpenCore turns prompts into a focused working surface for drafting, refactoring, research, and interface decisions.',
          featureStepLabel: '02 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.queue,
          headline: 'Queue follow-ups while a turn is running',
          body:
              'Keep momentum by lining up the next question, test request, or implementation step before the current model turn finishes.',
          featureStepLabel: '03 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.depth,
          headline: 'Tune how much thinking the AI uses',
          body:
              'Choose faster answers, balanced planning, or deeper reasoning before the model commits compute to the task.',
          featureStepLabel: '04 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.cta,
          heroId: OnboardingHeroId.brand,
          headline: 'OpenCore',
          body:
              'Your AI-native command center. Deploy specialized agents to handle code, review, test, and ship — all within your existing workflow without context switching.',
          featureStepLabel: null,
        ),
      ];
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_page_catalog_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/onboarding_page_model.dart \
  opencore_flutterians/lib/onboarding/onboarding_page_catalog.dart \
  opencore_flutterians/test/onboarding/onboarding_page_catalog_test.dart
git commit -m "$(cat <<'EOF'
Add onboarding page model and five-page catalog.

EOF
)"
```

---

### Task 4: Flow controller (TDD)

**Files:**
- Create: `opencore_flutterians/lib/onboarding/onboarding_flow_controller.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_flow_controller_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_flow_controller.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_catalog.dart';

class _FakeStore implements OnboardingCompletionStore {
  bool completed = false;
  bool throwOnMark = false;

  @override
  Future<bool> hasCompleted() async => completed;

  @override
  Future<void> markCompleted() async {
    if (throwOnMark) throw StateError('write failed');
    completed = true;
  }
}

void main() {
  late _FakeStore store;
  late OnboardingFlowController controller;
  var completedCalls = 0;

  setUp(() {
    store = _FakeStore();
    completedCalls = 0;
    controller = OnboardingFlowController(
      pages: OnboardingPageCatalog.build(),
      store: store,
      onCompleted: () => completedCalls++,
    );
  });

  tearDown(() => controller.dispose());

  test('starts at index 0', () {
    expect(controller.index, 0);
    expect(controller.isFirst, isTrue);
    expect(controller.isCta, isFalse);
  });

  test('next advances and clamps at cta', () {
    controller.next();
    expect(controller.index, 1);
    for (var i = 0; i < 10; i++) {
      controller.next();
    }
    expect(controller.index, 4);
    expect(controller.isCta, isTrue);
  });

  test('back retreats and clamps at 0', () {
    controller.next();
    controller.back();
    expect(controller.index, 0);
    controller.back();
    expect(controller.index, 0);
  });

  test('skip jumps to cta without persisting', () async {
    controller.skip();
    expect(controller.index, 4);
    expect(await store.hasCompleted(), isFalse);
    expect(completedCalls, 0);
  });

  test('enter persists and invokes onCompleted', () async {
    controller.skip();
    await controller.enter();
    expect(store.completed, isTrue);
    expect(completedCalls, 1);
    expect(controller.enterError, isNull);
  });

  test('enter failure sets inline error and does not complete', () async {
    store.throwOnMark = true;
    controller.skip();
    await controller.enter();
    expect(completedCalls, 0);
    expect(controller.enterError, '[ERROR: COULD NOT SAVE]');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_flow_controller_test.dart
```

Expected: FAIL — missing `OnboardingFlowController`.

- [ ] **Step 3: Write minimal implementation**

`lib/onboarding/onboarding_flow_controller.dart`:

```dart
import 'package:flutter/foundation.dart';

import 'onboarding_completion_store.dart';
import 'onboarding_page_model.dart';

class OnboardingFlowController extends ChangeNotifier {
  OnboardingFlowController({
    required List<OnboardingPageModel> pages,
    required OnboardingCompletionStore store,
    required VoidCallback onCompleted,
  })  : _pages = List.unmodifiable(pages),
        _store = store,
        _onCompleted = onCompleted;

  final List<OnboardingPageModel> _pages;
  final OnboardingCompletionStore _store;
  final VoidCallback _onCompleted;

  int _index = 0;
  String? _enterError;
  bool _entering = false;

  int get index => _index;
  String? get enterError => _enterError;
  bool get isEntering => _entering;
  bool get isFirst => _index == 0;
  bool get isCta => _pages[_index].kind == OnboardingPageKind.cta;
  OnboardingPageModel get currentPage => _pages[_index];
  List<OnboardingPageModel> get pages => _pages;
  int get ctaIndex => _pages.indexWhere((p) => p.kind == OnboardingPageKind.cta);

  void next() {
    if (isCta) return;
    _index = (_index + 1).clamp(0, _pages.length - 1);
    _enterError = null;
    notifyListeners();
  }

  void back() {
    if (isFirst) return;
    _index = (_index - 1).clamp(0, _pages.length - 1);
    _enterError = null;
    notifyListeners();
  }

  void skip() {
    final target = ctaIndex;
    if (target < 0 || _index == target) return;
    _index = target;
    _enterError = null;
    notifyListeners();
  }

  Future<void> enter() async {
    if (!isCta || _entering) return;
    _entering = true;
    _enterError = null;
    notifyListeners();
    try {
      await _store.markCompleted();
      _onCompleted();
    } catch (_) {
      _enterError = '[ERROR: COULD NOT SAVE]';
    } finally {
      _entering = false;
      notifyListeners();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_flow_controller_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/onboarding_flow_controller.dart \
  opencore_flutterians/test/onboarding/onboarding_flow_controller_test.dart
git commit -m "$(cat <<'EOF'
Add onboarding flow controller with skip and enter intents.

EOF
)"
```

---

### Task 5: Tokens + theme

**Files:**
- Create: `opencore_flutterians/lib/onboarding/onboarding_tokens.dart`
- Create: `opencore_flutterians/lib/onboarding/onboarding_theme.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_theme_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/onboarding_tokens.dart';

void main() {
  test('dark and light themes use 6pt control radius', () {
    final dark = OnboardingTheme.dark();
    final light = OnboardingTheme.light();
    expect(dark.filledButtonTheme.style?.shape?.resolve({}), isA<RoundedRectangleBorder>());
    final darkShape =
        dark.filledButtonTheme.style!.shape!.resolve({})! as RoundedRectangleBorder;
    expect(darkShape.borderRadius, BorderRadius.circular(OnboardingTokens.radiusControl));
    expect(OnboardingTokens.radiusControl, 6);
    expect(light.scaffoldBackgroundColor, OnboardingTokens.light.black);
    expect(dark.scaffoldBackgroundColor, OnboardingTokens.dark.black);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_theme_test.dart
```

Expected: FAIL — missing types.

- [ ] **Step 3: Write minimal implementation**

`lib/onboarding/onboarding_tokens.dart`:

```dart
import 'package:flutter/material.dart';

class OnboardingColorTokens {
  const OnboardingColorTokens({
    required this.black,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.borderVisible,
    required this.textDisabled,
    required this.textSecondary,
    required this.textPrimary,
    required this.textDisplay,
    required this.accent,
  });

  final Color black;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color borderVisible;
  final Color textDisabled;
  final Color textSecondary;
  final Color textPrimary;
  final Color textDisplay;
  final Color accent;
}

class OnboardingTokens {
  static const radiusControl = 6.0;
  static const accent = Color(0xFFD71921);

  static const dark = OnboardingColorTokens(
    black: Color(0xFF000000),
    surface: Color(0xFF111111),
    surfaceRaised: Color(0xFF1A1A1A),
    border: Color(0xFF222222),
    borderVisible: Color(0xFF333333),
    textDisabled: Color(0xFF666666),
    textSecondary: Color(0xFF999999),
    textPrimary: Color(0xFFE8E8E8),
    textDisplay: Color(0xFFFFFFFF),
    accent: accent,
  );

  static const light = OnboardingColorTokens(
    black: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF0F0F0),
    border: Color(0xFFE8E8E8),
    borderVisible: Color(0xFFCCCCCC),
    textDisabled: Color(0xFF999999),
    textSecondary: Color(0xFF666666),
    textPrimary: Color(0xFF1A1A1A),
    textDisplay: Color(0xFF000000),
    accent: accent,
  );
}
```

`lib/onboarding/onboarding_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_tokens.dart';

class OnboardingTheme {
  static ThemeData dark() => _build(OnboardingTokens.dark, Brightness.dark);
  static ThemeData light() => _build(OnboardingTokens.light, Brightness.light);

  static ThemeData _build(OnboardingColorTokens c, Brightness brightness) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.black,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.textDisplay,
        onPrimary: c.black,
        secondary: c.textSecondary,
        onSecondary: c.black,
        error: c.accent,
        onError: c.textDisplay,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),
    );

    TextStyle grotesk({
      double size = 16,
      FontWeight weight = FontWeight.w400,
      Color? color,
      double? height,
      double? letterSpacing,
    }) =>
        GoogleFonts.spaceGrotesk(
          fontSize: size,
          fontWeight: weight,
          color: color ?? c.textPrimary,
          height: height,
          letterSpacing: letterSpacing,
        );

    TextStyle mono({
      double size = 11,
      FontWeight weight = FontWeight.w400,
      Color? color,
      double letterSpacing = 0.08 * 11,
    }) =>
        GoogleFonts.spaceMono(
          fontSize: size,
          fontWeight: weight,
          color: color ?? c.textSecondary,
          letterSpacing: letterSpacing,
        );

    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: GoogleFonts.doto(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: c.textDisplay,
          height: 1.05,
          letterSpacing: -0.02 * 48,
        ),
        headlineMedium: grotesk(size: 24, weight: FontWeight.w400, color: c.textDisplay, height: 1.2),
        bodyLarge: grotesk(size: 16, height: 1.5),
        bodyMedium: grotesk(size: 14, color: c.textSecondary, height: 1.5),
        labelSmall: mono(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.textDisplay,
          foregroundColor: c.black,
          shape: shape,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(120, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.borderVisible),
          shape: shape,
          elevation: 0,
          minimumSize: const Size(120, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textSecondary,
          shape: shape,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        OnboardingThemeColors(colors: c),
      ],
    );
  }
}

class OnboardingThemeColors extends ThemeExtension<OnboardingThemeColors> {
  const OnboardingThemeColors({required this.colors});

  final OnboardingColorTokens colors;

  static OnboardingThemeColors of(BuildContext context) =>
      Theme.of(context).extension<OnboardingThemeColors>()!;

  @override
  OnboardingThemeColors copyWith({OnboardingColorTokens? colors}) =>
      OnboardingThemeColors(colors: colors ?? this.colors);

  @override
  OnboardingThemeColors lerp(ThemeExtension<OnboardingThemeColors>? other, double t) {
    if (other is! OnboardingThemeColors) return this;
    return t < 0.5 ? this : other;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_theme_test.dart
```

Expected: PASS. If `google_fonts` network fails in CI, set in test `setUpAll`:

```dart
GoogleFonts.config.allowRuntimeFetching = false;
```

and ensure the test still only asserts colors/radius (fonts fall back).

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/onboarding_tokens.dart \
  opencore_flutterians/lib/onboarding/onboarding_theme.dart \
  opencore_flutterians/test/onboarding/onboarding_theme_test.dart
git commit -m "$(cat <<'EOF'
Add Nothing-inspired onboarding tokens and dual themes.

EOF
)"
```

---

### Task 6: Hero strategies

**Files:**
- Create: `opencore_flutterians/lib/onboarding/heroes/onboarding_hero_strategy.dart`
- Create: `opencore_flutterians/lib/onboarding/heroes/onboarding_pairing_hero.dart`
- Create: `opencore_flutterians/lib/onboarding/heroes/onboarding_workspace_hero.dart`
- Create: `opencore_flutterians/lib/onboarding/heroes/onboarding_queue_hero.dart`
- Create: `opencore_flutterians/lib/onboarding/heroes/onboarding_depth_hero.dart`
- Create: `opencore_flutterians/lib/onboarding/heroes/onboarding_brand_hero.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_hero_strategy_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/onboarding_hero_strategy.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';

void main() {
  testWidgets('registry builds a distinct hero for each hero id', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: OnboardingHeroId.values
                    .map(
                      (id) => SizedBox(
                        height: 80,
                        child: OnboardingHeroRegistry.build(id, active: true),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(OnboardingPairingHero), findsOneWidget);
    expect(find.byType(OnboardingWorkspaceHero), findsOneWidget);
    expect(find.byType(OnboardingQueueHero), findsOneWidget);
    expect(find.byType(OnboardingDepthHero), findsOneWidget);
    expect(find.byType(OnboardingBrandHero), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_hero_strategy_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Write hero implementations**

`heroes/onboarding_hero_strategy.dart`:

```dart
import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';
import 'onboarding_brand_hero.dart';
import 'onboarding_depth_hero.dart';
import 'onboarding_pairing_hero.dart';
import 'onboarding_queue_hero.dart';
import 'onboarding_workspace_hero.dart';

abstract class OnboardingHeroStrategy {
  const OnboardingHeroStrategy();

  Widget build({required bool active});
}

class OnboardingHeroRegistry {
  static Widget build(OnboardingHeroId id, {required bool active}) {
    final strategy = switch (id) {
      OnboardingHeroId.pairing => const OnboardingPairingHeroStrategy(),
      OnboardingHeroId.workspace => const OnboardingWorkspaceHeroStrategy(),
      OnboardingHeroId.queue => const OnboardingQueueHeroStrategy(),
      OnboardingHeroId.depth => const OnboardingDepthHeroStrategy(),
      OnboardingHeroId.brand => const OnboardingBrandHeroStrategy(),
    };
    return strategy.build(active: active);
  }
}
```

Each hero file follows the same pattern: a public `StatelessWidget`/`StatefulWidget` type named `Onboarding*Hero` (for finders) plus a `const` strategy class.

`onboarding_pairing_hero.dart` — two outlined device rects (6pt) + lock tick via `AnimationController` 300ms ease-out when `active` becomes true. Export widget `OnboardingPairingHero`.

`onboarding_workspace_hero.dart` — prompt line fading into a larger surface block. Widget: `OnboardingWorkspaceHero`.

`onboarding_queue_hero.dart` — three stacked queue rows appearing with staggered opacity. Widget: `OnboardingQueueHero`.

`onboarding_depth_hero.dart` — three segmented bars labeled FAST / BALANCED / DEEP (Space Mono via theme `labelSmall`), active segment uses accent. Widget: `OnboardingDepthHero`.

`onboarding_brand_hero.dart` — large `OpenCore` using `Theme.of(context).textTheme.displayLarge`. Widget: `OnboardingBrandHero`.

Motion rules for all heroes:

- Duration 300–400ms
- Curve: `Cubic(0.25, 0.1, 0.25, 1)`
- Prefer opacity; no shadows, no gradients in chrome, no spring

Example pairing hero (others mirror structure):

```dart
import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_strategy.dart';

class OnboardingPairingHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingPairingHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingPairingHero(active: active);
}

class OnboardingPairingHero extends StatefulWidget {
  const OnboardingPairingHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingPairingHero> createState() => _OnboardingPairingHeroState();
}

class _OnboardingPairingHeroState extends State<OnboardingPairingHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: const Cubic(0.25, 0.1, 0.25, 1),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingPairingHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    return FadeTransition(
      opacity: _opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _device(c),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.lock_outline, color: c.accent, size: 20),
          ),
          _device(c),
        ],
      ),
    );
  }

  Widget _device(OnboardingColorTokens c) {
    return Container(
      width: 72,
      height: 112,
      decoration: BoxDecoration(
        border: Border.all(color: c.borderVisible),
        borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
      ),
    );
  }
}
```

Implement the other four heroes with the same strategy/widget split and mechanical motion. Keep each file focused; no shared “generic animated box” that erases page identity.

- [ ] **Step 4: Run test to verify it passes**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_hero_strategy_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/heroes \
  opencore_flutterians/test/onboarding/onboarding_hero_strategy_test.dart
git commit -m "$(cat <<'EOF'
Add onboarding hero strategies for all five pages.

EOF
)"
```

---

### Task 7: Chrome widgets (shell, progress, skip, nav)

**Files:**
- Create: `opencore_flutterians/lib/onboarding/widgets/onboarding_page_shell.dart`
- Create: `opencore_flutterians/lib/onboarding/widgets/onboarding_progress_indicator.dart`
- Create: `opencore_flutterians/lib/onboarding/widgets/onboarding_skip_control.dart`
- Create: `opencore_flutterians/lib/onboarding/widgets/onboarding_nav_bar.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_nav_bar_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/widgets/onboarding_nav_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: OnboardingTheme.dark(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('page 0 shows Continue and Skip only', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OnboardingNavBar(
          kind: OnboardingPageKind.feature,
          isFirst: true,
          isCta: false,
          enterError: null,
          isEntering: false,
          onBack: () {},
          onNext: () {},
          onSkip: () {},
          onEnter: () async {},
        ),
      ),
    );
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
    expect(find.text('BACK'), findsNothing);
    expect(find.text('NEXT'), findsNothing);
    expect(find.text('ENTER'), findsNothing);
  });

  testWidgets('middle feature page shows Back Next Skip', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OnboardingNavBar(
          kind: OnboardingPageKind.feature,
          isFirst: false,
          isCta: false,
          enterError: null,
          isEntering: false,
          onBack: () {},
          onNext: () {},
          onSkip: () {},
          onEnter: () async {},
        ),
      ),
    );
    expect(find.text('BACK'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
  });

  testWidgets('cta shows Enter only and error text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OnboardingNavBar(
          kind: OnboardingPageKind.cta,
          isFirst: false,
          isCta: true,
          enterError: '[ERROR: COULD NOT SAVE]',
          isEntering: false,
          onBack: () {},
          onNext: () {},
          onSkip: () {},
          onEnter: () async {},
        ),
      ),
    );
    expect(find.text('ENTER'), findsOneWidget);
    expect(find.text('[ERROR: COULD NOT SAVE]'), findsOneWidget);
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('BACK'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_nav_bar_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement chrome widgets**

`onboarding_skip_control.dart`:

```dart
import 'package:flutter/material.dart';

class OnboardingSkipControl extends StatelessWidget {
  const OnboardingSkipControl({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onSkip,
        child: Text('SKIP', style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
```

`onboarding_progress_indicator.dart`:

```dart
import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.index,
    required this.featureCount,
  });

  final int index;
  final int featureCount;

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    return Row(
      children: List.generate(featureCount, (i) {
        final active = i == index.clamp(0, featureCount - 1) && index < featureCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: const Cubic(0.25, 0.1, 0.25, 1),
          margin: const EdgeInsets.only(right: 8),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? c.accent : c.borderVisible,
            borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
          ),
        );
      }),
    );
  }
}
```

`onboarding_nav_bar.dart`:

```dart
import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';
import 'onboarding_skip_control.dart';

class OnboardingNavBar extends StatelessWidget {
  const OnboardingNavBar({
    super.key,
    required this.kind,
    required this.isFirst,
    required this.isCta,
    required this.enterError,
    required this.isEntering,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.onEnter,
  });

  final OnboardingPageKind kind;
  final bool isFirst;
  final bool isCta;
  final String? enterError;
  final bool isEntering;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Future<void> Function() onEnter;

  @override
  Widget build(BuildContext context) {
    if (isCta || kind == OnboardingPageKind.cta) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (enterError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                enterError!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          FilledButton(
            onPressed: isEntering ? null : () => onEnter(),
            child: Text(
              'ENTER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingSkipControl(onSkip: onSkip),
        const SizedBox(height: 8),
        if (isFirst)
          FilledButton(
            onPressed: onNext,
            child: Text(
              'CONTINUE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: Text('BACK', style: Theme.of(context).textTheme.labelSmall),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onNext,
                  child: Text(
                    'NEXT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
```

`onboarding_page_shell.dart`:

```dart
import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';
import 'onboarding_progress_indicator.dart';

class OnboardingPageShell extends StatelessWidget {
  const OnboardingPageShell({
    super.key,
    required this.page,
    required this.pageIndex,
    required this.featureCount,
    required this.hero,
    required this.navBar,
  });

  final OnboardingPageModel page;
  final int pageIndex;
  final int featureCount;
  final Widget hero;
  final Widget navBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (page.kind == OnboardingPageKind.feature) ...[
              Row(
                children: [
                  OnboardingProgressIndicator(
                    index: pageIndex,
                    featureCount: featureCount,
                  ),
                  const Spacer(),
                  Text(
                    page.featureStepLabel ?? '',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ] else
              const SizedBox(height: 64),
            Expanded(child: Center(child: hero)),
            const SizedBox(height: 32),
            Text(page.headline, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(page.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            navBar,
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_nav_bar_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/widgets \
  opencore_flutterians/test/onboarding/onboarding_nav_bar_test.dart
git commit -m "$(cat <<'EOF'
Add onboarding chrome widgets with 6pt controls.

EOF
)"
```

---

### Task 8: Entry + gestures + facade

**Files:**
- Create: `opencore_flutterians/lib/onboarding/onboarding_entry.dart`
- Create: `opencore_flutterians/lib/onboarding/onboarding_facade.dart`
- Create: `opencore_flutterians/lib/onboarding/onboarding.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_entry_test.dart`
- Test: `opencore_flutterians/test/onboarding/onboarding_facade_test.dart`

- [ ] **Step 1: Write failing entry tests**

`test/onboarding/onboarding_entry_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_entry.dart';

class _MemoryStore implements OnboardingCompletionStore {
  bool completed = false;
  @override
  Future<bool> hasCompleted() async => completed;
  @override
  Future<void> markCompleted() async => completed = true;
}

void main() {
  testWidgets('skip jumps to CTA Enter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingEntry(
          store: _MemoryStore(),
          onCompleted: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();
    expect(find.text('ENTER'), findsOneWidget);
    expect(find.text('OpenCore'), findsWidgets);
  });

  testWidgets('enter completes and calls onCompleted', (tester) async {
    final store = _MemoryStore();
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingEntry(
          store: store,
          onCompleted: () => done = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENTER'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(store.completed, isTrue);
  });
}
```

`test/onboarding/onboarding_facade_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_facade.dart';

class _MemoryStore implements OnboardingCompletionStore {
  _MemoryStore(this.completed);
  bool completed;
  @override
  Future<bool> hasCompleted() async => completed;
  @override
  Future<void> markCompleted() async => completed = true;
}

void main() {
  testWidgets('incomplete shows onboarding', (tester) async {
    final root = await OnboardingFacade(store: _MemoryStore(false)).buildRoot(
      home: const Text('HOME'),
    );
    await tester.pumpWidget(MaterialApp(home: root));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('complete shows home', (tester) async {
    final root = await OnboardingFacade(store: _MemoryStore(true)).buildRoot(
      home: const Text('HOME'),
    );
    await tester.pumpWidget(MaterialApp(home: root));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_entry_test.dart test/onboarding/onboarding_facade_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement entry, facade, barrel**

`onboarding_entry.dart` — key behaviors:

- Wraps content in `Theme` selecting `OnboardingTheme.dark()` / `.light()` from `MediaQuery.platformBrightness` (or `Theme.of(context).brightness` of parent). Prefer:

```dart
final brightness = MediaQuery.platformBrightnessOf(context);
final theme = brightness == Brightness.dark
    ? OnboardingTheme.dark()
    : OnboardingTheme.light();
```

- Owns `OnboardingFlowController` + `PageController`.
- `PageView` uses `physics: const NeverScrollableScrollPhysics()` so buttons/gestures own navigation.
- Horizontal drag: on `onHorizontalDragEnd`, if `details.primaryVelocity != null`:
  - `primaryVelocity! > 0` → finger swipe right → `controller.next()`
  - `primaryVelocity! < 0` → finger swipe left → `controller.back()`
- Animate `PageController` to `controller.index` on listener notify (300ms, `Cubic(0.25, 0.1, 0.25, 1)`).
- Build each page with `OnboardingPageShell` + `OnboardingHeroRegistry.build(..., active: index == i)` + `OnboardingNavBar`.

`onboarding_facade.dart`:

```dart
import 'package:flutter/widgets.dart';

import 'onboarding_completion_store.dart';
import 'onboarding_entry.dart';
import 'onboarding_shared_preferences_store.dart';

class OnboardingFacade {
  OnboardingFacade({OnboardingCompletionStore? store})
      : _store = store ?? OnboardingSharedPreferencesStore();

  final OnboardingCompletionStore _store;

  Future<Widget> buildRoot({required Widget home}) async {
    final completed = await _store.hasCompleted();
    if (completed) return home;
    return _OnboardingGate(store: _store, home: home);
  }
}

class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate({required this.store, required this.home});

  final OnboardingCompletionStore store;
  final Widget home;

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.home;
    return OnboardingEntry(
      store: widget.store,
      onCompleted: () => setState(() => _done = true),
    );
  }
}
```

`onboarding.dart` barrel (public only):

```dart
library onboarding;

export 'onboarding_entry.dart';
export 'onboarding_facade.dart';
```

Full `OnboardingEntry` implementation sketch (engineer must flesh heroes wiring exactly):

```dart
import 'package:flutter/material.dart';

import 'heroes/onboarding_hero_strategy.dart';
import 'onboarding_completion_store.dart';
import 'onboarding_flow_controller.dart';
import 'onboarding_page_catalog.dart';
import 'onboarding_theme.dart';
import 'widgets/onboarding_nav_bar.dart';
import 'widgets/onboarding_page_shell.dart';

class OnboardingEntry extends StatefulWidget {
  const OnboardingEntry({
    super.key,
    required this.store,
    required this.onCompleted,
  });

  final OnboardingCompletionStore store;
  final VoidCallback onCompleted;

  @override
  State<OnboardingEntry> createState() => _OnboardingEntryState();
}

class _OnboardingEntryState extends State<OnboardingEntry> {
  late final OnboardingFlowController _flow = OnboardingFlowController(
    pages: OnboardingPageCatalog.build(),
    store: widget.store,
    onCompleted: widget.onCompleted,
  );
  late final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _flow.addListener(_syncPage);
  }

  void _syncPage() {
    if (!_pageController.hasClients) return;
    final target = _flow.index;
    if (_pageController.page?.round() != target) {
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 350),
        curve: const Cubic(0.25, 0.1, 0.25, 1),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _flow.removeListener(_syncPage);
    _flow.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = brightness == Brightness.dark
        ? OnboardingTheme.dark()
        : OnboardingTheme.light();
    final featureCount = _flow.pages
        .where((p) => p.kind == OnboardingPageKind.feature)
        .length;

    return Theme(
      data: theme,
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity ?? 0;
            if (v > 200) {
              _flow.next();
            } else if (v < -200) {
              _flow.back();
            }
          },
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _flow.pages.length,
            itemBuilder: (context, index) {
              final page = _flow.pages[index];
              return OnboardingPageShell(
                page: page,
                pageIndex: index,
                featureCount: featureCount,
                hero: OnboardingHeroRegistry.build(
                  page.heroId,
                  active: _flow.index == index,
                ),
                navBar: OnboardingNavBar(
                  kind: page.kind,
                  isFirst: index == 0,
                  isCta: page.kind == OnboardingPageKind.cta,
                  enterError: _flow.enterError,
                  isEntering: _flow.isEntering,
                  onBack: _flow.back,
                  onNext: _flow.next,
                  onSkip: _flow.skip,
                  onEnter: _flow.enter,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

Add `import 'onboarding_page_model.dart';` in `onboarding_entry.dart` for `OnboardingPageKind`.

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd opencore_flutterians && flutter test test/onboarding/onboarding_entry_test.dart test/onboarding/onboarding_facade_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/onboarding/onboarding_entry.dart \
  opencore_flutterians/lib/onboarding/onboarding_facade.dart \
  opencore_flutterians/lib/onboarding/onboarding.dart \
  opencore_flutterians/test/onboarding/onboarding_entry_test.dart \
  opencore_flutterians/test/onboarding/onboarding_facade_test.dart
git commit -m "$(cat <<'EOF'
Add onboarding entry, gestures, facade, and public barrel.

EOF
)"
```

---

### Task 9: Wire `main.dart` + update smoke test

**Files:**
- Modify: `opencore_flutterians/lib/main.dart`
- Modify: `opencore_flutterians/test/widget_test.dart`

- [ ] **Step 1: Write the failing/updated smoke test**

Replace `test/widget_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch shows onboarding continue', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const OpenCoreApp());
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('completed launch shows home counter', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding.completed': true});
    await tester.pumpWidget(const OpenCoreApp());
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd opencore_flutterians && flutter test test/widget_test.dart
```

Expected: FAIL — `OpenCoreApp` missing / still `MyApp` without gate.

- [ ] **Step 3: Rewrite main wiring**

Replace `lib/main.dart` with a structure that:

1. Keeps portrait lock in `main()`.
2. Renames root to `OpenCoreApp`.
3. Uses a small bootstrap `FutureBuilder` / stateful loader calling `OnboardingFacade().buildRoot(home: const OpenCoreHomePage(...))`.
4. Preserves the existing counter home as `OpenCoreHomePage` (rename from `MyHomePage`; keep behavior).
5. Imports only `package:opencore_flutterians/onboarding/onboarding.dart` from the module.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencore_flutterians/onboarding/onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const OpenCoreApp());
}

class OpenCoreApp extends StatelessWidget {
  const OpenCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenCore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const _OpenCoreRoot(),
    );
  }
}

class _OpenCoreRoot extends StatefulWidget {
  const _OpenCoreRoot();

  @override
  State<_OpenCoreRoot> createState() => _OpenCoreRootState();
}

class _OpenCoreRootState extends State<_OpenCoreRoot> {
  late final Future<Widget> _rootFuture =
      OnboardingFacade().buildRoot(home: const OpenCoreHomePage(title: 'OpenCore'));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _rootFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('[LOADING...]')),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

class OpenCoreHomePage extends StatefulWidget {
  const OpenCoreHomePage({super.key, required this.title});

  final String title;

  @override
  State<OpenCoreHomePage> createState() => _OpenCoreHomePageState();
}

class _OpenCoreHomePageState extends State<OpenCoreHomePage> {
  int _counter = 0;

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 4: Run all tests**

```bash
cd opencore_flutterians && flutter test && flutter analyze
```

Expected: all tests PASS; analyze reports no issues in onboarding / main.

- [ ] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/main.dart opencore_flutterians/test/widget_test.dart
git commit -m "$(cat <<'EOF'
Wire onboarding facade into app root and update smoke tests.

EOF
)"
```

---

### Task 10: Manual verification checklist

**Files:** none (manual)

- [ ] **Step 1: Run on a simulator/device**

```bash
cd opencore_flutterians && flutter run
```

- [ ] **Step 2: Verify interactions**

1. Cold start → page 1 with Continue + Skip only.
2. Finger swipe right → page 2; swipe left → page 1.
3. Pages 2–4 show Back + Next + Skip.
4. Skip from any feature page → CTA with Enter only.
5. Swipe left on CTA → page 4.
6. Enter → home counter; kill app; relaunch → home (no onboarding).
7. Toggle system dark/light → tokens switch; controls stay 6pt radius.
8. Heroes animate on page focus; no shadows/toasts/gradients in chrome.

- [ ] **Step 3: Final commit if polish fixes were needed**

Only if Step 2 required code changes — commit those fixes with a focused message. Otherwise stop.

---

## Spec Coverage Self-Review

| Spec requirement | Task |
|------------------|------|
| Internal module + barrel public surface | 8 |
| Facade / Strategy / Repository / Controller / Factory | 2–4, 6, 8 |
| Naming `onboarding_*` / `Onboarding*` | all tasks |
| 5 pages + polished copy | 3 |
| Dark + light tokens, 6pt radius, fonts | 5, 7 |
| Continue / Back+Next / Enter chrome | 7 |
| Skip → CTA, Enter persists | 4, 8 |
| Finger swipe right=next, left=back | 8 |
| SharedPreferences persistence + read/write errors | 2, 4 |
| Heroes with mechanical motion | 6 |
| Wire to existing home | 9 |
| Unit + widget tests | 2–9 |

## Placeholder / Consistency Scan

- No TBD/TODO left in tasks.
- Store API is consistently `hasCompleted` / `markCompleted`.
- Controller intents: `next`, `back`, `skip`, `enter`.
- Public exports limited to facade + entry.
- Gesture mapping matches spec (finger direction, not PageView default).
