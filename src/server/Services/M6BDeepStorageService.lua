--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("M6BArtConfig"))

local Service = {}

local DEEP_SECTIONS = table.freeze({
	Furniture = true,
	Electronics = true,
	Recreation = true,
	GarageAuto = true,
	Construction = true,
	HeavyGoods = true,
	Industrial = true,
	PremiumInteriors = true,
	LuxuryGoods = true,
	ArtCollectibles = true,
	Secure = true,
	RestrictedPrototype = true,
})

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	transparency: number?,
	canCollide: boolean?
): Part
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

local function makeCylinder(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	transparency: number?
): Part
	local part = makePart(parent, name, size, cframe, color, material, transparency, false)
	part.Shape = Enum.PartType.Cylinder
	return part
end

local function sectionBounds(section: Model): (number?, number?, number?, number?)
	local front = tonumber(section:GetAttribute("FrontZ"))
	local back = tonumber(section:GetAttribute("BackZ"))
	if not front or not back then return nil, nil, nil, nil end
	return front, back, (front + back) * 0.5, front - back
end

local function addDepartmentLight(parent: Instance, position: Vector3, color: Color3, width: number, brightness: number?)
	local fixture = makePart(parent, "DepartmentLightFixture", Vector3.new(width, 0.42, 1.3), CFrame.new(position), color, Enum.Material.Neon, 0.14, false)
	local light = Instance.new("PointLight")
	light.Name = "DepartmentLight"
	light.Color = color
	light.Brightness = brightness or 0.72
	light.Range = 34
	light.Shadows = false
	light.Parent = fixture
end

local function slotBase(model: Model, marker: BasePart, style: any, size: Vector3, material: Enum.Material, y: number?): (Part, Part)
	local platform = makePart(
		model,
		"StoragePlatform",
		size,
		CFrame.new(marker.Position.X, y or 0.34, marker.Position.Z),
		style.Secondary,
		material,
		0.04,
		false
	)
	platform:SetAttribute("EmptySpawnPosition", true)
	platform:SetAttribute("SpawnName", marker.Name)

	local side = if marker.Position.X < 0 then -1 else 1
	local innerX = marker.Position.X - side * (size.X * 0.5 - 0.35)
	local status = makePart(
		model,
		"StatusLight",
		Vector3.new(0.40, 0.25, math.max(4.2, size.Z - 1.0)),
		CFrame.new(innerX, 0.72, marker.Position.Z),
		ArtConfig.SlotStatus.VacantColor,
		Enum.Material.Neon,
		ArtConfig.SlotStatus.VacantTransparency,
		false
	)
	status:SetAttribute("SlotState", "Vacant")
	status:SetAttribute("SpawnName", marker.Name)
	return platform, status
end

local function focalEdge(model: Model, marker: BasePart, style: any, length: number)
	local side = if marker.Position.X < 0 then -1 else 1
	local x = marker.Position.X - side * 5.0
	makePart(model, "FocalAisleEdge", Vector3.new(0.5, 0.22, length), CFrame.new(x, 0.50, marker.Position.Z), style.Accent, Enum.Material.Neon, 0.24, false)
	model:SetAttribute("HighlyVisibleOpportunity", true)
	model:SetAttribute("GuaranteedRare", false)
end

local function markerIsFocal(marker: BasePart): boolean
	local kind = tostring(marker:GetAttribute("OpportunityKind") or "StorageOpportunity")
	return kind == "SharedFocal" or kind == "SharedStaging"
end

local function buildFurniture(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(13.0,0.44,10.8) else Vector3.new(11.2,0.40,9.8), Enum.Material.WoodPlanks)
	local outerX = p.X + side * 5.2
	for _, z in {-4.3,4.3} do
		makePart(model, "FurnitureFramePost", Vector3.new(1.1,7.0,1.1), CFrame.new(outerX,3.5,p.Z+z), style.Base, Enum.Material.Metal, 0, true)
	end
	makePart(model, "WideFurnitureHeader", Vector3.new(1.15,0.9,9.7), CFrame.new(outerX,6.5,p.Z), style.Secondary, Enum.Material.Metal, 0.02, false)
	makePart(model, "RaisedFurnitureDeck", Vector3.new(6.0,0.5,8.2), CFrame.new(p.X + side*2.0,0.62,p.Z), Color3.fromRGB(139,96,72), Enum.Material.WoodPlanks, 0.03, false)
	if focal then
		makePart(model, "MattressWall", Vector3.new(0.65,5.2,7.7), CFrame.new(outerX - side*0.7,2.8,p.Z), Color3.fromRGB(204,190,174), Enum.Material.SmoothPlastic, 0.10, false)
		focalEdge(model, marker, style, 9.6)
	end
end

local function buildElectronics(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(10.2,0.42,9.2) else Vector3.new(8.7,0.38,8.1), Enum.Material.Metal)
	local backX = p.X + side*4.2
	makePart(model, "TechBackplane", Vector3.new(0.65,8.6,7.4), CFrame.new(backX,4.45,p.Z), Color3.fromRGB(33,44,62), Enum.Material.Metal, 0.02, true)
	for _, y in {2.2,4.4,6.6} do
		makePart(model, "TechShelf", Vector3.new(3.8,0.32,6.8), CFrame.new(p.X+side*2.1,y,p.Z), style.Secondary, Enum.Material.Metal, 0.02, false)
		makePart(model, "ShelfEdgeLight", Vector3.new(0.22,0.18,6.3), CFrame.new(p.X+side*0.22,y+0.24,p.Z), style.Accent, Enum.Material.Neon, 0.22, false)
	end
	for _, z in {-3.5,3.5} do
		makePart(model, "ElectronicsCagePost", Vector3.new(0.55,7.5,0.55), CFrame.new(p.X-side*3.6,3.75,p.Z+z), style.Base, Enum.Material.Metal, 0.06, false)
	end
	if focal then focalEdge(model, marker, style, 8.5) end
end

local function buildRecreation(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(10.5,0.40,10.0) else Vector3.new(8.8,0.36,8.6), Enum.Material.SmoothPlastic)
	local backX = p.X + side*4.0
	for _, z in {-3.4,3.4} do
		makePart(model, "PlayFrame", Vector3.new(0.75,7.6,0.75), CFrame.new(backX,3.8,p.Z+z) * CFrame.Angles(0,0,math.rad(if z < 0 then -4 else 4)), style.Base, Enum.Material.Metal, 0, true)
	end
	makePart(model, "AngledDisplayRail", Vector3.new(0.75,0.65,7.2), CFrame.new(backX-side*0.6,5.9,p.Z) * CFrame.Angles(math.rad(8),0,0), style.Accent, Enum.Material.SmoothPlastic, 0, false)
	for _, z in {-2.3,0,2.3} do
		makePart(model, "EquipmentHook", Vector3.new(2.4,0.30,0.40), CFrame.new(p.X+side*2.3,4.2,p.Z+z) * CFrame.Angles(0,math.rad(18*side),0), style.Secondary, Enum.Material.Metal, 0, false)
	end
	if focal then
		makePart(model, "ArcadeBayHeader", Vector3.new(3.6,1.0,6.8), CFrame.new(p.X+side*2.3,7.0,p.Z), Color3.fromRGB(101,81,150), Enum.Material.SmoothPlastic, 0.03, false)
		focalEdge(model, marker, style, 9.0)
	end
end

local function buildGarage(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(11.5,0.48,10.4) else Vector3.new(9.8,0.44,9.2), Enum.Material.Metal)
	local backX = p.X + side*4.7
	for _, z in {-3.9,3.9} do
		makePart(model, "GaragePost", Vector3.new(1.25,9.6,1.25), CFrame.new(backX,4.8,p.Z+z), Color3.fromRGB(58,59,64), Enum.Material.Metal, 0, true)
	end
	for _, y in {2.3,5.0,8.2} do
		makePart(model, "ToolBeam", Vector3.new(0.9,0.48,8.1), CFrame.new(backX-side*0.35,y,p.Z), if y == 5.0 then Color3.fromRGB(153,52,47) else style.Secondary, Enum.Material.Metal, 0, false)
	end
	for _, z in {-2.5,0,2.5} do
		makeCylinder(model, "TireRack", Vector3.new(0.55,2.1,2.1), CFrame.new(p.X+side*2.0,3.4,p.Z+z) * CFrame.Angles(0,0,math.rad(90)), Color3.fromRGB(35,36,39), Enum.Material.SmoothPlastic, 0)
	end
	makePart(model, "EngineCradle", Vector3.new(4.2,0.55,6.4), CFrame.new(p.X-side*2.3,0.8,p.Z), style.Accent, Enum.Material.Metal, 0.06, false)
	if focal then focalEdge(model, marker, style, 9.4) end
end

local function buildConstruction(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(12.0,0.50,10.8) else Vector3.new(10.3,0.46,9.5), Enum.Material.Metal)
	local backX = p.X + side*4.9
	for _, z in {-4.1,4.1} do
		makePart(model, "ScaffoldTowerPost", Vector3.new(1.25,12.0,1.25), CFrame.new(backX,6.0,p.Z+z), Color3.fromRGB(83,84,78), Enum.Material.Metal, 0, true)
	end
	for _, y in {3.0,6.0,9.0,11.5} do
		makePart(model, "ReinforcedShelfBeam", Vector3.new(0.95,0.55,8.7), CFrame.new(backX-side*0.4,y,p.Z), if y >= 9 then style.Accent else style.Secondary, Enum.Material.Metal, 0, false)
	end
	for _, y in {4.4,8.2} do
		makePart(model, "ScaffoldBrace", Vector3.new(4.0,0.32,0.55), CFrame.new(p.X+side*2.2,y,p.Z) * CFrame.Angles(0,0,math.rad(28*side)), style.Base, Enum.Material.Metal, 0, false)
	end
	if focal then
		makePart(model, "EquipmentDock", Vector3.new(6.6,0.62,7.8), CFrame.new(p.X-side*2.2,0.9,p.Z), Color3.fromRGB(190,124,42), Enum.Material.Metal, 0.02, false)
		focalEdge(model, marker, style, 9.8)
	end
end

local function buildHeavy(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(14.5,0.64,12.2) else Vector3.new(12.8,0.58,11.2), Enum.Material.DiamondPlate, 0.42)
	local outerX = p.X + side*5.7
	for _, z in {-4.8,4.8} do
		makePart(model, "MassiveSafetyPost", Vector3.new(1.6,9.5,1.6), CFrame.new(outerX,4.75,p.Z+z), Color3.fromRGB(59,64,68), Enum.Material.Metal, 0, true)
	end
	makePart(model, "MachineFrameHeader", Vector3.new(1.5,1.2,10.8), CFrame.new(outerX,8.7,p.Z), style.Secondary, Enum.Material.Metal, 0, false)
	makePart(model, "LoadingCradle", Vector3.new(7.8,0.8,8.8), CFrame.new(p.X+side*1.6,1.0,p.Z), Color3.fromRGB(78,86,88), Enum.Material.Metal, 0, false)
	for _, z in {-4.6,4.6} do
		makePart(model, "SafetyCageRail", Vector3.new(5.0,0.60,0.55), CFrame.new(p.X-side*3.1,3.2,p.Z+z), style.Accent, Enum.Material.Metal, 0, false)
	end
	if focal then focalEdge(model, marker, style, 11.0) end
end

local function buildIndustrial(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(15.0,0.68,12.6) else Vector3.new(13.2,0.62,11.5), Enum.Material.DiamondPlate, 0.44)
	local backX = p.X + side*6.0
	for _, z in {-5.0,5.0} do
		makePart(model, "MachineryCellPost", Vector3.new(1.8,15.5,1.8), CFrame.new(backX,7.75,p.Z+z), Color3.fromRGB(50,64,68), Enum.Material.Metal, 0, true)
	end
	makePart(model, "GantryHeader", Vector3.new(1.8,1.35,11.5), CFrame.new(backX,14.5,p.Z), style.Secondary, Enum.Material.Metal, 0, false)
	makePart(model, "HoistRail", Vector3.new(7.0,0.75,1.0), CFrame.new(p.X+side*2.4,12.6,p.Z), style.Accent, Enum.Material.Metal, 0, false)
	makePart(model, "MechanicalDock", Vector3.new(8.0,0.85,8.8), CFrame.new(p.X-side*2.0,1.05,p.Z), Color3.fromRGB(56,72,75), Enum.Material.Metal, 0, false)
	for _, z in {-3.2,3.2} do
		makeCylinder(model, "PipeSupport", Vector3.new(0.75,2.0,2.0), CFrame.new(p.X+side*3.5,8.8,p.Z+z) * CFrame.Angles(0,0,math.rad(90)), Color3.fromRGB(67,111,113), Enum.Material.Metal, 0)
	end
	if focal then focalEdge(model, marker, style, 11.4) end
end

local function buildPremium(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(11.5,0.44,10.2) else Vector3.new(9.8,0.40,9.0), Enum.Material.SmoothPlastic)
	local backX = p.X + side*4.7
	makePart(model, "PremiumBack", Vector3.new(0.65,8.2,8.0), CFrame.new(backX,4.25,p.Z), Color3.fromRGB(73,66,61), Enum.Material.SmoothPlastic, 0.02, true)
	makePart(model, "WarmIntegratedLight", Vector3.new(0.28,0.24,7.0), CFrame.new(backX-side*0.4,6.7,p.Z), style.Accent, Enum.Material.Neon, 0.30, false)
	for _, z in {-3.7,3.7} do
		makePart(model, "ProtectedGlassWing", Vector3.new(4.2,6.0,0.28), CFrame.new(p.X+side*2.3,3.2,p.Z+z), Color3.fromRGB(203,217,222), Enum.Material.Glass, 0.62, false)
	end
	makePart(model, "CuratedDeck", Vector3.new(6.2,0.48,7.6), CFrame.new(p.X-side*2.0,0.70,p.Z), Color3.fromRGB(181,164,142), Enum.Material.SmoothPlastic, 0.02, false)
	if focal then focalEdge(model, marker, style, 9.4) end
end

local function buildLuxury(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(11.4,0.46,10.0) else Vector3.new(9.8,0.42,9.0), Enum.Material.Metal)
	local backX = p.X + side*4.7
	makePart(model, "LuxuryCabinetBack", Vector3.new(0.70,9.4,8.0), CFrame.new(backX,4.9,p.Z), Color3.fromRGB(28,27,31), Enum.Material.Metal, 0, true)
	for _, z in {-3.8,3.8} do
		makePart(model, "LuxuryGlassSide", Vector3.new(4.3,7.8,0.30), CFrame.new(p.X+side*2.4,4.1,p.Z+z), Color3.fromRGB(150,177,184), Enum.Material.Glass, 0.55, false)
	end
	makePart(model, "GoldCabinetHeader", Vector3.new(0.82,0.72,8.1), CFrame.new(backX-side*0.35,8.5,p.Z), style.Accent, Enum.Material.Metal, 0, false)
	makePart(model, "LuxuryShelfLight", Vector3.new(0.30,0.24,7.2), CFrame.new(backX-side*0.42,6.4,p.Z), Color3.fromRGB(255,211,135), Enum.Material.Neon, 0.34, false)
	makePart(model, "FragranceTrunkDeck", Vector3.new(5.7,0.58,7.0), CFrame.new(p.X-side*2.1,0.76,p.Z), Color3.fromRGB(72,40,47), Enum.Material.SmoothPlastic, 0, false)
	if focal then focalEdge(model, marker, style, 9.4) end
end

local function buildArt(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(12.0,0.44,10.2) else Vector3.new(10.0,0.40,9.2), Enum.Material.SmoothPlastic)
	local backX = p.X + side*4.8
	for _, z in {-3.8,0,3.8} do
		makePart(model, "SlidingArtTrack", Vector3.new(4.6,0.45,0.36), CFrame.new(p.X+side*2.4,7.4,p.Z+z), style.Secondary, Enum.Material.Metal, 0, false)
		makePart(model, "PaddedArtFrame", Vector3.new(0.45,6.6,2.6), CFrame.new(backX-side*0.55,3.6,p.Z+z), Color3.fromRGB(94,66,105), Enum.Material.SmoothPlastic, 0.04, false)
	end
	makePart(model, "MuseumTransportBack", Vector3.new(0.62,8.6,8.4), CFrame.new(backX,4.45,p.Z), Color3.fromRGB(49,43,55), Enum.Material.SmoothPlastic, 0.02, true)
	makePart(model, "SculpturePedestal", Vector3.new(4.6,1.0,4.6), CFrame.new(p.X-side*2.6,0.82,p.Z), Color3.fromRGB(116,83,128), Enum.Material.SmoothPlastic, 0.02, false)
	if focal then focalEdge(model, marker, style, 9.6) end
end

local function buildSecure(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(12.8,0.56,10.6) else Vector3.new(11.0,0.52,9.6), Enum.Material.DiamondPlate)
	local backX = p.X + side*5.2
	makePart(model, "ArmoredCellBack", Vector3.new(1.15,10.5,8.6), CFrame.new(backX,5.45,p.Z), Color3.fromRGB(39,45,53), Enum.Material.Metal, 0, true)
	for _, z in {-4.3,4.3} do
		makePart(model, "VaultCellPillar", Vector3.new(1.5,10.8,1.5), CFrame.new(p.X-side*4.3,5.4,p.Z+z), Color3.fromRGB(50,60,72), Enum.Material.Metal, 0, true)
	end
	makePart(model, "VaultLockHeader", Vector3.new(8.3,0.95,0.9), CFrame.new(p.X-side*1.2,9.2,p.Z-4.2), style.Accent, Enum.Material.Metal, 0, false)
	for _, y in {3.0,6.0} do
		makePart(model, "SecurityCrossRail", Vector3.new(5.4,0.55,0.55), CFrame.new(p.X-side*2.5,y,p.Z+4.2), style.Secondary, Enum.Material.Metal, 0, false)
	end
	makePart(model, "SecurityStatus", Vector3.new(0.28,2.0,0.28), CFrame.new(p.X-side*4.15,6.1,p.Z-3.7), Color3.fromRGB(100,185,235), Enum.Material.Neon, 0.20, false)
	if focal then focalEdge(model, marker, style, 10.0) end
end

local function buildRestricted(model: Model, marker: BasePart, style: any, focal: boolean)
	local p = marker.Position
	local side = if p.X < 0 then -1 else 1
	slotBase(model, marker, style, if focal then Vector3.new(14.0,0.62,11.5) else Vector3.new(12.2,0.56,10.4), Enum.Material.Metal)
	local outerX = p.X + side*5.5
	for _, z in {-4.4,4.4} do
		makePart(model, "ContainmentTower", Vector3.new(1.4,13.5,1.4), CFrame.new(outerX,6.75,p.Z+z), Color3.fromRGB(34,40,48), Enum.Material.Metal, 0, true)
	end
	makePart(model, "PrototypeDockHeader", Vector3.new(1.5,1.0,10.2), CFrame.new(outerX,12.7,p.Z), Color3.fromRGB(86,42,58), Enum.Material.Metal, 0, false)
	for _, y in {3.2,7.0,10.7} do
		makePart(model, "EnergyContainmentBand", Vector3.new(5.8,0.34,8.3), CFrame.new(p.X+side*2.4,y,p.Z), if y == 7.0 then Color3.fromRGB(212,67,139) else style.Accent, Enum.Material.Neon, 0.44, false)
	end
	makeCylinder(model, "MagneticDockRing", Vector3.new(0.52,4.8,4.8), CFrame.new(p.X-side*2.6,5.2,p.Z) * CFrame.Angles(0,0,math.rad(90)), style.Accent, Enum.Material.Neon, 0.24)
	for _, z in {-3.5,3.5} do
		makePart(model, "RoboticSupportArm", Vector3.new(4.2,0.72,0.72), CFrame.new(p.X-side*1.1,8.5,p.Z+z) * CFrame.Angles(0,math.rad(18*side),math.rad(18*side)), Color3.fromRGB(82,91,101), Enum.Material.Metal, 0, false)
	end
	if focal then focalEdge(model, marker, style, 10.8) end
end

local SLOT_BUILDERS = table.freeze({
	Furniture = buildFurniture,
	Electronics = buildElectronics,
	Recreation = buildRecreation,
	GarageAuto = buildGarage,
	Construction = buildConstruction,
	HeavyGoods = buildHeavy,
	Industrial = buildIndustrial,
	PremiumInteriors = buildPremium,
	LuxuryGoods = buildLuxury,
	ArtCollectibles = buildArt,
	Secure = buildSecure,
	RestrictedPrototype = buildRestricted,
})

local function departmentFrame(folder: Folder, section: Model, style: any, height: number, postSize: number, samples: {number}, headerThickness: number)
	local front, back, _center, length = sectionBounds(section)
	if not front or not back or not length then return end
	for _, t in samples do
		local z = front - length*t
		for _, x in {-78,78} do
			makePart(folder, "DepartmentColumn", Vector3.new(postSize,height,postSize), CFrame.new(x,height*0.5,z), style.Base, Enum.Material.Metal, 0, true)
		end
		makePart(folder, "DepartmentHeader", Vector3.new(158,headerThickness,postSize), CFrame.new(0,height,z), style.Secondary, Enum.Material.Metal, 0.04, false)
	end
end

local function addFurnitureDepartment(folder: Folder, section: Model, style: any)
	local front, _back, center, length = sectionBounds(section)
	if not front or not center or not length then return end
	departmentFrame(folder, section, style, 16.5, 2.2, {0.28,0.72}, 1.2)
	for _, side in {-1,1} do
		makePart(folder, "FurnitureShowroomDeck", Vector3.new(52,0.08,math.max(14,length-10)), CFrame.new(53*side,0.22,center), Color3.fromRGB(151,112,85), Enum.Material.WoodPlanks, 0.58, false)
		makePart(folder, "MattressStack", Vector3.new(7.5,7.0,3.0), CFrame.new(72*side,3.7,front-length*0.58), Color3.fromRGB(212,199,184), Enum.Material.SmoothPlastic, 0.08, false)
	end
	addDepartmentLight(folder, Vector3.new(0,14.8,front-length*0.32), style.LightColor, 30)
	addDepartmentLight(folder, Vector3.new(0,14.8,front-length*0.75), style.LightColor, 30)
end

local function addElectronicsDepartment(folder: Folder, section: Model, style: any)
	local front, _back, center, length = sectionBounds(section)
	if not front or not center or not length then return end
	departmentFrame(folder, section, style, 18.5, 2.0, {0.22,0.50,0.78}, 1.0)
	for _, side in {-1,1} do
		makePart(folder, "TechFloorStrip", Vector3.new(52,0.06,math.max(14,length-8)), CFrame.new(53*side,0.22,center), Color3.fromRGB(37,49,67), Enum.Material.SmoothPlastic, 0.42, false)
		for _, t in {0.30,0.70} do
			makePart(folder, "EquipmentWall", Vector3.new(1.0,8.0,12.0), CFrame.new(80*side,4.2,front-length*t), Color3.fromRGB(35,46,63), Enum.Material.Metal, 0.02, false)
		end
	end
	addDepartmentLight(folder, Vector3.new(0,16.7,front-length*0.30), style.LightColor, 27)
	addDepartmentLight(folder, Vector3.new(0,16.7,front-length*0.72), style.LightColor, 27)
end

local function addRecreationDepartment(folder: Folder, section: Model, style: any)
	local front, _back, _center, length = sectionBounds(section)
	if not front or not length then return end
	departmentFrame(folder, section, style, 17.2, 1.8, {0.20,0.55,0.85}, 0.9)
	for _, side in {-1,1} do
		for _, t in {0.26,0.62} do
			local z = front-length*t
			makePart(folder, "PlayfulCrossFrame", Vector3.new(14.0,1.0,1.0), CFrame.new(64*side,9.0,z) * CFrame.Angles(0,math.rad(8*side),math.rad(12*side)), style.Accent, Enum.Material.SmoothPlastic, 0.06, false)
		end
	end
	addDepartmentLight(folder, Vector3.new(0,15.8,front-length*0.35), style.LightColor, 24)
	addDepartmentLight(folder, Vector3.new(0,15.8,front-length*0.78), Color3.fromRGB(213,199,255), 24)
end

local function addGarageDepartment(folder: Folder, section: Model, style: any)
	local front, _back, _center, length = sectionBounds(section)
	if not front or not length then return end
	departmentFrame(folder, section, style, 19.0, 2.6, {0.18,0.50,0.82}, 1.4)
	for _, side in {-1,1} do
		makePart(folder, "ToolWall", Vector3.new(1.2,9.0,15.0), CFrame.new(80*side,4.7,front-length*0.52), Color3.fromRGB(126,48,44), Enum.Material.Metal, 0.02, false)
	end
	addDepartmentLight(folder, Vector3.new(0,17.0,front-length*0.30), style.LightColor, 28)
	addDepartmentLight(folder, Vector3.new(0,17.0,front-length*0.72), style.LightColor, 28)
end

local function addConstructionDepartment(folder: Folder, section: Model, style: any)
	local front, _back, _center, length = sectionBounds(section)
	if not front or not length then return end
	departmentFrame(folder, section, style, 21.0, 2.8, {0.16,0.40,0.64,0.88}, 1.6)
	for _, side in {-1,1} do
		for _, t in {0.28,0.72} do
			local z = front-length*t
			for _, y in {5.0,10.0,15.0} do
				makePart(folder, "ScaffoldCrossBar", Vector3.new(13.5,0.7,0.7), CFrame.new(69*side,y,z) * CFrame.Angles(0,0,math.rad(22*side)), style.Accent, Enum.Material.Metal, 0.04, false)
			end
		end
	end
	addDepartmentLight(folder, Vector3.new(0,18.7,front-length*0.30), style.LightColor, 29)
	addDepartmentLight(folder, Vector3.new(0,18.7,front-length*0.76), style.LightColor, 29)
end

local function addHeavyDepartment(folder: Folder, section: Model, style: any)
	local front, _back, center, length = sectionBounds(section)
	if not front or not center or not length then return end
	departmentFrame(folder, section, style, 23.0, 3.2, {0.22,0.52,0.82}, 1.9)
	for _, side in {-1,1} do
		makePart(folder, "HeavyStagingFloor", Vector3.new(54,0.08,math.max(14,length-10)), CFrame.new(54*side,0.24,center), Color3.fromRGB(70,76,79), Enum.Material.DiamondPlate, 0.30, false)
	end
	addDepartmentLight(folder, Vector3.new(0,20.4,front-length*0.30), style.LightColor, 31)
	addDepartmentLight(folder, Vector3.new(0,20.4,front-length*0.76), style.LightColor, 31)
end

local function addIndustrialDepartment(folder: Folder, section: Model, style: any)
	local front, _back, _center, length = sectionBounds(section)
	if not front or not length then return end
	departmentFrame(folder, section, style, 28.0, 3.5, {0.18,0.42,0.66,0.90}, 2.2)
	for _, t in {0.30,0.72} do
		local z = front-length*t
		makePart(folder, "MainGantry", Vector3.new(136,2.0,3.0), CFrame.new(0,23.5,z), Color3.fromRGB(50,65,69), Enum.Material.Metal, 0, false)
		makePart(folder, "HoistTrack", Vector3.new(92,0.8,0.8), CFrame.new(0,21.8,z), style.Accent, Enum.Material.Metal, 0.04, false)
	end
	addDepartmentLight(folder, Vector3.new(0,25.4,front-length*0.30), style.LightColor, 34)
	addDepartmentLight(folder, Vector3.new(0,25.4,front-length*0.76), style.LightColor, 34)
end

local function addPremiumDepartment(folder: Folder, section: Model, style: any)
	local front, _back, center, length = sectionBounds(section)
	if not front or not center or not length then return end
	departmentFrame(folder, section, style, 19.5, 2.2, {0.24,0.58,0.84}, 1.1)
	for _, side in {-1,1} do
		makePart(folder, "PremiumFloor", Vector3.new(53,0.06,math.max(14,length-8)), CFrame.new(53*side,0.22,center), Color3.fromRGB(180,168,151), Enum.Material.SmoothPlastic, 0.42, false)
	end
	addDepartmentLight(folder, Vector3.new(0,17.2,front-length*0.30), style.LightColor, 30, 0.82)
	addDepartmentLight(folder, Vector3.new(0,17.2,front-length*0.74), style.LightColor, 30, 0.82)
end

local function addLuxuryDepartment(folder: Folder, section: Model, style: any)
	local front, _back, center, length = sectionBounds(section)
	if not front or not center or not length then return end
	departmentFrame(folder, section, style, 20.5, 2.5, {0.22,0.50,0.78}, 1.2)
	for _, side in {-1,1} do
		makePart(folder, "LuxuryFloor", Vector3.new(53,0.07,math.max(14,length-8)), CFrame.new(53*side,0.23,center), Color3.fromRGB(38,34,39), Enum.Material.SmoothPlastic, 0.18, false)
		makePart(folder, "GoldFloorTrim", Vector3.new(0.55,0.10,math.max(14,length-12)), CFrame.new(28*side,0.31,center), style.Accent, Enum.Material.Metal, 0.04, false)
	end
	addDepartmentLight(folder, Vector3.new(0,18.2,front-length*0.30), Color3.fromRGB(255,220,170), 28, 0.88)
	addDepartmentLight(folder, Vector3.new(0,18.2,front-length*0.74), Color3.fromRGB(255,220,170), 28, 0.88)
end

local function addArtDepartment(folder: Folder, section: Model, style: any)
	local front, _back, _center, length = sectionBounds(section)
	if not front or not length then return end
	departmentFrame(folder, section, style, 21.0, 2.3, {0.24,0.56,0.84}, 1.0)
	for _, side in {-1,1} do
		for _, t in {0.24,0.50,0.76} do
			local z = front-length*t
			makePart(folder, "GalleryTrack", Vector3.new(18.0,0.42,0.50), CFrame.new(64*side,17.0,z), style.Secondary, Enum.Material.Metal, 0, false)
		end
	end
	addDepartmentLight(folder, Vector3.new(0,18.3,front-length*0.30), style.LightColor, 24, 0.90)
	addDepartmentLight(folder, Vector3.new(0,18.3,front-length*0.72), style.LightColor, 24, 0.90)
end

local function addSecureDepartment(folder: Folder, section: Model, style: any)
	local front, _back, _center, length = sectionBounds(section)
	if not front or not length then return end
	departmentFrame(folder, section, style, 23.0, 3.8, {0.14,0.36,0.58,0.80}, 2.0)
	for _, t in {0.22,0.50,0.78} do
		local z = front-length*t
		for _, side in {-1,1} do
			makePart(folder, "VaultBulkhead", Vector3.new(12.0,13.0,2.4), CFrame.new(75*side,6.5,z), Color3.fromRGB(40,49,59), Enum.Material.Metal, 0, true)
		end
	end
	addDepartmentLight(folder, Vector3.new(0,20.5,front-length*0.30), style.LightColor, 30, 0.80)
	addDepartmentLight(folder, Vector3.new(0,20.5,front-length*0.74), Color3.fromRGB(160,205,245), 30, 0.80)
end

local function addRestrictedDepartment(folder: Folder, section: Model, style: any)
	local front, _back, _center, length = sectionBounds(section)
	if not front or not length then return end
	departmentFrame(folder, section, style, 27.0, 3.0, {0.16,0.38,0.60,0.82}, 1.6)
	for _, t in {0.28,0.58,0.86} do
		local z = front-length*t
		makePart(folder, "ResearchBridge", Vector3.new(122,1.1,2.0), CFrame.new(0,22.5,z), Color3.fromRGB(62,71,82), Enum.Material.Metal, 0, false)
		makePart(folder, "EnergyRail", Vector3.new(88,0.34,0.40), CFrame.new(0,21.2,z), if t == 0.58 then Color3.fromRGB(209,64,142) else style.Accent, Enum.Material.Neon, 0.48, false)
	end
	addDepartmentLight(folder, Vector3.new(0,24.5,front-length*0.30), Color3.fromRGB(170,225,235), 32, 0.82)
	addDepartmentLight(folder, Vector3.new(0,24.5,front-length*0.74), Color3.fromRGB(228,145,202), 32, 0.78)
end

local DEPARTMENT_BUILDERS = table.freeze({
	Furniture = addFurnitureDepartment,
	Electronics = addElectronicsDepartment,
	Recreation = addRecreationDepartment,
	GarageAuto = addGarageDepartment,
	Construction = addConstructionDepartment,
	HeavyGoods = addHeavyDepartment,
	Industrial = addIndustrialDepartment,
	PremiumInteriors = addPremiumDepartment,
	LuxuryGoods = addLuxuryDepartment,
	ArtCollectibles = addArtDepartment,
	Secure = addSecureDepartment,
	RestrictedPrototype = addRestrictedDepartment,
})

local function prepareSection(section: Model, sectionId: string, style: any)
	local oldIdentity = section:FindFirstChild("M6A3Identity")
	if oldIdentity then oldIdentity:Destroy() end
	local oldStorage = section:FindFirstChild("StorageStructures")
	if oldStorage then oldStorage:Destroy() end
	local oldDeep = section:FindFirstChild("M6BDeepDepartment")
	if oldDeep then oldDeep:Destroy() end

	local folder = Instance.new("Folder")
	folder.Name = "M6BDeepDepartment"
	folder:SetAttribute("SectionId", sectionId)
	folder:SetAttribute("StorageFamily", style.Family)
	folder.Parent = section

	local builder = DEPARTMENT_BUILDERS[sectionId]
	if builder then builder(folder, section, style) end
end

function Service.Build(root: Folder)
	local slots = root:FindFirstChild("M6BStorageSlots")
	if not slots or not slots:IsA("Folder") then
		slots = Instance.new("Folder")
		slots.Name = "M6BStorageSlots"
		slots.Parent = root
	end

	local gameplay = root:FindFirstChild("WarehouseGameplay")
	local sections = gameplay and gameplay:FindFirstChild("Sections")
	if sections then
		for sectionId in DEEP_SECTIONS do
			local section = sections:FindFirstChild(sectionId)
			local style = ArtConfig.SectionStyles[sectionId]
			if section and section:IsA("Model") and style then
				prepareSection(section, sectionId, style)
			end
		end
	end

	local markers = root:FindFirstChild("ItemSpawns")
	local slotCount = 0
	if markers then
		for _, marker in markers:GetChildren() do
			if marker:IsA("BasePart") then
				local sectionId = marker:GetAttribute("SectorName")
				if typeof(sectionId) == "string" and DEEP_SECTIONS[sectionId] == true then
					local style = ArtConfig.SectionStyles[sectionId]
					local builder = SLOT_BUILDERS[sectionId]
					if style and builder then
						local old = slots:FindFirstChild(marker.Name)
						if old then old:Destroy() end
						local model = Instance.new("Model")
						model.Name = marker.Name
						model:SetAttribute("SpawnName", marker.Name)
						model:SetAttribute("SectionId", sectionId)
						model:SetAttribute("StorageFamily", style.Family)
						model:SetAttribute("OpportunityKind", marker:GetAttribute("OpportunityKind") or "StorageOpportunity")
						model:SetAttribute("DepthStorageTier", sectionId)
						model.Parent = slots
						builder(model, marker, style, markerIsFocal(marker))
						slotCount += 1
					end
				end
			end
		end
	end

	root:SetAttribute("M6BDeepStorageArchitecture", true)
	root:SetAttribute("M6BDeepStorageSlotCount", slotCount)
	root:SetAttribute("M6BStorageProgressionRule", "Normal>Specialized>Heavy>Advanced>Premium>Collector>Vault>Experimental")
end

return Service
