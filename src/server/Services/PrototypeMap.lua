local Workspace = game:GetService("Workspace")

local PrototypeMap = {}

local function makePart(parent, name, size, cframe, color, canCollide)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = canCollide ~= false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addBillboard(part, text, offset, size)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = size or UDim2.fromOffset(360, 70)
	gui.StudsOffset = offset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 65
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.15
	label.BackgroundColor3 = Color3.fromRGB(26, 27, 34)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = text
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
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

	local world = Instance.new("Folder")
	world.Name = "GetItInPrototype"
	world.Parent = Workspace

	makePart(
		world,
		"Ground",
		Vector3.new(90, 1, 100),
		CFrame.new(0, -0.5, 5),
		Color3.fromRGB(78, 207, 96)
	)

	makePart(
		world,
		"Path",
		Vector3.new(28, 0.35, 78),
		CFrame.new(0, 0.18, 0),
		Color3.fromRGB(108, 116, 134)
	)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PrototypeSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.lookAt(Vector3.new(9, 0.6, -18), Vector3.new(0, 0.6, -12))
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 1
	spawn.Parent = world

	local truck = Instance.new("Model")
	truck.Name = "MovingTruck"
	truck.Parent = world

	makePart(
		truck,
		"TruckBox",
		Vector3.new(18, 10, 16),
		CFrame.new(0, 5, -31),
		Color3.fromRGB(87, 147, 255)
	)
	makePart(
		truck,
		"OpenBay",
		Vector3.new(15, 7, 1),
		CFrame.new(0, 4, -22.5),
		Color3.fromRGB(42, 47, 61),
		false
	)

	local truckLabel = makePart(
		truck,
		"TruckLabelAnchor",
		Vector3.new(1, 1, 1),
		CFrame.new(0, 10.5, -25),
		Color3.new(1, 1, 1),
		false
	)
	truckLabel.Transparency = 1
	addBillboard(truckLabel, "MOVING DAY", Vector3.zero, UDim2.fromOffset(270, 60))

	local objectiveSign = makePart(
		world,
		"ObjectiveSign",
		Vector3.new(1, 1, 1),
		CFrame.new(0, 7, -17),
		Color3.new(1, 1, 1),
		false
	)
	objectiveSign.Transparency = 1
	addBillboard(objectiveSign, "GET IT IN!", Vector3.zero, UDim2.fromOffset(340, 72))

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
