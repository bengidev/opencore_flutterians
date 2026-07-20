# Home Welcome Shell & Particle Orb — Design Spec

**Date:** 2026-07-20  
**Status:** Approved for planning  
**Source reference:** `opencore_swifters` `HomeParticleOrbView` / `HomeWelcomeView` / `HomeView` welcome state  
**Visual reference:** Desktop screenshot of iOS home welcome GUI

## Goal

Replicate the Swift home **welcome shell** in Flutter as a new `home` module: top bar, animated particle hero orb, and greeting copy. Wire it as the post-onboarding home screen. Preserve orb visual complexity without frame-time spikes, using progressive core→outer reveal so first paint feels snappy. Apply the same viewport-driven responsiveness to **onboarding** layout. Polish motion per Emil Kowalski design-engineering rules.

## Non-goals

- Composer chrome, bottom tab bar, side panel, chat transcript, or API/model selection
- Functional sidebar / new-chat / speech wiring beyond visual top-bar affordances
- Redesigning onboarding visuals or inventing new decorative onboarding motion

## Decisions locked

| Topic | Choice |
| --- | --- |
| Scope | Welcome shell only (option A) |
| Integration | Replace `OpenCoreHomePage` as `OnboardingFacade` home |
| Orb architecture | Pre-rasterized layered bitmaps + transform/opacity animation (Swift parity) |
| First-load UX | Progressive stage-in: core first, then mid/outer/orbit layers |
| Naming | `lib/home/`; orb package `lib/home/home_orb/`; types prefixed `Home` / `HomeOrb` |
| Responsiveness | Viewport metrics for home **and** onboarding |
| Motion polish | Emil design-eng: ease-out enters, transform+opacity only, no `scale(0)`, press ~0.97 |

## Architecture

### Module layout

```
lib/home/
  home.dart                         # public exports
  home_page.dart                    # post-onboarding root scaffold
  home_top_bar.dart                 # menu + new chat icons (visual)
  home_welcome_view.dart            # centered orb + greeting
  home_welcome_layout_metrics.dart  # viewport → spacers / orb size / type scale
  home_tokens.dart
  home_theme.dart
  home_orb/
    home_orb_view.dart              # widget + animation / stage orchestration
    home_orb_metrics.dart           # canvas size, fields, glyph ramp (Swift parity)
    home_orb_math.dart              # noise / gaussian helpers
    home_orb_layout.dart            # deterministic particle seeds
    home_orb_renderer.dart          # bake ui.Image layers / sprites
    home_orb_asset_pack.dart        # descriptors + cache key (tint/accent)
    home_orb_stage.dart             # progressive reveal stages
```

### Screen composition

1. `MaterialApp` → `OnboardingFacade().buildRoot(home: const HomePage())`
2. `HomePage`: light surface scaffold → `HomeTopBar` → `HomeWelcomeView`
3. `HomeWelcomeView`: vertical centering via `HomeWelcomeLayoutMetrics`, then `HomeOrbView` + monospaced greeting + encryption sublines
4. No composer / bottom nav in this iteration — empty bottom breathing room only

### Orb rendering model (performance)

Mirror Swift `HomeParticleOrbView`:

1. **Bake once** (deterministic layout → raster `ui.Image`s):
   - Outer dot layers, pulse dots, core block glyph layers (×3 prominence), dust
   - Shared outer-orbit-dot sprite and per-spark glyph sprites
2. **Animate cheaply** each frame: only layer `Transform` (position / rotation / scale) and opacity — never redraw hundreds of particles in `CustomPainter` every tick
3. **Cache** asset pack by tint + accent colors; skip rebake on revisit when colors match
4. **Lifecycle:** pause continuous motion when route inactive or reduce-motion / `disableAnimations` is on; still allow a static (or opacity-only) progressive reveal

### Progressive reveal (perceived performance)

Stages expand outward so users never wait on a blank hero while baking:

| Stage | Content | Behavior |
| --- | --- | --- |
| 0 | First dense core-block layer | Show as soon as ready; enter opacity + scale from ~0.95 |
| 1 | Remaining core block layers | Fade/scale in with short stagger |
| 2 | Pulse + dust mid layers | Same |
| 3 | Outer haze / outer dots | Same |
| 4 | Orbit dots + sparks; enable full drift/orbit loops | Same |

Later stages generate in the background (isolate and/or chunked microtasks). Stage transitions use **ease-out**, ~180–250ms, stagger ~40–70ms. Continuous orbit/drift uses ease-in-out / paced loops and runs only after stage 4 (or immediately in reduced form if already fully baked from cache).

### Responsiveness

#### Home — `HomeWelcomeLayoutMetrics`

Resolved from viewport height (and width for horizontal padding / type fit):

- Orb height: standard ~260 → compact ~200 when the hero cannot fit with min edge spacing
- Horizontal padding and top-bar insets scale with width
- Greeting: monospaced semibold; single line with min scale / fit so it does not overflow on narrow devices
- Sublines: secondary grey; spacing tracks orb size
- Top-bar icon hit targets ≥ 44 logical px

Orb canvas keeps Swift aspect (~360×240 logical); scales uniformly inside its allocated box.

#### Onboarding — `OnboardingLayoutMetrics` (layout pass only)

Thread viewport-driven metrics through existing chrome that currently uses fixed sizes, including:

- `OnboardingHeroFrame` fixed height `280` → compact / standard / roomy
- Page shell padding `24` and vertical gaps
- Feature header / nav spacing (keep ≥44 tap targets; tighten on short screens)
- Heroes that assume fixed boxes (e.g. brand orbit `300`) size from metrics

Same look and existing motion tokens; no visual redesign.

### Motion polish (Emil design-eng)

| Surface | Rule |
| --- | --- |
| Orb stage-in | Purpose: hide bake latency + avoid jarring pop; never `scale(0)` — start ~0.95 + opacity |
| Stage timing | Ease-out, under ~300ms per stage; short stagger |
| Continuous orbit | Transform + opacity only; pause off-screen / reduce-motion |
| Top-bar press | Scale ~0.97, ~160ms ease-out |
| Greeting appear | Soft opacity (+ tiny Y) after core visible; does not compete with orb |
| Frequency | Welcome orb is rare/first-view → progressive delight OK |
| Onboarding | Keep existing `easeOut` / `easeInOut` / short UI durations; responsive layout only |

### Theming

Light monochrome welcome matching the screenshot (white surface, near-black primary text, grey secondary). Prefer home tokens aligned with OpenCore light palette; do not introduce purple Material seed styling on this screen.

### Error / edge cases

- Bake failure: show a minimal static core placeholder (no crash); log in debug
- Color theme change: invalidate cache and rebake; progressive reveal may restart from core
- Very small viewports: compact metrics; greeting still one line via fit/scale
- Reduce-motion: no orbit/drift; stages may snap or opacity-fade only

## Testing

- Widget: `HomePage` shows top bar + greeting copy; orb mounts without throw
- Widget: progressive stages advance (or complete from cache) without overflow
- Layout: pump home and onboarding at narrow (~320×568) and large phone sizes — no overflow / clipped primary CTAs
- Optional later: golden for static orb resting state (not required for first plan)

## Success criteria

1. Post-onboarding destination is `HomePage` welcome shell
2. Orb visually reads as the Swift particle orb (dense glyph core, feathered outer dust, subtle motion)
3. First paint shows core quickly; outer complexity streams in without a long blank wait
4. No sustained jank from per-particle painting; animation stays on transform/opacity of baked layers
5. Home and onboarding adapt cleanly across small and large phone viewports
6. Motion follows Emil polish rules above

## Implementation notes for planning

- Port layout math / metrics constants from Swift `HomeParticleOrbView` private types for visual parity
- Prefer splitting `home_orb` files so no single file becomes an unmaintainable 1k+ line dump of bake + UI
- Keep public API small: `HomePage`, `HomeOrbView`, barrel `home.dart`
- TDD for metrics resolution and stage ordering where practical; visual bake may be covered by smoke widget tests
