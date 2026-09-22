--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GameConfig"))

local WorldService = {}

local ROOT_NAME = "OneTripPrototype"

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, transparency: number?): Part
	local instance = Instance.new("Part")
	instance.Name = name
	instance.Size = size
	instance.CFrame = cframe
	instance.Anchored = true
	instance.CanCollide = true
	instance.TopSurface = Enum.SurfaceType.Smooth
	instance.BottomSurface = Enum.SurfaceType.Smooth
	instance.Color = color
	instance.Transparency = transparency or 0
	instance.Parent = parent
	return instance
end

local function billboard(adornee: BasePart, text: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(180, 42)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = adornee

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.35
	label.Parent = gui
end

local function buildBay(parent: Folder, index: number, angle: number, radius: number)
	local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
	local position = direction * radius
	local bay = Instance.new("Model")
	bay.Name = ("Bay%02d"):format(index)
	bay:SetAttribute("BayIndex", index)
	bay.Parent = parent

	local pad = part(
		bay,
		"Pad",
		GameConfig.World.BaySize,
		CFrame.lookAt(position, Vector3.zero),
		Color3.fromRGB(74, 91, 118),
		0
	)
	pad.Material = Enum.Material.SmoothPlastic

	local unload = part(
		bay,
		"UnloadZone",
		Vector3.new(GameConfig.World.BaySize.X - 4, 0.2, 8),
		pad.CFrame * CFrame.new(0, 0.65, -5),
		Color3.fromRGB(88, 199, 126),
		0.25
	)
	unload.CanCollide = false
	unload:SetAttribute("BayIndex", index)

	local marker = part(
		bay,
		"LabelAnchor",
		Vector3.new(1, 1, 1),
		pad.CFrame * CFrame.new(0, 1.2, 0),
		Color3.new(1, 1, 1),
		1
	)
	marker.CanCollide = false
	billboard(marker, ("BAY %02d"):format(index))
end

function WorldService.Build()
	local previous = Workspace:FindFirstChild(ROOT_NAME)
	if previous then
		previous:Destroy()
	end

	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace

	local footprint = GameConfig.World.FootprintStuds
	local floor = part(
		root,
		"WarehouseFloor",
		Vector3.new(footprint, 1, footprint),
		CFrame.new(0, -0.5, 0),
		Color3.fromRGB(47, 51, 58),
		0
	)
	floor.Material = Enum.Material.Concrete

	local itemFloor = part(
		root,
		"ItemFloor",
		GameConfig.World.ItemFloorSize,
		CFrame.new(0, 0.06, 0),
		Color3.fromRGB(78, 84, 94),
		0
	)
	itemFloor.CanCollide = false
	itemFloor.Material = Enum.Material.SmoothPlastic

	local itemAreaAnchor = part(root, "ItemFloorLabel", Vector3.new(1, 1, 1), CFrame.new(0, 1, 0), Color3.new(1, 1, 1), 1)
	itemAreaAnchor.CanCollide = false
	billboard(itemAreaAnchor, "ITEM FLOOR")

	local bays = Instance.new("Folder")
	bays.Name = "Bays"
	bays.Parent = root

	for index = 1, GameConfig.World.BayCount do
		local angle = ((index - 1) / GameConfig.World.BayCount) * math.pi * 2
		buildBay(bays, index, angle, GameConfig.World.BayRadius)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PrototypeSpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 0.6, -(GameConfig.World.BayRadius - 22))
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 0.45
	spawn.Color = Color3.fromRGB(91, 170, 255)
	spawn.Parent = root

	return root
end

return WorldService
