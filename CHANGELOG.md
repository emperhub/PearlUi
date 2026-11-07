# Changelog

## Lucide catalog — 2026-11-07

- Bundled all 2,029 canonical icons and 296 upstream aliases at the existing pinned Lucide revision.
- Added frozen PearlUI.Icons / PearlUI.IconAliases catalogs, normalized names, and accurate fallback attributes; existing tab Icon use remains compatible.
- Decode/cache geometry only on use, avoiding thousands of unused shape tables and native UI instances.
- Extended the offline SVG compiler for compact arc flags, smooth curves, ellipses, lines, polylines and polygons; retained upstream license notices.

## Maintenance — 2026-11-07

- Fixed long application titles overflowing the Dock restore button: one-line ellipsis, 10px inner padding and clipping keep text inside the 142px button.
- Dock restore text and navigation icons now use the readable Text role, including dark themes and custom accents.
- Revalidated the 16-check Dock suite and visually checked a long-title, seven-tab Forest dock. Existing bot state and settings are preserved by the live repair.

## 0.8.0 — 2026-11-07

- Expanded the demo to 7 tabs, 14 sections and 102 initial controls with Components, Window lab and API tools.
- Added ten live control examples and an inspector for values, serialization, callbacks, silent updates, disabled/hidden/renamed states, destruction/recreation, dynamic dropdowns and color alpha/HSV.
- Added window/dock/panel/navigation controls and an isolated sample window for lifecycle, resets, memory persistence, configs, observers and JSON roundtrips.
- Added visible action results and recent output, synchronized parameter controls, and cleanup of sample windows when the demo is destroyed.
- Verified visible coverage for all 76 public API methods. The new showcase suite passes 45 targeted checks. The core implementation is unchanged from 0.7.0 apart from its version identifier; the prior 424-check baseline is retained separately.

## 0.7.0 — 2026-11-07

- Added a config manager with a searchable saved-config picker, create/update/load/rename/delete, active/edited status and an auto-load selection.
- Config lists, last working setup, active selection and auto-load are stored per game scope. Legacy saved profiles migrate into the current game without discarding the existing setup.
- Added versioned single-config JSON import/export through a scrollable modal editor, inline validation, readonly exports and explicit overwrite/delete confirmations.
- Added transient controls (Persist=false), silent dropdown option refresh, config-change listeners, case-insensitive duplicate checks and capacity validation before mutation.
- Preserved the existing file/DataStore adapter envelope and backup behavior; new game banks are stored in the same settings document.
- Passed 424 checks across fourteen suites, including 45 config checks. Actual file restoration and separate game scopes were verified. Existing user configs were preserved.

## 0.6.0 — 2026-11-07

- Added adapter-based persistent settings with debounced auto-save, manual save/reload, explicit status, acknowledged writes, retry and shutdown flush.
- Persist current values, appearance, layout and named profiles. Failed initial loads block overwriting existing data; edits made during a yielding save remain pending.
- Added an optional account-scoped local-file adapter with verified temporary writes and backup recovery. Added a server DataStore adapter/client module to the generated Studio demo and Rojo project.
- Added captured defaults, Appearance/Controls/Layout/All reset scopes and a reusable confirmation dialog with cancellation and one-shot completion.
- Added ResetAccent and an explicit Theme/Custom accent mode that survives profiles; the demo color picker follows the built-in theme accent when that mode is active.
- Added demo actions for Use theme color, scoped resets, Save now and Reload, with auto-save status.
- Passed 379 checks in thirteen suites. Verified real file restoration after a Roblox client/session change. DataStore request handling was tested against a mock backend; a published server was not used.

## 0.5.1 — 2026-11-07

- Added Forest, a dark green palette with near-black evergreen backgrounds, layered green cards, soft light text and a green default accent.
- Forest is available through GetThemes and the demo selector, and round-trips through profiles.
- Passed 316 checks across ten suites, including 59 theme checks with Forest surface, contrast and profile coverage.

## 0.5.0 — 2026-11-07

- Added six complete palettes: Midnight, Graphite, Lavender, Rose, Matcha and Ocean, alongside Light and Dark.
- Added PearlUI.GetThemes(), which returns a defensive, ordered list used by the demo theme selector.
- All palette roles update window/sidebar, controls, floating panels, dock, popup menus and notification surfaces. Explicit custom accents remain selected across theme changes.
- New themes serialize through existing profiles and preserve compatibility with Light/Dark profiles.
- Passed 310 runtime checks across ten suites, including 53 theme checks for selection, surface repainting, text contrast, profile restoration and accent preservation.

## 0.4.3 — 2026-11-07

- Fixed profile/layout restoration cancelling the dock's in-progress theme-color tween, which left a white dock while the selected theme was Dark.
- Added explicit notification previews: Notify({Preview=true}) can show a test toast without changing NotificationsEnabled. The demo Preview button uses this path; ordinary notifications still honor the preference.
- Replaced overflowing detached-panel placeholder text with separate truncated title/action lines. Open detached panel now reveals/raises its panel instead of docking it.
- Added Section:Reveal() for restoring and focusing a detached panel, plus title/body truncation for notification cards.
- Passed 257 runtime checks across nine suites, including 20 targeted notification, theme-restoration and placeholder checks.

## 0.4.2 — 2026-11-07

- Fixed detached right-column sections retaining their horizontal page offset, leaving only a clipped strip visible.
- Fixed lower sections retaining their vertical page offset inside floating panels.
- Cancel stale section-position tweens and reset the card origin and scroll position when detaching; constrain detached scrolling to the vertical axis.
- Added 23 geometry checks across left/right and upper/lower sections, field containment, docking, search, resize, profile restoration and reopening.
- Passed 237 checks across eight suites in the connected Roblox client. Visually verified the reported Component playground panel with full-width controls.

## 0.4.1 — 2026-11-07

- Fixed invisible sections after docking during entry, tab changes, search, or window hiding.
- Restore canonical transparency when a fade completes, and preserve control/highlight changes made during parent fades.
- Return section content to its original tab synchronously; fade the empty floating shell independently.
- Cascade new floating panels and raise the complete panel on interaction, keeping menus above panel contents.
- Cancel key capture, slider feedback and focused popup editors when their interaction ends or the window changes state.
- Dismiss dropdown/color popups on anchor scrolling; reject opening them from hidden windows or inactive pages.
- Isolate touch pointer ownership, scroll long sidebar navigation, and roll back failed control construction without reserving IDs.
- Recheck late-loaded avatars and continue low-frequency image polling until load or destruction.
- Passed 214 runtime checks, including 40 new lifecycle regressions, and a separate 100-operation randomized transition stress run.

## 0.4.0 — 2026-11-07

- Added two independently stacked section columns with a shared scrolling page.
- Added explicit Left/Right section placement, compact control rows, and a one-column fallback for narrow windows.
- Added `SetColumns` and persisted the column preference in layout documents.
- Replaced the sidebar version footer with the local player's avatar bust, display name and username.
- Added bounded thumbnail retries, loading fallback cleanup, and `RefreshUserProfile`.
- Preserved unrelated animation goals when another property is retargeted.
- Passed 174 runtime checks across layout, controls, profiles, animation, and dock behavior.

## 0.3.0 — 2026-11-07

- Added control-level `SetDisabled`, `SetVisible`, `SetLabel`, `Close`, and `Destroy` APIs.
- Added disabled explanations, native input blocking, owned-handler cleanup, and safe ID reuse.
- Added an HSV Color Picker with alpha, checkerboard previews, HEX/RGB editing, and profile serialization.
- Added searchable single/multiple-selection dropdowns with empty states, Clear/Done, defensive values, and option preservation.
- Added complete window/tab/panel/dock layout export and restoration, included automatically in profiles.
- Preserved support for previous profile documents without layout data.
- Kept color editors open while theme/accent callbacks repaint the UI.
- Added the component playground, favorites, color editor, and layout actions to the demo.
- Passed 141 runtime checks, including asynchronous restore/dock/editor races and scaled viewport geometry.

## 0.2.2 — 2026-11-07

- Moved the mini dock into its own inset-free-from-core-UI layer, flush with the top edge while respecting device cutouts.
- Added automatic left/right edge stowing when a dock drag is released near an edge.
- Added a 22-pixel recovery handle with click-to-reveal and drag-to-pull-out.
- Preserved the stowed side through viewport and visibility changes.
- Added `StowDock(side)` and `RevealDock()`.
- Destroyed both owned ScreenGuis together and cancelled their transitions.
- Passed 50 regression, 17 animation, and 16 edge-dock checks.

## 0.2.1 — 2026-11-07

- Positioned the mini dock at the top center by default.
- Added mouse/touch dragging from the dock surface and its buttons.
- Distinguished clicks from drags with a six-pixel movement threshold.
- Suppressed accidental button activation after a drag.
- Preserved moved dock positions across layout, restore, and minimize actions.
- Clamped draggable surfaces with their anchor points included.
- Passed 50 regression and 17 animation checks.

## 0.2.0 — 2026-11-07

- Added fade/slide transitions for window show/hide, compact mode, tabs, menus, floating panels, and toasts.
- Added animated maximize/restore and programmatic window resizing.
- Added hover/press/focus feedback for controls and title-bar buttons.
- Animated theme/accent colors, opacity, dropdown arrows, and slider values set from code.
- Kept pointer dragging/resizing and slider dragging immediate.
- Added property-aware tween cancellation and stale-callback protection.
- Preserved updated opacity when restoring a hidden window.
- Cancelled active tweens and delayed notification jobs on destruction.
- Passed 41 regression and 17 animation runtime checks.

## 0.1.1 — 2026-11-07

- Removed Interface scale from the demo.
- Added a bottom-right resize grip; text size stays unchanged as the window resizes.
- Added `window:SetSize(width, height)` and a Reset window size demo button.
- Kept scrolling content within the resized window.
- Added an explicit drag listener on the window title.
- Fixed the sidebar covering the lower-left rounded corner.
- Unified window outlines and card/field corner tokens.
- Removed the extra divider below the last visible row of each section.
- Passed 41 runtime checks plus native mouse resize and movement checks.
