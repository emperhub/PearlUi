--!nocheck
return function(build,required)
	local w=build()
	local checks={}
	local function check(n,v)assert(v,"FAILED: "..n);table.insert(checks,n)end
	local function execute(key)local ok,r=w._testBench.Run(key);assert(ok,r);return r end
	local ok,result=pcall(function()
		local b=w._testBench;assert(b,"Showcase was not attached")
		local missing={};for _,key in ipairs(required)do if not b.Coverage[key]then table.insert(missing,key)end end
		check("every public API has a visible showcase location",#missing==0)
		check("seven navigable tabs are present",#w.Tabs==7)
		for _,tab in ipairs(w.Tabs)do check("two sections in "..tab.Name,#tab.Sections==2)end
		local count=0;for _ in pairs(b.Controls)do count+=1 end
		check("all ten control examples are built",count==10)
		check("multi and no-search variants are available",b.Controls["Multi dropdown"].Multi and not b.Controls["No-search dropdown"].Searchable)
		local _,alpha=b.Controls["Color picker"]:Get();check("color picker demonstrates alpha",alpha==.7)
		local callbacksBeforeSync=b.CallbackCount
		w:SetScale(.85);w:SetSize(735,490);w:SetTheme("Forest");w:SetToggleKey("F8");b.Sync()
		check("geometry controls reflect external changes",w._ids["lab.scale"]:Get()==.85 and w._ids["lab.size"]:Get()=="Custom / drag the corner")
		check("theme and key controls stay synchronized",w._ids.theme:Get()=="Forest" and w._ids.menuKey:Get()=="F8" and w._ids["lab.theme"]:Get()=="Forest")
		check("parameter sync stays silent",b.CallbackCount==callbacksBeforeSync)
		w:SelectTab("Components");task.wait(.1)
		check("read action returns live value",execute("Control.Get")==true)
		execute("Control.Set");check("set action emits callback",b.CallbackCount==1 and not b.Controls.Toggle:Get())
		check("false values display as values",not b.Results[#b.Results]:find("Error:",1,true))
		local callbacks=b.CallbackCount;execute("Control.SetSilent");check("silent set does not emit callback",b.CallbackCount==callbacks and b.Controls.Toggle:Get())
		execute("Control.RemoveCallback");execute("Control.Set");check("callback can be detached",b.CallbackCount==callbacks)
		execute("Control.OnChanged");execute("Control.Set");check("callback can be reattached",b.CallbackCount==callbacks+1)
		execute("Control.SetDisabled");check("disabled state is testable",execute("Control.CanInteract")==false)
		execute("Control.SetDisabled");execute("Control.SetVisible");check("hidden control is testable",not b.Controls.Toggle.Visible)
		execute("Control.SetVisible");execute("Control.SetLabel");check("label mutation is testable",b.Controls.Toggle.Label=="Renamed example")
		local old=b.Controls.Toggle;execute("Control.Destroy");check("individual destruction is visible",old.Destroyed)
		execute("Control.Recreate");check("destroyed control can be rebuilt",b.Controls.Toggle~=old and not b.Controls.Toggle.Destroyed)
		b.Target:Set("Multi dropdown",true);execute("Dropdown.SetOptions");check("dynamic dropdown options are testable",#b.Controls["Multi dropdown"].Options==3)
		execute("Dropdown.Open");task.wait(.12);check("open dropdown action shows real popup",w._popupOwner==b.Controls["Multi dropdown"])
		execute("Control.Close");execute("ColorPicker.SetAlpha");local _,a=b.Controls["Color picker"]:Get();check("alpha action updates picker",a==.35)
		execute("ColorPicker.SetHSV");execute("ColorPicker.Open");task.wait(.12);check("color action shows real editor",w._popupOwner==b.Controls["Color picker"])
		b.Controls["Color picker"]:Close()
		execute("PearlUI.new");local sample=b.Sample
		check("lifecycle sample is separate from main demo",sample and sample~=w and not sample.Destroyed)
		execute("Window.ConfigurePersistence");execute("Sample.Toggle");execute("Window.SaveSettings");execute("Sample.Toggle");execute("Window.LoadSettings")
		check("sample memory storage restores values",sample._ids["sample.flag"]:Get())
		execute("Window.CreateConfig");execute("Window.ExportConfig");execute("Window.ValidateConfig");execute("Window.ImportConfig")
		check("sample config roundtrip remains isolated",sample._profiles["Imported copy"]~=nil and w._profiles["Imported copy"]==nil)
		execute("Window.OnConfigsChanged");execute("Window.SaveConfig");check("observer reports config events",b.ConfigEvents>0)
		local events=b.ConfigEvents;execute("Window.DisconnectConfigObserver");execute("Window.SaveConfig");check("observer can be disconnected",b.ConfigEvents==events)
		execute("Window.RenameConfig");check("sample rename updates target field",sample._profiles.Renamed~=nil)
		execute("Window.SetAutoLoadConfig");check("sample auto-load can be tested",sample:GetConfigStatus().AutoLoad=="Renamed")
		execute("Window.ClearAutoLoadConfig");execute("Window.SaveProfile");execute("Window.LoadProfile")
		check("legacy profile actions are demonstrated",sample._profiles["Legacy sample"]~=nil)
		execute("Sample.CaptureLayout");sample:SetSize(760,500);execute("Window.ImportLayout");check("layout roundtrip is testable",sample.WindowSize.X==680)
		execute("Sample.CaptureProfile");execute("Sample.Toggle");execute("Window.ImportProfile");check("profile roundtrip restores saved sample",sample._ids["sample.flag"]:Get())
		execute("Window.CaptureDefaults");execute("Sample.Toggle");execute("Window.Reset");check("direct reset applies to sample",sample._ids["sample.flag"]:Get())
		execute("Window.RequestReset");check("sample confirmation can be inspected",sample._confirmation~=nil);sample._confirmation:Cancel()
		execute("Window.DisablePersistence");check("disconnect storage is demonstrated",sample:GetPersistenceStatus()=="Disabled")
		execute("Window.Destroy");check("destroying sample preserves main demo",sample.Destroyed and not w.Destroyed)
		execute("PearlUI.new");local last=b.Sample;w:Destroy()
		check("destroying main cleans sample and polling jobs",last.Destroyed and next(w._jobs)==nil)
		return {passed=#checks,checks=checks,publicAPIs=#required}
	end)
	w:Destroy();if not ok then error(result)end;return result
end
