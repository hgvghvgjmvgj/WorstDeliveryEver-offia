--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local SupplyConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("SupplyConfig"))

local PremiumSupplyService = {}

local rng = Random.new()
local prototypeRoot: Folder? = nil
local itemFolder: Folder? = nil
local spawnFolder: Folder? = nil
local nextPremiumAt: {[string]: number} = {}
local downgradeCount = 0

local function lerpNumber(a: number, b: number, alpha: number): number
	return a + (b - a) * alpha
end

local function playerAlpha(): number
	local count = math.max(1, #Players:GetPlayers())
	return math.clamp((count - 1) / math.max(1, SupplyConfig.FullServerPlayers - 1), 0, 1)
end

local function premiumConfig(itemId: string): any?
	return SupplyConfig.PremiumInventory[itemId]
end

local function capFor(itemId: string): number
	local config = premiumConfig(itemId)
	if not config then
		return math.huge
	end
	return math.max(1, math.floor(lerpNumber(config.SoloCap, config.FullServerCap, playerAlpha()) + 0.5))
end

local function activeCount(itemId: string): number
	local folder = itemFolder
	if not folder then
		return 0
	end
	local count = 0
	for _, candidate in folder:GetChildren() do
		if candidate:IsA("BasePart")
			and candidate:GetAttribute("Available") == true
			and candidate:GetAttribute("ItemId") == itemId then
			count += 1
		end
	end
	return count
end

local function cooldownScale(): number
	return lerpNumber(1, SupplyConfig.FullServerCooldownScale, playerAlpha())
end

local function startReplacementGate(itemId: string)
	local config = premiumConfig(itemId)
	if not config then
		return
	end
	local delay = rng:NextNumber(config.MinReplacementSeconds, config.MaxReplacementSeconds) * cooldownScale()
	nextPremiumAt[itemId] = math.max(nextPremiumAt[itemId] or 0, os.clock() + delay)
end

local function premiumCanExist(itemId: string, candidateAlreadyExists: boolean): boolean
	local config = premiumConfig(itemId)
	if not config then
		return true
	end
	if os.clock() < (nextPremiumAt[itemId] or 0) then
		return false
	end
	local count = activeCount(itemId)
	if candidateAlreadyExists then
		return count <= capFor(itemId)
	end
	return count < capFor(itemId)
end

local function shuffledCopy(source: {Instance}): {Instance}
	local result = table.clone(source)
	for index = #result, 2, -1 do
		local swap = rng:NextInteger(1, index)
		result[index], result[swap] = result[swap], result[index]
	end
	return result
end

local function fallbackFor(item: BasePart, blockedItemId: string): string?
	local depth = item:GetAttribute("ZoneDepth")
	if typeof(depth) ~= "number" then
		depth = 1
	end
	depth = math.clamp(math.floor(depth + 0.5), 1, 3)

	-- A blocked Couch/Safe can occasionally become a TV if TV supply itself has
	-- room. This preserves some deep-value opportunities without letting every
	-- premium authored position become another premium substitute.
	if blockedItemId ~= "TV" and depth >= 2 and premiumCanExist("TV", false) and rng:NextNumber() < 0.40 then
		return "TV"
	end

	local pool = SupplyConfig.PremiumFallbacksByDepth[depth]
	if not pool or #pool == 0 then
		return nil
	end
	return pool[rng:NextInteger(1, #pool)]
end

local function refreshVisual(item: BasePart, itemId: string)
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	if not definition or not visual then
		return
	end

	item.Name = itemId
	item:SetAttribute("ItemId", itemId)
	item.Size = visual.Size
	item.Color = visual.Color

	local folder = spawnFolder
	local spawnName = item:GetAttribute("SpawnName")
	if folder and typeof(spawnName) == "string" and spawnName ~= "" then
		local marker = folder:FindFirstChild(spawnName)
		if marker and marker:IsA("BasePart") then
			item.CFrame = marker.CFrame + Vector3.new(0, visual.Size.Y * 0.5 + 0.15, 0)
		end
	end

	local billboard = item:FindFirstChild("PrototypeLabel")
	local label = billboard and billboard:FindFirstChildWhichIsA("TextLabel")
	if label then
		label.Text = definition.Name
	end
end

local function updateTelemetry()
	local root = prototypeRoot
	if not root then
		return
	end
	for itemId in SupplyConfig.PremiumInventory do
		local prefix = "SupplyPremium_" .. itemId .. "_"
		root:SetAttribute(prefix .. "Active", activeCount(itemId))
		root:SetAttribute(prefix .. "Cap", capFor(itemId))
		root:SetAttribute(prefix .. "NextInSeconds", math.max(0, (nextPremiumAt[itemId] or 0) - os.clock()))
	end
	root:SetAttribute("SupplyPremiumDowngrades", downgradeCount)
end

local function enforceItem(item: BasePart)
	local folder = itemFolder
	if not folder or item.Parent ~= folder or item:GetAttribute("Available") ~= true then
		return
	end
	local itemId = item:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or not premiumConfig(itemId) then
		return
	end
	if premiumCanExist(itemId, true) then
		updateTelemetry()
		return
	end

	local fallback = fallbackFor(item, itemId)
	if not fallback or not ItemConfig[fallback] then
		return
	end
	item:SetAttribute("PremiumSupplyOriginalItemId", itemId)
	item:SetAttribute("PremiumSupplySubstitute", true)
	refreshVisual(item, fallback)
	downgradeCount += 1
	updateTelemetry()
end

local function handleAdded(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end
	-- ItemService parents the Part before its sector/depth presentation attributes
	-- are attached, so defer until that spawn transaction has completed.
	task.defer(function()
		if itemFolder and instance.Parent == itemFolder then
			enforceItem(instance)
		end
	end)
end

local function handleRemoved(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end
	local itemId = instance:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or not premiumConfig(itemId) then
		updateTelemetry()
		return
	end

	-- A normal authoritative grab reserves the item before destroying it. Studio
	-- test players may use negative UserIds, so any nonzero reservation counts.
	local reservedBy = instance:GetAttribute("ReservedByUserId")
	if typeof(reservedBy) == "number" and reservedBy ~= 0 then
		startReplacementGate(itemId)
	end
	updateTelemetry()
end

function PremiumSupplyService.Start(root: Folder)
	prototypeRoot = root
	itemFolder = root:WaitForChild("Items") :: Folder
	spawnFolder = root:WaitForChild("ItemSpawns") :: Folder
	table.clear(nextPremiumAt)
	downgradeCount = 0

	itemFolder.ChildAdded:Connect(handleAdded)
	itemFolder.ChildRemoved:Connect(handleRemoved)

	-- Randomize the initial scan so premium survivors are distributed rather than
	-- whichever sector happens to appear first in an Instance traversal.
	for _, instance in shuffledCopy(itemFolder:GetChildren()) do
		if instance:IsA("BasePart") then
			enforceItem(instance)
		end
	end

	Players.PlayerAdded:Connect(updateTelemetry)
	Players.PlayerRemoving:Connect(function()
		task.defer(updateTelemetry)
	end)
	updateTelemetry()
end

return PremiumSupplyService
