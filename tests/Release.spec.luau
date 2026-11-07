--!nocheck
-- Synthetic viewport/input integration tests. No world or gameplay state.
return function(PearlUI)
	local Gui = game:GetService("GuiService")
	local Http = game:GetService("HttpService")
	local windows,checks = {},{}
	local previousSelection=Gui.SelectedObject
	local function check(name,value) assert(value,"FAILED: "..name);table.insert(checks,name) end
	local function window(options) local w=PearlUI.new(options or {Name="PearlReleaseTest",ReduceMotion=true,DisplayOrder=110});table.insert(windows,w);return w end
	local function count(map) local n=0;for _ in pairs(map)do n+=1 end;return n end
	local function key(code) return {UserInputType=Enum.UserInputType.Gamepad1,KeyCode=code} end
	local ok,result=pcall(function()
		local w=window()
		local tab=w:Tab({Name="Components",Icon="component"})
		local s=tab:Section({Title="Common icons",Id="icons",Icon="sparkles"})
		local other=w:Tab("Other");other:Section("Other"):Button({Label="Other action"})
		local controls={
			s:Toggle({Id="toggle",Label="Toggle",Icon="power"}),
			s:Slider({Id="slider",Label="Slider",Icon="sliders-horizontal",Default=20,Step=2}),
			s:Dropdown({Id="dropdown",Label="Dropdown",Icon="list",Options={"One","Two"}}),
			s:ColorPicker({Id="color",Label="Color",Icon="palette"}),
			s:Input({Id="input",Label="Input",Icon="text-cursor-input",Description="Description with an icon"}),
			s:Keybind({Id="key",Label="Key",Icon="keyboard"}),
			s:Button({Label="Button",Icon="play"}),s:Label({Label="Label",Value="Status",Icon="info"}),
		}
		task.wait(.08)
		for _,c in ipairs(controls) do
			check(c.Type.." renders common icon",c.Icon and #c.Icon:GetChildren()>0)
			local before=Http:JSONEncode(c:Serialize())
			local x=c.LabelText.Position.X.Offset
			for _=1,4 do c:SetIcon("check");c:SetIcon("bell") end
			check(c.Type.." icon replacement has no position drift",c.LabelText.Position.X.Offset==x)
			check(c.Type.." icon leaves value unchanged",Http:JSONEncode(c:Serialize())==before)
			c:SetIcon(nil);check(c.Type.." icon can be removed",c.Icon==nil and c.LabelText.Position.X.Offset==x-26)
			c:SetIcon("check")
		end
		tab:SetIcon("shield-check")
		check("tab changes sidebar and dock icons",tab.Icon:GetAttribute("LucideIcon")=="shield-check" and tab.DockButton.Icon:GetAttribute("LucideIcon")=="shield-check")
		s:SetIcon("folder-open");check("section icon setter",s.Icon:GetAttribute("LucideIcon")=="folder-open")
		s:Detach();controls[1]:SetIcon("heart");s:SetIcon("shield");s:Dock()
		check("dynamic detached control icon returns to base Z",controls[1].Icon.ZIndex==controls[1].LabelText.ZIndex)
		check("dynamic detached section icon returns to base Z",s.Icon.ZIndex==8)
		check("invalid section Icon reserves no ID",not pcall(function()tab:Section({Id="invalid-icon",Icon={}})end) and w._sectionIds["invalid-icon"]==nil)
		local guis=#w.Gui.Parent:GetChildren()
		for _,bad in ipairs({{Scale=0/0},{Scale=-1},{AnimationSpeed=math.huge},{ToggleKey="F8"},{Accent="green"},{Responsive="yes"}})do
			check("invalid constructor fails before allocating GUI",not pcall(PearlUI.new,bad) and #w.Gui.Parent:GetChildren()==guis)
		end
		for _,size in ipairs({Vector2.new(320,568),Vector2.new(390,844),Vector2.new(600,960),Vector2.new(844,390)})do
			w:_layout(false,size,Enum.PreferredInput.Touch);task.wait(.04)
			local label=tostring(size.X).."x"..tostring(size.Y)
			check(label.." keeps readable scale",w._mobileLayout and w._actualScale>=.85)
			check(label.." fits safe viewport",w.Main.Size.X.Offset<=w._rootWidth-16+.01 and w.Main.Size.Y.Offset<=w._rootHeight-16+.01)
			check(label.." compact sidebar",w.Sidebar.Size.X.Offset==56 and not tab.Label.Visible)
			check(label.." keeps touch fields 44px",controls[3].Field.Size.Y.Offset>=44 and controls[1].Row.ToggleHitArea.Visible)
			check(label.." does not enable resize",not w.ResizeHandle.Visible)
			check(label.." chrome targets stay separate",w._chromeTouchButtons[3].Position.X.Offset+44<=w.Main.Size.X.Offset-156)
			check(label.." Dock fits narrow viewport",w.Dock.Size.X.Offset<=w._dockWidth-16+.01)
			s:Detach();check(label.." floating panel fits",s.Float.Size.X.Offset<=w._rootWidth-16+.01);s:Dock()
		end
		w:_layout(false,Vector2.new(1280,800),Enum.PreferredInput.KeyboardAndMouse);task.wait(.04)
		check("desktop geometry restores after phone",not w._mobileLayout and w.Sidebar.Size.X.Offset==180 and w.Main.Size.X.Offset==900 and tab.Label.Visible)
		check("touch-only hit areas hide on desktop",not controls[1].Row.ToggleHitArea.Visible and not w._chromeTouchButtons[1].Visible)
		local release=w:_touchScrollLock(controls[2])
		check("touch slider can lock parent scroll",not tab.Page.ScrollingEnabled)
		local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(0,0,0)}
		local stranger={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(10,0,0)}
		local movements=0
		w._slider={input=touch,control=controls[2],update=function()movements+=1 end,finish=release}
		w:_updatePointer(stranger);w:_endPointer(stranger)
		check("unrelated touch cannot steal slider",movements==0 and w._slider~=nil)
		w:_updatePointer(touch);w:_endPointer(touch)
		check("own touch updates and releases scroll",movements==1 and w._slider==nil and tab.Page.ScrollingEnabled)
		local slider=controls[2]
		check("Focus selects a control",w:Focus(slider) and Gui.SelectedObject==slider._focusTarget)
		task.wait()
		check("focused control has visible ring",slider._focusTarget.FocusRing.Visible)
		w:_gamepadInput(key(Enum.KeyCode.DPadRight),false)
		check("gamepad changes slider by its step",slider:Get()==22)
		check("slider allows vertical navigation",not w:_gamepadInput(key(Enum.KeyCode.DPadDown),false))
		slider:SetDisabled(true);check("disabled control loses selection",Gui.SelectedObject~=slider._focusTarget and not slider._focusTarget.Selectable)
		slider:SetDisabled(false)
		check("Label is not focusable",not w:Focus(controls[8]))
		w:Focus(controls[3]);controls[3]:Open();task.wait()
		check("gamepad popup takes focus",w._popup and Gui.SelectedObject:IsDescendantOf(w._popup))
		check("dropdown is above its dismiss blocker",w._popup.ZIndex>w.MenuDismiss.ZIndex and controls[3]._menu.Rows.One.Button.ZIndex>w.MenuDismiss.ZIndex)
		w:_gamepadInput(key(Enum.KeyCode.ButtonB),false)
		check("Back closes popup and restores anchor",w._popup==nil and Gui.SelectedObject==controls[3].Field)
		w:Confirm({Title="Focus test"});task.wait()
		check("confirmation selects safe cancel",Gui.SelectedObject and Gui.SelectedObject.Name=="Cancel")
		w:_gamepadInput(key(Enum.KeyCode.ButtonB),false)
		check("Back cancels confirmation",w._confirmation==nil)
		w:Focus(slider);w:_gamepadInput(key(Enum.KeyCode.ButtonR1),false)
		check("shoulder button changes tabs",w.ActiveTab==other)
		w:_gamepadInput(key(Enum.KeyCode.ButtonL1),false);check("opposite shoulder restores tab",w.ActiveTab==tab)
		w:_gamepadInput(key(Enum.KeyCode.ButtonB),false);task.wait(.04)
		check("Back hides main but keeps recovery focus",not w.Visible and w:_ownsFocus(Gui.SelectedObject))
		w:Focus(slider)
		local color=controls[4];color:Open();local editor=color._menu
		check("color input is above its dismiss blocker",editor.SV.ZIndex>w.MenuDismiss.ZIndex and editor.Alpha.ZIndex>w.MenuDismiss.ZIndex)
		local popupZ=editor.Frame.ZIndex;w:_liftPopup(editor.Frame);w:_show(editor.Frame,true,true)
		check("popup layers remain stable across animation and raising",editor.Frame.ZIndex==popupZ and popupZ<20000)
		Gui.SelectedObject=editor.Alpha
		local _,alpha=color:Get();w:_gamepadInput(key(Enum.KeyCode.DPadLeft),false)
		check("gamepad adjusts color alpha",math.abs(select(2,color:Get())-math.max(0,alpha-.05))<.001)
		color:Close()
		local largeOptions={};for i=1,5000 do largeOptions[i]=string.format("Item %04d",i)end
		local large=s:Dropdown({Id="large",Options=largeOptions,PageSize=50})
		large:Open();local menu=large._menu
		check("large dropdown creates one bounded page",count(menu.Rows)==50 and menu.PageCount==100)
		menu.SetPage(2)
		check("next page displays later values",menu.Rows["Item 0051"]~=nil and menu.Rows["Item 0001"]==nil)
		check("rebuilt pages stay clickable above dismiss",menu.Rows["Item 0051"].Button.ZIndex>w.MenuDismiss.ZIndex)
		large:Set("Item 4999");check("selection domain includes other pages",large:Get()=="Item 4999")
		menu.Search.Text="4999";task.wait()
		check("search covers entire catalog",#menu.Matches==1 and menu.Rows["Item 4999"]~=nil)
		menu.Search.Text="no such option";task.wait();check("large dropdown empty state",menu.Empty.Visible and count(menu.Rows)==0)
		for i=1,30 do menu.Search.Text=tostring(i) end
		task.wait()
		check("search keeps row and listener allocation bounded",count(menu.Rows)<=50 and #w._connections<1600)
		large:Close()
		check("bad page size rolls back ID",not pcall(function()s:Dropdown({Id="bad-pages",Options={"A"},PageSize=0})end) and not w._ids["bad-pages"])
		local raw,saves
		saves=0
		local adapter={Load=function()return raw end,Save=function(_,value)raw=value;saves+=1;return true end}
		local a=window();local flag=a:Tab("General"):Section("Values"):Toggle({Id="flag"})
		check("Ready configures real adapter contract",a:Ready({Adapter=adapter,Key="test",Debounce=.05}))
		check("Ready captures baseline and Default config",a._defaults~=nil and table.find(a:ListConfigs(),"Default")~=nil)
		flag:Set(true);check("Ready values save with acknowledgement",a:SaveSettings() and raw~=nil and saves==1)
		local b=window();local flag2=b:Tab("General"):Section("Values"):Toggle({Id="flag"})
		check("Ready loads stored values",b:Ready({Adapter=adapter,Key="test"}) and flag2:Get())
		flag2:Set(false);b:Ready({Adapter=adapter,Key="test"})
		check("Ready is idempotent and does not reload edits",not flag2:Get())
		flag2:Set(true);b:Reset("All");check("Ready reset returns construction baseline",not flag2:Get())
		local failing=window();failing:Tab("General"):Section("Values"):Toggle({Id="flag"})
		local offline={Load=function()error("Offline")end,Save=function()error("Must not save after failed load")end}
		check("Ready surfaces initial storage failure",not failing:Ready({Adapter=offline,Key="test"}))
		check("failed Ready blocks settings overwrite",not failing:SaveSettings())
		offline.Load=function()return raw end;offline.Save=adapter.Save
		check("Ready can retry a recovered adapter",failing:Ready({Adapter=offline,Key="test"}))
		local session=window();session:Tab("General"):Section("Values"):Toggle({Id="flag"})
		local ready,message=session:Ready()
		check("no adapter explicitly reports session-only",ready and message=="Session only" and session:GetPersistenceStatus()=="Disabled")
		local noPad=window({GamepadNavigation=false,ReduceMotion=true})
		noPad:Tab("General"):Section("Values"):Button({})
		check("gamepad navigation can be opted out",not noPad:Focus() and next(noPad._focusables)==nil)
		for _,item in ipairs(windows)do item:Destroy()end
		check("destroy removes all input registries",next(w._focusables)==nil and next(w._focusControls)==nil and next(w._gamepadAdjust)==nil)
		check("destroy releases owned gamepad selection",not w:_ownsFocus(Gui.SelectedObject))
		return {passed=#checks,checks=checks}
	end)
	for _,w in ipairs(windows)do w:Destroy()end
	if previousSelection and previousSelection.Parent then Gui.SelectedObject=previousSelection end
	if not ok then error(result)end
	return result
end
