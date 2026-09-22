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

local function addBillboard(part, text, maxDistance)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(210, 44)
	gui.StudsOffset = Vector3.new(0, 3.25, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = maxDistance or 45
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.55
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

local function addArrow(parent, position)
	local arrow = makePart(
		parent,
		"RouteArrow",
		Vector3.new(3.5, 0.15, 5),
		position,
		Color3.fromRGB(255, 221, 61),
		Enum.Material.SmoothPlastic
	)
	arrow.CanCollide = false
	return arrow
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
		Vector3.new(0, -0.7, 0),
		Color3.fromRGB(72, 190, 82),
		Enum.Material.SmoothPlastic
	)

	local driveway = makePart(
		world,
		"Driveway",
		Vector3.new(26, 0.4, 95),
		Vector3.new(0, 0.2, 0),
		Color3.fromRGB(104, 111, 122),
		Enum.Material.SmoothPlastic
	)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PrototypeSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.lookAt(Vector3.new(9, 1, -23), Vector3.new(0, 1, -18))
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Transparency = 0.55
	spawn.Color = Color3.fromRGB(81, 177, 255)
	spawn.Parent = world

	local car = Instance.new("Model")
	car.Name = "GroceryCar"
	car.Parent = world

	makePart(car, "Body", Vector3.new(12, 3.5, 18), Vector3.new(0, 2.1, -33), Color3.fromRGB(38, 121, 235))
	makePart(car, "Roof", Vector3.new(10, 2.6, 8), Vector3.new(0, 4.9, -33), Color3.fromRGB(67, 151, 255))

	local trunk = makePart(
		car,
		"Trunk",
		Vector3.new(11, 1, 6),
		Vector3.new(0, 4.0, -23.5),
		Color3.fromRGB(48, 52, 63)
	)
	addBillboard(trunk, "TAKE AS MUCH AS YOU DARE", 30)

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
		Vector3.new(8, 0.45, 5),
		Vector3.new(0, 0.45, -15),
		Color3.fromRGB(75, 222, 103),
		Enum.Material.SmoothPlastic
	)
	addPrompt(goPart, "START TRIP", "ONE TRIP")

	addArrow(world, Vector3.new(0, 0.48, -9))
	addArrow(world, Vector3.new(0, 0.48, 9))
	addArrow(world, Vector3.new(0, 0.48, 29))

	local obstacleFolder = Instance.new("Folder")
	obstacleFolder.Name = "Obstacles"
	obstacleFolder.Parent = world

	local obstacleData = {
		{Vector3.new(0, 1.5, 0), Vector3.new(8.5, 3, 4.5), Color3.fromRGB(255, 151, 54), "TrashBins"},
		{Vector3.new(-5.2, 1.75, 14), Vector3.new(9.0, 3.5, 5.0), Color3.fromRGB(148, 92, 65), "Boxes"},
		{Vector3.new(4.6, 0.7, 26), Vector3.new(8.5, 1.4, 3.0), Color3.fromRGB(255, 216, 65), "Toy"},
	}

	for _, data in obstacleData do
		local obstacle = makePart(
			obstacleFolder,
			data[4],
			data[2],
			data[1],
			data[3],
			Enum.Material.SmoothPlastic
		)
		obstacle:SetAttribute("BalanceHazard", true)
	end

	local step1 = makePart(world, "FrontStep1", Vector3.new(15, 0.8, 4), Vector3.new(0, 0.6, 32), Color3.fromRGB(183, 187, 196))
	local step2 = makePart(world, "FrontStep2", Vector3.new(13, 1.4, 3), Vector3.new(0, 1.0, 35), Color3.fromRGB(196, 200, 208))
	step1:SetAttribute("BalanceHazard", true)
	step2:SetAttribute("BalanceHazard", true)

	local house = Instance.new("Model")
	house.Name = "House"
	house.Parent = world

	makePart(house, "HouseBody", Vector3.new(34, 18, 18), Vector3.new(0, 9, 49), Color3.fromRGB(255, 205, 93))
	makePart(house, "Door", Vector3.new(6, 9, 0.8), Vector3.new(0, 4.5, 39.6), Color3.fromRGB(69, 117, 218))

	local finish = makePart(
		world,
		"FinishZone",
		Vector3.new(10, 0.5, 6),
		Vector3.new(0, 1.6, 37),
		Color3.fromRGB(79, 235, 116),
		Enum.Material.SmoothPlastic
	)
	finish.Transparency = 0.25
	finish.CanCollide = false
	addBillboard(finish, "DELIVER HERE", 38)

	driveway:SetAttribute("PrototypeGenerated", true)

	return world
end

return PrototypeMap
