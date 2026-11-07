--!nocheck
-- Optional local-file adapter. The core library uses only injected Load/Save functions.
return function(options)
	options = options or {}
	local fs = options.FileSystem or getfenv()
	local folder = options.Folder or "PearlUI"
	local prefix = options.Prefix or ""
	assert(folder:match("^[%w_%-]+$"), "Folder must be a simple name")
	assert(type(prefix) == "string" and #prefix <= 32 and (prefix == "" or prefix:match("^[%w_%-]+$")), "Invalid file prefix")
	for _, name in ipairs({"isfile", "readfile", "writefile", "isfolder", "makefolder"}) do assert(type(fs[name]) == "function", "File adapter requires " .. name) end
	if not fs.isfolder(folder) then fs.makefolder(folder) end
	local Http = game:GetService("HttpService")
	local function path(key)
		assert(type(key) == "string" and #key <= 64 and key:match("^[%w_%-]+$"), "Invalid local storage key")
		return folder .. "/" .. prefix .. key .. ".json"
	end
	local function valid(raw)
		local ok, data = pcall(Http.JSONDecode, Http, raw)
		return ok and type(data) == "table" and data.Version == 1 and type(data.Current) == "table" and type(data.Profiles) == "table"
	end
	return {
		Load = function(key)
			local file, found = path(key), false
			for _, candidate in ipairs({file, file .. ".tmp", file .. ".bak"}) do
				if fs.isfile(candidate) then
					found = true
					local ok, raw = pcall(fs.readfile, candidate)
					if ok and valid(raw) then return raw end
				end
			end
			assert(not found, "Saved settings could not be read; existing files were preserved")
			return nil
		end,
		Save = function(key, raw)
			assert(valid(raw), "Refusing an invalid settings document")
			local file = path(key)
			fs.writefile(file .. ".tmp", raw)
			assert(fs.readfile(file .. ".tmp") == raw, "Temporary settings write failed")
			if fs.isfile(file) then
				local previous = fs.readfile(file)
				if valid(previous) then fs.writefile(file .. ".bak", previous) end
			end
			fs.writefile(file, raw)
			assert(fs.readfile(file) == raw, "Settings write verification failed")
			return true
		end,
	}
end
