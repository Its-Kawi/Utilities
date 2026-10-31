local env = getfenv()
local function g(n)
	return env[n]
end

local global = (g("getgenv") or function() return _G end)()
local n = "EventLib1"

if global[n] then
	return global[n]
end

local pack = table.pack
local error = error
local spawn = task.spawn
local freeze = table.freeze
local smt = setmetatable
local insert = table.insert
local remove = table.remove
local rawset = rawset
local unpack = table.unpack
local defer = task.defer
local delay = task.delay

local quick = Instance.new("BindableEvent") -- only for instant :Wait response
local quickEvent = quick.Event

local connectionBase = {
	Disconnect = function(self)
		if self.Connected then
			rawset(self, "Connected", false)
			freeze(self)

			rawset(self.Parent, "_Dirty", true)
		end
	end,
	Fire = function(self, ...)
		if not self.Enabled or not self.Connected or not self.Parent.Enabled then return end
		spawn(self.Callback, ...)
	end
}

connectionBase = { __index = connectionBase, __tostring = function() return "Connection" end, __newindex = function(self, key, value) if key ~= "Enabled" then error() end rawset(self, key, value) end }
local eventBase = {
	Connect = function(self, func)
		local connection = smt({ Callback = func, Connected = true, Enabled = true, Parent = self }, connectionBase)
		insert(self._Connections, connection)

		return connection
	end,
	Once = function(self, func)
		local con; con = self:Connect(function(...)
			con:Disconnect()
			con = nil

			func(...)
		end)

		return con
	end,
	Wait = function(self)
		local result
		self:Once(function(...)
			result = pack(...)
			quick:Fire()
		end)

		repeat quickEvent:Wait() until result
		return unpack(result, 1, result.n)
	end,
	Cleanup = function(self)
		if not self._Dirty then
			return
		end

		local cons = self._Connections
		local write = 1

		for read = 1, #cons do
			local connection = cons[read]

			if connection and connection.Connected then
				cons[write] = connection
				write += 1
			end
		end

		for i = write, #cons do
			cons[i] = nil
		end

		rawset(self, "_Dirty", false)
	end,

	Fire = function(self, ...)
		self:Cleanup()

		local cons = self._Connections
		for i = 1, #cons do
			if cons[i] then
				cons[i]:Fire(...)
			end
		end
	end,
	DisconnectAll = function(self)
		for _, v in self._Connections do
			v:Disconnect()
		end

		self:Cleanup()
	end
}

eventBase = { __index = eventBase, __tostring = function() return "Event" end, __newindex = function(self, key, value) if key ~= "Enabled" then error() end rawset(self, key, value) end }
local lib = setmetatable({
	new = function()
		return smt({
			_Connections = {},
			_Dirty = false,
			Enabled = true
		}, eventBase)
	end,
	RaceEvents = function(self, ...)
		local events = { ... }
		if typeof(events[1]) == "table" then
			events = events[1]
		end

		if #events == 0 then return end
		if #events == 1 then return events[1]:Wait() end

		local result, winner
		local connections = { }

		for i, v in events do
			connections[#connections + 1] = v:Once(function(...)
				for i, v in connections do
					v:Disconnect()
				end

				winner = i
				result = pack(...)
				quick:Fire()
			end)
		end

		repeat quickEvent:Wait() until result

		insert(result, 1, winner)
		return unpack(result, 1, result.n + 1)
	end,
	RaceEventsWithTimeout = function(self, events, timeout)
		local timeoutEvent = self.new()
		events[#events + 1] = timeoutEvent

		delay(timeout, timeoutEvent.Fire, timeoutEvent)

		local racing = pack(self:RaceEvents(events))
		local winner = remove(racing, 1)
		racing.n -= 1

		return winner ~= #events, racing
	end
}, freeze({ __call = function(self, ...) return self.new(...) end }))
global[n] = lib

local clock, fakeClock, deferClock = lib.new(), lib.new(), lib.new()
local race = lib.RaceEvents
local rs = game:GetService("RunService")
local r1, r2, r3 = rs.RenderStepped, rs.Heartbeat, rs.Stepped
local last = tick()
local fire = clock.Fire
local maxDefer = 2

clock:Connect(function(isDefer, dontFire)
	local current = tick()
	fakeClock:Fire(current - last, isDefer)
	last = current

	if dontFire then return end

	race(clock, r1, r2, r3)
	fire(clock, false, false)
	delay(0, fire, clock, false, true)

	for i = 1, maxDefer do
		defer(fire, deferClock)
		deferClock:Wait()

		if i <= 3 or i == 10 or i == maxDefer then
			fire(clock, true, true)
		end
	end
end)

rawset(lib, "Clock", fakeClock)
freeze(lib)
fire(clock, false)

return lib
