# Use PearlUI in a real project

PearlUI 1.0.2 is a client UI library. The application owns gameplay callbacks,
permissions and its choice of storage. Core, bundled icons and session-only use
work without executor APIs or runtime HTTP.

## Roblox Studio

1. Import dist/PearlUI.rbxmx into ReplicatedStorage as ModuleScript PearlUI, or
   copy src/PearlUI.luau into that ModuleScript.
2. Copy examples/Starter.client.luau to a LocalScript in
   StarterPlayer/StarterPlayerScripts. Run Play.
3. Replace callbacks with the app's behavior. Keep explicit stable IDs. Build
   every control before calling Ready.

```lua
local PearlUI = require(game.ReplicatedStorage.PearlUI)
local window = PearlUI.new({
    Title = "My interface", Theme = "Forest",
    ConfigScope = "game_" .. tostring(game.GameId),
})
local tab = window:Tab({Name="General", Icon="house"})
local section = tab:Section({Title="Settings", Icon="settings"})
section:Toggle({Id="enabled",Label="Enabled",Icon="power",Default=false,
    Callback=function(value) print("Enabled:", value) end})
local ok, status = window:Ready()
print(ok, status) -- true, Session only
```

## Retain settings between sessions

Choose one real adapter, then use the same final Ready call:

```lua
local ok, message = window:Ready({
    Adapter = adapter, Key = "my_app", DefaultConfig = "Default",
    AutoSave = true, Load = true, Debounce = 1.5,
    OnStatus = function(status, errorMessage)
        print(status, errorMessage or "")
    end,
})
if not ok then warn(message) end
```

- For your Roblox experience, install src/PersistenceClient.luau in
  ReplicatedStorage as PearlUIPersistence and examples/Persistence.server.luau
  in ServerScriptService. Set adapter to require(PearlUIPersistence). Server
  DataStore access must be configured for the experience. Keep keys <=24 bytes.
  Clients are scoped to the invoking player; they cannot choose another UserId.
- For a compatible local preview, use examples/FileStorage.luau with available
  file functions. The generated standalone demo already integrates it. Core has
  no dependency on those functions. Keep per-app key/folder and per-account prefix.
- Without an adapter the UI is usable and configs work within that window,
  but Ready reports Session only. It does not claim to save across sessions.

Ready captures the construction baseline once, creates Default for fresh data,
then loads storage. Saved current state/auto-load can override constructor values.
It does not automatically start gameplay actions. Failed loading returns false
and blocks writes; surface the error and retry after the adapter recovers. Repeated
successful Ready calls preserve edits. The lower-level CaptureDefaults and
ConfigurePersistence APIs remain available.

## Touch and gamepad

Responsive=true and GamepadNavigation=true are defaults. Phones use a compact
icon rail, readable scale, stacked fields and larger hit areas. The desktop
window geometry is retained for restoration. Set Responsive=false only if the
app supplies its own layout.

Call window:Focus(control) to start navigation. Select enters/refocuses the UI;
A activates, B closes a popup/dialog or hides the window, shoulders change tabs.
Left/right D-pad changes sliders and hue/alpha; the SV area also accepts up/down.
Text entry uses Roblox's native TextBox keyboard. No global navigation setting
is changed, and shortcuts act only while the window owns selection. An app can
opt out with GamepadNavigation=false. System reduced motion is respected.

## Icons, lists and lifecycle

All controls and sections accept Icon; controls/tabs/sections expose SetIcon.
Tab icons update the sidebar and dock. See Icons.md for the complete catalog.
Dropdown PageSize defaults 50 (10–100); search covers all options, while only
one bounded page is built. This includes lists such as all 2,029 Lucide names.

ReplaceExisting defaults to true: rerunning with the same Name and Parent retires
the previous PearlUI window, dock and floating panels before creating a fresh one.
Use a stable Name for each app. A different name or parent creates an independent
interface; ReplaceExisting=false permits deliberate duplicates. Reusing a name does
not transfer session-only values. Use the same adapter and key with Ready to reload
saved state. Overlapping replacements while a save is pending return an error;
retry after the first run finishes. No close confirmation is shown for a rerun.

Call window:Destroy() for an explicit teardown. It disconnects input,
focus listeners, jobs, panels and ScreenGuis. Hide/minimize keeps the instance
and storage watcher alive. Persist=false excludes inspectors and temporary values.
Callbacks run safely with errors reported; handle app errors rather than silently
ignoring failed storage or config operations.

## Delivery and verification

Open dist/PearlUI-Demo.rbxlx for the full Studio showcase, or build with Rojo
using default.project.json. Use dist/PearlUI-Demo.client.luau only in a compatible
client preview. Production deployments can pin a reviewed commit; the core
ModuleScript is the normal Studio integration.

Run python tools/check.py --compiler <path-to-luau-compile> before publishing
changes. Read tests/ReleaseValidation.json for the precise tested surfaces and
remaining manual device checks. Simulated input/viewport tests do not certify
every physical device or a published DataStore deployment.
