local char = string.char
local byte = string.byte

local abs = math.abs
local max = math.max
local floor = math.floor
local clamp = math.clamp
local tonumber = tonumber

local tostring = tostring
local error = error
local typeof = typeof
local c3r = Color3.fromRGB

local concat = table.concat
local find = table.find
local insert = table.insert
local unpack = unpack or table.unpack
local pack = table.pack
local create = table.create

local setmetatable = setmetatable

local buffer_create = buffer.create
local buffer_tostring = buffer.tostring
local buffer_fromstring = buffer.fromstring
local buffer_readu8 = buffer.readu8
local buffer_writeu8 = buffer.writeu8
local buffer_readstring = buffer.readstring

local maxBit32 = (2 ^ (32 - 1)) - 1
local maxBit64 = (2 ^ (64 - 1)) - 1

local INF = 1 / 0
local nINF = -INF
local NaN = 0 / 0
local small = 1e-16

local cyclicError = "tables cannot be cyclic."
local charError = "Invalid character: "
local typeError = "Invalid Data argument: string or buffer expected"
local malformedDataError = "Unable to deserialize data: Malformed data."

local types = {
	--== String ==--
	String = "\255",
	TextEnd = "\254",
	Buffer = "\253",

	--== Number ==--
	Integer = "\1",
	Float = "\2",
	Big = "\3",
	Infinite = "\4",
	NegativeInteger = "\5",
	NegativeFloat = "\6",
	NegativeBig = "\7",
	NegativeInfinite = "\8",
	NotANumber = "\9",
	Zero = "\10",

	--== Boolean ==--
	BooleanTrue = "\11",
	BooleanFalse = "\12",

	--== Nil ==--
	None = "\13",

	--== Table ==--
	List = "\14",
	Dictionary = "\15",
	Empty = "\16",
	TableEnd = "\17",

	--== Table|Custom ==--
	Custom = "\18",
	Color3 = "\19"
}

local function packLength(n1, n2)
	return (n1 - 1) * 16 + (n2 - 1)
end

local function unpackLength(n)
	return n / 16 + 1, n % 16 + 1
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

local ESC = "\255"
local TEXT_END = "\254"

local function escapeString(str)
	return (str:gsub("([\255\254])", ESC .. "%1"))
end

local function unescapeString(str)
	return (str:gsub("\255([\255\254])", "%1"))
end

local function getTableType(tbl)
	local hasAnything = false

	local next = 1
	for key in tbl do
		hasAnything = true

		if key ~= next then
			return 2
		end

		next += 1
	end

	return hasAnything and 1 or 0
end

local encoders = {
	string = function(self, str)
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

		local absNum = abs(num)
		local isNegative = num ~= absNum

		if absNum == 0 then
			return types.Zero
		end

		local isInt = num % 1 == 0
		if isInt then
			if absNum < maxBit64 then
				local n = base256encode(absNum)
				return (isNegative and types.NegativeInteger or types.Integer) .. base256encode(#n) .. n
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
				return types.Zero
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

	table = function(self, tbl, isCustom)
		local tblType = isCustom and 1 or getTableType(tbl)
		if tblType == 0 then
			return types.Empty
		end

		local chunks = {}

		if isCustom then
			insert(chunks, types.Custom)
		elseif tblType == 1 then
			insert(chunks, types.List)
		else
			insert(chunks, types.Dictionary)
		end

		if tblType == 1 then
			for _, value in tbl do
				insert(chunks, self:encode(value))
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
		return types.Color3 .. base256encode(clamp(floor(c3.R * 255), 0, 255)) .. base256encode(clamp(floor(c3.G * 255), 0, 255)) .. base256encode(clamp(floor(c3.B * 255), 0, 255))
	end,

	encode = function(self, val)
		return (self[typeof(val)] or self["nil"])(self, val)
	end,
	
	--== CUSTOM ==--

	CFrame = function(self, cframe)
		return self:table({ "\0", cframe:GetComponents() }, true)
	end,
	Vector2 = function(self, v2)
		return self:table({ "\1", v2.X, v2.Y }, true)
	end,
	Vector3 = function(self, v3)
		return self:table({ "\2", v3.X, v3.Y, v3.Z }, true)
	end,
	UDim2 = function(self, udim2)
		return self:table({ "\3", udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset }, true)
	end,
	UDim = function(self, udim)
		return self:table({ "\4", udim.Scale, udim.Offset }, true)
	end,
	ColorSequence = function(self, sequence)
		return self:table({ "\5", unpack(sequence.Keypoints) }, true)
	end,
	ColorSequenceKeypoint = function(self, sequence)
		return self:table({ "\6", sequence.Time, sequence.Value }, true)
	end,
	Vector3int16 = function(self, v3)
		return self:table({ "\7", v3.X, v3.Y, v3.Z }, true)
	end,
	Vector2int16 = function(self, v2)
		return self:table({ "\8", v2.X, v2.Y }, true)
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
	["\8"] = Vector2int16.new
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
		return char(self:readByte())
	end

	function DSF:readBytes(amount)
		local bytes = create(amount)
		local buffer = self.buffer
		local cursor = self.cursor

		for i = 1, amount do
			bytes[i] = buffer_readu8(buffer, cursor + i - 1)
		end
		
		return bytes, self:move(amount)
	end

	function DSF:readChars(amount)
		return buffer_readstring(self.buffer, self.cursor, amount), self:move(amount)
	end
end

local textEnd = types.TextEnd
local tableEnd = types.TableEnd

local decoders; decoders = {
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

	[types.Integer] = function(self, stream)
		return base256decode(stream:readChars(stream:readByte()))
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
	[types.Zero] = function(self, stream)
		return 0
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
	
	[types.Custom] = function(self, stream)
		local list = self[types.List](self, stream)
		return customDescriptors[list[1]](unpack(list, 2))
	end,
	[types.Color3] = function(self, stream)
		return c3r(stream:readByte(), stream:readByte(), stream:readByte())
	end,
	
	readNext = function(self, stream)
		local char = stream:readChar()
		local decoder = decoders[char]
		if decoder then
			return (decoder(self, stream))
		else
			if char == tableEnd then
				return nil, true
			end
			
			error(charError .. char)
		end
	end
}

return {
	serialize = function(data)
		local s, e = pcall(encoders.encode, encoders, data, { })
		if not s then error(e:match("overflow") and cyclicError or e, 0) end
		
		return e
	end,
	deserialize = function(data)
		if typeof(data) ~= "string" then error(typeError, 0) end
		
		local s, e = pcall(decoders.readNext, decoders, DataStream.new(data))
		if not s then error(malformedDataError, 0) end

		return e
	end
}
