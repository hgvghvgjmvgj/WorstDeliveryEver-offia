local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("GetItInConfig"))

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
	gui.MaxDistance = 55
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

local function markBlocker(part)
	part:SetAttribute("MoveBlocker", true)
	return part
end

function PrototypeMap.Build()
	local oldOneTrip = Workspace:FindFirstChild("OneTripPrototype")
	if oldOneTrip then
		oldOneTrip:Destroy()
	end

	local existing = Workspace:FindFirstChild("GetItInPrototype")
	if existing then
		existing:Destroy()
	end

	local world = Instance.new("Folder")
	world.Name = "GetItInPrototype"
	world.Parent = Workspace

	makePart(
		world,
		"Ground",
		Vector3.new(70, 1, 80),
		CFrame.new(0, -0.5, 3),
		Color3.fromRGB(78, 207, 96)
	)

	makePart(
		world,
		"Path",
		Vector3.new(25, 0.35, 66),
		CFrame.new(0, 0.18, 2),
		Color3.fromRGB(108, 116, 134)
	)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PrototypeSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.lookAt(Vector3.new(0, 1, -27), Vector3.new(0, 1, -12))
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Transparency = 0.5
	spawn.Color = Color3.fromRGB(78, 170, 255)
	spawn.Parent = world

	local objectiveSign = makePart(
		world,
		"ObjectiveSign",
		Vector3.new(8, 1, 1),
		CFrame.new(0, 6, -20),
		Color3.fromRGB(255, 211, 55),
		false
	)
	objectiveSign.Transparency = 1
	addBillboard(objectiveSign, "GET THE COUCH THROUGH THE DOOR", Vector3.zero, UDim2.fromOffset(460, 80))

	local wallColor = Color3.fromRGB(255, 201, 74)
	local wallThickness = 2
	local wallHeight = 12
	local totalWallWidth = 42
	local sideWidth = (totalWallWidth - Config.DoorWidth) / 2
	local leftX = -(Config.DoorWidth / 2 + sideWidth / 2)
	local rightX = -leftX

	markBlocker(makePart(
		world,
		"WallLeft",
		Vector3.new(sideWidth, wallHeight, wallThickness),
		CFrame.new(leftX, wallHeight / 2, Config.DoorCenterZ),
		wallColor
	))

	markBlocker(makePart(
		world,
		"WallRight",
		Vector3.new(sideWidth, wallHeight, wallThickness),
		CFrame.new(rightX, wallHeight / 2, Config.DoorCenterZ),
		wallColor
	))

	local headerHeight = wallHeight - Config.DoorHeight
	markBlocker(makePart(
		world,
		"WallHeader",
		Vector3.new(Config.DoorWidth, headerHeight, wallThickness),
		CFrame.new(0, Config.DoorHeight + headerHeight / 2, Config.DoorCenterZ),
		wallColor
	))

	local doorMarker = makePart(
		world,
		"DoorMarker",
		Vector3.new(Config.DoorWidth - 0.25, 0.2, 4),
		CFrame.new(0, 0.3, Config.DoorCenterZ),
		Color3.fromRGB(88, 174, 255),
		false
	)
	doorMarker.Transparency = 0.25

	makePart(
		world,
		"InsideFloor",
		Vector3.new(28, 0.4, 25),
		CFrame.new(0, 0.2, 21),
		Color3.fromRGB(213, 219, 231)
	)

	local finish = makePart(
		world,
		"SuccessZone",
		Vector3.new(22, 1, 6),
		CFrame.new(0, 0.6, Config.SuccessZ),
		Color3.fromRGB(77, 235, 116),
		false
	)
	finish.Transparency = 0.55
	addBillboard(finish, "INSIDE", Vector3.new(0, 2.2, 0), UDim2.fromOffset(180, 48))

	local couch = Instance.new("Part")
	couch.Name = "Couch"
	couch.Size = Config.CouchSize
	couch.CFrame = Config.CouchStartCFrame
	couch.Anchored = true
	couch.CanCollide = true
	couch.Material = Enum.Material.SmoothPlastic
	couch.Color = Color3.fromRGB(239, 73, 78)
	couch.TopSurface = Enum.SurfaceType.Smooth
	couch.BottomSurface = Enum.SurfaceType.Smooth
	couch.Parent = world

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GrabPrompt"
	prompt.ActionText = "GRAB"
	prompt.ObjectText = "Oversized Couch"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.G
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Parent = couch

	addBillboard(couch, "THIS DOES NOT FIT... RIGHT?", Vector3.new(0, 3.4, 0), UDim2.fromOffset(300, 55))

	return world
end

return PrototypeMap
