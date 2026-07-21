# Home Local Interactions + Tab Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every home chrome control respond with local UI (popup menus, snackbars, clear-on-send) and polish tab switches with a sliding indicator plus short page cross-fade.

**Architecture:** Keep UI-only local state in `HomeView` / `HomeTabShell`. Share one `showHomePopupMenu` helper for anchored menus. No bloc, no chat backend. Composer and model rail take callbacks; parent owns draft + model/speed labels.

**Tech Stack:** Flutter 3 / Dart 3.12, existing `HomePressable` / `HomeTokens` / `HomeColors`, `flutter_test`, `google_fonts` (tests disable runtime fetch).

## Global Constraints

- Package root: `opencore_flutterians/` (all `lib/` and `test/` paths below are relative to this).
- Spec: `docs/superpowers/specs/2026-07-21-home-local-interactions-design.md` (repo root).
- Menus: popup menus only — **never** bottom sheets for these controls.
- Backend: none — no chat thread, attachments, voice, or real model APIs.
- Press feedback: wrap new tappable chrome in `HomePressable`.
- Reduced motion: when `MediaQuery.disableAnimationsOf(context)` is true, skip page cross-fade and snap the tab indicator (`Duration.zero`).
- Tests: `GoogleFonts.config.allowRuntimeFetching = false` in `setUpAll`.
- Commit after each task.

## File map

| Path | Responsibility |
| --- | --- |
| `lib/home/home_tokens.dart` | Stub catalogs + snackbar / menu copy |
| `lib/home/views/home_popup_menu.dart` | Shared anchored `showMenu` styled with home tokens |
| `lib/home/views/home_composer_view.dart` | Attachment menu, mic snackbar, send clears + unfocus |
| `lib/home/views/home_model_rail.dart` | Pressable chips; model/speed menus; context snackbar |
| `lib/home/views/home_view.dart` | Menu chats popup; new-chat clear; model/speed state |
| `lib/home/views/home_tab_shell.dart` | Sliding pill, color tween, page cross-fade, haptic |
| `lib/home/home.dart` | Export tokens only (popup helper stays private to views) |
| `test/home/home_composer_test.dart` | Send clears; mic/attachment when practical |
| `test/home/home_model_rail_test.dart` | Model/speed label updates |
| `test/home/home_view_interactions_test.dart` | Menu + new chat |
| `test/home/home_tab_shell_test.dart` | Tab change + reduced-motion smoke |

---

### Task 1: Stub catalogs in `HomeTokens`

**Files:**
- Modify: `lib/home/home_tokens.dart`
- Test: none (constants only; covered by later widget tests)

**Interfaces:**
- Produces: `HomeTokens.stubChatTitles`, `stubModelTitles`, `stubSpeedTitles`, snackbar copy strings

- [x] **Step 1: Extend tokens**

Replace / append in `lib/home/home_tokens.dart` so existing fields stay, and add:

```dart
  static const modelTitle = 'Google: Gemma 4 26B A4B';
  static const speedTitle = 'Max';
  static const contextLabel = '0';

  static const stubChatTitles = <String>[
    'Draft: onboarding copy',
    'Refactor home shell',
    'Weekend ideas',
  ];

  static const stubModelTitles = <String>[
    modelTitle,
    'Google: Gemma 4 9B',
    'OpenCore: Local 7B',
  ];

  static const stubSpeedTitles = <String>[
    'Fast',
    'Balanced',
    'Max',
  ];

  static const snackbarNewChat = 'New chat';
  static const snackbarVoiceSoon = 'Voice input coming soon';
  static const snackbarContext = 'Context: 0 tokens';
  static String snackbarAttachment(String choice) => 'Added $choice';
```

Keep all existing radius/duration/greeting fields unchanged.

- [x] **Step 2: Analyze**

Run: `cd opencore_flutterians && dart analyze lib/home/home_tokens.dart`

Expected: no issues.

- [x] **Step 3: Commit**

```bash
git add opencore_flutterians/lib/home/home_tokens.dart
git commit -m "Add home stub catalogs and snackbar copy."
```

---

### Task 2: Shared home popup menu helper

**Files:**
- Create: `lib/home/views/home_popup_menu.dart`
- Test: `test/home/home_popup_menu_test.dart`

**Interfaces:**
- Produces: `Future<T?> showHomePopupMenu<T>({ required BuildContext context, required List<PopupMenuEntry<T>> entries })`
- Consumes: `HomeColors`, `HomeTokens.radius`

- [x] **Step 1: Write the failing test**

Create `test/home/home_popup_menu_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_popup_menu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showHomePopupMenu returns selected value', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  selected = await showHomePopupMenu<String>(
                    context: context,
                    entries: const [
                      PopupMenuItem(value: 'a', child: Text('Alpha')),
                      PopupMenuItem(value: 'b', child: Text('Beta')),
                    ],
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(selected, 'b');
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_popup_menu_test.dart`

Expected: FAIL — `home_popup_menu.dart` not found.

- [x] **Step 3: Implement helper**

Create `lib/home/views/home_popup_menu.dart`:

```dart
import 'package:flutter/material.dart';

import '../home_theme.dart';
import '../home_tokens.dart';

Future<T?> showHomePopupMenu<T>({
  required BuildContext context,
  required List<PopupMenuEntry<T>> entries,
}) {
  final box = context.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight = box.localToGlobal(
    box.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  final position = RelativeRect.fromRect(
    Rect.fromPoints(topLeft, bottomRight),
    Offset.zero & overlay.size,
  );
  final colors = HomeColors.of(context);

  return showMenu<T>(
    context: context,
    position: position,
    color: colors.surfaceRaised,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HomeTokens.radius),
      side: BorderSide(color: colors.border),
    ),
    items: entries,
  );
}
```

- [x] **Step 4: Run test to verify it passes**

Run: `cd opencore_flutterians && flutter test test/home/home_popup_menu_test.dart`

Expected: PASS.

- [x] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/views/home_popup_menu.dart \
  opencore_flutterians/test/home/home_popup_menu_test.dart
git commit -m "Add shared home popup menu helper."
```

---

### Task 3: Composer — send clears, mic snackbar, attachment menu

**Files:**
- Modify: `lib/home/views/home_composer_view.dart`
- Modify: `test/home/home_composer_test.dart`

**Interfaces:**
- Consumes: `showHomePopupMenu`, `HomeTokens.snackbar*`, attachment labels `Photo` / `File` / `Camera`
- Produces: send clears `controller` + unfocus; mic/attachment local feedback (no new public API required)

- [x] **Step 1: Write the failing tests**

Append to `test/home/home_composer_test.dart`:

```dart
  testWidgets('send clears draft and restores mic', (tester) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeComposerView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Send'), findsOneWidget);
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(controller.text, isEmpty);
    expect(find.byTooltip('Voice input'), findsOneWidget);
    expect(find.byTooltip('Send'), findsNothing);
  });

  testWidgets('mic shows coming-soon snackbar', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeComposerView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Voice input'));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.snackbarVoiceSoon), findsOneWidget);
  });

  testWidgets('attachment menu offers Photo File Camera', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeComposerView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Add attachment'));
    await tester.pumpAndSettle();

    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.snackbarAttachment('File')), findsOneWidget);
  });
```

Ensure imports include `home_tokens` via `package:opencore_flutterians/home/home.dart` (already exported).

- [x] **Step 2: Run tests to verify they fail**

Run: `cd opencore_flutterians && flutter test test/home/home_composer_test.dart`

Expected: FAIL — send does not clear; snackbars/menus missing.

- [x] **Step 3: Implement composer handlers**

In `home_composer_view.dart`:

1. Import `flutter/services.dart` (already), `home_popup_menu.dart`, keep `home_tokens`.
2. Replace attachment `onPressed: () {}` with:

```dart
onPressed: () async {
  final choice = await showHomePopupMenu<String>(
    context: context,
    entries: const [
      PopupMenuItem(value: 'Photo', child: Text('Photo')),
      PopupMenuItem(value: 'File', child: Text('File')),
      PopupMenuItem(value: 'Camera', child: Text('Camera')),
    ],
  );
  if (!context.mounted || choice == null) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(HomeTokens.snackbarAttachment(choice))));
},
```

3. Replace send `onPressed` with:

```dart
onPressed: () {
  HapticFeedback.lightImpact();
  widget.controller.clear();
  _focusNode.unfocus();
},
```

4. Replace mic `onPressed: () {}` with:

```dart
onPressed: () {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text(HomeTokens.snackbarVoiceSoon)));
},
```

- [x] **Step 4: Run tests to verify they pass**

Run: `cd opencore_flutterians && flutter test test/home/home_composer_test.dart`

Expected: all PASS.

- [x] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/views/home_composer_view.dart \
  opencore_flutterians/test/home/home_composer_test.dart
git commit -m "Wire composer attach, mic, and send local actions."
```

---

### Task 4: Model rail — pressable chips + menus

**Files:**
- Modify: `lib/home/views/home_model_rail.dart`
- Create: `test/home/home_model_rail_test.dart`
- Modify: `lib/home/views/home_view.dart` (pass model/speed state into rail — do minimal wiring here if rail API changes; finish HomeView chrome in Task 5)

**Interfaces:**
- Produces:

```dart
class HomeModelRail extends StatelessWidget {
  const HomeModelRail({
    super.key,
    required this.modelLabel,
    required this.speedLabel,
    required this.onModelSelected,
    required this.onSpeedSelected,
  });

  final String modelLabel;
  final String speedLabel;
  final ValueChanged<String> onModelSelected;
  final ValueChanged<String> onSpeedSelected;
}
```

- Consumes: `showHomePopupMenu`, `HomeTokens.stubModelTitles`, `stubSpeedTitles`, `snackbarContext`

- [x] **Step 1: Write the failing test**

Create `test/home/home_model_rail_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_model_rail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selecting a model updates via callback', (tester) async {
    var model = HomeTokens.modelTitle;
    var speed = HomeTokens.speedTitle;

    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return HomeModelRail(
                modelLabel: model,
                speedLabel: speed,
                onModelSelected: (v) => setState(() => model = v),
                onSpeedSelected: (v) => setState(() => speed = v),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('Gemma 4 26B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OpenCore: Local 7B'));
    await tester.pumpAndSettle();

    expect(find.text('OpenCore: Local 7B'), findsOneWidget);

    await tester.tap(find.text('Max'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fast'));
    await tester.pumpAndSettle();

    expect(find.text('Fast'), findsOneWidget);
  });

  testWidgets('context badge shows snackbar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: Scaffold(
          body: HomeModelRail(
            modelLabel: HomeTokens.modelTitle,
            speedLabel: HomeTokens.speedTitle,
            onModelSelected: (_) {},
            onSpeedSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(HomeTokens.contextLabel));
    await tester.pumpAndSettle();

    expect(find.text(HomeTokens.snackbarContext), findsOneWidget);
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_model_rail_test.dart`

Expected: FAIL — constructor / menus missing.

- [x] **Step 3: Rewrite `HomeModelRail`**

Replace `home_model_rail.dart` with a pressable rail that:

- Takes `modelLabel`, `speedLabel`, `onModelSelected`, `onSpeedSelected`.
- Wraps each chip and the context badge in `HomePressable`.
- Model tap → `showHomePopupMenu` over `HomeTokens.stubModelTitles`; on value call `onModelSelected`.
- Speed tap → same for `stubSpeedTitles` → `onSpeedSelected`.
- Context tap → snackbar `HomeTokens.snackbarContext` + `HapticFeedback.selectionClick()`.
- Keep existing visual styles (raised fill, border, 12px secondary text).
- Use `Builder` around each pressable so `showHomePopupMenu(context:)` anchors to that chip.

Also update `home_view.dart` temporarily so the project analyzes:

```dart
HomeModelRail(
  modelLabel: HomeTokens.modelTitle,
  speedLabel: HomeTokens.speedTitle,
  onModelSelected: (_) {},
  onSpeedSelected: (_) {},
),
```

(Task 5 replaces the stubs with real state.)

Update `test/home/home_composer_test.dart` first test if it pumps `HomeView` and expects rail text — it should still find Gemma / Max / `0` with defaults.

- [x] **Step 4: Run tests**

Run:

```bash
cd opencore_flutterians && flutter test test/home/home_model_rail_test.dart test/home/home_composer_test.dart
```

Expected: PASS.

- [x] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/views/home_model_rail.dart \
  opencore_flutterians/lib/home/views/home_view.dart \
  opencore_flutterians/test/home/home_model_rail_test.dart \
  opencore_flutterians/test/home/home_composer_test.dart
git commit -m "Make model rail chips selectable via popup menus."
```

---

### Task 5: HomeView — menu chats, new chat, model/speed state

**Files:**
- Modify: `lib/home/views/home_view.dart`
- Create: `test/home/home_view_interactions_test.dart`

**Interfaces:**
- Produces: local `_modelLabel` / `_speedLabel` owned by `HomeView`; menu uses `HomeTokens.stubChatTitles`; add clears draft + snackbar

- [x] **Step 1: Write the failing test**

Create `test/home/home_view_interactions_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('add clears draft and shows new-chat snackbar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView(orbActive: false)),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'keep me');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('keep me'), findsNothing);
    expect(find.text(HomeTokens.snackbarNewChat), findsOneWidget);
  });

  testWidgets('menu shows stub chat titles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView(orbActive: false)),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    for (final title in HomeTokens.stubChatTitles) {
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('model selection from rail updates chip label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HomeTheme.light(),
        home: const Scaffold(body: HomeView(orbActive: false)),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('Gemma 4 26B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Google: Gemma 4 9B'));
    await tester.pumpAndSettle();

    expect(find.text('Google: Gemma 4 9B'), findsOneWidget);
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `cd opencore_flutterians && flutter test test/home/home_view_interactions_test.dart`

Expected: FAIL — menu empty / add no-op / state not wired.

- [x] **Step 3: Implement `HomeView` wiring**

In `_HomeViewState`:

```dart
  var _modelLabel = HomeTokens.modelTitle;
  var _speedLabel = HomeTokens.speedTitle;
```

Menu button — wrap icon in `Builder`, on press:

```dart
onPressed: () async {
  final choice = await showHomePopupMenu<String>(
    context: context,
    entries: [
      for (final title in HomeTokens.stubChatTitles)
        PopupMenuItem(value: title, child: Text(title)),
    ],
  );
  if (choice == null) return;
  HapticFeedback.lightImpact();
},
```

Add (+) button:

```dart
onPressed: () {
  HapticFeedback.lightImpact();
  _draft.clear();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text(HomeTokens.snackbarNewChat)));
},
```

Note: top bar has two `Icons.add` potential collisions with composer — prefer `find.byIcon` only works if one; in HomeView test the composer also has add. Prefer giving the top-bar add a `Key('homeNewChatButton')` and menu `Key('homeMenuButton')`, and tap by key in tests. Update Step 1 tests to use those keys if icon collision appears.

Wire rail:

```dart
HomeModelRail(
  modelLabel: _modelLabel,
  speedLabel: _speedLabel,
  onModelSelected: (v) => setState(() => _modelLabel = v),
  onSpeedSelected: (v) => setState(() => _speedLabel = v),
),
```

Import `home_popup_menu.dart` and `services.dart` for haptics.

- [x] **Step 4: Run tests**

Run:

```bash
cd opencore_flutterians && flutter test \
  test/home/home_view_interactions_test.dart \
  test/home/home_composer_test.dart \
  test/home/home_model_rail_test.dart
```

Expected: PASS. If top-bar add collides with composer add, fix tests to use keys as noted.

- [x] **Step 5: Commit**

```bash
git add opencore_flutterians/lib/home/views/home_view.dart \
  opencore_flutterians/test/home/home_view_interactions_test.dart
git commit -m "Wire home menu, new chat, and model/speed state."
```

---

### Task 6: Tab shell — sliding indicator, cross-fade, haptic

**Files:**
- Modify: `lib/home/views/home_tab_shell.dart`
- Modify: `test/home/home_tab_shell_test.dart`

**Interfaces:**
- Consumes: `HomeTokens.durationTab`, `easeOut`, `HomePressable`, `HapticFeedback.selectionClick`
- Produces: same public `HomeTabShell` API; internal sliding pill + fade

- [x] **Step 1: Extend failing/updated tests**

Update `test/home/home_tab_shell_test.dart` to:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/home/home.dart';
import 'package:opencore_flutterians/home/views/home_tab_shell.dart';
import 'package:opencore_flutterians/home/views/home_placeholder_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('tapping Settings shows placeholder and keeps bar pinned',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    expect(find.byKey(const Key('homeStickyTabBar')), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byType(HomeTabShell), findsOneWidget);
    expect(find.text('Settings'), findsAtLeastNWidgets(2));
  });

  testWidgets('tab change under reduced motion still switches page',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: HomeTheme.light(),
          home: const HomeTabShell(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('About'));
    await tester.pump();

    expect(find.byType(HomePlaceholderPage), findsWidgets);
    expect(find.text('About'), findsAtLeastNWidgets(2));
  });

  testWidgets('retapping active Home tab does not throw', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: HomeTheme.light(), home: const HomeTabShell()),
    );
    await tester.pump();

    await tester.tap(find.text('Home').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
  });
}
```

- [x] **Step 2: Run tests (baseline)**

Run: `cd opencore_flutterians && flutter test test/home/home_tab_shell_test.dart`

Expected: existing behavior may already pass; implement polish next regardless.

- [x] **Step 3: Implement polished tab shell**

Rewrite body + bar in `home_tab_shell.dart` with this structure:

1. **Index change helper:**

```dart
void _select(int i) {
  if (i == _index) return;
  HapticFeedback.selectionClick();
  setState(() => _index = i);
}
```

2. **Page host** — keep all pages mounted (orb lifecycle). Prefer a `Stack` of pages with `IgnorePointer` + `AnimatedOpacity` for the active index, **or** keep `IndexedStack` and wrap with a short opacity pulse. Spec requires soft cross-fade **and** Home stays alive:

```dart
Widget _buildPages(bool reduceMotion) {
  final pages = [
    HomeView(orbActive: _index == 0),
    const HomePlaceholderPage(title: 'Settings'),
    const HomePlaceholderPage(title: 'About'),
  ];

  if (reduceMotion) {
    return IndexedStack(index: _index, children: pages);
  }

  return Stack(
    fit: StackFit.expand,
    children: [
      for (var i = 0; i < pages.length; i++)
        IgnorePointer(
          ignoring: i != _index,
          child: AnimatedOpacity(
            opacity: i == _index ? 1 : 0,
            duration: HomeTokens.durationTab,
            curve: HomeTokens.easeOut,
            child: pages[i],
          ),
        ),
    ],
  );
}
```

Important: building `HomeView(orbActive: _index == 0)` inside the loop each build is fine; do **not** dispose Home when leaving the tab.

3. **Sliding indicator tab bar** — replace per-item fill with a track `Stack`:

```dart
child: LayoutBuilder(
  builder: (context, constraints) {
    final tabWidth = constraints.maxWidth / _tabs.length;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reduceMotion ? Duration.zero : HomeTokens.durationTab;

    return SizedBox(
      height: /* intrinsic via column */,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: duration,
            curve: HomeTokens.easeOut,
            left: tabWidth * _index,
            width: tabWidth,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.tabActiveFill,
                borderRadius:
                    BorderRadius.circular(HomeTokens.radiusTabActive),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _TabBarItem(
                  spec: _tabs[i],
                  active: _index == i,
                  onTap: () => _select(i),
                ),
            ],
          ),
        ],
      ),
    );
  },
),
```

4. **`_TabBarItem`** — remove its own `AnimatedContainer` fill (transparent). Animate icon/label color with `AnimatedDefaultTextStyle` / `IconTheme` or explicit `Color.lerp` via `TweenAnimationBuilder<Color?>` keyed on `active`. Simplest acceptable approach:

```dart
AnimatedDefaultTextStyle(
  duration: HomeTokens.durationTab,
  curve: HomeTokens.easeOut,
  style: TextStyle(
    fontSize: 11,
    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
    color: active ? colors.textPrimary : colors.textSecondary,
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(spec.icon, size: 22, color: /* same active colors */),
      const SizedBox(height: 2),
      Text(spec.label, maxLines: 1, overflow: TextOverflow.ellipsis),
    ],
  ),
)
```

For icon color, wrap with `IconTheme` + `AnimatedDefaultTextStyle` does not animate Icon — use:

```dart
TweenAnimationBuilder<Color?>(
  duration: reduceMotion ? Duration.zero : HomeTokens.durationTab,
  curve: HomeTokens.easeOut,
  tween: ColorTween(
    end: active ? colors.textPrimary : colors.textSecondary,
  ),
  builder: (context, color, _) { ... },
)
```

5. Import `package:flutter/services.dart` for haptics.

- [x] **Step 4: Run tests**

Run:

```bash
cd opencore_flutterians && flutter test test/home/home_tab_shell_test.dart
```

Expected: PASS.

- [x] **Step 5: Full home regression**

Run:

```bash
cd opencore_flutterians && flutter test test/home/
```

Expected: all home tests PASS.

- [x] **Step 6: Commit**

```bash
git add opencore_flutterians/lib/home/views/home_tab_shell.dart \
  opencore_flutterians/test/home/home_tab_shell_test.dart
git commit -m "Polish home tab indicator and page cross-fade."
```

---

## Self-review (plan vs spec)

| Spec requirement | Task |
| --- | --- |
| Menu → popup stub chats | Task 5 |
| Add → clear draft + “New chat” | Task 5 |
| Attachment → Photo/File/Camera popup + snackbar | Task 3 |
| Mic → coming soon snackbar | Task 3 |
| Send → clear + unfocus + haptic | Task 3 |
| Model/speed chips → popup + label update | Tasks 4–5 |
| Context badge → snackbar | Task 4 |
| Sliding tab indicator | Task 6 |
| Page cross-fade; Home stays alive | Task 6 |
| Reduced motion snaps | Task 6 |
| Re-tap active no-op | Task 6 `_select` |
| No bottom sheets | All tasks use `showHomePopupMenu` |
| `HomePressable` on new controls | Tasks 4–6 |
| Stub catalogs in tokens | Task 1 |

No TBD/placeholder steps remain after this review.

## AC / TP tracking (post-implementation)

Mirrors [design success criteria + testing](../specs/2026-07-21-home-local-interactions-design.md) and PR #5.

### Acceptance criteria

- [x] No home chrome control that looks tappable has an empty no-op (except re-tapping the already-active tab)
- [x] Model and speed selections are visible on the rail after choosing from a popup menu
- [x] Tab changes show a sliding indicator + short page cross-fade (instant under reduced motion)
- [x] Existing home visual tokens and orb lifecycle behavior remain intact

### Test plan

- [x] `flutter test test/home/` (CI Analyze & test green)
- [x] Menu → stub chat titles popup (not a bottom sheet)
- [x] Top-bar + → draft clears + “New chat” snackbar
- [x] Composer: attach / mic / send local actions
- [x] Model/speed chip labels via popup; context badge snackbar
- [x] Tab switch: sliding pill + cross-fade; re-tap active is a no-op
- [x] Reduced motion: page switch without cross-fade; snapped indicator
- [x] Manual: tap every control once; Home ↔ Settings ↔ About; verify orb pauses off Home
