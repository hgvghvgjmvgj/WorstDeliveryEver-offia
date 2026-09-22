--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WarehouseConfig = require(
	ReplicatedStorage:WaitForChild("Config"):WaitForChild("WarehouseConfig")
)

local WorldService = {}

local ROOT_NAME = "OneTripPrototype"

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	transparency: number?
): Part
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

local function addBillboard(
	adornee: BasePart,
	name: string,
	text: string,
	color: Color3?,
	size: UDim2?,
	maxDistance: number?
): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Adornee = adornee
	gui.Size = size or UDim2.fromOffset(220, 54)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = maxDistance or 90
	gui.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.35
	label.Parent = gui

	return label
end

local function buildZoneSigns(root: Folder, zoneName: string, zone)
	local signs = Instance.new("Folder")
	signs.Name = zoneName .. "_Signs"
	signs.Parent = root

	local directions = {
		Vector3.new(0, 0, -1),
		Vector3.new(1, 0, 0),
		Vector3.new(0, 0, 1),
		Vector3.new(-1, 0, 0),
	}

	for index, direction in directions do
		local position = direction * zone.SignRadius
		local anchor = makePart(
			signs,
			("Sign_%02d"):format(index),
			Vector3.new(1, 1, 1),
			CFrame.new(position + Vector3.new(0, 1.1, 0)),
			Color3.new(1, 1, 1),
			1
		)
		anchor.CanCollide = false
		anchor.CanTouch = false
		anchor.CanQuery = false

		addBillboard(
			anchor,
			"ZoneLabel",
			zone.DisplayName,
			Color3.fromRGB(235, 238, 244),
			UDim2.fromOffset(220, 46),
			82
		)
	end
end

local function buildItemZones(root: Folder)
	local zonesFolder = Instance.new("Folder")
	zonesFolder.Name = "WarehouseZones"
	zonesFolder.Parent = root

	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root

	local clusterFolder = Instance.new("Folder")
	clusterFolder.Name = "ItemClusters"
	clusterFolder.Parent = root

	local zoneOrder = {
		{ Key = "Near", Depth = 1 },
		{ Key = "Mid", Depth = 2 },
		{ Key = "Deep", Depth = 3 },
	}

	for _, descriptor in zoneOrder do
		local zone = WarehouseConfig.Zones[descriptor.Key]

		local floor = makePart(
			zonesFolder,
			descriptor.Key .. "Floor",
			zone.FloorSize,
			CFrame.new(0, zone.FloorSize.Y * 0.5 + 0.01, 0),
			zone.FloorColor,
			0.12
		)
		floor.CanCollide = false
		floor.Material = Enum.Material.SmoothPlastic
		floor:SetAttribute("ZoneName", descriptor.Key)
		floor:SetAttribute("ZoneDepth", descriptor.Depth)

		buildZoneSigns(zonesFolder, descriptor.Key, zone)

		for clusterIndex, cluster in zone.Clusters do
			local model = Instance.new("Model")
			model.Name = cluster.Name
			model:SetAttribute("ZoneName", descriptor.Key)
			model:SetAttribute("ZoneDepth", descriptor.Depth)
			model:SetAttribute("ClusterIndex", clusterIndex)
			model.Parent = clusterFolder

			local pad = makePart(
				model,
				"Pad",
				Vector3.new(24, 0.10, 20),
				CFrame.new(cluster.Center),
				zone.FloorColor:Lerp(Color3.new(1, 1, 1), 0.10),
				0.52
			)
			pad.CanCollide = false

			local labelAnchor = makePart(
				model,
				"LabelAnchor",
				Vector3.new(1, 1, 1),
				CFrame.new(cluster.Center + Vector3.new(0, 0.9, 0)),
				Color3.new(1, 1, 1),
				1
			)
			labelAnchor.CanCollide = false
			labelAnchor.CanTouch = false
			labelAnchor.CanQuery = false

			addBillboard(
				labelAnchor,
				"ClusterLabel",
				zone.DisplayName,
				Color3.fromRGB(225, 229, 236),
				UDim2.fromOffset(190, 38),
				56
			)

			for itemIndex, itemId in cluster.Items do
				local columns = WarehouseConfig.SpawnLayout.ClusterColumns
				local row = math.floor((itemIndex - 1) / columns)
				local column = (itemIndex - 1) % columns

				local x = (column - (columns - 1) * 0.5)
					* WarehouseConfig.SpawnLayout.SpacingX
				local rowCount = math.ceil(#cluster.Items / columns)
				local z = (row - (rowCount - 1) * 0.5)
					* WarehouseConfig.SpawnLayout.SpacingZ
				local position = cluster.Center + Vector3.new(x, 0, z)

				local marker = makePart(
					spawnFolder,
					("%s_%02d_%02d_%s"):format(
						descriptor.Key,
						clusterIndex,
						itemIndex,
						itemId
					),
					Vector3.new(1.5, 0.10, 1.5),
					CFrame.new(position),
					Color3.fromRGB(126, 132, 143),
					0.86
				)
				marker.CanCollide = false
				marker:SetAttribute("ItemId", itemId)
				marker:SetAttribute("ZoneName", descriptor.Key)
				marker:SetAttribute("ZoneDepth", descriptor.Depth)
				marker:SetAttribute("ClusterName", cluster.Name)
				marker:SetAttribute(
					"RestockSeconds",
					WarehouseConfig.RestockSeconds[itemId] or 1.8
				)
			end
		end
	end
end

local function buildStockSlots(bay: Model, bayCFrame: CFrame)
	local config = WarehouseConfig.Bay
	local slotsFolder = Instance.new("Folder")
	slotsFolder.Name = "StockSlots"
	slotsFolder.Parent = bay

	for index, localOffset in config.StockSlotPositions do
		local activeByDefault = index <= config.InitialStockSlots
		local marker = makePart(
			slotsFolder,
			("StockSlot%02d"):format(index),
			config.StockSlotSize,
			bayCFrame * localOffset,
			if activeByDefault
				then Color3.fromRGB(93, 129, 160)
				else Color3.fromRGB(72, 80, 91),
			if activeByDefault then 0.45 else 1
		)

		marker.CanCollide = false
		marker.CanTouch = false
		marker.CanQuery = activeByDefault
		marker:SetAttribute("StockSlotIndex", index)
		marker:SetAttribute("ActiveByDefault", activeByDefault)
		marker:SetAttribute("ReservedForExpansion", true)

		if activeByDefault then
			addBillboard(
				marker,
				"StockSlotLabel",
				("STOCK %d"):format(index),
				Color3.fromRGB(205, 224, 241),
				UDim2.fromOffset(115, 30),
				40
			)
		end
	end

	local futureSell = makePart(
		bay,
		"FutureQuickSellAnchor",
		Vector3.new(1, 1, 1),
		bayCFrame * CFrame.new(-13.5, 1.0, -6.5),
		Color3.new(1, 1, 1),
		1
	)
	futureSell.CanCollide = false
	futureSell.CanTouch = false
	futureSell.CanQuery = false
	futureSell:SetAttribute("ReservedPurpose", "QuickSell")

	local futureUpgrade = makePart(
		bay,
		"FutureBayUpgradeAnchor",
		Vector3.new(1, 1, 1),
		bayCFrame * CFrame.new(13.5, 1.0, 13.5),
		Color3.new(1, 1, 1),
		1
	)
	futureUpgrade.CanCollide = false
	futureUpgrade.CanTouch = false
	futureUpgrade.CanQuery = false
	futureUpgrade:SetAttribute("ReservedPurpose", "BayUpgrade")
end

local function buildBay(baysFolder: Folder, index: number)
	local config = WarehouseConfig.Bay
	local angle = ((index - 1) / config.Count) * math.pi * 2
	local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
	local position = direction * config.Radius
	local bayCFrame = CFrame.lookAt(position, Vector3.new(0, position.Y, 0))

	local bay = Instance.new("Model")
	bay.Name = ("Bay%02d"):format(index)
	bay:SetAttribute("BayIndex", index)
	bay:SetAttribute("OwnerUserId", 0)
	bay:SetAttribute("OwnerName", "")
	bay:SetAttribute("InitialStockSlots", config.InitialStockSlots)
	bay:SetAttribute("MaxPlannedStockSlots", config.MaxPlannedStockSlots)
	bay.Parent = baysFolder

	local pad = makePart(
		bay,
		"BayPad",
		config.PadSize,
		bayCFrame,
		Color3.fromRGB(61, 71, 86)
	)
	pad.Material = Enum.Material.Concrete

	local processing = makePart(
		bay,
		"ProcessingArea",
		config.ProcessingSize,
		bayCFrame * config.ProcessingOffset,
		Color3.fromRGB(76, 111, 94),
		0.22
	)
	processing.CanCollide = false
	processing:SetAttribute("ReservedPurpose", "DeliveryProcessing")

	local unload = makePart(
		bay,
		"UnloadZone",
		config.UnloadSize,
		bayCFrame * config.UnloadOffset,
		Color3.fromRGB(84, 195, 122),
		0.72
	)
	unload.CanCollide = false
	unload.CanTouch = true
	unload:SetAttribute("BayIndex", index)

	local processingLabel = makePart(
		bay,
		"ProcessingLabelAnchor",
		Vector3.new(1, 1, 1),
		bayCFrame * CFrame.new(0, 1.3, -6.6),
		Color3.new(1, 1, 1),
		1
	)
	processingLabel.CanCollide = false
	processingLabel.CanTouch = false
	processingLabel.CanQuery = false

	addBillboard(
		processingLabel,
		"ProcessingLabel",
		"DELIVERY / PROCESSING",
		Color3.fromRGB(180, 255, 202),
		UDim2.fromOffset(200, 36),
		50
	)

	buildStockSlots(bay, bayCFrame)

	local van = Instance.new("Model")
	van.Name = "Van"
	van.Parent = bay

	local vanBody = makePart(
		van,
		"Body",
		Vector3.new(12.5, 5.2, 8.2),
		bayCFrame * config.VanOffset,
		Color3.fromRGB(126, 132, 143)
	)
	vanBody.Material = Enum.Material.SmoothPlastic

	local vanCab = makePart(
		van,
		"Cab",
		Vector3.new(8.2, 4.2, 4.2),
		bayCFrame * config.VanOffset * CFrame.new(0, -0.25, -5.4),
		Color3.fromRGB(148, 154, 164)
	)
	vanCab.Material = Enum.Material.SmoothPlastic

	local spawnMarker = makePart(
		bay,
		"SpawnMarker",
		Vector3.new(1, 1, 1),
		bayCFrame * config.SpawnOffset,
		Color3.new(1, 1, 1),
		1
	)
	spawnMarker.CanCollide = false
	spawnMarker.CanTouch = false
	spawnMarker.CanQuery = false

	local labelAnchor = makePart(
		bay,
		"OwnerLabelAnchor",
		Vector3.new(1, 1, 1),
		bayCFrame * config.OwnerLabelOffset,
		Color3.new(1, 1, 1),
		1
	)
	labelAnchor.CanCollide = false
	labelAnchor.CanTouch = false
	labelAnchor.CanQuery = false

	local label = addBillboard(
		labelAnchor,
		"OwnerLabel",
		("OPEN BAY %02d"):format(index),
		Color3.fromRGB(185, 193, 207),
		UDim2.fromOffset(240, 62),
		95
	)
	label:SetAttribute("BayIndex", index)

	bay.PrimaryPart = pad
end

local function buildExpansionPoints(root: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "FutureExpansionPoints"
	folder.Parent = root

	for index, cframe in WarehouseConfig.ExpansionPoints do
		local marker = makePart(
			folder,
			("ExpansionPoint%02d"):format(index),
			Vector3.new(2, 2, 2),
			cframe,
			Color3.fromRGB(124, 104, 155),
			1
		)
		marker.CanCollide = false
		marker.CanTouch = false
		marker.CanQuery = false
		marker:SetAttribute("ReservedPurpose", "FutureWarehouseAccess")
	end
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

	local floor = makePart(
		root,
		"WarehouseFloor",
		WarehouseConfig.FootprintSize,
		CFrame.new(0, -0.5, 0),
		Color3.fromRGB(45, 48, 55)
	)
	floor.Material = Enum.Material.Concrete

	local lanesFolder = Instance.new("Folder")
	lanesFolder.Name = "MainLanes"
	lanesFolder.Parent = root

	local laneLength = 315
	local laneNS = makePart(
		lanesFolder,
		"NorthSouthLane",
		Vector3.new(WarehouseConfig.MainLaneWidth, 0.08, laneLength),
		CFrame.new(0, 0.06, 0),
		Color3.fromRGB(107, 113, 124),
		0.65
	)
	laneNS.CanCollide = false

	local laneEW = makePart(
		lanesFolder,
		"EastWestLane",
		Vector3.new(laneLength, 0.08, WarehouseConfig.MainLaneWidth),
		CFrame.new(0, 0.065, 0),
		Color3.fromRGB(107, 113, 124),
		0.65
	)
	laneEW.CanCollide = false

	buildItemZones(root)

	local baysFolder = Instance.new("Folder")
	baysFolder.Name = "Bays"
	baysFolder.Parent = root

	for index = 1, WarehouseConfig.Bay.Count do
		buildBay(baysFolder, index)
	end

	buildExpansionPoints(root)

	local fallbackSpawn = Instance.new("SpawnLocation")
	fallbackSpawn.Name = "FallbackSpawn"
	fallbackSpawn.Size = Vector3.new(6, 1, 6)
	fallbackSpawn.CFrame = CFrame.lookAt(
		WarehouseConfig.FallbackSpawnPosition,
		Vector3.new(0, WarehouseConfig.FallbackSpawnPosition.Y, 0)
	)
	fallbackSpawn.Anchored = true
	fallbackSpawn.CanCollide = false
	fallbackSpawn.Neutral = true
	fallbackSpawn.Duration = 0
	fallbackSpawn.Transparency = 1
	fallbackSpawn.Parent = root

	local feedback = Instance.new("Folder")
	feedback.Name = "Feedback"
	feedback.Parent = root

	local wallColor = Color3.fromRGB(62, 65, 73)
	local halfX = WarehouseConfig.FootprintSize.X * 0.5
	local halfZ = WarehouseConfig.FootprintSize.Z * 0.5
	local wallY = WarehouseConfig.WallHeight * 0.5

	makePart(
		root,
		"NorthWall",
		Vector3.new(WarehouseConfig.FootprintSize.X, WarehouseConfig.WallHeight, 1),
		CFrame.new(0, wallY, halfZ),
		wallColor
	)
	makePart(
		root,
		"SouthWall",
		Vector3.new(WarehouseConfig.FootprintSize.X, WarehouseConfig.WallHeight, 1),
		CFrame.new(0, wallY, -halfZ),
		wallColor
	)
	makePart(
		root,
		"WestWall",
		Vector3.new(1, WarehouseConfig.WallHeight, WarehouseConfig.FootprintSize.Z),
		CFrame.new(-halfX, wallY, 0),
		wallColor
	)
	makePart(
		root,
		"EastWall",
		Vector3.new(1, WarehouseConfig.WallHeight, WarehouseConfig.FootprintSize.Z),
		CFrame.new(halfX, wallY, 0),
		wallColor
	)

	return root
end

return WorldService
