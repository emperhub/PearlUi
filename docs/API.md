# PearlUI API contract

Version 0.8.0. All 76 public methods; underscore methods are private.

See [Defaults.md](Defaults.md) for constructor/control options and values.

| Method | Returns | Contract |
|---|---|---|
| `picker:Get()` | Color3, number | Color plus alpha. Use Serialize for a JSON-safe representation. |
| `picker:Open()` | self | Open SV/hue/alpha and HEX/RGB editor if interactive and visible. |
| `picker:SetAlpha(alpha, silent?)` | self | Alpha in [0,1], optional silent. Preserve current HEX. |
| `picker:SetHSV(h, s, v, silent?)` | self | All channels finite in [0,1], optional silent; validates all channels before applying. |
| `Control:CanInteract()` | boolean | Own destroyed/disabled/visible/row state. Not a complete ancestor visibility or clipping check. |
| `Control:Close()` | self | Close an owned dropdown/color editor if open. |
| `Control:Destroy()` | nil | Idempotent removal, listener/tween cleanup and Id release. Rebuild with the same Id after destruction. |
| `Control:Get()` | value copy | Defensive copy for table values. ColorPicker overrides this to return Color3,alpha. |
| `Control:OnChanged(callback)` | self | Replace callback; nil removes it. This is one callback slot, not an event subscription list. |
| `Control:Serialize()` | JSON-safe value | ColorPicker returns {Hex,Alpha}; multi-dropdown returns an array. Never serialize GUI instances. |
| `Control:Set(value, silent)` | self | Validate, store and render. Callback fires unless silent=true; works while disabled. Destroyed controls reject setters. |
| `Control:SetDisabled(disabled, reason)` | self | Boolean plus optional reason. Blocks native input and cancels owned popup/capture/drag; setters still work. |
| `Control:SetLabel(value)` | self | Change presentation without changing Id; refresh search matching. |
| `Control:SetVisible(visible)` | self | Hide/show while respecting search. Hiding closes owned interactions. |
| `dropdown:Open()` | self | Open if enabled and in a visible window/page; multi selection stays open until Done/Close. |
| `dropdown:SetOptions(entries, default?, silent?)` | self | Validate new options before mutation; retain valid selections unless default supplied. Third argument silent suppresses callback. |
| `PearlUI.GetThemes()` | string[] | Ordered defensive copy: Light, Dark, Midnight, Graphite, Lavender, Rose, Matcha, Ocean, Forest. |
| `PearlUI.new(options)` | Window | Client constructor; LocalScript or explicit Parent. Enum KeyCode for constructor ToggleKey. See constructor/default tables. |
| `Section:Button(options)` | Control | Text='Run', Primary=false. Callback() on activation. No persistence Id/value contract. |
| `Section:ColorPicker(options)` | Control | Default current accent, Alpha=1. Accept Color3, HEX or {Hex,Alpha}; callback receives Color3,alpha. |
| `Section:Detach()` | nil | Move card to a floating window, resetting card origin/canvas. Already detached reveals it. |
| `Section:Dock()` | nil | Return content synchronously to its own page; fade empty floating shell independently. |
| `Section:Dropdown(options)` | Control | Required nonempty unique string Options. Multi=false, Searchable=true. Scalar or ordered array value. |
| `Section:Input(options)` | Control | Default empty string; MaxLength=128 UTF-8 characters, Placeholder='Enter text'. Commits on focus loss. |
| `Section:Keybind(options)` | Control | Default RightShift. Callback(string key name) for changes; OnPressed(Enum.KeyCode) for activation. |
| `Section:Label(options)` | Control | String shorthand or {Label,Value}; Value defaults empty. Get/Set useful for result labels; no persistence Id. |
| `Section:Reveal()` | self | Reveal/focus detached panel, restoring hidden/minimized main window; detaches if needed. |
| `Section:Slider(options)` | Control | Finite numeric Min/Max/Step; defaults 0/100/1; clamped and quantized value, Callback(number). |
| `Section:Toggle(options)` | Control | Boolean Default=false; Callback(boolean). |
| `Tab:Section(options)` | Section | String or {Title, Id, Column}. Stable unique Id; Column Left/Right, alternating by default. |
| `Window:CaptureDefaults()` | self | Capture current profile after building UI and before loading user state. Named Default profile is separate. |
| `Window:ConfigurePersistence(options)` | boolean, loaded-or-error | Adapter Load/Save, Key required; AutoSave=true, Load=true, Debounce=1.5, optional OnStatus. Configure after CaptureDefaults. |
| `Window:Confirm(options)` | handle | Title/Description/ConfirmText/OnConfirm/OnCancel. Optional Text, ReadOnly and Validate for editor. Handle Confirm/Cancel complete once; Editor/ErrorLabel available for inspection. |
| `Window:CreateConfig(name)` | boolean, name-or-error | Capture current profile under a new normalized name; set active; reject duplicates/capacity overflow. |
| `Window:DeleteConfig(name)` | boolean, name-or-error | Remove snapshot, clear matching references; do not reset current values. UI wraps this with confirmation. |
| `Window:Destroy()` | nil | Idempotent teardown; attempt final auto-save, cancel jobs/tweens/listeners, dispose both ScreenGuis. Showcase also disposes its sample. |
| `Window:DisablePersistence(flush)` | nil | flush=true attempts SaveSettings first; false disconnects without a write. Cancels its watcher. |
| `Window:ExportConfig(name)` | JSON-or-nil, error? | One versioned PearlUIConfig envelope with Name, Scope and Profile, not all configs. |
| `Window:ExportLayout()` | JSON string | Encode GetLayout for transfer/storage. |
| `Window:ExportProfile()` | JSON string | Version=1, Values, Appearance and Layout. Persist=false controls and destroyed controls are excluded. |
| `Window:GetConfigStatus()` | table | Scope, Active, AutoLoad, Dirty, Count. Manager fields and transient tab/visibility changes do not create edited status. |
| `Window:GetLayout()` | table | Version=1 layout with Window, Dock, Panels and ActiveTab; normalized positions, no GUI objects. |
| `Window:GetPersistenceStatus()` | status, error? | Disabled, Ready, Loading, Unsaved, Saving, Saved or Error. |
| `Window:ImportConfig(name,json,overwrite)` | boolean, name-or-error | Save a validated copy into current scope without applying; overwrite=true explicitly replaces an exact name. |
| `Window:ImportLayout(value)` | boolean, error? | Validate table or JSON before applying window, tab, panel and dock geometry. |
| `Window:ImportProfile(json)` | boolean, error? | Validate known control values/appearance/layout before applying; legacy AccentMode omission retains custom-color behavior. |
| `Window:ListConfigs()` | string[] | Sorted defensive list for current scope. |
| `Window:LoadConfig(name)` | boolean, name-or-error | Apply named profile and set active only on success. |
| `Window:LoadProfile(name)` | boolean, error? | Legacy raw named-profile apply. Prefer LoadConfig for active-config tracking. |
| `Window:LoadSettings()` | boolean, exists-or-error | Load/validate current game bank and named configs; selected auto-load overrides last working setup. Failed load blocks writes. |
| `Window:Notify(options)` | toast slot or nil | String shorthand or {Title,Description,Duration,Preview}. Disabled preference suppresses ordinary notifications; Preview=true bypasses it without changing preference. |
| `Window:OnConfigsChanged(callback)` | Disconnect handle | Observe list/metadata changes. This is not a callback for every control edit. |
| `Window:RefreshUserProfile()` | nil | Refresh LocalPlayer display name, username and AvatarBust thumbnail, with fallback/token guards. |
| `Window:RenameConfig(name, replacement)` | boolean, name-or-error | Move snapshot; update active/auto-load references; preserve current values. |
| `Window:RequestReset(scope)` | confirmation handle | Same scopes, with an in-product confirmation before application. |
| `Window:Reset(scope)` | boolean, error? | Apply captured Appearance/Controls/Layout/All immediately; requires CaptureDefaults and keeps named configs. |
| `Window:ResetAccent()` | self | Return to Theme mode; later themes follow their own accents. Demo also synchronizes its picker. |
| `Window:RevealDock(immediate)` | nil | Reveal expanded dock from edge; immediate=true skips its travel tween. Does not open main by itself. |
| `Window:SaveConfig(name)` | boolean, name-or-error | Update existing named snapshot from current setup and set active. Does not mean adapter has already acknowledged disk save. |
| `Window:SaveProfile(name)` | JSON string | Legacy named save in current scope; uses storage-budget checks. With persistence configured it survives through the settings envelope. |
| `Window:SaveSettings()` | boolean, error? | Save latest current setup and banks only after acknowledged adapter write; skip unchanged snapshot. |
| `Window:SelectTab(tab)` | nil | Tab object belonging to window or known name; closes menu and updates active page/search. |
| `Window:SetAccent(color)` | nil | Color3 sets Custom accent mode. nil restores the selected theme's accent. |
| `Window:SetAutoLoadConfig(name)` | boolean, name-or-error | Known name selects startup snapshot; nil clears it for this scope. |
| `Window:SetColumns(columns)` | nil | Only 1 or 2. Effective columns may collapse to one for a narrow viewport. |
| `Window:SetMaximized(maximized)` | nil | Maximize/restore while remembering prior position/size. |
| `Window:SetMinimized(minimized)` | nil | Minimize/restore; separate from Visible and from dock stow side. |
| `Window:SetOpacity(value)` | nil | Finite number, clamped to [0.75,1], including surfaces with a visibility transition. |
| `Window:SetScale(value)` | nil | Finite desired scale clamped to [0.65,1.3]; actual fit scale may be smaller. |
| `Window:SetSize(width, height)` | nil | Finite width/height; rounded, clamped to 680x420..1440x1000, with viewport fitting. |
| `Window:SetTheme(theme)` | nil | Name from GetThemes. Repaint all bound roles while preserving a custom accent override. |
| `Window:SetToggleKey(key)` | nil | Enum.KeyCode or key-name string; updates footer. Constructor itself expects an Enum.KeyCode. |
| `Window:SetVisible(visible)` | nil | Show/hide main and detached panels; hidden main leaves the dock available. |
| `Window:StowDock(side)` | nil | Left or Right; hides dock offscreen with recovery handle, retaining height. |
| `Window:Tab(options)` | Tab | String or {Name, Description, Icon}. Adds sidebar and dock entries; first tab is selected. |
| `Window:ValidateConfig(json)` | boolean, error? | Validate package or legacy profile JSON without applying or storing it. |

## Value and callback rules

- Generic `Get` and `Serialize` copy arrays/tables. ColorPicker `Get` returns Color3 plus alpha; serialize HEX/alpha instead.
- Keybind change callbacks receive a key-name string. OnPressed receives Enum.KeyCode and is ignored while typing in a TextBox.
- Ordinary setters do not automatically keep an unrelated application control synchronized. Bind it deliberately or update its value silently; the showcase performs parameter synchronization.
- Label and Button do not reserve persisted Ids. Put state in a value control with a stable Id.
- SetDisabled prevents interaction but permits Set. Hiding/destroying a control cancels owned interactions.
- Methods returning boolean/error are suitable for UI feedback. Constructor/control/configuration assertions can throw; use pcall at integration boundaries when inputs are external.

## Construction and runtime fields

Accepted window constructor options: Title, Name, Theme, Accent (Color3), Parent, DisplayOrder, Columns, Scale, ReduceMotion, AnimationSpeed, ToggleKey (Enum.KeyCode), ConfigScope. Size and opacity are changed through SetSize/SetOpacity, not invented constructor options.

Applications may deliberately update ReduceMotion, AnimationSpeed and NotificationsEnabled, as the supplied demo does. Read Theme, Palette, Scale, Columns, WindowSize and ToggleKey for current state; prefer methods for geometry/theme changes.

Control common options: Id, Label, Description, Callback, Visible, Disabled, DisabledReason, Persist and ResetGroup. Use explicit section Id/Column to preserve existing config layout.

## Icon catalogs

`PearlUI.Icons` is a frozen sorted array of all 2,029 canonical Lucide names. `PearlUI.IconAliases` is a frozen alias map. These are data properties, not additional methods. Use a name in `window:Tab({Name="Defense", Icon="shield-check"})`; see [Icons.md](Icons.md) for aliases, filtering and the pinned source revision.
