--!nocheck
return function(build)
	local checks,files,clock,fail={}, {}, 100, false
	local function check(n,v)assert(v,"FAILED: "..n);table.insert(checks,n)end
	local cleanup,remote
	local store={GetAsync=function(_,k)if fail then error("offline")end;return files[k]end,UpdateAsync=function(_,k,fn)if fail then error("offline")end;files[k]=fn(files[k]);return files[k]end}
	local services={Players={PlayerRemoving={Connect=function(_,fn)cleanup=fn end}},HttpService=game:GetService("HttpService"),ReplicatedStorage={},DataStoreService={GetDataStore=function()return store end}}
	remote=build({GetService=function(_,n)return services[n]end},{new=function()return {}end},{clock=function()return clock end})
	local a,b={UserId=123},{UserId=456}
	local raw='{"Version":1,"Current":{"Version":1,"Values":{}},"Profiles":{}}'
	local function invoke(player,operation,key,data)clock+=1;return remote.OnServerInvoke(player,operation,key,data)end
	check("unknown server operation rejected",not invoke(a,"Delete","demo").Ok)
	check("server key traversal rejected",not invoke(a,"Load","../other").Ok)
	check("long server key rejected",not invoke(a,"Load",string.rep("a",25)).Ok)
	local response=invoke(a,"Load","demo")
	check("server returns missing settings without fake data",response.Ok and response.Data==nil)
	check("invalid save document rejected",not invoke(a,"Save","demo","broken").Ok)
	check("oversized payload rejected",not invoke(a,"Save","demo",string.rep("a",200001)).Ok)
	check("valid settings acknowledged",invoke(a,"Save","demo",raw).Ok and files["123:demo"]==raw)
	check("writes are scoped to invoking user",invoke(b,"Load","demo").Ok and files["456:demo"]==nil)
	check("save cooldown rejects extra writes",not invoke(a,"Save","demo",raw).Ok)
	clock+=6;check("save succeeds after cooldown",invoke(a,"Save","demo",raw).Ok)
	fail=true;check("backend error is returned to client",not invoke(b,"Load","demo").Ok)
	fail=false;check("backend failure releases request lock",invoke(b,"Load","demo").Ok)
	clock+=6;remote.OnServerInvoke(a,"Load","demo");check("request burst is throttled",not remote.OnServerInvoke(a,"Load","demo").Ok)
	cleanup(a);check("player removal clears throttle state",remote.OnServerInvoke(a,"Load","demo").Ok)
	return {passed=#checks,checks=checks}
end
