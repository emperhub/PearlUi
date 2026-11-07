--!nocheck
local PearlUI = require(game:GetService("ReplicatedStorage"):WaitForChild("PearlUI"))
local window = PearlUI.new({
    Title = "Pearl UI", Name = "PearlUI", Theme = "Light",
    Columns = 2, Scale = 1, ReduceMotion = false, AnimationSpeed = 0.2,
    ToggleKey = Enum.KeyCode.RightShift,
    -- Per-game application policy; the core constructor defaults to "global".
    ConfigScope = "game_" .. tostring(game.GameId),
})
local tab = window:Tab({Name = "General", Icon = "general"})
local left = tab:Section({Title = "Interface", Id = "general.interface", Column = "Left"})
local right = tab:Section({Title = "Controls", Id = "general.controls", Column = "Right"})
left:Dropdown({Id = "theme", Label = "Theme", ResetGroup = "Appearance",
    Options = PearlUI.GetThemes(), Default = "Light",
    Callback = function(value) window:SetTheme(value) end})
left:Toggle({Id = "notifications", Label = "Show notifications", Default = true,
    Callback = function(value) window.NotificationsEnabled = value end})
left:Button({Label = "Try a notification", Text = "Preview",
    Callback = function() window:Notify({Title = "Pearl UI", Description = "Ready to build.", Preview = true}) end})
right:Keybind({Id = "toggleKey", Label = "Toggle menu", Default = "RightShift",
    Callback = function(value) window:SetToggleKey(value) end})
right:Toggle({Id = "reduceMotion", Label = "Reduce motion", Default = false,
    Callback = function(value) window.ReduceMotion = value end})
right:Slider({Id = "animation", Label = "Animation speed", Min = 0.05, Max = 0.6,
    Step = 0.05, Default = 0.2, Suffix = " s",
    Callback = function(value) window.AnimationSpeed = value end})
window:CaptureDefaults()
-- Add a real adapter after this point; see docs/Persistence.md. This example
-- intentionally does not claim to retain settings across sessions.
right:Button({Label = "Restore initial setup", Text = "Reset…",
    Callback = function() window:RequestReset("All") end})
