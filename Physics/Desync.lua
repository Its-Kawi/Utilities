local env = getfenv()
local function g(n)
	return env[n]
end

local global = (g("getgenv") or function() return _G end)()

if global.DesyncLib then
	return global.DesyncLib
end

local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 78, 117, 108, 108, 45, 67, 104, 101, 114, 114, 121, 47, 85, 116, 105, 108, 105, 116, 105, 101, 115, 47, 114, 101, 102, 115, 47, 104, 101, 97, 100, 115, 47, 109, 97, 105, 110, 47, 85, 116, 105, 108, 105, 116, 121, 47, 77, 97, 105, 110, 46, 108, 117, 97)))() end)()local env = getfenv()
local function g(n)
	return env[n]
end

local request = g("request")
local global = (g("getgenv") or function() return _G end)()

if global.DataLibrary then
	return global.DataLibrary
end

local pcall = pcall
local typeof = typeof
local tonum = tonumber
local spawn = task.spawn
local freeze = table.freeze
local smt = setmetatable
local tick = tick
local find = table.find
local tostring = tostring
local insert = table.insert
local wait = task.wait
local char = string.char
local game = game
local concat = table.concat
local pairs = pairs
local sub = string.sub
local byte = string.byte
local create = table.create
local floor = math.floor

local function gHTTPP(url, body)
	return game:HttpPost(url, body)
end

local function httpPost(url, body)
	if request then
		local result = request({ Url = url, Method = "POST", Body = body, Headers = { } })
		local success = result.Success or tostring(result.StatusCode):sub(1, 1) == "2"
		return success and result.Body or "", success
	else
		local s, e = pcall(gHTTPP, url, body)
		return s and e or "", s
	end
end

local util = (getfenv().getgenv or function() return _G end)().QKUtil or (function() local rf, IF = getfenv().readfile or getfenv().read_file, getfenv().isfile or getfenv().is_file return loadstring(rf and IF and IF("QUtil/Utility.lua") and rf("QUtil/Utility.lua") or game:HttpGet(string.char(104, 116, 116, 112, 115, 58, 47, 47, 114, 97, 119, 46, 103, 105, 116, 104, 117, 98, 117, 115, 101, 114, 99, 111, 110, 116, 101, 110, 116, 46, 99, 111, 109, 47, 78, 117, 108, 108, 45, 67, 104, 101, 114, 114, 121, 47, 85, 116, 105, 108, 105, 116, 105, 101, 115, 47, 114, 101, 102, 115, 47, 104, 101, 97, 100, 115, 47, 109, 97, 105, 110, 47, 85, 116, 105, 108, 105, 116, 121, 47, 77, 97, 105, 110, 46, 108, 117, 97)))() end)()
local newEvent = util:Event()

local hexHi = { }
local hexLo = { }
local hexPairToByte = { }
local hexChars = "0123456789abcdef"
local null = ""

local charCache = { }

for i = 0, 255 do
	local hi, lo = floor(i / 16), i % 16
	hexHi[i] = sub(hexChars, hi + 1, hi + 1)
	hexLo[i] = sub(hexChars, lo + 1, lo + 1)

	hexPairToByte[hexHi[i] .. hexLo[i]] = 255 - i

	local chr = char(i)
	charCache[i] = chr
end

local function weirdHexEncode(str)
	local len = #str
	local result = create(len * 2, null)
	local idx = 0

	for i = len, 1, -1 do
		local b = 255 - byte(str, i)
		idx = idx + 2

		result[idx - 1], result[idx] = hexHi[b], hexLo[b]
	end

	return concat(result, null, 1, idx)
end

local function weirdHexDecode(encodedStr)
	local len = #encodedStr
	local result = create(floor(len / 2), null)
	local idx = 0

	for i = len, 1, -2 do
		idx = idx + 1
		result[idx] = charCache[hexPairToByte[sub(encodedStr, i - 1, i)]]
	end

	return concat(result, null, 1, idx)
end

local url = "https://null-api.onrender.com/channels/"

local ecs = game:GetService("EncodingService")
local http = game:GetService("HttpService")
local userServ = game:GetService("UserService")
local plrs = game:GetService("Players")

local plr = plrs.LocalPlayer

local dataCache = { }
local function getData(id)
	local v = dataCache[id]
	if v then
		return v
	end

	v = userServ:GetUserInfosByUserIdsAsync({ id })[1]
	dataCache[id] = v

	return v
end

local encodePlayer
local sha256 = Enum.HashAlgorithm.Sha256

local hashCache = { }
local function hash256(str)
	local v = hashCache[str]
	if v then
		return v
	end

	v = ecs:ComputeStringHash(str, sha256)
	hashCache[str] = v

	return v
end

function encodePlayer(plr)
	if tonum(plr) then
		local success, data = pcall(getData, plr)
		if not success then
			return encodePlayer(plr)
		end

		plr = {
			UserId = plr,
			Name = data.Username,
			DisplayName = data.DisplayName,
		}
	end

	return weirdHexEncode(hash256((plr.DisplayName:sub(1, 6):reverse() .. plr.DisplayName:sub(7) .. plr.Name:sub(1, 6):reverse() .. plr.Name:sub(7) .. tostring(plr.UserId)):reverse()))
end

local myself = encodePlayer(plr)
local function getPlayer(encoded)
	for i, v in pairs(plrs:GetPlayers()) do
		if encodePlayer(v) == encoded then
			return v
		end
	end
end

local repeatedIds = { }
local warned = false

local channelBase = {
	ChannelName = "Global",
	_Get = function(self)
		if not self.Enabled then return end

		local messages = self:_Send()
		if typeof(messages) ~= "table" then return end

		for i, message in pairs(messages) do
			if typeof(message) == "table" then
				local senderId = message[1]
				local sender, message, sent = getPlayer(senderId), message[2], message[3]
				local s, message = pcall(weirdHexDecode, message)
				local msgId = weirdHexEncode(tostring(sent))

				if s and (not sender or (sender and sender == plr and self.RecieveOwn or sender ~= plr)) then
					if not find(repeatedIds, msgId) then
						insert(repeatedIds, msgId)

						local isRaw = message:sub(1, 1) == "1"
						local msg = message:sub(2)
						local data = { Hash = senderId, Sender = sender, Message = msg, RawMessage = message, Timestamp = sent, MessageId = msgId, IsRaw = isRaw }
						local success, decoded

						if not isRaw then
							success, decoded = pcall(http.JSONDecode, http, msg)
							if not success then -- may be uses OG library?
								msg = message:sub(11)
								success, decoded = pcall(http.JSONDecode, http, msg)
								if success then
									data.Message = msg
								end
							end
						end

						self.OnMessageRaw:Fire(msg, sender, data)

						if success then
							self.OnMessage:Fire(decoded, sender, data)
						end
					end
				end
			end
		end
	end,
	SendAsyncUnsafe = function(self, message, to, isRaw) -- Returns a boolean (success/fail). Unsafe because it can fail when rate limited
		if not self.Enabled or to == plr then return false end

		local msg = message or ""
		return not not self:_Send((isRaw and "1" or "0") .. http:JSONEncode(msg), typeof(to) == "Instance" and to:IsA("Player") and encodePlayer(plr) or true)
	end,
	SendAsync = function(self, ...)
		local _, to = ...
		if not self.Enabled or to == plr then return false end

		while not self:SendAsyncUnsafe(...) and self.Enabled do end
		return self.Enabled
	end,
	Send = function(self, ...)
		spawn(self.SendAsync, self, ...)
	end,
	_Send = function(self, message, to)
		if not self.Enabled then return end

		local isGet = not message
		local res, success = httpPost(url .. self.ChannelName, weirdHexEncode(http:JSONEncode({
			Self = myself,
			To = not isGet and (to or true) or nil,
			Message = not isGet and weirdHexEncode(message) or nil,
			Get = isGet or nil
		})))

		if not success or not self.Enabled then return end 

		local start = 1
		local End = #res

		while res:sub(start, start):gsub("[\r\t\f\n\0 ]", "") == "" do
			start = start + 1
		end

		while res:sub(End, End):gsub("[\r\t\f\n\0 ]", "") == "" do
			End = End - 1
		end

		res = res:sub(start, End)
		if res == "OK" then return true end

		local s, e = pcall(weirdHexDecode, res)
		local e = s and e or nil

		local s, e = pcall(http.JSONDecode, http, e or "false")
		return s and e or nil
	end
}

channelBase = { __index = channelBase }

local cache = { }
local lib

local function newChannel(channelName)
	if cache[channelName or "Global"] then
		return cache[channelName or "Global"]
	end

	local channel = smt({
		ChannelName = channelName,
		Enabled = true,
		Rate = 1, -- once per 1 seconds
		Ping = 1 / 0,
		RecieveOwn = false,

		OnMessage = newEvent(),
		OnMessageRaw = newEvent()
	}, channelBase)

	cache[channelName or "Global"] = channel

	spawn(function()
		local last = 0

		while wait() do
			local t = tick()
			if t - last >= channel.Rate then
				last = t

				channel:_Get()
				channel.Ping = tick() - t
			end
		end
	end)

	return channel
end

lib = freeze({
	new = newChannel,
	ValidatePlayer = function(self, id, hash)
		if not tonum(id) then return end
		if typeof(hash) == "table" then hash = hash.Hash end
		if not hash then return end

		return encodePlayer(id) == hash
	end
})

global.DataLibrary = lib
return lib

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
