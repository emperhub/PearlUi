# Integration

For a new application start with [GettingStarted.md](GettingStarted.md) and
examples/Starter.client.luau. Core version 1.0.0 has responsive touch layout,
scoped gamepad navigation and the Ready initialization helper.

## Studio: minimal library

Import `dist/PearlUI.rbxmx` into ReplicatedStorage as ModuleScript `PearlUI`.
Alternatively create that ModuleScript from `src/PearlUI.luau`. Put
`examples/Default.client.luau` into StarterPlayer/StarterPlayerScripts as a
LocalScript. This example has two sections, explicit defaults and stable IDs.
No durable storage is implied. Do not run the UI on the server.

## Load the example from GitHub

In the compatible client preview with HttpGet/loadstring, run:

```lua
local app = loadstring(game:HttpGet("https://raw.githubusercontent.com/emperhub/PearlUi/main/examples/Remote.client.luau"))()
```

This downloads the example and loads PearlUI from an immutable commit URL.
It builds a Forest window, two sections and eleven controls with real callbacks:
theme, notifications, opacity, message, menu key, motion, toast, detach/dock and
reset. The returned app has Window, Controls and Events for inspection. Call
`app.Window:Destroy()` before replacing this instance. No storage adapter is
configured, so this example does not change the full demo's saved configs.
HttpGet/loadstring preview execution is environment-specific; use the ModuleScript
example above for Studio. Inspect the source before running a remote example.

## Full interactive showcase

Open `dist/PearlUI-Demo.rbxlx` and Play, or map `default.project.json` with Rojo.
The five sources are: PearlUI and PearlUIPersistence from src, PearlUIShowcase
from examples in ReplicatedStorage; Persistence.server in ServerScriptService;
Demo.client in StarterPlayerScripts. The generated XML includes all five.
Use [Showcase](Showcase.md) for all 81 public APIs, 7 tabs and 14 sections.

The standalone `dist/PearlUI-Demo.client.luau` embeds core, showcase and the
optional FileStorage adapter. It belongs in a compatible local client preview;
it is not the Studio server persistence deployment. No file API is required by
the core. Follow [Persistence](Persistence.md) to choose real durable storage.

## Build and install the reusable skill

From a checkout run `python tools/build.py`, `python tools/sync_skill.py`, then
`python tools/validate_metadata.py`. Generated dist files and bundled references
must match the checked-in source. No third-party Python package is required.

Copy the complete `skills/pearl-ui` folder into your Codex user skills directory
(`~/.codex/skills/pearl-ui`). Keep agents, scripts and references together.
Reload skills/restart the app if discovery does not refresh. Invoke `$pearl-ui`
and provide the checkout location and requested change. Its references include
the API, defaults, config behavior, integration, architecture and validation.
Run its portable `scripts/inspect_project.py <checkout>` to inspect a checkout.

## Existing application

Keep its chosen names, IDs, scope, theme and saved data. Construct all controls,
call CaptureDefaults, then ConfigurePersistence. Use explicit section/control IDs
for layout and values; exclude temporary inspector fields with Persist=false.
Core scope defaults global; the demo recommends `game_` + GameId, sharing settings
across places within one game. Do not replace existing scope conventions without
a data migration. There is no universal raw-URL loader requirement: require the
ModuleScript in Studio or use the generated standalone for its documented context.
