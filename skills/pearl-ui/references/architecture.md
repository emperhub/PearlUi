# Implementation map and regression invariants

Version 1.0.0. These details guide maintenance; app integrations use public API.

| Source | Responsibility |
|---|---|
| src/PearlUI.luau | Themes, controls, layouts, dock, detached panels, transitions, config manager and adapter lifecycle |
| src/PersistenceClient.luau | Client RemoteFunction adapter and response validation |
| examples/Persistence.server.luau | Per-player DataStore integration, validation, cooldown and acknowledged writes |
| examples/FileStorage.luau | Optional injected/native file functions, temp/backup recovery |
| examples/Demo.client.luau | App bindings, Profiles manager, defaults and durable adapter selection |
| examples/Showcase.luau | Components/Window lab/API tools, transient inspector and isolated sample window |
| tools/build.py | XML, standalone and embedded-source roundtrip checks |
| tools/sync_skill.py | Reviewed API inventory, palette extraction and bundled reference sync |

## Rendering and animation

The complete Lucide catalog is generated from the pinned SVG snapshot by
tools/build_icons.py. Geometry is packed as per-icon JSON strings to stay within
Luau constant/register limits; ICON_CACHE decodes only requested icons. Never
eagerly build the 2,029 icons into GUI instances. Frozen PearlUI.Icons and
PearlUI.IconAliases expose names without exposing mutable geometry. Unknown
names resolve to the existing settings-2 fallback. See Icons.md for regeneration.

Native transparency-property fades retain canonical alpha values. Interrupted
show/hide transitions must settle before reparenting; do not capture a half-faded
alpha as the new baseline. Docking returns the card synchronously and fades the
empty floating shell separately. This prevents disappearing/duplicate content.

`_tween` tracks ownership per object/property. Canceling one property in a grouped
tween must retarget surviving goals and disconnect completion callbacks. A canceled
completion must never apply stale visibility or destroy a restored panel. Geometry
imports stop geometry transitions, preserving independent theme/color transitions.

Detached cards reset their Position and canvas origin to zero in the new parent.
Scrolling is vertical; all descendants move into the floating panel Z layer, with
dropdown/color popups above it. Test detach, re-detach, dock, close/reopen and theme
changes during motion. Changing only the outer shell ZIndex is insufficient.

## Coordinates, input and responsive layout

Main and dock are separate ScreenGuis. Respect inset/scale transforms when turning
pointer coordinates into logical offsets; stow/reveal uses dock coordinates. The
dock starts top-center at y=0 and retains dragged height when stowed left/right.
The recovery handle must remain reachable after viewport changes.

Dock restore titles use a single clipped line with end ellipsis and 10px inner
padding inside the fixed 142px button. Never let long app titles resize over the
navigation viewport. Restore text and dock icons bind to Text rather than Accent,
so a dark custom accent cannot make the controls unreadable.

Only one owned popup, key capture or drag should hold its input interaction.
Hiding, disabling, destroying and switching tabs cancel owned interactions and
release focus. Typing must not trigger keybind actions. Touch and mouse paths need
independent manual verification; mouse-only results do not prove gamepad support.

Responsive mobile mode fills the safe viewport with a 56px navigation rail and
readable text instead of scaling down the 900px desktop window. It preserves the
desktop size/position. Focus targets are registered explicitly, scoped to this
window, modal or popup, and released on hide/disable/destroy. Deferred recovery
may only claim an empty selection; it must not steal a newer popup focus.

Two columns activate at content width >=580 logical pixels; compact rows below
460. Column gap 14, card gap 16. CanvasSize is managed explicitly; do not mix an
automatic canvas policy into one detached layout without checking scroll bounds.

## Identity, persistence and validation

Control IDs survive label edits; destroyed controls release IDs. Constructor
validation must roll back any reserved ID/listeners after an invalid control.
Transient showcase/config-manager inputs use Persist=false and must not dirty a
named config. Generic table values return copies, not internal mutable state.

Profile Version=1 contains Values, Appearance, Layout. Appearance includes Theme,
Accent, AccentMode (Theme/Custom), Scale, Opacity. Legacy missing AccentMode uses
the old saved custom-color meaning. SetTheme preserves a custom override; ResetAccent
removes it. Keep the UI picker synchronized silently when code changes the accent.

Settings retain backward-compatible Current/Profiles fields, plus Configurations
Version=1 and Banks keyed by scope; each bank has Profiles, Current, Active, AutoLoad.
Legacy profiles migrate into the current bank. Validate all known values and layout
before mutation. Reject nonfinite numbers, invalid UTF-8, duplicate options, malformed
color data and oversized JSON at boundaries. Never store Instance/Enum/Color3 directly
in settings JSON. Failed initial load blocks saves to protect existing settings.

Auto-save records working state/banks, not a replacement of the named snapshot.
ImportConfig stores a validated copy without applying it. Selection does not load.
Reset applies the captured baseline and leaves named configs intact. Delete clears
active/auto-load references without resetting current settings. Follow Configs.md
for name/size/capacity limits and user-facing confirmations.

The red titlebar button (including its mobile hit target) opens a close confirmation.
Cancel, Escape or an outside tap keeps the interface alive. Confirm calls Destroy,
removing the main window, floating panels and dock; reopening requires a fresh instance.
Repeated red activation reuses the pending close dialog. Yellow only minimizes;
green toggles maximize. Direct SetVisible/SetMinimized and Destroy retain their APIs.

Constructors default to ReplaceExisting=true, scoped by exact Name and Parent.
Retire all matching PearlUI owners before creating the replacement. A tagged
BindableFunction on the old ScreenGui calls its original Destroy implementation,
even across separately evaluated module copies; no executor globals are needed.
A temporary parent lease rejects overlapping replacements while a final save yields.
Invalid options are checked before retiring the old UI. Same-name unrelated GUIs
are preserved. Legacy PearlUI window structure is recognized and its existing
Destroying handler performs cleanup. ReplaceExisting=false permits deliberate
duplicates; different names/parents remain independent. Reruns create fresh state;
retaining values between instances requires the same real storage adapter and key.

Destroy is idempotent: stop callbacks, listeners, input ownership, tween jobs,
thumbnail responses and persistence watcher; dispose both ScreenGuis. The showcase
also destroys its isolated sample. User-avatar requests use token guards/fallbacks.
