--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PearlUI = require(ReplicatedStorage:WaitForChild("PearlUI"))

-- BEGIN STORAGE ADAPTER
local persistenceAdapter
local persistenceModule = ReplicatedStorage:FindFirstChild("PearlUIPersistence")
if persistenceModule then
	local ok, adapter = pcall(require, persistenceModule)
	if ok then persistenceAdapter = adapter end
end
-- END STORAGE ADAPTER

local window = PearlUI.new({ Title = "Pearl UI", Name = "PearlUIDemo", Theme = "Light", Columns = 2, ConfigScope = "game_" .. tostring(game.GameId) })
local general = window:Tab({ Name = "General", Icon = "layout-dashboard", Description = "A calmer space. Made for the way you play." })
local appearance = window:Tab({ Name = "Appearance", Icon = "appearance", Description = "Your palette, your atmosphere." })
local controls = window:Tab({ Name = "Controls", Icon = "sliders-horizontal", Description = "Small details. A more comfortable workspace." })
local profiles = window:Tab({ Name = "Profiles", Icon = "folder-cog", Description = "Keep a setup you can come back to." })
local defaultLayout

local interface = general:Section({ Title = "Interface", Column = "Left" })
interface:Toggle({ Id = "showNotifications", Label = "Show notifications", Default = true, Callback = function(value) window.NotificationsEnabled = value end })
interface:Dropdown({ Id = "theme", ResetGroup = "Appearance", Label = "Theme", Options = PearlUI.GetThemes(), Default = "Light", Callback = function(value) window:SetTheme(value) end })

local behavior = general:Section({ Title = "Controls", Column = "Right" })
behavior:Keybind({ Id = "menuKey", Label = "Toggle menu", Default = "RightShift", Callback = function(value) window:SetToggleKey(value) end })
behavior:Toggle({ Id = "reduceMotion", Label = "Reduce motion", Default = false, Callback = function(value) window.ReduceMotion = value end })
behavior:Slider({ Id = "animation", Label = "Animation speed", Min = 0.05, Max = 0.5, Step = 0.05, Default = 0.2, Suffix = " s", Callback = function(value) window.AnimationSpeed = value end })

local favorites = interface
local favoriteSummary
favorites:Dropdown({
	Id = "favorites", Label = "Favorite tools", Multi = true, Searchable = true,
	Options = { "Interface", "Appearance", "Controls", "Profiles", "Notifications", "Color picker", "Floating panels" },
	Default = { "Appearance", "Profiles" },
	Callback = function(values) if favoriteSummary then favoriteSummary:Set(#values == 0 and "None" or table.concat(values, ", ")) end end,
})
favoriteSummary = favorites:Label({ Label = "Selected", Value = "Appearance, Profiles" })

local accentColors = {
	Blue = Color3.fromRGB(0, 113, 246), Violet = Color3.fromRGB(151, 101, 238),
	Rose = Color3.fromRGB(231, 105, 163), Mint = Color3.fromRGB(44, 164, 139),
}
local palette = appearance:Section({ Title = "Personalization", Column = "Left" })
local accentPicker
palette:Dropdown({ Id = "accent", ResetGroup = "Appearance", Label = "Accent preset", Options = { "Blue", "Violet", "Rose", "Mint" }, Default = "Blue", Callback = function(value) if accentPicker then accentPicker:Set(accentColors[value]) else window:SetAccent(accentColors[value]) end end })
accentPicker = palette:ColorPicker({ Id = "accentColor", ResetGroup = "Appearance", Label = "Custom accent", Default = accentColors.Blue, Alpha = 1, Callback = function(color) window:SetAccent(color) end })
window._accentControl = accentPicker
palette:Button({ Label = "Use this theme's accent", Text = "Use theme color", Callback = function() window:ResetAccent() end })
palette:Slider({ Id = "opacity", ResetGroup = "Appearance", Label = "Panel opacity", Min = 75, Max = 100, Default = 97, Suffix = "%", Callback = function(value) window:SetOpacity(value / 100) end })
palette:Button({ Label = "Try a notification", Text = "Preview", Callback = function() window:Notify({ Title = "Hello from Pearl", Description = "A little less noise. A little more you.", Preview = true }) end })
palette:Button({ Label = "Reset appearance", Text = "Reset…", Callback = function() window:RequestReset("Appearance") end })
local panels = appearance:Section({ Title = "Floating panels", Column = "Right" })
panels:Label({ Label = "Pull a section out", Value = "Use the detach icon" })
panels:Button({ Label = "Detach personalization", Text = "Detach", Callback = function() palette:Detach() end })
panels:Button({ Label = "Bring all panels home", Text = "Dock all", Callback = function() for _, section in ipairs(window.Sections) do section:Dock() end end })

local interaction = controls:Section({ Title = "Workspace", Column = "Left" })
interaction:Button({ Label = "Compact mode", Text = "Minimize", Callback = function() window:SetMinimized(true) end })
interaction:Button({ Label = "Fill the screen", Text = "Maximize", Callback = function() window:SetMaximized(not window.Maximized) end })
interaction:Button({ Label = "Reset window size", Text = "Reset", Callback = function() window:SetSize(900, 610) end })
interaction:Button({ Label = "Reset control values", Text = "Reset…", Callback = function() window:RequestReset("Controls") end })
local components = controls:Section({ Title = "Component playground", Column = "Right" })
local example
local function createExample()
	return components:Button({ Label = "Example action", Text = "Try it", Primary = true, Callback = function() window:Notify({ Title = "Action completed", Description = "This control is enabled and ready." }) end })
end
example = createExample()
local disableExample = components:Toggle({ Id = "disableExample", Label = "Disable example", Default = false, Callback = function(value) if not example.Destroyed then example:SetDisabled(value, "Turn off Disable example to use this action.") end end })
local showExample = components:Toggle({ Id = "showExample", Label = "Show example", Default = true, Callback = function(value) if not example.Destroyed then example:SetVisible(value) end end })
local exampleLabel = components:Input({ Id = "exampleLabel", Label = "Action label", Default = "Example action", MaxLength = 32, Callback = function(value) if not example.Destroyed then example:SetLabel(value) end end })
components:Button({ Label = "Remove example", Text = "Remove", Callback = function() example:Destroy() end })
components:Button({ Label = "Recreate example", Text = "Recreate", Callback = function()
	if example.Destroyed then example = createExample(); example:SetLabel(exampleLabel:Get()); example:SetDisabled(disableExample:Get(), "Turn off Disable example to use this action."); example:SetVisible(showExample:Get()) end
end })
local about = interaction
about:Label({ Label = "Version", Value = PearlUI.Version })
about:Label({ Label = "Dependencies", Value = "None" })
about:Label({ Label = "Made for", Value = "Roblox / Luau" })

local profile = profiles:Section({ Title = "Configurations", Id = "Profiles.Your profiles", Column = "Left" })
local transfer = profiles:Section({ Title = "Transfer & storage", Id = "Profiles.Window layout", Column = "Right" })
local name = profile:Input({ Id = "profileName", Persist = false, Label = "Config name", Default = "", Placeholder = "Name your config", MaxLength = 32 })
local selected, automatic, activeLabel, refresh
local refreshing = false
selected = profile:Dropdown({ Id = "selectedConfig", Persist = false, Label = "Saved configs", Options = {"(no configs)"}, Callback = function(value)
	if refreshing then return end
	name:Set(value, true)
	if automatic then automatic:Set(window:GetConfigStatus().AutoLoad == value, true) end
end })
local function feedback(ok, message, title)
	window:Notify({Title = ok and title or "Could not update config", Description = ok and "Your config list has been updated." or tostring(message), Preview = true})
end
profile:Button({ Label = "Create from current setup", Text = "Create", Primary = true, Callback = function()
	local ok, result = window:CreateConfig(name:Get()); if ok then refresh(result) end; feedback(ok, result, "Config created")
end })
profile:Button({ Label = "Update selected config", Text = "Save changes", Callback = function()
	local ok, result = window:SaveConfig(selected:Get()); if ok then refresh(result) end; feedback(ok, result, "Config updated")
end })
profile:Button({ Label = "Apply selected config", Text = "Load", Callback = function()
	local target = selected:Get()
	local function apply() local ok, result = window:LoadConfig(target); if ok then refresh(target) end; feedback(ok, result, "Config loaded") end
	if window:GetConfigStatus().Dirty then window:Confirm({Title = "Load config?", Description = "Unsaved edits to the active config will be replaced.", ConfirmText = "Load", OnConfirm = apply}) else apply() end
end })
profile:Button({ Label = "Rename selected config", Text = "Rename", Callback = function()
	local ok, result = window:RenameConfig(selected:Get(), name:Get()); if ok then refresh(result) end; feedback(ok, result, "Config renamed")
end })
profile:Button({ Label = "Remove selected config", Text = "Delete…", Callback = function()
	local target = selected:Get()
	if not window._profiles[target] then feedback(false, "Select a saved config first."); return end
	window:Confirm({Title = "Delete config?", Description = "Delete \"" .. target .. "\"? Your current settings will stay as they are.", ConfirmText = "Delete", OnConfirm = function()
		local ok, result = window:DeleteConfig(target); refresh(); feedback(ok, result, "Config deleted")
	end})
end })
automatic = profile:Toggle({ Id = "autoLoadConfig", Persist = false, Label = "Auto-load selected", Default = false, Callback = function(value)
	local ok, result = window:SetAutoLoadConfig(value and selected:Get() or nil); refresh(); if not ok then feedback(ok, result) end
end })
activeLabel = profile:Label({Label = "Active config", Value = "None"})
profile:Label({Label = "Config scope", Value = "This game"})
local function updateStatus()
	local status = window:GetConfigStatus()
	activeLabel:Set(status.Active and (status.Active .. (status.Dirty and " · edited" or " · saved")) or "None loaded")
end
refresh = function(preferred)
	if refreshing then return end
	refreshing = true
	local names = window:ListConfigs()
	local status = window:GetConfigStatus()
	local choice = preferred or (window._profiles[selected:Get()] and selected:Get()) or status.Active or names[1] or "(no configs)"
	selected:SetOptions(#names > 0 and names or {"(no configs)"}, choice, true)
	selected:SetDisabled(#names == 0, #names == 0 and "Create or import a config first." or nil)
	automatic:SetDisabled(#names == 0)
	automatic:Set(status.AutoLoad == choice, true)
	if preferred then name:Set(preferred, true) end
	updateStatus()
	refreshing = false
end
window:OnConfigsChanged(function() refresh(window:GetPersistenceStatus() == "Loading" and window:GetConfigStatus().Active or nil) end)
local function statusTick()
	updateStatus()
	window:_later(0.75, statusTick)
end
window:_later(0.75, statusTick)
transfer:Button({ Label = "Share selected config", Text = "Export JSON", Callback = function()
	local raw, message = window:ExportConfig(selected:Get())
	if not raw then feedback(false, message); return end
	window:Confirm({Title = "Export config", Description = "Select and copy the text. Paste it into Import on another setup.", Text = raw, ReadOnly = true, ConfirmText = "Done"})
end })
transfer:Button({ Label = "Paste a shared config", Text = "Import JSON…", Callback = function()
	local target = name:Get():match("^%s*(.-)%s*$")
	if target == "" then feedback(false,"Enter a config name first.");return end
	window:Confirm({Title = "Import config", Description = "Paste JSON below. It will be saved under the config name you entered.", Text = "", ConfirmText = "Import", Validate = function(raw) return window:ValidateConfig(raw) end, OnConfirm = function(raw)
		local function apply(overwrite)
			local ok, result = window:ImportConfig(target, raw, overwrite); if ok then refresh(result) end; feedback(ok, result, "Config imported")
		end
		if window._profiles[target] then window:Confirm({Title = "Replace existing config?", Description = "The saved values in \"" .. target .. "\" will be replaced. Current settings will not be applied automatically.", ConfirmText = "Replace", OnConfirm = function() apply(true) end}) else apply(false) end
	end})
end })
local storageStatus = transfer:Label({ Label = "Auto-save", Value = persistenceAdapter and "Connecting…" or "Not connected" })
transfer:Button({ Label = "Write latest settings", Text = "Save now", Callback = function()
	local ok, message = window:SaveSettings()
	window:Notify({ Title = ok and "Settings saved" or "Could not save", Description = ok and "Your settings are ready for next time." or message, Preview = true })
end })
transfer:Button({ Label = "Read saved settings", Text = "Reload", Callback = function()
	local ok, loaded = window:LoadSettings(); refresh()
	window:Notify({ Title = ok and "Settings loaded" or "Could not load", Description = ok and (loaded and "Your saved setup has been restored." or "No saved setup yet.") or loaded, Preview = true })
end })
transfer:Button({ Label = "Reset window layout", Text = "Reset layout…", Callback = function() window:RequestReset("Layout") end })
transfer:Button({ Label = "Reset all preferences", Text = "Reset all…", Callback = function() window:RequestReset("All") end })

-- BEGIN SHOWCASE
local showcaseModule = ReplicatedStorage:FindFirstChild("PearlUIShowcase")
if showcaseModule then window._testBench = require(showcaseModule)(PearlUI, window) end
-- END SHOWCASE

window:SelectTab(general)
defaultLayout = window:ExportLayout()
window:SaveProfile("Default")
window:CaptureDefaults()
refresh()
if persistenceAdapter then
	window:ConfigurePersistence({ Adapter = persistenceAdapter, Key = "demo", Debounce = 1.5, OnStatus = function(status)
		storageStatus:Set(status == "Error" and "Save unavailable — retry" or status)
	end })
end

if window._testBench then window._testBench.Sync() end

-- Return a handle for the standalone preview and runtime test harness.
return window
