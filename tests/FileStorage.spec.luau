--!nocheck
return function(factory)
	local checks,files,folders={},{},{}
	local function check(n,v)assert(v,"FAILED: "..n);table.insert(checks,n)end
	local fs={isfile=function(p)return files[p]~=nil end,readfile=function(p)assert(files[p],"Missing file");return files[p]end,writefile=function(p,v)files[p]=v end,isfolder=function(p)return folders[p]==true end,makefolder=function(p)folders[p]=true end}
	local adapter=factory({FileSystem=fs,Folder="PearlTest",Prefix="u1_"})
	local first='{"Version":1,"Current":{"Version":1,"Values":{}},"Profiles":{}}'
	local second='{"Version":1,"Current":{"Version":1,"Values":{"flag":true}},"Profiles":{}}'
	check("first load distinguishes missing settings",adapter.Load("demo")==nil)
	assert(adapter.Save("demo",first));check("save writes verified settings",files["PearlTest/u1_demo.json"]==first and files["PearlTest/u1_demo.json.tmp"]==first)
	assert(adapter.Save("demo",second));check("next save preserves backup",files["PearlTest/u1_demo.json.bak"]==first)
	files["PearlTest/u1_demo.json"]="broken";check("damaged primary recovers verified temporary file",adapter.Load("demo")==second)
	files["PearlTest/u1_demo.json.tmp"]="broken";check("backup recovers damaged primary and temp",adapter.Load("demo")==first)
	files["PearlTest/u1_demo.json.bak"]="broken";check("unrecoverable settings raise instead of overwriting",not pcall(adapter.Load,"demo"))
	check("path traversal key rejected",not pcall(adapter.Load,"../other"))
	check("invalid payload rejected before writes",not pcall(adapter.Save,"demo","invalid") and files["PearlTest/u1_demo.json"]=="broken")
	local another=factory({FileSystem=fs,Folder="PearlTest",Prefix="u2_"})
	check("account prefixes isolate settings",another.Load("demo")==nil)
	assert(another.Save("demo",first));check("isolated save leaves other account intact",files["PearlTest/u1_demo.json"]=="broken")
	local reopened=factory({FileSystem=fs,Folder="PearlTest",Prefix="u2_"})
	check("new adapter instance loads persisted file",reopened.Load("demo")==first)
	return {passed=#checks,checks=checks}
end
