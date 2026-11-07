--!nocheck
return function(PearlUI, reloadLibrary, legacyLibrary)
	assert(type(reloadLibrary)=="function","Provide a fresh library evaluator for cross-copy testing")
	local checks,windows,objects={},{},{}
	local parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	local function check(name,value)assert(value,"FAILED: "..name);table.insert(checks,name)end
	local function create(lib,name,options)
		options=options or {};options.Name=name;options.ReduceMotion=true;options.Parent=options.Parent or parent
		local w=lib.new(options);table.insert(windows,w)
		local s=w:Tab("General"):Section({Title="Settings",Id="settings"})
		local flag=s:Toggle({Id="flag",Default=false})
		return w,s,flag
	end
	local function count(name)local n=0;for _,g in ipairs(parent:GetChildren())do if g.Name==name then n+=1 end end;return n end
	local ok,result=pcall(function()
		local a,s,flag=create(PearlUI,"PearlRerunTest")
		local raw,saves=nil,0
		local adapter={Load=function()return raw end,Save=function(_,value)raw=value;saves+=1;return true end}
		a:Ready({Adapter=adapter,Key="rerun"});flag:Set(true);s:Detach();a:_activateChrome(1)
		local other=create(PearlUI,"PearlRerunOther")
		local fresh=reloadLibrary();check("factory evaluates a separate module",fresh~=PearlUI)
		local b,_,newFlag=create(fresh,"PearlRerunTest")
		check("same name replaces window across module copies",a.Destroyed and not b.Destroyed)
		check("replacement removes old main and dock",a.Gui.Parent==nil and a.DockGui.Parent==nil)
		check("replacement removes detached panel",s.Float.Parent==nil)
		check("replacement cancels pending confirmation",a._confirmation==nil)
		check("replacement releases old connections and jobs",#a._connections==0 and next(a._jobs)==nil)
		check("replacement flushes old configured autosave",saves==1 and raw~=nil)
		check("different window names stay alive",not other.Destroyed)
		check("only one matching main and dock remain",count("PearlRerunTest")==1 and count("PearlRerunTest_Dock")==1)
		b:Ready({Adapter=adapter,Key="rerun"});check("new window reloads flushed values",newFlag:Get())
		local bad=pcall(function()fresh.new({Name="PearlRerunTest",Theme="Unknown"})end)
		check("invalid replacement preserves old window",not bad and not b.Destroyed)
		check("invalid replacement option rejected",not pcall(function()fresh.new({Name="PearlRerunTest",ReplaceExisting="yes"})end) and not b.Destroyed)
		local c=create(fresh,"PearlRerunMulti",{ReplaceExisting=false})
		local d=create(PearlUI,"PearlRerunMulti",{ReplaceExisting=false})
		check("explicit opt-out permits multiple windows",not c.Destroyed and not d.Destroyed and count("PearlRerunMulti")==2)
		local e=create(fresh,"PearlRerunMulti")
		check("default replacement retires all matching owners",c.Destroyed and d.Destroyed and not e.Destroyed and count("PearlRerunMulti")==1)
		local folder=Instance.new("Folder");folder.Name="PearlRerunParentTest";folder.Parent=parent;table.insert(objects,folder)
		local nested=create(PearlUI,"PearlRerunOther",{Parent=folder})
		check("same name in another parent is independent",not nested.Destroyed and not other.Destroyed)
		local unowned=Instance.new("ScreenGui");unowned.Name="PearlRerunUnowned";unowned.Parent=parent;table.insert(objects,unowned)
		create(fresh,"PearlRerunUnowned")
		check("unrelated matching-name GUI is preserved",unowned.Parent==parent)
		local defaultOld=create(PearlUI,nil,{Parent=folder})
		local defaultNew=create(fresh,nil,{Parent=folder})
		check("default PearlUI name also replaces",defaultOld.Destroyed and not defaultNew.Destroyed)
		local gate=Instance.new("BindableEvent");table.insert(objects,gate)
		local started,completed,replacement=false,false,nil
		local slow,_,slowFlag=create(PearlUI,"PearlRerunConcurrent")
		slow:Ready({Key="slow",Adapter={Load=function()return nil end,Save=function()started=true;gate.Event:Wait();return true end}})
		slowFlag:Set(true)
		task.spawn(function()local success,value=pcall(create,fresh,"PearlRerunConcurrent");replacement=success and value;completed=true end)
		local deadline=os.clock()+3;repeat task.wait()until started or os.clock()>deadline
		check("replacement awaits old storage flush",started and not completed)
		task.delay(.2,function()gate:Fire()end)
		local duplicate=pcall(function()create(PearlUI,"PearlRerunConcurrent")end)
		check("overlapping rerun cannot create duplicate",not duplicate)
		gate:Fire();deadline=os.clock()+3;repeat task.wait()until completed or os.clock()>deadline
		check("pending replacement completes after flush",completed and replacement and slow.Destroyed)
		check("concurrent replacement leaves one main and dock",count("PearlRerunConcurrent")==1 and count("PearlRerunConcurrent_Dock")==1)
		local leaseLeft=false;for _,g in ipairs(parent:GetChildren())do if g:GetAttribute("PearlUIReplacing")~=nil then leaseLeft=true end end
		check("replacement lease removed",not leaseLeft)
		if legacyLibrary then
			local old=create(legacyLibrary,"PearlRerunLegacy")
			create(fresh,"PearlRerunLegacy");task.wait(.1)
			check("previous library version retires through Destroying",old.Destroyed and old.DockGui.Parent==nil and #old._connections==0)
		end
		return {passed=#checks,checks=checks,crossModule=true,legacy=legacyLibrary~=nil}
	end)
	for _,w in ipairs(windows)do w:Destroy()end
	for _,object in ipairs(objects)do object:Destroy()end
	if not ok then error(result)end
	return result
end
