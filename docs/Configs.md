# Configuration manager

Open **Profiles**. Configs are separated by Roblox game (GameId), with a
separate saved list, last setup, active config and auto-load choice per game.
Places in the same game use the same config scope.

## Everyday use

1. Enter a **Config name** and click **Create** to capture the current setup.
2. Select a name in **Saved configs**. Selection alone does not apply values.
3. Click **Load** to apply it. Edited active configs get a replacement prompt.
4. After changing settings, click **Save changes** to update that named config.
5. Edit the name field and click **Rename** to rename the selected config.
6. **Delete…** asks for confirmation and leaves the live settings unchanged.

The active config displays **saved** or **edited**. Manager fields and switching
tabs or showing/hiding the window do not mark a config edited. Auto-save stores
your latest working setup and config list; it does not silently overwrite a
named config's saved values.

**Auto-load selected** uses that config's saved values next time this game is
opened. With auto-load off, the last working setup for this game is restored.
Rename updates auto-load references; deleting that config clears its auto-load
selection. **Reset all** does not remove your saved configs.

## Share a config

- Select a config and click **Export JSON**. Select and copy its text.
- Enter a name, click **Import JSON…**, paste the text and confirm.
- Invalid JSON stays in the editor with an error. It is not applied or stored.
- Replacing an existing name requires a separate confirmation.
- Import creates a saved copy in the current game. It does not load it
  automatically or change the game scope. Click **Load** when ready.

The export contains one profile with a version, name and source scope. It does
not contain the other configs. Legacy ExportProfile JSON can also be imported.
The editor uses Roblox's [TextBox selection and clipboard support](https://create.roblox.com/docs/reference/engine/classes/TextBox).

## Library API

```lua
local window = PearlUI.new({
    Title = "My UI",
    ConfigScope = "game_" .. tostring(game.GameId),
})
-- Build controls first. UI-only manager fields can use Persist = false.
window:CaptureDefaults()
-- ConfigurePersistence loads banks and applies the chosen startup config.

local ok, nameOrError = window:CreateConfig("Farm")
window:SaveConfig("Farm")
window:LoadConfig("Farm")
window:RenameConfig("Farm", "Gather")
window:SetAutoLoadConfig("Gather")
window:SetAutoLoadConfig(nil) -- disable auto-load for this scope

local names = window:ListConfigs() -- sorted defensive copy
local status = window:GetConfigStatus()
-- status.Scope, status.Active, status.AutoLoad, status.Dirty, status.Count
local json, errorMessage = window:ExportConfig("Gather")
window:ValidateConfig(json)
window:ImportConfig("Shared", json)       -- rejects duplicate names
window:ImportConfig("Shared", json, true) -- explicit overwrite
window:DeleteConfig("Gather")

local listener = window:OnConfigsChanged(function()
    -- Refresh your picker/status labels.
end)
listener:Disconnect()
```

Mutation methods return success plus a normalized name or error. ExportConfig
returns JSON or nil plus an error. ValidateConfig returns success plus any
validation error without changing live values. New names allow 1–32 UTF-8
characters, trim surrounding whitespace and reject control characters and
case-insensitive duplicates. Legacy longer profile names remain loadable.

Each game can hold 20 configs, with at most 32 game scopes in one settings
document. One config is limited to 50 KB; imported transfer text to 100 KB;
the full settings envelope remains limited to 200 KB. Capacity checks reject
before replacing stored values. SaveProfile remains available and uses the
same storage-budget checks.

The settings envelope keeps its existing Version=1, Current and Profiles
fields, adding Configurations.Version=1 and Banks. Each bank stores Profiles,
Current, Active and AutoLoad. Old settings without banks migrate their named
profiles into the first current game scope; their live setup is preserved.
The optional file adapter retains its existing backup/recovery behavior.
