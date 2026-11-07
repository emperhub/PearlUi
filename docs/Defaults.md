# Default values

Version 1.0.2. [Machine-readable catalog](../defaults/PearlUI.defaults.json),
[minimal runnable example](../examples/Default.client.luau), [API contract](API.md), [production integration](GettingStarted.md).
The catalog is documentation: do not pass the entire JSON object to `PearlUI.new`
or import it as a saved config. Resolve Enum, Color3 and Parent in Luau.

## Window constructor

| Option | Default | Meaning |
|---|---|---|
| Title / Name | Pearl UI / PearlUI | Visible title / ScreenGui base name |
| Theme | Light | Forest is the available dark-green theme |
| Accent | nil | Follow the current theme; Color3 selects Custom mode |
| Parent | nil | LocalPlayer.PlayerGui |
| DisplayOrder | 50 | Dock uses this + 1 |
| Columns | 2 | Only 1 or 2; narrow content collapses to one |
| Scale | 1 | Desired range 0.65–1.3; viewport fit can reduce actual scale |
| ReduceMotion | false | App toggle; system reduced-motion preference also bypasses animation |
| Responsive | true | Phone layout below 640px; touch landscape below 500px height |
| GamepadNavigation | true | Scoped selection, focus ring, Back, shoulders and D-pad adjustment |
| ReplaceExisting | true | Retire existing PearlUI windows with the same Name and Parent before creation |
| AnimationSpeed | 0.2 seconds | Effective duration clamps to 0.05–0.6 |
| ToggleKey | Enum.KeyCode.RightShift | Constructor needs Enum, setter accepts string too |
| ConfigScope | global | Demo deliberately uses game_<game.GameId> |

Desktop initial size is 900 × 610; bounds are 680 × 420 through 1440 × 1000.
Initial opacity is 0.97 (range 0.75–1), notifications enabled, visible and
not minimized/maximized. These are runtime state, **not constructor options**:
use `SetSize`, `SetOpacity`, `SetVisible`, `SetMinimized`, `SetMaximized`.
The dock starts at the very top center, up to 330 × 54 with a 22px recovery handle.
On phones it fits within the safe viewport. Mobile fills the available window at
readable scale 0.85–1.1 with a 56px icon rail and 44px touch targets. Desktop size
remains stored for switching back; mobile layout does not rewrite it.
Two-column content threshold is 580 logical pixels; gap 14 and card gap 16.
Corners: window 14, card 12, field 7. Fonts: Gotham/GothamMedium.

## Sections and controls

Tab defaults: Name `Tab`, Description empty, Icon lowercase Name.
Section defaults: Title `Section`, Id `<Tab.Name>.<Title>`, alternating Left/Right,
Icon `grip-vertical`. All controls accept optional Icon; SetIcon(nil) removes it.
Value control Id defaults to `<Tab.Name>.<Section.Title>.<Label>`; prefer explicit
stable IDs. Button and Label have no persisted Id. Common options: Visible true,
Disabled false, Persist true, ResetGroup `Controls`; Description/Callback/reason unset.
Label defaults to the control kind. Set ResetGroup `Appearance` for theme controls.

| Control | Defaults / required values |
|---|---|
| Toggle | Default false |
| Slider | Min 0, Max 100, Step 1, Default Min, Suffix empty |
| Dropdown | Options required, nonempty unique strings; Multi false; Searchable true; PageSize 50 (10–100); first option / empty array for multi |
| ColorPicker | Default current palette Accent, Alpha 1 |
| Input | Default empty, MaxLength 128 UTF-8 characters, Placeholder Enter text |
| Keybind | Default RightShift; OnPressed unset |
| Button | Text Run, Primary false |
| Label | Value empty; string shorthand supported |

Use `Get` for live values and `Serialize` for JSON. ColorPicker Get returns Color3
and alpha; serialization returns `{Hex, Alpha}`. Set(value, true) suppresses the
callback. Disabled controls still accept programmatic Set.

Notify defaults: Title `Done`, Description empty, Duration 4 seconds, Preview false.
An ordinary notification obeys NotificationsEnabled; an explicit preview can use
`Preview = true`. Confirm defaults: Title `Are you sure?`, Description empty,
ConfirmText `Confirm`, Text unset, ReadOnly false and no callbacks/validator.

## Reset defaults versus saved configs

`CaptureDefaults()` captures the **current UI profile**, not this JSON catalog.
Build every control, capture once, then configure persistence. `Reset('All')`
returns to that captured baseline and does not delete configs. `RequestReset`
adds the normal in-product confirmation. An app can deliberately capture Forest
as its baseline without changing the library's factory Light default.

The demo's named `Default` config is a separately saved snapshot. Its presence
does not change what CaptureDefaults means. Saved startup state/auto-load overrides
construction values. A custom accent stays custom across themes until ResetAccent.

## Persistence and schemas

Persistence starts disabled. Ready() captures defaults and creates a named Default
config; with no adapter it reports Session only. Ready({Adapter=adapter,Key="settings"})
also configures storage (default key settings). ConfigurePersistence is the lower-level
API and needs Adapter and Key;
AutoSave true, Load true, Debounce 1.5 seconds. It polls at 0.5 seconds and retries
failed writes after 6 seconds. Save must return true after acknowledgement.
Initial load failure blocks writes until recovery. Server key limit is 24 bytes
(core limit 64); full document limit 200,000 bytes. Server cooldown is 6 seconds.

Config names trim whitespace, require 1–32 UTF-8 characters, at most 128 bytes,
no control characters and no case-insensitive duplicates. Limit: 20 configs per
scope, 32 scopes, 50,000-byte profile, 100,000-byte transfer. Auto-load starts unset.
Layout/profile/settings/transfer schema versions are 1. Transfer Kind is
`PearlUIConfig`; it contains Name, Scope and Profile. See [Configs](Configs.md)
and [Persistence](Persistence.md) for exact flows and legacy migration.

## Theme palette

Light, Dark, Midnight, Graphite, Lavender, Rose, Matcha, Ocean, Forest.
The catalog contains every palette's Window, Sidebar, Card, Text, Muted, Border,
Track, Field, Hover and Accent HEX values, generated directly from the module.
Light accent is #0071F6; Forest accent is #37744A.

The showcase is an opinionated app, not a factory-value fixture: game scope,
enabled notification toggle, selected favorite tools, and its narrower 0.05–0.5
animation slider are deliberate overrides recorded in demoOverrides in the catalog.
