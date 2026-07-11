---
name: OpenCore Flutterians
description: Nothing-inspired monochrome workbench for developers — typographic hierarchy, tactile 6pt controls, signal red for state only.
colors:
  canvas-black: "#000000"
  surface: "#111111"
  surface-raised: "#1A1A1A"
  border-subtle: "#222222"
  border-visible: "#333333"
  text-disabled: "#666666"
  text-secondary: "#999999"
  text-primary: "#E8E8E8"
  text-display: "#FFFFFF"
  signal-red: "#D71921"
  canvas-light: "#F5F5F5"
  surface-light: "#FFFFFF"
  surface-raised-light: "#F0F0F0"
  border-subtle-light: "#E8E8E8"
  border-visible-light: "#CCCCCC"
  text-disabled-light: "#999999"
  text-secondary-light: "#666666"
  text-primary-light: "#1A1A1A"
  text-display-light: "#000000"
typography:
  display:
    fontFamily: "Doto, Space Grotesk, system-ui, sans-serif"
    fontSize: "48px"
    fontWeight: 400
    lineHeight: 1.05
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Space Grotesk, system-ui, sans-serif"
    fontSize: "24px"
    fontWeight: 400
    lineHeight: 1.2
  body:
    fontFamily: "Space Grotesk, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
  body-secondary:
    fontFamily: "Space Grotesk, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Space Mono, ui-monospace, monospace"
    fontSize: "11px"
    fontWeight: 400
    letterSpacing: "0.08em"
rounded:
  control: "6px"
spacing:
  screen-x: "24px"
  screen-top: "16px"
  screen-bottom: "24px"
  section: "32px"
  group: "12px"
  tight: "8px"
components:
  button-primary:
    backgroundColor: "{colors.text-display}"
    textColor: "{colors.canvas-black}"
    rounded: "{rounded.control}"
    padding: "0 24px"
    height: "48px"
    size: "120px"
  button-primary-pressed:
    backgroundColor: "{colors.text-primary}"
    textColor: "{colors.canvas-black}"
    rounded: "{rounded.control}"
    padding: "0 24px"
    height: "48px"
  button-outlined:
    backgroundColor: "transparent"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.control}"
    padding: "0 24px"
    height: "48px"
  button-text:
    backgroundColor: "transparent"
    textColor: "{colors.text-secondary}"
    typography: "{typography.label}"
    padding: "10px 12px"
  progress-active:
    backgroundColor: "{colors.signal-red}"
    rounded: "{rounded.control}"
    width: "24px"
    height: "8px"
  progress-inactive:
    backgroundColor: "{colors.border-visible}"
    rounded: "{rounded.control}"
    width: "8px"
    height: "8px"
---

# Design System: OpenCore Flutterians

## 1. Overview

**Creative North Star: "The Monochrome Workbench"**

OpenCore's visual system is a developer workbench rendered in near-black monochrome: OLED canvas, stepped neutral surfaces, and typography that carries hierarchy before color ever does. The aesthetic draws from Nothing-inspired industrial craft—structure as ornament, subtractive composition, monospace labels at the edges—while staying inside Flutter's adaptive Material 3 shell on Android and iOS.

Dark mode is the primary expression (onboarding ships dark-first). Light mode mirrors the same tonal ladder with inverted ink. Interactive controls are tactile and precise: 6pt rounded rectangles, 48px touch height, scale-to-0.97 press feedback, and 160ms state transitions. Red (`#D71921`) is an event, not wallpaper—it marks active progress and errors only.

The system explicitly rejects generic chat UIs, SaaS cream-and-gradient marketing surfaces, and over-rounded bubbly consumer chrome. If a screen reads like a chat tab or a landing-page template, it has drifted off-brand.

**Key Characteristics:**

- Monochrome canvas with three-layer typographic hierarchy (display → grotesk body → mono labels)
- Flat surfaces; depth conveyed by tonal steps (`canvas-black` → `surface` → `surface-raised`), never drop shadows
- 6pt control radius on buttons, progress segments, and interactive shells
- Signal red reserved for active state and error feedback
- Tactile press feedback (scale + fill shift) on every primary control
- Developer-native density: 24px screen gutters, tight 8–12px intra-group spacing, wide 32–48px section breaks

## 2. Colors

A near-neutral industrial palette: true black scaffold, two surface steps, two border steps, four text steps, and one accent. Light mode inverts the ladder without changing roles.

### Primary

- **Signal Red** (`#D71921` / oklch(52% 0.21 25)): Active progress indicator fill, error text on CTA screens. Never used as a hero background or decorative gradient.

### Neutral

- **Canvas Black** (`#000000` / oklch(0% 0 0)): Dark-mode scaffold background. OLED-target black.
- **Surface** (`#111111` / oklch(14% 0 0)): Default elevated panel tone in dark mode.
- **Surface Raised** (`#1A1A1A` / oklch(18% 0 0)): Secondary elevation step when a control needs subtle lift without shadow.
- **Border Subtle** (`#222222` / oklch(22% 0 0)): Hairline separators at rest.
- **Border Visible** (`#333333` / oklch(28% 0 0)): Outlined button strokes, inactive progress segments.
- **Text Disabled** (`#666666` / oklch(48% 0 0)): Disabled control fills and muted copy.
- **Text Secondary** (`#999999` / oklch(65% 0 0)): Tertiary labels, skip actions, supporting metadata (Space Mono uppercase).
- **Text Primary** (`#E8E8E8` / oklch(93% 0 0)): Body copy and pressed-state button fills.
- **Text Display** (`#FFFFFF` / oklch(100% 0 0)): Headlines, filled-button backgrounds, high-contrast display type.

### Light mode (mirrored roles)

- **Canvas Light** (`#F5F5F5`), **Surface Light** (`#FFFFFF`), **Surface Raised Light** (`#F0F0F0`), **Border Subtle Light** (`#E8E8E8`), **Border Visible Light** (`#CCCCCC`), **Text Disabled Light** (`#999999`), **Text Secondary Light** (`#666666`), **Text Primary Light** (`#1A1A1A`), **Text Display Light** (`#000000`).

### Named Rules

**The One Signal Rule.** Signal red appears only on active progress segments and error feedback. Its rarity is the point—if red decorates a card, a hero, or a button by default, the palette has collapsed into generic accent spam.

**The Monochrome-First Rule.** Any screen should remain legible in grayscale. Color encodes state, not hierarchy.

## 3. Typography

**Display Font:** Doto (with Space Grotesk fallback)
**Body Font:** Space Grotesk (with system-ui fallback)
**Label Font:** Space Mono (with ui-monospace fallback)

**Character:** Industrial grotesk for reading and headlines; dot-matrix display for hero moments; monospace caps for system labels and button chrome. Three families, three jobs—never a fourth decorative face.

### Hierarchy

- **Display** (400, 48px, line-height 1.05, letter-spacing -0.02em): Hero headlines on onboarding and rare brand moments. Doto only—do not use for UI labels.
- **Headline** (400, 24px, line-height 1.2): Page titles and section headers. Space Grotesk in `text-display` color.
- **Body** (400, 16px, line-height 1.5): Primary reading text. Space Grotesk in `text-primary`.
- **Body Secondary** (400, 14px, line-height 1.5): Supporting descriptions in `text-secondary`.
- **Label** (400, 11px, letter-spacing 0.08em, uppercase): Navigation chrome—CONTINUE, NEXT, BACK, SKIP, ENTER, step counters (`01 / 04`). Space Mono in `text-secondary`, shifting to `text-display` on press.

### Named Rules

**The Three-Layer Rule.** Every screen has exactly three layers of importance: one display-scale primary, grotesk secondary context grouped tight (8–16px), and mono tertiary metadata pushed to edges or bottom. If two elements compete at squint distance, shrink or fade one—never add a border to fake hierarchy.

**The Mono Chrome Rule.** Button labels and step metadata use Space Mono uppercase. Prose headlines and body never use mono.

## 4. Elevation

This system is flat by default. Buttons set `elevation: 0`; cards do not ship ghost borders paired with wide drop shadows. Depth is conveyed exclusively through tonal stepping (`canvas-black` → `surface` → `surface-raised`) and 1px border shifts on outlined controls.

Pressed states add a transient fill shift (`text-display` → `text-primary` on filled buttons; 8% white overlay on outlined/text buttons) plus `scale(0.97)` tactile feedback—never a lifted shadow.

### Named Rules

**The Flat-By-Default Rule.** Shadows are prohibited on resting surfaces. If depth is needed, step the surface tone or add a 1px `border-visible` stroke—pick one, not both.

**The No Ghost Card Rule.** Never pair `border: 1px solid` with soft wide `box-shadow` blur ≥16px on the same element. This is the SaaS ghost-card tell; it is off-brand.

## 5. Components

### Buttons

- **Character:** Tactile, uppercase mono labels, 6pt corners, 48px minimum height.
- **Shape:** 6px border radius (`radiusControl`). Minimum width 120px on filled/outlined variants.
- **Primary (filled):** Background `text-display` (#FFFFFF), label `canvas-black`, Space Mono 11px w500 uppercase. Pressed: background shifts to `text-primary`, scale 0.97, 160ms `cubic-bezier(0.23, 1, 0.32, 1)`. Disabled: `text-disabled` at 35% alpha fill.
- **Outlined:** 1px `border-visible` stroke, transparent fill, `text-primary` label. Pressed: 8% `text-primary` overlay, border thickens to 1.25px and shifts to `text-primary`, label to `text-display`.
- **Text (skip/tertiary):** No border. `text-secondary` label w700; pressed: 6% `text-primary` overlay, label to `text-display`. Padding 10px × 12px.

### Progress Indicator

- **Style:** Horizontal row of 8px-tall segments with 6px radius, 8px gap between segments.
- **Inactive:** 8px wide, `border-visible` fill.
- **Active:** 24px wide, `signal-red` fill. Animates width/color over 200ms `cubic-bezier(0.25, 0.1, 0.25, 1)`.

### Page Shell / Layout

- **Screen padding:** 24px horizontal, 16px top, 24px bottom (inside SafeArea).
- **Feature flow:** Progress row + step label (`01 / 04` mono) → 48px gap → centered hero → 32px gap → headline → 12px gap → body → 32px gap → nav bar.
- **CTA flow:** 64px top breathing room (no progress row) → hero → headline → body → nav.

### Navigation Bar

- **Feature pages:** Skip (text button, right-aligned) → 8px gap → CONTINUE (first page) or BACK + NEXT row (12px gap, equal width).
- **CTA page:** Error label in `signal-red` mono (12px bottom padding when present) → full-width ENTER filled button.
- **Typography:** All nav labels use `label` style (Space Mono 11px uppercase).

### Cards / Containers

- **Default:** Prefer spacing-only grouping. When a container is unavoidable, use `surface` on `canvas-black` with no shadow and no nested cards.
- **Corner style:** 6px if bordered; otherwise square outer sections with internal rounded controls only.

## 6. Do's and Don'ts

### Do:

- **Do** keep the scaffold at true black (`#000000`) in dark mode for OLED depth and Nothing-adjacent contrast.
- **Do** use 6px radius on every interactive control—buttons, progress segments, text-button hit areas.
- **Do** apply scale(0.97) + 160ms ease-out press feedback on all tappable chrome via the tactile shell pattern.
- **Do** reserve Space Mono uppercase for system labels, step counters, and button copy.
- **Do** honor `prefers-reduced-motion` by collapsing animations to instant state changes or crossfades.

### Don't:

- **Don't** ship generic chat-bubble UIs or ChatGPT-clone layouts that treat conversation as the product instead of the task.
- **Don't** use SaaS landing-page aesthetics: cream cards, gradient heroes, eyebrow kickers, or ghost-card shadows.
- **Don't** use over-rounded, bubbly consumer chrome—no 24px+ card radii, no full-pill buttons except tags.
- **Don't** use signal red as a decorative accent on buttons, heroes, or backgrounds—active/error only.
- **Don't** pair 1px borders with wide soft shadows on the same component.
- **Don't** flatten hierarchy by giving every element the same size and weight—squint test must still reveal a primary.
