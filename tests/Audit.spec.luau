--!nocheck
return function(PearlUI)
	local w = PearlUI.new({ Name = "PearlLifecycleAudit", AnimationSpeed = 0.08 })
	local checks = {}
	local function check(name, value) assert(value, "FAILED: " .. name); table.insert(checks, name) end
	local function settle() task.wait(0.16) end
	local function colorEqual(a,b) return (Vector3.new(a.R,a.G,a.B)-Vector3.new(b.R,b.G,b.B)).Magnitude < 0.001 end
	local ok, result = pcall(function()
		local a, b = w:Tab("A"), w:Tab("B")
		local s, t = a:Section("First"), a:Section("Second")
		local c = s:Toggle({ Id = "visible", Label = "Visible", Default = true })
		local d = s:Dropdown({ Id = "choice", Label = "Choice", Options = { "Light", "Dark" }, Callback = function(value) w:SetTheme(value) end })
		local k = s:Keybind({ Id = "key", Label = "Key" })
		local other = t:Toggle({ Id = "other", Label = "Other" })
		local foreign = b:Section("Foreign"):Dropdown({ Id = "foreign", Label = "Foreign", Options = { "A", "B" } })
		settle()
		s:Detach(); task.wait(0.02); s:Dock(); w:SelectTab(b); task.wait(0.01); w:SelectTab(a); settle()
		check("dock during entry restores visible card", c.LabelText.TextTransparency < 0.001 and math.abs(s.Frame.BackgroundTransparency - 0.03) < 0.001)
		check("dock return cannot be stolen by tab switch", s.Frame.Parent == a.Page and not s.Float.Visible)
		s:Detach(); settle(); w:SetVisible(false); task.wait(0.02); s:Dock(); settle(); w:SetVisible(true); settle()
		check("dock while main is hiding preserves text", c.LabelText.TextTransparency < 0.001 and s.Frame.Parent == a.Page)
		check("hidden roots keep canonical alpha", math.abs(w.Main.Shell.BackgroundTransparency - 0.03) < 0.001)
		s:Detach(); t:Detach(); settle()
		check("new panels cascade", s.Float.Position ~= t.Float.Position)
		check("new panel sits wholly above previous panel", t.Float.Surface.ZIndex > c.LabelText.ZIndex)
		w:_raisePanel(s)
		check("focusing earlier panel raises its complete contents", s.Float.Surface.ZIndex > other.LabelText.ZIndex)
		d:Open(); settle()
		check("popup is above raised panel", w._popup and w._popup.ZIndex > c.LabelText.ZIndex and w.MenuDismiss.ZIndex > c.LabelText.ZIndex)
		w:_closeMenu(); s:Dock(); t:Dock(); settle()
		check("raised panels dock with original layers", c.LabelText.ZIndex == 9 and other.LabelText.ZIndex == 9)
		for i=1,20 do
			s:Detach(); task.wait(0.004); s:Dock()
			w:SelectTab(i%2==0 and a or b)
			w:SetVisible(false); w:SetTheme(i%2==0 and "Dark" or "Light"); task.wait(0.004); w:SetVisible(true)
		end
		w:SelectTab(a); settle()
		check("repeated detach dock leaves visible rows", c.LabelText.TextTransparency < 0.001 and d.Field.TextTransparency < 0.001 and not s.Detached and s.Frame.Parent == a.Page)
		check("repeated transitions restore card surface", math.abs(s.Frame.BackgroundTransparency - (1-w.Opacity)) < 0.001)
		check("one active tab survives repeated transitions", a.Page.Visible and not b.Page.Visible)
		check("theme reaches main surface after stress", colorEqual(w.Main.Shell.BackgroundColor3,w.Palette.Window))
		check("theme reaches recovery dock after stress", colorEqual(w.Dock.BackgroundColor3,w.Palette.Card))
		check("active navigation stays visible", a.Label.TextTransparency < 0.001 and a.Button.BackgroundTransparency < 0.001)
		w:SetVisible(false); task.wait(0.02); w:SelectTab(b); settle(); w:SetVisible(true); settle()
		check("tab change during fade clears old highlight", a.Button.BackgroundTransparency > 0.999 and b.Button.BackgroundTransparency < 0.001)
		w:SelectTab(a); settle()
		w:SetVisible(false); settle(); w:SetTheme("Light"); w:SetTheme("Dark"); settle()
		check("theme changes while hidden repaint recovery dock", colorEqual(w.Dock.BackgroundColor3,w.Palette.Card))
		w:SetVisible(true); settle(); d:Open(); settle()
		check("theme selector reopens after stress", w._popupOwner == d and d._menu ~= nil)
		d:Set("Dark"); d:Close(); settle()
		check("theme callback applies and popup closes", w.Theme == "Dark" and not w._popup)
		w._capturing = k; w:SetVisible(false)
		check("hiding cancels key capture", w._capturing == nil and k.Row.Keybind.Text == k.Value)
		local finishes = 0
		w._slider = { finish = function() finishes += 1 end }; w:SetMinimized(true)
		check("minimizing finishes slider feedback", finishes == 1 and w._slider == nil)
		w:SetMinimized(false); w:SetVisible(true); settle()
		w._capturing = k; d:Open()
		check("opening popup cancels key capture", w._capturing == nil and w._popupOwner == d)
		d:Close(); foreign:Open()
		check("inactive tab cannot open orphan popup", w._popup == nil)
		w:SetVisible(false); d:Open()
		check("hidden window cannot open orphan popup", w._popup == nil)
		w:SetVisible(true); settle()
		for _, case in ipairs({
			{ "Dropdown", { Id="bad", Options={} } },
			{ "Slider", { Id="bad", Min=10, Max=0 } },
			{ "Slider", { Id="bad", Step=math.huge } },
			{ "Keybind", { Id="bad", Default="NotAKey" } },
			{ "ColorPicker", { Id="bad", Default="invalid" } },
			{ "Input", { Id="bad", MaxLength=-1 } },
			{ "Toggle", { Id="bad", Callback="bad" } },
		}) do
			local controls, rows = #w.Controls, #s.Controls
			local accepted = pcall(function() s[case[1]](s,case[2]) end)
			check("invalid "..case[1].." leaves no ghost control", not accepted and #w.Controls==controls and #s.Controls==rows and w._ids.bad==nil)
		end
		local valid = s:Toggle({ Id="bad", Label="Reused ID" }); check("failed build ID remains reusable", valid ~= nil); valid:Destroy()
		local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(30,30,0)}
		local second={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(40,40,0)}
		local updates=0
		w._slider={input=touch,update=function() updates+=1 end,finish=function() finishes+=1 end}
		w:_updatePointer({UserInputType=Enum.UserInputType.MouseMovement,Position=Vector3.new(10,10,0)})
		check("mouse cannot move active touch slider", updates==0)
		w:_endPointer(second); check("second finger cannot end first slider", w._slider~=nil)
		w:_updatePointer(touch); check("initiating touch updates slider", updates==1)
		w:_endPointer(touch); check("initiating touch ends slider", w._slider==nil)
		for i=1,10 do s:Label({Label="Extra row "..i}) end; settle()
		d:Open(); settle(); a.Page.CanvasPosition=Vector2.new(0,10); task.wait();
		check("scroll dismisses anchored popup", a.Page.CanvasPosition.Y>0 and w._popup==nil)
		for i=1,12 do w:Tab("Extra"..i) end; settle()
		check("many tabs use clipped scrolling navigation", w.Navigation:IsA("ScrollingFrame") and w.Navigation.ClipsDescendants and w.Navigation.AbsoluteCanvasSize.Y>w.Navigation.AbsoluteSize.Y)
		if w.UserAvatar.IsLoaded then w.AvatarFallback.Visible=true end
		w:SetVisible(false); w:SetVisible(true); settle()
		check("showing rechecks late-loaded avatar fallback", not w.UserAvatar.IsLoaded or not w.AvatarFallback.Visible)
		check("no visibility jobs remain after settle", next(w._visibility)==nil)
		return { passed=#checks,checks=checks }
	end)
	w:Destroy()
	if not ok then error(result) end
	return result
end
