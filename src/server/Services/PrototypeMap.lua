local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local PrototypeMap = {}

local COLORS = {
	Grass = Color3.fromRGB(105, 214, 112),
	GrassDark = Color3.fromRGB(78, 181, 92),
	Driveway = Color3.fromRGB(91, 101, 120),
	Road = Color3.fromRGB(53, 60, 75),
	Concrete = Color3.fromRGB(215, 220, 229),
	House = Color3.fromRGB(255, 225, 172),
	HouseAccent = Color3.fromRGB(72, 177, 196),
	Roof = Color3.fromRGB(49, 61, 83),
	TruckBlue = Color3.fromRGB(72, 143, 255),
	TruckLight = Color3.fromRGB(214, 235, 255),
	Window = Color3.fromRGB(114, 205, 255),
	Dark = Color3.fromRGB(37, 42, 55),
	White = Color3.fromRGB(250, 250, 246),
	Box = Color3.fromRGB(210, 145, 76),
	Tree = Color3.fromRGB(65, 161, 78),
	TreeLight = Color3.fromRGB(88, 194, 96),
	Trunk = Color3.fromRGB(117, 78, 53),
	Locked = Color3.fromRGB(130, 139, 158),
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

local function makeBall(parent, name, size, position, color)
	local part = makePart(parent, name, size, CFrame.new(position), color, false)
	part.Shape = Enum.PartType.Ball
	return part
end

local function addBillboard(part, text, offset, size, backgroundColor, maxDistance)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = size or UDim2.fromOffset(360, 70)
	gui.StudsOffset = offset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = maxDistance or 105
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
		Vector3.new(1.3 * scale, 5.5 * scale, 1.3 * scale),
		CFrame.new(x, 2.75 * scale, z),
		COLORS.Trunk,
		false
	)
	makeBall(parent, "TreeCanopy", Vector3.new(6.2, 5.4, 6.2) * scale, Vector3.new(x, 6.5 * scale, z), COLORS.Tree)
	makeBall(
		parent,
		"TreeCanopyHighlight",
		Vector3.new(4.2, 3.8, 4.2) * scale,
		Vector3.new(x - 1.2 * scale, 7.4 * scale, z - 0.6 * scale),
		COLORS.TreeLight
	)
end

local function addShrub(parent, x, z, scale)
	scale = scale or 1
	makeBall(parent, "Shrub", Vector3.new(3.5, 2.2, 2.7) * scale, Vector3.new(x, 1.05 * scale, z), COLORS.Tree)
end

local function addBoxStack(parent, x, z, rotation)
	local base = CFrame.new(x, 0.85, z) * CFrame.Angles(0, math.rad(rotation or 0), 0)
	makePart(parent, "MovingBox", Vector3.new(2.8, 1.7, 2.4), base, COLORS.Box, false)
	makePart(
		parent,
		"MovingBox",
		Vector3.new(2.1, 1.5, 2),
		base * CFrame.new(0.35, 1.6, 0),
		Color3.fromRGB(230, 165, 88),
		false
	)
end

local function addDecorativeHouse(parent, x, z, rotation, bodyColor, accentColor, signText)
	local model = Instance.new("Model")
	model.Name = "NeighborhoodHouse"
	model.Parent = parent

	local yaw = math.rad(rotation or 0)
	local base = CFrame.new(x, 0, z) * CFrame.Angles(0, yaw, 0)

	makePart(model, "Body", Vector3.new(38, 12, 24), base * CFrame.new(0, 6, 0), bodyColor, true)
	makePart(model, "Roof", Vector3.new(42, 1.4, 28), base * CFrame.new(0, 12.8, 0), COLORS.Roof, false)
	makePart(model, "Accent", Vector3.new(38.2, 1.0, 0.8), base * CFrame.new(0, 10.8, -12.2), accentColor, false)
	makePart(model, "Door", Vector3.new(5, 8, 0.45), base * CFrame.new(0, 4, -12.3), accentColor, false)

	for _, windowX in {-11, 11} do
		makePart(
			model,
			"Window",
			Vector3.new(7, 4.5, 0.35),
			base * CFrame.new(windowX, 6, -12.35),
			COLORS.Window,
			false
		)
	end

	makePart(model, "Driveway", Vector3.new(15, 0.22, 24), base * CFrame.new(0, 0.11, -23), COLORS.Driveway, false)
	addShrub(model, x - 14, z - 10, 0.8)
	addShrub(model, x + 14, z - 10, 0.8)

	if signText then
		local anchor = makePart(
			model,
			"LotSignAnchor",
			Vector3.new(1, 1, 1),
			base * CFrame.new(0, 6.5, -15),
			Color3.new(1, 1, 1),
			false
		)
		anchor.Transparency = 1
		addBillboard(anchor, signText, Vector3.zero, UDim2.fromOffset(250, 56), accentColor, 120)
	end
end

local function addContractBoard(parent)
	local board = Instance.new("Model")
	board.Name = "ContractBoard"
	board.Parent = parent

	makePart(board, "PostLeft", Vector3.new(0.8, 6, 0.8), CFrame.new(-7, 3, -72), COLORS.Dark, true)
	makePart(board, "PostRight", Vector3.new(0.8, 6, 0.8), CFrame.new(7, 3, -72), COLORS.Dark, true)
	local panel = makePart(
		board,
		"Board",
		Vector3.new(18, 8, 1),
		CFrame.new(0, 7, -72),
		Color3.fromRGB(44, 53, 69),
		true
	)

	addBillboard(
		panel,
		"EARN CASH → UNLOCK HARDER JOBS\n$100 SECTIONAL • $180 GRAND PIANO",
		Vector3.new(0, 0.2, -0.7),
		UDim2.fromOffset(520, 150),
		Color3.fromRGB(44, 53, 69),
		95
	)
end

local function addMovingCompanyYard(parent)
	local yard = Instance.new("Folder")
	yard.Name = "MovingCompanyYard"
	yard.Parent = parent

	makePart(yard, "YardPad", Vector3.new(70, 0.28, 52), CFrame.new(-95, 0.14, -72), COLORS.Concrete, false)
	makePart(yard, "Office", Vector3.new(34, 12, 22), CFrame.new(-108, 6, -78), Color3.fromRGB(242, 236, 215), true)
	makePart(yard, "OfficeRoof", Vector3.new(38, 1.2, 26), CFrame.new(-108, 12.7, -78), COLORS.Roof, false)
	makePart(yard, "GarageDoor", Vector3.new(15, 8, 0.5), CFrame.new(-108, 4.5, -89.2), COLORS.TruckBlue, false)

	local anchor = makePart(yard, "CompanySignAnchor", Vector3.new(1, 1, 1), CFrame.new(-108, 13.8, -89), COLORS.White, false)
	anchor.Transparency = 1
	addBillboard(
		anchor,
		"GET IT IN! MOVING CO.",
		Vector3.zero,
		UDim2.fromOffset(340, 70),
		Color3.fromRGB(48, 107, 207),
		130
	)

	for i = 0, 3 do
		local x = -79 - i * 10
		makePart(yard, "TruckBay", Vector3.new(8, 0.18, 17), CFrame.new(x, 0.22, -68), Color3.fromRGB(157, 166, 181), false)
	end

	local upgrades = makePart(yard, "UpgradeSign", Vector3.new(1, 1, 1), CFrame.new(-78, 6.5, -87), COLORS.White, false)
	upgrades.Transparency = 1
	addBillboard(
		upgrades,
		"FUTURE: TRUCK STYLES • TOOLS • COMPANY UPGRADES",
		Vector3.zero,
		UDim2.fromOffset(330, 70),
		Color3.fromRGB(70, 78, 95),
		90
	)
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

	local oldOneTrip = Workspace:FindFirstChild("OneTripPrototype")
	if oldOneTrip then
		oldOneTrip:Destroy()
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

	-- Large neighborhood footprint. This is intentionally much larger than the active puzzle lot.
	makePart(
		environment,
		"NeighborhoodGround",
		Vector3.new(340, 2, 320),
		CFrame.new(0, -1, 0),
		COLORS.Grass,
		true
	)

	-- Main roads form a simple readable neighborhood rather than one tiny driveway.
	makePart(environment, "MainRoad", Vector3.new(320, 0.25, 24), CFrame.new(0, 0.08, -48), COLORS.Road, false)
	makePart(environment, "CrossRoad", Vector3.new(24, 0.25, 250), CFrame.new(92, 0.08, 35), COLORS.Road, false)
	makePart(environment, "NorthRoad", Vector3.new(250, 0.25, 22), CFrame.new(0, 0.08, 110), COLORS.Road, false)

	makePart(environment, "MainSidewalkNorth", Vector3.new(320, 0.18, 5), CFrame.new(0, 0.12, -33), COLORS.Concrete, false)
	makePart(environment, "MainSidewalkSouth", Vector3.new(320, 0.18, 5), CFrame.new(0, 0.12, -63), COLORS.Concrete, false)

	for x = -145, 145, 28 do
		makePart(
			environment,
			"LaneMark",
			Vector3.new(12, 0.05, 0.55),
			CFrame.new(x, 0.21, -48),
			Color3.fromRGB(247, 210, 81),
			false
		)
	end

	-- Active contract property remains in the center, with enough room to solve furniture puzzles.
	makePart(environment, "ActiveDriveway", Vector3.new(28, 0.26, 48), CFrame.new(0, 0.1, -7), COLORS.Driveway, false)
	makePart(environment, "ActiveFrontWalk", Vector3.new(11, 0.28, 20), CFrame.new(0, 0.12, 4), Color3.fromRGB(182, 190, 203), false)

	local house = Instance.new("Folder")
	house.Name = "ActiveHouseArt"
	house.Parent = environment

	makePart(house, "Roof", Vector3.new(88, 1.3, 18), CFrame.new(0, 13.25, 16), COLORS.Roof, false)
	makePart(house, "Fascia", Vector3.new(88, 1.15, 1.4), CFrame.new(0, 12.45, 8.9), COLORS.HouseAccent, false)
	makePart(house, "InteriorFloor", Vector3.new(72, 0.20, 42), CFrame.new(0, 0.22, 31), Color3.fromRGB(226, 217, 200), false)
	makePart(house, "Porch", Vector3.new(20, 0.38, 6), CFrame.new(0, 0.18, 7), Color3.fromRGB(198, 205, 214), false)

	for _, x in {-27, -18, 18, 27} do
		makePart(house, "Window", Vector3.new(7, 4.5, 0.35), CFrame.new(x, 6.2, 8.72), COLORS.Window, false)
		makePart(house, "WindowTop", Vector3.new(7.6, 0.35, 0.45), CFrame.new(x, 8.55, 8.65), COLORS.White, false)
	end

	addShrub(environment, -14, 5.5, 1.15)
	addShrub(environment, 14, 5.5, 1.15)
	addShrub(environment, -22, 5.8, 0.85)
	addShrub(environment, 22, 5.8, 0.85)

	-- Future contract lots make cash/progression visible in the world.
	addDecorativeHouse(
		environment,
		-100,
		22,
		0,
		Color3.fromRGB(244, 201, 190),
		Color3.fromRGB(227, 105, 98),
		"STARTER NEIGHBORHOOD"
	)
	addDecorativeHouse(
		environment,
		100,
		25,
		0,
		Color3.fromRGB(201, 225, 247),
		Color3.fromRGB(76, 145, 219),
		"$100 JOBS"
	)
	addDecorativeHouse(
		environment,
		-95,
		105,
		180,
		Color3.fromRGB(235, 216, 166),
		Color3.fromRGB(220, 160, 55),
		"$180 HARD JOBS"
	)
	addDecorativeHouse(
		environment,
		45,
		112,
		180,
		Color3.fromRGB(212, 197, 239),
		Color3.fromRGB(137, 99, 199),
		"FUTURE SPECIAL JOBS"
	)

	-- Additional houses make the server feel populated even before M8 gives players separate jobs.
	addDecorativeHouse(environment, 140, 86, 90, Color3.fromRGB(235, 210, 180), Color3.fromRGB(70, 172, 142), nil)
	addDecorativeHouse(environment, 142, -5, 90, Color3.fromRGB(246, 211, 218), Color3.fromRGB(212, 95, 124), nil)
	addDecorativeHouse(environment, -145, 85, -90, Color3.fromRGB(204, 232, 210), Color3.fromRGB(73, 168, 94), nil)

	addMovingCompanyYard(environment)
	addContractBoard(environment)

	-- Stylized moving truck at active lot.
	local truck = Instance.new("Model")
	truck.Name = "MovingTruck"
	truck.Parent = environment

	makePart(truck, "CargoBox", Vector3.new(18, 10, 16), CFrame.new(0, 5.2, -27.5), COLORS.TruckBlue, true)
	makePart(truck, "CargoStripe", Vector3.new(18.25, 2.1, 16.15), CFrame.new(0, 5.4, -27.5), COLORS.TruckLight, false)
	makePart(truck, "Cab", Vector3.new(15, 7, 8), CFrame.new(0, 3.5, -38.5), Color3.fromRGB(63, 127, 226), true)
	makePart(truck, "Windshield", Vector3.new(10.5, 3.2, 0.3), CFrame.new(0, 5.1, -42.65), Color3.fromRGB(116, 205, 239), false)
	makePart(truck, "RearOpening", Vector3.new(14.5, 7.2, 0.35), CFrame.new(0, 4.2, -19.35), COLORS.Dark, false)
	makePart(truck, "LoadingRamp", Vector3.new(12, 0.35, 7), CFrame.new(0, 0.32, -16), Color3.fromRGB(111, 122, 143), false)

	for _, x in {-6.8, 6.8} do
		for _, z in {-37.5, -25} do
			makePart(truck, "Wheel", Vector3.new(1.3, 3.2, 3.2), CFrame.new(x, 1.4, z), COLORS.Dark, false)
		end
	end

	local truckLabel = makePart(truck, "TruckLabelAnchor", Vector3.new(1, 1, 1), CFrame.new(0, 10.5, -26), Color3.new(1, 1, 1), false)
	truckLabel.Transparency = 1
	addBillboard(truckLabel, "GET IT IN! MOVING CO.", Vector3.zero, UDim2.fromOffset(330, 62), Color3.fromRGB(48, 107, 207), 100)

	addBoxStack(environment, -10, -14, -8)
	addBoxStack(environment, 10, -13, 12)
	addBoxStack(environment, -14, -24, 6)

	-- Trees spread through the neighborhood to break up empty sightlines.
	for _, entry in {
		{-150, -105, 1.1}, {-120, -105, 0.9}, {-65, -105, 1.0}, {-35, -105, 0.9},
		{45, -105, 1.0}, {75, -105, 0.9}, {125, -105, 1.1}, {150, -105, 0.9},
		{-155, 45, 1.0}, {-55, 60, 0.9}, {58, 65, 1.0}, {155, 45, 0.95},
		{-150, 145, 1.0}, {-55, 145, 1.0}, {60, 145, 0.9}, {145, 145, 1.1}
	} do
		addTree(environment, entry[1], entry[2], entry[3])
	end

	-- Outer border is far from the playable center, so you cannot simply jump into the void.
	local borderColor = Color3.fromRGB(64, 147, 78)
	makePart(environment, "NorthBorder", Vector3.new(340, 18, 4), CFrame.new(0, 9, 158), borderColor, true)
	makePart(environment, "SouthBorder", Vector3.new(340, 18, 4), CFrame.new(0, 9, -158), borderColor, true)
	makePart(environment, "WestBorder", Vector3.new(4, 18, 320), CFrame.new(-168, 9, 0), borderColor, true)
	makePart(environment, "EastBorder", Vector3.new(4, 18, 320), CFrame.new(168, 9, 0), borderColor, true)

	-- Active puzzle lot fences prevent furniture from bypassing the challenge while leaving the neighborhood itself large.
	makePart(environment, "ActiveLotLeftFence", Vector3.new(1, 5, 100), CFrame.new(-43, 2.5, 24), COLORS.White, true)
	makePart(environment, "ActiveLotRightFence", Vector3.new(1, 5, 100), CFrame.new(43, 2.5, 24), COLORS.White, true)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PrototypeSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.lookAt(Vector3.new(9, 0.6, -18), Vector3.new(0, 0.6, -11))
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 1
	spawn.Parent = world

	local objectiveSign = makePart(environment, "ObjectiveSign", Vector3.new(1, 1, 1), CFrame.new(0, 7, -10), Color3.new(1, 1, 1), false)
	objectiveSign.Transparency = 1
	addBillboard(objectiveSign, "ACTIVE JOB", Vector3.zero, UDim2.fromOffset(240, 58), Color3.fromRGB(237, 86, 83), 85)

	local objectFolder = Instance.new("Folder")
	objectFolder.Name = "RoundObject"
	objectFolder.Parent = world

	local challengeFolder = Instance.new("Folder")
	challengeFolder.Name = "ChallengeGeometry"
	challengeFolder.Parent = world

	local markerFolder = Instance.new("Folder")
	markerFolder.Name = "RoundMarkers"
	markerFolder.Parent = world

	return world
end

return PrototypeMap
