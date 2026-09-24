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
	GripItemCount: number,
	LastPreviewAt: number,
	LastVelocity: Vector3,
	LastDirection: Vector3?,
	LastSpeed: number,
	CruiseSeconds: number,
	EventSeverity: number,
	MotionSwayMultiplier: number,
	MotionRecoveryMultiplier: number,
}

local runtime: {[Player]: RuntimeState} = {}
local carryService: any = nil
local worldRoot: Folder? = nil
local previewRemote: RemoteEvent
local noticeRemote: RemoteEvent
local accumulator = 0
local PREVIEW_COOLDOWN_SECONDS = 0.08
local UPDATE_SECONDS = 0.10

local function setAttributeIfChanged(player: Player, name: string, value: any)
	local current = player:GetAttribute(name)
	if typeof(current) == "number" and typeof(value) == "number" then
		if math.abs(current - value) <= 0.001 then return end
	elseif current == value then
		return
	end
	player:SetAttribute(name, value)
end

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
			if itemId and index and ItemConfig[itemId] then table.insert(found, { Index = index, ItemId = itemId }) end
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
			local result = HandlingConfig.Evaluate(stats, definition, totalWeight, totalBulk, rawBase, wideCount, tallCount)
			result.ItemId = itemId
			result.ItemCount = #allIds
			if not worst or result.Ratio < worst.Ratio then worst = result end
		end
	end
	return worst
end

local function normalized(value: number, startValue: number, fullValue: number): number
	return math.clamp((value - startValue) / math.max(0.001, fullValue - startValue), 0, 1)
end

local function updateMotion(player: Player, state: RuntimeState, dt: number)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		state.LastVelocity = Vector3.zero
		state.LastDirection = nil
		state.LastSpeed = 0
		state.CruiseSeconds = 0
		state.EventSeverity = 0
		state.MotionSwayMultiplier = 1
		state.MotionRecoveryMultiplier = 1
		return
	end

	local tuning = CarryConfig.SpeedHandling
	local velocity3 = root.AssemblyLinearVelocity
	local velocity = Vector3.new(velocity3.X, 0, velocity3.Z)
	local speed = velocity.Magnitude
	local previousSpeed = state.LastSpeed
	local acceleration = (velocity - state.LastVelocity).Magnitude / math.max(0.01, dt)
	local speedGain = math.max(0, speed - previousSpeed)
	local speedDrop = math.max(0, previousSpeed - speed)
	local direction = if speed > CarryConfig.Movement.VelocityDeadzone then velocity.Unit else nil
	local turnDegrees = 0
	if direction and state.LastDirection then
		turnDegrees = math.deg(math.acos(math.clamp(state.LastDirection:Dot(direction), -1, 1)))
	end

	local speedAlpha = normalized(math.max(speed, previousSpeed), tuning.SpeedAmplificationStart, tuning.SpeedAmplificationFull)
	local accelerationAlpha = 0
	if speedGain > 0.2 then accelerationAlpha = normalized(acceleration, tuning.AccelerationStart, tuning.AccelerationFull) end
	local brakingAlpha = normalized(speedDrop, tuning.BrakeSpeedDropStart, tuning.BrakeSpeedDropFull)
	local turnAlpha = normalized(turnDegrees, tuning.TurnStartDegrees, tuning.TurnFullDegrees)
	if turnDegrees >= tuning.ReversalDegrees then turnAlpha = 1 end

	-- Low-speed starts still produce ordinary carry recoil, while high-speed
	-- velocity changes receive the large M6A.2 amplification.
	local rawEvent = math.max(accelerationAlpha, brakingAlpha, turnAlpha)
	rawEvent *= 0.35 + 0.65 * speedAlpha
	state.EventSeverity = math.max(rawEvent, state.EventSeverity * math.exp(-tuning.EventDecayPerSecond * dt))

	local stableAcceleration = acceleration <= tuning.CruiseAccelerationTolerance
	local stableTurn = turnDegrees <= tuning.CruiseTurnToleranceDegrees
	local cruising = speed >= tuning.CruiseMinimumSpeed and stableAcceleration and stableTurn
	if cruising then state.CruiseSeconds += dt else state.CruiseSeconds = 0 end
	local cruiseStable = state.CruiseSeconds >= tuning.CruiseSettleSeconds

	local stats = statsFor(player)
	local controlReduction = math.max(1, stats.Control ^ tuning.ControlReductionExponent)
	local controlledSeverity = math.clamp(state.EventSeverity / controlReduction, 0, 1)
	state.MotionSwayMultiplier = 1 + controlledSeverity * (tuning.MaximumEventSwayMultiplier - 1)
	state.MotionRecoveryMultiplier = 1 - controlledSeverity * (1 - tuning.MinimumEventRecoveryMultiplier)
	if cruiseStable and rawEvent <= 0.02 then
		state.MotionSwayMultiplier = 1
		state.MotionRecoveryMultiplier = 1
	end

	setAttributeIfChanged(player, "MotionSpeed", speed)
	setAttributeIfChanged(player, "MotionAcceleration", acceleration)
	setAttributeIfChanged(player, "MotionTurnDegrees", turnDegrees)
	setAttributeIfChanged(player, "MotionEventSeverity", controlledSeverity)
	setAttributeIfChanged(player, "MotionCruiseStable", cruiseStable)

	state.LastVelocity = velocity
	state.LastSpeed = speed
	if direction then state.LastDirection = direction elseif speed <= CarryConfig.Movement.VelocityDeadzone then state.LastDirection = nil end
end

local function penaltyKey(evaluation, state: RuntimeState): string
	if not evaluation then
		return string.format("NONE|%.2f|%.2f", state.MotionSwayMultiplier, state.MotionRecoveryMultiplier)
	end
	return string.format(
		"%s|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f|%.2f|%.2f",
		evaluation.Band,
		evaluation.BaseInstabilityBonus,
		evaluation.InstabilityFloor,
		evaluation.SwayMultiplier,
		evaluation.RecoveryMultiplier,
		evaluation.MovementMultiplier,
		evaluation.StrainFloor,
		state.MotionSwayMultiplier,
		state.MotionRecoveryMultiplier
	)
end

local function clearHandling(player: Player, state: RuntimeState)
	setAttributeIfChanged(player, "HandlingBand", "READY")
	setAttributeIfChanged(player, "HandlingWeakness", "")
	setAttributeIfChanged(player, "HandlingRatio", 1)
	setAttributeIfChanged(player, "HandlingRequiredStrength", 0)
	setAttributeIfChanged(player, "HandlingRequiredCarrySpace", 0)
	setAttributeIfChanged(player, "HandlingRequiredControl", 0)
	setAttributeIfChanged(player, "HandlingBaseInstabilityBonus", 0)
	setAttributeIfChanged(player, "HandlingInstabilityFloor", 0)
	setAttributeIfChanged(player, "HandlingSwayMultiplier", state.MotionSwayMultiplier)
	setAttributeIfChanged(player, "HandlingRecoveryMultiplier", state.MotionRecoveryMultiplier)
	setAttributeIfChanged(player, "HandlingMovementMultiplier", 1)
	setAttributeIfChanged(player, "HandlingStrainFloor", 0)
	setAttributeIfChanged(player, "HandlingGripRemaining", 0)
	state.GripStartedAt = nil
	state.GripDuration = 0
	state.GripWarned = false
	state.GripItemCount = 0
	local key = penaltyKey(nil, state)
	if state.PenaltyKey ~= key then
		state.PenaltyKey = key
		carryService.RefreshHandling(player)
	end
end

local function applyEvaluation(player: Player, state: RuntimeState, evaluation)
	if not evaluation then clearHandling(player, state) return end
	setAttributeIfChanged(player, "HandlingBand", evaluation.Band)
	setAttributeIfChanged(player, "HandlingWeakness", evaluation.Weakness)
	setAttributeIfChanged(player, "HandlingRatio", evaluation.Ratio)
	setAttributeIfChanged(player, "HandlingRequiredStrength", evaluation.RequiredStrength)
	setAttributeIfChanged(player, "HandlingRequiredCarrySpace", evaluation.RequiredCarrySpace)
	setAttributeIfChanged(player, "HandlingRequiredControl", evaluation.RequiredControl)
	setAttributeIfChanged(player, "HandlingBaseInstabilityBonus", evaluation.BaseInstabilityBonus)
	setAttributeIfChanged(player, "HandlingInstabilityFloor", evaluation.InstabilityFloor)
	setAttributeIfChanged(player, "HandlingSwayMultiplier", evaluation.SwayMultiplier * state.MotionSwayMultiplier)
	setAttributeIfChanged(player, "HandlingRecoveryMultiplier", evaluation.RecoveryMultiplier * state.MotionRecoveryMultiplier)
	setAttributeIfChanged(player, "HandlingMovementMultiplier", evaluation.MovementMultiplier)
	setAttributeIfChanged(player, "HandlingStrainFloor", evaluation.StrainFloor)

	local key = penaltyKey(evaluation, state)
	if state.PenaltyKey ~= key then state.PenaltyKey = key carryService.RefreshHandling(player) end

	if evaluation.Band == "UNMANAGEABLE" then
		local itemCount = math.max(0, math.floor(tonumber(evaluation.ItemCount) or 0))
		if not state.GripStartedAt then
			state.GripStartedAt = os.clock()
			state.GripDuration = HandlingConfig.GripFailureSeconds(evaluation.Ratio)
			state.GripWarned = false
			state.GripItemCount = itemCount
		elseif itemCount > state.GripItemCount then
			carryService.ForceGripLoss(player)
			state.GripItemCount = math.max(0, itemCount - 1)
			return
		else
			state.GripItemCount = itemCount
		end
		if not state.GripWarned then state.GripWarned = true noticeRemote:FireClient(player, HandlingConfig.GripFailure.WarningText) end
		local elapsed = os.clock() - (state.GripStartedAt or os.clock())
		local remaining = math.max(0, state.GripDuration - elapsed)
		setAttributeIfChanged(player, "HandlingGripRemaining", remaining)
		if remaining <= 0 then
			state.GripStartedAt = nil
			state.GripWarned = false
			state.GripItemCount = 0
			carryService.ForceGripLoss(player)
		end
	else
		state.GripStartedAt = nil
		state.GripDuration = 0
		state.GripWarned = false
		state.GripItemCount = 0
		setAttributeIfChanged(player, "HandlingGripRemaining", 0)
	end
end

local function initializePlayer(player: Player)
	if runtime[player] then return end
	runtime[player] = {
		PenaltyKey = "", GripStartedAt = nil, GripDuration = 0, GripWarned = false, GripItemCount = 0,
		LastPreviewAt = -math.huge, LastVelocity = Vector3.zero, LastDirection = nil, LastSpeed = 0,
		CruiseSeconds = 0, EventSeverity = 0, MotionSwayMultiplier = 1, MotionRecoveryMultiplier = 1,
	}
	setAttributeIfChanged(player, "HandlingBand", "READY")
	setAttributeIfChanged(player, "HandlingWeakness", "")
	setAttributeIfChanged(player, "HandlingRatio", 1)
	setAttributeIfChanged(player, "HandlingMovementMultiplier", 1)
	setAttributeIfChanged(player, "HandlingSwayMultiplier", 1)
	setAttributeIfChanged(player, "HandlingRecoveryMultiplier", 1)
	setAttributeIfChanged(player, "HandlingBaseInstabilityBonus", 0)
	setAttributeIfChanged(player, "HandlingInstabilityFloor", 0)
	setAttributeIfChanged(player, "HandlingStrainFloor", 0)
	setAttributeIfChanged(player, "HandlingGripRemaining", 0)
	setAttributeIfChanged(player, "MotionCruiseStable", false)
	setAttributeIfChanged(player, "MotionEventSeverity", 0)
end

local function updatePlayer(player: Player, dt: number)
	local state = runtime[player]
	if not state then return end
	updateMotion(player, state, dt)
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
	local state = runtime[player]
	if not state or player:GetAttribute("ProfileLoaded") ~= true then return end
	local now = os.clock()
	if now - state.LastPreviewAt < PREVIEW_COOLDOWN_SECONDS then return end
	state.LastPreviewAt = now
	local part = validPreviewCandidate(player, candidate)
	if not part then previewRemote:FireClient(player, { clear = true }) return end
	local itemId = part:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" then return end
	local definition = ItemConfig[itemId]
	if not definition then return end
	local evaluation = worstEvaluation(player, carriedItemIds(player), itemId)
	if not evaluation then return end
	local stats = statsFor(player)
	previewRemote:FireClient(player, {
		instance = part, itemId = itemId, name = definition.Name, rarity = definition.Rarity or "Common",
		sellValue = definition.Value, band = evaluation.Band, weakness = evaluation.Weakness,
		requiredStrength = evaluation.RequiredStrength, requiredCarrySpace = evaluation.RequiredCarrySpace,
		requiredControl = evaluation.RequiredControl, strength = stats.Strength, carrySpace = stats.CarrySpace,
		control = stats.Control, rigTier = tonumber(player:GetAttribute("HandlingRigTier")) or 0,
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
		if accumulator < UPDATE_SECONDS then return end
		local step = accumulator
		accumulator = 0
		for _, player in Players:GetPlayers() do updatePlayer(player, step) end
	end)
end

return HandlingRuntimeService
