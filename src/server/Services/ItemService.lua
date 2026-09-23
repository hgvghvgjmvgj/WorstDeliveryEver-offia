--!strict

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local WarehouseConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("WarehouseConfig"))

local ItemService = {}

local itemFolder: Folder? = nil
local spawnFolder: Folder? = nil
local lostVisualFolder: Folder? = nil
local activeBySpawn: {[string]: BasePart} = {}
local enabledSpawns: {[string]: boolean} = {}
local sectorSpawns: {[string]: {BasePart}} = {}
local reconcileGeneration = 0

local function makeWorldItem(itemId: string, cframe: CFrame, spawnName: string?, ownerUserId: number?): Part
	assert(itemFolder, "ItemService.Start must run first")
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	assert(definition and visual, ("Unknown prototype item %s"):format(itemId))

	local item = Instance.new("Part")
	item.Name = itemId
	item.Size = visual.Size
	item.CFrame = cframe + Vector3.new(0, visual.Size.Y * 0.5 + 0.15, 0)
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = true
	item.Material = Enum.Material.SmoothPlastic
	item.Color = visual.Color
	item:SetAttribute("ItemId", itemId)
	item:SetAttribute("WorldItemId", HttpService:GenerateGUID(false))
	item:SetAttribute("Available", true)
	item:SetAttribute("ReservedByUserId", 0)
	item:SetAttribute("SpawnName", spawnName or "")
	item:SetAttribute("OwnerUserId", ownerUserId or 0)
	item:SetAttribute("ProtectedUntil", 0)
	item.Parent = itemFolder

	local gui = Instance.new("BillboardGui")
	gui.Name = "PrototypeLabel"
	gui.Adornee = item
	gui.Size = UDim2.fromOffset(160, 40)
	gui.StudsOffset = Vector3.new(0, visual.Size.Y * 0.5 + 1.25, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 42
	gui.Parent = item

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	-- World labels no longer show the obsolete pre-M3 ItemConfig.Value.
	label.Text = definition.Name
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Parent = gui
	return item
end

local function spawnStock(spawnPart: BasePart)
	if not itemFolder or enabledSpawns[spawnPart.Name] ~= true then return end
	local spawnName = spawnPart.Name
	local existing = activeBySpawn[spawnName]
	if existing and existing.Parent then return end

	local itemId = spawnPart:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or itemId == "" or not ItemConfig[itemId] then return end

	local item = makeWorldItem(itemId, spawnPart.CFrame, spawnName, nil)
	item:SetAttribute("ZoneName", spawnPart:GetAttribute("ZoneName") or "")
	item:SetAttribute("ZoneDepth", spawnPart:GetAttribute("ZoneDepth") or 0)
	item:SetAttribute("SectorName", spawnPart:GetAttribute("SectorName") or "")
	item:SetAttribute("OpportunityName", spawnPart:GetAttribute("OpportunityName") or "")
	item:SetAttribute("OpportunityKind", spawnPart:GetAttribute("OpportunityKind") or "")
	activeBySpawn[spawnName] = item

	item.Destroying:Connect(function()
		if activeBySpawn[spawnName] == item then activeBySpawn[spawnName] = nil end
	end)
end

local function scheduleRestock(spawnName: string)
	if not spawnFolder or enabledSpawns[spawnName] ~= true then return end
	local sourceSpawn = spawnFolder:FindFirstChild(spawnName)
	if not sourceSpawn or not sourceSpawn:IsA("BasePart") then return end
	local delaySeconds = sourceSpawn:GetAttribute("RestockSeconds")
	if typeof(delaySeconds) ~= "number" then delaySeconds = 1.8 end
	task.delay(delaySeconds, function()
		if sourceSpawn.Parent and itemFolder and enabledSpawns[spawnName] == true then
			spawnStock(sourceSpawn)
		end
	end)
end

local function targetPerSector(): number
	local density = WarehouseConfig.Density
	local playerCount = math.max(1, #Players:GetPlayers())
	local denominator = math.max(1, density.FullServerPlayers - 1)
	local alpha = math.clamp((playerCount - 1) / denominator, 0, 1)
	return math.clamp(
		math.floor(density.MinActivePerSector + (density.MaxActivePerSector - density.MinActivePerSector) * alpha + 0.5),
		density.MinActivePerSector,
		density.MaxActivePerSector
	)
end

local function desiredForSector(markers: {BasePart}, target: number): {[string]: boolean}
	local byDepth: {[number]: {BasePart}} = { [1] = {}, [2] = {}, [3] = {} }
	for _, marker in markers do
		local depth = marker:GetAttribute("ZoneDepth")
		if typeof(depth) == "number" and byDepth[depth] then
			table.insert(byDepth[depth], marker)
		else
			table.insert(byDepth[1], marker)
		end
	end
	for _, group in byDepth do
		table.sort(group, function(a, b) return a.Name < b.Name end)
	end

	local desired: {[string]: boolean} = {}
	local cursors = { [1] = 1, [2] = 1, [3] = 1 }
	local selected = 0
	while selected < math.min(target, #markers) do
		local addedThisPass = false
		for depth = 1, 3 do
			local group = byDepth[depth]
			local cursor = cursors[depth]
			local marker = group[cursor]
			if marker and selected < target then
				desired[marker.Name] = true
				cursors[depth] = cursor + 1
				selected += 1
				addedThisPass = true
			end
		end
		if not addedThisPass then break end
	end
	return desired
end

local function reconcileDensity()
	if not itemFolder then return end
	local target = targetPerSector()
	local nextEnabled: {[string]: boolean} = {}
	for _, markers in sectorSpawns do
		local desired = desiredForSector(markers, target)
		for spawnName in desired do nextEnabled[spawnName] = true end
	end

	-- Existing items at newly-disabled points stay in the world until someone
	-- takes them. They simply do not restock, avoiding visible despawn pop-in.
	enabledSpawns = nextEnabled
	for _, markers in sectorSpawns do
		for _, marker in markers do
			if enabledSpawns[marker.Name] then spawnStock(marker) end
		end
	end
end

local function scheduleDensityReconcile()
	reconcileGeneration += 1
	local generation = reconcileGeneration
	task.delay(WarehouseConfig.Density.ReconcileDelaySeconds, function()
		if generation == reconcileGeneration then reconcileDensity() end
	end)
end

local function spawnLostVisual(itemId: string, startCFrame: CFrame, offsetIndex: number, lostKind: string, ownerUserId: number?, scatterSeconds: number, lifetimeSeconds: number, fadeSeconds: number)
	if not lostVisualFolder then return end
	local visual = PrototypeVisualConfig.Items[itemId]
	if not visual then return end
	local angle = offsetIndex * 1.73
	local radius = 3.0 + (offsetIndex % 3) * 1.05
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local destinationPosition = Vector3.new(startCFrame.Position.X + offset.X, visual.Size.Y * 0.5 + 0.06, startCFrame.Position.Z + offset.Z)

	local lost = Instance.new("Part")
	lost.Name = ("%s_%s"):format(lostKind, itemId)
	lost.Size = visual.Size
	lost.CFrame = startCFrame
	lost.Anchored = true
	lost.CanCollide = false
	lost.CanTouch = false
	lost.CanQuery = false
	lost.Material = Enum.Material.SmoothPlastic
	lost.Color = visual.Color
	lost:SetAttribute("ItemId", itemId)
	lost:SetAttribute("Available", false)
	lost:SetAttribute("TripLossKind", lostKind)
	lost:SetAttribute("AbandonedByUserId", ownerUserId or 0)
	lost.Parent = lostVisualFolder

	local spin = CFrame.Angles(math.rad(24 + offsetIndex * 11), math.rad(offsetIndex * 43), math.rad(30 - offsetIndex * 7))
	TweenService:Create(lost, TweenInfo.new(scatterSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(destinationPosition) * spin }):Play()
	task.delay(math.max(0.15, lifetimeSeconds - fadeSeconds), function()
		if not lost.Parent then return end
		TweenService:Create(lost, TweenInfo.new(fadeSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1,
			Size = lost.Size * 0.82,
		}):Play()
	end)
	Debris:AddItem(lost, lifetimeSeconds)
end

function ItemService.Start(root: Folder)
	table.clear(activeBySpawn)
	table.clear(enabledSpawns)
	table.clear(sectorSpawns)

	itemFolder = Instance.new("Folder")
	itemFolder.Name = "Items"
	itemFolder.Parent = root
	spawnFolder = root:WaitForChild("ItemSpawns") :: Folder
	lostVisualFolder = Instance.new("Folder")
	lostVisualFolder.Name = "LostTripItems"
	lostVisualFolder.Parent = root

	for _, spawnPart in spawnFolder:GetChildren() do
		if spawnPart:IsA("BasePart") then
			local sectorName = spawnPart:GetAttribute("SectorName")
			if typeof(sectorName) ~= "string" or sectorName == "" then sectorName = "Unassigned" end
			sectorSpawns[sectorName] = sectorSpawns[sectorName] or {}
			table.insert(sectorSpawns[sectorName], spawnPart)
		end
	end
	reconcileDensity()
	Players.PlayerAdded:Connect(scheduleDensityReconcile)
	Players.PlayerRemoving:Connect(scheduleDensityReconcile)
end

function ItemService.GetAvailableCount(): number
	if not itemFolder then return 0 end
	local count = 0
	for _, candidate in itemFolder:GetChildren() do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Available") == true then count += 1 end
	end
	return count
end

function ItemService.TryTake(player: Player, candidate: Instance): (boolean, string?, CFrame?)
	if not itemFolder or not candidate:IsA("BasePart") or candidate.Parent ~= itemFolder then return false, nil, nil end
	if candidate:GetAttribute("Available") ~= true or candidate:GetAttribute("ReservedByUserId") ~= 0 then return false, nil, nil end
	local itemId = candidate:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or not ItemConfig[itemId] then return false, nil, nil end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then return false, nil, nil end
	if (root.Position - candidate.Position).Magnitude > CarryConfig.GrabDistance then return false, nil, nil end

	candidate:SetAttribute("ReservedByUserId", player.UserId)
	candidate:SetAttribute("Available", false)
	local pickupCFrame = candidate.CFrame
	local spawnName = candidate:GetAttribute("SpawnName")
	if typeof(spawnName) == "string" and spawnName ~= "" and activeBySpawn[spawnName] == candidate then
		activeBySpawn[spawnName] = nil
	end
	candidate:Destroy()
	if typeof(spawnName) == "string" and spawnName ~= "" then scheduleRestock(spawnName) end
	return true, itemId, pickupCFrame
end

function ItemService.SpawnCollapseLoss(itemId: string, startCFrame: CFrame, offsetIndex: number)
	spawnLostVisual(itemId, startCFrame, offsetIndex, "Collapse", nil, CarryConfig.Failure.CollapseScatterSeconds, CarryConfig.Failure.LostVisualLifetimeSeconds, 0.40)
end

function ItemService.SpawnDropped(itemId: string, startCFrame: CFrame, ownerUserId: number, offsetIndex: number)
	spawnLostVisual(itemId, startCFrame, offsetIndex, "Ditch", ownerUserId, CarryConfig.Ditch.ScatterSeconds, CarryConfig.Ditch.VisualLifetimeSeconds, CarryConfig.Ditch.FadeSeconds)
end

return ItemService
