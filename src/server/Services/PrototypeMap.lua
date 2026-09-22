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
	local part = makePart(
		parent,
		name,
		size,
		CFrame.new(position),
		color,
		false,
		Enum.Material.SmoothPlastic
	)
	part.Shape = Enum.PartType.Ball
	return part
end

local function addBillboard(part, text, offset, size, backgroundColor)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = size or UDim2.fromOffset(360, 70)
	gui.StudsOffset = offset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 75
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
	makeBall(
		parent,
		"Shrub",
		Vector3.new(3.5, 2.2, 2.7) * scale,
		Vector3.new(x, 1.05 * scale, z),
		COLORS.Tree
	)
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

	-- Stylized lawn and street.
	makePart(
		environment,
		"Ground",
		Vector3.new(104, 1, 112),
		CFrame.new(0, -0.5, 4),
		COLORS.Grass,
		true
	)

	makePart(
		environment,
		"Road",
		Vector3.new(104, 0.22, 18),
		CFrame.new(0, 0.05, -47),
		COLORS.Road,
		false
	)

	makePart(
		environment,
		"Sidewalk",
		Vector3.new(104, 0.24, 5),
		CFrame.new(0, 0.08, -37),
		COLORS.Concrete,
		false
	)

	makePart(
		environment,
		"Driveway",
		Vector3.new(24, 0.26, 43),
		CFrame.new(0, 0.1, -14),
		COLORS.Driveway,
		false
	)

	makePart(
		environment,
		"FrontWalk",
		Vector3.new(11, 0.28, 20),
		CFrame.new(0, 0.12, 4),
		Color3.fromRGB(182, 190, 203),
		false
	)

	for x = -42, 42, 28 do
		makePart(
			environment,
			"LaneMark",
			Vector3.new(12, 0.05, 0.55),
			CFrame.new(x, 0.18, -47),
			Color3.fromRGB(247, 210, 81),
			false
		)
	end

	-- Keep the puzzle space honest even though the scenery extends beyond it.
	makePart(
		environment,
		"LeftBoundaryFence",
		Vector3.new(1, 5, 94),
		CFrame.new(-44, 2.5, 5),
		Color3.fromRGB(233, 236, 228),
		true
	)
	makePart(
		environment,
		"RightBoundaryFence",
		Vector3.new(1, 5, 94),
		CFrame.new(44, 2.5, 5),
		Color3.fromRGB(233, 236, 228),
		true
	)

	-- House shell: challenge walls are generated inside this visual structure.
	local house = Instance.new("Folder")
	house.Name = "HouseArt"
	house.Parent = environment

	makePart(
		house,
		"Roof",
		Vector3.new(88, 1.3, 18),
		CFrame.new(0, 13.25, 16),
		COLORS.Roof,
		false
	)
	makePart(
		house,
		"Fascia",
		Vector3.new(88, 1.15, 1.4),
		CFrame.new(0, 12.45, 8.9),
		COLORS.HouseAccent,
		false
	)
	makePart(
		house,
		"InteriorFloor",
		Vector3.new(72, 0.20, 38),
		CFrame.new(0, 0.22, 29),
		Color3.fromRGB(226, 217, 200),
		false
	)
	makePart(
		house,
		"Porch",
		Vector3.new(20, 0.38, 6),
		CFrame.new(0, 0.18, 7),
		Color3.fromRGB(198, 205, 214),
		false
	)

	-- Decorative windows/trim that do not affect puzzle collision.
	for _, x in {-27, -18, 18, 27} do
		makePart(
			house,
			"Window",
			Vector3.new(7, 4.5, 0.35),
			CFrame.new(x, 6.2, 8.72),
			COLORS.Window,
			false
		)
		makePart(
			house,
			"WindowTop",
			Vector3.new(7.6, 0.35, 0.45),
			CFrame.new(x, 8.55, 8.65),
			COLORS.White,
			false
		)
	end

	makePart(
		house,
		"HouseNumber",
		Vector3.new(4, 1.1, 0.35),
		CFrame.new(-7.8, 9.2, 8.62),
		COLORS.Dark,
		false
	)

	-- Landscape props.
	addTree(environment, -34, -20, 1.05)
	addTree(environment, 34, -16, 0.95)
	addTree(environment, -33, 35, 0.9)
	addShrub(environment, -14, 5.5, 1.15)
	addShrub(environment, 14, 5.5, 1.15)
	addShrub(environment, -22, 5.8, 0.85)
	addShrub(environment, 22, 5.8, 0.85)

	local mailbox = Instance.new("Folder")
	mailbox.Name = "Mailbox"
	mailbox.Parent = environment
	makePart(mailbox, "Post", Vector3.new(0.7, 4.2, 0.7), CFrame.new(20, 2.1, -34), COLORS.White, false)
	makePart(mailbox, "Box", Vector3.new(3.2, 1.8, 1.7), CFrame.new(20, 4.5, -34), COLORS.HouseAccent, false)
	makePart(mailbox, "Flag", Vector3.new(0.25, 2.3, 0.3), CFrame.new(21.75, 5.0, -34), Color3.fromRGB(239, 73, 78), false)

	-- Stylized moving truck.
	local truck = Instance.new("Model")
	truck.Name = "MovingTruck"
	truck.Parent = environment

	makePart(
		truck,
		"CargoBox",
		Vector3.new(18, 10, 16),
		CFrame.new(0, 5.2, -29.5),
		COLORS.TruckBlue,
		true
	)
	makePart(
		truck,
		"CargoStripe",
		Vector3.new(18.25, 2.1, 16.15),
		CFrame.new(0, 5.4, -29.5),
		COLORS.TruckLight,
		false
	)
	makePart(
		truck,
		"Cab",
		Vector3.new(15, 7, 8),
		CFrame.new(0, 3.5, -40.5),
		Color3.fromRGB(63, 127, 226),
		true
	)
	makePart(
		truck,
		"Windshield",
		Vector3.new(10.5, 3.2, 0.3),
		CFrame.new(0, 5.1, -44.65),
		Color3.fromRGB(116, 205, 239),
		false
	)
	makePart(
		truck,
		"RearOpening",
		Vector3.new(14.5, 7.2, 0.35),
		CFrame.new(0, 4.2, -21.35),
		COLORS.Dark,
		false
	)
	makePart(
		truck,
		"LoadingRamp",
		Vector3.new(12, 0.35, 8),
		CFrame.new(0, 0.32, -18),
		Color3.fromRGB(111, 122, 143),
		false
	)

	for _, x in {-6.8, 6.8} do
		for _, z in {-39.5, -27} do
			makePart(
				truck,
				"Wheel",
				Vector3.new(1.3, 3.2, 3.2),
				CFrame.new(x, 1.4, z),
				COLORS.Dark,
				false
			)
		end
	end

	local truckLabel = makePart(
		truck,
		"TruckLabelAnchor",
		Vector3.new(1, 1, 1),
		CFrame.new(0, 10.5, -28),
		Color3.new(1, 1, 1),
		false
	)
	truckLabel.Transparency = 1
	addBillboard(
		truckLabel,
		"GET IT IN! MOVING CO.",
		Vector3.zero,
		UDim2.fromOffset(330, 62),
		Color3.fromRGB(48, 107, 207)
	)

	addBoxStack(environment, -10, -15, -8)
	addBoxStack(environment, 10, -13, 12)
	addBoxStack(environment, -14, -25, 6)

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

	local objectiveSign = makePart(
		environment,
		"ObjectiveSign",
		Vector3.new(1, 1, 1),
		CFrame.new(0, 7, -10),
		Color3.new(1, 1, 1),
		false
	)
	objectiveSign.Transparency = 1
	addBillboard(
		objectiveSign,
		"GET IT IN!",
		Vector3.zero,
		UDim2.fromOffset(280, 62),
		Color3.fromRGB(237, 86, 83)
	)

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
