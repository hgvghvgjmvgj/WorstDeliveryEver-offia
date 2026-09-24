--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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

local function addDepartmentLight(parent: Instance, position: Vector3, color: Color3, width: number)
	local fixture = makePart(parent, "DepartmentLightFixture", Vector3.new(width, 0.45, 1.4), CFrame.new(position), color, Enum.Material.Neon, 0.08, false)
	local light = Instance.new("PointLight")
	light.Name = "DepartmentLight"
	light.Color = color
	light.Brightness = 0.85
	light.Range = 38
	light.Shadows = false
	light.Parent = fixture
end

local function sectionBounds(sectionModel: Model): (number?, number?, number?)
	local front = tonumber(sectionModel:GetAttribute("FrontZ"))
	local back = tonumber(sectionModel:GetAttribute("BackZ"))
	if not front or not back then return nil, nil, nil end
	return front, back, (front + back) * 0.5
end

local function addEmptySlotBase(model: Model, marker: BasePart, style: any, size: Vector3, material: Enum.Material): (Part, Part)
	local platform = makePart(model, "StoragePlatform", size, CFrame.new(marker.Position.X, 0.32, marker.Position.Z), style.Secondary, material, 0.04, false)
	platform:SetAttribute("EmptySpawnPosition", true)
	platform:SetAttribute("SpawnName", marker.Name)

	local side = if marker.Position.X < 0 then -1 else 1
	local innerX = marker.Position.X - side * (size.X * 0.5 - 0.35)
	local light = makePart(model, "StatusLight", Vector3.new(0.38, 0.25, math.max(4.4, size.Z - 1.0)), CFrame.new(innerX, 0.70, marker.Position.Z), ArtConfig.SlotStatus.VacantColor, Enum.Material.Neon, ArtConfig.SlotStatus.VacantTransparency, false)
	light:SetAttribute("SlotState", "Vacant")
	light:SetAttribute("SpawnName", marker.Name)
	return platform, light
end

local function addFocalEdge(model: Model, marker: BasePart, style: any, length: number)
	local side = if marker.Position.X < 0 then -1 else 1
	local x = marker.Position.X - side * 4.9
	makePart(model, "FocalAisleEdge", Vector3.new(0.48, 0.20, length), CFrame.new(x, 0.48, marker.Position.Z), style.Accent, Enum.Material.Neon, 0.22, false)
	model:SetAttribute("HighlyVisibleOpportunity", true)
	model:SetAttribute("GuaranteedRare", false)
end

local function buildReceivingSlot(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local outer = math.abs(p.X) >= 45
	local platformSize = if focal then Vector3.new(9.8, 0.48, 9.6) else Vector3.new(7.6, 0.42, 7.5)
	addEmptySlotBase(model, marker, style, platformSize, Enum.Material.WoodPlanks)
	local side = if p.X < 0 then -1 else 1

	if focal then
		for _, zOffset in {-3.7, 3.7} do
			makePart(model, "StagingBumper", Vector3.new(0.55, 1.1, 0.75), CFrame.new(p.X + side * 4.2, 0.75, p.Z + zOffset), style.Accent, Enum.Material.Metal, 0, false)
		end
		addFocalEdge(model, marker, style, 8.5)
	elseif outer then
		local backX = p.X + side * 3.8
		for _, zOffset in {-3.1, 3.1} do
			makePart(model, "PalletRackPost", Vector3.new(1.0, 8.4, 1.0), CFrame.new(backX, 4.2, p.Z + zOffset), style.Base, Enum.Material.Metal, 0, true)
		end
		for _, y in {2.7, 5.3, 7.8} do
			makePart(model, "PalletRackBeam", Vector3.new(0.78, 0.52, 7.0), CFrame.new(backX - side * 0.35, y, p.Z), if y == 7.8 then style.Accent else style.Secondary, Enum.Material.Metal, 0, false)
		end
	else
		local backX = p.X + side * 3.5
		makePart(model, "SortingBack", Vector3.new(0.55, 5.2, 6.5), CFrame.new(backX, 2.8, p.Z), style.Base, Enum.Material.Metal, 0.12, true)
		for _, y in {2.0, 4.0} do
			makePart(model, "SortingShelf", Vector3.new(3.2, 0.38, 6.2), CFrame.new(p.X + side * 1.9, y, p.Z), style.Secondary, Enum.Material.Metal, 0.04, false)
		end
	end
end

local function buildHomeSlot(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	local platformSize = if focal then Vector3.new(9.0, 0.36, 9.0) else Vector3.new(7.2, 0.34, 7.2)
	addEmptySlotBase(model, marker, style, platformSize, Enum.Material.WoodPlanks)

	if focal then
		makePart(model, "HomePocketBack", Vector3.new(0.48, 3.8, 7.4), CFrame.new(p.X + side * 3.8, 2.1, p.Z), Color3.fromRGB(217, 199, 165), Enum.Material.SmoothPlastic, 0.02, false)
		makePart(model, "SoftAccentRail", Vector3.new(0.62, 0.48, 6.6), CFrame.new(p.X + side * 3.5, 3.8, p.Z), Color3.fromRGB(111, 153, 111), Enum.Material.SmoothPlastic, 0, false)
		addFocalEdge(model, marker, style, 8.0)
	else
		local backX = p.X + side * 3.4
		makePart(model, "WarmShelfBack", Vector3.new(0.50, 5.5, 6.4), CFrame.new(backX, 3.0, p.Z), Color3.fromRGB(136, 98, 71), Enum.Material.WoodPlanks, 0.03, true)
		for _, y in {1.8, 3.6, 5.2} do
			makePart(model, "HomeShelf", Vector3.new(3.0, 0.34, 6.2), CFrame.new(p.X + side * 1.8, y, p.Z), Color3.fromRGB(209, 185, 144), Enum.Material.WoodPlanks, 0, false)
		end
		makePart(model, "StorageBasket", Vector3.new(2.2, 1.2, 2.6), CFrame.new(p.X - side * 1.9, 0.95, p.Z + 2.0), Color3.fromRGB(106, 149, 104), Enum.Material.SmoothPlastic, 0, false)
	end
end

local function buildApplianceSlot(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	local platformSize = if focal then Vector3.new(11.2, 0.48, 10.2) else Vector3.new(9.6, 0.44, 9.0)
	addEmptySlotBase(model, marker, style, platformSize, Enum.Material.SmoothPlastic)
	local backX = p.X + side * 4.6

	for _, zOffset in {-3.9, 3.9} do
		makePart(model, "ApplianceFramePost", Vector3.new(1.15, 11.8, 1.15), CFrame.new(backX, 5.9, p.Z + zOffset), style.Base, Enum.Material.Metal, 0, true)
	end
	makePart(model, "ApplianceFrameHeader", Vector3.new(1.2, 1.1, 9.0), CFrame.new(backX, 11.2, p.Z), style.Secondary, Enum.Material.Metal, 0, false)
	makePart(model, "CoolBayTrim", Vector3.new(0.62, 0.42, 8.2), CFrame.new(backX - side * 0.45, 8.8, p.Z), style.Accent, Enum.Material.Neon, 0.22, false)
	if focal then addFocalEdge(model, marker, style, 9.0) end
end

local BUILDERS = {
	Receiving = buildReceivingSlot,
	HomeBasics = buildHomeSlot,
	Appliances = buildApplianceSlot,
}

local function buildSlot(slotsFolder: Folder, marker: BasePart)
	local sectionId = marker:GetAttribute("SectorName")
	if typeof(sectionId) ~= "string" or ArtConfig.ProofSections[sectionId] ~= true then return end
	local style = ArtConfig.SectionStyles[sectionId]
	local builder = BUILDERS[sectionId]
	if not style or not builder then return end

	local model = Instance.new("Model")
	model.Name = marker.Name
	model:SetAttribute("SpawnName", marker.Name)
	model:SetAttribute("SectionId", sectionId)
	model:SetAttribute("StorageFamily", style.Family)
	model:SetAttribute("OpportunityKind", marker:GetAttribute("OpportunityKind") or "StorageOpportunity")
	model.Parent = slotsFolder

	local kind = tostring(marker:GetAttribute("OpportunityKind") or "StorageOpportunity")
	local focal = kind == "SharedFocal" or kind == "SharedStaging"
	builder(model, marker, style, focal)
end

local function addReceivingDepartment(folder: Folder, section: Model, style: any)
	local front, back, center = sectionBounds(section)
	if not front or not back or not center then return end
	local length = front - back

	for _, t in {0.18, 0.52, 0.84} do
		local z = front - length * t
		makePart(folder, "ReceivingTruss", Vector3.new(164, 1.6, 2.2), CFrame.new(0, style.OverheadHeight, z), style.Base, Enum.Material.Metal, 0.03, false)
		for _, x in {-78, 78} do
			makePart(folder, "ReceivingColumn", Vector3.new(2.4, style.OverheadHeight, 2.4), CFrame.new(x, style.OverheadHeight * 0.5, z), style.Base, Enum.Material.Metal, 0, true)
		end
	end
	for _, side in {-1, 1} do
		local x = 72 * side
		for _, t in {0.10, 0.62} do
			local z = front - length * t
			makePart(folder, "PalletStack", Vector3.new(9.0, 1.0, 6.8), CFrame.new(x, 0.72, z), Color3.fromRGB(157, 112, 68), Enum.Material.WoodPlanks, 0, false)
			makePart(folder, "ParcelBin", Vector3.new(4.0, 3.0, 4.0), CFrame.new(x - side * 8.5, 1.65, z + 3.0), Color3.fromRGB(70, 119, 167), Enum.Material.SmoothPlastic, 0, false)
		end
	end
	addDepartmentLight(folder, Vector3.new(0, style.OverheadHeight - 1.3, front - length * 0.28), style.LightColor, 28)
	addDepartmentLight(folder, Vector3.new(0, style.OverheadHeight - 1.3, front - length * 0.72), style.LightColor, 28)
end

local function addHomeDepartment(folder: Folder, section: Model, style: any)
	local front, back, center = sectionBounds(section)
	if not front or not back or not center then return end
	local length = front - back

	for _, side in {-1, 1} do
		makePart(folder, "HomeFloorPocket", Vector3.new(54, 0.05, math.max(12, length - 8)), CFrame.new(53 * side, 0.20, center), Color3.fromRGB(215, 196, 163), Enum.Material.SmoothPlastic, 0.48, false)
		for _, t in {0.24, 0.72} do
			local z = front - length * t
			makePart(folder, "HomeDisplayIsland", Vector3.new(9.0, 0.72, 6.5), CFrame.new(69 * side, 0.56, z), Color3.fromRGB(184, 137, 87), Enum.Material.WoodPlanks, 0, false)
			makePart(folder, "HomeBin", Vector3.new(3.2, 2.0, 3.2), CFrame.new(58 * side, 1.18, z + 4), Color3.fromRGB(105, 148, 102), Enum.Material.SmoothPlastic, 0, false)
		end
	end
	for _, t in {0.30, 0.70} do
		local z = front - length * t
		makePart(folder, "HomeCeilingBeam", Vector3.new(154, 1.1, 1.8), CFrame.new(0, style.OverheadHeight, z), Color3.fromRGB(117, 91, 72), Enum.Material.WoodPlanks, 0.08, false)
	end
	addDepartmentLight(folder, Vector3.new(0, style.OverheadHeight - 1.0, front - length * 0.34), style.LightColor, 24)
	addDepartmentLight(folder, Vector3.new(0, style.OverheadHeight - 1.0, front - length * 0.74), style.LightColor, 24)
end

local function addApplianceDepartment(folder: Folder, section: Model, style: any)
	local front, back, center = sectionBounds(section)
	if not front or not back or not center then return end
	local length = front - back

	for _, side in {-1, 1} do
		makePart(folder, "ApplianceCleanFloor", Vector3.new(55, 0.05, math.max(12, length - 8)), CFrame.new(53 * side, 0.21, center), Color3.fromRGB(192, 201, 209), Enum.Material.SmoothPlastic, 0.42, false)
	end
	for _, t in {0.20, 0.52, 0.84} do
		local z = front - length * t
		makePart(folder, "ApplianceOverheadFrame", Vector3.new(166, 1.8, 2.5), CFrame.new(0, style.OverheadHeight, z), Color3.fromRGB(74, 88, 105), Enum.Material.Metal, 0.02, false)
		for _, x in {-80, 80} do
			makePart(folder, "ApplianceSupport", Vector3.new(2.8, style.OverheadHeight, 2.8), CFrame.new(x, style.OverheadHeight * 0.5, z), Color3.fromRGB(74, 88, 105), Enum.Material.Metal, 0, true)
		end
	end
	addDepartmentLight(folder, Vector3.new(0, style.OverheadHeight - 1.4, front - length * 0.30), style.LightColor, 31)
	addDepartmentLight(folder, Vector3.new(0, style.OverheadHeight - 1.4, front - length * 0.74), style.LightColor, 31)
end

local DEPARTMENT_BUILDERS = {
	Receiving = addReceivingDepartment,
	HomeBasics = addHomeDepartment,
	Appliances = addApplianceDepartment,
}

local function addSectionEntryAccent(sectionModel: Model, sectionId: string, style: any)
	local frontZ = tonumber(sectionModel:GetAttribute("FrontZ"))
	if not frontZ then return end
	local folder = Instance.new("Folder")
	folder.Name = "M6BSectionAccent"
	folder.Parent = sectionModel
	local postHeight = if sectionId == "HomeBasics" then 10.5 elseif sectionId == "Appliances" then 15 else 13
	for _, x in {-82, 82} do
		makePart(folder, "ChunkyEntryPost", Vector3.new(3.2, postHeight, 3.2), CFrame.new(x, postHeight * 0.5, frontZ - 2.5), style.Base, Enum.Material.Metal, 0, true)
		makePart(folder, "ColorBand", Vector3.new(3.6, 1.1, 3.6), CFrame.new(x, postHeight * 0.72, frontZ - 2.5), style.Accent, Enum.Material.SmoothPlastic, 0, false)
	end
	makePart(folder, "SectionHeaderBand", Vector3.new(166, 1.35, 2.0), CFrame.new(0, postHeight - 0.5, frontZ - 2.5), style.Secondary, Enum.Material.Metal, 0.10, false)
	folder:SetAttribute("SectionId", sectionId)
end

local function buildFreightLane(root: Folder, sections: Instance)
	local receiving = sections:FindFirstChild("Receiving")
	local appliances = sections:FindFirstChild("Appliances")
	if not receiving or not appliances or not receiving:IsA("Model") or not appliances:IsA("Model") then return end
	local front = tonumber(receiving:GetAttribute("FrontZ"))
	local back = tonumber(appliances:GetAttribute("BackZ"))
	if not front or not back then return end
	local center = (front + back) * 0.5
	local length = front - back
	local old = root:FindFirstChild("M6BFreightLane")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "M6BFreightLane"
	folder.Parent = root
	for _, x in {-18.2, 18.2} do
		makePart(folder, "FreightLaneEdge", Vector3.new(0.65, 0.06, length), CFrame.new(x, 0.24, center), Color3.fromRGB(220, 225, 229), Enum.Material.SmoothPlastic, 0.10, false)
	end
	for index = 1, math.floor(length / 28) do
		local z = front - index * 28
		makePart(folder, "FreightRhythm_" .. index, Vector3.new(6.0, 0.05, 1.2), CFrame.new(0, 0.245, z), Color3.fromRGB(132, 151, 167), Enum.Material.SmoothPlastic, 0.26, false)
	end
	folder:SetAttribute("Purpose", "FastSharedRoute")
end

local function maybeHideSigns(sectionModel: Model)
	if Workspace:GetAttribute("M6BHideSectionSigns") ~= true then return end
	for _, descendant in sectionModel:GetDescendants() do
		if descendant:IsA("BillboardGui") and string.find(descendant.Name, "Label") then
			descendant.Enabled = false
		end
	end
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
				if ArtConfig.ProofSections[sectionId] == true then
					local style = ArtConfig.SectionStyles[sectionId]
					local builder = DEPARTMENT_BUILDERS[sectionId]
					if style and builder then
						local graybox = sectionModel:FindFirstChild("StorageStructures")
						if graybox then graybox:Destroy() end
						local grayIdentity = sectionModel:FindFirstChild("M6A3Identity")
						if grayIdentity then grayIdentity:Destroy() end
						local previous = sectionModel:FindFirstChild("M6BSectionAccent")
						if previous then previous:Destroy() end
						local oldDepartment = sectionModel:FindFirstChild("M6BDepartmentSet")
						if oldDepartment then oldDepartment:Destroy() end
						local department = Instance.new("Folder")
						department.Name = "M6BDepartmentSet"
						department.Parent = sectionModel
						addSectionEntryAccent(sectionModel, sectionId, style)
						builder(department, sectionModel, style)
						maybeHideSigns(sectionModel)
					end
				end
			end
		end
		buildFreightLane(root, sections)
	end

	local markers = root:FindFirstChild("ItemSpawns")
	if markers then
		for _, marker in markers:GetChildren() do
			if marker:IsA("BasePart") then buildSlot(slotsFolder, marker) end
		end
	end

	root:SetAttribute("M6BStorageArchitecture", true)
	root:SetAttribute("M6BProofSections", "Receiving,HomeBasics,Appliances")
	root:SetAttribute("M6BStorageSlotCount", #slotsFolder:GetChildren())
	root:SetAttribute("M6BArtStyle", "StylizedColorfulChunkyClean")
	root:SetAttribute("M6BScaleBeyondSection3", false)
end

return Service
