--!nocheck
local PearlUI = require(game:GetService("ReplicatedStorage"):WaitForChild("PearlUI"))
local window = PearlUI.new({Title = "Pearl / Lucide", Name = "PearlLucideExample", Theme = "Forest"})
local examples = {
    {"Home", "house"}, {"Components", "component"}, {"Files", "folder-open"},
    {"Security", "shield-check"}, {"Analytics", "chart-no-axes-combined"},
    {"Notifications", "bell"}, {"Settings", "settings"},
}
for _,entry in ipairs(examples) do
    local name, icon = entry[1], entry[2]
    local tab = window:Tab({Name = name, Icon = icon, Description = "Lucide icon: " .. icon})
    local preview = tab:Section({Title = "Preview", Column = "Left"})
    preview:Label({Label = "Icon name", Value = icon})
    preview:Button({Label = "Show usage", Text = "View code", Callback = function()
        window:Confirm({Title = "Use this icon", ReadOnly = true, ConfirmText = "Done",
            Text = 'window:Tab({Name = "' .. name .. '", Icon = "' .. icon .. '"})'})
    end})
    local catalog = tab:Section({Title = "Library", Column = "Right"})
    catalog:Label({Label = "Canonical icons", Value = tostring(#PearlUI.Icons)})
    catalog:Label({Label = "Source", Value = "Lucide"})
end
return window
