--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MacroLayoutConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MacroLayoutConfig"))
local WarehouseConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("WarehouseConfig"))
local LegacyWorldService = require(script.Parent:WaitForChild("WorldService"))

local M6WorldService = {}
local ROOT_NAME = "OneTripPrototype"

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	transparency: number?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = true
	part.CanTouch = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = color
	part.Transparency = transparency or 0
	part.Parent = parent
	return part
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
	return part
end

local function makeLabelAnchor(
	parent: Instance,
	name: string,
	position: Vector3,
	text: string,
	color: Color3,
	maxDistance: number?
): BasePart
	local anchor = makePart(parent, name, Vector3.new(1, 1, 1), CFrame.new(position), Color3.new(1, 1, 1), 1)
	anchor.CanCollide = false
	anchor.CanQuery = false
	addBillboard(anchor, "Label", text, color, UDim2.fromOffset(300, 58), maxDistance or 125)
	return anchor
end

local function angleDirection(degrees: number): Vector3
	local radians = math.rad(degrees)
	return Vector3.new(math.cos(radians), 0, math.sin(radians))
end

local function resetWorld(): Folder
	local previous = Workspace:FindFirstChild(ROOT_NAME)
	if previous then previous:Destroy() end
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then baseplate:Destroy() end
	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace
	return root
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
		marker.CanQuery = activeByDefault
		marker:SetAttribute("StockSlotIndex", index)
		marker:SetAttribute("ActiveByDefault", activeByDefault)
		marker:SetAttribute("ReservedForExpansion", true)
		if activeByDefault then
			addBillboard(marker, "StockSlotLabel", ("STOCK %d"):format(index), Color3.fromRGB(205, 224, 241), UDim2.fromOffset(115, 30), 40)
		end
	end

	local futureSell = makePart(bay, "FutureQuickSellAnchor", Vector3.new(1, 1, 1), bayCFrame * CFrame.new(-13.5, 1, -6.5), Color3.new(1, 1, 1), 1)
	futureSell.CanCollide = false
	futureSell.CanQuery = false
	futureSell:SetAttribute("ReservedPurpose", "Sell")

	local futureUpgrade = makePart(bay, "FutureBayUpgradeAnchor", Vector3.new(1, 1, 1), bayCFrame * CFrame.new(13.5, 1, 13.5), Color3.new(1, 1, 1), 1)
	futureUpgrade.CanCollide = false
	futureUpgrade.CanQuery = false
	futureUpgrade:SetAttribute("ReservedPurpose", "BayUpgrade")
end

local function buildBayAt(baysFolder: Folder, index: number, bayCFrame: CFrame)
	local config = WarehouseConfig.Bay
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

	local processingAnchor = makePart(bay, "ProcessingLabelAnchor", Vector3.new(1, 1, 1), bayCFrame * CFrame.new(0, 1.3, -7.4), Color3.new(1, 1, 1), 1)
	processingAnchor.CanCollide = false
	processingAnchor.CanQuery = false
	addBillboard(processingAnchor, "ProcessingLabel", "DELIVERY / PROCESSING", Color3.fromRGB(180, 255, 202), UDim2.fromOffset(200, 36), 50)

	buildStockSlots(bay, bayCFrame)

	local van = Instance.new("Model")
	van.Name = "Van"
	van.Parent = bay
	makePart(van, "Body", Vector3.new(12.5, 5.2, 8.2), bayCFrame * config.VanOffset, Color3.fromRGB(126, 132, 143))
	makePart(van, "Cab", Vector3.new(8.2, 4.2, 4.2), bayCFrame * config.VanOffset * CFrame.new(0, -0.25, -5.4), Color3.fromRGB(148, 154, 164))

	local spawnMarker = makePart(bay, "SpawnMarker", Vector3.new(1, 1, 1), bayCFrame * config.SpawnOffset, Color3.new(1, 1, 1), 1)
	spawnMarker.CanCollide = false
	spawnMarker.CanQuery = false

	local ownerAnchor = makePart(bay, "OwnerLabelAnchor", Vector3.new(1, 1, 1), bayCFrame * config.OwnerLabelOffset, Color3.new(1, 1, 1), 1)
	ownerAnchor.CanCollide = false
	ownerAnchor.CanQuery = false
	local label = addBillboard(ownerAnchor, "OwnerLabel", ("OPEN BAY %02d"):format(index), Color3.fromRGB(185, 193, 207), UDim2.fromOffset(240, 62), 95)
	label:SetAttribute("BayIndex", index)
	bay.PrimaryPart = pad
end

local function buildFallbackAndFeedback(root: Folder, position: Vector3)
	local fallbackSpawn = Instance.new("SpawnLocation")
	fallbackSpawn.Name = "FallbackSpawn"
	fallbackSpawn.Size = Vector3.new(6, 1, 6)
	fallbackSpawn.CFrame = CFrame.lookAt(position, position + Vector3.new(0, 0, -1))
	fallbackSpawn.Anchored = true
	fallbackSpawn.CanCollide = false
	fallbackSpawn.Neutral = true
	fallbackSpawn.Duration = 0
	fallbackSpawn.Transparency = 1
	fallbackSpawn.Parent = root

	local feedback = Instance.new("Folder")
	feedback.Name = "Feedback"
	feedback.Parent = root
end

local function makeSpawnMarker(
	spawnFolder: Folder,
	sectionId: string,
	index: number,
	position: Vector3,
	opportunityKind: string
)
	local meta = MacroLayoutConfig.Sections[sectionId]
	local marker = makePart(
		spawnFolder,
		("M6_%s_%02d"):format(sectionId, index),
		Vector3.new(1.2, 0.08, 1.2),
		CFrame.new(position + Vector3.new(0, 0.04, 0)),
		Color3.fromRGB(126, 132, 143),
		1
	)
	marker.CanCollide = false
	marker.CanQuery = false
	marker:SetAttribute("ItemId", meta.FallbackItemId)
	marker:SetAttribute("ZoneName", meta.DisplayName)
	marker:SetAttribute("ZoneDepth", meta.Depth)
	marker:SetAttribute("SectorName", sectionId)
	marker:SetAttribute("SectionIndex", meta.Index)
	marker:SetAttribute("SectionDisplayName", meta.DisplayName)
	marker:SetAttribute("OpportunityName", marker.Name)
	marker:SetAttribute("OpportunityKind", opportunityKind)
	marker:SetAttribute("RestockSeconds", 1.8)
end

local function buildSectionSign(sectionModel: Model, sectionId: string, position: Vector3)
	local meta = MacroLayoutConfig.Sections[sectionId]
	local identity = Instance.new("Folder")
	identity.Name = "SectionIdentity"
	identity.Parent = sectionModel
	makeLabelAnchor(identity, "SectionSignAnchor", position, meta.DisplayName, Color3.fromRGB(235, 238, 244), 145)
end

local function buildRectangularWalls(root: Folder, footprint: Vector3, height: number)
	local wallColor = Color3.fromRGB(62, 65, 73)
	local halfX = footprint.X * 0.5
	local halfZ = footprint.Z * 0.5
	local y = height * 0.5
	makePart(root, "NorthWall", Vector3.new(footprint.X, height, 1), CFrame.new(0, y, halfZ), wallColor)
	makePart(root, "SouthWall", Vector3.new(footprint.X, height, 1), CFrame.new(0, y, -halfZ), wallColor)
	makePart(root, "WestWall", Vector3.new(1, height, footprint.Z), CFrame.new(-halfX, y, 0), wallColor)
	makePart(root, "EastWall", Vector3.new(1, height, footprint.Z), CFrame.new(halfX, y, 0), wallColor)
end

local function buildSpineStructure(sectionModel: Model, sectionId: string, index: number, position: Vector3)
	local meta = MacroLayoutConfig.Sections[sectionId]
	local folder = sectionModel:FindFirstChild("StorageStructures") :: Folder?
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "StorageStructures"
		folder.Parent = sectionModel
	end

	local kind = "Rack"
	local size = Vector3.new(16, 10, 18)
	local material = Enum.Material.Metal
	local transparency = 0.18
	local collides = true
	if sectionId == "Receiving" then
		kind = "PalletStaging"
		size = Vector3.new(24, 1.2, 16)
		material = Enum.Material.Concrete
		transparency = 0.35
		collides = false
	elseif sectionId == "Appliances" then
		kind = "ApplianceRow"
		size = Vector3.new(20, 9, 18)
	elseif sectionId == "Furniture" then
		kind = "FurnitureStage"
		size = Vector3.new(28, 1.0, 24)
		material = Enum.Material.WoodPlanks
		transparency = 0.38
		collides = false
	elseif sectionId == "HeavyGoods" then
		kind = "EquipmentCage"
		size = Vector3.new(20, 11, 20)
		transparency = 0.28
	elseif sectionId == "Industrial" then
		kind = "MachineBay"
		size = Vector3.new(22, 13, 22)
		transparency = 0.12
	elseif sectionId == "Secure" then
		kind = "SecureCell"
		size = Vector3.new(22, 14, 20)
		transparency = 0.22
	end

	local part = makePart(
		folder,
		("%02d_%s"):format(index, kind),
		size,
		CFrame.new(position.X, size.Y * 0.5, position.Z),
		meta.Color:Lerp(Color3.fromRGB(50, 53, 60), 0.35),
		transparency
	)
	part.Material = material
	part.CanCollide = collides
	part:SetAttribute("GrayboxStructure", true)
	part:SetAttribute("StructureKind", kind)
	part:SetAttribute("SectorName", sectionId)
end

local function buildOptionB(root: Folder)
	local config = MacroLayoutConfig.OptionB
	root:SetAttribute("MacroLayoutMode", "B")
	root:SetAttribute("M6A_LayoutName", config.Name)
	root:SetAttribute("M6A_FootprintX", config.Footprint.X)
	root:SetAttribute("M6A_FootprintZ", config.Footprint.Z)
	root:SetAttribute("M6A_FreightWidth", config.FreightWidth)

	local floor = makePart(root, "WarehouseFloor", config.Footprint, CFrame.new(0, -0.5, 0), Color3.fromRGB(45, 48, 55))
	floor.Material = Enum.Material.Concrete

	local gameplay = Instance.new("Folder")
	gameplay.Name = "WarehouseGameplay"
	gameplay.Parent = root
	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root

	local hub = makePart(gameplay, "CentralDispatch", config.HubSize, CFrame.new(config.HubCenter), Color3.fromRGB(66, 72, 82), 0.08)
	hub.CanCollide = false
	hub.Material = Enum.Material.Concrete
	makeLabelAnchor(gameplay, "DispatchLabelAnchor", config.HubCenter + Vector3.new(0, 1.2, 22), "DELIVERY / SOCIAL HUB", Color3.fromRGB(216, 226, 237), 145)

	local routeFolder = Instance.new("Folder")
	routeFolder.Name = "RouteNetwork"
	routeFolder.Parent = gameplay
	local freight = laneBetween(routeFolder, "MainFreightSpine", Vector3.new(0, 0, config.FreightStartZ), Vector3.new(0, 0, config.FreightEndZ), config.FreightWidth, Color3.fromRGB(119, 126, 136), 0.45)
	freight:SetAttribute("RouteType", "Freight")

	for sideIndex, side in { -1, 1 } do
		local serviceFolder = Instance.new("Folder")
		serviceFolder.Name = if side < 0 then "LeftServiceRoute" else "RightServiceRoute"
		serviceFolder.Parent = routeFolder
		local x = 132 * side
		local points = {
			Vector3.new(x, 0, 300),
			Vector3.new((x + 26 * side), 0, 180),
			Vector3.new((x - 18 * side), 0, 55),
			Vector3.new((x + 24 * side), 0, -80),
			Vector3.new(x, 0, -245),
		}
		for i = 1, #points - 1 do
			local segment = laneBetween(serviceFolder, ("Segment_%02d"):format(i), points[i], points[i + 1], config.ServiceWidth, Color3.fromRGB(145, 122, 82), 0.58)
			segment:SetAttribute("RouteType", "ServiceShortcut")
		end
	end

	local sectionsFolder = Instance.new("Folder")
	sectionsFolder.Name = "Sections"
	sectionsFolder.Parent = gameplay
	for _, sectionId in MacroLayoutConfig.SectionOrder do
		local meta = MacroLayoutConfig.Sections[sectionId]
		local centerZ = config.SectionCenters[sectionId]
		local sectionModel = Instance.new("Model")
		sectionModel.Name = sectionId
		sectionModel:SetAttribute("SectorName", sectionId)
		sectionModel:SetAttribute("SectionIndex", meta.Index)
		sectionModel:SetAttribute("DisplayName", meta.DisplayName)
		sectionModel:SetAttribute("GrayboxStyle", "M6A_LongSpine")
		sectionModel.Parent = sectionsFolder

		local sectionFloor = makePart(sectionModel, "SectionFloor", Vector3.new(config.SectionWidth, 0.08, config.SectionDepth), CFrame.new(0, 0.11, centerZ), meta.Color, 0.88)
		sectionFloor.CanCollide = false
		buildSectionSign(sectionModel, sectionId, Vector3.new(-190, 4.5, centerZ + config.SectionDepth * 0.40))

		local cross = laneBetween(sectionModel, "SectionCrossLane", Vector3.new(-205, 0, centerZ), Vector3.new(205, 0, centerZ), 18, Color3.fromRGB(104, 109, 118), 0.62)
		cross:SetAttribute("RouteType", "CrossAisle")
		cross:SetAttribute("SectorName", sectionId)

		local positions = {
			Vector3.new(-180, 0.18, centerZ + 26), Vector3.new(-105, 0.18, centerZ + 24),
			Vector3.new(-58, 0.18, centerZ + 19), Vector3.new(58, 0.18, centerZ + 21),
			Vector3.new(105, 0.18, centerZ + 25), Vector3.new(180, 0.18, centerZ + 24),
			Vector3.new(-168, 0.18, centerZ + 3), Vector3.new(-72, 0.18, centerZ + 6),
			Vector3.new(72, 0.18, centerZ + 4), Vector3.new(168, 0.18, centerZ + 2),
			Vector3.new(-180, 0.18, centerZ - 25), Vector3.new(-105, 0.18, centerZ - 24),
			Vector3.new(-58, 0.18, centerZ - 18), Vector3.new(58, 0.18, centerZ - 20),
			Vector3.new(105, 0.18, centerZ - 26), Vector3.new(180, 0.18, centerZ - 24),
		}
		for index, position in positions do
			local greed = math.abs(position.X) <= 72 and math.abs(position.Z - centerZ) >= 16
			makeSpawnMarker(spawnFolder, sectionId, index, position, if greed then "GreedSightline" else "StorageOpportunity")
			if index % 2 == 1 then
				local structureX = position.X + (if position.X < 0 then -16 else 16)
				buildSpineStructure(sectionModel, sectionId, index, Vector3.new(structureX, 0, position.Z))
			end
		end

		root:SetAttribute(("M6A_%s_DistanceStuds"):format(sectionId), math.abs(config.HubCenter.Z - centerZ))
	end

	local baysFolder = Instance.new("Folder")
	baysFolder.Name = "Bays"
	baysFolder.Parent = root
	for index = 1, 12 do
		local x = config.BayStartX + (index - 1) * config.BaySpacing
		buildBayAt(baysFolder, index, CFrame.lookAt(Vector3.new(x, 0, config.BayZ), Vector3.new(x, 0, config.BayZ - 1)))
	end

	buildFallbackAndFeedback(root, config.FallbackSpawnPosition)
	buildRectangularWalls(root, config.Footprint, config.WallHeight)
end

local function radialStructureSpec(sectionId: string): (Vector3, number, boolean, Enum.Material, string)
	if sectionId == "Receiving" then
		return Vector3.new(18, 1.2, 10), 0.36, false, Enum.Material.Concrete, "PalletCluster"
	elseif sectionId == "Appliances" then
		return Vector3.new(14, 9, 12), 0.16, true, Enum.Material.Metal, "ApplianceRow"
	elseif sectionId == "Furniture" then
		return Vector3.new(24, 1.0, 16), 0.38, false, Enum.Material.WoodPlanks, "FurnitureStage"
	elseif sectionId == "HeavyGoods" then
		return Vector3.new(15, 11, 14), 0.28, true, Enum.Material.Metal, "EquipmentCage"
	elseif sectionId == "Industrial" then
		return Vector3.new(17, 14, 15), 0.12, true, Enum.Material.Metal, "MachineBay"
	end
	return Vector3.new(16, 15, 14), 0.22, true, Enum.Material.Metal, "SecureVaultCell"
end

local function buildRadialStructure(sectionModel: Model, sectionId: string, index: number, position: Vector3, degrees: number)
	local folder = sectionModel:FindFirstChild("StorageStructures") :: Folder?
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "StorageStructures"
		folder.Parent = sectionModel
	end
	local size, transparency, collides, material, kind = radialStructureSpec(sectionId)
	local radial = angleDirection(degrees)
	local tangent = Vector3.new(-radial.Z, 0, radial.X)
	local offset = tangent * (if index % 4 < 2 then 16 else -16)
	local place = position + offset
	local part = makePart(
		folder,
		("%02d_%s"):format(index, kind),
		size,
		CFrame.lookAt(Vector3.new(place.X, size.Y * 0.5, place.Z), Vector3.new(place.X, size.Y * 0.5, place.Z) + radial),
		MacroLayoutConfig.Sections[sectionId].Color:Lerp(Color3.fromRGB(50, 53, 60), 0.36),
		transparency
	)
	part.Material = material
	part.CanCollide = collides
	part:SetAttribute("GrayboxStructure", true)
	part:SetAttribute("StructureKind", kind)
	part:SetAttribute("SectorName", sectionId)
end

local function buildPolygonWall(root: Folder, radius: number, sides: number, height: number)
	local folder = Instance.new("Folder")
	folder.Name = "OuterWarehouseWall"
	folder.Parent = root
	local chord = 2 * radius * math.sin(math.pi / sides) + 5
	for index = 1, sides do
		local degrees = (index - 1) * (360 / sides)
		local radial = angleDirection(degrees)
		local position = radial * radius
		local wall = makePart(
			folder,
			("Wall_%02d"):format(index),
			Vector3.new(chord, height, 1.5),
			CFrame.lookAt(Vector3.new(position.X, height * 0.5, position.Z), Vector3.new(position.X, height * 0.5, position.Z) + radial),
			Color3.fromRGB(62, 65, 73),
			0.02
		)
		wall.Material = Enum.Material.Metal
	end
end

local function buildOptionC(root: Folder)
	local config = MacroLayoutConfig.OptionC
	root:SetAttribute("MacroLayoutMode", "C")
	root:SetAttribute("M6A_LayoutName", config.Name)
	root:SetAttribute("M6A_FootprintX", config.Footprint.X)
	root:SetAttribute("M6A_FootprintZ", config.Footprint.Z)
	root:SetAttribute("M6A_HubRadius", config.HubRadius)
	root:SetAttribute("M6A_OuterRadius", config.OuterRadius)
	root:SetAttribute("M6A_FreightWidth", config.FreightWidth)
	root:SetAttribute("M6A_PolygonSides", config.PolygonSides)

	local baseFloor = makePart(root, "WarehouseFloor", config.Footprint, CFrame.new(0, -0.55, 0), Color3.fromRGB(42, 45, 51))
	baseFloor.Material = Enum.Material.Concrete

	local gameplay = Instance.new("Folder")
	gameplay.Name = "WarehouseGameplay"
	gameplay.Parent = root
	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root

	local hub = makePart(
		gameplay,
		"CentralHub",
		Vector3.new(0.16, config.HubRadius * 2, config.HubRadius * 2),
		CFrame.new(0, 0.10, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(65, 73, 84),
		0.06
	)
	hub.Shape = Enum.PartType.Cylinder
	hub.CanCollide = false
	hub.Material = Enum.Material.Concrete
	makeLabelAnchor(gameplay, "CentralHubLabelAnchor", Vector3.new(0, 1.2, 0), "ONE TRIP DISPATCH / HOME", Color3.fromRGB(220, 232, 241), 150)

	local routeFolder = Instance.new("Folder")
	routeFolder.Name = "RouteNetwork"
	routeFolder.Parent = gameplay
	local freightFolder = Instance.new("Folder")
	freightFolder.Name = "FreightSpokes"
	freightFolder.Parent = routeFolder
	for index, degrees in config.SpokeAnglesDegrees do
		local radial = angleDirection(degrees)
		local segment = laneBetween(
			freightFolder,
			("FreightSpoke_%02d"):format(index),
			radial * (config.HubRadius - 5),
			radial * config.OuterRadius,
			config.FreightWidth,
			Color3.fromRGB(119, 126, 136),
			0.44
		)
		segment:SetAttribute("RouteType", "Freight")
	end

	local serviceFolder = Instance.new("Folder")
	serviceFolder.Name = "ServiceCuts"
	serviceFolder.Parent = routeFolder
	for index, degrees in config.ServiceAnglesDegrees do
		local outerDirection = angleDirection(degrees - 11)
		local innerDirection = angleDirection(degrees + 8)
		local segment = laneBetween(
			serviceFolder,
			("ServiceCut_%02d"):format(index),
			outerDirection * 472,
			innerDirection * 146,
			config.ServiceWidth,
			Color3.fromRGB(145, 122, 82),
			0.58
		)
		segment:SetAttribute("RouteType", "ServiceShortcut")
	end

	local sectionsFolder = Instance.new("Folder")
	sectionsFolder.Name = "Sections"
	sectionsFolder.Parent = gameplay
	local sideStep = 360 / config.PolygonSides
	for _, sectionId in MacroLayoutConfig.SectionOrder do
		local meta = MacroLayoutConfig.Sections[sectionId]
		local ring = config.Rings[sectionId]
		local centerRadius = (ring.Inner + ring.Outer) * 0.5
		local radialWidth = ring.Outer - ring.Inner
		local chord = 2 * centerRadius * math.sin(math.pi / config.PolygonSides) + 5

		local sectionModel = Instance.new("Model")
		sectionModel.Name = sectionId
		sectionModel:SetAttribute("SectorName", sectionId)
		sectionModel:SetAttribute("SectionIndex", meta.Index)
		sectionModel:SetAttribute("DisplayName", meta.DisplayName)
		sectionModel:SetAttribute("GrayboxStyle", "M6A_PolygonRing")
		sectionModel:SetAttribute("InnerRadius", ring.Inner)
		sectionModel:SetAttribute("OuterRadius", ring.Outer)
		sectionModel.Parent = sectionsFolder

		local ringFloorFolder = Instance.new("Folder")
		ringFloorFolder.Name = "RingFloor"
		ringFloorFolder.Parent = sectionModel
		for segmentIndex = 1, config.PolygonSides do
			local degrees = (segmentIndex - 1) * sideStep
			local radial = angleDirection(degrees)
			local position = radial * centerRadius
			local segment = makePart(
				ringFloorFolder,
				("RingSegment_%02d"):format(segmentIndex),
				Vector3.new(chord, 0.08, radialWidth),
				CFrame.lookAt(Vector3.new(position.X, 0.11, position.Z), Vector3.new(position.X, 0.11, position.Z) + radial),
				meta.Color,
				0.86
			)
			segment.CanCollide = false
			segment:SetAttribute("SectorName", sectionId)
		end

		buildSectionSign(sectionModel, sectionId, angleDirection(90) * (ring.Inner + 6) + Vector3.new(0, 4.5, 0))

		local markerIndex = 0
		for spokeIndex, spokeDegrees in config.SpokeAnglesDegrees do
			local clusterPositions = {}
			for offsetIndex, angleOffset in { -17, -6, 6, 17 } do
				markerIndex += 1
				local degrees = spokeDegrees + angleOffset
				local radiusOffset = ({ -8, 9, -2, 12 })[offsetIndex]
				local radius = centerRadius + radiusOffset
				local position = angleDirection(degrees) * radius + Vector3.new(0, 0.18, 0)
				table.insert(clusterPositions, position)
				local kind = if math.abs(angleOffset) <= 6 then "GreedSightline" else "StorageArcOpportunity"
				makeSpawnMarker(spawnFolder, sectionId, markerIndex, position, kind)
				if markerIndex % 2 == 1 then buildRadialStructure(sectionModel, sectionId, markerIndex, position, degrees) end
			end
			local arcFolder = sectionModel:FindFirstChild("StorageArcs") :: Folder?
			if not arcFolder then
				arcFolder = Instance.new("Folder")
				arcFolder.Name = "StorageArcs"
				arcFolder.Parent = sectionModel
			end
			for i = 1, #clusterPositions - 1 do
				local arc = laneBetween(arcFolder, ("Spoke%02d_Arc_%02d"):format(spokeIndex, i), clusterPositions[i], clusterPositions[i + 1], 16, Color3.fromRGB(104, 109, 118), 0.63)
				arc:SetAttribute("RouteType", "StorageArc")
				arc:SetAttribute("SectorName", sectionId)
			end
		end

		root:SetAttribute(("M6A_%s_InnerRadius"):format(sectionId), ring.Inner)
		root:SetAttribute(("M6A_%s_OuterRadius"):format(sectionId), ring.Outer)
		root:SetAttribute(("M6A_%s_DistanceStuds"):format(sectionId), centerRadius)
	end

	local baysFolder = Instance.new("Folder")
	baysFolder.Name = "Bays"
	baysFolder.Parent = root
	for index = 1, 12 do
		local degrees = 15 + (index - 1) * 30
		local outward = angleDirection(degrees)
		local position = outward * config.BayRadius
		buildBayAt(baysFolder, index, CFrame.lookAt(position, position + outward))
	end

	local expansionFolder = Instance.new("Folder")
	expansionFolder.Name = "FutureExpansionPoints"
	expansionFolder.Parent = root
	for index, degrees in config.SpokeAnglesDegrees do
		local radial = angleDirection(degrees)
		local point = makePart(expansionFolder, ("ExpansionPoint%02d"):format(index), Vector3.new(2, 2, 2), CFrame.new(radial * (config.OuterRadius + 28)), Color3.fromRGB(124, 104, 155), 1)
		point.CanCollide = false
		point.CanQuery = false
		point:SetAttribute("ReservedPurpose", "FutureOuterRingOrAnnex")
	end

	buildFallbackAndFeedback(root, config.FallbackSpawnPosition)
	buildPolygonWall(root, config.OuterRadius + 12, config.PolygonSides, config.WallHeight)
end

local function publishCommonMetrics(root: Folder, mode: string)
	root:SetAttribute("M6A_Mode", mode)
	root:SetAttribute("M6A_SectionCount", #MacroLayoutConfig.SectionOrder)
	root:SetAttribute("M6A_TestStatus", "RUNTIME PLAYTEST REQUIRED")
	for _, sectionId in MacroLayoutConfig.SectionOrder do
		local distance = tonumber(root:GetAttribute(("M6A_%s_DistanceStuds"):format(sectionId))) or 0
		root:SetAttribute(("M6A_%s_UnloadedEstimate16s"):format(sectionId), distance / 16)
		root:SetAttribute(("M6A_%s_UnloadedEstimate25s"):format(sectionId), distance / 25)
	end
end

function M6WorldService.Build(): Folder
	local requested = Workspace:GetAttribute("M6LayoutMode")
	local mode = MacroLayoutConfig.ResolveMode(requested)
	if mode == "A" then
		local root = LegacyWorldService.Build()
		root:SetAttribute("MacroLayoutMode", "A")
		root:SetAttribute("M6A_LayoutName", MacroLayoutConfig.OptionA.Name)
		root:SetAttribute("M6A_Mode", "A")
		root:SetAttribute("M6A_TestStatus", "BASELINE RUNTIME PLAYTEST REQUIRED")
		return root
	end

	local root = resetWorld()
	if mode == "B" then
		buildOptionB(root)
	else
		buildOptionC(root)
	end
	publishCommonMetrics(root, mode)
	return root
end

return M6WorldService
