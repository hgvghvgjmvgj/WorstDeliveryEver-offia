--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))
local LootEconomy = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootEconomy"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local LootPresentation = require(script.Parent:WaitForChild("LootPresentation"))

local LootRarityService = {}

local rng = Random.new()
local root: Folder? = nil
local itemFolder: Folder? = nil
local spawnFolder: Folder? = nil
local nextRarityAt: {[string]: number} = {}
local lastBaseBySpawn: {[string]: string} = {}
local generation = 0

local function lerp(a: number, b: number, alpha: number): number
	return a + (b - a) * alpha
end

local function playerAlpha(): number
	local count = math.max(1, #Players:GetPlayers())
	return math.clamp((count - 1) / math.max(1, RarityConfig.FullServerPlayers - 1), 0, 1)
end

local function activeRarityCount(rarity: string): number
	local folder = itemFolder
	if not folder then return 0 end
	local count = 0
	for _, candidate in folder:GetChildren() do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Available") == true and candidate:GetAttribute("Rarity") == rarity then
			count += 1
		end
	end
	return count
end

local function capFor(rarity: string): number
	local tier = RarityConfig.Tiers[rarity]
	if not tier or not tier.SoloCap then return math.huge end
	return math.max(1, math.floor(lerp(tier.SoloCap, tier.FullServerCap or tier.SoloCap, playerAlpha()) + 0.5))
end

local function rarityAvailable(rarity: string): boolean
	local tier = RarityConfig.Tiers[rarity]
	if not tier then return false end
	if tier.Rank < 5 then return true end
	if os.clock() < (nextRarityAt[rarity] or 0) then return false end
	return activeRarityCount(rarity) < capFor(rarity)
end

local function debugScopeMatches(sectionId: string): boolean
	local currentRoot = root
	if not currentRoot or not RunService:IsStudio() then return false end
	local requested = currentRoot:GetAttribute("DevForceSection")
	return typeof(requested) ~= "string" or requested == "" or requested == sectionId
end

local function forcedRarity(sectionId: string): string?
	if not debugScopeMatches(sectionId) then return nil end
	local currentRoot = root
	local value = currentRoot and currentRoot:GetAttribute("DevForceRarity")
	if typeof(value) == "string" and RarityConfig.Tiers[value] then
		return value
	end
	return nil
end

local function weightedRarity(sectionId: string): string
	local forced = forcedRarity(sectionId)
	if forced then return forced end
	local total = 0
	local options = {}
	for _, rarity in RarityConfig.Order do
		local tier = RarityConfig.Tiers[rarity]
		if rarityAvailable(rarity) then
			total += tier.Weight
			table.insert(options, { Rarity = rarity, Upper = total })
		end
	end
	if total <= 0 then return "Common" end
	local roll = rng:NextNumber(0, total)
	for _, option in options do
		if roll <= option.Upper then return option.Rarity end
	end
	return "Common"
end

local function heroAllowed(baseItemId: string, rarity: string): boolean
	local base = LootCatalog.ById[baseItemId]
	if not base or not base.HeroMinRarity then return false end
	return RarityConfig.Rank(rarity) >= RarityConfig.Rank(base.HeroMinRarity)
end

local function chooseBase(sectionId: string, rarity: string, spawnName: string): string?
	local currentRoot = root
	if debugScopeMatches(sectionId) and currentRoot then
		local forced = currentRoot:GetAttribute("DevForceBaseItemId")
		if typeof(forced) == "string" and forced ~= "" then
			local candidate = LootCatalog.ById[forced]
			if candidate and candidate.SectionId == sectionId and (candidate.Core or heroAllowed(forced, rarity)) then
				return forced
			end
		end
	end

	local heroes = LootCatalog.HeroBySection[sectionId]
	local heroChance = RarityConfig.HeroChanceByRarity[rarity] or 0
	if heroes and #heroes > 0 and heroChance > 0 and rng:NextNumber() <= heroChance then
		local eligible = {}
		for _, baseItemId in heroes do
			if heroAllowed(baseItemId, rarity) then table.insert(eligible, baseItemId) end
		end
		if #eligible > 0 then return eligible[rng:NextInteger(1, #eligible)] end
	end

	local pool = LootCatalog.CoreBySection[sectionId]
	if not pool or #pool == 0 then return nil end
	local previous = lastBaseBySpawn[spawnName]
	if #pool == 1 then return pool[1] end
	for _ = 1, 6 do
		local pick = pool[rng:NextInteger(1, #pool)]
		if pick ~= previous or rng:NextNumber() < 0.08 then return pick end
	end
	return pool[rng:NextInteger(1, #pool)]
end

local function repositionAtMarker(part: BasePart)
	local folder = spawnFolder
	local spawnName = part:GetAttribute("SpawnName")
	if not folder or typeof(spawnName) ~= "string" or spawnName == "" then return end
	local marker = folder:FindFirstChild(spawnName)
	if marker and marker:IsA("BasePart") then
		part.CFrame = marker.CFrame + Vector3.new(0, part.Size.Y * 0.5 + 0.15, 0)
	end
end

local function attachEconomyAttributes(part: BasePart, baseItemId: string, rarity: string)
	local economy = LootEconomy.For(baseItemId, rarity)
	if not economy then return end
	part:SetAttribute("PassiveRatePerMinute", economy.PassivePerMinute)
	part:SetAttribute("SectionMultiplier", economy.SectionMultiplier)
	part:SetAttribute("RarityMultiplier", economy.RarityMultiplier)
	part:SetAttribute("CalculatedSellValue", economy.SellValue)
	part:SetAttribute("BreakEvenMinutes", economy.BreakEvenMinutes)
end

local function transform(part: BasePart, playCue: boolean)
	local folder = itemFolder
	if not folder or part.Parent ~= folder or part:GetAttribute("Available") ~= true then return end
	local sectionId = part:GetAttribute("SectorName")
	if typeof(sectionId) ~= "string" or not LootCatalog.Sections[sectionId] then return end
	local spawnName = part:GetAttribute("SpawnName")
	if typeof(spawnName) ~= "string" then spawnName = part.Name end

	local rarity = weightedRarity(sectionId)
	local baseItemId = chooseBase(sectionId, rarity, spawnName)
	if not baseItemId then return end
	local variantId = RarityConfig.MakeVariantId(baseItemId, rarity)
	if not ItemConfig[variantId] or not PrototypeVisualConfig.Items[variantId] then return end

	part.Name = variantId
	LootPresentation.Apply(part, variantId, playCue)
	part:SetAttribute("SectorName", sectionId)
	part:SetAttribute("LootCatalogM5B", true)
	attachEconomyAttributes(part, baseItemId, rarity)
	repositionAtMarker(part)
	lastBaseBySpawn[spawnName] = baseItemId
end

local function updateTelemetry()
	local currentRoot = root
	if not currentRoot then return end
	for _, rarity in RarityConfig.Order do
		local prefix = "LootRarity_" .. rarity .. "_"
		currentRoot:SetAttribute(prefix .. "Active", activeRarityCount(rarity))
		currentRoot:SetAttribute(prefix .. "NextInSeconds", math.max(0, (nextRarityAt[rarity] or 0) - os.clock()))
		local cap = capFor(rarity)
		currentRoot:SetAttribute(prefix .. "Cap", if cap == math.huge then -1 else cap)
	end
end

local function startClaimGate(rarity: string)
	local tier = RarityConfig.Tiers[rarity]
	if not tier or tier.Rank < 5 or not tier.ClaimCooldownMin then return end
	local scale = lerp(1, 0.70, playerAlpha())
	local delay = rng:NextNumber(tier.ClaimCooldownMin, tier.ClaimCooldownMax) * scale
	nextRarityAt[rarity] = math.max(nextRarityAt[rarity] or 0, os.clock() + delay)
end

local function handleAdded(instance: Instance)
	if not instance:IsA("BasePart") then return end
	task.defer(function()
		if itemFolder and instance.Parent == itemFolder then
			transform(instance, true)
			updateTelemetry()
		end
	end)
end

local function handleRemoved(instance: Instance)
	if not instance:IsA("BasePart") then return end
	local rarity = instance:GetAttribute("Rarity")
	local reservedBy = instance:GetAttribute("ReservedByUserId")
	if typeof(rarity) == "string" and typeof(reservedBy) == "number" and reservedBy ~= 0 then
		startClaimGate(rarity)
		local spawnName = instance:GetAttribute("SpawnName")
		local baseItemId = instance:GetAttribute("BaseItemId")
		if typeof(spawnName) == "string" and typeof(baseItemId) == "string" then
			lastBaseBySpawn[spawnName] = baseItemId
		end
	end
	updateTelemetry()
end

local function inspect(itemId: string)
	local currentRoot = root
	if not currentRoot then return end
	local definition = ItemConfig[itemId]
	local tuning = require(ReplicatedStorage.Config.EconomyConfig).Items[itemId]
	if not definition or not tuning then
		currentRoot:SetAttribute("DevInspectStatus", "UNKNOWN ITEM")
		return
	end
	currentRoot:SetAttribute("DevInspectStatus", definition.Name)
	currentRoot:SetAttribute("DevInspectSellValue", definition.Value)
	currentRoot:SetAttribute("DevInspectPassivePerMinute", tuning.PassivePerMinute)
	currentRoot:SetAttribute("DevInspectRarity", definition.Rarity or "Common")
	currentRoot:SetAttribute("DevInspectSection", definition.SectionId or "Legacy")
	currentRoot:SetAttribute("DevInspectRarityMultiplier", tuning.RarityMultiplier or 1)
	currentRoot:SetAttribute("DevInspectSectionMultiplier", tuning.SectionMultiplier or 1)
	currentRoot:SetAttribute("DevInspectWeight", definition.Weight)
	currentRoot:SetAttribute("DevInspectBulk", definition.Bulk)
	currentRoot:SetAttribute("DevInspectShape", definition.ShapeTag)
end

local function debugSpawnNow()
	local currentRoot = root
	local folder = itemFolder
	if not currentRoot or not folder or not RunService:IsStudio() then return end
	local requestedSection = currentRoot:GetAttribute("DevForceSection")
	local candidates = {}
	for _, candidate in folder:GetChildren() do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Available") == true then
			local sectionId = candidate:GetAttribute("SectorName")
			if typeof(requestedSection) ~= "string" or requestedSection == "" or requestedSection == sectionId then
				table.insert(candidates, candidate)
			end
		end
	end
	if #candidates > 0 then
		transform(candidates[rng:NextInteger(1,#candidates)], true)
	end
	currentRoot:SetAttribute("DevSpawnNow", false)
	updateTelemetry()
end

function LootRarityService.Start(worldRoot: Folder)
	generation += 1
	local myGeneration = generation
	root = worldRoot
	itemFolder = worldRoot:WaitForChild("Items") :: Folder
	spawnFolder = worldRoot:WaitForChild("ItemSpawns") :: Folder
	table.clear(nextRarityAt)
	table.clear(lastBaseBySpawn)

	worldRoot:SetAttribute("M5BBaseLootCount", 72)
	worldRoot:SetAttribute("M5BHeroLootCount", 6)
	if worldRoot:GetAttribute("DevForceRarity") == nil then worldRoot:SetAttribute("DevForceRarity", "") end
	if worldRoot:GetAttribute("DevForceBaseItemId") == nil then worldRoot:SetAttribute("DevForceBaseItemId", "") end
	if worldRoot:GetAttribute("DevForceSection") == nil then worldRoot:SetAttribute("DevForceSection", "") end
	if worldRoot:GetAttribute("DevSpawnNow") == nil then worldRoot:SetAttribute("DevSpawnNow", false) end
	if worldRoot:GetAttribute("DevInspectItemId") == nil then worldRoot:SetAttribute("DevInspectItemId", "") end
	worldRoot:SetAttribute("DevLootDebugEnabled", RunService:IsStudio())

	-- Shuffle the initial population so global high-rarity caps are not biased
	-- toward the first section returned by Instance traversal.
	local initial = itemFolder:GetChildren()
	for index = #initial, 2, -1 do
		local swap = rng:NextInteger(1,index)
		initial[index], initial[swap] = initial[swap], initial[index]
	end
	for _, instance in initial do
		if instance:IsA("BasePart") then transform(instance, false) end
	end

	itemFolder.ChildAdded:Connect(handleAdded)
	itemFolder.ChildRemoved:Connect(handleRemoved)
	worldRoot:GetAttributeChangedSignal("DevSpawnNow"):Connect(function()
		if worldRoot:GetAttribute("DevSpawnNow") == true then debugSpawnNow() end
	end)
	worldRoot:GetAttributeChangedSignal("DevInspectItemId"):Connect(function()
		local value = worldRoot:GetAttribute("DevInspectItemId")
		if typeof(value) == "string" and value ~= "" then inspect(value) end
	end)
	Players.PlayerAdded:Connect(updateTelemetry)
	Players.PlayerRemoving:Connect(function() task.defer(updateTelemetry) end)
	updateTelemetry()

	task.spawn(function()
		while generation == myGeneration and root == worldRoot and worldRoot.Parent do
			task.wait(1)
			updateTelemetry()
		end
	end)
end

return LootRarityService