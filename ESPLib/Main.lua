-- [[ GENERATED WITH InfernoHub/Scriptify STUDIO PLUGIN ]] --
-- Scriptify Version: 1.4

--

-- Create objects
local parent = nil;
local objects = {
    ["Instance0"] = Instance.new("ModuleScript");
    ["Instance1"] = Instance.new("ModuleScript");
    ["Instance2"] = Instance.new("BillboardGui");
    ["Instance3"] = Instance.new("Frame");
    ["Instance4"] = Instance.new("UICorner");
    ["Instance5"] = Instance.new("UIStroke");
    ["Instance6"] = Instance.new("UIGradient");
    ["Instance7"] = Instance.new("TextLabel");
    ["Instance8"] = Instance.new("UIStroke");
    ["Instance9"] = Instance.new("Highlight");
    ["Instance10"] = Instance.new("TextLabel");
    ["Instance11"] = Instance.new("UIStroke");
};

do -- Set properties
    objects["Instance0"]["Parent"] = parent;
    objects["Instance0"]["Name"] = "ESPLib";

    objects["Instance1"]["Parent"] = objects["Instance0"];
    objects["Instance1"]["Name"] = "Event";

    objects["Instance2"]["LightInfluence"] = 1;
    objects["Instance2"]["Name"] = "ESPObject";
    objects["Instance2"]["Active"] = true;
    objects["Instance2"]["Parent"] = objects["Instance0"];
    objects["Instance2"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
    objects["Instance2"]["AlwaysOnTop"] = true;
    objects["Instance2"]["Size"] = UDim2.new(0, 20, 0, 20);

    objects["Instance3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
    objects["Instance3"]["BorderColor3"] = Color3.new(0, 0, 0);
    objects["Instance3"]["Name"] = "Circle";
    objects["Instance3"]["Position"] = UDim2.new(0.5, 0, 0.5, 2);
    objects["Instance3"]["Parent"] = objects["Instance2"];
    objects["Instance3"]["Size"] = UDim2.new(1, -8, 1, -8);
    objects["Instance3"]["BorderSizePixel"] = 0;
    objects["Instance3"]["BackgroundColor3"] = Color3.new(1, 1, 1);

    objects["Instance4"]["Parent"] = objects["Instance3"];

    objects["Instance5"]["Thickness"] = 2;
    objects["Instance5"]["Parent"] = objects["Instance3"];

    objects["Instance6"]["Rotation"] = 90;
    objects["Instance6"]["Parent"] = objects["Instance3"];
    objects["Instance6"]["Color"] = ColorSequence.new({
    [1] = ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    [2] = ColorSequenceKeypoint.new(1, Color3.new(0.686275, 0.686275, 0.686275))
});

    objects["Instance7"]["FontSize"] = Enum.FontSize.Size14;
    objects["Instance7"]["Parent"] = objects["Instance2"];
    objects["Instance7"]["AnchorPoint"] = Vector2.new(0.5, 0);
    objects["Instance7"]["BorderSizePixel"] = 0;
    objects["Instance7"]["Size"] = UDim2.new(0, 10000, 0, 10000);
    objects["Instance7"]["RichText"] = true;
    objects["Instance7"]["TextColor3"] = Color3.new(1, 1, 1);
    objects["Instance7"]["BorderColor3"] = Color3.new(0, 0, 0);
    objects["Instance7"]["Text"] = "Point zero";
    objects["Instance7"]["TextWrap"] = true;
    objects["Instance7"]["TextWrapped"] = true;
    objects["Instance7"]["BackgroundTransparency"] = 1;
    objects["Instance7"]["Position"] = UDim2.new(0.5, 0, 1, -1);
    objects["Instance7"]["TextSize"] = 14;
    objects["Instance7"]["TextYAlignment"] = Enum.TextYAlignment.Top;
    objects["Instance7"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal, true);
    objects["Instance7"]["BackgroundColor3"] = Color3.new(1, 1, 1);

    objects["Instance8"]["Thickness"] = 2;
    objects["Instance8"]["Parent"] = objects["Instance7"];

    objects["Instance9"]["Parent"] = objects["Instance2"];
    objects["Instance9"]["FillColor"] = Color3.new(1, 1, 1);
    objects["Instance9"]["FillTransparency"] = 0.75;
    objects["Instance9"]["Enabled"] = false;

    objects["Instance10"]["FontSize"] = Enum.FontSize.Size12;
    objects["Instance10"]["Parent"] = objects["Instance2"];
    objects["Instance10"]["AnchorPoint"] = Vector2.new(0.5, 1);
    objects["Instance10"]["BorderSizePixel"] = 0;
    objects["Instance10"]["Size"] = UDim2.new(0, 10000, 0, 10000);
    objects["Instance10"]["RichText"] = true;
    objects["Instance10"]["TextColor3"] = Color3.new(1, 1, 1);
    objects["Instance10"]["BorderColor3"] = Color3.new(0, 0, 0);
    objects["Instance10"]["Text"] = "<font transparency=\"0.25\">World's 0, 0, 0 point</font>";
    objects["Instance10"]["TextWrap"] = true;
    objects["Instance10"]["Name"] = "TopTextLabel";
    objects["Instance10"]["TextWrapped"] = true;
    objects["Instance10"]["BackgroundTransparency"] = 1;
    objects["Instance10"]["Position"] = UDim2.new(0.5, 0, 0, 2);
    objects["Instance10"]["TextSize"] = 12;
    objects["Instance10"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
    objects["Instance10"]["FontFace"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal, true);
    objects["Instance10"]["BackgroundColor3"] = Color3.new(1, 1, 1);

    objects["Instance11"]["Thickness"] = 2;
    objects["Instance11"]["Parent"] = objects["Instance10"];
end;
local ___args = table.pack(...); local ___up = unpack;

-- Set modules
local o_require = require; local require; local cache = { };
local modules do
    modules = { };
    require = function(object)
        if modules[object] then
            local ret = cache[object] or modules[object](___up(___args));
            cache[object] = ret;
            return ret;
        end
        return o_require(object);
    end;

    getfenv().require = require;

    modules[objects["Instance1"]] = function(...)
        local script = objects["Instance1"];
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

            self.Parent:Cleanup()
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
    Cleanup = function(self) -- usually not needed to be called manually
        local cons = self._Connections
        local i, ln = 1, #cons

        while i <= ln do
            if not cons[i] or not cons[i].Connected then
                remove(cons, i)
                ln -= 1
            else
                i += 1
            end
        end
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
        for i, v in self._Connections do
            v:Disconnect()
        end
    end
}

eventBase = { __index = eventBase, __tostring = function() return "Event" end, __newindex = function(self, key, value) if key ~= "Enabled" then error() end rawset(self, key, value) end }
local lib = setmetatable({
    new = function()
        return smt({ _Connections = { }, Enabled = true }, eventBase)
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
local maxDefer = 10

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
    end;

    modules[objects["Instance0"]] = function(...)
        local script = objects["Instance0"];
local ESPObj = script.ESPObject
local getfenv = getfenv
local env = getfenv()
env = env.getgenv and env.getgenv() or env

local global = env.getgenv and env.getgenv() or _G
local n = "FESPLib"

local v = global[n]
if v then
    ESPObj:Destroy()
    script:Destroy()

    return v
end

script.Parent, ESPObj.Parent = nil, nil

local inew = Instance.new
local workspace, game = workspace, game

local holder = inew("Folder", game:GetService("CoreGui") or workspace)
holder.Name = "ESPLib"

local event = require(script.Event)
local ESPs = { }

local rawset, rawget = rawset, rawget
local setmetatable = setmetatable
local tick = tick
local v2 = Vector2.new
local hsv = Color3.fromHSV
local c3n = Color3.new
local typeof = typeof
local concat = table.concat
local pack, unpack = table.pack, table.unpack
local pcall = pcall
local u2 = UDim2.new
local v3 = Vector3.new
local round = math.round
local clamp = math.clamp

local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local drawing = env.Drawing or env.drawing
local fromPoint = v2(0, 0)
local maxX, maxY = 0, 0

local guiServ = game:GetService("GuiService")
local opened = guiServ.MenuIsOpen

guiServ.MenuOpened:Connect(function()
    opened = true
end)

guiServ.MenuClosed:Connect(function()
    opened = false
end)

local function memoize(fn)
    --[[local cache = setmetatable({ }, { __mode = "k" })

    return function(...)
        local args = pack(...)
        local key = args.n ~= 0 and concat(args, "\0") or ""

        local result = cache[key]
        if result then
            return unpack(result, 1, result.n)
        end

        result = pack(fn(...))
        cache[key] = result

        return unpack(result, 1, result.n)
    end]]
    
    return fn
end

local deg, atan2 = memoize(math.deg), memoize(math.atan2)

local dnew = --drawing and drawing.new or
    nil

local topb = inew("ScreenGui", holder.Parent == workspace and plr:WaitForChild("PlayerGui", 9e9) or holder.Parent)
topb.Name = "TopbarMeasurer"
topb.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets

local dh = not dnew and inew("ScreenGui", topb.Parent)
if dh then
    dh.DisplayOrder = 2147483646
    dh.ResetOnSpawn = false
    -- dh.IgnoreGuiInset = true
    dh.ClipToDeviceSafeArea = false
    dh.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        dh.OnTopOfCoreBlur = true
    end)
end

local newLine = dnew and function()
    return dnew("Line")
end or function()
    local line = inew("Frame", dh)
    line.BorderSizePixel = 0
    line.Size = u2(0, 1, 0, 1)
    line.AnchorPoint = v2(0.5, 0.5)

    return line
end

local updateLine = dnew and function(line, visible, to, color)
    line.Visible = visible
    if not visible then return end

    line.From = fromPoint
    line.To = to
    line.Color = color
    line.Thickness = 1
end or function(line, visible, to, color)
    line.Visible = false
    if not visible then return end

    local direction = (to - fromPoint)
    local center = (to + fromPoint) / 2
    line.Position = u2(0, center.X, 0, center.Y)
    line.Rotation = deg(atan2(direction.Y, direction.X))
    line.Size =  u2(0, direction.Magnitude, 0, 1)
    line.BackgroundColor3 = color
    line.Visible = true
end

local refresh
local onUpdate = function(self, idx, val)
    rawset(self, idx, val)
    self.Changed:Fire(idx, val)

    for _, v in self.Objects do
        refresh(v)
    end
end

local time = tick()
local lastTick = tick()

local currentRGBColor = hsv(time % 1, 1, 1)

onUpdate = { __newindex = onUpdate }

local ev = event.new()
local base = {
    RGBSpeed = 1,
    RGBWhite = 0, -- 0-1
    RGB = false,
    Tracers = true,
    FromPoint = "Bottom",
    Performant = false,
    ShowDistance = true,
    Event = ev,
    FPS = 30, -- good balance between laggy and smooth
    DistanceGradient = { 100, c3n(1, 0.4, 0.4), c3n(0.4, 1, 0.4) },
    ClassSettings = setmetatable({ }, {
        __index = function(self, idx)
            local tbl = rawget(self, idx)
            ESPs[idx] = ESPs[idx] or { }

            if not tbl then
                tbl = setmetatable({
                    Tracers = false,
                    RGB = false,
                    Objects = ESPs[idx],
                    Visible = false,
                    Changed = event.new(),
                    Color = c3n(1, 1, 1),
                    ShowDistance = false,
                }, onUpdate)

                rawset(self, idx, tbl)
                ev:Fire(idx, tbl)
            end

            return tbl
        end,
        __newindex = error
    }),
    InitClass = function(self, class, options)
        local class = self.ClassSettings[class]
        for i, v in options do
            class[i] = v
        end

        return class
    end
}

local cam = workspace.CurrentCamera
local f = 50
local myPos = cam and cam.CFrame or CFrame.new()
local target

game:GetService("RunService").Stepped:Connect(function()
    local currentTick = tick()
    time += (currentTick - lastTick) * base.RGBSpeed
    lastTick = currentTick
    target = plr and plr.Character or cam

    currentRGBColor = hsv(time % 1, 1, 1):Lerp(c3n(1, 1, 1), base.RGBWhite)
    cam = workspace.CurrentCamera or cam.Parent == workspace and cam or nil

    maxX = (cam and cam.ViewportSize.X or topb.AbsoluteSize.X) + f
    maxY = (cam and cam.ViewportSize.Y or 0) + f

    if base.FromPoint == "Bottom" then
        fromPoint = cam and v2(cam.ViewportSize.X / 2, cam.ViewportSize.Y - topb.AbsoluteSize.Y) or v2(0, 0)
    elseif base.FromPoint == "Top" then
        fromPoint = cam and v2(cam.ViewportSize.X / 2, -topb.AbsoluteSize.Y) or v2(0, 0)
    elseif base.FromPoint == "Center" then
        fromPoint = cam and v2(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2 - topb.AbsoluteSize.Y) or v2(0, 0)
    elseif typeof(base.FromPoint) == "Vector2" then
        if base.FromPoint.X <= 1 and base.FromPoint.Y <= 1 and (round(base.FromPoint.X) ~= base.FromPoint.X or base.FromPoint.X % 1 == 0) and (round(base.FromPoint.Y) ~= base.FromPoint.Y or base.FromPoint.Y % 1 == 0) then
            fromPoint = v2(base.FromPoint.X * cam.ViewportSize.X, base.FromPoint.Y * cam.ViewportSize.Y - topb.AbsoluteSize.Y)
        else
            fromPoint = base.FromPoint - v2(0, topb.AbsoluteSize.Y)
        end
    elseif typeof(base.FromPoint) == "UDim2" then
        local u = base.FromPoint
        fromPoint = cam and v2(u.X.Scale * cam.ViewportSize.X + u.X.Offset, u.Y.Scale * cam.ViewportSize.Y + u.Y.Offset - topb.AbsoluteSize.Y) or v2(0, 0)
    else
        fromPoint = v2(mouse.X, mouse.Y)
    end

    myPos = plr and plr.Character and plr.Character:GetPivot().Position or cam and cam.CFrame.Position or myPos
end)

local espCache = { }
task.spawn(function()
    local wait = task.wait
    local spawn = task.spawn
    
    while wait(1 / base.FPS) do
        for _, v in espCache do
            spawn(refresh, v)
        end
    end
end)

local function destroy(self)
    self = self.Self or self
    if self.Destroyed then return end

    if self.Object then
        ESPs[self.Settings.Class][self.Object] = nil
        espCache[self.Object] = nil
    end

    self.ESP:Destroy()
    self.Line:Destroy()
    
    for i, v in self.Connections do
        if v.Connected then
            v:Disconnect()
            self.Connections[i] = nil
        end
    end

    rawset(self, "Destroyed", true)
    rawset(self, "ESP", nil)
    rawset(self, "Connections", nil)
    rawset(self, "Line", nil)
end

local function getVector2(pos)
    if not cam then return nil end

    local v3 = cam:WorldToViewportPoint(pos)
    if v3.Z < 0 or base.Performant and (v3.X < -f or v3.X > maxX or v3.Y < -f or v3.Y > maxY) then return nil end

    return v2(v3.X, v3.Y - topb.AbsoluteSize.Y)
end

local getPosition; getPosition = function(obj)
    if obj:IsA("Folder") then
        local pos = v3()
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

local function paintRichText(text, color3)
    return "<font color=\"#" .. c3n(clamp(color3.R, 0, 1), clamp(color3.G, 0, 1), clamp(color3.B, 0, 1)):ToHex() .. "\">" .. text .. "</font>"
end

local function rotateRGB(col)
    return c3n(col.G, col.R, col.B)
end

refresh = function(self)
    self = self.Self or self

    if self.Destroyed then return end

    local esp = self.ESP
    local settings = self.Settings
    local obj = self.Object
    local line = self.Line

    if not obj then return destroy(self) end

    local highlight = esp.Highlight
    local pos = getPosition(obj)
    local vec = getVector2(pos)

    local class = settings.Class
    local classSettings = base.ClassSettings[class]
    local visible = vec and settings.Visible and classSettings.Visible

    esp.Enabled = visible
    highlight.Enabled = visible and settings.Highlight

    if not visible then
        return updateLine(line, false)
    end

    local text = esp.TextLabel
    local topText = esp.TopTextLabel
    local rgb = (settings.RGB or base.RGB or classSettings.RGB) and currentRGBColor

    local color = rgb
    if not color then
        color = settings.Color or classSettings.Color or c3n(1, 1, 1)
        if settings.RotationLevel then
            color = color:Lerp(rotateRGB(color), settings.RotationLevel)
        end
    end

    esp.Circle.BackgroundColor3 = color
    esp.StudsOffsetWorldSpace = pos

    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Adornee = typeof(settings.HighlightAdornee) == "Instance" and settings.HighlightAdornee or obj
    highlight.Enabled = settings.Highlight

    text.Text = settings.Text
    text.TextColor3 = color

    local afterText = ""
    
    if settings.ShowDistance or classSettings.ShowDistance and base.ShowDistance and target then
        local dist = (myPos - pos).Magnitude
            
        local gradient = settings.DistanceGradient or classSettings.DistanceGradient or base.DistanceGradient
        afterText = paintRichText("\n[ " .. (dist >= 10 and round(dist) or ("%.1f"):format(dist)) .. " ]", gradient[2]:Lerp(gradient[3], clamp(dist / gradient[1], 0, 1)))
    end

    topText.Text = settings.TopText .. afterText
    topText.TextColor3 = color

    local tracerEnabled = settings.Tracer or classSettings.Tracers and base.Tracers
    if opened or not tracerEnabled then
        return updateLine(line, false)
    end

    updateLine(line, true, vec, color)
end

local ESPBaseSettings = {
    Highlight = true,
    HighlightAdornee = false,
    Tracer = false,
    Text = "",
    TopText = "",
    Visible = true,
    ShowDistance = false,
    RGB = false,
    Class = "_Default",

    Refresh = refresh,
    Destroy = destroy
}

ESPBaseSettings = { __index = ESPBaseSettings }

local objectBase = { __index = function(self, idx)
    return rawget(rawget(self, "Settings") or { }, idx) or rawget(self, idx)
end, __newindex = function(self, idx, val)
    rawset(rawget(self, "Settings") or { }, idx, val)
    refresh(self)
end }

local function newObject(object, settings, class)
    settings = setmetatable(settings or { }, ESPBaseSettings)
    if class then
        rawset(settings, "Class", class)
    end

    rawset(settings, "Settings", settings)

    local v = espCache[object]
    if v then
        ESPs[v.Settings.Class][object] = nil
        ESPs[settings.Class][object] = v
        rawset(v, "Settings", settings)

        refresh(v)
        return v
    end

    local espObj = ESPObj:Clone()
    espObj.Parent = holder

    local tracerLine = newLine()
    updateLine(tracerLine, false)

    v = setmetatable({ Object = object, Settings = settings, ESP = espObj, Line = tracerLine, Destroy = destroy, Connections = { object.AncestryChanged:Connect(function()
        if not object:IsDescendantOf(workspace) then
            v:Destroy()
        end
    end), object:GetPropertyChangedSignal("Parent"):Connect(function()
        if not object:IsDescendantOf(workspace) then
            v:Destroy()
        end
    end) }}, objectBase)

    rawset(settings, "Self", v)

    ESPs[settings.Class] = ESPs[settings.Class] or { }
    ESPs[settings.Class][object] = v
    espCache[object] = v

    if object:IsDescendantOf(workspace) then
        refresh(v)
    else
        v:Destroy()
    end

    return v
end

base.new = newObject
global[n] = base

return base
    end;
end;

-- YOUR CODE DOWN HERE --

local obj = objects["Instance0"];
return require(obj)
