--!nocheck
return function(PearlUI)
	local w=PearlUI.new({Name="PearlThemeTest",AnimationSpeed=0.05})
	local checks={}
	local function check(name,value)assert(value,"FAILED: "..name);table.insert(checks,name)end
	local function same(a,b)return (Vector3.new(a.R,a.G,a.B)-Vector3.new(b.R,b.G,b.B)).Magnitude<0.001 end
	local function luminance(c)
		local function linear(v)return v<=0.04045 and v/12.92 or ((v+0.055)/1.055)^2.4 end
		return 0.2126*linear(c.R)+0.7152*linear(c.G)+0.0722*linear(c.B)
	end
	local function contrast(a,b)local x,y=luminance(a),luminance(b);return (math.max(x,y)+0.05)/(math.min(x,y)+0.05)end
	local ok,result=pcall(function()
		local tab=w:Tab("Themes")
		local section=tab:Section("Palette")
		local dropdown=section:Dropdown({Id="theme",Label="Theme",Options=PearlUI.GetThemes(),Callback=function(v)w:SetTheme(v)end})
		section:Toggle({Label="Enabled",Default=true})
		local names=PearlUI.GetThemes()
		check("nine themes available in stable order",#names==9 and names[1]=="Light" and names[8]=="Ocean" and names[9]=="Forest")
		names[1]="Changed";check("theme catalog is defensive",PearlUI.GetThemes()[1]=="Light")
		task.wait(0.12);section:Detach();task.wait(0.12)
		for _,name in ipairs(PearlUI.GetThemes())do
			dropdown:Set(name);task.wait(0.12)
			check(name.." applies from theme selector",w.Theme==name and same(w.Main.Shell.BackgroundColor3,w.Palette.Window))
			check(name.." paints dock and detached shell",same(w.Dock.BackgroundColor3,w.Palette.Card) and same(section.Float.Surface.BackgroundColor3,w.Palette.Window))
			check(name.." paints card and field",same(section.Frame.BackgroundColor3,w.Palette.Card) and same(dropdown.Field.BackgroundColor3,w.Palette.Field))
			check(name.." keeps text readable",contrast(w.Palette.Text,w.Palette.Card)>=7 and contrast(w.Palette.Muted,w.Palette.Card)>=4.5)
			local toast=w:Notify({Title=name,Duration=0.02});check(name.." paints toast surface",toast and same(toast.Card.BackgroundColor3,w.Palette.Card))
			local profile=w:ExportProfile();w:SetTheme(name=="Light" and "Dark" or "Light");assert(w:ImportProfile(profile));task.wait(0.12)
			check(name.." profile restores palette and dock",w.Theme==name and dropdown:Get()==name and same(w.Dock.BackgroundColor3,w.Palette.Card))
		end
		local custom=Color3.fromRGB(151,65,139);w:SetAccent(custom);w:SetTheme("Matcha");task.wait(0.12)
		check("custom accent survives theme change",same(w.Palette.Accent,custom))
		local before=w.Theme;check("unknown theme rejected without mutation",not pcall(function()w:SetTheme("Unknown")end) and w.Theme==before)
		section:Dock();task.wait(0.12)
		check("section docks after cycling palettes",section.Frame.Parent==tab.Page and section.Controls[1].LabelText.TextTransparency<0.001)
		return {passed=#checks,checks=checks}
	end)
	w:Destroy();if not ok then error(result)end;return result
end
