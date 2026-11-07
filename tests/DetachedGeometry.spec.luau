--!nocheck
return function(PearlUI)
	local w = PearlUI.new({ Name="PearlDetachedGeometryTest", AnimationSpeed=0.08 })
	local checks={}
	local function check(name, condition) assert(condition,"FAILED: "..name);table.insert(checks,name) end
	local function settle() task.wait(0.16) end
	local function contained(s)
		local card, viewport = s.Frame, s.FloatScroll
		return card.AbsolutePosition.X >= viewport.AbsolutePosition.X-1
			and card.AbsolutePosition.X+card.AbsoluteSize.X <= viewport.AbsolutePosition.X+viewport.AbsoluteSize.X+1
			and math.abs(card.AbsolutePosition.Y-viewport.AbsolutePosition.Y) < 5*w._actualScale
	end
	local ok,result=pcall(function()
		local t=w:Tab("Geometry")
		local sections={}
		for i=1,4 do
			local s=t:Section({Title="Section"..i,Column=i%2==0 and "Right" or "Left"})
			s:Button({Label="Visible action",Text="Click"})
			for j=1,4 do s:Label({Label="Row"..j,Value="Value"}) end
			table.insert(sections,s)
		end
		settle()
		check("fixture has right-column horizontal offset",sections[2].Frame.Position.X.Offset>100)
		check("fixture has lower-row vertical offset",sections[3].Frame.Position.Y.Offset>100)
		for i,s in ipairs(sections) do
			s:Detach();settle()
			check("detached card fits viewport "..i,contained(s))
			local field=s.Controls[1].Row.Button
			check("detached action is fully inside viewport "..i,field.AbsolutePosition.X>=s.FloatScroll.AbsolutePosition.X and field.AbsolutePosition.X+field.AbsoluteSize.X<=s.FloatScroll.AbsolutePosition.X+s.FloatScroll.AbsoluteSize.X+1)
			check("detached scroll is vertical "..i,s.FloatScroll.ScrollingDirection==Enum.ScrollingDirection.Y)
			s:Dock();settle()
			check("docking restores original column "..i,s.Frame.Parent==t.Page and (i%2==0 and s.Frame.Position.X.Offset>100 or i%2==1 and s.Frame.Position.X.Offset==0))
		end
		w.Search.Text="Visible action";settle()
		local right=sections[4];right:Detach();settle()
		check("detach from packed search resets both offsets",contained(right))
		w.Search.Text="";w:SetSize(680,500);settle()
		check("main resize cannot move detached content",contained(right))
		local saved=w:ExportProfile();right:Dock();settle();assert(w:ImportProfile(saved));settle()
		check("profile restores detached card inside viewport",right.Detached and contained(right))
		right.FloatScroll.CanvasPosition=Vector2.new(0,50);right:Dock();settle();right:Detach();settle()
		check("reopening starts at top of panel",right.FloatScroll.CanvasPosition==Vector2.zero and contained(right))
		w:SetColumns(1);settle();right:Dock();settle();right:Detach();settle()
		check("single-column detach also fits viewport",contained(right))
		return {passed=#checks,checks=checks}
	end)
	w:Destroy()
	if not ok then error(result) end
	return result
end
