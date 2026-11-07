--!nocheck
local PearlUI = require(game:GetService("ReplicatedStorage"):WaitForChild("PearlUI"))
local window = PearlUI.new({Title="My interface",Name="PearlStarter",Theme="Forest",
    ConfigScope="game_"..tostring(game.GameId)})
local tab = window:Tab({Name="General",Icon="house",Description="Your settings, ready to connect."})
local settings = tab:Section({Title="Settings",Id="general.settings",Column="Left",Icon="settings"})
local feedback = tab:Section({Title="Feedback",Id="general.feedback",Column="Right",Icon="bell"})
local value = feedback:Label({Label="Current value",Value="Off",Icon="info"})
settings:Toggle({Id="enabled",Label="Enabled",Default=false,Icon="power",
    Callback=function(v) value:Set(v and "On" or "Off") end})
settings:Slider({Id="amount",Label="Amount",Default=50,Icon="sliders-horizontal"})
settings:Dropdown({Id="choice",Label="Choice",Options={"One","Two","Three"},Icon="list"})
settings:Input({Id="name",Label="Name",Default="",Icon="text-cursor-input"})
feedback:Button({Label="Try a notification",Text="Preview",Icon="bell",Callback=function()
    window:Notify({Title="Ready",Description="Your callback is connected.",Preview=true})
end})
feedback:Button({Label="Restore initial values",Text="Reset…",Icon="rotate-ccw",Callback=function()
    window:RequestReset("All")
end})
-- Supply a real adapter here to retain settings. See docs/GettingStarted.md.
local ok,status = window:Ready()
if not ok then warn(status) end
return window
