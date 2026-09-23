--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local HandlingConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("HandlingConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local HandlingRuntimeService = {}

type RuntimeState = {
	PenaltyKey: string,
	GripStartedAt: number?,
	GripDuration: number,
	GripWarned: boolean,
}

local runtime: {[Player]: RuntimeState} = {}
local carryService: any = nil
local worldRoot: Folder? = nil
local previewRemote: RemoteEvent
local noticeRemote: RemoteEvent
local accumulator = 0

local function statsFor(player: Player)
	return {
		Strength = math.max(0.1, tonumber(player:GetAttribute("CarryStrength")) or CarryConfig.Beginner.Strength),
		CarrySpace = math.max(0.1, tonumber(player:GetAttribute("CarrySpace")) or CarryConfig.Beginner.CarrySpace),
		Control = math.max(0.1, tonumber(player:GetAttribute("CarryControl")) or CarryConfig.Beginner.Control),
	}
end

local function carriedItemIds(player: Player): {string}
	local character = player.Character
	local rig = character and character:FindFirstChild("OneTripCarry")
	if not rig then return {} end
	local found = {}
	for _, descendant in rig:GetDescendants() do
		if descendant:IsA("BasePart") then
			local itemId, indexText = string.match(descendant.Name, "^Carry_(.+)_(%d+)$")
			local index = tonumber(indexText)
			if itemId and index and ItemConfig[itemId] then
				table.insert(found, { Index = index, ItemId = itemId })
			end
		end
	end
	table.sort(found, function(a, b) return a.Index < b.Index end)
	local ids = {}
	for _, record in found do table.insert(ids, record.ItemId) end
	return ids
end

local function loadContext(itemIds: {string}, extraItemId: string?)
	local totalWeight = 0
	local totalBulk = 0
	local wideCount = 0
	local tallCount = 0
	local allIds = table.clone(itemIds)
	if extraItemId then table.insert(allIds, extraItemId) end
	for _, itemId in allIds do
		local definition = ItemConfig[itemId]
		if definition then
			totalWeight += definition.Weight
			totalBulk += definition.Bulk
			if definition.ShapeTag == "Wide" then wideCount += 1 end
			if definition.ShapeTag == "Tall" then tallCount += 1 end
		end
	end
	return allIds, totalWeight, totalBulk, wideCount, tallCount
end

local function worstEvaluation(player: Player, itemIds: {string}, extraItemId: string?)
	local allIds, totalWeight, totalBulk, wideCount, tallCount = loadContext(itemIds, extraItemId)
	if #allIds == 0 then return nil end
	local stats = statsFor(player)
	local rawBase = math.max(0, tonumber(player:GetAttribute("CarryRawBaseInstability")) or 0)
	local worst = nil
	for _, itemId in allIds do
		local definition = ItemConfig[itemId]
		if definition then
			local result = HandlingConfig.Evaluate(
				stats,
				definition,
				totalWeight,
				totalBulk,
				rawBase,
				wideCount,
				tallCount
			)
			result.ItemId = itemId
			if not worst or result.Ratio < worst.Ratio then worst = result end
		end
	end
	return worst
end

local function penaltyKey(evaluation): string
	if not evaluation then return "NONE" end
	return string.format(
		"%s|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f",
		evaluation.Band,
		evaluation.BaseInstabilityBonus,
		evaluation.InstabilityFloor,
		evaluation.SwayMultiplier,
		evaluation.RecoveryMultiplier,
		evaluation.MovementMultiplier,
		evaluation.StrainFloor
	)
end

local function clearHandling(player: Player, state: RuntimeState)
	player:SetAttribute("HandlingBand", "READY")
	player:SetAttribute("HandlingWeakness", "")
	player:SetAttribute("HandlingRatio", 1)
	player:SetAttribute("HandlingRequiredStrength", 0)
	player:SetAttribute("HandlingRequiredCarrySpace", 0)
	player:SetAttribute("HandlingRequiredControl", 0)
	player:SetAttribute("HandlingBaseInstabilityBonus", 0)
	player:SetAttribute("HandlingInstabilityFloor", 0)
	player:SetAttribute("HandlingSwayMultiplier", 1)
	player:SetAttribute("HandlingRecoveryMultiplier", 1)
	player:SetAttribute("HandlingMovementMultiplier", 1)
	player:SetAttribute("HandlingStrainFloor", 0)
	player:SetAttribute("HandlingGripRemaining", 0)
	state.GripStartedAt = nil
	state.GripDuration = 0
	state.GripWarned = false
	local key = "NONE"
	if state.PenaltyKey ~= key then
		state.PenaltyKey = key
		carryService.RefreshHandling(player)
	end
end

local function applyEvaluation(player: Player, state: RuntimeState, evaluation)
	if not evaluation then
		clearHandling(player, state)
		return
	end
	player:SetAttribute("HandlingBand", evaluation.Band)
	player:SetAttribute("HandlingWeakness", evaluation.Weakness)
	player:SetAttribute("HandlingRatio", evaluation.Ratio)
	player:SetAttribute("HandlingRequiredStrength", evaluation.RequiredStrength)
	player:SetAttribute("HandlingRequiredCarrySpace", evaluation.RequiredCarrySpace)
	player:SetAttribute("HandlingRequiredControl", evaluation.RequiredControl)
	player:SetAttribute("HandlingBaseInstabilityBonus", evaluation.BaseInstabilityBonus)
	player:SetAttribute("HandlingInstabilityFloor", evaluation.InstabilityFloor)
	player:SetAttribute("HandlingSwayMultiplier", evaluation.SwayMultiplier)
	player:SetAttribute("HandlingRecoveryMultiplier", evaluation.RecoveryMultiplier)
	player:SetAttribute("HandlingMovementMultiplier", evaluation.MovementMultiplier)
	player:SetAttribute("HandlingStrainFloor", evaluation.StrainFloor)

	local key = penaltyKey(evaluation)
	if state.PenaltyKey ~= key then
		state.PenaltyKey = key
		carryService.RefreshHandling(player)
	end

	if evaluation.Band == "UNMANAGEABLE" then
		if not state.GripStartedAt then
			state.GripStartedAt = os.clock()
			state.GripDuration = HandlingConfig.GripFailureSeconds(evaluation.Ratio)
			state.GripWarned = false
		end
		if not state.GripWarned then
			state.GripWarned = true
			noticeRemote:FireClient(player, HandlingConfig.GripFailure.WarningText)
		end
		local elapsed = os.clock() - (state.GripStartedAt or os.clock())
		local remaining = math.max(0, state.GripDuration - elapsed)
		player:SetAttribute("HandlingGripRemaining", remaining)
		if remaining <= 0 then
			state.GripStartedAt = nil
			state.GripWarned = false
			carryService.ForceGripLoss(player)
		end
	else
		state.GripStartedAt = nil
		state.GripDuration = 0
		state.GripWarned = false
		player:SetAttribute("HandlingGripRemaining", 0)
	end
end

local function initializePlayer(player: Player)
	if runtime[player] then return end
	runtime[player] = { PenaltyKey = "", GripStartedAt = nil, GripDuration = 0, GripWarned = false }
	player:SetAttribute("HandlingBand", "READY")
	player:SetAttribute("HandlingWeakness", "")
	player:SetAttribute("HandlingRatio", 1)
	player:SetAttribute("HandlingMovementMultiplier", 1)
	player:SetAttribute("HandlingSwayMultiplier", 1)
	player:SetAttribute("HandlingRecoveryMultiplier", 1)
	player:SetAttribute("HandlingBaseInstabilityBonus", 0)
	player:SetAttribute("HandlingInstabilityFloor", 0)
	player:SetAttribute("HandlingStrainFloor", 0)
	player:SetAttribute("HandlingGripRemaining", 0)
end

local function updatePlayer(player: Player)
	local state = runtime[player]
	if not state then return end
	if player:GetAttribute("ProfileLoaded") ~= true then return end
	local ids = carriedItemIds(player)
	local evaluation = worstEvaluation(player, ids, nil)
	applyEvaluation(player, state, evaluation)
end

local function validPreviewCandidate(player: Player, candidate: any): BasePart?
	if typeof(candidate) ~= "Instance" or not candidate:IsA("BasePart") then return nil end
	local root = worldRoot
	local items = root and root:FindFirstChild("Items")
	if not items or candidate.Parent ~= items or candidate:GetAttribute("Available") ~= true then return nil end
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp or not hrp:IsA("BasePart") then return nil end
	if (hrp.Position - candidate.Position).Magnitude > CarryConfig.GrabDistance + 3 then return nil end
	return candidate
end

local function handlePreview(player: Player, candidate: any)
	local part = validPreviewCandidate(player, candidate)
	if not part then
		previewRemote:FireClient(player, { clear = true })
		return
	end
	local itemId = part:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" then return end
	local definition = ItemConfig[itemId]
	if not definition then return end
	local evaluation = worstEvaluation(player, carriedItemIds(player), itemId)
	if not evaluation then return end
	local stats = statsFor(player)
	previewRemote:FireClient(player, {
		instance = part,
		itemId = itemId,
		name = definition.Name,
		rarity = definition.Rarity or "Common",
		sellValue = definition.Value,
		band = evaluation.Band,
		weakness = evaluation.Weakness,
		requiredStrength = evaluation.RequiredStrength,
		requiredCarrySpace = evaluation.RequiredCarrySpace,
		requiredControl = evaluation.RequiredControl,
		strength = stats.Strength,
		carrySpace = stats.CarrySpace,
		control = stats.Control,
		rigTier = tonumber(player:GetAttribute("HandlingRigTier")) or 0,
	})
end

function HandlingRuntimeService.Start(world: Folder, carryServiceModule: any)
	worldRoot = world
	carryService = carryServiceModule
	previewRemote = RemoteService.Get(RemoteNames.HandlingPreview)
	noticeRemote = RemoteService.Get(RemoteNames.PrototypeNotice)
	previewRemote.OnServerEvent:Connect(handlePreview)

	Players.PlayerAdded:Connect(initializePlayer)
	Players.PlayerRemoving:Connect(function(player) runtime[player] = nil end)
	for _, player in Players:GetPlayers() do initializePlayer(player) end

	RunService.Heartbeat:Connect(function(dt)
		accumulator += dt
		if accumulator < 0.10 then return end
		accumulator = 0
		for _, player in Players:GetPlayers() do updatePlayer(player) end
	end)
end

return HandlingRuntimeService
