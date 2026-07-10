# ASCII + Block Pixel Hero Swarm Design

**Date:** 2026-07-10  
**Project:** OpenCore Flutterians (`opencore_flutterians/`)  
**Status:** Approved for implementation planning  
**Related:** `2026-07-09-onboarding-design.md`

## Goal

Make feature onboarding heroes (pages 01–04) feel alive: mixed shade blocks (`░▒▓█`) and ASCII characters scatter across the hero stage, then assemble into an interactive feature highlight that ambient-loops how the feature behaves. Tap replays the full swarm → assemble → loop sequence. Brand CTA stays simpler and out of this polish pass.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Approach | Shared block-swarm kit + per-hero behavior loops |
| Interaction | Ambient loops by default + tap to replay swarm → assemble |
| Scatter coverage | Full hero stage with soft edge fade (dense center, thinner margins) |
| Scope | Feature heroes only (pairing, workspace, queue, depth); brand unchanged |
| Glyph language | Combine shade blocks **and** ASCII — not blocks alone |
| Queue motif | Chat-style request/response bubbles + queued follow-up; **no** arrow |

## Motion language

### Enter sequence (orchestration)

1. **Scatter** — Mixed `░▒▓█` + ASCII fill the hero stage with soft edge fade so headline/nav stay readable.
2. **Assemble** — Staggered **translate** + **scale in** into feature slots (**continuity transition**: same glyphs become the GUI).
3. **Feature loop** — Ambient motion that mirrors the feature.
4. **Tap** — Restarts enter from 0 (swarm → assemble → loop).

### Glyph mix (swarm + assembled GUI)

| Role | Shade blocks | ASCII accents |
|------|----------------|---------------|
| Muted / structure | `░` `▒` | `-` `.` `:` |
| Primary form | `▓` `█` | `#` `+` `=` |
| Accent / live | `█` | `!` `*` `>` |

Assembled panels, bars, and chat bubbles are built from this mix. Short ASCII labels (`E2E`, `RUNNING…`, `QUEUED`, `FAST` / `BALANCED` / `DEEP`) remain readable anchors.

### Timing

- Enter duration ~900–1100ms: scatter hold → staggered assemble → chrome/labels last.
- Soft edge fade on the swarm cloud.
- After assemble completes, `life` ambient loops run.
- Tap restarts `enter` from 0; ambient resumes when enter completes.

### Reduced motion

If `MediaQuery.disableAnimations` / reduced-motion preference is on:

- Skip scatter.
- Show assembled highlight immediately.
- Keep only a subtle opacity pulse, or static.

## Per-hero feature behavior

| Hero | Assembled highlight | Ambient loop | Feature meaning |
|------|---------------------|--------------|-----------------|
| **Pairing** | Two devices + link + lock | Link **pulse**; lock settles open→secure | Encrypted pairing / trust boundary |
| **Workspace** | Prompt + output surface | Caret blink (**idle**); output lines **float**/breath | Ask / write / explore surface |
| **Queue** | Chat request → response bubbles + queued request (no arrow) | Active response shows live progress; queued request stays muted | Queue follow-ups while a turn runs |
| **Depth** | FAST / BALANCED / DEEP bars | BALANCED grows from left (**transform origin**); selection **pulse** | Tune thinking depth |

### Queue chat vignette (detail)

- User **request** bubble (outgoing).
- Model **response** bubble with live fill / `RUNNING…` state.
- Second **queued** request bubble waiting (muted `░` / `-`).
- Bubble chrome and message body use mixed blocks + ASCII lines.
- Ambient: response fill advances; queued bubble stays muted until tap-replay.

**Brand CTA:** out of scope for this pass — keep current simpler treatment.

## Architecture

### Shared kit (feature heroes)

| Piece | Responsibility |
|-------|----------------|
| `ascii_glyph` | Role → `░▒▓█` + ASCII mix; swarm glyph pool from both |
| `pixel_swarm` | Full-stage scatter, soft edge fade, longer hold, denser particles |
| `PixelHeroAssembly` | Cloud → GUI assemble/crossfade; tap → `enter.forward(from: 0)` |
| `pixel_grid` / bars / labels | Assembled cells use the mixed glyph set |

### Per-hero skins

- **Pairing / Workspace / Depth** — Keep current layouts; wire stronger swarm, ambient loops, tap replay.
- **Queue** — Replace arrow with chat vignette; same shared kit.
- **Brand** — Unchanged; do not apply full-stage swarm kit.

### Motion hooks

Reuse `OnboardingHeroMotion` (`enter` + `life`). Tap only restarts `enter`.

### Module touchpoints

```
lib/onboarding/heroes/pixel/
  ascii_glyph.dart          # mixed glyph mapping + swarm pool
  pixel_swarm.dart          # scatter math, cloud, PixelHeroAssembly + tap
  pixel_grid.dart           # assembled mixed glyphs
  pixel_pattern.dart        # patterns; queue chat motifs as needed
  onboarding_hero_motion.dart

lib/onboarding/heroes/
  onboarding_pairing_hero.dart
  onboarding_workspace_hero.dart
  onboarding_queue_hero.dart    # chat vignette (no arrow)
  onboarding_depth_hero.dart
  onboarding_brand_hero.dart    # no change required for this pass
```

## Success criteria

- Feature heroes (01–04) clearly show mixed `░▒▓█` + ASCII scatter across the stage before forming.
- Assembled GUI feels interactive: ambient loops + tap replay.
- Queue reads as chat request/response + queued follow-up (no arrow).
- Brand unchanged.
- Existing onboarding tests updated and passing; no layout overflow from swarm.

## Out of scope

- Brand CTA swarm polish.
- Drag-to-reorder queue.
- Real product data wiring.
- New onboarding pages or copy changes beyond hero visuals.

## Testing

- Update queue hero / strategy tests for chat layout (no arrow assertions).
- Keep swarm / assembly smoke coverage for feature heroes.
- Verify reduced-motion path does not scatter.
- Guard against RenderFlex / overflow regressions from full-stage scatter (`Clip.none` + Stack positioning as today).
