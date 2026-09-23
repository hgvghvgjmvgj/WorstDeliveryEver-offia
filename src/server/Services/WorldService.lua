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
	gui.MaxDistance = maxDistance or 100
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

local function depthName(depth: number): string
	if depth >= 3 then
		return "Deep"
	elseif depth >= 2 then
		return "Mid"
	end
	return "Near"
end

local function laneBetween(
	parent: Instance,
	name: string,
	a: Vector3,
	b: Vector3,
	width: number,
	color: Color3,
	transparency: number
): Part
	local flatA = Vector3.new(a.X, 0.14, a.Z)
	local flatB = Vector3.new(b.X, 0.14, b.Z)
	local midpoint = (flatA + flatB) * 0.5
	local length = (flatB - flatA).Magnitude
	local cframe = CFrame.lookAt(midpoint, flatB)
	local part = makePart(parent, name, Vector3.new(width, 0.08, length), cframe, color, transparency)
	part.CanCollide = false
	part.CanTouch = false
	return part
end

local function makeLabelAnchor(
	parent: Instance,
	name: string,
	position: Vector3,
	text: string,
	color: Color3,
	maxDistance: number?
)
	local anchor = makePart(
		parent,
		name,
		Vector3.new(1, 1, 1),
		CFrame.new(position),
		Color3.new(1, 1, 1),
		1
	)
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	addBillboard(anchor, "Label", text, color, UDim2.fromOffset(240, 44), maxDistance or 110)
end

local function buildLoadingApron(root: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "ReceivingDispatch"
	folder.Parent = root

	local apron = makePart(
		folder,
		"LoadingApron",
		WarehouseConfig.LoadingApron.Size,
		CFrame.new(WarehouseConfig.LoadingApron.Center),
		Color3.fromRGB(66, 72, 82),
		0.08
	)
	apron.CanCollide = false
	apron.Material = Enum.Material.Concrete

	local crossing = makePart(
		folder,
		"FreightCrossing",
		Vector3.new(WarehouseConfig.LoadingApron.Size.X - 22, 0.08, 20),
		CFrame.new(0, 0.14, WarehouseConfig.LoadingApron.FreightCrossingZ),
		Color3.fromRGB(112, 118, 128),
		0.54
	)
	crossing.CanCollide = false
	crossing.CanTouch = false

	-- Deliberate open staging pockets explain why the apron is wider than an aisle.
	for index, x in { -292, 292 } do
		local staging = makePart(
			folder,
			("OversizedStaging_%02d"):format(index),
			Vector3.new(42, 0.12, 34),
			CFrame.new(x, 0.15, 145),
			Color3.fromRGB(82, 88, 98),
			0.25
		)
		staging.CanCollide = false
		staging.CanTouch = false
		staging:SetAttribute("ReservedPurpose", "OversizedReceiving")
	end

	makeLabelAnchor(
		folder,
		"DispatchLabelAnchor",
		Vector3.new(0, 1.2, 148),
		"RECEIVING / DISPATCH",
		Color3.fromRGB(216, 226, 237),
		130
	)
end

local function buildCrossAisles(root: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "CrossAisles"
	folder.Parent = root

	for _, aisle in WarehouseConfig.CrossAisles do
		local part = makePart(
			folder,
			aisle.Name,
			Vector3.new(638, 0.09, aisle.Width),
			CFrame.new(0, 0.15, aisle.Z),
			Color3.fromRGB(112, 118, 128),
			0.48
		)
		part.CanCollide = false
		part.CanTouch = false
		part:SetAttribute("RouteType", "CrossAisle")

		makeLabelAnchor(
			folder,
			aisle.Name .. "_LabelAnchor",
			Vector3.new(0, 1.0, aisle.Z),
			string.gsub(aisle.Name, "_", " "),
			Color3.fromRGB(195, 202, 213),
			86
		)
	end
end

local function structureVisual(sectorColor: Color3, kind: string): (Color3, Enum.Material, number, boolean)
	if kind == "Rack" then
		return sectorColor:Lerp(Color3.fromRGB(43, 46, 52), 0.48), Enum.Material.Metal, 0.06, true
	elseif kind == "Block" then
		return sectorColor:Lerp(Color3.fromRGB(60, 64, 72), 0.32), Enum.Material.Metal, 0.10, true
	elseif kind == "Divider" then
		return sectorColor:Lerp(Color3.fromRGB(55, 58, 64), 0.40), Enum.Material.Metal, 0.12, true
	elseif kind == "Cage" then
		return Color3.fromRGB(92, 94, 86), Enum.Material.Metal, 0.35, true
	elseif kind == "Staging" then
		return sectorColor:Lerp(Color3.fromRGB(115, 112, 102), 0.20), Enum.Material.Concrete, 0.48, false
	else
		return sectorColor:Lerp(Color3.fromRGB(120, 123, 129), 0.20), Enum.Material.Concrete, 0.42, false
	end
end

local function buildOpportunity(
	spawnFolder: Folder,
	sectorKey: string,
	index: number,
	opportunity
)
	local depth = opportunity.Depth
	local zoneName = depthName(depth)
	local marker = makePart(
		spawnFolder,
		("%s_%02d_%s_%s"):format(sectorKey, index, zoneName, opportunity.ItemId),
		Vector3.new(1.2, 0.08, 1.2),
		CFrame.new(opportunity.Position + Vector3.new(0, 0.04, 0)),
		Color3.fromRGB(126, 132, 143),
		1
	)
	marker.CanCollide = false
	marker.CanTouch = false
	marker.CanQuery = false
	marker:SetAttribute("ItemId", opportunity.ItemId)
	marker:SetAttribute("ZoneName", zoneName)
	marker:SetAttribute("ZoneDepth", depth)
	marker:SetAttribute("SectorName", sectorKey)
	marker:SetAttribute("OpportunityName", opportunity.Name)
	marker:SetAttribute("OpportunityKind", opportunity.Kind)
	marker:SetAttribute("RestockSeconds", WarehouseConfig.RestockSeconds[opportunity.ItemId] or 1.8)
end

local function buildSectorStructures(model: Model, sectorKey: string, sector)
	local folder = Instance.new("Folder")
	folder.Name = "StorageStructures"
	folder.Parent = model

	for index, structure in sector.Structures do
		local color, material, transparency, collides = structureVisual(sector.Color, structure.Kind)
		local part = makePart(
			folder,
			("%02d_%s"):format(index, structure.Name),
			structure.Size,
			CFrame.new(structure.Position),
			color,
			transparency
		)
		part.Material = material
		part.CanCollide = collides
		part.CanTouch = false
		part:SetAttribute("GrayboxStructure", true)
		part:SetAttribute("StructureKind", structure.Kind)
		part:SetAttribute("SectorName", sectorKey)
	end
end

local function buildServiceRoute(model: Model, sectorKey: string, sector)
	local folder = Instance.new("Folder")
	folder.Name = "ServiceRoute"
	folder.Parent = model

	for index = 1, #sector.ServiceRoute - 1 do
		local segment = laneBetween(
			folder,
			("Service_%02d"):format(index),
			sector.ServiceRoute[index],
			sector.ServiceRoute[index + 1],
			WarehouseConfig.Sector.ServiceLaneWidth,
			Color3.fromRGB(145, 122, 82),
			0.56
		)
		segment:SetAttribute("RouteType", "ServiceShortcut")
		segment:SetAttribute("SectorName", sectorKey)
	end
end

local function buildSector(
	root: Folder,
	spawnFolder: Folder,
	sectorKey: string,
	sector
)
	local model = Instance.new("Model")
	model.Name = sectorKey
	model:SetAttribute("SectorName", sectorKey)
	model:SetAttribute("GrayboxStyle", sector.Style)
	model.Parent = root

	local centerZ = (WarehouseConfig.Sector.FrontZ + WarehouseConfig.Sector.BackZ) * 0.5
	local length = WarehouseConfig.Sector.FrontZ - WarehouseConfig.Sector.BackZ
	local floor = makePart(
		model,
		"SectorFloor",
		Vector3.new(WarehouseConfig.Sector.Width, 0.08, length),
		CFrame.new(sector.CenterX, 0.11, centerZ),
		sector.Color,
		0.90
	)
	floor.CanCollide = false
	floor.CanTouch = false

	local freight = makePart(
		model,
		"MainFreightRoute",
		Vector3.new(WarehouseConfig.Sector.FreightLaneWidth, 0.09, length),
		CFrame.new(sector.CenterX, 0.15, centerZ),
		Color3.fromRGB(119, 126, 136),
		0.52
	)
	freight.CanCollide = false
	freight.CanTouch = false
	freight:SetAttribute("RouteType", "Freight")

	-- Short side branches visually/physically connect off-axis loot pockets to the
	-- main route instead of making them feel randomly scattered on the floor.
	local branchFolder = Instance.new("Folder")
	branchFolder.Name = "SideBranches"
	branchFolder.Parent = model
	for index, opportunity in sector.Opportunities do
		local deltaX = opportunity.Position.X - sector.CenterX
		if math.abs(deltaX) >= 24 then
			local branch = laneBetween(
				branchFolder,
				("Branch_%02d"):format(index),
				Vector3.new(sector.CenterX, 0, opportunity.Position.Z),
				opportunity.Position,
				14,
				Color3.fromRGB(105, 109, 117),
				0.70
			)
			branch:SetAttribute("RouteType", "SideBranch")
		end
	end

	buildSectorStructures(model, sectorKey, sector)
	buildServiceRoute(model, sectorKey, sector)

	makeLabelAnchor(
		model,
		"SectorSignAnchor",
		Vector3.new(sector.CenterX, 1.2, 101),
		sector.DisplayName,
		Color3.fromRGB(235, 238, 244),
		118
	)

	for opportunityIndex, opportunity in sector.Opportunities do
		buildOpportunity(spawnFolder, sectorKey, opportunityIndex, opportunity)
	end
end

local function buildDeepStorageLandmark(root: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "SecureStorage"
	folder.Parent = root

	local boundary = makePart(
		folder,
		"SecureBackline",
		Vector3.new(630, 0.12, 8),
		CFrame.new(0, 0.16, -190),
		Color3.fromRGB(123, 93, 74),
		0.28
	)
	boundary.CanCollide = false
	boundary.CanTouch = false
	boundary:SetAttribute("ReservedPurpose", "FutureSecureExpansion")

	for _, x in { -240, -80, 80, 240 } do
		local doorFrame = makePart(
			folder,
			("SecureDoor_%d"):format(x),
			Vector3.new(54, 18, 4),
			CFrame.new(x, 9, -199),
			Color3.fromRGB(72, 69, 66),
			0.20
		)
		doorFrame.Material = Enum.Material.Metal
		doorFrame.CanCollide = true
		doorFrame:SetAttribute("ReservedPurpose", "FutureSecureStorage")
	end

	makeLabelAnchor(
		folder,
		"SecureLabelAnchor",
		Vector3.new(0, 1.4, -178),
		"DEEP / SECURE STORAGE",
		Color3.fromRGB(238, 210, 185),
		128
	)
end

local function buildWarehouseGameplay(root: Folder)
	local gameplay = Instance.new("Folder")
	gameplay.Name = "WarehouseGameplay"
	gameplay.Parent = root

	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root

	buildLoadingApron(gameplay)
	buildCrossAisles(gameplay)

	local sectorFolder = Instance.new("Folder")
	sectorFolder.Name = "Sectors"
	sectorFolder.Parent = gameplay
	for _, key in { "General", "Appliances", "Furniture", "Industrial" } do
		buildSector(sectorFolder, spawnFolder, key, WarehouseConfig.Sectors[key])
	end

	buildDeepStorageLandmark(gameplay)
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
			if activeByDefault then Color3.fromRGB(93, 129, 160) else Color3.fromRGB(72, 80, 91),
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
	futureSell:SetAttribute("ReservedPurpose", "Sell")

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
	local position = Vector3.new(config.StartX + (index - 1) * config.Spacing, 0, config.Z)
	local bayCFrame = CFrame.lookAt(position, position + Vector3.new(0, 0, -1))

	local bay = Instance.new("Model")
	bay.Name = ("Bay%02d"):format(index)
	bay:SetAttribute("BayIndex", index)
	bay:SetAttribute("OwnerUserId", 0)
	bay:SetAttribute("OwnerName", "")
	bay:SetAttribute("InitialStockSlots", config.InitialStockSlots)
	bay:SetAttribute("MaxPlannedStockSlots", config.MaxPlannedStockSlots)
	bay.Parent = baysFolder

	local pad = makePart(bay, "BayPad", config.PadSize, bayCFrame, Color3.fromRGB(61, 71, 86))
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
		bayCFrame * CFrame.new(0, 1.3, -7.4),
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
	makePart(van, "Body", Vector3.new(12.5, 5.2, 8.2), bayCFrame * config.VanOffset, Color3.fromRGB(126, 132, 143))
	makePart(van, "Cab", Vector3.new(8.2, 4.2, 4.2), bayCFrame * config.VanOffset * CFrame.new(0, -0.25, -5.4), Color3.fromRGB(148, 154, 164))

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

	buildWarehouseGameplay(root)

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
		WarehouseConfig.FallbackSpawnPosition + Vector3.new(0, 0, -1)
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
	makePart(root, "NorthWall", Vector3.new(WarehouseConfig.FootprintSize.X, WarehouseConfig.WallHeight, 1), CFrame.new(0, wallY, halfZ), wallColor)
	makePart(root, "SouthWall", Vector3.new(WarehouseConfig.FootprintSize.X, WarehouseConfig.WallHeight, 1), CFrame.new(0, wallY, -halfZ), wallColor)
	makePart(root, "WestWall", Vector3.new(1, WarehouseConfig.WallHeight, WarehouseConfig.FootprintSize.Z), CFrame.new(-halfX, wallY, 0), wallColor)
	makePart(root, "EastWall", Vector3.new(1, WarehouseConfig.WallHeight, WarehouseConfig.FootprintSize.Z), CFrame.new(halfX, wallY, 0), wallColor)

	return root
end

return WorldService
