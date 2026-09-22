local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("ItemConfig"))

local PrototypeMap = {}

local function makePart(parent, name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Material = material or Enum.Material.SmoothPlastic
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addPrompt(part, actionText, objectText)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "InteractionPrompt"
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Parent = part
	return prompt
end

local function addBillboard(part, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(220, 60)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.35
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

function PrototypeMap.Build()
	local existing = Workspace:FindFirstChild("OneTripPrototype")
	if existing then
		return existing
	end

	local world = Instance.new("Folder")
	world.Name = "OneTripPrototype"
	world.Parent = Workspace

	makePart(
		world,
		"Ground",
		Vector3.new(86, 1, 126),
		Vector3.new(0, -0.5, 0),
		Color3.fromRGB(86, 104, 76),
		Enum.Material.Grass
	)

	local driveway = makePart(
		world,
		"Driveway",
		Vector3.new(26, 0.4, 95),
		Vector3.new(0, 0.2, 0),
		Color3.fromRGB(91, 91, 91),
		Enum.Material.Concrete
	)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PrototypeSpawn"
	spawn.Size = Vector3.new(7, 1, 7)
	spawn.Position = Vector3.new(0, 1, -47)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Transparency = 0.35
	spawn.Color = Color3.fromRGB(86, 170, 255)
	spawn.Parent = world

	local car = Instance.new("Model")
	car.Name = "GroceryCar"
	car.Parent = world

	makePart(car, "Body", Vector3.new(12, 3.5, 18), Vector3.new(0, 2.1, -33), Color3.fromRGB(38, 102, 185))
	makePart(car, "Roof", Vector3.new(10, 2.6, 8), Vector3.new(0, 4.9, -33), Color3.fromRGB(49, 120, 205))

	local trunk = makePart(
		car,
		"Trunk",
		Vector3.new(11, 1, 6),
		Vector3.new(0, 4.0, -23.5),
		Color3.fromRGB(44, 44, 44)
	)
	addBillboard(trunk, "TAKE GROCERIES")

	local itemsFolder = Instance.new("Folder")
	itemsFolder.Name = "PickupItems"
	itemsFolder.Parent = world

	local xPositions = {-5.0, -2.5, 0, 2.5, 5.0}
	for index, itemId in ItemConfig.Order do
		local definition = ItemConfig.Get(itemId)
		local itemPart = makePart(
			itemsFolder,
			itemId,
			definition.Size,
			Vector3.new(xPositions[index], 5.2, -23.0),
			definition.Color
		)
		itemPart:SetAttribute("ItemId", itemId)
		itemPart:SetAttribute("Weight", definition.Weight)
		itemPart:SetAttribute("Reward", definition.Reward)
		addPrompt(itemPart, "TAKE", definition.DisplayName)
	end

	local goPart = makePart(
		world,
		"GoPart",
		Vector3.new(8, 1, 5),
		Vector3.new(0, 0.7, -15),
		Color3.fromRGB(68, 200, 95),
		Enum.Material.Neon
	)
	addBillboard(goPart, "GO — ONE TRIP")
	addPrompt(goPart, "START TRIP", "Ready?")

	local obstacleFolder = Instance.new("Folder")
	obstacleFolder.Name = "Obstacles"
	obstacleFolder.Parent = world

	local obstacleData = {
		{Vector3.new(-5.5, 1.0, -1), Vector3.new(3.5, 2, 3.5), Color3.fromRGB(232, 140, 50)},
		{Vector3.new(5.0, 1.5, 13), Vector3.new(4.5, 3, 4.5), Color3.fromRGB(106, 80, 58)},
		{Vector3.new(-4.0, 0.6, 26), Vector3.new(7, 1.2, 2), Color3.fromRGB(232, 207, 71)},
	}

	for index, data in obstacleData do
		makePart(
			obstacleFolder,
			"Obstacle" .. index,
			data[2],
			data[1],
			data[3],
			Enum.Material.SmoothPlastic
		)
	end

	local house = Instance.new("Model")
	house.Name = "House"
	house.Parent = world

	makePart(house, "HouseBody", Vector3.new(34, 18, 18), Vector3.new(0, 9, 49), Color3.fromRGB(224, 207, 178))
	makePart(house, "Door", Vector3.new(6, 9, 0.8), Vector3.new(0, 4.5, 39.6), Color3.fromRGB(95, 57, 39))

	local finish = makePart(
		world,
		"FinishZone",
		Vector3.new(10, 1, 7),
		Vector3.new(0, 0.6, 35),
		Color3.fromRGB(71, 220, 103),
		Enum.Material.Neon
	)
	finish.Transparency = 0.25
	addBillboard(finish, "FRONT DOOR")

	driveway:SetAttribute("PrototypeGenerated", true)

	return world
end

return PrototypeMap
