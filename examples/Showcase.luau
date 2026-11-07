--!nocheck
return function(PearlUI, window)
	local Http = game:GetService("HttpService")
	local bench = { Coverage = {}, Actions = {}, Controls = {}, Factories = {}, Results = {}, CallbackCount = 0, ConfigEvents = 0 }
	local components = window:Tab({Name="Components",Icon="controls",Description="Every control. Live values, callbacks and editable states."})
	local windows = window:Tab({Name="Window lab",Icon="general",Description="Try window geometry, the dock, panels and navigation."})
	local tools = window:Tab({Name="API tools",Icon="profiles",Description="Inspect data and test persistence in an isolated sample window."})
	local showcase = components:Section({Title="All components",Column="Left"})
	local controlActions = components:Section({Title="Control inspector",Column="Right"})
	local geometry = windows:Section({Title="Window & dock",Column="Left"})
	local panels = windows:Section({Title="Panels & navigation",Column="Right"})
	local sandboxActions = tools:Section({Title="Sample window",Column="Left"})
	local dataActions = tools:Section({Title="Data & feedback",Column="Right"})
	local lastResult, callbackLabel, valueLabel
	local function describe(value)
		if value == nil then return "nil" end
		if typeof(value)=="Color3" then return "#"..value:ToHex():upper() end
		if type(value)=="table" then local ok,json=pcall(Http.JSONEncode,Http,value);return ok and json or tostring(value) end
		return tostring(value)
	end
	local function report(name,value)
		local text=name.." → "..describe(value)
		table.insert(bench.Results,text);if #bench.Results>30 then table.remove(bench.Results,1)end
		if lastResult then lastResult:Set(text)end
		return value
	end
	local function register(key,location,fn)
		bench.Coverage[key]=location
		if fn then bench.Actions[key]=fn end
	end
	function bench.Run(key,...)
		assert(bench.Actions[key],"No runnable showcase action: "..key)
		local ok,result=pcall(bench.Actions[key],...)
		if ok then report(key,result)else report(key,"Error: "..tostring(result))end
		return ok,result
	end
	local function run(name,fn)
		local ok,result=pcall(fn);if ok then report(name,result)else report(name,"Error: "..tostring(result))end;return ok,result
	end
	local function action(section,label,text,key,fn)
		register(key,section.Title.." / "..label,fn)
		return section:Button({Label=label,Text=text,Callback=function()bench.Run(key)end})
	end
	local function menu(section,label,entries)
		local names={};for _,entry in ipairs(entries)do table.insert(names,entry[1]);register(entry[2],section.Title.." / "..label.." / "..entry[1],entry[3])end
		local selected=section:Dropdown({Id="lab.menu."..label,Persist=false,Label=label,Options=names})
		section:Button({Label="Run selected action",Text="Run",Primary=true,Callback=function()
			for _,entry in ipairs(entries)do if entry[1]==selected:Get()then bench.Run(entry[2]);break end end
		end})
		return selected
	end
	local function changed(name,value,alpha)
		bench.CallbackCount+=1
		if callbackLabel then callbackLabel:Set(bench.CallbackCount)end
		if valueLabel then valueLabel:Set(name..": "..describe(value)..(alpha and " / "..tostring(alpha) or ""))end
	end
	local definitions={
		{"Toggle","Toggle",{Default=true}},
		{"Slider","Slider",{Min=0,Max=100,Step=5,Default=35,Suffix="%"}},
		{"Single dropdown","Dropdown",{Options={"Alpha","Beta","Gamma"},Default="Alpha"}},
		{"Multi dropdown","Dropdown",{Options={"Alpha","Beta","Gamma","Delta"},Multi=true,Default={"Alpha","Gamma"}}},
		{"No-search dropdown","Dropdown",{Options={"One","Two","Three"},Searchable=false}},
		{"Color picker","ColorPicker",{Default="#55A879",Alpha=0.7}},
		{"Text input","Input",{Default="Hello, Pearl",MaxLength=64,Placeholder="Type here"}},
		{"Keybind","Keybind",{Default="F6",OnPressed=function(key)report("Key pressed",key.Name)end}},
		{"Button","Button",{Text="Press me",Primary=true}},
		{"Label","Label",{Value="Live output"}},
	}
	local names={}
	for _,definition in ipairs(definitions)do
		local name,kind,settings=definition[1],definition[2],definition[3]
		table.insert(names,name)
		bench.Factories[name]=function()
			local options=table.clone(settings);options.Label=name;options.Id="lab.control."..name;options.Persist=false
			options.Callback=function(value,alpha)changed(name,value,alpha)end
			local control=showcase[kind](showcase,options);bench.Controls[name]=control;return control
		end
		bench.Factories[name]()
		register("Section."..kind,"Components / All components / "..name)
	end
	local target=controlActions:Dropdown({Id="lab.target",Persist=false,Label="Target control",Options=names})
	local function current()
		local control=bench.Controls[target:Get()];assert(control and not control.Destroyed,"Recreate the selected control first.");return control
	end
	local function setExample(silent)
		local c=current();local values={Slider=75,Input="Updated in the inspector",Keybind="F7",ColorPicker="#C777AA",Label="Updated label"}
		local value=values[c.Type]
		if c.Type=="Toggle" then value=not c:Get()
		elseif c.Type=="Dropdown" then value=c.Multi and {c.Options[#c.Options]} or c.Options[#c.Options]
		elseif c.Type=="Button" then return "Buttons use Activated; select a value control." end
		c:Set(value,silent);return c:Get()
	end
	menu(controlActions,"Control API",{
		{"Read value","Control.Get",function()return current():Get()end},
		{"Serialize value","Control.Serialize",function()return current():Serialize()end},
		{"Set sample value","Control.Set",function()return setExample(false)end},
		{"Set silently","Control.SetSilent",function()local n=bench.CallbackCount;setExample(true);return "Callbacks: "..n.." → "..bench.CallbackCount end},
		{"Attach callback","Control.OnChanged",function()local c=current();c:OnChanged(function(v,a)changed(c.Label,v,a)end);return "Callback attached"end},
		{"Remove callback","Control.RemoveCallback",function()current():OnChanged(nil);return "Callback removed"end},
		{"Can interact?","Control.CanInteract",function()return current():CanInteract()end},
		{"Disable / enable","Control.SetDisabled",function()local c=current();c:SetDisabled(not c.Disabled,"Enable this control from the inspector.");return c.Disabled and "Disabled" or "Enabled"end},
		{"Hide / show","Control.SetVisible",function()local c=current();c:SetVisible(not c.Visible);return c.Visible and "Visible" or "Hidden"end},
		{"Change label","Control.SetLabel",function()local c=current();c:SetLabel(c.Label==target:Get() and "Renamed example" or target:Get());return c.Label end},
		{"Close editor","Control.Close",function()current():Close();return "Editor closed"end},
		{"Destroy selected","Control.Destroy",function()current():Destroy();return "Destroyed; choose Recreate next."end},
		{"Recreate selected","Control.Recreate",function()local c=bench.Controls[target:Get()];if c and not c.Destroyed then c:Destroy()end;bench.Factories[target:Get()]();return "Recreated with its original ID"end},
	})
	callbackLabel=controlActions:Label({Label="Callback count",Value=0})
	valueLabel=controlActions:Label({Label="Last value",Value="Interact with a control"})
	lastResult=controlActions:Label({Label="Action result",Value="Choose an action and press Run"})
	local function dropdown()
		local c=current();assert(c.Type=="Dropdown","Select a dropdown first.");return c
	end
	local function openEditor(c)
		assert(c:CanInteract(),"Show and enable the selected control first.")
		window:SelectTab(c.Section.Tab)
		if c.Section.Detached then c.Section:Reveal()end
		local scroll=c.Section.Detached and c.Section.FloatScroll or c.Section.Tab.Page
		local y=scroll.CanvasPosition.Y+(c.Row.AbsolutePosition.Y-scroll.AbsolutePosition.Y)/window._actualScale-12
		scroll.CanvasPosition=Vector2.new(0,math.max(0,y))
		window:_later(.03,function()if not c.Destroyed then c:Open()end end)
		return "Editor opening at the selected control"
	end
	menu(controlActions,"Dropdown API",{
		{"Open dropdown","Dropdown.Open",function()return openEditor(dropdown())end},
		{"Replace options","Dropdown.SetOptions",function()local c=dropdown();c:SetOptions({"New one","New two","New three"});return c:Get()end},
	})
	local function picker()
		local c=bench.Controls["Color picker"];assert(c and not c.Destroyed,"Recreate the color picker first.");return c
	end
	menu(controlActions,"Color API",{
		{"Open color editor","ColorPicker.Open",function()return openEditor(picker())end},
		{"Read color + alpha","ColorPicker.Get",function()local c,a=picker():Get();return describe(c).." / "..a end},
		{"Set alpha to 35%","ColorPicker.SetAlpha",function()picker():SetAlpha(.35);return picker():Serialize()end},
		{"Set HSV green","ColorPicker.SetHSV",function()picker():SetHSV(.38,.55,.65);return picker():Serialize()end},
	})
	geometry:Slider({Id="lab.scale",Persist=false,Label="Interface scale",Min=.65,Max=1.3,Step=.05,Default=window.Scale,Callback=function(v)window:SetScale(v);report("Scale",v)end})
	register("Window.SetScale","Window lab / Interface scale")
	geometry:Slider({Id="lab.opacity",Persist=false,Label="Panel opacity",Min=75,Max=100,Default=window.Opacity*100,Suffix="%",Callback=function(v)window:SetOpacity(v/100);report("Opacity",v)end})
	register("Window.SetOpacity","Window lab / Panel opacity")
	geometry:Dropdown({Id="lab.columns",Persist=false,Label="Section columns",Options={"Two","One"},Callback=function(v)window:SetColumns(v=="Two" and 2 or 1);report("Columns",window.Columns)end})
	register("Window.SetColumns","Window lab / Section columns")
	geometry:Dropdown({Id="lab.size",Persist=false,Label="Window size",Options={"Default 900 × 610","Compact 680 × 420","Wide 1200 × 760","Custom / drag the corner"},Callback=function(v)
		if v:find("Compact")then window:SetSize(680,420)elseif v:find("Wide")then window:SetSize(1200,760)elseif v:find("Default")then window:SetSize(900,610)end
		report("Size",window.WindowSize)
	end})
	register("Window.SetSize","Window lab / Window size")
	menu(geometry,"Window actions",{
		{"Hide for two seconds","Window.SetVisible",function()window:SetVisible(false);window:_later(2,function()window:SetVisible(true)end);return "Returns in two seconds"end},
		{"Minimize to dock","Window.SetMinimized",function()window:SetMinimized(true);return "Use Open Pearl UI on the dock"end},
		{"Maximize / restore","Window.SetMaximized",function()window:SetMaximized(not window.Maximized);return window.Maximized end},
		{"Stow dock left","Window.StowDock",function()window:SetMinimized(true);window:StowDock("Left");return "Use the handle on the left edge"end},
		{"Stow dock right","Window.StowDockRight",function()window:SetMinimized(true);window:StowDock("Right");return "Use the handle on the right edge"end},
		{"Reveal dock","Window.RevealDock",function()window:SetMinimized(true);window:RevealDock();return "Dock revealed"end},
	})
	local sectionNames,sections={},{}
	for _,s in ipairs(window.Sections)do local name=s.Tab.Name.." / "..s.Title;table.insert(sectionNames,name);sections[name]=s end
	local selectedPanel=panels:Dropdown({Id="lab.panel",Persist=false,Label="Target panel",Options=sectionNames})
	menu(panels,"Panel actions",{
		{"Detach selected","Section.Detach",function()sections[selectedPanel:Get()]:Detach();return selectedPanel:Get()end},
		{"Reveal selected","Section.Reveal",function()sections[selectedPanel:Get()]:Reveal();return selectedPanel:Get()end},
		{"Dock selected","Section.Dock",function()sections[selectedPanel:Get()]:Dock();return selectedPanel:Get()end},
	})
	panels:Button({Label="Bring every panel home",Text="Dock all",Callback=function()for _,s in ipairs(window.Sections)do s:Dock()end;report("Panels","All docked")end})
	local tabNames={};for _,tab in ipairs(window.Tabs)do table.insert(tabNames,tab.Name)end
	local selectedTab=panels:Dropdown({Id="lab.tab",Persist=false,Label="Jump to tab",Options=tabNames})
	action(panels,"Open selected tab","Open","Window.SelectTab",function()window.Search.Text="";window:SelectTab(selectedTab:Get());return selectedTab:Get()end)
	action(panels,"Refresh user card","Refresh","Window.RefreshUserProfile",function()window:RefreshUserProfile();return window.UserDisplayName.Text end)
	panels:Keybind({Id="lab.menuKey",Persist=false,Label="Menu toggle key",Default=window.ToggleKey.Name,Callback=function(v)window:SetToggleKey(v);report("Menu key",v)end})
	register("Window.SetToggleKey","Window lab / Menu toggle key")
	local sample,sampleFlag,memory,listener
	local function createSample()
		if sample and not sample.Destroyed then return sample end
		if listener then listener:Disconnect();listener=nil end
		sample=PearlUI.new({Name="PearlUISample",Title="Pearl sample",Theme=window.Theme,ReduceMotion=window.ReduceMotion,DisplayOrder=window.Gui.DisplayOrder+2,ConfigScope="showcase"})
		sample:SetSize(680,420)
		local tab=sample:Tab({Name="Sample",Description="An isolated window for lifecycle and data tests."})
		local section=tab:Section("Sample controls")
		sampleFlag=section:Toggle({Id="sample.flag",Label="Sample value",Default=false,Callback=function(v)report("Sample value",v)end})
		section:Button({Label="Close this sample",Text="Destroy sample",Callback=function()sample:Destroy();report("Sample","Destroyed")end})
		sample:CaptureDefaults();bench.Sample=sample;return sample
	end
	local function sampleWindow()return createSample()end
	action(sandboxActions,"Open an isolated window","Open sample","PearlUI.new",function()createSample();return "Sample window opened"end)
	register("Window.Tab","API tools / Open an isolated window")
	register("Tab.Section","API tools / Open an isolated window")
	menu(sandboxActions,"Lifecycle & reset",{
		{"Destroy sample window","Window.Destroy",function()if sample then sample:Destroy()end;return "Main demo is still available"end},
		{"Capture sample defaults","Window.CaptureDefaults",function()sampleWindow():CaptureDefaults();return "Sample defaults captured"end},
		{"Toggle sample value","Sample.Toggle",function()sampleWindow();sampleFlag:Set(not sampleFlag:Get());return sampleFlag:Get()end},
		{"Reset sample controls now","Window.Reset",function()local w=sampleWindow();local ok,e=w:Reset("Controls");assert(ok,e);return sampleFlag:Get()end},
		{"Request sample reset","Window.RequestReset",function()sampleWindow():RequestReset("All");return "Confirm or cancel in the sample"end},
	})
	menu(sandboxActions,"Storage adapter",{
		{"Connect memory storage","Window.ConfigurePersistence",function()local w=sampleWindow();memory=memory or {};local adapter={Load=function(k)return memory[k]end,Save=function(k,v)memory[k]=v;return true end};local ok,e=w:ConfigurePersistence({Adapter=adapter,Key="sample",AutoSave=false});assert(ok,e);return w:GetPersistenceStatus()end},
		{"Save sample settings","Window.SaveSettings",function()local ok,e=sampleWindow():SaveSettings();assert(ok,e);return "Sample settings saved"end},
		{"Reload sample settings","Window.LoadSettings",function()local ok,e=sampleWindow():LoadSettings();assert(ok,e);return "Sample settings restored"end},
		{"Read storage status","Window.GetPersistenceStatus",function()return sampleWindow():GetPersistenceStatus()end},
		{"Disconnect sample storage","Window.DisablePersistence",function()sampleWindow():DisablePersistence(true);return sampleWindow():GetPersistenceStatus()end},
	})
	local configName=sandboxActions:Input({Id="lab.configName",Persist=false,Label="Sample config name",Default="Sample",MaxLength=32})
	local rename=sandboxActions:Input({Id="lab.rename",Persist=false,Label="New sample name",Default="Renamed",MaxLength=32})
	local configJSON=""
	menu(sandboxActions,"Sample configs",{
		{"Create config","Window.CreateConfig",function()local ok,e=sampleWindow():CreateConfig(configName:Get());assert(ok,e);return e end},
		{"Save config changes","Window.SaveConfig",function()local ok,e=sampleWindow():SaveConfig(configName:Get());assert(ok,e);return e end},
		{"Load config","Window.LoadConfig",function()local ok,e=sampleWindow():LoadConfig(configName:Get());assert(ok,e);return e end},
		{"Rename config","Window.RenameConfig",function()local ok,e=sampleWindow():RenameConfig(configName:Get(),rename:Get());assert(ok,e);configName:Set(e,true);return e end},
		{"Delete config","Window.DeleteConfig",function()local ok,e=sampleWindow():DeleteConfig(configName:Get());assert(ok,e);return e end},
		{"Set startup config","Window.SetAutoLoadConfig",function()local ok,e=sampleWindow():SetAutoLoadConfig(configName:Get());assert(ok,e);return e end},
		{"Clear startup config","Window.ClearAutoLoadConfig",function()local ok,e=sampleWindow():SetAutoLoadConfig(nil);assert(ok,e);return "Auto-load cleared"end},
		{"List configs","Window.ListConfigs",function()return sampleWindow():ListConfigs()end},
		{"Read config status","Window.GetConfigStatus",function()return sampleWindow():GetConfigStatus()end},
		{"Export to sample buffer","Window.ExportConfig",function()local raw,e=sampleWindow():ExportConfig(configName:Get());assert(raw,e);configJSON=raw;return "JSON stored in the sample buffer"end},
		{"Validate sample buffer","Window.ValidateConfig",function()local ok,e=sampleWindow():ValidateConfig(configJSON);assert(ok,e);return "Valid config JSON"end},
		{"Import as a copy","Window.ImportConfig",function()local ok,e=sampleWindow():ImportConfig("Imported copy",configJSON,true);assert(ok,e);return e end},
		{"Save legacy profile","Window.SaveProfile",function()sampleWindow():SaveProfile("Legacy sample");return "Legacy sample saved"end},
		{"Load legacy profile","Window.LoadProfile",function()local ok,e=sampleWindow():LoadProfile("Legacy sample");assert(ok,e);return "Legacy sample loaded"end},
	})
	menu(sandboxActions,"Config observer",{
		{"Listen for config changes","Window.OnConfigsChanged",function()if listener then listener:Disconnect()end;listener=sampleWindow():OnConfigsChanged(function()bench.ConfigEvents+=1;report("Config events",bench.ConfigEvents)end);return "Observer connected"end},
		{"Disconnect observer","Window.DisconnectConfigObserver",function()if listener then listener:Disconnect();listener=nil end;return "Observer disconnected"end},
	})
	local function inspect(title,value)
		local raw=type(value)=="string" and value or describe(value)
		window:Confirm({Title=title,Description="Read-only output. Select and copy any text you need.",Text=raw,ReadOnly=true,ConfirmText="Done"})
		return "Output opened"
	end
	menu(dataActions,"Read main demo data",{
		{"Read layout table","Window.GetLayout",function()return inspect("Layout table",window:GetLayout())end},
		{"Export layout JSON","Window.ExportLayout",function()return inspect("Layout JSON",window:ExportLayout())end},
		{"Export profile JSON","Window.ExportProfile",function()return inspect("Profile JSON",window:ExportProfile())end},
		{"List available themes","PearlUI.GetThemes",function()return inspect("Available themes",PearlUI.GetThemes())end},
		{"Read recent results","Showcase.Results",function()return inspect("Recent actions",bench.Results)end},
	})
	local layoutJSON,profileJSON
	menu(dataActions,"Sample JSON roundtrip",{
		{"Capture sample layout","Sample.CaptureLayout",function()layoutJSON=sampleWindow():ExportLayout();return "Layout captured"end},
		{"Restore sample layout","Window.ImportLayout",function()assert(layoutJSON,"Capture a sample layout first.");local ok,e=sampleWindow():ImportLayout(layoutJSON);assert(ok,e);return "Layout restored"end},
		{"Capture sample profile","Sample.CaptureProfile",function()profileJSON=sampleWindow():ExportProfile();return "Profile captured"end},
		{"Restore sample profile","Window.ImportProfile",function()assert(profileJSON,"Capture a sample profile first.");local ok,e=sampleWindow():ImportProfile(profileJSON);assert(ok,e);return "Profile restored"end},
	})
	menu(dataActions,"Dialogs & notifications",{
		{"Show a notification","Window.Notify",function()window:Notify({Title="Pearl showcase",Description="This is a notification preview.",Preview=true});return "Notification shown"end},
		{"Confirm or cancel","Window.Confirm",function()window:Confirm({Title="Test confirmation",Description="Try Confirm, Cancel or Escape. This test changes no settings.",OnConfirm=function()report("Dialog","Confirmed")end,OnCancel=function()report("Dialog","Cancelled")end});return "Dialog opened"end},
		{"Open a text editor","Showcase.TextEditor",function()window:Confirm({Title="Test text editor",Description="Type something, then confirm or cancel.",Text="Hello from Pearl",OnConfirm=function(text)report("Editor",text)end});return "Editor opened"end},
	})
	local themes=dataActions:Dropdown({Id="lab.theme",Persist=false,Label="Theme preview",Options=PearlUI.GetThemes(),Default=window.Theme,Callback=function(v)window:SetTheme(v);report("Theme",v)end})
	register("Window.SetTheme","API tools / Theme preview")
	dataActions:ColorPicker({Id="lab.accent",Persist=false,Label="Accent preview",Default=window.Palette.Accent,Callback=function(v)window:SetAccent(v);report("Accent",v)end})
	register("Window.SetAccent","API tools / Accent preview")
	action(dataActions,"Follow theme accent again","Use theme color","Window.ResetAccent",function()window:ResetAccent();return window.Palette.Accent end)
	dataActions:Label({Label="Sandbox storage",Value="Memory only · no real configs"})
	dataActions:Label({Label="Keyboard testing",Value="F6/F7 · ignores typing in fields"})
	bench.Coverage["Control.SetSilent"]="Components / Set silently"
	bench.ComponentTab=components
	bench.SampleWindow=sampleWindow
	bench.Target=target
	bench.ShowcaseSection=showcase
	function bench.Sync()
		local size=window.WindowSize
		local sizeName=size==Vector2.new(900,610) and "Default 900 × 610" or size==Vector2.new(680,420) and "Compact 680 × 420" or size==Vector2.new(1200,760) and "Wide 1200 × 760" or "Custom / drag the corner"
		local values={["lab.scale"]=window.Scale,["lab.opacity"]=window.Opacity*100,["opacity"]=window.Opacity*100,["lab.columns"]=window.Columns==2 and "Two" or "One",["lab.size"]=sizeName,["lab.theme"]=window.Theme,["theme"]=window.Theme,["lab.menuKey"]=window.ToggleKey.Name,["menuKey"]=window.ToggleKey.Name}
		for id,value in pairs(values)do local c=window._ids[id];if c and not c.Destroyed and window._capturing~=c then local normalized=c.Validate and c.Validate(value) or value;if c:Get()~=normalized then c:Set(normalized,true)end end end
		local c=window._ids["lab.accent"]
		if c and not c.Destroyed and c.Value.Hex~="#"..window.Palette.Accent:ToHex():upper()then c:Set(window.Palette.Accent,true)end
		c=window._accentControl
		if c and not c.Destroyed and c.Value.Hex~="#"..window.Palette.Accent:ToHex():upper()then c:Set(window.Palette.Accent,true)end
	end
	local function syncTick()bench.Sync();window:_later(.75,syncTick)end
	window:_later(.75,syncTick)
	bench.Dispose=function()if listener then listener:Disconnect()end;if sample and not sample.Destroyed then sample:Destroy()end end
	window:_connect(window.Gui.Destroying,bench.Dispose)
	local destroy=window.Destroy
	function window:Destroy()bench.Dispose();return destroy(self)end
	return bench
end
