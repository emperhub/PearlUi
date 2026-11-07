--!nocheck
return function(PearlUI)
	local w=PearlUI.new({Name="PearlNotificationDockTest",AnimationSpeed=0.08})
	local checks={}
	local function check(name,condition) assert(condition,"FAILED: "..name);table.insert(checks,name) end
	local function settle() task.wait(0.16) end
	local function same(a,b) return (Vector3.new(a.R,a.G,a.B)-Vector3.new(b.R,b.G,b.B)).Magnitude<0.001 end
	local ok,result=pcall(function()
		local t=w:Tab("General")
		local s=t:Section("Component playground with a deliberately long section title")
		s:Button({Label="Example",Text="Try"})
		settle()
		w.NotificationsEnabled=false
		check("ordinary notifications respect disabled preference",w:Notify({Title="Suppressed"})==nil and w.Notifications:FindFirstChild("Toast")==nil)
		local preview=w:Notify({Title="Preview",Description="Still works while notifications are disabled",Preview=true,Duration=0.35})
		settle()
		check("explicit preview creates visible toast",preview and preview.Parent==w.Notifications and preview.Card.Visible and preview.Card.BackgroundTransparency<0.04)
		check("preview preserves disabled preference",not w.NotificationsEnabled)
		check("toast is inside viewport",preview.AbsolutePosition.X>=w.Root.AbsolutePosition.X and preview.AbsolutePosition.Y>=w.Root.AbsolutePosition.Y and preview.AbsolutePosition.Y+preview.AbsoluteSize.Y<=w.Root.AbsolutePosition.Y+w.Root.AbsoluteSize.Y+1)
		check("toast contents paint above its surface",preview.Card:FindFirstChildWhichIsA("TextLabel").ZIndex>preview.Card.ZIndex)
		task.wait(0.4)
		check("preview expires and releases its slot",preview.Parent==nil)
		w.NotificationsEnabled=true
		local ordinary=w:Notify({Title="Enabled",Duration=0.05})
		check("enabled notifications still create toast",ordinary~=nil)
		task.wait(0.25)
		check("ordinary notification expires",ordinary.Parent==nil)
		w:SetTheme("Dark");w:SetMinimized(true);settle()
		local dark=w:ExportProfile()
		w:SetTheme("Light");settle()
		check("fixture has a white light-theme dock",same(w.Dock.BackgroundColor3,w.Palette.Card))
		assert(w:ImportProfile(dark));settle()
		check("profile import preserves dock theme tween",w.Theme=="Dark" and same(w.Dock.BackgroundColor3,w.Palette.Card))
		local layout=w:GetLayout()
		w:SetTheme("Light");assert(w:ImportLayout(layout));settle()
		check("layout restore cannot cancel dock recoloring",same(w.Dock.BackgroundColor3,w.Palette.Card))
		assert(w:ImportProfile(dark));w:StowDock("Left");settle();w:RevealDock();settle()
		check("edge recovery retains restored theme",same(w.Dock.BackgroundColor3,w.Palette.Card))
		w:SetMinimized(false);settle();s:Detach();settle()
		local texts={};for _,o in ipairs(s.Placeholder:GetChildren())do if o:IsA("TextLabel")then table.insert(texts,o)end end
		check("placeholder separates title and action",#texts==2 and texts[1].TextTruncate==Enum.TextTruncate.AtEnd and texts[2].Text=="Open detached panel")
		for _,o in ipairs(texts)do check("placeholder text stays within card "..o.Text,o.AbsolutePosition.X>=s.Placeholder.AbsolutePosition.X and o.AbsolutePosition.X+o.AbsoluteSize.X<=s.Placeholder.AbsolutePosition.X+s.Placeholder.AbsoluteSize.X+1)end
		local position=s.Float.Position;s:Reveal();settle()
		check("open detached panel retains detached ownership",s.Detached and s.Frame.Parent==s.FloatScroll and s.Float.Visible)
		check("revealing does not move settled floating panel",s.Float.Position==position)
		w:SetMinimized(true);settle();s:Reveal();settle()
		check("reveal restores minimized workspace",not w.Minimized and w.Visible and s.Float.Visible)
		s:Dock();settle();check("explicit dock still returns section home",not s.Detached and s.Frame.Parent==t.Page)
		w:Destroy();check("destroyed window cannot create previews",w:Notify({Preview=true})==nil)
		return {passed=#checks,checks=checks}
	end)
	w:Destroy();if not ok then error(result)end
	return result
end
