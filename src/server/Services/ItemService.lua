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
	item:SetAttribute("SpawnName", spawnName or "")
	item:SetAttribute("OwnerUserId", ownerUserId or 0)
	item:SetAttribute("ProtectedUntil", 0)
	item.Parent = itemFolder

	local gui = Instance.new("BillboardGui")
	gui.Name = "PrototypeLabel"
	gui.Adornee = item
	gui.Size = UDim2.fromOffset(170, 44)
	gui.StudsOffset = Vector3.new(0, visual.Size.Y * 0.5 + 1.3, 0)
	gui.AlwaysOnTop = true
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
	local itemId = spawnPart:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or itemId == "" then
		return
	end
	makeWorldItem(itemId, spawnPart.CFrame, spawnPart.Name, nil)
end

function ItemService.Start(root: Folder)
	itemFolder = Instance.new("Folder")
	itemFolder.Name = "Items"
	itemFolder.Parent = root

	spawnFolder = root:WaitForChild("ItemSpawns") :: Folder
	for _, spawnPart in spawnFolder:GetChildren() do
		if spawnPart:IsA("BasePart") then
			spawnStock(spawnPart)
		end
	end
end

function ItemService.TryTake(player: Player, candidate: Instance): (boolean, string?, CFrame?)
	if not itemFolder or not candidate:IsA("BasePart") or candidate.Parent ~= itemFolder then
		return false, nil, nil
	end
	if candidate:GetAttribute("Available") ~= true then
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

	local pickupCFrame = candidate.CFrame
	candidate:SetAttribute("Available", false)
	local spawnName = candidate:GetAttribute("SpawnName")
	candidate:Destroy()

	if typeof(spawnName) == "string" and spawnName ~= "" and spawnFolder then
		local sourceSpawn = spawnFolder:FindFirstChild(spawnName)
		if sourceSpawn and sourceSpawn:IsA("BasePart") then
			task.delay(GameConfig.Prototype.StockRespawnSeconds, function()
				if sourceSpawn.Parent and itemFolder then
					spawnStock(sourceSpawn)
				end
			end)
		end
	end

	return true, itemId, pickupCFrame
end

function ItemService.SpawnDropped(itemId: string, startCFrame: CFrame, ownerUserId: number, offsetIndex: number)
	if not itemFolder then
		return
	end

	local angle = offsetIndex * 1.73
	local radius = 2.8 + (offsetIndex % 3) * 0.9
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local floorPosition = Vector3.new(startCFrame.Position.X + offset.X, 0.01, startCFrame.Position.Z + offset.Z)

	local item = makeWorldItem(itemId, CFrame.new(floorPosition), nil, ownerUserId)
	local destination = item.CFrame
	item.CFrame = startCFrame
	item:SetAttribute("ProtectedUntil", Workspace:GetServerTimeNow() + CarryConfig.DroppedItemProtectionSeconds)

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
