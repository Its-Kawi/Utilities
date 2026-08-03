local env = getfenv()
local function g(n)
	return env[n]
end

local global = (g("getgenv") or function() return _G end)()
local key = "NFOtherLib"

if global[key] then
	return global[key]
end

local max, min = math.max, math.min
local c3n = Color3.new
local c3h = Color3.fromHSV
local utf8co = utf8.codes
local utf8ch = utf8.char
local abs = math.abs
local clamp = math.clamp

local pack, concat = table.pack, table.concat
local function memoize(fn, skipFirst)
	local cache = setmetatable({ }, { __mode = "k" })

	return function(...)
		local args = pack(...)
		if skipFirst then
			args[1] = ""
		end
		
		local key = args.n ~= 0 and concat(args, "\0") or ""

		local result = cache[key]
		if result then
			return unpack(result, 1, result.n)
		end

		result = pack(fn(...))
		cache[key] = result

		return unpack(result, 1, result.n)
	end
end

local special = memoize(function(i)
	return i:lower() == i and i:upper() == i
end)

local isUpper = memoize(function(v)
	return not special(v) and v:upper() == v
end)

local isLower = memoize(function(v)
	return not special(v) and v:lower() == v
end)

local isNumber = memoize(function(v)
	return v >= '0' and v <= '9'
end)

local defaultRotationPattern = { "G", "B", "R" }
local richReplace = {
	["'"] = "&apos;",
	['"'] = "&quot;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	["&"] = "&amp;"
}

local lib = {
	Smart = function(self, str: string)
		if #str <= 1 then return str end
		
		local chars = self:GetCharacters(str)
		local result: string = chars[1]:upper()
		for i = 2, #chars do
			local v = chars[i]
			local prev = chars[max(i - 1, 1)]
			result ..= ((isUpper(v) and not isUpper(prev) or isUpper(v) and isUpper(prev) and isUpper(chars[max(i - 2, 1)]) and isLower(chars[min(i + 1, #str)])) and " " or "") .. v
		end

		local final = ""
		for i = 1, #result do
			local char = result:sub(i, i)
			local prevChar = i > 1 and result:sub(i - 1, i - 1) or ""

			if isNumber(char) and isLower(prevChar) then
				final = final .. " "
			end

			final ..= char
		end

		return final
	end,
	GetCharacters = memoize(function(self, str)
		local res = { }
		for _, v in utf8co(str) do
			res[#res + 1] = utf8ch(v)
		end

		return res
	end, true),
	RotateColor = function(self, color, pattern)
		pattern = pattern or defaultRotationPattern

		local channels = { R = color.R, G = color.G, B = color.B }
		local result = { }
		for i, channelName in pattern do
			result[channelName] = channels[channelName]
		end

		return c3n(result.R, result.G, result.B)
	end,
	RichPaint = function(self, text, c3)
		return "<font color=\"#" .. (c3n(clamp(c3.R, 0, 1), clamp(c3.G, 0, 1), clamp(c3.B, 0, 1))):ToHex() .. "\">" .. self:RichEscape(text) .. "</font>"
	end,
	RichGradient = function(self, text, c1, c2, offset)
		offset = offset or 0

		local result = ""
		local chars = self:GetCharacters(text)
		local ch = #chars - 1

		for i, v in chars do
			result ..= self:RichPaint(v, c1:Lerp(c2, abs((((i - 1) / ch) + offset) % 2 - 1)))
		end

		return result
	end,
	RGBGradient = function(self, str, offset, speed, saturation, value, mirror)
		return self:RichGradient(str, c3h((abs(offset / (3 - (speed or 2))) + (mirror and 0.2 or 0 )) % 1, saturation or 1, value or 1), c3h((abs(offset / (3 - (speed or 2))) + (mirror and 0 or 0.2 )) % 1, saturation or 1, value or 1))
	end,
	RichEscape = memoize(function(self, str)
		return str:gsub("[&<>'\"%z]", richReplace)
	end, true),
	Memoize = function(self, ...)
		return memoize(...)
	end
}

global[key] = lib
return lib
