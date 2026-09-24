--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MacroLayoutConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MacroLayoutConfig"))
local WarehouseConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("WarehouseConfig"))

local Service = {}
local ROOT_NAME = "OneTripPrototype"

local function makePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, transparency: number?): Part
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

local function addBillboard(adornee: BasePart, name: string, text: string, color: Color3?, size: UDim2?, maxDistance: number?): TextLabel
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

local function makeLabelAnchor(parent: Instance, name: string, position: Vector3, text: string, color: Color3, maxDistance: number?): BasePart
	local anchor = makePart(parent, name, Vector3.new(1, 1, 1), CFrame.new(position), Color3.new(1, 1, 1), 1)
	anchor.CanCollide = false
	anchor.CanQuery = false
	addBillboard(anchor, "Label", text, color, UDim2.fromOffset(300, 58), maxDistance or 125)
	return anchor
end

local function laneBetween(parent: Instance, name: string, a: Vector3, b: Vector3, width: number, color: Color3, transparency: number): Part
	local flatA = Vector3.new(a.X, 0.14, a.Z)
	local flatB = Vector3.new(b.X, 0.14, b.Z)
	local midpoint = (flatA + flatB) * 0.5
	local length = (flatB - flatA).Magnitude
	local part = makePart(parent, name, Vector3.new(width, 0.08, length), CFrame.lookAt(midpoint, flatB), color, transparency)
	part.CanCollide = false
	return part
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

local function buildBayAt(baysFolder: Folder, index: number, position: Vector3, lookTarget: Vector3)
	local config = WarehouseConfig.Bay
	local bayCFrame = CFrame.lookAt(position, lookTarget)
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

local function buildBays(root: Folder, config)
	local baysFolder = Instance.new("Folder")
	baysFolder.Name = "Bays"
	baysFolder.Parent = root

	local leftIndex = 1
	local rightIndex = 7
	for _, z in config.BayRowsZ do
		for _, x in { -config.BayOuterX, -config.BayInnerX } do
			buildBayAt(baysFolder, leftIndex, Vector3.new(x, 0, z), config.BayLookTarget)
			leftIndex += 1
		end
		for _, x in { config.BayInnerX, config.BayOuterX } do
			buildBayAt(baysFolder, rightIndex, Vector3.new(x, 0, z), config.BayLookTarget)
			rightIndex += 1
		end
	end
end

local function buildFallbackAndFeedback(root: Folder, position: Vector3)
	local fallbackSpawn = Instance.new("SpawnLocation")
	fallbackSpawn.Name = "FallbackSpawn"
	fallbackSpawn.Size = Vector3.new(6, 1, 6)
	fallbackSpawn.CFrame = CFrame.lookAt(position, Vector3.new(position.X, position.Y, position.Z - 1))
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

local function buildHomeApron(root: Folder, gameplay: Folder, config)
	local apron = makePart(
		root,
		"HomeApronFloor",
		config.HomeApronSize,
		CFrame.new(config.HomeApronCenter + Vector3.new(0, -config.HomeApronSize.Y * 0.5, 0)),
		Color3.fromRGB(52, 58, 68)
	)
	apron.Material = Enum.Material.Concrete

	local departure = makePart(
		gameplay,
		"SharedDepartureArea",
		Vector3.new(172, 0.10, 46),
		CFrame.new(0, 0.10, config.SharedDepartureZ),
		Color3.fromRGB(78, 88, 102),
		0.28
	)
	departure.CanCollide = false
	departure:SetAttribute("RouteType", "SharedDeparture")
	makeLabelAnchor(
		gameplay,
		"HomeLabelAnchor",
		Vector3.new(0, 1.2, config.SharedDepartureZ + 18),
		"HOME / DELIVERY  →  RUN DEEPER FOR BETTER CARGO",
		Color3.fromRGB(220, 232, 241),
		165
	)
end

local function makeSpawnMarker(spawnFolder: Folder, sectionId: string, index: number, position: Vector3, opportunityKind: string)
	local meta = MacroLayoutConfig.Sections[sectionId]
	local marker = makePart(
		spawnFolder,
		("M6D_%s_%02d"):format(sectionId, index),
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

local function sectionStructureSpec(sectionId: string): (Vector3, number, boolean, Enum.Material, string)
	if sectionId == "Receiving" then
		return Vector3.new(18, 1.2, 14), 0.35, false, Enum.Material.Concrete, "PalletCluster"
	elseif sectionId == "Appliances" then
		return Vector3.new(13, 9, 16), 0.16, true, Enum.Material.Metal, "ApplianceRow"
	elseif sectionId == "Furniture" then
		return Vector3.new(18, 2.0, 18), 0.32, true, Enum.Material.WoodPlanks, "FurnitureStage"
	elseif sectionId == "HeavyGoods" then
		return Vector3.new(14, 11, 16), 0.28, true, Enum.Material.Metal, "EquipmentCage"
	elseif sectionId == "Industrial" then
		return Vector3.new(16, 13, 18), 0.12, true, Enum.Material.Metal, "MachineBay"
	end
	return Vector3.new(14, 14, 16), 0.22, true, Enum.Material.Metal, "SecureCell"
end

local function buildSectionStructures(sectionModel: Model, sectionId: string, centerZ: number)
	local meta = MacroLayoutConfig.Sections[sectionId]
	local folder = Instance.new("Folder")
	folder.Name = "StorageStructures"
	folder.Parent = sectionModel
	local size, transparency, collides, material, kind = sectionStructureSpec(sectionId)
	local index = 0
	for _, side in { -1, 1 } do
		for _, zOffset in { 26, 0, -26 } do
			index += 1
			local part = makePart(
				folder,
				("%02d_%s"):format(index, kind),
				size,
				CFrame.new(76 * side, size.Y * 0.5, centerZ + zOffset),
				meta.Color:Lerp(Color3.fromRGB(48, 52, 59), 0.34),
				transparency
			)
			part.Material = material
			part.CanCollide = collides
			part:SetAttribute("GrayboxStructure", true)
			part:SetAttribute("StructureKind", kind)
			part:SetAttribute("SectorName", sectionId)
		end
	end
end

local function buildSectionIdentity(sectionModel: Model, sectionId: string, frontZ: number, runwayWidth: number)
	local meta = MacroLayoutConfig.Sections[sectionId]
	local identity = Instance.new("Folder")
	identity.Name = "SectionIdentity"
	identity.Parent = sectionModel
	for _, x in { -(runwayWidth * 0.5 - 7), runwayWidth * 0.5 - 7 } do
		local post = makePart(
			identity,
			("TransitionPost_%d"):format(math.floor(x)),
			Vector3.new(5, 14, 3),
			CFrame.new(x, 7, frontZ - 1),
			meta.Color:Lerp(Color3.fromRGB(46, 49, 55), 0.34),
			0.10
		)
		post.Material = Enum.Material.Metal
	end
	local beam = makePart(
		identity,
		"TransitionBeam",
		Vector3.new(runwayWidth - 18, 2.0, 2.5),
		CFrame.new(0, 13.5, frontZ - 1),
		meta.Color:Lerp(Color3.fromRGB(46, 49, 55), 0.34),
		0.14
	)
	beam.Material = Enum.Material.Metal
	beam.CanCollide = false
	makeLabelAnchor(identity, "SectionSignAnchor", Vector3.new(-61, 4.5, frontZ - 5), meta.DisplayName, Color3.fromRGB(235, 238, 244), 135)
end

local function markerLayout(centerZ: number): {{Position: Vector3, Kind: string}}
	return {
		{ Position = Vector3.new(-28, 0.18, centerZ + 30), Kind = "SharedFocal" },
		{ Position = Vector3.new(28, 0.18, centerZ + 30), Kind = "SharedFocal" },
		{ Position = Vector3.new(-54, 0.18, centerZ + 27), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(54, 0.18, centerZ + 27), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(-66, 0.18, centerZ + 15), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(66, 0.18, centerZ + 15), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(-45, 0.18, centerZ + 7), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(45, 0.18, centerZ + 7), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(-28, 0.18, centerZ - 2), Kind = "SharedStaging" },
		{ Position = Vector3.new(28, 0.18, centerZ - 2), Kind = "SharedStaging" },
		{ Position = Vector3.new(-66, 0.18, centerZ - 14), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(66, 0.18, centerZ - 14), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(-52, 0.18, centerZ - 25), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(52, 0.18, centerZ - 25), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(-38, 0.18, centerZ - 32), Kind = "StorageOpportunity" },
		{ Position = Vector3.new(38, 0.18, centerZ - 32), Kind = "StorageOpportunity" },
	}
end

local function buildSection(sectionsFolder: Folder, spawnFolder: Folder, routeFolder: Folder, sectionId: string, config)
	local meta = MacroLayoutConfig.Sections[sectionId]
	local centerZ = config.SectionCenters[sectionId]
	local frontZ = centerZ + config.SectionDepth * 0.5
	local backZ = centerZ - config.SectionDepth * 0.5

	local sectionModel = Instance.new("Model")
	sectionModel.Name = sectionId
	sectionModel:SetAttribute("SectorName", sectionId)
	sectionModel:SetAttribute("SectionIndex", meta.Index)
	sectionModel:SetAttribute("DisplayName", meta.DisplayName)
	sectionModel:SetAttribute("GrayboxStyle", "M6A1_SharedRunway")
	sectionModel:SetAttribute("FrontZ", frontZ)
	sectionModel:SetAttribute("BackZ", backZ)
	sectionModel:SetAttribute("CenterZ", centerZ)
	sectionModel.Parent = sectionsFolder

	local floor = makePart(sectionModel, "SectionFloor", Vector3.new(config.RunwayWidth, 0.08, config.SectionDepth), CFrame.new(0, 0.11, centerZ), meta.Color, 0.86)
	floor.CanCollide = false
	buildSectionIdentity(sectionModel, sectionId, frontZ, config.RunwayWidth)
	buildSectionStructures(sectionModel, sectionId, centerZ)

	local storageRoutes = Instance.new("Folder")
	storageRoutes.Name = "StoragePaths"
	storageRoutes.Parent = sectionModel
	for _, x in { -51, 51 } do
		local path = laneBetween(
			storageRoutes,
			if x < 0 then "LeftStoragePath" else "RightStoragePath",
			Vector3.new(x, 0, frontZ - 7),
			Vector3.new(x, 0, backZ + 7),
			config.StoragePathWidth,
			Color3.fromRGB(104, 109, 118),
			0.68
		)
		path:SetAttribute("RouteType", "StoragePath")
		path:SetAttribute("SectorName", sectionId)
	end

	local cross = laneBetween(
		routeFolder,
		("%s_CrossAisle"):format(sectionId),
		Vector3.new(-(config.RunwayWidth * 0.5 - 5), 0, centerZ),
		Vector3.new(config.RunwayWidth * 0.5 - 5, 0, centerZ),
		config.CrossAisleWidth,
		Color3.fromRGB(124, 130, 139),
		0.56
	)
	cross:SetAttribute("RouteType", "CrossAisle")
	cross:SetAttribute("SectorName", sectionId)

	local focalCount = 0
	local markers = markerLayout(centerZ)
	for index, markerSpec in markers do
		makeSpawnMarker(spawnFolder, sectionId, index, markerSpec.Position, markerSpec.Kind)
		if markerSpec.Kind == "SharedFocal" or markerSpec.Kind == "SharedStaging" then focalCount += 1 end
	end

	local root = sectionsFolder.Parent and sectionsFolder.Parent.Parent
	if root and root:IsA("Folder") then
		root:SetAttribute(("M6A1_%s_Markers"):format(sectionId), #markers)
		root:SetAttribute(("M6A1_%s_SharedFocal"):format(sectionId), focalCount)
		root:SetAttribute(("M6A1_%s_StorageMarkers"):format(sectionId), #markers - focalCount)
	end
end

local function buildWarehouseWalls(root: Folder, config)
	local wallColor = Color3.fromRGB(61, 65, 73)
	local wallY = config.WallHeight * 0.5
	local runwayCenterZ = (config.RunwayFrontZ + config.RunwayBackZ) * 0.5
	local runwayLength = config.RunwayFrontZ - config.RunwayBackZ
	local halfRunway = config.RunwayWidth * 0.5

	makePart(root, "RunwayWestWall", Vector3.new(1.5, config.WallHeight, runwayLength), CFrame.new(-halfRunway, wallY, runwayCenterZ), wallColor)
	makePart(root, "RunwayEastWall", Vector3.new(1.5, config.WallHeight, runwayLength), CFrame.new(halfRunway, wallY, runwayCenterZ), wallColor)
	makePart(root, "SecureBackWall", Vector3.new(config.RunwayWidth, config.WallHeight, 1.5), CFrame.new(0, wallY, config.RunwayBackZ), wallColor)

	local apronHalfX = config.HomeApronSize.X * 0.5
	local apronHalfZ = config.HomeApronSize.Z * 0.5
	local apronNorth = config.HomeApronCenter.Z + apronHalfZ
	local apronSouth = config.HomeApronCenter.Z - apronHalfZ
	makePart(root, "ApronWestWall", Vector3.new(1.5, config.WallHeight, config.HomeApronSize.Z), CFrame.new(-apronHalfX, wallY, config.HomeApronCenter.Z), wallColor)
	makePart(root, "ApronEastWall", Vector3.new(1.5, config.WallHeight, config.HomeApronSize.Z), CFrame.new(apronHalfX, wallY, config.HomeApronCenter.Z), wallColor)
	makePart(root, "ApronFrontWall", Vector3.new(config.HomeApronSize.X, config.WallHeight, 1.5), CFrame.new(0, wallY, apronNorth), wallColor)

	local wingWidth = apronHalfX - halfRunway
	if wingWidth > 1 then
		local leftCenterX = -(halfRunway + wingWidth * 0.5)
		local rightCenterX = halfRunway + wingWidth * 0.5
		makePart(root, "ApronMouthLeftWing", Vector3.new(wingWidth, config.WallHeight, 1.5), CFrame.new(leftCenterX, wallY, apronSouth), wallColor)
		makePart(root, "ApronMouthRightWing", Vector3.new(wingWidth, config.WallHeight, 1.5), CFrame.new(rightCenterX, wallY, apronSouth), wallColor)
	end
end

local function buildExpansionMarkers(root: Folder, config)
	local folder = Instance.new("Folder")
	folder.Name = "FutureExpansionPoints"
	folder.Parent = root
	for index, x in { -56, 0, 56 } do
		local marker = makePart(folder, ("ExpansionPoint%02d"):format(index), Vector3.new(2, 2, 2), CFrame.new(x, 1, config.RunwayBackZ - 18), Color3.fromRGB(124, 104, 155), 1)
		marker.CanCollide = false
		marker.CanQuery = false
		marker:SetAttribute("ReservedPurpose", "FutureRunwayExtensionOrAnnex")
	end
end

local function publishMetrics(root: Folder, config)
	root:SetAttribute("MacroLayoutMode", "D")
	root:SetAttribute("M6A_Mode", "D")
	root:SetAttribute("M6A_LayoutName", config.Name)
	root:SetAttribute("M6A_TestStatus", "M6A.1 RUNTIME PLAYTEST REQUIRED")
	root:SetAttribute("M6A_SectionCount", #MacroLayoutConfig.SectionOrder)
	root:SetAttribute("M6A1_RunwayWidth", config.RunwayWidth)
	root:SetAttribute("M6A1_RunwayLength", config.RunwayLength)
	root:SetAttribute("M6A1_SectionDepth", config.SectionDepth)
	root:SetAttribute("M6A1_FreightWidth", config.FreightWidth)
	root:SetAttribute("M6A1_CrossAisleWidth", config.CrossAisleWidth)
	root:SetAttribute("M6A1_HomeApronWidth", config.HomeApronSize.X)
	root:SetAttribute("M6A1_HomeApronDepth", config.HomeApronSize.Z)
	root:SetAttribute("M6A1_TotalSpawnMarkers", #MacroLayoutConfig.SectionOrder * config.MarkersPerSection)
	root:SetAttribute("M6A1_SharedFocalMarkers", #MacroLayoutConfig.SectionOrder * config.SharedFocalMarkersPerSection)

	for _, sectionId in MacroLayoutConfig.SectionOrder do
		local centerZ = config.SectionCenters[sectionId]
		local distance = math.abs(config.HomeReferenceZ - centerZ)
		root:SetAttribute(("M6A_%s_DistanceStuds"):format(sectionId), distance)
		root:SetAttribute(("M6A_%s_UnloadedEstimate16s"):format(sectionId), distance / 16)
		root:SetAttribute(("M6A_%s_UnloadedEstimate25s"):format(sectionId), distance / 25)
		root:SetAttribute(("M6A1_%s_LoadedEstimate12s"):format(sectionId), distance / 12)
		root:SetAttribute(("M6A1_%s_LoadedEstimate9_5s"):format(sectionId), distance / 9.5)
	end
end

function Service.Build(): Folder
	local config = MacroLayoutConfig.OptionD
	local root = resetWorld()

	local gameplay = Instance.new("Folder")
	gameplay.Name = "WarehouseGameplay"
	gameplay.Parent = root
	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root

	buildHomeApron(root, gameplay, config)
	local runwayFloor = makePart(
		root,
		"WarehouseFloor",
		Vector3.new(config.RunwayWidth, 1, config.RunwayLength),
		CFrame.new(0, -0.5, (config.RunwayFrontZ + config.RunwayBackZ) * 0.5),
		Color3.fromRGB(45, 48, 55)
	)
	runwayFloor.Material = Enum.Material.Concrete

	local routeFolder = Instance.new("Folder")
	routeFolder.Name = "RouteNetwork"
	routeFolder.Parent = gameplay
	local freight = laneBetween(
		routeFolder,
		"MainSharedFreightAisle",
		Vector3.new(0, 0, config.RunwayFrontZ),
		Vector3.new(0, 0, config.RunwayBackZ + 4),
		config.FreightWidth,
		Color3.fromRGB(119, 126, 136),
		0.44
	)
	freight:SetAttribute("RouteType", "Freight")
	freight:SetAttribute("SharedRoute", true)

	local sectionsFolder = Instance.new("Folder")
	sectionsFolder.Name = "Sections"
	sectionsFolder.Parent = gameplay
	for _, sectionId in MacroLayoutConfig.SectionOrder do
		buildSection(sectionsFolder, spawnFolder, routeFolder, sectionId, config)
	end

	buildBays(root, config)
	buildWarehouseWalls(root, config)
	buildExpansionMarkers(root, config)
	buildFallbackAndFeedback(root, config.FallbackSpawnPosition)
	publishMetrics(root, config)
	return root
end

return Service
