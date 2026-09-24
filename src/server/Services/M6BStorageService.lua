--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("M6BArtConfig"))

local Service = {}

local function makePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, transparency: number?, canCollide: boolean?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = canCollide == true
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = color
	part.Material = material
	part.Transparency = transparency or 0
	part:SetAttribute("M6BEnvironment", true)
	part.Parent = parent
	return part
end

local function addPlatform(model: Model, position: Vector3, style: any, focal: boolean): (Part, Part)
	local size = if focal then Vector3.new(10.5, 0.55, 10.5) else Vector3.new(8.5, 0.45, 8.2)
	local platform = makePart(
		model,
		"StoragePlatform",
		size,
		CFrame.new(position.X, 0.34, position.Z),
		style.Secondary,
		style.Material,
		0.05,
		false
	)
	platform:SetAttribute("EmptySpawnPosition", true)

	local side = if position.X < 0 then -1 else 1
	local innerX = position.X - side * (size.X * 0.5 - 0.35)
	local light = makePart(
		model,
		"StatusLight",
		Vector3.new(0.38, 0.26, math.max(4.8, size.Z - 1.2)),
		CFrame.new(innerX, 0.72, position.Z),
		ArtConfig.SlotStatus.VacantColor,
		Enum.Material.Neon,
		ArtConfig.SlotStatus.VacantTransparency,
		false
	)
	light:SetAttribute("SlotState", "Vacant")
	return platform, light
end

local function addBackPosts(model: Model, position: Vector3, style: any, height: number, widthZ: number, top: boolean)
	local side = if position.X < 0 then -1 else 1
	local backX = position.X + side * 4.1
	for _, zOffset in {-widthZ * 0.5, widthZ * 0.5} do
		makePart(model, "RackPost", Vector3.new(1.0, height, 1.0), CFrame.new(backX, height * 0.5, position.Z + zOffset), style.Base, Enum.Material.Metal, 0, true)
	end
	if top then
		makePart(model, "RackHeader", Vector3.new(1.1, 1.0, widthZ + 1.0), CFrame.new(backX, height - 0.5, position.Z), style.Accent, Enum.Material.Metal, 0, true)
	end
end

local function addBackPanel(model: Model, position: Vector3, style: any, height: number, widthZ: number, transparency: number?, material: Enum.Material?)
	local side = if position.X < 0 then -1 else 1
	local backX = position.X + side * 4.25
	makePart(model, "BackPanel", Vector3.new(0.55, height, widthZ), CFrame.new(backX, height * 0.5, position.Z), style.Base, material or style.Material, transparency or 0, true)
end

local function buildPalletRack(model: Model, p: Vector3, style: any)
	addBackPosts(model, p, style, 8.5, 7.0, true)
	local side = if p.X < 0 then -1 else 1
	local backX = p.X + side * 3.9
	for _, y in {2.7, 5.4} do
		makePart(model, "ShelfBeam", Vector3.new(0.7, 0.5, 6.8), CFrame.new(backX - side * 0.4, y, p.Z), style.Secondary, Enum.Material.Metal, 0, false)
	end
end

local function buildHomeShelf(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 6.5, 7.0, 0.08, Enum.Material.WoodPlanks)
	local side = if p.X < 0 then -1 else 1
	for _, y in {2.2, 4.3} do
		makePart(model, "HomeShelf", Vector3.new(3.7, 0.45, 6.7), CFrame.new(p.X + side * 2.4, y, p.Z), style.Secondary, Enum.Material.WoodPlanks, 0, false)
	end
end

local function buildApplianceBay(model: Model, p: Vector3, style: any)
	addBackPosts(model, p, style, 10.5, 7.8, true)
	local side = if p.X < 0 then -1 else 1
	makePart(model, "ApplianceStop", Vector3.new(0.65, 1.3, 7.4), CFrame.new(p.X + side * 4.0, 0.95, p.Z), style.Secondary, Enum.Material.Metal, 0, true)
end

local function buildFurnitureBay(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 4.2, 8.4, 0.12, Enum.Material.WoodPlanks)
	local side = if p.X < 0 then -1 else 1
	for _, zOffset in {-4.0, 4.0} do
		makePart(model, "FurnitureDivider", Vector3.new(4.5, 2.3, 0.65), CFrame.new(p.X + side * 2.0, 1.25, p.Z + zOffset), style.Secondary, Enum.Material.WoodPlanks, 0.06, true)
	end
end

local function buildTechShelf(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 7.5, 7.0, 0.03, Enum.Material.Metal)
	local side = if p.X < 0 then -1 else 1
	local x = p.X + side * 3.85
	for _, y in {2.4, 4.7, 6.7} do
		makePart(model, "TechShelfTrim", Vector3.new(0.78, 0.28, 6.5), CFrame.new(x - side * 0.45, y, p.Z), style.Accent, Enum.Material.Neon, 0.25, false)
	end
end

local function buildRecreationBay(model: Model, p: Vector3, style: any)
	addBackPosts(model, p, style, 7.5, 8.0, true)
	local side = if p.X < 0 then -1 else 1
	makePart(model, "PlayfulHeader", Vector3.new(1.15, 1.0, 4.2), CFrame.new(p.X + side * 3.9, 5.8, p.Z), style.Accent, Enum.Material.SmoothPlastic, 0, false)
end

local function buildGarageRack(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 7.8, 7.2, 0.02, Enum.Material.Metal)
	local side = if p.X < 0 then -1 else 1
	for _, y in {2.1, 4.2, 6.3} do
		makePart(model, "ToolRail", Vector3.new(0.72, 0.38, 6.6), CFrame.new(p.X + side * 3.75, y, p.Z), style.Accent, Enum.Material.Metal, 0, false)
	end
end

local function buildConstructionRack(model: Model, p: Vector3, style: any)
	addBackPosts(model, p, style, 9.5, 8.0, true)
	local side = if p.X < 0 then -1 else 1
	makePart(model, "SafetyBar", Vector3.new(0.9, 0.7, 7.0), CFrame.new(p.X + side * 3.7, 2.2, p.Z), style.Accent, Enum.Material.Metal, 0, true)
end

local function buildHeavyPad(model: Model, p: Vector3, style: any)
	local side = if p.X < 0 then -1 else 1
	local outerX = p.X + side * 4.0
	for _, zOffset in {-3.7, 3.7} do
		makePart(model, "ReinforcedPost", Vector3.new(1.25, 6.2, 1.25), CFrame.new(outerX, 3.1, p.Z + zOffset), style.Base, Enum.Material.Metal, 0, true)
	end
	makePart(model, "SafetyRail", Vector3.new(0.9, 0.65, 7.2), CFrame.new(outerX, 5.6, p.Z), style.Accent, Enum.Material.Metal, 0, false)
end

local function buildIndustrialCell(model: Model, p: Vector3, style: any)
	addBackPosts(model, p, style, 12.5, 8.2, true)
	local side = if p.X < 0 then -1 else 1
	makePart(model, "GantryArm", Vector3.new(4.6, 0.8, 1.0), CFrame.new(p.X + side * 2.1, 10.5, p.Z), style.Secondary, Enum.Material.Metal, 0, false)
end

local function buildPremiumBay(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 6.8, 7.4, 0.02, Enum.Material.SmoothPlastic)
	local side = if p.X < 0 then -1 else 1
	makePart(model, "PremiumTrim", Vector3.new(0.7, 0.5, 7.0), CFrame.new(p.X + side * 3.8, 5.9, p.Z), style.Accent, Enum.Material.Metal, 0.05, false)
end

local function buildLuxuryCabinet(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 8.0, 7.4, 0, Enum.Material.Metal)
	local side = if p.X < 0 then -1 else 1
	local innerX = p.X - side * 3.4
	for _, zOffset in {-3.5, 3.5} do
		makePart(model, "GlassSide", Vector3.new(3.6, 7.0, 0.28), CFrame.new(p.X + side * 1.9, 3.7, p.Z + zOffset), Color3.fromRGB(140, 176, 189), Enum.Material.Glass, 0.55, false)
	end
	makePart(model, "GoldHeader", Vector3.new(0.7, 0.7, 7.2), CFrame.new(p.X + side * 3.75, 7.25, p.Z), style.Accent, Enum.Material.Metal, 0, false)
	makePart(model, "CabinetThreshold", Vector3.new(0.45, 0.45, 6.6), CFrame.new(innerX, 0.65, p.Z), style.Accent, Enum.Material.Metal, 0, false)
end

local function buildGalleryStorage(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 9.2, 7.6, 0.04, Enum.Material.SmoothPlastic)
	local side = if p.X < 0 then -1 else 1
	makePart(model, "ArtTransportFrame", Vector3.new(2.8, 6.3, 0.55), CFrame.new(p.X + side * 2.3, 3.5, p.Z), style.Secondary, Enum.Material.Metal, 0, false)
	makePart(model, "Pedestal", Vector3.new(4.2, 1.0, 4.2), CFrame.new(p.X, 0.9, p.Z), style.Secondary, Enum.Material.SmoothPlastic, 0.03, false)
end

local function buildSecureCell(model: Model, p: Vector3, style: any)
	addBackPanel(model, p, style, 9.5, 7.6, 0, Enum.Material.Metal)
	local side = if p.X < 0 then -1 else 1
	local x = p.X + side * 2.0
	for _, zOffset in {-3.6, -1.2, 1.2, 3.6} do
		makePart(model, "SecurityBar", Vector3.new(3.5, 0.5, 0.32), CFrame.new(x, 5.0, p.Z + zOffset), style.Secondary, Enum.Material.Metal, 0, false)
	end
	makePart(model, "SecurityHeader", Vector3.new(0.75, 0.65, 7.0), CFrame.new(p.X + side * 3.8, 8.3, p.Z), style.Accent, Enum.Material.Neon, 0.25, false)
end

local function buildContainmentFrame(model: Model, p: Vector3, style: any)
	addBackPosts(model, p, style, 11.5, 8.0, true)
	local side = if p.X < 0 then -1 else 1
	local x = p.X + side * 1.9
	for _, y in {2.2, 6.0, 9.8} do
		makePart(model, "ContainmentBand", Vector3.new(4.2, 0.48, 7.0), CFrame.new(x, y, p.Z), style.Accent, Enum.Material.Neon, 0.30, false)
	end
end

local BUILDERS = {
	PalletRack = buildPalletRack,
	HomeShelf = buildHomeShelf,
	ApplianceBay = buildApplianceBay,
	FurnitureBay = buildFurnitureBay,
	TechShelf = buildTechShelf,
	RecreationBay = buildRecreationBay,
	GarageRack = buildGarageRack,
	ConstructionRack = buildConstructionRack,
	HeavyPad = buildHeavyPad,
	IndustrialCell = buildIndustrialCell,
	PremiumBay = buildPremiumBay,
	LuxuryCabinet = buildLuxuryCabinet,
	GalleryStorage = buildGalleryStorage,
	SecureCell = buildSecureCell,
	ContainmentFrame = buildContainmentFrame,
}

local function addFocalTreatment(model: Model, p: Vector3, style: any)
	local side = if p.X < 0 then -1 else 1
	local innerX = p.X - side * 4.8
	makePart(model, "FocalAisleEdge", Vector3.new(0.55, 0.25, 9.2), CFrame.new(innerX, 0.45, p.Z), style.Accent, Enum.Material.Neon, 0.22, false)
	model:SetAttribute("HighlyVisibleOpportunity", true)
	model:SetAttribute("GuaranteedRare", false)
end

local function buildSlot(slotsFolder: Folder, marker: BasePart)
	local sectionId = marker:GetAttribute("SectorName")
	if typeof(sectionId) ~= "string" then return end
	local style = ArtConfig.SectionStyles[sectionId]
	if not style then return end

	local model = Instance.new("Model")
	model.Name = marker.Name
	model:SetAttribute("SpawnName", marker.Name)
	model:SetAttribute("SectionId", sectionId)
	model:SetAttribute("StorageFamily", style.Family)
	model:SetAttribute("OpportunityKind", marker:GetAttribute("OpportunityKind") or "StorageOpportunity")
	model.Parent = slotsFolder

	local kind = tostring(marker:GetAttribute("OpportunityKind") or "StorageOpportunity")
	local focal = kind == "SharedFocal" or kind == "SharedStaging"
	local platform, light = addPlatform(model, marker.Position, style, focal)
	platform:SetAttribute("SpawnName", marker.Name)
	light:SetAttribute("SpawnName", marker.Name)

	local builder = BUILDERS[style.Family]
	if builder then builder(model, marker.Position, style) end
	if focal then addFocalTreatment(model, marker.Position, style) end
end

local function addSectionEntryAccent(sectionModel: Model, sectionId: string, style: any)
	local frontZ = tonumber(sectionModel:GetAttribute("FrontZ"))
	if not frontZ then return end
	local folder = Instance.new("Folder")
	folder.Name = "M6BSectionAccent"
	folder.Parent = sectionModel
	for _, x in {-82, 82} do
		makePart(folder, "ChunkyEntryPost", Vector3.new(3.4, 12, 3.4), CFrame.new(x, 6, frontZ - 2.5), style.Base, Enum.Material.Metal, 0, true)
		makePart(folder, "ColorBand", Vector3.new(3.75, 1.2, 3.75), CFrame.new(x, 9.0, frontZ - 2.5), style.Accent, Enum.Material.SmoothPlastic, 0, false)
	end
	makePart(folder, "SectionHeaderBand", Vector3.new(166, 1.6, 2.0), CFrame.new(0, 11.2, frontZ - 2.5), style.Secondary, Enum.Material.Metal, 0.08, false)
	folder:SetAttribute("SectionId", sectionId)
end

function Service.Build(root: Folder)
	local old = root:FindFirstChild("M6BStorageSlots")
	if old then old:Destroy() end
	local slotsFolder = Instance.new("Folder")
	slotsFolder.Name = "M6BStorageSlots"
	slotsFolder.Parent = root

	local gameplay = root:FindFirstChild("WarehouseGameplay")
	local sections = gameplay and gameplay:FindFirstChild("Sections")
	if sections then
		for _, sectionModel in sections:GetChildren() do
			if sectionModel:IsA("Model") then
				local sectionId = sectionModel.Name
				local style = ArtConfig.SectionStyles[sectionId]
				if style then
					local graybox = sectionModel:FindFirstChild("StorageStructures")
					if graybox then graybox:Destroy() end
					local previous = sectionModel:FindFirstChild("M6BSectionAccent")
					if previous then previous:Destroy() end
					addSectionEntryAccent(sectionModel, sectionId, style)
				end
			end
		end
	end

	local markers = root:FindFirstChild("ItemSpawns")
	if markers then
		for _, marker in markers:GetChildren() do
			if marker:IsA("BasePart") then buildSlot(slotsFolder, marker) end
		end
	end

	root:SetAttribute("M6BStorageArchitecture", true)
	root:SetAttribute("M6BStorageSlotCount", #slotsFolder:GetChildren())
	root:SetAttribute("M6BArtStyle", "StylizedColorfulChunkyClean")
end

return Service
