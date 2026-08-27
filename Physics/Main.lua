local libN = "PhyLib"
local g = (getfenv().getgenv or function() return _G end)()

if g[libN] then
	return g[libN]
end

local pack = table.pack
local error = error
local pcall = pcall
local typeof = typeof
local tonum = tonumber
local spawn = task.spawn
local freeze = table.freeze
local smt = setmetatable
local clear = table.clear
local insert = table.insert
local remove = table.remove
local rawset = rawset
local find = table.find
local wait = task.wait
local unpack = table.unpack
local random = math.random
local v3 = vector.create
local deg = math.deg
local ncf = CFrame.new
local xyz = CFrame.fromEulerAnglesXYZ
local rad = math.rad
local look = CFrame.lookAt
local workspace = workspace
local clamp = math.clamp
local newproxy = newproxy

local zero = v3(0, 0, 0)
local cfz = ncf()

local GITHUB = "https://raw.githubusercontent.com/Its-Kawi/"
local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local url = GITHUB .. "Utilities/refs/heads/main/Utility/Main.lua" local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or getfenv().request and getfenv().request({ Url = url, Method = "GET" }).Body or game:HttpGet(url))() end)()

if g[libN] then
	return g[libN]
end

local event = util:Event()
local beforeSpoofing, afterSpoofing, afterSpoofCycle = event.new(), event.new(), event.new()

local function fr()
	return (random() - 0.5) * 2
end

local spoofQueue = { }
local spooferToData = { }

local _spooferBase = {
	Set = function(self)
		self = spooferToData[self] if not self then return end
		
		if not self.Enabled or not self.Object then return end
		self.BeforeSet:Fire()

		local props = self.Properties
		local object = self.Object
		local originalValues = self.OriginalValues

		originalValues.CFrame = object.CFrame
		originalValues.Velocity = object.AssemblyLinearVelocity
		originalValues.RotVelocity = object.AssemblyAngularVelocity

		object.CFrame = (props.CFrame or object.CFrame) * (props.OffsetCFrame or cfz) * (ncf(fr() / 1000, fr() / 1000, fr() / 1000) * xyz(fr() / 100000, fr() / 100000, fr() / 100000))
		object.AssemblyLinearVelocity = (props.Velocity or object.AssemblyLinearVelocity) + (props.OffsetVelocity or zero) + v3(fr() / 1000, fr() / 1000, fr() / 1000)
		object.AssemblyAngularVelocity = (props.RotVelocity or object.AssemblyAngularVelocity) + (props.OffsetRotVelocity or zero) + v3(fr() / 1000, fr() / 1000, fr() / 1000)

		originalValues.NewCFrame = object.CFrame
		self.AfterSet:Fire()
	end,
	Restore = function(self)
		self = spooferToData[self] if not self then return end

		if not self.Object then return end
		self.BeforeRestore:Fire()

		local object = self.Object
		local props = self.Properties
		local originalValues = self.OriginalValues

		local newCFrame = originalValues.NewCFrame
		originalValues.NewCFrame = nil

		if newCFrame then
			if (object.Position - newCFrame.Position).Magnitude >= 0.01 then -- teleported
				originalValues.CFrame = nil
				originalValues.Velocity = props.Velocity and props.Velocity + v3(fr() / 10, fr() / 10, fr() / 10) or originalValues.Velocity or zero
			end
		end

		for i, v in originalValues do
			object[i == "RotVelocity" and "AssemblyAngularVelocity" or i] = typeof(v) == "Vector3" and (v + v3(0, 0.01)) or v
		end

		clear(originalValues)
		self.AfterRestore:Fire()
	end,

	Unlink = function(self)
		local found = find(spoofQueue, self)
		if found then
			remove(spoofQueue, found)
		end
	end
}

local spooferBase = {
	__index = function(self, index)
		self = spooferToData[self]
		
		local got = _spooferBase[index]
		if got == nil then
			if not self then return end
			got = self.Properties[index]
			
			if got == nil then
				got = self[index]
			end
		end
		
		return got
	end,
	__newindex = function(self, index, value)
		self = spooferToData[self] if not self then error() end

		if index == "Enabled" then
			rawset(self, index, not not value)
		elseif index == "Object" then
			rawset(self, index, typeof(value) == "Instance" and value or nil)
		else
			self.Properties[index] = value
		end
	end,
	__metatable = "Spoofer",
	__tostring = function(self)
		if not self then return "nil Spoofer" end
		return self.Object and self.Object:GetFullName() .. " Spoofer" or "None Spoofer"
	end
}

local newSpoofer = function(object)
	local spooferData = { Properties = { }, OriginalValues = { }, BeforeSet = event.new(), AfterSet = event.new(), BeforeRestore = event.new(), AfterRestore = event.new(), Enabled = true, Object = object }
	local proxy = newproxy(true)
	local meta = getmetatable(proxy)
	
	for i, v in spooferBase do
		meta[i] = v
	end
	
	insert(spoofQueue, proxy)
	spooferToData[proxy] = spooferData
	
	return proxy
end

local rs = game:GetService("RunService")
local hb = rs.PostSimulation
local rns = rs.RenderStepped
local s = rs.PreAnimation

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local playerSpoofer = newSpoofer(plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") or nil)
playerSpoofer.Enabled = false

local lib

task.spawn(function()
	while task.wait() do
		playerSpoofer.Object = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") or nil
	end
end)

task.spawn(function()
	while hb:Wait() do
		if not lib.Spoofer.Enabled then continue end

		beforeSpoofing:Fire()
		for i, v in spoofQueue do
			pcall(v.Set, v)
		end

		afterSpoofing:Fire()
		rns:Wait()

		for i, v in spoofQueue do
			pcall(v.Restore, v)
		end

		s:Wait()
		afterSpoofCycle:Fire()
	end
end)

local prev, old
beforeSpoofing:Connect(function()
	if playerSpoofer.Object then
		old = playerSpoofer.Object.CFrame.Position
	end
end)

playerSpoofer.BeforeRestore:Connect(function()
	if not lib.Spoofer.AdjustCamera or not lib.Spoofer.Enabled then return end

	local cam = workspace.CurrentCamera
	if playerSpoofer.Object and playerSpoofer.Enabled and cam.CFrame ~= prev and old then
		cam.CFrame += (old - playerSpoofer.Object.CFrame.Position)
		prev = cam.CFrame
	end
end)

local can = pcall(function() plr.DevCameraOcclusionMode = plr.DevCameraOcclusionMode end)
if can then
	local original = plr.DevCameraOcclusionMode
	local invis = Enum.DevCameraOcclusionMode.Invisicam
	
	rs.PreRender:Connect(function()
		plr.DevCameraOcclusionMode = lib.Spoofer.Enabled and playerSpoofer.Enabled and invis or original
	end)
end

lib = freeze({
	Spoofer = {
		Spoof = function(self, object) return newSpoofer(object) end,
		Enabled = true,
		AdjustCamera = true,
		Objects = spoofQueue,

		SpoofPlayer = function(self)
			playerSpoofer.Enabled = true
			return playerSpoofer
		end,

		BeforeSpoofing = beforeSpoofing,
		AfterSpoofing = afterSpoofing,
		AfterSpoofCycle = afterSpoofCycle
	}
})

g[libN] = lib
return lib
