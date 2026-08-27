local global = (getfenv().getgenv or function() return _G end)()
local key = "EditableCursorLib"

if global[key] then
	return global[key]
end

local base = "111611945515467"

local BASE_DECREASE, BIG_DECREASE = 1, 4 -- fixes pixels being weird

local BASE = 128 - BASE_DECREASE
local BIG = 196 - BIG_DECREASE

local EFFECTS = { -- Order, ID, Name, Is Pixelated, Size, Put Behind Base, Default Color | nil
	-- There gonna be +1 order skip for each new category

	GlitchyGlow = { 1, "109237646553064", "Glitchy Glow", true, BIG, true, nil },
	Glitch = { 2, "137064778284738", "Glitch", true, BASE, false, nil },
	GlitchyOutline = { 3, "100747681027577", "Inside Glitchy Outline", true, BASE, false, nil },
	SmallGlitch = { 4, "115837731276292", "Small Glitch", true, BASE, false, nil },

	Glow = { 6, "111303583666486", "Glow", false, BIG, true, nil },
	CenteredGlow = { 7, "117156608404145", "Centered Glow", false, BASE, false, nil },
	InsideGlow = { 8, "82284124866450", "Inside Glow", false, BASE, false, nil },

	Outline = { 10, "137779358107707", "Outline", false, BIG, true, Color3.new(0, 0, 0) },
	CenteredOutline = { 11, "107008327010804", "Centered Outline", false, BASE, false, nil },
	InsideOutline = { 12, "89472362438218", "Inside Outline", false, BASE, false, Color3.new(0, 0, 0) },

	GradientTop = { 14, "125702466733350", "Top Gradient", false, BASE, false, nil },
	GradientBottom = { 15, "78860595216966", "Bottom Gradient", false, BASE, false, nil },

	Normal3D = { 17, "105926903515772", "3D", false, BASE, false, Color3.new(1, 1, 1) },
	Blurred3D = { 18, "110410299371403", "Blurred 3D", false, BASE, false, Color3.new(1, 1, 1) },
	Metallic3D = { 19, "136384212097552", "Metallic 3D", false, BASE, false, Color3.new(1, 1, 1) }
}

BASE += BASE_DECREASE
BIG += BIG_DECREASE

for i, v in EFFECTS do
	local ratio = v[5] / BASE
	v[5] = UDim2.fromScale(ratio, ratio)
end

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer or plrs.PlayerAdded:Wait()

local cursorsGUI = Instance.new("ScreenGui")
task.spawn(function()
	cursorsGUI.Parent = getfenv().gethui and getfenv().gethui() or game:GetService("CoreGui") or plr:WaitForChild("PlayerGui")
end)

pcall(function()
	cursorsGUI.OnTopOfCoreBlur = true
end)

cursorsGUI.IgnoreGuiInset = false
cursorsGUI.ResetOnSpawn = false
cursorsGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
cursorsGUI.DisplayOrder = 2147483647
cursorsGUI.Name = "Editable Cursor Library"

local cursor = Instance.new("CanvasGroup", cursorsGUI)
cursor.BackgroundTransparency = 1
cursor.AnchorPoint = Vector2.new(0.25, 0.25)
cursor.Size = UDim2.fromOffset(50, 50) -- that gonna be variable + actual size gonna be x2 smaller
cursor.Name = "Cursor Holder"

local cursorDefault = Instance.new("Frame") do
	cursorDefault.BackgroundTransparency = 1
	cursorDefault.AnchorPoint = Vector2.new(0.5, 0.5)
	cursorDefault.Size = UDim2.fromScale(0.5, 0.5)
	cursorDefault.Position = cursorDefault.Size
	cursorDefault.Visible = false
	cursorDefault.Name = "Cursor"

	local baseImage = Instance.new("ImageLabel", cursorDefault)
	baseImage.BackgroundTransparency = 1
	baseImage.AnchorPoint = Vector2.new(0.5, 0.5)
	baseImage.Size = UDim2.fromScale(1, 1)
	baseImage.Position = UDim2.fromScale(0.5, 0.5)
	baseImage.Image = "rbxassetid://" .. base
	baseImage.ZIndex = 0
	baseImage.Name = "Cursor Image"

	local baseInfront = Instance.new("Frame", cursorDefault)
	baseInfront.Size = UDim2.fromScale(1, 1)
	baseInfront.BackgroundTransparency = 1
	baseInfront.ZIndex = 1
	baseInfront.Name = "Infront"

	local baseBehind = baseInfront:Clone()
	baseBehind.Parent = cursorDefault
	baseBehind.ZIndex = -1
	baseBehind.Name = "Behind"
end

local setmetatable = setmetatable
local insert = table.insert
local find = table.find
local remove = table.remove
local rawset = rawset

local c3n = Color3.new
local v2 = Vector2.new
local U2s = UDim2.fromScale
local U2o = UDim2.fromOffset

local rmd = Enum.ResamplerMode.Default
local rmp = Enum.ResamplerMode.Pixelated

local clamp = math.clamp
local max = math.max

local function createEffect(effectName)
	local effectData = EFFECTS[effectName]
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.AnchorPoint = v2(0.5, 0.5)
	image.Image = "rbxassetid://" .. effectData[2]
	image.Name = effectData[3]
	image.ResampleMode = effectData[4] and rmp or rmd
	image.Size = effectData[5]
	image.Position = U2s(0.5, 0.5)

	return image, effectData[6], effectData[7], effectData[3]
end

local defaultEffectOptions = {
	Order = 0,
	Color = c3n(1, 1, 1),
	Transparency = 0,
	Visible = true,

	Destroy = function(self)
		self.Destroyed = true
		self.Effect:Destroy()

		if self.Cursor then
			local cursorEffects = self.Cursor.Effects
			local me = find(cursorEffects, self)
			if me then
				remove(cursorEffects, me)
			end
		end

		return self
	end,

	Refresh = function(self)
		local eff = self.Effect
		local visible = self.Visible
		local trans = clamp(self.Transparency, 0, 1)

		eff.Visible = visible
		if not visible or trans == 1 then return end

		eff.ImageColor3 = self.Color
		eff.ImageTransparency = trans
		eff.ZIndex = self.Order
	end
}

local function newEffect(effectName, options)
	local options = options or { }	
	local effect, putBehind, defaultColor, name = createEffect(effectName)

	if options.Color == nil then
		options.Color = defaultColor or defaultEffectOptions.Color
	end

	for i, v in defaultEffectOptions do
		if options[i] == nil then
			options[i] = v
		end
	end

	options.NameShort = effectName
	options.Name = name
	options.Effect = effect
	options.PutBehind = putBehind
	options.Destroyed = false

	return options
end

local cursorProxyData = { }
local CursorBase = {
	Destroy = function(self)
		local self = cursorProxyData[self]
		if not self then return end

		self.Frame:Destroy()
		self.Active = false
		self.Destroyed = true

		cursorProxyData[self] = nil
	end
}

for i, v in EFFECTS do
	CursorBase[i] = function(self, options)
		local effect = newEffect(i, options)
		if effect.Destroyed then return end

		effect.Effect.Parent = self.Frame[effect.PutBehind and "Behind" or "Infront"]
		effect.Cursor = self

		insert(self.Effects, effect)

		return self
	end
end

local biggestPriority = 0
local maxBit32 = (2 ^ 31) - 1

local activeQueue : { [number]: { } } = { }
local cursorBase = {
	__index = function(self, index)
		local self = cursorProxyData[self]
		if not self then return end

		local ret = CursorBase[index]
		if ret == nil then ret = self[index] end

		return ret
	end,
	__metatable = "Editable Cursor",
	__tostring = "Cursor",
	__newindex = function(self, index, value)
		self = cursorProxyData[self]
		if not self then return end

		local isPriority = index == "Priority"
		local isActive = index == "Active"

		if isActive and self.Destroyed then value = false end
		self[index] = isPriority and clamp(value, -maxBit32, maxBit32) or value

		local myQueue, me
		if isPriority or isActive and not value then
			local old = self._Priority
			self._Priority = isPriority and clamp(value, -maxBit32, maxBit32) or self.Priority

			myQueue = activeQueue[old]
			if myQueue then
				me = find(myQueue, self)
				if me then
					remove(myQueue, me)
				end

				if #myQueue == 0 then
					activeQueue[old] = nil
				end
			end
		end

		if isActive and value then
			local priority = self.Priority

			myQueue = activeQueue[priority] or { }
			activeQueue[priority] = myQueue

			me = find(myQueue, self)
			if me then
				remove(myQueue, me)
			end

			insert(myQueue, 1, self)
		end

		local biggest = -maxBit32 - 1
		for priority in activeQueue do
			biggest = max(biggest, priority)
		end

		if not self.Active then
			self.Frame.Visible = false
		end
	end,
}

local cursors = { }
local cursorLib = {
	new = function(effects)
		local newCursor = cursorDefault:Clone()
		newCursor.Parent = cursor

		local proxy = newproxy(true)
		local meta = getmetatable(proxy)
		local cursorData = {
			Active = false,
			Destroyed = false,

			Transparency = 0,

			Priority = 0,
			_Priority = 0,

			Size = 20, -- in pixels

			Centered = false,
			Effects = effects or { },

			Frame = newCursor,
			Color = c3n(1, 1, 1),

			Image = "",
			Blurry = false
		}

		cursorProxyData[proxy] = cursorData
		for i, v in cursorBase do
			meta[i] = v
		end

		insert(cursors, proxy)

		local effects = proxy.Effects
		for i = #effects, 1, -1 do
			local v = effects[i]
			if not v.Destroyed then
				v.Effect.Parent = newCursor[v.PutBehind and "Behind" or "Infront"]
				v.Cursor = proxy
			else
				remove(effects, i)
			end
		end

		return proxy
	end,
	SetActive = function(self, cursor, active)
		cursor.Active = false

		if active or active == nil then
			cursor.Active = true
		end

		return cursor
	end,

	Effects = { }
}

for i, v in EFFECTS do
	cursorLib[i] = function(self, options)
		return newEffect(i, options)
	end

	cursorLib.Effects[i] = table.freeze({ Order = v[1], Name = v[2], })
end

task.spawn(function() -- HANDLE CURSORS
	local mouse = plr:GetMouse()
	local guiServ = game:GetService("GuiService")
	local uis = game:GetService("UserInputService")

	local windowActive = true
	local mouseActive = true

	uis.WindowFocused:Connect(function()
		windowActive = true
		mouseActive = true
	end)

	uis.WindowFocusReleased:Connect(function()
		windowActive = false
	end)

	local uitmv = Enum.UserInputType.MouseMovement
	uis.InputBegan:Connect(function(inp)
		if inp.UserInputType == uitmv then
			mouseActive = true
		end
	end)

	uis.InputEnded:Connect(function(inp)
		if inp.UserInputType == uitmv then
			mouseActive = false
		end
	end)

	local mblc = Enum.MouseBehavior.LockCenter
	local function refreshCursor()
		cursor.Position = U2o(mouse.X, mouse.Y)

		local queue = activeQueue[biggestPriority]
		if not queue then return false end

		local currentCursor = queue[1]
		if not currentCursor then return false end

		cursor.GroupTransparency = currentCursor.Transparency
		cursor.Size = U2o(currentCursor.Size * 2, currentCursor.Size * 2)

		local isActive = uis.MouseEnabled and mouseActive and windowActive and not guiServ.MenuIsOpen and currentCursor.Active
		local frame = currentCursor.Frame

		frame.Visible = isActive
		frame.AnchorPoint = currentCursor.Centered and v2(1, 1) or v2(0.5, 0.5)

		if not isActive then return false end

		local cursorImage = frame:FindFirstChildOfClass("ImageLabel")
		cursorImage.ImageColor3 = currentCursor.Color

		if currentCursor.Image:gsub("[\n\r\f\t\0 ]", "") ~= "" then
			cursorImage.Image = currentCursor.Image

			for i, v in frame:GetChildren() do
				v.Visible = false
			end

			cursorImage.Visible = true
			cursorImage.ResampleMode = currentCursor.Blurry and rmd or rmp

			return true
		else
			cursorImage.Image = "rbxassetid://" .. base
			cursorImage.ResampleMode = rmd

			for i, v in frame:GetChildren() do
				v.Visible = true
			end
		end

		local effects = currentCursor.Effects
		for i = #effects, 1, -1 do
			local effect = effects[i]
			if not effect.Destroyed then
				effect:Refresh()
			else
				remove(effects, i)
			end
		end

		return true
	end

	local old = uis.MouseIconEnabled

	local set = false
	local set2 = false
	
	local function cycle()
		local success = refreshCursor()
		local targetEnabled = not success and old or success and false

		if not targetEnabled then
			set = false
			
			if not set2 then
				set2 = false
				old = uis.MouseIconEnabled
				uis.MouseIconEnabled = targetEnabled
			end
		else
			set2 = false
			
			if not set then
				set = true
				uis.MouseIconEnabled = old
			end
		end
	end

	game:GetService("RunService").PreRender:Connect(cycle)
	-- while wait(1) do cycle() end
end)

global[key] = cursorLib
table.freeze(cursorLib.Effects)
return table.freeze(cursorLib)
