--!nocheck
-- ServerScriptService only. Uses only the invoking player's own settings key.
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Replicated = game:GetService("ReplicatedStorage")
local store = game:GetService("DataStoreService"):GetDataStore("PearlUI_Settings_v1")
local remote = Instance.new("RemoteFunction")
remote.Name = "PearlUISettings"
local busy, lastRequest, lastSave = {}, {}, {}
remote.OnServerInvoke = function(player, operation, key, payload)
	if type(key) ~= "string" or #key > 24 or not key:match("^[%w_%-]+$") then return {Ok=false,Error="Invalid settings key"} end
	if operation ~= "Load" and operation ~= "Save" then return {Ok=false,Error="Unknown storage operation"} end
	local id = player.UserId
	if busy[id] or os.clock() - (lastRequest[id] or -math.huge) < 0.5 then return {Ok=false,Error="Settings storage is busy; retry shortly"} end
	if operation == "Save" then
		if type(payload) ~= "string" or #payload > 200000 then return {Ok=false,Error="Settings exceed storage limit"} end
		local ok, data = pcall(Http.JSONDecode, Http, payload)
		if not ok or type(data) ~= "table" or data.Version ~= 1 or type(data.Current) ~= "table" or type(data.Profiles) ~= "table" then return {Ok=false,Error="Invalid settings document"} end
		if os.clock() - (lastSave[id] or -math.huge) < 6 then return {Ok=false,Error="Waiting to save latest changes; retry shortly"} end
	end
	busy[id], lastRequest[id] = true, os.clock()
	local ok, result = pcall(function()
		local storageKey = tostring(id) .. ":" .. key
		if operation == "Load" then return store:GetAsync(storageKey) end
		store:UpdateAsync(storageKey, function() return payload end)
		lastSave[id] = os.clock()
	end)
	busy[id] = nil
	if not ok then warn("[PearlUI storage] " .. tostring(result)); return {Ok=false,Error="Settings service unavailable; retry shortly"} end
	return {Ok=true,Data=result}
end
remote.Parent = Replicated
Players.PlayerRemoving:Connect(function(player)
	local id = player.UserId
	busy[id], lastRequest[id], lastSave[id] = nil, nil, nil
end)
