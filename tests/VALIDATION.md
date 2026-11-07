# Validation — 2026-11-07

PearlUI **0.8.0** expands the demo; the core implementation changes only its
version identifier. The targeted Showcase.spec.luau suite passed **45 / 45**
checks in the connected Roblox client. The prior core baseline is 424 checks
from 0.7.0; those older suites were not rerun for this demo-only change.

Public methods were extracted from the core source, excluding underscore
methods and including dropdown/color-specific methods. All **76** have a
visible showcase location recorded in docs/ShowcaseAPI.json. The fresh demo
constructs 7 tabs, 14 sections and 102 controls, with ten component examples.

The suite builds the entire real demo with persistence disconnected. It
checks tab/section structure, silent value synchronization, callbacks,
get/set/serialize and false results, callback removal/attachment, disabled,
hidden and renamed controls, destroy/recreate, dynamic dropdown options,
actual dropdown/color popups, alpha/HSV, separate sample lifecycle, memory
storage restoration, config export/validate/import, observer disconnection,
legacy profiles, layout/profile roundtrips, reset confirmation and cleanup.

The live demo was updated with existing named configs preserved.
Its Components page was visually inspected with callback counts and values
displayed. User edits and deliberately destroyed showcase controls were not
reset by the final synchronization update. Test values are Persist=false;
sample storage is memory-only and separate from the real demo's settings.

The official Luau compiler checks the module, demo, showcase, tests and
standalone source. The build verifies all five embedded sources in Studio
XML, plus archive CRC when packaging.

Limits: coverage means every public method has a visible test/example path,
not that every possible interaction sequence was exercised. Physical touch,
gamepad, published DataStore and reopening generated XML in Studio were not
tested. Native gestures were inspected rather than exhaustively automated.

## Previous validation history

PearlUI **0.7.0** passed **424 / 424** checks across fourteen suites in the
connected Roblox client. Previous suites report Runtime 50, Animation 18,
Dock 16, Features 52, FeatureMotion 6, ColumnsProfile 32, Audit 40,
DetachedGeometry 23, NotificationDock 20, Themes 59, Settings 38,
FileStorage 11 and PersistenceServer 14. Configs.spec.luau adds 45 checks.

## Config coverage

Tests cover trimmed and Unicode names, duplicate rejection, create/update/
load/rename/delete, active and auto-load references, transient manager fields,
edited-state detection, sorted defensive lists, versioned exports, readonly
editors, invalid JSON staying open, atomic validation failure, explicit
overwrite, legacy raw-profile import, listeners, auto-load restoration,
per-game config and value isolation, preservation of another game's bank,
legacy migration, missing auto-load rejection, twenty-config capacity,
legacy long names and ignoring stale transient manager values.

An actual file adapter in a separate PearlUITests namespace stored a named
config and auto-load choice. Recreating the window read them from disk;
opening a different scope yielded its own empty config list/default values.
These scope checks use separate game identifiers in the same connected
client; a physical game/server switch was not performed for this release.

The real user demo was migrated from the previous settings document with
Forest preserved. Its Profiles manager was visually inspected. Existing
Default and other user-created configs remained available and the storage
status reported Saved. Final compatibility updates preserved the open UI
and its active/edited state instead of recreating the user's editing session.

Luau compilation, four-source XML roundtrip and ZIP integrity are verified.
Published DataStore, physical touch/gamepad and reopening XML in Studio
remain untested. Server adapter tests use mock services/store. Readonly
editor selection/copy follows the Roblox TextBox API linked in docs/Configs.md;
a full native clipboard copy/paste roundtrip was not automated.

## Previous validation history

PearlUI **0.6.0** passed **379 / 379** checks across thirteen suites in the
connected Roblox client: Runtime 50, Animation 18, Dock 16, Features 52,
FeatureMotion 6, ColumnsProfile 32, Audit 40, DetachedGeometry 23,
NotificationDock 20, Themes 59, Settings 38, FileStorage 11 and
PersistenceServer 14.

## New behavior

Settings checks cover Theme/Custom accent mode, scoped reset isolation,
captured defaults, preservation of named profiles, waiting for confirmation,
cancel/confirm/replacement/hide behavior, duplicate completion protection,
manual save, redundant-write suppression, restoration into a new window,
corrupt data without overwrite, retry, debounced auto-save, final local flush,
poll cancellation, stale-load rejection and edits during yielding saves.

FileStorage checks use an injected file system for verified writes, backups,
recovery after primary/temp damage, invalid payloads, path validation,
account isolation and recreation of the adapter.

The actual optional file adapter was also connected in the live demo. Save
was acknowledged and a recreated demo loaded Forest and named profiles from
the physical JSON file. The connected Roblox client then changed from a
RoWorld session to Just a baseplate; the new client loaded the same saved
settings from disk and reported Saved with Forest restored. No scene or
gameplay state was modified by these tests.

The reset confirmation dialog was visually inspected in Forest. Cancellation
was observed without changing the selected theme. Reset acceptance is covered
through the same dialog handle's Confirm method in the runtime suite.

PersistenceServer tests run the real handler source with a mock store/clock/
service surface. They verify user-scoped keys, invalid requests, size limits,
cooldown, service failure recovery and cleanup. No published DataStore backend
was contacted. The included client/server integration follows the documented
Roblox DataStore and RemoteFunction APIs linked in docs/Persistence.md.

The official Luau compiler checks the library, examples, adapters, generated
standalone source and tests. XML roundtrips now verify all four embedded
script/module sources, and ZIP integrity is checked.

Limits: DataStore operation on a published game and Studio API settings were
not tested or changed. Physical touch/gamepad and reopening XML in Studio were
not tested. The earlier randomized stress run below applies to 0.4.1.

## Previous validation history

PearlUI **0.5.1** passed **316 / 316** checks in the connected Roblox client.
All nine previous non-theme suites passed (257 checks), and Themes.spec.luau
passed 59 checks with the nine-palette catalog including Forest. Coverage for
Forest includes theme selection, main/dock/detached/card/field/notification
colors, computed text contrast and profile restoration. Existing accent
preservation and invalid-theme behavior still pass.

The live demo was updated with Forest available and selected. Luau compilation,
generated XML source roundtrips and ZIP CRC are verified. Physical touch and
gamepad hardware are not tested; XML was not reopened in Studio.

## Previous validation history

PearlUI **0.5.0** passed **310 / 310** checks in the connected Roblox client:
Runtime 50, Animation 18, Dock 16, Features 52, FeatureMotion 6,
ColumnsProfile 32, Audit 40, DetachedGeometry 23, NotificationDock 20,
and Themes 53.

Themes.spec.luau cycles through Light, Dark, Midnight, Graphite, Lavender,
Rose, Matcha and Ocean via a dropdown callback. Each palette is checked on
the main window, dock, detached shell, card, field and notification surface.
Every theme is exported, changed and restored through a profile. Tests also
check catalog ordering/defensive copies, preserving a custom accent, rejecting
unknown themes without mutation, and docking after cycling through palettes.
Computed contrast checks require Text/Card >= 7 and Muted/Card >= 4.5.

The live demo was updated to the eight-option selector. Matcha was visually
inspected in the connected Roblox window; user-selected theme state was kept.
The module, example and all suites pass Luau 0.745 compilation. Generated XML
source roundtrips and archive CRC are verified by the packaging workflow.

Limits: no physical touch-device/gamepad test; the generated place was not
reopened in Studio. Earlier stress runs below refer to version 0.4.1.

## Previous validation history

PearlUI **0.4.3** passed **257 / 257** checks in the connected Roblox client:
Runtime 50, Animation 18, Dock 16, Features 52, FeatureMotion 6,
ColumnsProfile 32, Audit 40, DetachedGeometry 23, NotificationDock 20.

## Reproduction and fixes

The live demo had NotificationsEnabled=false and showNotifications=false.
Notify returned nil before creating a card. The demo Preview callback now
uses Preview=true, allowing an intentional test notification while preserving
the disabled preference. Ordinary notifications remain suppressed when off.
Invoking the actual live demo Preview callback created a Hello from Pearl
card while both preference values remained false. Tests cover creation,
viewport bounds, content Z-order, expiry, normal enabled/disabled behavior
and destruction. Native Preview input was interrupted by user input; this
validation does not claim a completed native click for that button.

The recurring white Dock was reproduced by importing a Dark, minimized
profile into a new Light window: Theme became Dark but the dock remained
#FFFFFF rather than #2B2E37. _applyLayout stopped all dock tweens after
SetTheme started recoloring. It now stops only Position, preserving the
theme tween. Repeating the same import now reaches #2B2E37 without an extra
SetTheme repaint. Profile import, direct layout import and edge recovery
are covered. The live dock was visually inspected in Dark, and Open Pearl UI
was clicked successfully with the main window restored.

Detached placeholders have separate title/action labels bounded by the card,
with truncation for long titles. Open detached panel calls Reveal, keeping
the section detached, bringing it forward and restoring a minimized workspace.
Tests also verify that explicit Dock still returns content to its own page.

Luau compilation, generated XML source roundtrips and ZIP CRC are checked.
Physical touch hardware and gamepad navigation were not tested. Generated
XML was not reopened in Studio. Previous stress runs below refer to 0.4.1.

## Previous validation history

PearlUI **0.4.2** passed **237 / 237** checks in the connected Roblox client:
Runtime 50, Animation 18, Dock 16, Features 52, FeatureMotion 6,
ColumnsProfile 32, Audit 40, and DetachedGeometry 23.

The reported clipping defect was reproduced before editing: a right-column
section retained Position.X.Offset=336 after reparenting into FloatScroll.
Its content began 338 rendered pixels to the right of the viewport origin.
The fix resets the section origin to zero, cancels stale position tweens,
starts the scroll at the top and restricts scrolling to the vertical axis.

The new tests check rendered card/action bounds inside the floating viewport
for four sections across two columns and two rows. They also verify docking
back to the correct column, detachment from search results, main-window resize,
profile restoration, reopening after scrolling and single-column detachment.

The actual Component playground demo panel was visually inspected after the
update: its card begins two pixels inside the viewport and fits fully across
the available width. Existing user settings were preserved on live replacement.
Luau compilation, generated XML source roundtrips and ZIP CRC are verified.

Limits: no physical touch-device or gamepad test; generated XML was not reopened
in Studio. Prior 100-operation stress results below refer to version 0.4.1.

## Previous validation history

PearlUI **0.4.1** passed **214 / 214** checks in the connected Roblox client.
The seven suites report Runtime 50, Animation 18, Dock 16, Features 52,
FeatureMotion 6, ColumnsProfile 32, and Audit 40. These suites create isolated
PlayerGui windows and destroy them after testing.

## Reproduced defects and verification

- Before the fix, detach → dock during entry → switch tabs left the returned
  card background and text at transparency 1. The same happened when docking
  while the main window was hiding. Both sequences now restore text to 0 and
  card transparency to 1 minus the configured opacity.
- Changing tabs during a parent fade could leave both old and new tab buttons
  highlighted. The fade now retains new intended transparency values; the
  previous button ends at 1 and the active button at 0.
- Floating panels now occupy distinct initial positions and complete Z-order
  bands; focusing an older panel raises its surface and all controls together.
  Popup and dismissal layers remain above them. Docking restores original Z.
- Added tests for repeated detach/dock, hide/show, tab changes, theme changes,
  late-loaded avatar fallback, popup ownership, inactive/hidden popup attempts,
  scrolling dismissal, key-capture cancellation, slider completion, rejected
  builder rollback/ID reuse, synthetic touch ownership, and many-tab navigation.
- A separate deterministic randomized stress run (seed 1041) performed 100
  detach, dock, tab, theme, visibility and search operations across 8 sections.
  All sections returned to their own pages with visible text and canonical
  surface opacity; no failures were found in the checked final invariants.

## Native UI verification

Using Windows input against the actual Roblox window, verified General-tab
navigation, dropdown opening, selecting Light and restoring Dark, Workspace
detachment and red-button docking, yellow-button minimization, and recovery
through Open Pearl UI. Read back live state to confirm placement, visibility,
theme callback values and rendered colors. Live demo updated with existing
user settings preserved. Both 800-pixel and 1920-pixel window states were
observed; narrow layout remained readable.

The Luau 0.745 compiler validates the module, demo and suites. The standard
build script verifies the generated XML source roundtrip. ZIP contents and
CRC are checked when packaging.

## Limits

Physical touch hardware and gamepad navigation were not tested. Touch
ownership checks use synthetic input records. The generated place was not
reopened in Studio. This audit covers reproduced lifecycle failures and the
listed regressions; passing checks do not prove all possible bugs are absent.

## Previous validation history

PearlUI **0.4.0** passed **174 / 174** checks in a connected Roblox client:
50 regression checks from `Runtime.spec.luau` with ReduceMotion enabled, plus
18 animated-state checks from `Animation.spec.luau` with motion enabled, and
16 edge-dock checks from `Dock.spec.luau`, 52 feature checks from
`Features.spec.luau`, 6 integration checks from `FeatureMotion.spec.luau`, and
32 responsive-layout/profile checks from `ColumnsProfile.spec.luau`.
The test window is created in PlayerGui and destroyed at the end; the scene and
other players are not modified.

The 0.4.0 suite checks default/explicit columns, independent card stacks,
matching widths, compact row geometry, labels/descriptions above fields,
measured card heights, canvas extents, one-column fallback, restoring wide
rows, saved column preferences, old layout compatibility, search packing,
detach/dock placement, hidden-row reflow, LocalPlayer names, avatar surfaces,
bottom-left profile placement, shortcut hints, stale thumbnail request tokens,
loaded-image fallback cleanup, invalid column data and destruction cleanup.
An animation regression verifies that opacity/size retargeting preserves
unrelated color animation goals.

The two-column dark-theme layout was visually inspected in the live client.
The profile displayed the current display name and username; runtime checks
confirmed the avatar image was loaded and its monogram fallback was hidden.

The new feature suite covers control labels/visibility/disabled input, visible
disabled reasons, cleanup and safe ID reuse, defensive multi-selection values,
canonical ordering, searching and empty results, replacing options atomically,
HEX/alpha/HSV validation, correct color/alpha callbacks, pointer coordinates
including GUI insets, theme changes while the picker remains open, destroying
an open editor, JSON-safe colors, complete layout roundtrips, detached-panel
positions, saved dock sides, validation before mutations, different UI scales,
legacy profiles, adding controls to detached sections, and invalidating handles.

The feature-motion suite checks editor replacement after destruction,
disabling/reopening while fading, rapid layout imports with pending docking,
and destruction while new feature transitions are running. Geometry checks
allow less than one logical pixel for UDim offset quantization at fractional
UI scales. Resize expectations include the available viewport bounds.

Coverage: UI layout, original Lucide icon data, control defaults and setters,
callbacks and silent setters, slider bounds/steps, dropdown option validation,
UTF-8 input length, keybind values, theme/accent changes, JSON profile roundtrip,
validation before profile mutations, malformed JSON, named/missing profiles,
search across tabs, restoring section ownership, detach/dock, visibility of
detached panels, minimized/maximized state, option replacement, menu listener
and style registry cleanup, invalid scale rejection, toast expiration, and
idempotent destruction.

Additional checks cover the rounded sidebar mask, shared chrome radius,
suppression of the final row divider, programmatic resize, pointer delta
resizing without changing text scale, minimum window dimensions, pointer
release, and disabling the resize handle while maximized.

Mini-dock checks cover initial top-center placement, a small-motion click
threshold, pointer-driven movement, suppression of button activation during
and after a drag, preserving position through layout and restore/minimize,
anchor-aware viewport bounds, and re-enabling ordinary clicks. Top-center
placement was visually confirmed in the live client. During verification the
live dock moved while the main window stayed minimized.

The 0.2.2 edge suite covers the separate full-height dock layer, hiding both
left and right, keeping a recovery handle visible, reveal without opening the
main window, retaining side/height during layout and visibility changes,
dragging inward from a recovery handle, automatic stowing after drag release,
hiding the handle while the main window opens, restoring it on minimize,
rapid stow/reveal cancellation, and destroying the additional ScreenGui.
Flush-top positioning and the left recovery handle were visually confirmed
in the live client. Native pointer automation was interrupted by ongoing
user input; automated edge gestures were exercised through the same pointer
handlers used by live input.

The animation suite verifies settled opacity, entry cleanup, cancellation of
obsolete completion callbacks, an intermediate exit state, rapid hide/show,
opacity changes while hidden, rapid tab switching, theme color interpolation,
slider interpolation, reopening a closing dropdown, rapid dock/detach,
docking while the window hides, rapid maximize/restore, toast exit cleanup,
ReduceMotion interruption, and destroying active animations and delayed jobs.

Transitions use native TweenService properties rather than a CanvasGroup
texture, preserving the existing hierarchy and resize behavior. Mouse/touch
dragging stays direct; scrolling continues to use native ScrollingFrame input.

Luau compiler **0.745** successfully compiled the library, example, runtime
suite, and generated standalone example. Build checks confirmed that generated
Roblox XML retains the library and demo sources exactly.

The actual rendered light theme was visually inspected at a 1920-pixel-wide
viewport and an 800-pixel-wide viewport. Lucide icons, text, controls, and the
detached Personalization panel rendered without missing font glyphs.

The 0.3.0 Color Picker was visually inspected in the live light theme and the
searchable multi-select popup in the live dark theme. HEX/RGB fields, SV/hue,
checkerboard alpha, selected icons, counts, search, Clear/Done, and scrolling
options rendered within their popup bounds. Local review captures are excluded
from the public repository. Automated API and pointer-handler tests passed; native pointer
automation may be interrupted while the user is interacting with the client.

Native mouse gestures were completed successfully for the 0.1.1 resize handle
and title bar. A corner drag changed the logical size from 900×610 to 784×540;
a title-bar drag then moved the window while preserving that size. The new
rounded lower corners and removal of the Interface scale row were visually
confirmed. Physical touch devices and gamepad navigation have not been tested. The generated
`.rbxlx` was structurally checked, but has not been reopened in Studio during
this session.
