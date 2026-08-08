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
local user = "https://raw.githubusercontent.com/Its-Kawi/"
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

local ver = "1.04"
local wf, rf, mf, IF, df, DF = writefile or write_file, readfile or read_file, makefolder or make_folder, isfile or is_file, deletefolder or delfolder or removefolder or delete_folder or del_folder or remove_folder, deletefile or delfile or removefile or delete_file or del_fire or remove_file
local loadstring, tonumber, game, error, warn, freeze, spawn, pcall, tick, tostring = loadstring or load, tonumber, game, error, warn, table.freeze, task.spawn, pcall, tick, tostring
local utilityPrefix = "-- This is the main utility loader. Its used for quickly loading without needing to be downloaded\n"

if wf and rf and mf and df and IF and DF then
	local isf = IF(utilVerCheckFile)
	local serverVer = (isf and tick() - tonumber(rf(utilVerCheckFile)) > 10800 or not isf) and game:HttpGet(subUrls.Util .. "Utility/Version.txt", true):gsub("[\n\r\f\t\s\0 ]", "") or ver
	if tonumber(serverVer) and ver ~= serverVer then
		local self = game:HttpGet(subUrls.Util .. "Utility/Main" .. ext, true)
		local loadTest = loadstring(self)
		
		if loadTest then
			pcall(df, coreFolder:sub(1, -2))
			pcall(DF, "FireLibrary/Library" .. ext) -- force UI library to update
			
			pcall(mf, coreFolder:sub(1, -2))
			pcall(mf, utilsFolder:sub(1, -2))
			pcall(wf, utilFile, utilityPrefix .. self)
			pcall(wf, utilVerCheckFile, tostring(tick()))
			
			return loadTest()
		else
			error("Failed to update Utility to version " .. serverVer, 0)
		end
	elseif not tonumber(serverVer) then
		warn("Failed to get version for Utility: " .. serverVer)
		warn("The script using that utility might work incorrectly or not at all")
	end

	spawn(function()
		local self = game:HttpGet(subUrls.Util .. "Utility/Main" .. ext, true)
		if loadstring(self) then
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

local cache = { }

local downloadModule
local function try(moduleName)
	local filePath = utilsFolder .. hash(moduleName) .. ext
	local cached = cache[moduleName]
	if cached then
		return cached
	end

	if IF and IF(filePath) then
		return loadstring(rf(filePath))
	end

	local gkey = utilGlobalKeys[moduleName]
	if gkey then
		local found = global[gkey]
		if found then
			spawn(downloadModule, true)
			return found
		end
	end
end

function downloadModule(name, forceDownload)
	local moduleName, moduleType = getModuleInfo(name)
	
	if not forceDownload then local ret = try(moduleName) if ret then return ret end end
	local moduleContents = game:HttpGet(moduleType == "Download" and moduleName or moduleType == "Url" and urls[moduleName] or subUrls[moduleType] .. moduleName .. "/Main" .. ext, true)
	if not forceDownload then local ret = try(moduleName) if ret then return ret end end
	
	local loadTest = loadstring(moduleContents)

	if loadTest then
		pcall(wf, utilsFolder .. hash(moduleName) .. ext, "-- " .. moduleName .. "\n" .. moduleContents)
		return loadTest
	else
		error("Module failed to load: " .. moduleContents, 0)
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
		defer(function()
			pcall(downloadModule, module, true)
			pcall(downloadModule, module)
		end)
	end
end)

local returnCache = { }
local util = setmetatable({
	Load = function(self, name) if not self.Modules then error("Call via ':' next time!", 0) end return downloadModule(name)() end,
	LoadModule = function(self, ...) return self:Load(...) end,
	Modules = modules,
	Utililites = modules,
	Utils = modules
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

task.wait()
return util
