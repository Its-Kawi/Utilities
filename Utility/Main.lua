local GITHUB = "https://raw.githubusercontent.com/Its-Kawi/"
local utils = {
	Data = "Util",
	ESPLib = "Util",
	Event = "Util",
	Physics = "Util",
	Typer = "Util",
	Other = "Util",
	Fire = "Util",
	EditableCursor = "Util",
	KeyEnums = "Util",
	SimpleSerializer = "Util",

	Desync = "Url",
	UI = "Url",

	NullFireWindow = "NF",
	FunkyFridayAutoPlay = "NF",
	PressureTubePuzzle = "NF"
}

local utilGlobalKeys = {
	Data = "DataLibrary",
	ESPLib = "FESPLib",
	Event = "EventLib1",
	Physics = "PhyLib",
	Other = "NFOtherLib",
	Fire = "FIRELIB_omg_UI_lib_name_drop",
	EditableCursor = "EditableCursorLib",

	Desync = "DesyncLib",
	UI = "FireLibrary",

	NullFireWindow = "NFWINDOW",
	FunkyFridayAutoPlay = "FFAutoplayLib",
	PressureTubePuzzle = "PressureTubes"
}

local ext = ".lua"
local subUrls = {
	Util = GITHUB .. "Utilities/refs/heads/main/"
}

local urls = {
	UI = GITHUB .. "Fire-Library/refs/heads/main/QuickLoader" .. ext,
	Desync = subUrls.Util .. "Physics/Desync" .. ext
}

local nfPaths = {
	NullFireWindow = "Libraries/Window",
	FunkyFridayAutoPlay = "Funky-Friday/Autoplay",
	PressureTubePuzzle = "Pressure/TubePuzzle"
}

local shortcuts = {
	ESP = "ESPLib",
	Cursor = "EditableCursor",
	Keys = "KeyEnums",
	SS = "SimpleSerializer"
}

local preload = { "Event", "Physics", "Desync", "Typer", "Other", "Fire", "KeyEnums", "SimpleSerializer" }

local global = getgenv and getgenv() or _G
local globalKey = "QKUtil"

if global[globalKey] then
	return global[globalKey]
end

local coreFolder = "QUtil/"
local utilFile = coreFolder .. "Utility" .. ext
local utilVerCheckFile = coreFolder .. "VCheck.txt"
local utilsFolder = coreFolder .. "Utilities/"
local cacheFolder = coreFolder .. "Cache/"

local wf, rf, mf, IF, If, df, DF, re, lf = writefile, readfile, makefolder, isfile or is_file, isfolder or is_folder, deletefolder or delfolder or removefolder, deletefile or delfile or removefile, request or http_request, listfiles
local loadstring, tonumber, game, error, warn, freeze, spawn, pcall, tick, tostring = loadstring or load, tonumber, game, error, warn, table.freeze, task and task.spawn or spawn, pcall, tick, tostring
local utilityPrefix = "-- This is the main utility loader. Its used for quickly loading without needing to be downloaded\n"
local pack, remove, unpack, wait = table.pack, table.remove, unpack or table.unpack, task and task.wait or wait

local recurviseDelete; function recurviseDelete(name)
	pcall(df, name)
	pcall(DF, name)
	
	if If(name) then
		for _, v in lf(name) do
			recurviseDelete(v)
		end
	end
end

local function httpGet(url, headers, retry)
	local tries = 0
	local allowed = tonumber(retry) or retry == true and 1 / 0 or 1
	local retry = allowed

	local r, s	
	while tries <= allowed do
		tries += 1

		if re then
			r = re({ Url = url, Method = "GET", Headers = headers })
			s = r.Success and r.StatusCode <= 400
			r = r.Body or ""
		else
			s, r = pcall(game.HttpGet, game, url, true, headers)
		end

		if not retry or s then
			return r, s
		end
		
		if tries < allowed then
			wait()
		end
	end

	return r, s
end

local expiryTime = 60 * 60 * 4 -- 4 hours
if wf and rf and mf and df and IF and DF and lf and If then
	local isf = IF(utilVerCheckFile)
	if isf and tick() - tonumber(rf(utilVerCheckFile)) > expiryTime then
		local self, s = httpGet(subUrls.Util .. "Utility/Main" .. ext)
		if s then
			local loadTest = loadstring(self)

			if loadTest then
				pcall(recurviseDelete, coreFolder:sub(1, -2))
				pcall(recurviseDelete, "FireLibrary/Library" .. ext) -- force UI library to update
				
				while If(coreFolder:sub(1, -2)) or IF("FireLibrary/Library" .. ext) do
					wait()
				end

				pcall(wf, utilFile, utilityPrefix .. self)
				pcall(wf, utilVerCheckFile, tostring(tick()))

				return loadTest()
			end
		end
	end

	spawn(function()
		local self, s = httpGet(subUrls.Util .. "Utility/Main" .. ext)
		if s and loadstring(self) then
			pcall(mf, coreFolder:sub(1, -2))
			pcall(mf, utilsFolder:sub(1, -2))
			pcall(mf, cacheFolder:sub(1, -2))
			pcall(wf, utilFile, utilityPrefix .. self)
			pcall(wf, utilVerCheckFile, tostring(tick()))
		end
	end)

	pcall(mf, coreFolder:sub(1, -2))
	pcall(mf, utilsFolder:sub(1, -2))
	pcall(mf, cacheFolder:sub(1, -2))
end

if global[globalKey] then
	return global[globalKey]
end

local function tableSearch(key, table)
	for k, v in table do
		if k:lower() == key:lower() then
			return k, v
		end
	end
end

local function getModuleInfo(name)
	if name:sub(1, 4):lower() == "http" then
		return name, "Download"
	end

	local _, full = tableSearch(name, shortcuts)
	full = full or name
	if not full then error("Module not found: " .. name, 0) end

	local _, moduleType = tableSearch(full, utils)
	if not moduleType then error("Module not found: " .. full, 0) end

	return full, moduleType
end

local ecs = game:GetService("EncodingService")
local md5 = Enum.HashAlgorithm.Md5

local _hx = function(a) return ("%02x"):format(a:byte()) end
local function hash(str)
	return ecs:ComputeStringHash(str, md5):gsub(".", _hx)
end

local downloadModule
local function getUrl(moduleName, moduleType)
	return moduleType == "Download" and moduleName or moduleType == "Url" and urls[moduleName] or moduleType == "NF" and (nfPaths[moduleName]:sub(1, 9) == "Libraries" and GITHUB .. "Null-Fire/refs/heads/main/Core/" or GITHUB .. "Null-Fire/refs/heads/main/Core/Loaders/") .. nfPaths[moduleName] .. (nfPaths[moduleName]:sub(1, 9) == "Libraries" and "/Main" or "") .. ext or subUrls[moduleType] .. moduleName .. "/Main" .. ext
end

local function try(moduleName, moduleType, doUpdate)
	local url = getUrl(moduleName, moduleType)
	local filePath = utilsFolder .. hash(url) .. ext

	if IF and IF(filePath) then
		return loadstring(rf(filePath))
	end

	local gkey = utilGlobalKeys[moduleName]
	if gkey then
		local found = global[gkey]
		if found then
			if doUpdate then
				spawn(downloadModule, moduleName, true)
			end

			return function() return found end
		end
	end
end

local function updCheck(hash)
	local extFile = cacheFolder .. hash
	if IF(extFile) then
		local n = tonumber(rf(extFile))
		if n and n > expiryTime then
			pcall(recurviseDelete, extFile)
			pcall(recurviseDelete, utilsFolder .. hash .. ext)
		end
	end
end

local moduleCache = { }
function downloadModule(name, forceDownload)
	local moduleName, moduleType = getModuleInfo(name)
	if not forceDownload then
		local cached = moduleCache[moduleName]
		if cached then return cached end
	end

	local url = getUrl(moduleName, moduleType)
	local hash = hash(url)
	
	pcall(updCheck, hash)

	if not forceDownload then local ret = try(moduleName, moduleType, true) if ret then moduleCache[moduleName] = ret return ret end end
	local moduleContents = httpGet(url, nil, true)
	if not forceDownload then local ret = try(moduleName, moduleType, true) if ret then moduleCache[moduleName] = ret return ret end end
	
	local loadTest = loadstring(moduleContents)
	if loadTest then
		pcall(wf, utilsFolder .. hash .. ext, "-- " .. moduleName .. ext .."\n" .. moduleContents)
		pcall(wf, cacheFolder .. hash, tostring(tick()))

		moduleCache[moduleName] = loadTest
		return loadTest
	else
		error("Module failed to load: " .. moduleContents, 0)
	end
end

local function bruteforceLoadModule(name)
	while true do
		local success, func = pcall(downloadModule, name)
		if success then
			return func
		end

		warn("Downloading", name, "failed:", func)
		wait()
	end
end

local modules = { }
for module in utils do
	modules[#modules + 1] = module
end

freeze(modules)

local defer = task.defer
local find = table.find

spawn(function()
	for i, module in modules do
		pcall(downloadModule, module, true)
		local s, f = pcall(bruteforceLoadModule, module)

		if s and find(preload, module) then
			pcall(f)
		end
	end
end)

local returnCache = { }
local util = setmetatable({
	Download = function(self, name) if not self.Modules then error("Call via ':' next time!", 0) end return bruteforceLoadModule(name) end,
	Modules = modules,
	Utililites = modules,
	Utils = modules,

	HttpGet = function(self, url, headers, retry)
		return httpGet(url, headers, retry)
	end,
	HttpPost = function(self, url, body, headers, retry)
		local tries = 0
		local allowed = tonumber(retry) or retry == true and 1 / 0 or 1
		local retry = allowed

		local r, s	
		while tries <= allowed do
			tries += 1

			if re then
				r = re({ Url = url, Method = "POST", Body = body, Headers = headers })
				s = r.Success and r.StatusCode <= 400
				r = r.Body or ""
			else
				s, r = pcall(game.HttpPost, game, url, body, headers)
			end

			if not retry or s then
				return r, s
			end

			if tries < allowed then
				wait()
			end
		end

		return r, s
	end
}, freeze({
	__index = function(self, name)
		local safeName = name:gsub("[\n\r\f\t\0 ]", ""):lower()
		safeName = safeName:sub(1, 1):upper() .. safeName:sub(2)

		local c = returnCache[safeName]
		if c then return c end

		local retF = function(self, ...) return self:Download(name)(...) end
		returnCache[safeName] = retF

		return retF
	end,
	__newindex = error,
	__metatable = getmetatable(game)
}))

global[globalKey] = util

wait()
return util
