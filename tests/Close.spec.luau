--!nocheck
-- Shared desktop/touch traffic-light behavior; never touches real settings.
return function(PearlUI)
	local checks,windows={},{}
	local function check(name,value) assert(value,"FAILED: "..name);table.insert(checks,name) end
	local function create(options)
		local w=PearlUI.new(options or {Name="PearlCloseTest",ReduceMotion=true,DisplayOrder=110})
		table.insert(windows,w)
		local s=w:Tab("General"):Section({Title="Settings",Id="settings"})
		s:Toggle({Id="flag",Default=true})
		return w,s
	end
	local ok,result=pcall(function()
		local w,s=create();task.wait()
		s:Detach()
		local handle=w:_activateChrome(1)
		check("red opens close confirmation",handle and handle.Pending and w._confirmation==handle)
		check("red preserves visible main until confirmed",w.Visible and not w.Minimized and not w.Destroyed)
		check("red preserves detached ownership",s.Detached and s.Float.Parent~=nil)
		check("repeated red reuses one confirmation",w:_activateChrome(1)==handle)
		handle:Cancel();task.wait()
		check("cancel keeps window usable",not w.Destroyed and w.Visible and w._confirmation==nil)
		check("cancel preserves values and panels",w._ids.flag:Get() and s.Detached)
		local second=w:_activateChrome(1)
		check("red can reopen after cancellation",second~=handle and second.Pending)
		second:Cancel()
		w:_activateChrome(2)
		check("yellow still minimizes without confirmation",w.Minimized and not w.Destroyed and w._confirmation==nil)
		check("yellow preserves dock for recovery",w.Dock.Visible and w.DockGui.Parent~=nil)
		w:SetMinimized(false)
		w:_activateChrome(3);check("green maximizes",w.Maximized)
		w:_activateChrome(3);check("green restores",not w.Maximized)
		local saves=0
		w:Ready({Adapter={Load=function()return nil end,Save=function()saves+=1;return true end},Key="close-test"})
		w._ids.flag:Set(false)
		local final=w:_activateChrome(1);final:Confirm()
		check("confirmed red destroys window",w.Destroyed)
		check("confirmed red removes main and dock",w.Gui.Parent==nil and w.DockGui.Parent==nil)
		check("confirmed red removes detached panels",s.Float.Parent==nil)
		check("confirmed red flushes configured autosave",saves==1)
		check("confirmed red releases listeners and jobs",#w._connections==0 and next(w._jobs)==nil)
		final:Confirm();final:Cancel();w:_activateChrome(1);w:Destroy()
		check("repeated close is harmless",w.Destroyed and saves==1)
		local mobile=create();task.wait()
		mobile:_layout(false,Vector2.new(390,844),Enum.PreferredInput.Touch)
		check("mobile close has touch hit target",mobile._chromeTouchButtons[1].Visible)
		mobile:_activateChrome(1);mobile:_gamepadInput({UserInputType=Enum.UserInputType.Gamepad1,KeyCode=Enum.KeyCode.ButtonB},false)
		-- Without gamepad focus, use the same cancellation path as Escape/outside tap.
		if mobile._confirmation then mobile._confirmation:Cancel() end
		check("mobile cancel keeps UI alive",not mobile.Destroyed and mobile.Visible)
		mobile:_activateChrome(1):Confirm()
		check("mobile confirmed close destroys both GUIs",mobile.Destroyed and mobile.DockGui.Parent==nil)
		return {passed=#checks,checks=checks}
	end)
	for _,w in ipairs(windows)do w:Destroy()end
	if not ok then error(result)end
	return result
end
