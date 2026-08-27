local CursorLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Its-Kawi/Utilities/refs/heads/main/EditableCursor/Main.lua"))()

local Cursor1 = CursorLib.new() do -- Creating a new Cursor and adding effects to it
	Cursor1
		:Glow({ Order = 0, Color = Color3.fromRGB(255, 85, 127) }) -- Effect #1
		:Outline({ Transparency = 0.5, Order = 1 }) -- Effect #2
		:Blurred3D()
	
	Cursor1.Transparency = 0.1 -- Cursor's Group Transparency
	Cursor1.Effects[2]:Destroy() -- Remove the Stroke (#2), now Blurred3D becomes the 2nd effect (#2)
end

local Cursor2 = CursorLib.new({ -- Creating a new Cursor and pre-defining it's effects using a table
	CursorLib:Glitch({ Visible = false })
}) do
	Cursor2.Size = 30 -- 10 pixels bigger than Cursor1
	Cursor2.Image = "rbxassetid://316279304" -- Crosshair
	Cursor2.Centered = true -- Center the Crosshair image
	Cursor2.Color = Color3.fromRGB(255, 170, 0) -- This will change Crosshair's/Cursor's color and it won't apply to effects
	Cursor2.Blurry = false -- It will be pixelated instead, only works when Image is present (Image ~= "")
end

for effectName, effectData in CursorLib.Effects do
	print("--", effectName, "--\nName:", effectData.Name, "\nOrder:", effectData.Order, "\n")
	-- Name is full effect name (e.g. with spacebars, sometimes it won't match the EffectName) and Order is effect's order, if you wanna put it in a list (Dropdown or smth)
end

-- By default Cursors are inactive, so you need to activate them
CursorLib:SetActive(Cursor1)
CursorLib:SetActive(Cursor2) -- The last active cursor will have the priority, so Cursor2 gonna be visible instead

task.wait(5)

CursorLib:SetActive(Cursor1)
Cursor2:Destroy()

task.wait(5)

CursorLib:SetActive(Cursor1, false) -- Deactivate 1st cursor, because its still active
CursorLib:SetActive(Cursor2) -- Since Cursor2 is now destroyed, it will show default Roblox's cursor (or game's)
