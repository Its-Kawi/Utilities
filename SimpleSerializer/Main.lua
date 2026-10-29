local char = string.char
local byte = string.byte

local abs = math.abs
local max = math.max
local floor = math.floor
local clamp = math.clamp
local tonumber = tonumber

local tostring = tostring
local typeof = typeof
local c3r = Color3.fromRGB

local concat = table.concat
local insert = table.insert
local unpack = unpack or table.unpack
local find = table.find

local setmetatable = setmetatable
local getmetatable = getmetatable

local info = debug.info

local buffer_create = buffer.create
local buffer_tostring = buffer.tostring
local buffer_fromstring = buffer.fromstring
local buffer_readu8 = buffer.readu8
local buffer_writeu8 = buffer.writeu8
local buffer_readstring = buffer.readstring

local error = error

local game = game

local cstu = Enum.ContentSourceType.Uri

local content_none = Content.none
local content_fromUri = Content.fromUri

local maxBit64 = (2 ^ (64 - 1)) - 1

local INF = 1 / 0
local nINF = -INF
local NaN = 0 / 0
local small = 1e-16

local cyclicError = "tables cannot be cyclic."
local charError = "Invalid character: "
local typeError = "Invalid Data argument: string or buffer expected"
local malformedDataError = "Unable to deserialize data: Malformed data."
local unknownWarning = "Unknown function"

local types = {
	--== String ==--
	String = "\255",
	TextEnd = "\254",
	Buffer = "\253",
	EmptyString = "\1",
	SingleString = "\2",
	DoubleString = "\3",

	--== Number ==--
	SmallInteger = "\4",
	MediumInteger = "\5",
	LargeInteger = "\6",
	Integer = "\7",
	Float = "\8",
	Big = "\9",
	Infinite = "\10",
	NegativeSmallInteger = "\11",
	NegativeMediumInteger = "\12",
	NegativeLargeInteger = "\13",
	NegativeInteger = "\14",
	NegativeFloat = "\15",
	NegativeBig = "\16",
	NegativeInfinite = "\17",
	NotANumber = "\18",

	--== Boolean ==--
	BooleanTrue = "\19",
	BooleanFalse = "\20",

	--== Nil ==--
	None = "\21",

	--== Table ==--
	List = "\22",
	Dictionary = "\23",
	Empty = "\24",
	TableEnd = "\25",
	TableReference = "\26",

	--== Table|Custom ==--
	Custom = "\27",
	Color3 = "\28",
	Function = "\29",
	Content = "\30",
	Instance = "\31"
}

local numStart = 32
local numEnd = 252
local numRange = numEnd - numStart
local rangeHalf = floor(numRange / 2)
for i = numStart, numEnd do
	types[(i - numStart) - rangeHalf] = char(i)
end

local function packLength(n1, n2)
	return n1 * 16 + n2
end

local function unpackLength(n)
	return floor(n / 16), n % 16
end

local function index(a, b)
	return a[b]
end

local function base256encode(num)
	local count = 0
	local n = num

	while n > 0 do
		count += 1
		n = floor(n / 256)
	end

	local buf = buffer_create(count)
	for i = 0, count - 1 do
		buffer_writeu8(buf, i, num % 256)
		num = floor(num / 256)
	end

	return buffer_tostring(buf)
end

local function base256decode(encodedStr)
	local num = 0
	local shift = 0

	for i = 1, #encodedStr do
		num += byte(encodedStr, i) * (256 ^ shift)
		shift += 1
	end

	return num
end

local ESC = types.String
local TEXT_END = types.TextEnd
local function escapeString(str)
	return (str:gsub("([" .. ESC .. TEXT_END .. "])", ESC .. "%1"))
end

local function getTableType(tbl)
	local count = 0

	for key in tbl do
		if typeof(key) ~= "number"
			or key < 1
			or key % 1 ~= 0 then
			return 2
		end

		count += 1
	end

	for i = 1, count do
		if tbl[i] == nil then
			return 2
		end
	end

	return count == 0 and 0 or 1
end

local sizes = { "Small", "Medium", "Large" }
local maxSize = #sizes

local env = getfenv()
local possibleTables = {
	--== Roblox LuaU ==--
	"WebViewParams", "Random", "Ray", "Rect", "Region3",
	"Region3int16", "RaycastParams", "RotationCurveKey",
	"task", "table", "TweenInfo", "UDim2", "UDim", "utf8",
	"User", "Instance", "InstanceHandle", "OverlapParams",
	"os", "PhysicalProperties", "PathWaypoint", "Path2DControlPoint",
	"Axes", "string", "SecurityCapabilities", "Secret", --[["shared", ]]
	"debug", "DateTime", "DockWidgetPluginGuiInfo", "Font", "File",
	"FloatCurveKey", "Faces", "Color3", "CFrame", "Content",
	"ColorSequence", "coroutine", "CatalogSearchParams",
	"ColorSequenceKeypoint", "Vector2", "vector", "Vector3",
	"Vector2int16", "Vector3int16", "ValueCurveKey",
	"buffer", "bit32", "bit", "BrickColor", "NumberRange",
	"NumberSequence", "NumberSequenceKeypoint", "math",
	--[["_G", ]]
	
	--== Exploit LuaU ==--
	"cache", "crypt", "Drawing", "DrawingImmediate", "oth",
	"raknet", "Regex", "WebSocket",
	
	"syn"
}

local tableByName = { }
for _, v in possibleTables do
	tableByName[v] = env[v]
end

local definedTables = {
	[_G] = "\4",
	[shared] = "\1",
	[getfenv()] = "\2",
	[(getfenv().getgenv or function() return {} end)()] = "\3"
}

for i = 1, #possibleTables do
	local tbl = env[possibleTables[i]]
	if tbl then
		definedTables[tbl] = char(i + 5)
	end
end

local definedTablesReverse = { }

for key, val in definedTables do
	definedTablesReverse[val] = key
end

local function clone(a)
	local b = { }
	for i, v in a do
		b[i] = v
	end
	
	return b
end

local tableScan; tableScan = function(target, tbl, route, visited)
	if typeof(tbl) ~= "table" or find(visited, tbl) then
		return nil
	end

	insert(visited, tbl)
	route = clone(route)

	for k, v in tbl do
		if v == target then
			insert(route, k)
			return route
		elseif typeof(v) == "table" then
			local r = clone(route)
			insert(r, k)

			local result = tableScan(target, v, r, visited)
			if result then
				return result
			end
		end
	end

	return nil
end

local encoders = {
	string = function(self, str)
		if str == "" then
			return types.EmptyString
		elseif #str == 1 then
			return types.SingleString .. str
		elseif #str == 2 then
			return types.DoubleString .. str
		end
		
		return types.String .. escapeString(str) .. types.TextEnd
	end,
	number = function(self, num)
		if num ~= num then
			return types.NotANumber
		end

		if num == INF then
			return types.Infinite
		end

		if num == nINF then
			return types.NegativeInfinite
		end

		local tn = types[num]
		if tn then
			return tn
		end

		local absNum = abs(num)
		local isNegative = num ~= absNum
		local isInt = num % 1 == 0
		if isInt then
			local n = base256encode(absNum)
			local nl = #n
			
			if nl <= maxSize then
				return types[(isNegative and "Negative" or "") .. sizes[nl] .. "Integer"] .. n
			elseif absNum < maxBit64 then
				return (isNegative and types.NegativeInteger or types.Integer) .. base256encode(nl) .. n
			else
				local zeros = -1
				local current = absNum

				while current > 1 do
					zeros += 1
					current /= 10
				end

				if zeros > 255 then
					return (isNegative and types.NegativeInfinite or types.Infinite)
				end

				local s = tostring(absNum):sub(1, 2)
				if not tonumber(s:sub(-1)) then
					s = s:sub(1, 1)
				end

				return (isNegative and types.NegativeBig or types.Big) .. base256encode(tonumber(s)) .. base256encode(max(zeros, 0))
			end
		else
			if absNum < small then
				return types[0]
			elseif absNum < maxBit64 then
				local str = tostring(absNum)
				if not str:find(".", 0, true) then
					local x, y = str:match("(%d+)[eE]%-?(%d+)")
					str = "0." .. ("0"):rep(tonumber(y) - #x) .. x
				end

				local spl = str:split(".")

				local n1 = base256encode(tonumber(spl[1]))
				local n2 = base256encode(tonumber(spl[2]:reverse()))
				
				return (isNegative and types.NegativeFloat or types.Float) .. char(packLength(#n1, #n2)) .. n1 .. n2
			else
				return self:number(floor(num))
			end
		end
	end,
	boolean = function(self, bool)
		return bool and types.BooleanTrue or types.BooleanFalse
	end,
	["nil"] = function(self, _)
		return types.None
	end,

	table = function(self, tbl, custom, globalSearch)
		if globalSearch then
			local d = definedTables[tbl]
			if not d and getmetatable(tbl) == "The metatable is locked" and tbl.error == error then
				return types.TableReference .. "\2"
			end
			
			if d then
				return types.TableReference .. d
			end
			
			local fn = self["function"](self, tbl)
			if fn ~= types.None then
				return fn
			end
		end
		
		local tblType = custom and 1 or getTableType(tbl)
		if tblType == 0 then
			return types.Empty
		end

		local chunks = { }
		if custom then
			insert(chunks, custom)
		elseif tblType == 1 then
			insert(chunks, types.List)
		else
			insert(chunks, types.Dictionary)
		end

		if tblType == 1 then
			for i = 1, #tbl do
				insert(chunks, self:encode(tbl[i]))
			end
		else
			for key, value in tbl do
				insert(chunks, self:encode(key))
				insert(chunks, self:encode(value))
			end
		end

		insert(chunks, types.TableEnd)
		return concat(chunks)
	end,
	buffer = function(self, buf)
		return types.Buffer .. escapeString(buffer_tostring(buf)) .. types.TextEnd
	end,
	
	Color3 = function(self, c3)
		return types.Color3 .. char(clamp(floor(c3.R * 255 + 0.5), 0, 255), clamp(floor(c3.G * 255 + 0.5), 0, 255), clamp(floor(c3.B * 255 + 0.5), 0, 255))
	end,
	["function"] = function(self, fn)
		if typeof(fn) == "function" then
			local fnn = info(fn, "n")
			if env[fnn] == fn then
				return self:table({ fnn }, types.Function, false)
			end
		end
		
		local visited = { }
		for tblN, tbl in tableByName do
			if typeof(tbl) == "table" then
				local foundRoute = tableScan(fn, tbl, {tblN}, visited)

				if foundRoute then
					return self:table(foundRoute, types.Function, false)
				end
			end
		end

		for tblN, tbl in definedTablesReverse["\3"] do
			if typeof(tbl) == "table" then
				local foundRoute = tableScan(fn, tbl, { tblN }, visited)
				
				if foundRoute then
					return self:table(foundRoute, types.Function, false)
				end
			end
		end
		
		return types.None
	end,
	Instance = function(self, instance)
		if instance == game then
			return types.Instance
		elseif not instance:IsDescendantOf(game) then
			return types.None
		end

		local path = { }
		local current = instance

		while current ~= game do
			local next = current.Parent
			local isService = false

			if next == game then
				local s, serv = pcall(game.GetService, game, current.ClassName)
				if serv == current then
					isService = true
				end
			end

			insert(path, 1, isService and current.ClassName or current.Name)
			current = next
		end

		return self:table(path, types.Instance, false)
	end,
	Content = function(self, content)
		if content.SourceType == cstu then
			return types.Content .. base256encode(2) .. self:encode(content.Uri)
		end
		
		return types.Content .. base256encode(1)
	end,

	encode = function(self, val)
		return (self[typeof(val)] or self["nil"])(self, val, nil, true)
	end,
	
	--== CUSTOM ==--

	CFrame = function(self, cframe)
		return self:table({ "\0", cframe:GetComponents() }, types.Custom, false)
	end,
	Vector2 = function(self, v2)
		return self:table({ "\1", v2.X, v2.Y }, types.Custom, false)
	end,
	Vector3 = function(self, v3)
		return self:table({ "\2", v3.X, v3.Y, v3.Z }, types.Custom, false)
	end,
	UDim2 = function(self, udim2)
		return self:table({ "\3", udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset }, types.Custom, false)
	end,
	UDim = function(self, udim)
		return self:table({ "\4", udim.Scale, udim.Offset }, types.Custom, false)
	end,
	ColorSequence = function(self, sequence)
		return self:table({ "\5", unpack(sequence.Keypoints) }, types.Custom, false)
	end,
	ColorSequenceKeypoint = function(self, sequence)
		return self:table({ "\6", sequence.Time, sequence.Value }, types.Custom, false)
	end,
	Vector3int16 = function(self, v3)
		return self:table({ "\7", v3.X, v3.Y, v3.Z }, types.Custom, false)
	end,
	Vector2int16 = function(self, v2)
		return self:table({ "\8", v2.X, v2.Y }, types.Custom, false)
	end,
	Enums = function(self, enums)
		return self:table({ "Enum" }, types.Function, false)
	end,
	Enum = function(self, enum)
		return self:table({ "Enum", tostring(enum) }, types.Function, false)
	end,
	EnumItem = function(self, enumItem)
		return self:table({ "Enum", tostring(enumItem.EnumType), enumItem.Name }, types.Function, false)
	end
}

local customDescriptors = {
	["\0"] = CFrame.new,
	["\1"] = Vector2.new,
	["\2"] = Vector3.new,
	["\3"] = UDim2.new,
	["\4"] = UDim.new,
	["\5"] = ColorSequence.new,
	["\6"] = ColorSequenceKeypoint.new,
	["\7"] = Vector3int16.new,
	["\8"] = Vector2int16.new,
}

local DataStream do
	local DSF = {}
	DSF.__index = DSF

	DataStream = {
		new = function(data)
			if typeof(data) == "string" then
				data = buffer_fromstring(data)
			elseif typeof(data) ~= "buffer" then
				error("DataStream expects a string or buffer", 2)
			end

			return setmetatable({
				buffer = data,
				cursor = 0
			}, DSF)
		end
	}

	function DSF:move(t)
		self.cursor += t or 1
	end

	function DSF:readByte()
		return buffer_readu8(self.buffer, self.cursor), self:move()
	end

	function DSF:readChar()
		return char((self:readByte()))
	end

	function DSF:readChars(amount)
		return buffer_readstring(self.buffer, self.cursor, amount), self:move(amount)
	end
end

local textEnd = types.TextEnd
local tableEnd = types.TableEnd

local decoders; decoders = {
	[types.EmptyString] = function(self, stream)
		return ""
	end,
	[types.SingleString] = function(self, stream)
		return stream:readChars(1)
	end,
	[types.DoubleString] = function(self, stream)
		return stream:readChars(2)
	end,
	[types.String] = function(self, stream)
		local str = { }
		local isEscape = false

		while true do
			local char = stream:readChar()
			if char == ESC then
				if isEscape then
					insert(str, char)
					isEscape = false
				else
					isEscape = true
				end
			elseif isEscape then
				insert(str, char)
				isEscape = false
			else
				if char == textEnd then
					break
				end
				
				insert(str, char)
			end
		end

		return concat(str, "")
	end,
	[types.Buffer] = function(self, stream)
		return buffer_fromstring(self[types.String](self, stream))
	end,
	
	[types.SmallInteger] = function(self, stream)
		return stream:readByte()
	end,
	[types.Integer] = function(self, stream)
		return base256decode(stream:readChars(stream:readByte()))
	end,
	[types.NegativeSmallInteger] = function(self, stream)
		return -stream:readByte()
	end,
	[types.NegativeInteger] = function(self, stream)
		return -base256decode(stream:readChars(stream:readByte()))
	end,
	[types.Float] = function(self, stream)
		local ln1, ln2 = unpackLength(stream:readByte())
		local ch1 = base256decode(stream:readChars(ln1))
		return tonumber(ch1 .. "." .. tostring(base256decode(stream:readChars(ln2))):reverse())
	end,
	[types.NegativeFloat] = function(self, stream)
		return -self[types.Float](self, stream)
	end,
	[types.Big] = function(self, stream)
		return tonumber(base256decode(stream:readChar()) .. "e" .. base256decode(stream:readChar()))
	end,
	[types.NegativeBig] = function(self, stream)
		return -tonumber(base256decode(stream:readChar()) .. "e" .. base256decode(stream:readChar()))
	end,
	[types.Infinite] = function(self, stream)
		return INF
	end,
	[types.NegativeInfinite] = function(self, stream)
		return nINF
	end,
	[types.NotANumber] = function(self, stream)
		return NaN
	end,
	
	[types.BooleanTrue] = function(self, stream)
		return true
	end,
	[types.BooleanFalse] = function(self, stream)
		return false
	end,
	
	[types.None] = function(self, stream)
		return nil
	end,

	[types.List] = function(self, stream)
		local list = { }
		while true do
			local got, isEnd = self:readNext(stream)
			if isEnd then
				return list
			end

			insert(list, got)
		end
	end,
	[types.Dictionary] = function(self, stream)
		local dict = { }
		while true do
			local key, isEnd = self:readNext(stream)
			if isEnd then return dict end
			
			local value, isEnd = self:readNext(stream)
			if isEnd then return dict end
			
			dict[key] = value
		end
	end,
	[types.Empty] = function(self, stream)
		return { }
	end,
	[types.TableReference] = function(self, stream)
		return definedTablesReverse[stream:readChar()] or { }
	end,
	
	[types.Custom] = function(self, stream)
		local list = self[types.List](self, stream)
		return customDescriptors[list[1]](unpack(list, 2))
	end,
	
	[types.Color3] = function(self, stream)
		return c3r((stream:readByte()), (stream:readByte()), (stream:readByte()))
	end,

	[types.Function] = function(self, stream)
		local route = self[types.List](self, stream)
		local current = env
		local routeEnd = #route

		for i = 1, routeEnd do
			local v = route[i]
			local s, c = pcall(index, current, route[i])
			if s then
				current = current[route[i]]

				if not current then
					return nil
				end
			else
				return nil
			end
		end

		return current
	end,
	[types.Instance] = function(self, stream)
		local s, nextChar = pcall(stream.readChar, stream)
		if s then
			stream:move(-1)
		else
			nextChar = ""
		end
		
		if nextChar == types.String then
			local route = self[types.List](self, stream)
			local current = game
			
			for i = 1, #route do
				local v = route[i]
				if i == 1 then
					local s, serv = pcall(current.GetService, current, v)
					if not s then
						serv = current:FindFirstChild(v)
					end
					
					if not serv then
						return nil
					end
					
					current = serv
				else
					current = current:FindFirstChild(v)
					
					if not current then
						return nil
					end
				end
			end
			
			return current
		else
			return game
		end
	end,
	[types.Content] = function(self, stream)
		local type = stream:readByte()
		if type == 1 then
			return content_none
		else
			return content_fromUri(self:readNext(stream))
		end
	end,
	
	readNext = function(self, stream)
		local char = stream:readChar()
		local decoder = decoders[char]
		if typeof(decoder) == "function" then
			return (decoder(self, stream))
		else
			if char == tableEnd then
				return nil, true
			end
			
			error(charError .. char)
		end
	end
}

for i = numStart, numEnd do
	decoders[char(i)] = function(self, stream)
		return (i - numStart) - rangeHalf
	end
end

for i, v in sizes do
	decoders[types["Negative" .. v .. "Integer"]] = function(self, stream)
		return -base256decode(stream:readChars(i))
	end
	
	decoders[types[v .. "Integer"]] = function(self, stream)
		return base256decode(stream:readChars(i))
	end
end

return {
	serialize = function(data)
		local s, e = pcall(encoders.encode, encoders, data, { })
		if not s then error(e:match("overflow") and cyclicError or e, 0) end
		
		return e
	end,
	deserialize = function(data)
		if typeof(data) ~= "string" and typeof(data) ~= "buffer" then error(typeError, 0) end
		
		local stream = DataStream.new(data)
		local s, e = pcall(decoders.readNext, decoders, stream)
		if not s or pcall(decoders.readNext, decoders, stream) then error(malformedDataError, 0) end

		return e
	end
}
