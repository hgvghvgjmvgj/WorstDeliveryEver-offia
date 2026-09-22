--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GameConfig"))

local WorldService = {}

local ROOT_NAME = "OneTripPrototype"

local function makePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, transparency: number?): Part
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

local function addBillboard(adornee: BasePart, text: string, color: Color3?)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(220, 54)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = adornee

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.35
	label.Parent = gui
end

function WorldService.Build(): Folder
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

	local world = GameConfig.World

	local floor = makePart(root, "Floor", world.FootprintSize, CFrame.new(0, -0.5, 0), Color3.fromRGB(48, 51, 58))
	floor.Material = Enum.Material.Concrete

	local itemFloor = makePart(
		root,
		"ItemFloor",
		world.ItemFloorSize,
		CFrame.new(world.ItemFloorCenter),
		Color3.fromRGB(77, 83, 94)
	)
	itemFloor.CanCollide = false
	itemFloor.Material = Enum.Material.SmoothPlastic

	local itemLabel = makePart(root, "ItemFloorLabel", Vector3.new(1, 1, 1), CFrame.new(0, 1, 5), Color3.new(1, 1, 1), 1)
	itemLabel.CanCollide = false
	addBillboard(itemLabel, "M1.1 TEMPTATION TEST")

	local unloadZone = makePart(
		root,
		"UnloadZone",
		world.UnloadSize,
		CFrame.new(world.UnloadCenter),
		Color3.fromRGB(82, 194, 121),
		0.22
	)
	unloadZone.CanCollide = false
	unloadZone.CanTouch = true
	addBillboard(unloadZone, "MAKE IT HOME", Color3.fromRGB(182, 255, 201))

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PrototypeSpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.lookAt(world.SpawnPosition, Vector3.new(0, world.SpawnPosition.Y, 0))
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 0.35
	spawn.Color = Color3.fromRGB(86, 164, 255)
	spawn.Parent = root

	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root

	for index, spawnDefinition in world.TestItemSpawns do
		local marker = makePart(
			spawnFolder,
			("Spawn_%02d_%s"):format(index, spawnDefinition.ItemId),
			Vector3.new(2, 0.15, 2),
			CFrame.new(spawnDefinition.Position),
			Color3.fromRGB(130, 138, 151),
			0.72
		)
		marker.CanCollide = false
		marker:SetAttribute("ItemId", spawnDefinition.ItemId)
	end

	local routeLeft = makePart(
		root,
		"ReturnPathLeft",
		Vector3.new(2, 0.08, 29),
		CFrame.new(-16, 0.08, -35),
		Color3.fromRGB(99, 104, 113),
		0.4
	)
	routeLeft.CanCollide = false

	local routeRight = makePart(
		root,
		"ReturnPathRight",
		Vector3.new(2, 0.08, 29),
		CFrame.new(16, 0.08, -35),
		Color3.fromRGB(99, 104, 113),
		0.4
	)
	routeRight.CanCollide = false

	local feedback = Instance.new("Folder")
	feedback.Name = "Feedback"
	feedback.Parent = root

	local wallColor = Color3.fromRGB(67, 71, 79)
	local halfX = world.FootprintSize.X * 0.5
	local halfZ = world.FootprintSize.Z * 0.5
	makePart(root, "NorthWall", Vector3.new(world.FootprintSize.X, 10, 1), CFrame.new(0, 5, halfZ), wallColor)
	makePart(root, "SouthWall", Vector3.new(world.FootprintSize.X, 10, 1), CFrame.new(0, 5, -halfZ), wallColor)
	makePart(root, "WestWall", Vector3.new(1, 10, world.FootprintSize.Z), CFrame.new(-halfX, 5, 0), wallColor)
	makePart(root, "EastWall", Vector3.new(1, 10, world.FootprintSize.Z), CFrame.new(halfX, 5, 0), wallColor)

	return root
end

return WorldService
