local env = getfenv()
local function g(n)
	return env[n]
end

local global = (g("getgenv") or function() return _G end)()

if global.DesyncLib then
	return global.DesyncLib
end

local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 78, 117, 108, 108, 45, 67, 104, 101, 114, 114, 121, 47, 85, 116, 105, 108, 105, 116, 105, 101, 115, 47, 114, 101, 102, 115, 47, 104, 101, 97, 100, 115, 47, 109, 97, 105, 110, 47, 85, 116, 105, 108, 105, 116, 121, 47, 77, 97, 105, 110, 46, 108, 117, 97)))() end)()

local physics = util:Physics()
local spoofer = physics.Spoofer
local clock = util:Event().Clock

if global.DesyncLib then
	return global.DesyncLib
end

local plrSpoofer = spoofer:SpoofPlayer()
plrSpoofer.Enabled = false

local rs = game:GetService("RunService")

local library = {
	Enabled = false,
	Delay = 1,
	RandomLagTime = 0,
	Show = false,
	DontResetValues = false,
	ClearHistoryOnDeath = true,
	
	OverrideVelocity = nil,
	OverrideRotVelocity = nil,
	
	Physics = physics,
	Spoofer = spoofer,
	PlayerSpoofer = plrSpoofer,
}

local history = { }

local insert, remove, clear = table.insert, table.remove, table.clear
local tick = tick
local wait = task.wait
local random = math.random

local plr = game:GetService("Players").LocalPlayer
local fakeHrp = Instance.new("Part")
fakeHrp.Transparency = 0.5
fakeHrp.CanCollide = false
fakeHrp.CanTouch = false
fakeHrp.CanQuery = false
fakeHrp.Anchored = true
fakeHrp.Name = "Desync display"

local history = { }
local function makeRecord(hrp)
	insert(history, { hrp.CFrame, hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity, tick() })
end

local resetState = false
task.spawn(function()
	while true do
		local random = random()
		if random * library.RandomLagTime > 0 then
			local start = tick()
			while tick() - start < random * library.RandomLagTime do
				wait()
			end
		end
		
		while true do
			local _, skip = clock:Wait()
			if skip then continue end
			
			if #history == 0 or library.Delay <= 0 then
				if not library.Enabled and not resetState then
					resetState = true
					fakeHrp.Parent = nil

					if not library.DontResetValues then
						plrSpoofer.CFrame, plrSpoofer.Velocity, plrSpoofer.RotVelocity = nil, nil, nil
					end
				end

				break
			end

			local record = history[1]
			if record[4] + library.Delay < tick() then
				remove(history, 1)
			else
				break
			end

			plrSpoofer.CFrame = record[1]
			plrSpoofer.Velocity = library.OverrideVelocity or record[2]
			plrSpoofer.RotVelocity = library.OverrideRotVelocity or record[3]
			fakeHrp.CFrame = record[1]
			fakeHrp.Parent = library.Show and (workspace:FindFirstChildOfClass("Terrain") or workspace) or nil
		end
	end
end)

local can = pcall(function() plr.DevCameraOcclusionMode = plr.DevCameraOcclusionMode end)
local original = can and plr.DevCameraOcclusionMode
local invis = Enum.DevCameraOcclusionMode.Invisicam

rs.RenderStepped:Connect(function()
	plrSpoofer.Enabled = library.Enabled
	if library.Enabled and library.Delay > 0 then
		local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			if can then
				plr.DevCameraOcclusionMode = invis
			end
			
			resetState = false
			fakeHrp.Size = hrp.Size
			makeRecord(hrp)
		else
			if can then
				plr.DevCameraOcclusionMode = original
			end
			
			if library.ClearHistoryOnDeath then
				clear(history)
			end
		end
	else
		if can then
			plr.DevCameraOcclusionMode = original
		end
		
		clear(history)
	end
end)

global.DesyncLib = library
return library
