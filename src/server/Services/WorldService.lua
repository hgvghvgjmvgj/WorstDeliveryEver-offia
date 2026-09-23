--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WarehouseConfig = require(
	ReplicatedStorage:WaitForChild("Config"):WaitForChild("WarehouseConfig")
)

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

local function addBillboard(adornee: BasePart, name: string, text: string, color: Color3?, size: UDim2?, maxDistance: number?): TextLabel
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

local function depthName(depth: number): string
	if depth >= 3 then
		return "Deep"
	elseif depth >= 2 then
		return "Mid"
	end
	return "Near"
end

local function laneBetween(parent: Instance, name: string, a: Vector3, b: Vector3, width: number, color: Color3, transparency: number): Part
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

local function buildLoadingApron(root: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "ReceivingDispatch"
	folder.Parent = root

	local apron = makePart(
		folder,
		"LoadingApron",
		WarehouseConfig.LoadingApron.Size,
		CFrame.new(WarehouseConfig.LoadingApron.Center),
		Color3.fromRGB(68, 74, 84),
		0.12
	)
	apron.CanCollide = false
	apron.Material = Enum.Material.Concrete

	local anchor = makePart(folder, "DispatchLabelAnchor", Vector3.new(1, 1, 1), CFrame.new(0, 1.2, 230), Color3.new(1, 1, 1), 1)
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	addBillboard(anchor, "DispatchLabel", "RECEIVING / DISPATCH", Color3.fromRGB(210, 222, 235), UDim2.fromOffset(260, 46), 120)
end

local function buildCrossAisles(root: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "CrossAisles"
	folder.Parent = root

	for _, aisle in WarehouseConfig.CrossAisles do
		local part = makePart(
			folder,
			aisle.Name,
			Vector3.new(570, 0.09, aisle.Width),
			CFrame.new(0, 0.15, aisle.Z),
			Color3.fromRGB(110, 116, 126),
			0.57
		)
		part.CanCollide = false
		part.CanTouch = false

		local anchor = makePart(folder, aisle.Name .. "_Label", Vector3.new(1, 1, 1), CFrame.new(0, 1.0, aisle.Z), Color3.new(1, 1, 1), 1)
		anchor.CanCollide = false
		anchor.CanTouch = false
		anchor.CanQuery = false
		addBillboard(anchor, "Label", string.gsub(aisle.Name, "_", " "), Color3.fromRGB(195, 202, 213), UDim2.fromOffset(180, 32), 75)
	end
end

local function buildOpportunity(spawnFolder: Folder, sectorModel: Model, sectorKey: string, sectorColor: Color3, index: number, opportunity)
	local depth = opportunity.Depth
	local zoneName = depthName(depth)
	local pad = makePart(
		sectorModel,
		("Opportunity_%02d_%s"):format(index, opportunity.Kind),
		Vector3.new(14, 0.10, 10),
		CFrame.new(opportunity.Position),
		sectorColor:Lerp(Color3.new(1, 1, 1), 0.12),
		0.48
	)
	pad.CanCollide = false
	pad.CanTouch = false
	pad:SetAttribute("SectorName", sectorKey)
	pad:SetAttribute("ZoneName", zoneName)
	pad:SetAttribute("ZoneDepth", depth)
	pad:SetAttribute("OpportunityKind", opportunity.Kind)

	local marker = makePart(
		spawnFolder,
		("%s_%02d_%s_%s"):format(sectorKey, index, zoneName, opportunity.ItemId),
		Vector3.new(1.5, 0.10, 1.5),
		CFrame.new(opportunity.Position + Vector3.new(0, 0.05, 0)),
		Color3.fromRGB(126, 132, 143),
		0.86
	)
	marker.CanCollide = false
	marker:SetAttribute("ItemId", opportunity.ItemId)
	marker:SetAttribute("ZoneName", zoneName)
	marker:SetAttribute("ZoneDepth", depth)
	marker:SetAttribute("SectorName", sectorKey)
	marker:SetAttribute("OpportunityName", opportunity.Name)
	marker:SetAttribute("OpportunityKind", opportunity.Kind)
	marker:SetAttribute("RestockSeconds", WarehouseConfig.RestockSeconds[opportunity.ItemId] or 1.8)
end

local function buildSector(root: Folder, spawnFolder: Folder, sectorKey: string, sector, sectorIndex: number)
	local model = Instance.new("Model")
	model.Name = sectorKey
	model:SetAttribute("SectorName", sectorKey)
	model.Parent = root

	local centerZ = (WarehouseConfig.Sector.FrontZ + WarehouseConfig.Sector.BackZ) * 0.5
	local length = WarehouseConfig.Sector.FrontZ - WarehouseConfig.Sector.BackZ
	local floor = makePart(
		model,
		"SectorFloor",
		Vector3.new(WarehouseConfig.Sector.Width, 0.08, length),
		CFrame.new(sector.CenterX, 0.11, centerZ),
		sector.Color,
		0.79
	)
	floor.CanCollide = false
	floor.CanTouch = false

	local freight = makePart(
		model,
		"MainFreightRoute",
		Vector3.new(WarehouseConfig.Sector.FreightLaneWidth, 0.09, length),
		CFrame.new(sector.CenterX, 0.15, centerZ),
		Color3.fromRGB(119, 126, 136),
		0.58
	)
	freight.CanCollide = false
	freight.CanTouch = false
	freight:SetAttribute("RouteType", "Freight")

	local signAnchor = makePart(
		model,
		"SectorSignAnchor",
		Vector3.new(1, 1, 1),
		CFrame.new(sector.CenterX, 1.1, 220),
		Color3.new(1, 1, 1),
		1
	)
	signAnchor.CanCollide = false
	signAnchor.CanTouch = false
	signAnchor.CanQuery = false
	addBillboard(signAnchor, "SectorLabel", sector.DisplayName, Color3.fromRGB(235, 238, 244), UDim2.fromOffset(220, 42), 100)

	-- Solid rack rows create partial occlusion and make the space read as a real
	-- warehouse without turning it into a maze. Cross-aisles interrupt the rows.
	for bandIndex, z in WarehouseConfig.RackBands do
		for sideIndex, side in { -1, 1 } do
			local rack = makePart(
				model,
				("Rack_%02d_%02d"):format(bandIndex, sideIndex),
				WarehouseConfig.Sector.RackSize,
				CFrame.new(sector.CenterX + side * WarehouseConfig.Sector.RackOffsetX, WarehouseConfig.Sector.RackSize.Y * 0.5, z),
				sector.Color:Lerp(Color3.fromRGB(45, 48, 55), 0.45),
				0.08
			)
			rack.Material = Enum.Material.Metal
			rack:SetAttribute("GrayboxRack", true)
		end
	end

	-- Zig-zag service route: shorter lateral cuts, but more direction changes than
	-- the straight freight lane. Geometry remains generous for mobile/camera use.
	local side = if sectorIndex % 2 == 0 then 1 else -1
	local shortcutFolder = Instance.new("Folder")
	shortcutFolder.Name = "ServiceShortcut"
	shortcutFolder.Parent = model
	local points = {
		Vector3.new(sector.CenterX + side * 26, 0, 211),
		Vector3.new(sector.CenterX + side * 34, 0, 157),
		Vector3.new(sector.CenterX - side * 27, 0, 124),
		Vector3.new(sector.CenterX + side * 30, 0, 34),
		Vector3.new(sector.CenterX - side * 24, 0, -63),
	}
	for index = 1, #points - 1 do
		local segment = laneBetween(
			shortcutFolder,
			("Shortcut_%02d"):format(index),
			points[index],
			points[index + 1],
			WarehouseConfig.Sector.ServiceLaneWidth,
			Color3.fromRGB(142, 121, 82),
			0.60
		)
		segment:SetAttribute("RouteType", "ServiceShortcut")
	end

	for opportunityIndex, opportunity in sector.Opportunities do
		buildOpportunity(spawnFolder, model, sectorKey, sector.Color, opportunityIndex, opportunity)
	end
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
	local ordered = { "General", "Appliances", "Furniture", "Industrial" }
	for index, key in ordered do
		buildSector(sectorFolder, spawnFolder, key, WarehouseConfig.Sectors[key], index)
	end

	local deepBoundary = makePart(
		gameplay,
		"DeepStorageBoundary",
		Vector3.new(570, 0.10, 5),
		CFrame.new(0, 0.16, -86),
		Color3.fromRGB(132, 99, 78),
		0.28
	)
	deepBoundary.CanCollide = false
	deepBoundary.CanTouch = false
	deepBoundary:SetAttribute("ReservedPurpose", "FutureDeeperStorage")
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
			addBillboard(marker, "StockSlotLabel", ("STOCK %d"):format(index), Color3.fromRGB(205, 224, 241), UDim2.fromOffset(115, 30), 40)
		end
	end

	local futureSell = makePart(bay, "FutureQuickSellAnchor", Vector3.new(1, 1, 1), bayCFrame * CFrame.new(-13.5, 1.0, -6.5), Color3.new(1, 1, 1), 1)
	futureSell.CanCollide = false
	futureSell.CanTouch = false
	futureSell.CanQuery = false
	futureSell:SetAttribute("ReservedPurpose", "Sell")

	local futureUpgrade = makePart(bay, "FutureBayUpgradeAnchor", Vector3.new(1, 1, 1), bayCFrame * CFrame.new(13.5, 1.0, 13.5), Color3.new(1, 1, 1), 1)
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
	local processing = makePart(bay, "ProcessingArea", config.ProcessingSize, bayCFrame * config.ProcessingOffset, Color3.fromRGB(76, 111, 94), 0.22)
	processing.CanCollide = false
	processing:SetAttribute("ReservedPurpose", "DeliveryProcessing")
	local unload = makePart(bay, "UnloadZone", config.UnloadSize, bayCFrame * config.UnloadOffset, Color3.fromRGB(84, 195, 122), 0.72)
	unload.CanCollide = false
	unload.CanTouch = true
	unload:SetAttribute("BayIndex", index)

	local processingLabel = makePart(bay, "ProcessingLabelAnchor", Vector3.new(1, 1, 1), bayCFrame * CFrame.new(0, 1.3, -7.4), Color3.new(1, 1, 1), 1)
	processingLabel.CanCollide = false
	processingLabel.CanTouch = false
	processingLabel.CanQuery = false
	addBillboard(processingLabel, "ProcessingLabel", "DELIVERY / PROCESSING", Color3.fromRGB(180, 255, 202), UDim2.fromOffset(200, 36), 50)

	buildStockSlots(bay, bayCFrame)

	local van = Instance.new("Model")
	van.Name = "Van"
	van.Parent = bay
	makePart(van, "Body", Vector3.new(12.5, 5.2, 8.2), bayCFrame * config.VanOffset, Color3.fromRGB(126, 132, 143))
	makePart(van, "Cab", Vector3.new(8.2, 4.2, 4.2), bayCFrame * config.VanOffset * CFrame.new(0, -0.25, -5.4), Color3.fromRGB(148, 154, 164))

	local spawnMarker = makePart(bay, "SpawnMarker", Vector3.new(1, 1, 1), bayCFrame * config.SpawnOffset, Color3.new(1, 1, 1), 1)
	spawnMarker.CanCollide = false
	spawnMarker.CanTouch = false
	spawnMarker.CanQuery = false
	local labelAnchor = makePart(bay, "OwnerLabelAnchor", Vector3.new(1, 1, 1), bayCFrame * config.OwnerLabelOffset, Color3.new(1, 1, 1), 1)
	labelAnchor.CanCollide = false
	labelAnchor.CanTouch = false
	labelAnchor.CanQuery = false
	local label = addBillboard(labelAnchor, "OwnerLabel", ("OPEN BAY %02d"):format(index), Color3.fromRGB(185, 193, 207), UDim2.fromOffset(240, 62), 95)
	label:SetAttribute("BayIndex", index)
	bay.PrimaryPart = pad
end

local function buildExpansionPoints(root: Folder)
	local folder = Instance.new("Folder")
	folder.Name = "FutureExpansionPoints"
	folder.Parent = root
	for index, cframe in WarehouseConfig.ExpansionPoints do
		local marker = makePart(folder, ("ExpansionPoint%02d"):format(index), Vector3.new(2, 2, 2), cframe, Color3.fromRGB(124, 104, 155), 1)
		marker.CanCollide = false
		marker.CanTouch = false
		marker.CanQuery = false
		marker:SetAttribute("ReservedPurpose", "FutureWarehouseAccess")
	end
end

function WorldService.Build(): Folder
	local previous = Workspace:FindFirstChild(ROOT_NAME)
	if previous then previous:Destroy() end
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then baseplate:Destroy() end

	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace

	local floor = makePart(root, "WarehouseFloor", WarehouseConfig.FootprintSize, CFrame.new(0, -0.5, 0), Color3.fromRGB(45, 48, 55))
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
	fallbackSpawn.CFrame = CFrame.lookAt(WarehouseConfig.FallbackSpawnPosition, WarehouseConfig.FallbackSpawnPosition + Vector3.new(0, 0, -1))
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
