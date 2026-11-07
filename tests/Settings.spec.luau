--!nocheck
return function(PearlUI)
	local checks, windows = {}, {}
	local function check(n,v)assert(v,"FAILED: "..n);table.insert(checks,n)end
	local function fixture(name)
		local w=PearlUI.new({Name=name or "PearlSettingsTest",ReduceMotion=true})
		table.insert(windows,w)
		local a=w:Tab("General");w:Tab("Other")
		local s=a:Section("Interface")
		local theme=s:Dropdown({Id="theme",ResetGroup="Appearance",Options=PearlUI.GetThemes(),Default="Light",Callback=function(v)w:SetTheme(v)end})
		local color=s:ColorPicker({Id="color",ResetGroup="Appearance",Default=Color3.fromRGB(0,113,246),Callback=function(v)w:SetAccent(v)end})
		w._accentControl=color
		local flag=s:Toggle({Id="flag",Default=false})
		local key=s:Keybind({Id="key",Default="RightShift",Callback=function(v)w:SetToggleKey(v)end})
		w:CaptureDefaults()
		return w,theme,color,flag,key,s
	end
	local ok,result=pcall(function()
		local w,theme,color,flag,key,s=fixture()
		theme:Set("Forest");local forest=w.Palette.Accent
		check("theme color picker follows built-in accent",color:Get()==forest)
		color:Set("#B14569");check("custom color marks override",w._accentOverride~=nil)
		w:ResetAccent();check("reset accent restores current palette",w._accentOverride==nil and w.Palette.Accent==forest and color:Get()==forest)
		theme:Set("Matcha");check("theme accent follows later theme changes",w._accentOverride==nil and color:Get()==w.Palette.Accent)
		local p=w:ExportProfile();color:Set("#FF0000");assert(w:ImportProfile(p))
		check("theme accent mode survives profile restore",w._accentOverride==nil and color:Get()==w.Palette.Accent)
		color:Set("#AA5577");p=w:ExportProfile();w:ResetAccent();assert(w:ImportProfile(p))
		check("custom accent mode survives profile restore",w._accentOverride~=nil and color.Value.Hex=="#AA5577")
		flag:Set(true);key:Set("F4");w:SetSize(760,500);s:Detach();theme:Set("Forest")
		assert(w:Reset("Appearance"))
		check("appearance reset restores theme and accent",w.Theme=="Light" and w._accentOverride==nil)
		check("appearance reset preserves controls and layout",flag:Get() and key:Get()=="F4" and s.Detached and w.WindowSize.X==760)
		theme:Set("Forest");assert(w:Reset("Controls"))
		check("control reset restores values and keybind",not flag:Get() and key:Get()=="RightShift" and w.ToggleKey==Enum.KeyCode.RightShift)
		check("control reset preserves appearance and layout",w.Theme=="Forest" and s.Detached and w.WindowSize.X==760)
		flag:Set(true);assert(w:Reset("Layout"));task.wait(.05)
		check("layout reset docks panels and restores size",not s.Detached and w.WindowSize.X==900)
		check("layout reset preserves values and theme",flag:Get() and w.Theme=="Forest")
		w:SaveProfile("Keep me");assert(w:Reset("All"))
		check("full reset preserves named profiles",not flag:Get() and w.Theme=="Light" and w._profiles["Keep me"]~=nil)
		check("unknown reset scope rejects before mutation",not pcall(function()w:Reset("Wrong")end) and not flag:Get())
		flag:Set(true);local h=w:RequestReset("Controls")
		check("request reset waits for confirmation",h.Pending and flag:Get() and w._confirmation==h)
		h:Cancel();check("cancel leaves values unchanged",flag:Get() and not h.Pending)
		h=w:RequestReset("Controls");h:Confirm();h:Confirm()
		check("confirm performs reset once",not flag:Get() and not h.Pending)
		local confirms,cancels=0,0
		h=w:Confirm({OnConfirm=function()confirms+=1 end,OnCancel=function()cancels+=1 end});h:Confirm();h:Cancel()
		check("confirmation completes once",confirms==1 and cancels==0)
		h=w:Confirm({OnCancel=function()cancels+=1 end});local replacement=w:Confirm({});check("replacement cancels previous dialog",not h.Pending and replacement.Pending and cancels==1)
		w:SetVisible(false);check("hiding cancels modal",not replacement.Pending and not w._confirmation)
		w:SetVisible(true)
		local disk,writes={},0
		local adapter={Load=function(k)return disk[k]end,Save=function(k,v)disk[k]=v;writes+=1;return true end}
		assert(w:ConfigurePersistence({Adapter=adapter,Key="test",AutoSave=false}))
		check("empty storage starts ready",w:GetPersistenceStatus()=="Ready")
		theme:Set("Forest");flag:Set(true);key:Set("F5");s:Detach();w:SaveProfile("Forest setup")
		assert(w:SaveSettings());check("manual save writes durable document",writes==1 and type(disk.test)=="string")
		assert(w:SaveSettings());check("unchanged snapshot skips redundant write",writes==1)
		local restored,rTheme,rColor,rFlag,rKey,rSection=fixture("PearlRestoredSettings")
		assert(restored:ConfigurePersistence({Adapter=adapter,Key="test",AutoSave=false}));task.wait(.05)
		check("new window restores theme and controls",restored.Theme=="Forest" and rFlag:Get() and rKey:Get()=="F5")
		check("new window restores detached layout",rSection.Detached and rSection.Frame.Parent==rSection.FloatScroll)
		check("new window restores named profiles",restored._profiles["Forest setup"]~=nil)
		check("new window preserves theme accent mode",restored._accentOverride==nil and rColor:Get()==restored.Palette.Accent)
		disk.test="{broken";local before=restored:ExportProfile();local count=writes
		check("corrupt storage rejects load",not restored:LoadSettings())
		check("failed load preserves current setup",restored:ExportProfile()==before)
		check("failed load prevents destructive overwrite",not restored:SaveSettings() and writes==count and disk.test=="{broken")
		assert(w:SaveSettings()==true);disk.test=game:GetService("HttpService"):JSONEncode(w:_settingsSnapshot())
		assert(restored:LoadSettings());check("retry load unlocks saves",restored:GetPersistenceStatus()=="Saved")
		local fail=true
		local unreliable={Load=function()return nil end,Save=function(k,v)if fail then return false,"offline"end;disk[k]=v;return true end}
		assert(restored:ConfigurePersistence({Adapter=unreliable,Key="retry",AutoSave=false}))
		check("unacknowledged save reports failure",not restored:SaveSettings() and restored:GetPersistenceStatus()=="Error")
		fail=false;assert(restored:SaveSettings());check("manual save recovers after storage error",restored:GetPersistenceStatus()=="Saved" and disk.retry~=nil)
		local auto,aTheme=fixture("PearlAutoSettings")
		assert(auto:ConfigurePersistence({Adapter=adapter,Key="auto",Debounce=.05}))
		aTheme:Set("Ocean");local deadline=os.clock()+2
		repeat task.wait(.05) until disk.auto or os.clock()>=deadline
		check("auto-save persists changed values",disk.auto and game:GetService("HttpService"):JSONDecode(disk.auto).Current.Appearance.Theme=="Ocean")
		aTheme:Set("Forest");auto:Destroy()
		check("destroy flushes final local changes",game:GetService("HttpService"):JSONDecode(disk.auto).Current.Appearance.Theme=="Forest")
		check("destroy cancels persistence polling",auto._persistence==nil and next(auto._jobs)==nil)
		local stale,staleTheme=fixture("PearlStaleLoad")
		local delayed={Load=function()task.wait(.08);return disk.test end,Save=adapter.Save}
		task.delay(.02,function()stale:DisablePersistence(false)end)
		local loaded=stale:ConfigurePersistence({Adapter=delayed,Key="test",AutoSave=false})
		check("disabled in-flight load cannot apply stale values",not loaded and stale.Theme=="Light")
		local concurrent,cTheme=fixture("PearlConcurrentSave")
		local slow={Load=function()return nil end,Save=function(k,v)task.wait(.08);disk[k]=v;return true end}
		assert(concurrent:ConfigurePersistence({Adapter=slow,Key="slow",AutoSave=false}))
		task.delay(.02,function()cTheme:Set("Forest")end);assert(concurrent:SaveSettings());assert(concurrent:SaveSettings())
		check("edits during yielding save are not lost",game:GetService("HttpService"):JSONDecode(disk.slow).Current.Appearance.Theme=="Forest")
		return {passed=#checks,checks=checks}
	end)
	for _,w in ipairs(windows)do w:Destroy()end
	if not ok then error(result)end;return result
end
