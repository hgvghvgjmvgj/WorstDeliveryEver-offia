local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local PrototypeMap = {}

local COLORS = {
	Grass = Color3.fromRGB(104, 212, 111),
	Road = Color3.fromRGB(52, 59, 73),
	Concrete = Color3.fromRGB(216, 222, 232),
	Driveway = Color3.fromRGB(91, 101, 120),
	Roof = Color3.fromRGB(48, 59, 80),
	Dark = Color3.fromRGB(37, 42, 55),
	White = Color3.fromRGB(248, 248, 244),
	Window = Color3.fromRGB(112, 204, 245),
	TruckBlue = Color3.fromRGB(70, 142, 255),
	TruckLight = Color3.fromRGB(213, 235, 255),
	Tree = Color3.fromRGB(66, 162, 80),
	TreeLight = Color3.fromRGB(89, 195, 97),
	Trunk = Color3.fromRGB(118, 79, 54),
}

local THEMES = {
	{Body = Color3.fromRGB(255, 225, 172), Accent = Color3.fromRGB(72, 177, 196)},
	{Body = Color3.fromRGB(244, 201, 190), Accent = Color3.fromRGB(227, 105, 98)},
	{Body = Color3.fromRGB(201, 225, 247), Accent = Color3.fromRGB(76, 145, 219)},
	{Body = Color3.fromRGB(224, 209, 244), Accent = Color3.fromRGB(139, 101, 199)},
}

local function makePart(parent, name, size, cframe, color, canCollide, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = canCollide ~= false
	part.CanTouch = part.CanCollide
	part.CanQuery = true
	part.Material = material or Enum.Material.SmoothPlastic
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeFurnitureBlocker(parent, name, size, cframe, color)
	local part = makePart(parent, name, size, cframe, color, true)
	part:SetAttribute("MoveBlocker", true)
	return part
end

local function makeBall(parent, name, size, position, color)
	local part = makePart(parent, name, size, CFrame.new(position), color, false)
	part.Shape = Enum.PartType.Ball
	return part
end

local function addBillboard(part, text, offset, size, backgroundColor, maxDistance)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = size or UDim2.fromOffset(330, 70)
	gui.StudsOffset = offset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = maxDistance or 115
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.08
	label.BackgroundColor3 = backgroundColor or COLORS.Dark
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = text
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label
end

local function addTree(parent, x, z, scale)
	scale = scale or 1
	makePart(
		parent,
		"TreeTrunk",
		Vector3.new(1.2 * scale, 5.2 * scale, 1.2 * scale),
		CFrame.new(x, 2.6 * scale, z),
		COLORS.Trunk,
		false
	)
	makeBall(parent, "TreeCanopy", Vector3.new(6.0, 5.2, 6.0) * scale, Vector3.new(x, 6.2 * scale, z), COLORS.Tree)
	makeBall(
		parent,
		"TreeHighlight",
		Vector3.new(3.8, 3.5, 3.8) * scale,
		Vector3.new(x - 1.1 * scale, 7.1 * scale, z - 0.5 * scale),
		COLORS.TreeLight
	)
end

local function addTruck(parent, baseCFrame, labelText)
	local truck = Instance.new("Model")
	truck.Name = "MovingTruck"
	truck.Parent = parent

	makePart(truck, "CargoBox", Vector3.new(18, 10, 16), baseCFrame * CFrame.new(0, 5.2, 0), COLORS.TruckBlue, true)
	makePart(truck, "CargoStripe", Vector3.new(18.25, 2, 16.15), baseCFrame * CFrame.new(0, 5.4, 0), COLORS.TruckLight, false)
	makePart(truck, "Cab", Vector3.new(15, 7, 8), baseCFrame * CFrame.new(0, 3.5, -11), Color3.fromRGB(62, 126, 225), true)
	makePart(truck, "Windshield", Vector3.new(10.5, 3.1, 0.3), baseCFrame * CFrame.new(0, 5.1, -15.15), COLORS.Window, false)

	for _, x in {-6.8, 6.8} do
		for _, z in {-9.5, 3} do
			makePart(truck, "Wheel", Vector3.new(1.3, 3.2, 3.2), baseCFrame * CFrame.new(x, 1.4, z), COLORS.Dark, false)
		end
	end

	if labelText then
		local anchor = makePart(truck, "TruckLabelAnchor", Vector3.new(1, 1, 1), baseCFrame * CFrame.new(0, 10.7, 1), COLORS.White, false)
		anchor.Transparency = 1
		addBillboard(anchor, labelText, Vector3.zero, UDim2.fromOffset(290, 58), Color3.fromRGB(48, 107, 207), 95)
	end
end

local function addJobPlot(parent, index, position, theme)
	local plot = Instance.new("Model")
	plot.Name = ("JobPlot%d"):format(index)
	plot:SetAttribute("PlotIndex", index)
	plot:SetAttribute("OccupiedUserId", 0)
	plot.Parent = parent

	local origin = makePart(
		plot,
		"Origin",
		Vector3.new(1, 1, 1),
		CFrame.new(position),
		Color3.new(1, 1, 1),
		false
	)
	origin.Transparency = 1

	local art = Instance.new("Folder")
	art.Name = "Art"
	art.Parent = plot

	local function localPart(name, size, localCFrame, color, canCollide)
		return makePart(art, name, size, origin.CFrame * localCFrame, color, canCollide)
	end

	localPart("PlotLawn", Vector3.new(92, 0.35, 98), CFrame.new(0, 0.12, 16), COLORS.Grass, false)
	localPart("Driveway", Vector3.new(26, 0.28, 42), CFrame.new(0, 0.16, -7), COLORS.Driveway, false)
	localPart("FrontWalk", Vector3.new(10, 0.3, 18), CFrame.new(0, 0.18, 8), COLORS.Concrete, false)
	localPart("InteriorFloor", Vector3.new(72, 0.2, 42), CFrame.new(0, 0.22, 31), Color3.fromRGB(226, 217, 200), false)
	localPart("Roof", Vector3.new(88, 1.3, 18), CFrame.new(0, 13.25, 16), COLORS.Roof, false)
	localPart("Fascia", Vector3.new(88, 1.0, 1.2), CFrame.new(0, 12.45, 8.9), theme.Accent, false)
	localPart("Porch", Vector3.new(20, 0.38, 6), CFrame.new(0, 0.18, 7), COLORS.Concrete, false)

	for _, x in {-27, -18, 18, 27} do
		localPart("Window", Vector3.new(7, 4.5, 0.35), CFrame.new(x, 6.2, 8.72), COLORS.Window, false)
		localPart("WindowTop", Vector3.new(7.6, 0.35, 0.45), CFrame.new(x, 8.55, 8.65), COLORS.White, false)
	end

	-- These are the hard furniture boundaries. The kinematic furniture controller
	-- only respects parts marked MoveBlocker.
	makeFurnitureBlocker(
		plot,
		"FurnitureBoundaryLeft",
		Vector3.new(1, 8, 108),
		origin.CFrame * CFrame.new(-43, 4, 22),
		COLORS.White
	)
	makeFurnitureBlocker(
		plot,
		"FurnitureBoundaryRight",
		Vector3.new(1, 8, 108),
		origin.CFrame * CFrame.new(43, 4, 22),
		COLORS.White
	)

	local playerSpawn = makePart(
		plot,
		"PlayerSpawn",
		Vector3.new(2, 1, 2),
		origin.CFrame * CFrame.new(9, 0.6, -18),
		Color3.new(1, 1, 1),
		false
	)
	playerSpawn.Transparency = 1

	local labelAnchor = makePart(
		plot,
		"PlotLabelAnchor",
		Vector3.new(1, 1, 1),
		origin.CFrame * CFrame.new(0, 8, -12),
		Color3.new(1, 1, 1),
		false
	)
	labelAnchor.Transparency = 1
	addBillboard(
		labelAnchor,
		("JOB SITE %d"):format(index),
		Vector3.zero,
		UDim2.fromOffset(230, 54),
		theme.Accent,
		95
	)

	addTruck(art, origin.CFrame * CFrame.new(0, 0, -28), nil)

	local roundObject = Instance.new("Folder")
	roundObject.Name = "RoundObject"
	roundObject.Parent = plot

	local challengeGeometry = Instance.new("Folder")
	challengeGeometry.Name = "ChallengeGeometry"
	challengeGeometry.Parent = plot

	local roundMarkers = Instance.new("Folder")
	roundMarkers.Name = "RoundMarkers"
	roundMarkers.Parent = plot

	return plot
end

local function addHQ(parent)
	local hq = Instance.new("Folder")
	hq.Name = "MovingCompanyHQ"
	hq.Parent = parent

	makePart(hq, "HQPad", Vector3.new(118, 0.35, 74), CFrame.new(0, 0.14, -164), COLORS.Concrete, false)
	makePart(hq, "Office", Vector3.new(54, 14, 28), CFrame.new(-24, 7, -176), Color3.fromRGB(244, 238, 219), true)
	makePart(hq, "OfficeRoof", Vector3.new(58, 1.3, 32), CFrame.new(-24, 14.2, -176), COLORS.Roof, false)
	makePart(hq, "GarageDoor", Vector3.new(19, 9, 0.45), CFrame.new(-24, 5, -190.2), COLORS.TruckBlue, false)

	local sign = makePart(hq, "SignAnchor", Vector3.new(1, 1, 1), CFrame.new(-24, 15.7, -190), COLORS.White, false)
	sign.Transparency = 1
	addBillboard(sign, "GET IT IN! MOVING CO.", Vector3.zero, UDim2.fromOffset(350, 68), Color3.fromRGB(48, 107, 207), 130)

	-- Vehicle bays are deliberately reserved now. The actual drivable vehicle
	-- system comes only after independent jobs are proven.
	for i = 1, 4 do
		local x = 14 + (i - 1) * 21
		makePart(hq, ("VehicleBay%d"):format(i), Vector3.new(16, 0.24, 30), CFrame.new(x, 0.18, -165), Color3.fromRGB(164, 173, 188), false)
	end

	local garage = makePart(hq, "GarageFutureAnchor", Vector3.new(1, 1, 1), CFrame.new(46, 7, -183), COLORS.White, false)
	garage.Transparency = 1
	addBillboard(
		garage,
		"VEHICLE GARAGE\nVANS • TRUCKS • UPGRADES",
		Vector3.zero,
		UDim2.fromOffset(310, 92),
		Color3.fromRGB(65, 74, 92),
		110
	)

	local lobbySpawn = Instance.new("SpawnLocation")
	lobbySpawn.Name = "LobbySpawn"
	lobbySpawn.Size = Vector3.new(8, 1, 8)
	lobbySpawn.CFrame = CFrame.lookAt(Vector3.new(0, 0.6, -145), Vector3.new(0, 0.6, -120))
	lobbySpawn.Anchored = true
	lobbySpawn.CanCollide = false
	lobbySpawn.Neutral = true
	lobbySpawn.Duration = 0
	lobbySpawn.Transparency = 1
	lobbySpawn.Parent = hq
end

local function configureLighting()
	Lighting.Brightness = 2.4
	Lighting.ClockTime = 14.2
	Lighting.Ambient = Color3.fromRGB(118, 125, 148)
	Lighting.OutdoorAmbient = Color3.fromRGB(152, 162, 185)
	Lighting.ShadowSoftness = 0.22
	Lighting.EnvironmentDiffuseScale = 0.7
	Lighting.EnvironmentSpecularScale = 0.35

	for _, name in {"GetItInColor", "GetItInBloom"} do
		local existing = Lighting:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
	end

	local color = Instance.new("ColorCorrectionEffect")
	color.Name = "GetItInColor"
	color.Brightness = 0.02
	color.Contrast = 0.06
	color.Saturation = 0.12
	color.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "GetItInBloom"
	bloom.Intensity = 0.12
	bloom.Size = 20
	bloom.Threshold = 1.8
	bloom.Parent = Lighting
end

local function clearTemplateWorld()
	local existing = Workspace:FindFirstChild("GetItInPrototype")
	if existing then
		existing:Destroy()
	end

	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate:Destroy()
	end

	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("SpawnLocation") then
			descendant:Destroy()
		end
	end
end

function PrototypeMap.Build()
	clearTemplateWorld()
	configureLighting()

	local world = Instance.new("Folder")
	world.Name = "GetItInPrototype"
	world.Parent = Workspace

	local environment = Instance.new("Folder")
	environment.Name = "Environment"
	environment.Parent = world

	-- Large enough to read as a town foundation, but deliberately not the final
	-- car-scale map yet. Driving gets added before we spread sites farther apart.
	makePart(environment, "TownGround", Vector3.new(460, 2, 460), CFrame.new(0, -1, 0), COLORS.Grass, true)
	makePart(environment, "MainRoad", Vector3.new(30, 0.24, 390), CFrame.new(0, 0.08, 22), COLORS.Road, false)
	makePart(environment, "SouthCrossRoad", Vector3.new(420, 0.24, 26), CFrame.new(0, 0.08, -70), COLORS.Road, false)
	makePart(environment, "NorthCrossRoad", Vector3.new(420, 0.24, 26), CFrame.new(0, 0.08, 78), COLORS.Road, false)

	for z = -145, 170, 28 do
		makePart(environment, "CenterLine", Vector3.new(0.55, 0.05, 12), CFrame.new(0, 0.21, z), Color3.fromRGB(247, 210, 81), false)
	end

	addHQ(environment)

	local jobPlots = Instance.new("Folder")
	jobPlots.Name = "JobPlots"
	jobPlots.Parent = world

	addJobPlot(jobPlots, 1, Vector3.new(-112, 0, -12), THEMES[1])
	addJobPlot(jobPlots, 2, Vector3.new(112, 0, -12), THEMES[2])
	addJobPlot(jobPlots, 3, Vector3.new(-112, 0, 135), THEMES[3])
	addJobPlot(jobPlots, 4, Vector3.new(112, 0, 135), THEMES[4])

	for _, entry in {
		{-205, -120, 1.0}, {-175, -115, 0.9}, {-70, -118, 1.0}, {70, -118, 0.9}, {175, -118, 1.0}, {205, -110, 0.9},
		{-205, 65, 1.0}, {-42, 55, 0.9}, {42, 55, 1.0}, {205, 62, 0.9},
		{-205, 200, 1.0}, {-65, 205, 1.0}, {65, 205, 0.9}, {205, 198, 1.0}
	} do
		addTree(environment, entry[1], entry[2], entry[3])
	end

	local borderColor = Color3.fromRGB(63, 146, 77)
	makePart(environment, "NorthBorder", Vector3.new(460, 18, 4), CFrame.new(0, 9, 228), borderColor, true)
	makePart(environment, "SouthBorder", Vector3.new(460, 18, 4), CFrame.new(0, 9, -228), borderColor, true)
	makePart(environment, "WestBorder", Vector3.new(4, 18, 460), CFrame.new(-228, 9, 0), borderColor, true)
	makePart(environment, "EastBorder", Vector3.new(4, 18, 460), CFrame.new(228, 9, 0), borderColor, true)

	return world
end

return PrototypeMap
