--!nocheck
-- Client preview with HttpGet/loadstring; use Default.client.luau in Studio.
local SOURCE_URL = "https://raw.githubusercontent.com/emperhub/PearlUi/4a731f911bc3a3426734e3e24057fba3fded17e7/src/PearlUI.luau"
local ok, source = pcall(function() return game:HttpGet(SOURCE_URL) end)
assert(ok and type(source) == "string" and #source > 0, "Could not download PearlUI: " .. tostring(source))
assert(type(loadstring) == "function", "This preview needs loadstring; use the Studio ModuleScript example otherwise")
local chunk, compileError = loadstring(source, "@PearlUI-v1.0.2")
assert(chunk, compileError)
local PearlUI = chunk()
assert(type(PearlUI) == "table" and PearlUI.Version == "1.0.2", "Unexpected PearlUI version")

local window = PearlUI.new({
    Title = "Pearl / GitHub example", Name = "PearlRemoteExample", Theme = "Forest",
    Columns = 2, ConfigScope = "game_" .. tostring(game.GameId),
})
local tab = window:Tab({Name = "General", Icon = "general", Description = "Loaded from GitHub. Your own interface starts here."})
local interface = tab:Section({Title = "Interface", Id = "remote.interface", Column = "Left"})
local behavior = tab:Section({Title = "Behavior", Id = "remote.behavior", Column = "Right"})
local controls, events = {}, {}
local result = behavior:Label({Label = "Last action", Value = "Ready"})
local function record(name, value)
    table.insert(events, {Name = name, Value = value})
    result:Set(name .. ": " .. tostring(value))
end
controls.Theme = interface:Dropdown({Id = "theme", Label = "Theme", ResetGroup = "Appearance",
    Options = PearlUI.GetThemes(), Default = "Forest", Callback = function(value)
        window:SetTheme(value); record("Theme", value)
    end})
controls.Notifications = interface:Toggle({Id = "notifications", Label = "Notifications", Default = true,
    Callback = function(value) window.NotificationsEnabled = value; record("Notifications", value) end})
controls.Opacity = interface:Slider({Id = "opacity", Label = "Panel opacity", ResetGroup = "Appearance",
    Min = 75, Max = 100, Default = 97, Suffix = "%",
    Callback = function(value) window:SetOpacity(value / 100); record("Opacity", value) end})
controls.Message = interface:Input({Id = "message", Label = "Your message", Default = "Hello from GitHub", MaxLength = 80,
    Callback = function(value) record("Message", value) end})
controls.Key = behavior:Keybind({Id = "key", Label = "Toggle menu", Default = "RightShift",
    Callback = function(value) window:SetToggleKey(value); record("Key", value) end})
controls.Motion = behavior:Toggle({Id = "motion", Label = "Reduce motion", Default = false,
    Callback = function(value) window.ReduceMotion = value; record("Reduce motion", value) end})
behavior:Button({Label = "Try a notification", Text = "Preview", Primary = true, Callback = function()
    window:Notify({Title = "Pearl UI", Description = controls.Message:Get(), Preview = true})
    record("Notification", controls.Message:Get())
end})
behavior:Button({Label = "Floating section", Text = "Detach", Callback = function() interface:Detach() end})
behavior:Button({Label = "Return floating section", Text = "Dock", Callback = function() interface:Dock() end})
behavior:Button({Label = "Restore this example", Text = "Reset…", Callback = function() window:RequestReset("All") end})
window:Ready()
window:Notify({Title = "Loaded from GitHub", Description = "PearlUI " .. PearlUI.Version .. " is ready.", Preview = true})
-- No persistence adapter: this isolated example does not change saved demo configs.
return {Window = window, Controls = controls, Events = events, Section = interface, Result = result,
    Version = PearlUI.Version, SourceURL = SOURCE_URL}
