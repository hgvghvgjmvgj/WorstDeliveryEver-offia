--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GameConfig"))

local WorldService = {}

local ROOT_NAME = "OneTripPrototype"

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	transparency: number?
): Part
	local instance = Instance.new("Part")
	instance.Name = name
	instance.Size = size
	instance.CFrame = cframe
	instance.Anchored = true
	instance.CanCollide = true
	instance.TopSurface = Enum.SurfaceType.Smooth
	instance.BottomSurface = Enum.SurfaceType.Smooth
	instance.Color = color
	instance.Transparency = transparency or 0
	instance.Parent = parent
	return instance
end

local function addBillboard(
	adornee: BasePart,
	name: string,
	text: string,
	color: Color3?,
	size: UDim2?
): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Adornee = adornee
	gui.Size = size or UDim2.fromOffset(220, 54)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
	gui.AlwaysOnTop = true
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

local function buildItemClusters(root: Folder)
	local world = GameConfig.World
	local itemConfig = GameConfig.Items

	local itemFloor = makePart(
		root,
		"ItemFloor",
		world.ItemFloorSize,
		CFrame.new(world.ItemFloorCenter),
		Color3.fromRGB(76, 82, 92)
	)
	itemFloor.CanCollide = false
	itemFloor.Material = Enum.Material.SmoothPlastic

	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "ItemSpawns"
	spawnFolder.Parent = root

	local clustersFolder = Instance.new("Folder")
	clustersFolder.Name = "ItemClusters"
	clustersFolder.Parent = root

	for clusterIndex, cluster in itemConfig.Clusters do
		local clusterModel = Instance.new("Model")
		clusterModel.Name = cluster.Name
		clusterModel:SetAttribute("ClusterIndex", clusterIndex)
		clusterModel.Parent = clustersFolder

		local pad = makePart(
			clusterModel,
			"Pad",
			Vector3.new(43, 0.10, 28),
			CFrame.new(cluster.Center),
			Color3.fromRGB(91, 97, 108),
			0.68
		)
		pad.CanCollide = false

		local labelAnchor = makePart(
			clusterModel,
			"LabelAnchor",
			Vector3.new(1, 1, 1),
			CFrame.new(cluster.Center + Vector3.new(0, 0.8, 0)),
			Color3.new(1, 1, 1),
			1
		)
		labelAnchor.CanCollide = false
		addBillboard(
			labelAnchor,
			"ClusterLabel",
			cluster.Name,
			Color3.fromRGB(226, 230, 237),
			UDim2.fromOffset(185, 42)
		)

		for index, itemId in cluster.Items do
			local columns = itemConfig.ClusterColumns
			local row = math.floor((index - 1) / columns)
			local column = (index - 1) % columns
			local x = (column - (columns - 1) * 0.5) * itemConfig.ClusterSpacingX
			local z = (row - 0.5) * itemConfig.ClusterSpacingZ
			local position = cluster.Center + Vector3.new(x, 0, z)

			local marker = makePart(
				spawnFolder,
				("C%02d_S%02d_%s"):format(clusterIndex, index, itemId),
				Vector3.new(1.6, 0.12, 1.6),
				CFrame.new(position),
				Color3.fromRGB(124, 131, 143),
				0.82
			)
			marker.CanCollide = false
			marker:SetAttribute("ItemId", itemId)
			marker:SetAttribute("ClusterName", cluster.Name)
			marker:SetAttribute("RestockSeconds", itemConfig.RestockSeconds[itemId] or 1.8)
		end
	end
end

local function buildBay(baysFolder: Folder, index: number)
	local world = GameConfig.World
	local angle = ((index - 1) / world.BayCount) * math.pi * 2
	local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
	local position = direction * world.BayRadius
	local bayCFrame = CFrame.lookAt(position, Vector3.new(0, position.Y, 0))

	local bay = Instance.new("Model")
	bay.Name = ("Bay%02d"):format(index)
	bay:SetAttribute("BayIndex", index)
	bay:SetAttribute("OwnerUserId", 0)
	bay:SetAttribute("OwnerName", "")
	bay.Parent = baysFolder

	local pad = makePart(
		bay,
		"BayPad",
		world.BayPadSize,
		bayCFrame,
		Color3.fromRGB(65, 76, 94)
	)
	pad.Material = Enum.Material.Concrete

	local boundary = makePart(
		bay,
		"BayBoundary",
		Vector3.new(world.BayPadSize.X + 1.6, 0.12, world.BayPadSize.Z + 1.6),
		bayCFrame * CFrame.new(0, 0.22, 0),
		Color3.fromRGB(105, 119, 143),
		0.55
	)
	boundary.CanCollide = false

	local unload = makePart(
		bay,
		"UnloadZone",
		world.BayUnloadSize,
		bayCFrame * world.BayUnloadOffset,
		Color3.fromRGB(84, 195, 122),
		0.28
	)
	unload.CanCollide = false
	unload.CanTouch = true
	unload:SetAttribute("BayIndex", index)

	local van = Instance.new("Model")
	van.Name = "Van"
	van.Parent = bay

	local vanBody = makePart(
		van,
		"Body",
		Vector3.new(11.5, 5.0, 7.5),
		bayCFrame * world.BayVanOffset,
		Color3.fromRGB(126, 132, 143)
	)
	vanBody.Material = Enum.Material.SmoothPlastic

	local vanCab = makePart(
		van,
		"Cab",
		Vector3.new(8.0, 4.2, 4.0),
		bayCFrame * world.BayVanOffset * CFrame.new(0, -0.25, -5.0),
		Color3.fromRGB(148, 154, 164)
	)
	vanCab.Material = Enum.Material.SmoothPlastic

	local spawnMarker = makePart(
		bay,
		"SpawnMarker",
		Vector3.new(1, 1, 1),
		bayCFrame * world.BaySpawnOffset,
		Color3.new(1, 1, 1),
		1
	)
	spawnMarker.CanCollide = false
	spawnMarker.CanTouch = false
	spawnMarker.CanQuery = false

	local labelAnchor = makePart(
		bay,
		"OwnerLabelAnchor",
		Vector3.new(1, 1, 1),
		bayCFrame * CFrame.new(0, 4.0, 5.5),
		Color3.new(1, 1, 1),
		1
	)
	labelAnchor.CanCollide = false
	labelAnchor.CanTouch = false
	labelAnchor.CanQuery = false

	local label = addBillboard(
		labelAnchor,
		"OwnerLabel",
		("OPEN BAY %02d"):format(index),
		Color3.fromRGB(185, 193, 207),
		UDim2.fromOffset(240, 62)
	)
	label:SetAttribute("BayIndex", index)

	bay.PrimaryPart = pad
end

function WorldService.Build(): Folder
	local previous = Workspace:FindFirstChild(ROOT_NAME)
	if previous then
		previous:Destroy()
	end

	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace

	local world = GameConfig.World

	local floor = makePart(
		root,
		"WarehouseFloor",
		world.FootprintSize,
		CFrame.new(0, -0.5, 0),
		Color3.fromRGB(46, 50, 57)
	)
	floor.Material = Enum.Material.Concrete

	buildItemClusters(root)

	local baysFolder = Instance.new("Folder")
	baysFolder.Name = "Bays"
	baysFolder.Parent = root

	for index = 1, world.BayCount do
		buildBay(baysFolder, index)
	end

	local fallbackSpawn = Instance.new("SpawnLocation")
	fallbackSpawn.Name = "FallbackSpawn"
	fallbackSpawn.Size = Vector3.new(6, 1, 6)
	fallbackSpawn.CFrame = CFrame.lookAt(
		world.FallbackSpawnPosition,
		Vector3.new(0, world.FallbackSpawnPosition.Y, 0)
	)
	fallbackSpawn.Anchored = true
	fallbackSpawn.CanCollide = false
	fallbackSpawn.Neutral = true
	fallbackSpawn.Duration = 0
	fallbackSpawn.Transparency = 1
	fallbackSpawn.Parent = root

	local warehouseLabel = makePart(
		root,
		"WarehouseLabel",
		Vector3.new(1, 1, 1),
		CFrame.new(0, 1, -61),
		Color3.new(1, 1, 1),
		1
	)
	warehouseLabel.CanCollide = false
	addBillboard(
		warehouseLabel,
		"WarehouseLabelGui",
		"SHARED ITEM FLOOR",
		Color3.fromRGB(234, 237, 242),
		UDim2.fromOffset(300, 58)
	)

	local feedback = Instance.new("Folder")
	feedback.Name = "Feedback"
	feedback.Parent = root

	local wallColor = Color3.fromRGB(64, 68, 76)
	local halfX = world.FootprintSize.X * 0.5
	local halfZ = world.FootprintSize.Z * 0.5

	makePart(
		root,
		"NorthWall",
		Vector3.new(world.FootprintSize.X, 12, 1),
		CFrame.new(0, 6, halfZ),
		wallColor
	)
	makePart(
		root,
		"SouthWall",
		Vector3.new(world.FootprintSize.X, 12, 1),
		CFrame.new(0, 6, -halfZ),
		wallColor
	)
	makePart(
		root,
		"WestWall",
		Vector3.new(1, 12, world.FootprintSize.Z),
		CFrame.new(-halfX, 6, 0),
		wallColor
	)
	makePart(
		root,
		"EastWall",
		Vector3.new(1, 12, world.FootprintSize.Z),
		CFrame.new(halfX, 6, 0),
		wallColor
	)

	return root
end

return WorldService
