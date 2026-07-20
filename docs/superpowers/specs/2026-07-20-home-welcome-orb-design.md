# Home Welcome GUI + Particle Orb — Design Spec

**Date:** 2026-07-20  
**Status:** Approved for planning  
**Reference:** [opencore_swifters](https://github.com/bengidev/opencore_swifters) Home feature (`HomeView`, `HomeWelcomeView`, `HomeParticleOrbView`)  
**Visual reference:** Desktop screenshot of iOS home welcome state

## Goal

Replicate the OpenCore Swifters home welcome GUI in Flutter as a new `home` module, with primary fidelity on the center **hero particle orb**. Ship a full visual shell (UI-only). Preserve orb complexity without frame-time spikes by baking particles into layers (Swift’s performance model) plus Flutter-specific optimizations. Wire the module as the real post-onboarding home.

## Decisions (locked)

| Topic | Choice |
| --- | --- |
| Scope | Full visual shell: top bar, orb + greeting, composer, model/speed/context pills, sticky bottom tab bar |
| Backend | None — no chat/API/model catalog |
| Orb fidelity | Near-exact port of Swift bake + animation model, with Flutter optimizations that do not change the look |
| Integration | Replace placeholder `OpenCoreHomePage` via onboarding `home:` wiring |
| Orb naming | `home_orb_*` under `lib/home/home_orb/` |
| Bottom nav | Sticky bottom tab bar (pinned; content insets above it) |
| Motion polish | Emil Kowalski design-engineering guidance for shell interactions |

## Architecture

### Module layout

```
lib/home/
  home.dart                 # public exports
  home_facade.dart          # post-onboarding root builder
  home_tokens.dart          # spacing, radii, typography sizes
  home_theme.dart           # grayscale palette (screenshot match)
  views/
    home_tab_shell.dart     # sticky bottom tab bar + page host
    home_view.dart          # welcome home content
    home_welcome_view.dart  # orb + greeting + encryption copy
    home_composer_view.dart # prompt card chrome
    home_model_rail.dart    # model / Max / context chips
    home_placeholder_page.dart  # Settings & About stubs
  home_orb/
    home_orb_view.dart
    home_orb_baker.dart
    home_orb_metrics.dart
    home_orb_layout.dart
    home_orb_math.dart
    home_orb_layer_pack.dart
    home_orb_animator.dart
```

### Screen composition

```
OnboardingFacade.buildRoot(
  home: HomeFacade().buildRoot(),
)
  → HomeTabShell (sticky bottom bar: Home | Settings | About)
       Home tab → HomeView
         Top bar (menu + plus)
         Welcome column (home_orb + greeting + encryption lines)
         Composer card
         Model rail (model chip, Max, context 0)
       Settings / About → placeholder pages
```

### State (v1)

Lightweight local state only:

- Selected tab index
- Composer focus + draft text (visual)
- Optional local speed/model display strings (static defaults matching screenshot)

No bloc/cubit required for v1. Prefer `StatefulWidget` / small `ValueNotifier`s to avoid over-architecture for UI-only chrome.

## Hero orb (`home_orb`)

### Performance model (non-negotiable)

Do **not** redraw ~1,100 particles every frame.

Port Swift’s approach:

1. **Bake once** (per palette): generate particles with deterministic seed math into **7 raster `ui.Image` layers** plus shared orbit-dot and spark bitmaps.
2. **Animate cheaply forever**: only `transform` (position/rotation/scale) and `opacity` on ~77 nodes (7 layers + ~42 orbit dots + ~28 sparks).

Particle inventory (match Swift counts):

| Layer / set | Count / contents |
| --- | --- |
| Outer dots | 138 + 126 |
| Pulse dots | 86 |
| Core blocks (`░▒▓█`) | 236 + 220 + 158 |
| Orb dust | 132 |
| Outer orbit dots | 42 animated sprites |
| Sparks | 28 animated sprites |
| Raster layers total | 7 images |

Canvas metrics (logical): **360 × 240**; outer field 324×204; core field 156×146; snap grid 3; glyph ramp `░▒▓█`.

### Bake pipeline

- `home_orb_math.dart` — `noise`, `gaussian2D` (port of `ParticleOrbMath`)
- `home_orb_layout.dart` — `makeOuterDots`, `makePulseDots`, `makeOrbDust`, `makeCoreBlocks`, `coreDensity`, orbit/spark seeds (port of `ParticleOrbLayoutFactory`)
- `home_orb_baker.dart` — paint dots/blocks/sparks into `ui.Image` via `PictureRecorder` / `Canvas`
- Bake **off the UI isolate** (`compute` or dedicated isolate); cache pack keyed by tint + accent colors
- Re-bake only when palette colors change

### Animation

- Drift / rotation / scale / opacity keyframe loops matching Swift durations and phase offsets
- Outer orbit dots and sparks follow elliptical orbits with radial pulse
- Animate **only** transform + opacity (GPU-friendly)

### Lifecycle / accessibility

Pause ambient motion when:

- App lifecycle ≠ resumed
- Home tab is not visible
- `MediaQuery.disableAnimations` / reduce-motion preference is set

Under reduce-motion: hold rest poses (opacity/scale/position at rest). Soft opacity settle is allowed; no orbit/drift/rotation.

### Optimizations (look-preserving)

- Bake off main isolate; cache by palette
- `RepaintBoundary` around the orb host
- Pause controllers when offstage / inactive tab
- Avoid rebuilding static shell widgets on orb ticks (orb subtree owns its `AnimatedBuilder`s)
- Prefer pre-decoded images + `RawImage` / layered `Transform` stack over per-frame `CustomPainter` of particles

## Sticky bottom tab bar

- Pinned to the bottom of `HomeTabShell` (not a scroll-away floating overlay)
- Content area uses bottom inset so composer and pills never sit under the bar
- Visual chrome may still use a rounded pill / soft surface matching the screenshot; “sticky” refers to layout behavior
- Tabs: Home (active), Settings, About
- Active indicator: rounded highlight behind icon + label
- Tab change motion ≤ 220ms ease-out; no bounce

## Composer + model rail (visual only)

**Composer**

- Large rounded card
- Placeholder: `Ask anything... @files, $skills, /commands`
- Bottom row: `+` (left), mic + circular send (right)
- Local focus only; send/mic/`+` are no-ops or empty stubs
- Press feedback: scale ~0.97, 140–160ms ease-out

**Model rail**

- Model chip (truncated title, e.g. Google Gemma line from screenshot)
- Speed chip (“Max”)
- Circular context usage `0`
- Taps may no-op or open empty sheets; no real catalog

## Motion polish (Emil guidance)

| Interaction | Spec | Rationale |
| --- | --- | --- |
| Icon / pill press | scale 0.97, ~140–160ms ease-out | Instant feedback |
| Tab selection | active pill morph ≤220ms ease-out | Occasional spatial state |
| Composer focus layout | ≤220ms ease-out | Avoid jarring jump |
| Orb ambient loops | long ease-in-out (Swift timings) | Decorative constant motion; pause under reduce-motion |
| Keyboard / high-frequency toggles | no decorative delay animations | Avoid sluggish feel |

Only animate transform and opacity for shell chrome. Never animate ambient orb via full particle redraw.

## Theming

- Light grayscale palette matching screenshot (white surface, black primary text, medium grey secondary)
- Monospaced greeting headline (~28 semibold)
- Secondary encryption copy ~11 regular, grey
- Tokens live in `home_tokens.dart` / `home_theme.dart`; do not depend on onboarding theme internals

## Welcome layout metrics

Port `HomeWelcomeLayoutMetrics` behavior:

- Standard orb height 260 + padding 28 when viewport allows
- Compact orb height 200 + padding 20 when needed
- Vertically center hero (orb + text block ~66) with min edge spacing 16

## Wiring

Replace:

```dart
home: const OpenCoreHomePage(title: 'OpenCore'),
```

with:

```dart
home: HomeFacade().buildRoot(),
```

Remove or leave unused the counter `OpenCoreHomePage` (prefer delete if nothing references it).

## Testing

- Widget: `HomeFacade` root shows greeting copy and sticky tab bar
- Widget: Settings / About tabs show placeholders
- Orb: bake yields 7 layers + expected orbit/spark counts
- Orb: reduce-motion keeps layers at rest (no orbit controllers running)
- Smoke: post-onboarding path builds home root without throwing

## Out of scope

- Real chat sending / streaming
- Model catalog / provider auth
- Side panel / drawer content
- Speech / vision features
- Dark mode parity (unless trivial via tokens later)
- Functional encryption — copy only

## Success criteria

1. Side-by-side with screenshot: layout, typography hierarchy, and orb silhouette read as the same product.
2. Orb remains complex (glyph core + halo + orbiting sparks/dots) without sustained frame drops on a mid-range device during idle animation.
3. Sticky tab bar stays pinned; switching tabs does not dispose/rebuild the orb bake unnecessarily when returning to Home (cache retained).
4. Reduce-motion disables ambient orb motion.
5. Onboarding completion lands on this home shell.
