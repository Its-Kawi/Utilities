local env = getfenv()
local function g(n)
	return env[n]
end

local global = (g("getgenv") or function() return _G end)()
local key = "FIRELIB_omg_UI_lib_name_drop"

if global[key] then
	return global[key]
end

local repeats = setmetatable({ }, { __mode = "kv" })
local cd = setmetatable({ }, { __mode = "kv" })

local plr = game:GetService("Players").LocalPlayer
local rns = game:GetService("RunService").RenderStepped
local ins = Instance.new
local spawn, wait = task.spawn, task.wait
local tonumber = tonumber
local max = math.max
local game, workspace = game, workspace
local pcall = pcall
local typeof = typeof

local function rs(times)
	local dt = 0

	for i = 1, tonumber(times) or 1 do
		dt += rns:Wait()
	end

	return dt
end

local function objCheck(pp, obj)
	if not pp or not pp.Parent or not obj or not obj.Parent or not workspace.CurrentCamera then
		pcall(obj.Destroy, obj)
		return true
	end
end

local originalFPP = true
local _fireproximityprompt = function(pp, repeatTimes)
	repeatTimes = max(tonumber(repeatTimes) or 1, 0)
	repeats[pp] = (repeats[pp] or 0) + repeatTimes

	if cd[pp] then return end

	cd[pp] = true

	local a, b, c, d, e = pp.MaxActivationDistance, pp.Enabled, pp.Parent, pp.HoldDuration, pp.RequiresLineOfSight
	local obj = ins("Part", workspace)
	obj.Transparency = 1
	obj.CanCollide = false
	obj.Size = Vector3.new(0.1, 0.1, 0.1)
	obj.Anchored = true

	pp.Parent = obj
	pp.MaxActivationDistance = 1 / 0
	pp.Enabled = true
	pp.HoldDuration = 0
	pp.RequiresLineOfSight = false

	if objCheck(pp, obj) then return end; obj:PivotTo(workspace.CurrentCamera.CFrame + (workspace.CurrentCamera.CFrame.LookVector / 5)) rs()
	obj:PivotTo(workspace.CurrentCamera.CFrame + (workspace.CurrentCamera.CFrame.LookVector / 5))

	for i = 1, repeats[pp] do
		pp:InputHoldBegin(); pp:InputHoldEnd()
	end

	cd[pp] = nil
	repeats[pp] = nil

	if pp.Parent == obj then
		pp.Parent = c
		pp.MaxActivationDistance = a
		pp.Enabled = b
		pp.HoldDuration = d
		pp.RequiresLineOfSight = e
	end

	obj:Destroy()
end

local function touchYield(dynamicPart, staticPart)
	local con; con = staticPart.Touched:Connect(function(hit)
		if hit == dynamicPart then
			con:Disconnect()
		end
	end)

	local i = 0
	repeat
		staticPart.CanTouch = true

		i += 1
		if i == 5 then
			i = 0

			dynamicPart:PivotTo(staticPart:GetPivot() + Vector3.new(0, 1))
			dynamicPart.AssemblyLinearVelocity = Vector3.new(0, -25)
		end

		rs()
	until not con.Connected or not dynamicPart.Parent or not staticPart.Parent
	pcall(con.Disconnect, con)
end

local ofiretouchinterest = function(a, b, c)
	if a:IsA("TouchTransmitter") then
		a = a.Parent
	end

	if b:IsA("TouchTransmitter") then
		b = b.Parent
	end

	if cd[a] or cd[b] then return end

	if typeof(c) == "boolean" then
		c = c and 1 or 0
	elseif c ~= 1 and c ~= 0 then
		error("number must be 1 or 0", 0)
	end

	if a:IsDescendantOf(plr.Character) and b:IsDescendantOf(plr.Character) or a == b then return end
	if b:IsDescendantOf(plr.Character) then
		a, b = b, a
	end

	cd[a] = true
	cd[b] = true

	if c == 0 then
		local ct = b.CanTouch

		b.CanTouch = false
		rs(); rs()
		b.CanTouch = ct
	else
		local pp = b:GetPivot()
		local t, c, an, pa, si = b.Transparency, b.CanCollide, b.Anchored, b.Parent, b.Size

		b:PivotTo(a:GetPivot())

		b.Parent = workspace
		b.Transparency = 1
		b.CanCollide = false
		b.Anchored = false
		b.Size = Vector3.new(0.001, 0.001, 0.001)

		touchYield(b, a)

		b.Parent = pa
		b.Transparency = t
		b.CanCollide = c
		b.Anchored = an
		b.Size = si

		b:PivotTo(pp)
	end

	cd[a] = nil
	cd[b] = nil
end

local _firetouchinterest = ofiretouchinterest
local firetouchinterest = function(...)
	_firetouchinterest(...)
end

local v3 = vector.create
local getPosition; getPosition = function(obj)
	if not obj then return v3(0, 0, 0) end
	if obj:IsA("Folder") then
		local pos = v3(0, 0, 0)
		local total = 0

		for _, v in obj:GetChildren() do
			if v:IsA("Model") or v:IsA("BasePart") then
				pos += getPosition(v)
				total += 1
			end
		end

		return pos / total
	elseif obj:IsA("Camera") then
		return obj.CFrame.Position
	end

	return obj:GetPivot(obj).Position
end

local getHolder; getHolder = function(obj)
	if not obj or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart") or obj:IsA("Attachment") then return obj end
	return getHolder(obj.Parent)
end

spawn(pcall, function()
	local fti = getfenv().firetouchinterest
	if fti then
		local ftiv = false

		local part = ins("Part", workspace)
		part.Position = v3(1234, 10000, 5678)
		part.Anchored = false -- important
		part.CanCollide = false
		part.Transparency = 1
		part.Touched:Once(function()
			part:Destroy()
			ftiv = true
		end)

		wait(0.1)
		repeat wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and part and part.Parent

		fti(part, plr.Character.HumanoidRootPart, 0)
		fti(plr.Character.HumanoidRootPart, part, 0)
		wait()

		repeat wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and part and part.Parent
		fti(part, plr.Character.HumanoidRootPart, 1)
		fti(plr.Character.HumanoidRootPart, part, 1)

		wait()

		if ftiv then
			_firetouchinterest = fti
		end
	end
end)

spawn(pcall, function()
	local fpp = getfenv().fireproximityprompt
	if fpp then
		local fppn = false
		local part = ins("Part", workspace)
		part.Position = v3(1234, 10000, 5678)
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		
		local pp = ins("ProximityPrompt", part)
		pp.MaxActivationDistance = 0
		
		pp.Triggered:Once(function()
			fppn = true
		end)

		spawn(fpp, pp)
		rs(2)
		
		if fppn then
			originalFPP = false
			_fireproximityprompt = fpp
		end
		
		pp:Destroy()
		part:Destroy()
	end
end)

local touchpart = function(part, useOld)
	local part2 = plr.Character and plr.Character:FindFirstChildWhichIsA("BasePart", true)
	if not part2 then
		error("Unable to touch the Part!", 0)
	end

	(useOld and ofiretouchinterest or firetouchinterest)(part, part2, true)
end

local lib = {
	fireproximityprompt = function(pp : ProximityPrompt, hitTimes, distanceCheck)
		if cd[pp] or distanceCheck and ((plr.Character and ((plr.Character.PrimaryPart and plr.Character):GetPivot().Position) or workspace.CurrentCamera.CFrame.Position) - getPosition(getHolder(pp))).Magnitude > pp.MaxActivationDistance + 0.1 then return end

		if originalFPP then
			spawn(_fireproximityprompt, pp, hitTimes)
		else
			for i = 1, hitTimes or 1 do
				spawn(_fireproximityprompt, pp)
			end
		end
	end,
	firetouchinterest = firetouchinterest,
	touchpart = touchpart,
	sit = function(seatPart)
		if not seatPart or not plr.Character then return end
		local hum = plr.Character:FindFirstChildOfClass("Humanoid")

		if hum then
			if seatPart.Occupant then return end
			
			local old = seatPart:GetPivot()
			seatPart:PivotTo(plr.Character.HumanoidRootPart:GetPivot())
			
			touchpart(seatPart, true)
			
			seatPart:PivotTo(old)
		end
	end
}

global[key] = lib
return lib
