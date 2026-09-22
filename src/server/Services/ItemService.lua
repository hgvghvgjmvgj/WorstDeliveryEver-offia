--!strict

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GameConfig"))
local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))

local ItemService = {}

local itemFolder: Folder? = nil
local spawnFolder: Folder? = nil
local lostVisualFolder: Folder? = nil
local activeBySpawn: {[string]: BasePart} = {}

local function makeWorldItem(
	itemId: string,
	cframe: CFrame,
	spawnName: string?,
	ownerUserId: number?
): Part
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
	label.Text = string.format("%s  +%d", definition.Name, definition.Value)
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Parent = gui

	return item
end

local function spawnStock(spawnPart: BasePart)
	if not itemFolder then
		return
	end

	local spawnName = spawnPart.Name
	local existing = activeBySpawn[spawnName]
	if existing and existing.Parent then
		return
	end

	local itemId = spawnPart:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or itemId == "" or not ItemConfig[itemId] then
		return
	end

	local item = makeWorldItem(itemId, spawnPart.CFrame, spawnName, nil)
	activeBySpawn[spawnName] = item

	item.Destroying:Connect(function()
		if activeBySpawn[spawnName] == item then
			activeBySpawn[spawnName] = nil
		end
	end)
end

local function scheduleRestock(spawnName: string)
	if not spawnFolder then
		return
	end

	local sourceSpawn = spawnFolder:FindFirstChild(spawnName)
	if not sourceSpawn or not sourceSpawn:IsA("BasePart") then
		return
	end

	local delaySeconds = sourceSpawn:GetAttribute("RestockSeconds")
	if typeof(delaySeconds) ~= "number" then
		delaySeconds = 1.8
	end

	task.delay(delaySeconds, function()
		if sourceSpawn.Parent and itemFolder then
			spawnStock(sourceSpawn)
		end
	end)
end

function ItemService.Start(root: Folder)
	table.clear(activeBySpawn)

	itemFolder = Instance.new("Folder")
	itemFolder.Name = "Items"
	itemFolder.Parent = root

	spawnFolder = root:WaitForChild("ItemSpawns") :: Folder

	lostVisualFolder = Instance.new("Folder")
	lostVisualFolder.Name = "LostCollapseItems"
	lostVisualFolder.Parent = root

	for _, spawnPart in spawnFolder:GetChildren() do
		if spawnPart:IsA("BasePart") then
			spawnStock(spawnPart)
		end
	end
end

function ItemService.GetAvailableCount(): number
	if not itemFolder then
		return 0
	end

	local count = 0
	for _, candidate in itemFolder:GetChildren() do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Available") == true then
			count += 1
		end
	end
	return count
end

function ItemService.TryTake(player: Player, candidate: Instance): (boolean, string?, CFrame?)
	if not itemFolder or not candidate:IsA("BasePart") or candidate.Parent ~= itemFolder then
		return false, nil, nil
	end

	if candidate:GetAttribute("Available") ~= true then
		return false, nil, nil
	end

	if candidate:GetAttribute("ReservedByUserId") ~= 0 then
		return false, nil, nil
	end

	local itemId = candidate:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or not ItemConfig[itemId] then
		return false, nil, nil
	end

	local protectedUntil = candidate:GetAttribute("ProtectedUntil")
	local ownerUserId = candidate:GetAttribute("OwnerUserId")
	if typeof(protectedUntil) == "number"
		and protectedUntil > Workspace:GetServerTimeNow()
		and typeof(ownerUserId) == "number"
		and ownerUserId ~= 0
		and ownerUserId ~= player.UserId
	then
		return false, nil, nil
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return false, nil, nil
	end

	if (root.Position - candidate.Position).Magnitude > CarryConfig.GrabDistance then
		return false, nil, nil
	end

	-- No yields below this point until the item has been reserved. The first
	-- valid server request wins this shared object.
	candidate:SetAttribute("ReservedByUserId", player.UserId)
	candidate:SetAttribute("Available", false)

	local pickupCFrame = candidate.CFrame
	local spawnName = candidate:GetAttribute("SpawnName")

	if typeof(spawnName) == "string" and spawnName ~= "" then
		if activeBySpawn[spawnName] == candidate then
			activeBySpawn[spawnName] = nil
		end
	end

	candidate:Destroy()

	if typeof(spawnName) == "string" and spawnName ~= "" then
		scheduleRestock(spawnName)
	end

	return true, itemId, pickupCFrame
end

function ItemService.SpawnCollapseLoss(itemId: string, startCFrame: CFrame, offsetIndex: number)
	if not lostVisualFolder then
		return
	end

	local visual = PrototypeVisualConfig.Items[itemId]
	if not visual then
		return
	end

	local angle = offsetIndex * 1.73
	local radius = 3.0 + (offsetIndex % 3) * 1.05
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local destinationPosition = Vector3.new(
		startCFrame.Position.X + offset.X,
		visual.Size.Y * 0.5 + 0.06,
		startCFrame.Position.Z + offset.Z
	)

	local lost = Instance.new("Part")
	lost.Name = ("Lost_%s"):format(itemId)
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
	lost:SetAttribute("LostFromCollapse", true)
	lost.Parent = lostVisualFolder

	local spin = CFrame.Angles(
		math.rad(24 + offsetIndex * 11),
		math.rad(offsetIndex * 43),
		math.rad(30 - offsetIndex * 7)
	)

	TweenService:Create(
		lost,
		TweenInfo.new(
			CarryConfig.Failure.CollapseScatterSeconds,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{ CFrame = CFrame.new(destinationPosition) * spin }
	):Play()

	task.delay(
		math.max(0.5, CarryConfig.Failure.LostVisualLifetimeSeconds - 0.45),
		function()
			if not lost.Parent then
				return
			end

			TweenService:Create(
				lost,
				TweenInfo.new(0.40, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Transparency = 1,
					Size = lost.Size * 0.82,
				}
			):Play()
		end
	)

	Debris:AddItem(lost, CarryConfig.Failure.LostVisualLifetimeSeconds)
end

function ItemService.SpawnDropped(
	itemId: string,
	startCFrame: CFrame,
	ownerUserId: number,
	offsetIndex: number
)
	if not itemFolder then
		return
	end

	local angle = offsetIndex * 1.73
	local radius = 2.8 + (offsetIndex % 3) * 0.9
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local floorPosition = Vector3.new(
		startCFrame.Position.X + offset.X,
		0.01,
		startCFrame.Position.Z + offset.Z
	)

	local item = makeWorldItem(itemId, CFrame.new(floorPosition), nil, ownerUserId)
	local destination = item.CFrame
	item.CFrame = startCFrame
	item:SetAttribute(
		"ProtectedUntil",
		Workspace:GetServerTimeNow() + CarryConfig.DroppedItemProtectionSeconds
	)

	local spin = CFrame.Angles(
		math.rad(18 + offsetIndex * 9),
		math.rad(offsetIndex * 37),
		math.rad(24 - offsetIndex * 5)
	)

	TweenService:Create(
		item,
		TweenInfo.new(
			CarryConfig.Failure.CollapseScatterSeconds,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{ CFrame = destination * spin }
	):Play()

	Debris:AddItem(item, GameConfig.Prototype.DroppedItemLifetimeSeconds)
end

return ItemService
