--!nocheck
-- ModuleScript in ReplicatedStorage, named PearlUIPersistence.
local remote = game:GetService("ReplicatedStorage"):WaitForChild("PearlUISettings", 8)
assert(remote and remote:IsA("RemoteFunction"), "PearlUI persistence server is unavailable")
local function request(operation, key, payload)
	local done, response, failure = false, nil, nil
	task.spawn(function()
		local ok, result = pcall(remote.InvokeServer, remote, operation, key, payload)
		if ok then response = result else failure = result end
		done = true
	end)
	local deadline = os.clock() + 12
	repeat task.wait(0.05) until done or os.clock() >= deadline
	assert(done, "Settings request timed out")
	assert(not failure, tostring(failure))
	assert(type(response) == "table" and response.Ok, type(response) == "table" and response.Error or "Invalid storage response")
	return response.Data
end
return {
	Load = function(key) return request("Load", key) end,
	Save = function(key, payload) request("Save", key, payload); return true end,
}
