local utils = {
	Data = "Util",
	ESPLib = "Util",
	Event = "Util",
	Physics = "Util",
	Typer = "Util",
	Desync = "Url",
	UI = "Url",
	NullFireWindow = "Url",
	FunkyFridayAutoPlay = "Url"
}

local utilGlobalKeys = {
	Data = "DataLibrary",
	ESPLib = "FESPLib",
	Event = "EventLib1",
	Physics = "PhyLib",
	Desync = "DesyncLib",
	UI = "FireLibrary",
	NullFireWindow = "NFWINDOW",
	FunkyFridayAutoPlay = "FFAutoplayLib"
}

local ext = ".lua"
local user = "https://raw.githubusercontent.com/Null-Cherry/"
local subUrls = {
	Util = user .. "Utilities/refs/heads/main/"
}

local urls = {
	UI = user .. "Fire-Library/refs/heads/main/QuickLoader" .. ext,
	Desync = subUrls.Util .. "Physics/Desync" .. ext,
	NullFireWindow = user .. "Null-Fire/refs/heads/main/Core/Libraries/Window/Main" .. ext,
	FunkyFridayAutoPlay = user .. "Null-Fire/refs/heads/main/Core/Loaders/Funky-Friday/Autoplay" .. ext
}

local shortcuts = {
	ESP = "ESPLib"
}

local global = getgenv and getgenv() or _G
local globalKey = "QKUtil"

if global[globalKey] then
	return global[globalKey]
end

local coreFolder = "QUtil/"
local utilFile = coreFolder .. "Utility" .. ext
local utilVerCheckFile = coreFolder .. "VCheck.txt"
local utilsFolder = coreFolder .. "Utilities/"

local wf, rf, mf, IF, df, DF, re = writefile or write_file, readfile or read_file, makefolder or make_folder, isfile or is_file, deletefolder or delfolder or removefolder or delete_folder or del_folder or remove_folder, deletefile or delfile or removefile or delete_file or del_fire or remove_file, request or http_request
local loadstring, tonumber, game, error, warn, freeze, spawn, pcall, tick, tostring = loadstring or load, tonumber, game, error, warn, table.freeze, task and task.spawn or spawn, pcall, tick, tostring
local utilityPrefix = "-- This is the main utility loader. Its used for quickly loading without needing to be downloaded\n"

local function httpGet(url, headers)
	if re then
		local r = re({ Url = url, Method = "GET", Headers = headers })
		return r.Body or "", r.Success
	else
		local s, r = pcall(game.HttpGet, game, url, true, headers)
		return s, r
	end
end

if wf and rf and mf and df and IF and DF then
	local isf = IF(utilVerCheckFile)
	if isf and tick() - tonumber(rf(utilVerCheckFile)) > 10800 or not isf then
		local self, s = httpGet(subUrls.Util .. "Utility/Main" .. ext)
		if s then
			local loadTest = loadstring(self)
			
			if loadTest then
				pcall(df, coreFolder:sub(1, -2))
				pcall(DF, "FireLibrary/Library" .. ext) -- force UI library to update
				
				pcall(mf, coreFolder:sub(1, -2))
				pcall(mf, utilsFolder:sub(1, -2))
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
			pcall(wf, utilFile, utilityPrefix .. self)
			pcall(wf, utilVerCheckFile, tostring(tick()))
		end
	end)
	
	pcall(mf, coreFolder:sub(1, -2))
	pcall(mf, utilsFolder:sub(1, -2))
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
local function try(moduleName, doUpdate)
	local filePath = utilsFolder .. hash(moduleName) .. ext
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

function downloadModule(name, forceDownload)
	local moduleName, moduleType = getModuleInfo(name)
	
	if not forceDownload then local ret = try(moduleName, true) if ret then return ret end end
	local moduleContents, s = httpGet(moduleType == "Download" and moduleName or moduleType == "Url" and urls[moduleName] or subUrls[moduleType] .. moduleName .. "/Main" .. ext)
	if not s or moduleContents:gsub("[\n\r\f\t\0 ]", "") == "" or #moduleContents < #utilityPrefix + 5 then
		return downloadModule(name, true)
	end
	
	if not forceDownload then local ret = try(moduleName, false) if ret then return ret end end
	local loadTest = loadstring(moduleContents)

	if loadTest then
		pcall(wf, utilsFolder .. hash(moduleName) .. ext, "-- " .. moduleName .. "\n" .. moduleContents)
		return loadTest
	else
		error("Module failed to load: " .. moduleContents, 0)
	end
end

local pack, remove, unpack, wait = table.pack, table.remove, unpack or table.unpack, task and task.wait or wait
local function bruteforceLoadModule(name)
	while true do
		local success, func = pcall(downloadModule, name)
		if success then
			return func
		end
		
		warn("Download failed:", func)
		wait()
	end
end

local modules = { }
for module in utils do
	modules[#modules + 1] = module
end

freeze(modules)

local defer = task.defer
spawn(function()
	for i, module in modules do
		pcall(downloadModule, module, true)
		pcall(bruteforceLoadModule, module)
	end
end)

local returnCache = { }
local util = setmetatable({
	Load = function(self, name) if not self.Modules then error("Call via ':' next time!", 0) end return bruteforceLoadModule(name)() end,
	LoadModule = function(self, ...) return self:Load(...) end,
	Modules = modules,
	Utililites = modules,
	Utils = modules,
	
	HttpGet = function(self, url, headers)
		return httpGet(url, headers)
	end,
	HttpPost = function(self, url, body, headers)
		if re then
			local r = re({ Url = url, Method = "POST", Body = body, Headers = headers })
			return r.Body, r.Success
		else
			local s, r = pcall(game.HttpPost, game, url, body, headers)
			return r, s
		end
	end
}, freeze({
	__index = function(_, name)
		local safeName = name:gsub("[\n\r\f\t\s\0 ]", ""):lower()
		local c = returnCache[safeName]
		if c then return c end
		
		local retF = function(self) return self:Load(name) end
		returnCache[safeName] = retF
		
		return retF
	end,
	__newindex = error,
	__metatable = getmetatable(game)
}))

global[globalKey] = util

wait()
return util
