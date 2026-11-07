# Settings, resets and theme accents

The library accepts a storage adapter and has no dependency on executor file APIs.
The standalone preview includes an optional file adapter. The Studio demo place
includes a server DataStore integration.

## Local preview

Run `dist/PearlUI-Demo.client.luau` in the same local preview environment used
for the demo. When file APIs are available, it uses
`PearlUI/u<LocalPlayer.UserId>_demo.json`, with `.tmp` and `.bak` recovery copies
in that environment's file workspace. The files contain only PearlUI settings
and named profiles. Different account prefixes do not share settings.

An adapter factory is also provided in `examples/FileStorage.luau`. Its file
functions may be supplied through `FileSystem`, so integrations can use their
own storage implementation.

## Your Roblox game

The generated `PearlUI-Demo.rbxlx` already includes:

- `ReplicatedStorage/PearlUI`: the UI module.
- `ReplicatedStorage/PearlUIPersistence`: `src/PersistenceClient.luau`.
- `ServerScriptService/PearlUIPersistenceServer`: `examples/Persistence.server.luau`.
- `StarterPlayer/StarterPlayerScripts/PearlUIDemo`: the client demo.

For an existing game, put those sources in the same locations. The server owns
the `PearlUI_Settings_v1` data store and keys each settings document by the
invoking player's UserId and a short application key. Clients never supply
another player's UserId. Saves require acknowledgement from `UpdateAsync`.

DataStore services must be available for the published experience. Studio
DataStore access is an explicit experience setting; it is not enabled by this
project. The server uses a six-second save cooldown, and the client retries
failed automatic saves while keeping the latest values in memory. A failed
initial load blocks writes until a successful reload, preventing a temporary
read failure from overwriting an existing setup with defaults.

References: [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)
and [RemoteFunction communication](https://create.roblox.com/docs/scripting/events/remote).

## Custom adapter API

Construct controls first, capture defaults, then load storage:

```lua
window:CaptureDefaults()
local ok, message = window:ConfigurePersistence({
    Key = "my-ui", -- server adapter: 1–24 ASCII letters, digits, _ or -
    Adapter = {
        Load = function(key)
            return yourStorage:Read(key) -- JSON string, or nil when absent
        end,
        Save = function(key, json)
            yourStorage:Write(key, json)
            return true -- explicit acknowledgement is required
        end,
    },
    Debounce = 1.5,
    AutoSave = true,
    OnStatus = function(status, errorMessage)
        -- Ready, Loading, Unsaved, Saving, Saved or Error
    end,
})
```

`SaveSettings()` and `LoadSettings()` return success plus an error/result.
`GetPersistenceStatus()` returns the current status and any error.
`DisablePersistence(true)` flushes before disconnecting the adapter;
`DisablePersistence(false)` disconnects without a write. The automatic watcher
checks settings every 0.5 seconds, then waits for the debounce interval after
the last observed edit. `Destroy()` attempts a final save when auto-save is on.
Use **Save now** and wait for **Saved** before leaving if recent changes are
still pending. A process termination or unavailable storage service cannot be
guaranteed to preserve edits that have not yet been acknowledged.

The storage envelope includes per-game config banks and their current control values, appearance, window/tab/
panel/dock layout and named profiles. Usernames, avatar images and transient
notifications are not stored. The maximum settings document is 200,000 bytes.

## Reset controls

`CaptureDefaults()` records the initial setup independently of named profiles.
Mark appearance controls with `ResetGroup = "Appearance"`; other controls
default to the `"Controls"` group.

```lua
window:RequestReset("Appearance") -- confirmation dialog first
window:RequestReset("Controls")
window:RequestReset("Layout")
window:RequestReset("All")
```

`Reset(scope)` applies immediately for code integrations and returns success
plus any validation error. Resetting does not delete named profiles. A general
`Confirm({Title, Description, ConfirmText, OnConfirm, OnCancel})` dialog is also
available; its handle has `Confirm()` and `Cancel()` methods. Escape, Cancel
or clicking outside the dialog cancels without applying the reset.

## Theme accent

`SetAccent(color)` selects a custom accent. `ResetAccent()` or `SetAccent(nil)`
returns to the current theme's accent and follows subsequent theme changes.
New profiles record `Appearance.AccentMode` as `"Theme"` or `"Custom"`.
Older profiles without that field retain their saved custom-color behavior.

The demo's **Appearance → Personalization → Use theme color** button restores
this mode and updates the color picker. Appearance and control resets remain
separate from layout resets.

## Per-game configuration banks

Version 0.7.0 adds separate banks for each ConfigScope while retaining the
existing Version=1 / Current / Profiles envelope. The demo uses GameId to
choose its scope. Both the latest working setup and the named config list
are separate per game. A selected auto-load config overrides that game's
last working setup at startup. Legacy data migrates into the first current
scope and the file adapter retains a backup. See [Configs.md](Configs.md)
for the manager controls, schema and transfer API.
