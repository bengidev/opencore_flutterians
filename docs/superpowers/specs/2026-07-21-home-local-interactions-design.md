# Home Local Interactions + Tab Transition Polish — Design Spec

**Date:** 2026-07-21  
**Status:** Approved for planning  
**Branch context:** `feature/home-ui-polish`  
**Depends on:** [2026-07-20-home-welcome-orb-design.md](./2026-07-20-home-welcome-orb-design.md)

## Goal

Make every interaction control on the home shell respond to taps with local UI only (no chat/API/model catalog). Replace empty `onPressed` stubs and non-pressable rail chips with real local feedback. Polish tab switches so the indicator and page body feel intentional without slowing frequent taps.

## Decisions (locked)

| Topic | Choice |
| --- | --- |
| Scope | Local UI interactivity for home chrome + tab transition polish |
| Backend | None — no chat thread, no real model APIs |
| Menus | Popup menus anchored to the control (`showMenu` / `PopupMenuButton`), **not** bottom sheets |
| State | Lightweight `StatefulWidget` / local fields in `HomeView` + `HomeTabShell` (no bloc) |
| Press feedback | Existing `HomePressable` on all newly interactive controls |
| Reduced motion | Skip page cross-fade and use zero-duration indicator motion when `MediaQuery.disableAnimations` is true |

## Per-control behavior

| Control | On tap | Local result |
| --- | --- | --- |
| **Menu** | Popup menu | Stub chats (2–3 titles). Select → dismiss + light haptic. No navigation. |
| **Add (+)** | Immediate | Clear draft if any; snackbar “New chat”; haptic. |
| **Attachment (+)** | Popup menu | Photo / File / Camera → snackbar with choice. |
| **Mic** | Immediate | Snackbar “Voice input coming soon” + selection haptic. |
| **Send** | Immediate (draft non-empty) | Clear draft, unfocus field, light haptic. No message bubble. |
| **Model chip** | Popup menu | 3 stub models; chip label updates to selection. |
| **Speed chip** | Popup menu | Fast / Balanced / Max; chip label updates. |
| **Context badge** | Immediate | Snackbar “Context: 0 tokens” (static). |
| **Tabs** | Existing index change | Polished transition (see below). |

### Shared UI rules

- Wrap previously static rail chips / context badge in `HomePressable`.
- Popup menus use home theme colors and `HomeTokens.radius` — no new card chrome language.
- Snackbars are short, single-line, dismissible; do not stack aggressively.
- Menus dismiss on selection; selecting the already-selected model/speed is a no-op visually (still dismisses).

### Stub catalog (hard-coded)

**Chats (menu):** e.g. “Draft: onboarding copy”, “Refactor home shell”, “Weekend ideas”  

**Models:** keep current default `Google: Gemma 4 26B A4B` plus two stubs (e.g. another Gemma / a second provider label). Labels may truncate on the chip as today.  

**Speeds:** `Fast`, `Balanced`, `Max` (default remains `Max` / `HomeTokens.speedTitle`).

## Tab transition polish

Today: `IndexedStack` hard-cuts pages; only the per-chip fill animates.

| Piece | Behavior |
| --- | --- |
| **Active indicator** | Single sliding pill across the tab track (`AnimatedAlign` or equivalent), ~200ms `HomeTokens.easeOut` |
| **Icon + label** | Color / weight tween with the same duration (not an instant swap) |
| **Page body** | Soft cross-fade between pages (~180–220ms). Keep Home subtree alive so `orbActive` can pause/resume as today |
| **Haptic** | Light selection click on index change |
| **Re-tap active** | No-op — no bounce or replay |
| **Reduced motion** | Instant page swap; indicator snaps |

**Out of scope for tabs:** `PageView` swipe, directional horizontal slide.

## State ownership

```
HomeTabShell
  _index                    // selected tab
  (page cross-fade + sliding indicator)

HomeView
  _draft (TextEditingController)
  _modelLabel               // string, default HomeTokens.modelTitle
  _speedLabel               // string, default HomeTokens.speedTitle
  → HomeComposerView(controller, callbacks for attach/mic/send)
  → HomeModelRail(model, speed, onModel, onSpeed, onContext)
```

- Composer keeps focus/`_hasText` locally; send/clear is driven by parent or an `onSend` callback that clears the shared controller.
- No persistence across app restarts for model/speed selection in this pass.

## Architecture / files touched

Expected touch set (implementation may add small private helpers in the same files):

| File | Change |
| --- | --- |
| `home_view.dart` | Wire menu / add; hold model+speed state; pass callbacks |
| `home_composer_view.dart` | Attachment popup, mic snackbar, send clears + unfocus |
| `home_model_rail.dart` | Pressable chips; model/speed popups; context snackbar |
| `home_tab_shell.dart` | Sliding indicator, icon/label tween, page cross-fade, haptic |
| `home_tokens.dart` | Stub label lists / snackbar copy if useful; optional duration alias |
| Tests | Composer send clears; rail updates label; tab transition still shows correct page |

Prefer a tiny shared helper for `showMenu` styling (position from render box + home colors) over duplicating menu chrome three times — only if duplication appears.

## Testing

- Widget tests: send with text clears field and restores mic tooltip; model/speed selection updates visible chip text; menu/attachment menus can be opened (find items) when practical.
- Existing tab shell test still passes (Settings placeholder visible; sticky bar present). Optionally assert no crash under `disableAnimations: true`.
- Manual: tap every control once; switch tabs Home ↔ Settings ↔ About; verify orb pauses off Home.

## Out of scope

- Real chat list / navigation destinations
- Real attachments, voice, or token counts
- Bottom sheets / modal drawers for these controls
- Building a message transcript above the composer
- Bloc / repository layer for models

## Success criteria

1. No home chrome control that looks tappable has an empty no-op (except re-tapping the already-active tab).
2. Model and speed selections are visible on the rail after choosing from a popup menu.
3. Tab changes show a sliding indicator + short page cross-fade (instant under reduced motion).
4. Existing home visual tokens and orb lifecycle behavior remain intact.
