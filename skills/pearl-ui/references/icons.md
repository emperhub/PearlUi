# Lucide icons in PearlUI

PearlUI includes all **2,029 canonical Lucide icons** from upstream commit
`53fab88ff9d1b48f4704b5b5b560d6b4d560bf4c`, plus **296 upstream aliases**.
The pack is embedded in the core module: no image uploads, asset IDs, extra
ModuleScripts or runtime icon downloads are needed.

```lua
local PearlUI = require(game.ReplicatedStorage.PearlUI)
local window = PearlUI.new({Title = "My interface", Theme = "Forest"})

window:Tab({Name = "Overview", Icon = "layout-dashboard"})
window:Tab({Name = "Economy", Icon = "wallet"})
window:Tab({Name = "Combat", Icon = "swords"})
window:Tab({Name = "Defense", Icon = "shield-check"})
window:Tab({Name = "Upgrades", Icon = "circle-arrow-up"})
window:Tab({Name = "Configs", Icon = "folder-cog"})
window:Tab({Name = "Settings", Icon = "settings"})
```

Use the canonical kebab-case name from [Lucide](https://lucide.dev/icons/).
`ShieldCheck`, `shield_check`, `lucide:shield-check` and `lucide-shield-check`
also resolve. Unknown names render `settings-2` as a fallback; the canvas
LucideIcon attribute reports the name actually rendered.

`PearlUI.Icons` is a sorted, frozen array of canonical names.
`PearlUI.IconAliases` is a frozen alias-to-canonical map. To search names:

```lua
local results = {}
for _, name in ipairs(PearlUI.Icons) do
    if name:find("shield", 1, true) then table.insert(results, name) end
end
```

[catalog.json](https://github.com/emperhub/PearlUi/blob/main/assets/lucide/catalog.json) includes every name, tag and
category. [aliases.json](https://github.com/emperhub/PearlUi/blob/main/assets/lucide/aliases.json) records upstream aliases.
Legacy PearlUI names general, appearance, controls, profiles and detach remain
compatible. An explicit tab Icon applies to both its sidebar and dock icon.
Icon support here is the existing tab Icon option; it does not invent an Icon
option for every control type.

Geometry is stored as compact strings and decoded/cached only when an icon is
used. Only requested icons create native Roblox strokes. Do not render the entire
catalog or create thousands of dropdown rows at once; filter/paginate large
pickers (for example, 50 results per page). Curves/ellipses are approximated by
short line segments; circles and equal-radius rounded rectangles use native
UIStroke shapes. Rendering preserves the existing theme bindings and Z layers.

## Regenerating the embedded pack

```text
python tools/fetch_lucide.py
python tools/build_icons.py
python tools/test_icon_geometry.py
python tools/build.py
python tools/sync_skill.py
python tools/validate_metadata.py
```

Fetch uses the exact SOURCE-COMMIT.txt revision. An existing upstream tar.gz can
be passed as `--archive <path>`. The compiler handles all path commands and SVG
primitives used by this revision, including compact arc flags, reflected cubic/
quadratic curves, lines, polygons and ellipses. New upstream shapes fail explicitly
instead of disappearing. Keep the Lucide ISC and Feather MIT notices in
assets/lucide/LICENSE and the generated source.
