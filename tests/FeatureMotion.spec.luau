--!nocheck
return function(PearlUI)
	local w = PearlUI.new({ Name = "PearlFeatureMotionTest", AnimationSpeed = 0.08 })
	local checks = {}
	local function check(name, condition) assert(condition, "FAILED: " .. name); table.insert(checks, name) end
	local ok, result = pcall(function()
		local tab = w:Tab("General")
		local section = tab:Section({ Id = "floating", Title = "Floating" })
		local color = section:ColorPicker({ Id = "color", Label = "Color", Callback = function(value) w:SetAccent(value) end })
		local multi = section:Dropdown({ Id = "multi", Label = "Multiple", Multi = true, Options = { "Alpha", "Beta" } })
		task.wait(0.16)
		color:Open(); color:Set("#AA55CC"); task.wait(0.14)
		check("animated color callback preserves editor", w._popupOwner == color and math.abs(color._menu.Frame.BackgroundTransparency - (1 - w.Opacity)) < 0.001)
		local oldPopup = w._popup
		color:Destroy(); multi:Open(); task.wait(0.16)
		check("destroyed editor cannot close replacement popup", oldPopup.Parent == nil and w._popupOwner == multi and multi._menu.Frame.Parent ~= nil)
		multi:SetDisabled(true); multi:SetDisabled(false); multi:Open(); task.wait(0.16)
		check("disable during transition keeps latest popup", w._popupOwner == multi and not multi.Disabled and multi._menu.Frame.Visible)
		multi:Close()
		section:Detach(); task.wait(0.16)
		section.Float.Position = UDim2.fromOffset(40, 100)
		local detached = w:ExportProfile()
		section:Dock()
		local docked = w:ExportProfile()
		assert(w:ImportProfile(detached)); assert(w:ImportProfile(docked)); assert(w:ImportProfile(detached))
		task.wait(0.2)
		check("rapid layout import retains latest detached state", section.Detached and section.Frame.Parent == section.FloatScroll and section.Frame.ZIndex == 48)
		assert(w:ImportProfile(docked)); task.wait(0.2)
		check("profile docking completes after fade", not section.Detached and section.Frame.Parent == tab.Page and not section.Float.Visible)
		multi:Open(); w:SetVisible(false); w:Destroy(); task.wait(0.12)
		check("destroy cancels pending feature transitions", next(w._tweens) == nil and next(w._jobs) == nil and w.Gui.Parent == nil)
		return { passed = #checks, checks = checks }
	end)
	w:Destroy()
	if not ok then error(result) end
	return result
end
