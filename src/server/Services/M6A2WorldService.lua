--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MacroLayoutConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MacroLayoutConfig"))
local SectionConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("SectionConfig"))
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

local function addBillboard(adornee: BasePart, name: string, text: string, color: Color3?, maxDistance: number?): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(310, 58)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = maxDistance or 130
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

local function labelAnchor(parent: Instance, name: string, position: Vector3, text: string, maxDistance: number?): BasePart
	local anchor = makePart(parent, name, Vector3.new(1, 1, 1), CFrame.new(position), Color3.new(1,1,1), 1)
	anchor.CanCollide = false
	anchor.CanQuery = false
	addBillboard(anchor, "Label", text, Color3.fromRGB(235, 238, 244), maxDistance)
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
	local old = Workspace:FindFirstChild(ROOT_NAME)
	if old then old:Destroy() end
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then baseplate:Destroy() end
	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace
	return root
end

local function buildStockSlots(bay: Model, bayCFrame: CFrame)
	local config = WarehouseConfig.Bay
	local folder = Instance.new("Folder")
	folder.Name = "StockSlots"
	folder.Parent = bay
	for index, localOffset in config.StockSlotPositions do
		local active = index <= config.InitialStockSlots
		local marker = makePart(folder, ("StockSlot%02d"):format(index), config.StockSlotSize, bayCFrame * localOffset, if active then Color3.fromRGB(93,129,160) else Color3.fromRGB(72,80,91), if active then 0.45 else 1)
		marker.CanCollide = false
		marker.CanQuery = active
		marker:SetAttribute("StockSlotIndex", index)
		marker:SetAttribute("ActiveByDefault", active)
		marker:SetAttribute("ReservedForExpansion", true)
		if active then addBillboard(marker, "StockSlotLabel", ("STOCK %d"):format(index), Color3.fromRGB(205,224,241), 40) end
	end

	local futureSell = makePart(bay, "FutureQuickSellAnchor", Vector3.new(1,1,1), bayCFrame * CFrame.new(-13.5,1,-6.5), Color3.new(1,1,1), 1)
	futureSell.CanCollide = false
	futureSell.CanQuery = false
	futureSell:SetAttribute("ReservedPurpose", "Sell")
	local futureUpgrade = makePart(bay, "FutureBayUpgradeAnchor", Vector3.new(1,1,1), bayCFrame * CFrame.new(13.5,1,13.5), Color3.new(1,1,1), 1)
	futureUpgrade.CanCollide = false
	futureUpgrade.CanQuery = false
	futureUpgrade:SetAttribute("ReservedPurpose", "BayUpgrade")
end

local function buildBayAt(folder: Folder, index: number, position: Vector3, target: Vector3)
	local config = WarehouseConfig.Bay
	local cf = CFrame.lookAt(position, target)
	local bay = Instance.new("Model")
	bay.Name = ("Bay%02d"):format(index)
	bay:SetAttribute("BayIndex", index)
	bay:SetAttribute("OwnerUserId", 0)
	bay:SetAttribute("OwnerName", "")
	bay:SetAttribute("InitialStockSlots", config.InitialStockSlots)
	bay:SetAttribute("MaxPlannedStockSlots", config.MaxPlannedStockSlots)
	bay.Parent = folder

	local pad = makePart(bay, "BayPad", config.PadSize, cf, Color3.fromRGB(61,71,86))
	pad.Material = Enum.Material.Concrete
	local processing = makePart(bay, "ProcessingArea", config.ProcessingSize, cf * config.ProcessingOffset, Color3.fromRGB(76,111,94), 0.22)
	processing.CanCollide = false
	processing:SetAttribute("ReservedPurpose", "DeliveryProcessing")
	local unload = makePart(bay, "UnloadZone", config.UnloadSize, cf * config.UnloadOffset, Color3.fromRGB(84,195,122), 0.72)
	unload.CanCollide = false
	unload.CanTouch = true
	unload:SetAttribute("BayIndex", index)
	local processingAnchor = makePart(bay, "ProcessingLabelAnchor", Vector3.new(1,1,1), cf * CFrame.new(0,1.3,-7.4), Color3.new(1,1,1), 1)
	processingAnchor.CanCollide = false
	processingAnchor.CanQuery = false
	addBillboard(processingAnchor, "ProcessingLabel", "DELIVERY / PROCESSING", Color3.fromRGB(180,255,202), 50)
	buildStockSlots(bay, cf)

	local van = Instance.new("Model")
	van.Name = "Van"
	van.Parent = bay
	makePart(van, "Body", Vector3.new(12.5,5.2,8.2), cf * config.VanOffset, Color3.fromRGB(126,132,143))
	makePart(van, "Cab", Vector3.new(8.2,4.2,4.2), cf * config.VanOffset * CFrame.new(0,-0.25,-5.4), Color3.fromRGB(148,154,164))
	local spawn = makePart(bay, "SpawnMarker", Vector3.new(1,1,1), cf * config.SpawnOffset, Color3.new(1,1,1), 1)
	spawn.CanCollide = false
	spawn.CanQuery = false
	local owner = makePart(bay, "OwnerLabelAnchor", Vector3.new(1,1,1), cf * config.OwnerLabelOffset, Color3.new(1,1,1), 1)
	owner.CanCollide = false
	owner.CanQuery = false
	local label = addBillboard(owner, "OwnerLabel", ("OPEN BAY %02d"):format(index), Color3.fromRGB(185,193,207), 95)
	label:SetAttribute("BayIndex", index)
	bay.PrimaryPart = pad
end

local function buildBays(root: Folder, config)
	local folder = Instance.new("Folder")
	folder.Name = "Bays"
	folder.Parent = root
	local leftIndex = 1
	local rightIndex = 7
	for _, z in config.BayRowsZ do
		for _, x in { -config.BayOuterX, -config.BayInnerX } do
			buildBayAt(folder, leftIndex, Vector3.new(x,0,z), config.BayLookTarget)
			leftIndex += 1
		end
		for _, x in { config.BayInnerX, config.BayOuterX } do
			buildBayAt(folder, rightIndex, Vector3.new(x,0,z), config.BayLookTarget)
			rightIndex += 1
		end
	end
end

local function makeSpawnMarker(folder: Folder, sectionId: string, index: number, position: Vector3, kind: string)
	local meta = SectionConfig.Sections[sectionId]
	local marker = makePart(folder, ("M6A2_%02d_%s_%02d"):format(meta.Index, sectionId, index), Vector3.new(1.2,0.08,1.2), CFrame.new(position + Vector3.new(0,0.04,0)), Color3.fromRGB(126,132,143), 1)
	marker.CanCollide = false
	marker.CanQuery = false
	marker:SetAttribute("ItemId", meta.FallbackItemId)
	marker:SetAttribute("ZoneName", meta.DisplayName)
	marker:SetAttribute("ZoneDepth", meta.Depth)
	marker:SetAttribute("SectorName", sectionId)
	marker:SetAttribute("SectionIndex", meta.Index)
	marker:SetAttribute("SectionDisplayName", meta.DisplayName)
	marker:SetAttribute("OpportunityName", marker.Name)
	marker:SetAttribute("OpportunityKind", kind)
	marker:SetAttribute("RestockSeconds", 1.8)
end

local MARKERS = {
	{ X=-28, T=0.15, Kind="SharedFocal" }, { X=28, T=0.15, Kind="SharedFocal" },
	{ X=-57, T=0.22, Kind="StorageOpportunity" }, { X=57, T=0.22, Kind="StorageOpportunity" },
	{ X=-67, T=0.32, Kind="StorageOpportunity" }, { X=67, T=0.32, Kind="StorageOpportunity" },
	{ X=-48, T=0.42, Kind="StorageOpportunity" }, { X=48, T=0.42, Kind="StorageOpportunity" },
	{ X=-28, T=0.53, Kind="SharedStaging" }, { X=28, T=0.53, Kind="SharedStaging" },
	{ X=-66, T=0.64, Kind="StorageOpportunity" }, { X=66, T=0.64, Kind="StorageOpportunity" },
	{ X=-53, T=0.76, Kind="StorageOpportunity" }, { X=53, T=0.76, Kind="StorageOpportunity" },
	{ X=-39, T=0.88, Kind="StorageOpportunity" }, { X=39, T=0.88, Kind="StorageOpportunity" },
}

local function structureSpec(kind: string): (Vector3, number, boolean, Enum.Material)
	if kind == "Pallets" then return Vector3.new(19,1.2,14), 0.38, false, Enum.Material.Concrete end
	if kind == "HomeRows" then return Vector3.new(15,6,15), 0.25, true, Enum.Material.WoodPlanks end
	if kind == "ApplianceRows" then return Vector3.new(14,9,16), 0.18, true, Enum.Material.Metal end
	if kind == "FurnitureBays" then return Vector3.new(20,3,18), 0.32, true, Enum.Material.WoodPlanks end
	if kind == "ElectronicsRows" then return Vector3.new(14,7,17), 0.20, true, Enum.Material.Metal end
	if kind == "RecreationFloor" then return Vector3.new(19,5,20), 0.30, true, Enum.Material.Concrete end
	if kind == "GarageRacks" then return Vector3.new(16,9,18), 0.22, true, Enum.Material.Metal end
	if kind == "ConstructionStaging" then return Vector3.new(18,8,20), 0.27, true, Enum.Material.Metal end
	if kind == "HeavyPads" then return Vector3.new(18,11,19), 0.24, true, Enum.Material.Metal end
	if kind == "MachineBays" then return Vector3.new(18,14,20), 0.14, true, Enum.Material.Metal end
	if kind == "PremiumShowrooms" then return Vector3.new(21,8,20), 0.24, true, Enum.Material.Marble end
	if kind == "LuxuryDisplays" then return Vector3.new(17,10,18), 0.20, true, Enum.Material.Metal end
	if kind == "GalleryStorage" then return Vector3.new(19,12,18), 0.18, true, Enum.Material.SmoothPlastic end
	if kind == "VaultCells" then return Vector3.new(16,14,18), 0.16, true, Enum.Material.Metal end
	return Vector3.new(18,16,20), 0.12, true, Enum.Material.Metal
end

local function buildSectionStructures(sectionModel: Model, meta, frontZ: number, backZ: number)
	local folder = Instance.new("Folder")
	folder.Name = "StorageStructures"
	folder.Parent = sectionModel
	local size, transparency, collides, material = structureSpec(meta.StructureKind)
	local length = frontZ - backZ
	local samples = if length >= 110 then {0.16,0.38,0.62,0.84} else {0.20,0.50,0.80}
	local index = 0
	for _, side in {-1,1} do
		for _, t in samples do
			index += 1
			local z = frontZ - length * t
			local part = makePart(folder, ("Structure_%02d_%s"):format(index, meta.StructureKind), size, CFrame.new(76 * side, size.Y * 0.5, z), Color3.fromRGB(74 + meta.Index * 2, 78 + meta.Index, 84 + meta.Index), transparency)
			part.Material = material
			part.CanCollide = collides
			part:SetAttribute("GrayboxStructure", true)
			part:SetAttribute("StructureKind", meta.StructureKind)
		end
	end
end

local function buildSectionIdentity(sectionModel: Model, meta, frontZ: number, runwayWidth: number)
	local identity = Instance.new("Folder")
	identity.Name = "SectionIdentity"
	identity.Parent = sectionModel
	for _, x in {-(runwayWidth*0.5-7), runwayWidth*0.5-7} do
		local post = makePart(identity, ("TransitionPost_%d"):format(math.floor(x)), Vector3.new(5,16,3), CFrame.new(x,8,frontZ-1), Color3.fromRGB(62 + meta.Index*2, 66 + meta.Index, 74 + meta.Index), 0.10)
		post.Material = Enum.Material.Metal
	end
	local beam = makePart(identity, "TransitionBeam", Vector3.new(runwayWidth-18,2.2,2.5), CFrame.new(0,15,frontZ-1), Color3.fromRGB(64 + meta.Index*2,68 + meta.Index,76 + meta.Index), 0.12)
	beam.Material = Enum.Material.Metal
	beam.CanCollide = false
	labelAnchor(identity, "SectionSignAnchor", Vector3.new(-61,4.5,frontZ-5), ("%02d  %s"):format(meta.Index, meta.DisplayName), 160)
end

local function buildSection(sectionsFolder: Folder, spawnFolder: Folder, routeFolder: Folder, sectionId: string, frontZ: number, config): number
	local meta = SectionConfig.Sections[sectionId]
	local backZ = frontZ - meta.Length
	local centerZ = (frontZ + backZ) * 0.5
	local section = Instance.new("Model")
	section.Name = sectionId
	section:SetAttribute("SectorName", sectionId)
	section:SetAttribute("SectionIndex", meta.Index)
	section:SetAttribute("DisplayName", meta.DisplayName)
	section:SetAttribute("CargoTheme", meta.CargoTheme)
	section:SetAttribute("GrayboxStyle", "M6A2_15SectionRunway")
	section:SetAttribute("FrontZ", frontZ)
	section:SetAttribute("BackZ", backZ)
	section:SetAttribute("CenterZ", centerZ)
	section:SetAttribute("SectionLength", meta.Length)
	section.Parent = sectionsFolder

	local tone = Color3.fromRGB(54 + math.min(meta.Index*2,28), 58 + math.min(meta.Index,20), 65 + math.min(meta.Index,16))
	local floor = makePart(section, "SectionFloor", Vector3.new(config.RunwayWidth,0.08,meta.Length), CFrame.new(0,0.11,centerZ), tone, 0.84)
	floor.CanCollide = false
	buildSectionIdentity(section, meta, frontZ, config.RunwayWidth)
	buildSectionStructures(section, meta, frontZ, backZ)

	local storage = Instance.new("Folder")
	storage.Name = "StoragePaths"
	storage.Parent = section
	for _, x in {-51,51} do
		local path = laneBetween(storage, if x < 0 then "LeftStoragePath" else "RightStoragePath", Vector3.new(x,0,frontZ-6), Vector3.new(x,0,backZ+6), config.StoragePathWidth, Color3.fromRGB(104,109,118), 0.68)
		path:SetAttribute("RouteType", "StoragePath")
		path:SetAttribute("SectorName", sectionId)
	end

	local cross = laneBetween(routeFolder, ("%02d_%s_CrossAisle"):format(meta.Index, sectionId), Vector3.new(-(config.RunwayWidth*0.5-5),0,centerZ), Vector3.new(config.RunwayWidth*0.5-5,0,centerZ), config.CrossAisleWidth, Color3.fromRGB(124,130,139), 0.56)
	cross:SetAttribute("RouteType", "CrossAisle")
	cross:SetAttribute("SectorName", sectionId)

	for index, marker in MARKERS do
		local z = frontZ - meta.Length * marker.T
		makeSpawnMarker(spawnFolder, sectionId, index, Vector3.new(marker.X,0.18,z), marker.Kind)
	end
	return backZ
end

local function buildHome(root: Folder, gameplay: Folder, config)
	local apron = makePart(root, "HomeApronFloor", config.HomeApronSize, CFrame.new(config.HomeApronCenter + Vector3.new(0,-config.HomeApronSize.Y*0.5,0)), Color3.fromRGB(52,58,68))
	apron.Material = Enum.Material.Concrete
	local departure = makePart(gameplay, "SharedDepartureArea", Vector3.new(172,0.10,46), CFrame.new(0,0.10,config.SharedDepartureZ), Color3.fromRGB(78,88,102), 0.28)
	departure.CanCollide = false
	departure:SetAttribute("RouteType", "SharedDeparture")
	labelAnchor(gameplay, "HomeLabelAnchor", Vector3.new(0,1.2,config.SharedDepartureZ+18), "HOME / DELIVERY  →  BETTER CARGO IS DEEPER", 180)
end

local function buildWalls(root: Folder, config)
	local half = config.RunwayWidth * 0.5
	local centerZ = (config.RunwayFrontZ + config.RunwayBackZ) * 0.5
	local wallY = config.WallHeight * 0.5
	local color = Color3.fromRGB(61,65,73)
	makePart(root, "RunwayWestWall", Vector3.new(1.5,config.WallHeight,config.RunwayLength), CFrame.new(-half,wallY,centerZ), color)
	makePart(root, "RunwayEastWall", Vector3.new(1.5,config.WallHeight,config.RunwayLength), CFrame.new(half,wallY,centerZ), color)
	local apronHalfX = config.HomeApronSize.X * 0.5
	local apronHalfZ = config.HomeApronSize.Z * 0.5
	local north = config.HomeApronCenter.Z + apronHalfZ
	local south = config.HomeApronCenter.Z - apronHalfZ
	makePart(root, "ApronWestWall", Vector3.new(1.5,config.WallHeight,config.HomeApronSize.Z), CFrame.new(-apronHalfX,wallY,config.HomeApronCenter.Z), color)
	makePart(root, "ApronEastWall", Vector3.new(1.5,config.WallHeight,config.HomeApronSize.Z), CFrame.new(apronHalfX,wallY,config.HomeApronCenter.Z), color)
	makePart(root, "ApronFrontWall", Vector3.new(config.HomeApronSize.X,config.WallHeight,1.5), CFrame.new(0,wallY,north), color)
	local wing = apronHalfX - half
	makePart(root, "ApronMouthLeftWing", Vector3.new(wing,config.WallHeight,1.5), CFrame.new(-(half+wing*0.5),wallY,south), color)
	makePart(root, "ApronMouthRightWing", Vector3.new(wing,config.WallHeight,1.5), CFrame.new(half+wing*0.5,wallY,south), color)
end

local function buildContinuation(root: Folder, config)
	local continuation = Instance.new("Folder")
	continuation.Name = "FutureWarehouseContinuation"
	continuation.Parent = root
	local extra = config.LongTermDepth.VisualContinuationLength
	local centerZ = config.RunwayBackZ - extra*0.5
	local floor = makePart(continuation, "ContinuationFloor", Vector3.new(config.RunwayWidth,0.7,extra), CFrame.new(0,-0.36,centerZ), Color3.fromRGB(38,41,47), 0.08)
	floor.Material = Enum.Material.Concrete
	local half = config.RunwayWidth*0.5
	makePart(continuation, "ContinuationWestWall", Vector3.new(1.5,config.WallHeight,extra), CFrame.new(-half,config.WallHeight*0.5,centerZ), Color3.fromRGB(54,58,66), 0.12)
	makePart(continuation, "ContinuationEastWall", Vector3.new(1.5,config.WallHeight,extra), CFrame.new(half,config.WallHeight*0.5,centerZ), Color3.fromRGB(54,58,66), 0.12)
	for i = 1, 5 do
		local z = config.RunwayBackZ - i*(extra/6)
		for _, x in {-62,62} do
			makePart(continuation, ("DistantColumn_%02d_%d"):format(i,x), Vector3.new(5,22,5), CFrame.new(x,11,z), Color3.fromRGB(64,68,75), 0.12 + i*0.07)
		end
		local beam = makePart(continuation, ("DistantBeam_%02d"):format(i), Vector3.new(config.RunwayWidth-24,2.5,3), CFrame.new(0,20,z), Color3.fromRGB(67,71,79), 0.18 + i*0.06)
		beam.CanCollide = false
	end
	local boundary = makePart(root, "CurrentPlayableDepthBoundary", Vector3.new(config.RunwayWidth,28,1.2), CFrame.new(0,14,config.RunwayBackZ-5), Color3.new(1,1,1), 1)
	boundary.CanCollide = true
	boundary.CanQuery = false
	boundary:SetAttribute("ReservedPurpose", "M6A2PlayableDepthBoundary")
	for index, x in {-56,0,56} do
		local marker = makePart(continuation, ("ExpansionPoint%02d"):format(index), Vector3.new(2,2,2), CFrame.new(x,1,config.RunwayBackZ-extra+24), Color3.fromRGB(124,104,155), 1)
		marker.CanCollide = false
		marker.CanQuery = false
		marker:SetAttribute("ReservedPurpose", config.LongTermDepth.FutureExpansionPurpose)
	end
end

local function buildFallback(root: Folder, config)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "FallbackSpawn"
	spawn.Size = Vector3.new(6,1,6)
	spawn.CFrame = CFrame.lookAt(config.FallbackSpawnPosition, config.FallbackSpawnPosition + Vector3.new(0,0,-1))
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 1
	spawn.Parent = root
	local feedback = Instance.new("Folder")
	feedback.Name = "Feedback"
	feedback.Parent = root
end

function Service.Build(): Folder
	local config = MacroLayoutConfig.OptionD
	local root = resetWorld()
	root:SetAttribute("MacroLayoutMode", "D")
	root:SetAttribute("M6A_Mode", "D")
	root:SetAttribute("M6A2_SectionCount", SectionConfig.LaunchSectionCount)
	root:SetAttribute("M6A2_PlayableDepth", config.RunwayLength)
	root:SetAttribute("M6A2_EndpointHidden", true)

	local gameplay = Instance.new("Folder")
	gameplay.Name = "WarehouseGameplay"
	gameplay.Parent = root
	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root
	buildHome(root, gameplay, config)

	local runway = makePart(root, "WarehouseFloor", Vector3.new(config.RunwayWidth,1,config.RunwayLength), CFrame.new(0,-0.5,(config.RunwayFrontZ+config.RunwayBackZ)*0.5), Color3.fromRGB(45,48,55))
	runway.Material = Enum.Material.Concrete
	local routes = Instance.new("Folder")
	routes.Name = "RouteNetwork"
	routes.Parent = gameplay
	local freight = laneBetween(routes, "MainSharedFreightAisle", Vector3.new(0,0,config.RunwayFrontZ), Vector3.new(0,0,config.RunwayBackZ+4), config.FreightWidth, Color3.fromRGB(119,126,136), 0.44)
	freight:SetAttribute("RouteType", "Freight")
	freight:SetAttribute("SharedRoute", true)

	local sections = Instance.new("Folder")
	sections.Name = "Sections"
	sections.Parent = gameplay
	local frontZ = config.RunwayFrontZ
	local previousBack: number? = nil
	for _, sectionId in config.SectionOrder do
		if previousBack then
			local transition = laneBetween(routes, ("Transition_%02d"):format(SectionConfig.Sections[sectionId].Index), Vector3.new(-(config.RunwayWidth*0.5-5),0,frontZ), Vector3.new(config.RunwayWidth*0.5-5,0,frontZ), config.CrossAisleWidth, Color3.fromRGB(136,141,150), 0.52)
			transition:SetAttribute("RouteType", "SectionTransition")
		end
		local backZ = buildSection(sections, spawnFolder, routes, sectionId, frontZ, config)
		local meta = SectionConfig.Sections[sectionId]
		local centerZ = (frontZ + backZ)*0.5
		local distance = math.abs(config.HomeReferenceZ - centerZ)
		root:SetAttribute(("M6A2_%02d_%s_Length"):format(meta.Index, sectionId), meta.Length)
		root:SetAttribute(("M6A2_%02d_%s_Distance"):format(meta.Index, sectionId), distance)
		frontZ = backZ
		previousBack = backZ
	end

	buildBays(root, config)
	buildWalls(root, config)
	buildContinuation(root, config)
	buildFallback(root, config)
	root:SetAttribute("M6A2_TotalSpawnMarkers", SectionConfig.LaunchSectionCount * config.MarkersPerSection)
	return root
end

return Service
