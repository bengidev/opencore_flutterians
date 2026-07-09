# Onboarding Feature Design

**Date:** 2026-07-09  
**Project:** OpenCore Flutterians (`opencore_flutterians/`)  
**Status:** Approved for implementation planning

## Goal

Ship a first-run onboarding flow: four feature highlight pages plus one CTA page. Visual language follows the Nothing-inspired design system (monochrome hierarchy, typography-led, mechanical motion). The feature lives as an **internal module** under the Flutter app — not a standalone pub package. Abstractions hide implementations inside the module. Completion is persisted so the user sees the flow once.

## Constraints

- Scope limited to this repository’s Flutter app; no external product references beyond OpenCore copy already in-repo.
- Internal module only (`lib/onboarding/`), not a separate package.
- Naming: module prefix on files and types (`onboarding_*` / `Onboarding*`).
- Design system: Nothing-inspired tokens, dark + light from day one.
- Controls use **rounded rectangle at 6pt radius** (not pills/capsules).
- Existing home remains the post-onboarding destination (current demo home until replaced).

## Architecture

### Module layout

```
opencore_flutterians/lib/onboarding/
  onboarding.dart                      # barrel: public exports only
  onboarding_facade.dart               # app-facing bootstrap API
  onboarding_entry.dart                # root flow widget
  onboarding_flow_controller.dart      # page index + intents
  onboarding_page_model.dart           # page data model
  onboarding_page_catalog.dart         # immutable 5-page catalog
  onboarding_completion_store.dart     # abstract persistence
  onboarding_shared_preferences_store.dart
  onboarding_tokens.dart               # dark + light token maps
  onboarding_theme.dart                # ThemeData bridge
  heroes/
    onboarding_hero_strategy.dart      # strategy interface
    onboarding_pairing_hero.dart
    onboarding_workspace_hero.dart
    onboarding_queue_hero.dart
    onboarding_depth_hero.dart
    onboarding_brand_hero.dart
  widgets/
    onboarding_page_shell.dart
    onboarding_progress_indicator.dart
    onboarding_nav_bar.dart
    onboarding_skip_control.dart
```

### Public surface

App code (`main.dart` / root) may import only:

| Export | Role |
|--------|------|
| `OnboardingFacade` | Bootstrap: resolve completion, build onboarding or defer to app home |
| `OnboardingEntry` | Full 5-page experience widget |

`OnboardingEntry` (or the facade-built subtree) wraps the Nothing dark/light theme internally. Theme helpers are **not** exported from the barrel.

Everything else stays module-private (not exported from the barrel).

### Patterns

| Pattern | Application |
|---------|-------------|
| **Facade** | `OnboardingFacade` is the sole app-facing API |
| **Strategy** | `OnboardingHeroStrategy` — one implementation per page hero/effect |
| **Repository** | `OnboardingCompletionStore` abstracts persistence; prefs impl is internal |
| **Controller** | `OnboardingFlowController` owns index and intent handling; UI dispatches only |
| **Factory** | Catalog + strategy map constructed once at module bootstrap |

### App wiring

1. `main` / root awaits `OnboardingFacade` (or store via facade).
2. If incomplete → show `OnboardingEntry`.
3. If complete → show existing app home.
4. On successful **Enter** → persist → replace route/tree with home.

## Visual system

### Fonts (required)

Load via Google Fonts (or bundled equivalents):

| Role | Family |
|------|--------|
| Display / hero moments | **Doto** |
| Body / UI | **Space Grotesk** |
| Labels / data / captions | **Space Mono** (ALL CAPS for tertiary labels) |

Per screen budget: max 2 families in active use (Grotesk + Mono; Doto only for the one display break), max 3 sizes, max 2 weights.

### Color & modes

- Dark and light are first-class; shared token map with mode variants (OLED black / warm off-white surfaces).
- Hierarchy via gray scale (`display` → `primary` → `secondary` → `disabled`).
- Accent red `#D71921` is an interrupt — at most one accent UI moment per screen (e.g. active progress mark or CTA emphasis).
- No gradients in chrome, no shadows, no blur, no toast popups.

### Shape language

- Buttons, skip control, progress marks, outlined controls: **rounded rectangle, 6pt corner radius**.
- Prefer spacing over dividers; cards only if interaction requires a surface.

### Motion

Mechanical, subtle ease-out (no spring/bounce):

- Page enter: short cross-fade + slight vertical settle.
- Hero strategies: one focused animation when the page becomes active.
- Progress: tick/opacity change on index change.
- Enter: brief press feedback.
- Swipe: PageView-driven with the same settle feel.

## Pages & copy

Five pages. Feature pages use three-layer hierarchy (primary hero break, secondary copy, tertiary chrome). Copy is polished from the product brief while keeping meaning.

### Page 1 — Encrypted pairing

- **Kind:** feature  
- **Hero strategy:** pairing / trust boundary motif (devices + lock cue, tick motion)  
- **Headline:** End-to-end encrypted pairing and chats  
- **Body:** Pair trusted devices, keep local workspace context private, and open AI chats without leaking the conversation boundary.  
- **Chrome:** Continue only; tertiary Skip; step `01 / 04`

### Page 2 — AI workspace

- **Kind:** feature  
- **Hero strategy:** prompt → focused working surface  
- **Headline:** Ask, write, and explore with AI models  
- **Body:** OpenCore turns prompts into a focused working surface for drafting, refactoring, research, and interface decisions.  
- **Chrome:** Back + Next; tertiary Skip; step `02 / 04`

### Page 3 — Prompt queue

- **Kind:** feature  
- **Hero strategy:** queued follow-ups stacking while a turn runs  
- **Headline:** Queue follow-ups while a turn is running  
- **Body:** Keep momentum by lining up the next question, test request, or implementation step before the current model turn finishes.  
- **Chrome:** Back + Next; tertiary Skip; step `03 / 04`

### Page 4 — Thinking depth

- **Kind:** feature  
- **Hero strategy:** segmented depth control (faster / balanced / deeper)  
- **Headline:** Tune how much thinking the AI uses  
- **Body:** Choose faster answers, balanced planning, or deeper reasoning before the model commits compute to the task.  
- **Chrome:** Back + Next; tertiary Skip; step `04 / 04`

### Page 5 — CTA

- **Kind:** cta  
- **Hero strategy:** brand display — **OpenCore** as the primary signal  
- **Headline / brand:** OpenCore  
- **Body:** Your AI-native command center. Deploy specialized agents to handle code, review, test, and ship — all within your existing workflow without context switching.  
- **Chrome:** Enter only (no Skip, no Back button; swipe-left still allowed to return to page 4)

## Navigation & interaction

### Gestures

Finger direction (not content travel):

| Gesture | Effect |
|---------|--------|
| Finger swipe right | Continue / next (no-op on CTA) |
| Finger swipe left | Back (no-op on page 1) |

This is the inverse of Flutter’s default `PageView` drag mapping; implement with a reversed/custom page physics or explicit gesture handling so the controller intents stay authoritative.

### Buttons

| Page | Primary chrome | Tertiary |
|------|----------------|----------|
| 1 | Continue | Skip → CTA |
| 2–4 | Back + Next | Skip → CTA |
| 5 | Enter | — |

### Intents (controller)

| Intent | Effect |
|--------|--------|
| Continue / Next / finger swipe right | `index = min(index + 1, last)` |
| Back / finger swipe left | `index = max(index - 1, 0)` |
| Skip | `index = ctaIndex` |
| Enter | Persist completion; on success navigate to home |

Skip never persists completion. Only Enter does.

## Persistence

- Abstraction: `OnboardingCompletionStore` with `Future<bool> hasCompleted()` and `Future<void> markCompleted()`.
- Implementation: `OnboardingSharedPreferencesStore` using a namespaced key, e.g. `onboarding.completed`.
- Bootstrap read failure → treat as incomplete (show onboarding).
- Enter write failure → stay on CTA; show inline status `[ERROR: COULD NOT SAVE]`; user can retry Enter.
- No toast system.

## Error handling

| Case | Behavior |
|------|----------|
| Prefs read fails at launch | Show onboarding |
| Prefs write fails on Enter | Inline error on CTA; remain on page |
| Invalid index / gesture at bounds | No-op |

## Testing

- **Unit:** `OnboardingFlowController` — next/back/skip/bounds; store mock complete vs incomplete.
- **Widget:** Page 1 Continue-only; pages 2–4 Back+Next+Skip; CTA Enter-only; Skip lands on CTA; Enter triggers store then home callback.
- Facade bootstrap: incomplete → entry; complete → home builder.

## Out of scope

- Replacing the demo home with a real workspace.
- Account / auth / pairing implementation (onboarding is presentational + completion gate only).
- Analytics, remote config, or A/B variants.
- Standalone pub package extraction.

## Success criteria

- First launch shows the 5-page flow; after Enter, subsequent launches go to home.
- Dark and light both render with correct Nothing tokens and 6pt controls.
- Module boundary holds: app imports only the public barrel; implementations stay inside `lib/onboarding/`.
- Motion and per-page heroes make the flow feel alive without violating Nothing anti-patterns (no shadows, gradients-in-chrome, toasts, or springy motion).
