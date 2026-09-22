--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local CarryService = {}

type LayerVisual = {
	Part: BasePart,
	Weld: Weld,
	Sway: Vector2,
}

type ItemEntry = {
	ItemId: string,
	Layer: number,
	Visual: BasePart?,
	VisualWeld: Weld?,
}

type CarryState = {
	Items: {ItemEntry},
	Weight: number,
	Bulk: number,
	RunValue: number,
	SessionScore: number,
	BaseInstability: number,
	Strain: number,
	StrainLoadSeverity: number,
	StrainStage: string,
	StrainPhase: number,
	DynamicSway: Vector2,
	CurrentSway: Vector2,
	Phase: number,
	LastVelocity: Vector3,
	LastDirection: Vector3?,
	DangerState: string,
	CollapseStartedAt: number?,
	LastRecoveryFeedbackAt: number,
	TutorialWarningsEnabled: boolean,
	TutorialStrainMessageShown: boolean,
	Character: Model?,
	Humanoid: Humanoid?,
	Root: BasePart?,
	RigFolder: Folder?,
	RigRoot: BasePart?,
	RigWeld: Weld?,
	LayerVisuals: {[number]: LayerVisual},
	MaxLayer: number,
	LastGrabAt: number,
	VisualAccumulator: number,
	StateAccumulator: number,
	WideItemCount: number,
}

local states: {[Player]: CarryState} = {}
local itemService: any = nil

local requestGrab: RemoteEvent
local requestDrop: RemoteEvent
local carryStateRemote: RemoteEvent
local noticeRemote: RemoteEvent
local feedbackRemote: RemoteEvent

local function getStats(player: Player)
	if player:GetAttribute("CarryPreset") == "Veteran" then
		return CarryConfig.Veteran
	end
	return CarryConfig.Beginner
end

local function clampVector2(vector: Vector2, maximum: number): Vector2
	local magnitude = vector.Magnitude
	if magnitude <= maximum or magnitude <= 0.0001 then
		return vector
	end
	return vector.Unit * maximum
end

local function dangerName(risk: number): string
	local thresholds = CarryConfig.Danger
	if risk >= thresholds.NearCollapse then
		return "Near Collapse"
	elseif risk >= thresholds.Dangerous then
		return "Dangerous"
	elseif risk >= thresholds.Unstable then
		return "Unstable"
	elseif risk >= thresholds.SlightWobble then
		return "Slight Wobble"
	end
	return "Stable"
end

local function placementFor(index: number, itemId: string): (CFrame, number)
	local stack = CarryConfig.Stack
	local visual = PrototypeVisualConfig.Items[itemId]
	local definition = ItemConfig[itemId]

	local layer = math.floor((index - 1) / stack.ItemsPerLayer) + 1
	local slot = (index - 1) % stack.ItemsPerLayer
	local side = if slot == 0 then -1 else 1

	local spread = stack.SideSpacing + (layer - 1) * stack.LayerSpreadPerLevel
	local x = side * spread
	local y = stack.BaseHeight + (layer - 1) * stack.LayerHeight + visual.Size.Y * 0.5
	local z = stack.BaseForwardOffset + (if layer % 2 == 0 then 0.30 else -0.18)

	local yaw = math.rad(side * stack.CompactYawDegrees)
	local roll = math.rad(side * 2)

	if definition.ShapeTag == "Tall" then
		x *= 0.94
		y += 0.35
		roll = math.rad(-side * stack.TallOutwardRollDegrees)
	elseif definition.ShapeTag == "Wide" then
		x += side * stack.WideExtraSpread
		z -= stack.WideForwardOffset
		yaw = math.rad(side * stack.WideYawDegrees)
		roll = math.rad(side * stack.WideRollDegrees)
	end

	return CFrame.new(x, y, z) * CFrame.Angles(0, yaw, roll), layer
end

local function calculateBaseInstability(player: Player, state: CarryState): number
	local stats = getStats(player)
	local tuning = CarryConfig.BaseInstability
	local strength = math.max(stats.Strength, 0.1)
	local carrySpace = math.max(stats.CarrySpace, 0.1)

	local weightRatio = state.Weight / strength
	local bulkRatio = state.Bulk / carrySpace
	local instability = 0

	instability += math.max(0, weightRatio - tuning.WeightPressureStart) * tuning.WeightPressureScale
	instability += math.max(0, bulkRatio - tuning.BulkPressureStart) * tuning.BulkPressureScale

	local highestLayer = 0
	local shapeContribution = 0
	local highWeightContribution = 0

	for _, entry in state.Items do
		local definition = ItemConfig[entry.ItemId]
		if definition then
			highestLayer = math.max(highestLayer, entry.Layer)

			if definition.ShapeTag == "Tall" then
				shapeContribution += tuning.TallBaseContribution
					+ (entry.Layer - 1) * tuning.TallLayerContribution
			elseif definition.ShapeTag == "Wide" then
				shapeContribution += tuning.WideContribution
			end

			if entry.Layer > 1 then
				highWeightContribution += definition.Weight
					* (entry.Layer - 1)
					* tuning.HighWeightPerLayer
			end
		end
	end

	instability += math.max(0, highestLayer - 1) * tuning.LayerContribution
	instability += shapeContribution
	instability += highWeightContribution

	local controlDivisor = math.max(0.6, stats.Control ^ tuning.ControlExponent)
	return math.clamp(instability / controlDivisor, 0, tuning.MaxBaseInstability)
end

local function movementSpeedFor(player: Player, state: CarryState): number
	local stats = getStats(player)
	local ratio = state.Weight / math.max(stats.Strength, 0.1)

	if ratio <= 0.50 then
		return CarryConfig.BaseWalkSpeed
	end

	local alpha = math.clamp((ratio - 0.50) / 0.90, 0, 1)
	alpha = alpha * alpha * (3 - 2 * alpha)

	return CarryConfig.BaseWalkSpeed
		+ (CarryConfig.MinimumLoadedWalkSpeed - CarryConfig.BaseWalkSpeed) * alpha
end

local function riskValue(state: CarryState): number
	return state.BaseInstability
		+ state.CurrentSway.Magnitude * CarryConfig.Danger.SwayRiskScale
end

local function normalizedPressure(value: number, startValue: number, fullValue: number): number
	return math.clamp(
		(value - startValue) / math.max(0.01, fullValue - startValue),
		0,
		1
	)
end

local function calculateStrainLoadSeverity(player: Player, state: CarryState): number
	if #state.Items == 0 then
		return 0
	end

	local tuning = CarryConfig.Strain
	local stats = getStats(player)

	local weightRatio = state.Weight / math.max(stats.Strength, 0.1)
	local bulkRatio = state.Bulk / math.max(stats.CarrySpace, 0.1)

	local weightPressure = normalizedPressure(
		weightRatio,
		tuning.StartWeightRatio,
		tuning.FullWeightRatio
	)
	local bulkPressure = normalizedPressure(
		bulkRatio,
		tuning.StartBulkRatio,
		tuning.FullBulkRatio
	)
	local basePressure = normalizedPressure(
		state.BaseInstability,
		tuning.StartBaseInstability,
		tuning.FullBaseInstability
	)
	local heightPressure = normalizedPressure(
		state.MaxLayer,
		tuning.StartLayer,
		tuning.FullLayer
	)

	local combined = weightPressure * tuning.WeightWeight
		+ bulkPressure * tuning.BulkWeight
		+ basePressure * tuning.BaseWeight
		+ heightPressure * tuning.HeightWeight

	local peak = math.max(
		weightPressure,
		bulkPressure,
		basePressure,
		heightPressure
	)

	return math.clamp(
		peak * tuning.PeakPressureWeight
			+ combined * tuning.CombinedPressureWeight,
		0,
		1
	)
end

local function strainStageName(strain: number): string
	local tuning = CarryConfig.Strain

	if strain >= tuning.Critical then
		return "Critical"
	elseif strain >= tuning.High then
		return "High"
	elseif strain >= tuning.Moderate then
		return "Moderate"
	elseif strain > 0 then
		return "Low"
	end

	return "None"
end

local function updateStrain(player: Player, state: CarryState, dt: number)
	local tuning = CarryConfig.Strain
	local severity = state.StrainLoadSeverity

	if #state.Items == 0 then
		state.Strain = 0
	elseif severity >= tuning.MinimumLoadSeverity then
		local rate = tuning.MaxAccumulationPerSecond
			* (severity ^ tuning.AccumulationExponent)
		state.Strain = math.min(tuning.Max, state.Strain + rate * dt)
	else
		state.Strain = math.max(
			0,
			state.Strain - tuning.ComfortDecayPerSecond * dt
		)
	end

	if not state.TutorialStrainMessageShown
		and state.Strain >= tuning.TutorialMessageStrain
	then
		state.TutorialStrainMessageShown = true
		noticeRemote:FireClient(player, "LOAD PRESSURE BUILDS WHEN YOU CARRY TOO MUCH FOR TOO LONG.")
	end

	local newStage = strainStageName(state.Strain)
	if newStage ~= state.StrainStage then
		state.StrainStage = newStage
		feedbackRemote:FireClient(player, "StrainStage", {
			stage = newStage,
		})
	end
end


local function ensureRig(state: CarryState)
	local character = state.Character
	local root = state.Root
	if not character or not root then
		return
	end

	if state.RigRoot and state.RigRoot.Parent then
		return
	end

	local old = character:FindFirstChild("OneTripCarry")
	if old then
		old:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = "OneTripCarry"
	folder.Parent = character

	local rigRoot = Instance.new("Part")
	rigRoot.Name = "CarryRoot"
	rigRoot.Size = Vector3.new(1, 1, 1)
	rigRoot.Transparency = 1
	rigRoot.CanCollide = false
	rigRoot.CanTouch = false
	rigRoot.CanQuery = false
	rigRoot.Massless = true
	rigRoot.CFrame = root.CFrame
	rigRoot.Parent = folder

	local weld = Instance.new("Weld")
	weld.Name = "CarryWeld"
	weld.Part0 = root
	weld.Part1 = rigRoot
	weld.C0 = CFrame.new()
	weld.C1 = CFrame.new()
	weld.Parent = rigRoot

	state.RigFolder = folder
	state.RigRoot = rigRoot
	state.RigWeld = weld
	table.clear(state.LayerVisuals)
end

local function ensureLayerVisual(state: CarryState, layerIndex: number): LayerVisual?
	ensureRig(state)

	local existing = state.LayerVisuals[layerIndex]
	if existing and existing.Part.Parent then
		return existing
	end

	local rigRoot = state.RigRoot
	local folder = state.RigFolder
	if not rigRoot or not folder then
		return nil
	end

	local layerRoot = Instance.new("Part")
	layerRoot.Name = ("LayerRoot_%02d"):format(layerIndex)
	layerRoot.Size = Vector3.new(0.5, 0.5, 0.5)
	layerRoot.Transparency = 1
	layerRoot.CanCollide = false
	layerRoot.CanTouch = false
	layerRoot.CanQuery = false
	layerRoot.Massless = true
	layerRoot.CFrame = rigRoot.CFrame
	layerRoot.Parent = folder

	local weld = Instance.new("Weld")
	weld.Name = "LayerWeld"
	weld.Part0 = rigRoot
	weld.Part1 = layerRoot
	weld.C0 = CFrame.new()
	weld.C1 = CFrame.new()
	weld.Parent = layerRoot

	local record: LayerVisual = {
		Part = layerRoot,
		Weld = weld,
		Sway = Vector2.zero,
	}
	state.LayerVisuals[layerIndex] = record
	return record
end

local function clearCarryRig(state: CarryState)
	if state.RigFolder and state.RigFolder.Parent then
		state.RigFolder:Destroy()
	end

	state.RigFolder = nil
	state.RigRoot = nil
	state.RigWeld = nil
	table.clear(state.LayerVisuals)

	for _, entry in state.Items do
		entry.Visual = nil
		entry.VisualWeld = nil
	end
end

local function cleanupUnusedLayers(state: CarryState)
	for layerIndex, layerVisual in state.LayerVisuals do
		if layerIndex > state.MaxLayer then
			if layerVisual.Part.Parent then
				layerVisual.Part:Destroy()
			end
			state.LayerVisuals[layerIndex] = nil
		end
	end
end

local function addVisual(state: CarryState, entry: ItemEntry, index: number, pickupCFrame: CFrame?)
	local targetLocal, layerIndex = placementFor(index, entry.ItemId)
	entry.Layer = layerIndex

	local layerVisual = ensureLayerVisual(state, layerIndex)
	if not layerVisual then
		return
	end

	local visual = PrototypeVisualConfig.Items[entry.ItemId]
	local startWorld = pickupCFrame or (layerVisual.Part.CFrame * targetLocal)
	local startLocal = layerVisual.Part.CFrame:ToObjectSpace(startWorld)

	local part = Instance.new("Part")
	part.Name = ("Carry_%s_%02d"):format(entry.ItemId, index)
	part.Size = visual.Size * 0.78
	part.Color = visual.Color
	part.Material = Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.CFrame = startWorld
	part.Parent = state.RigFolder

	local weld = Instance.new("Weld")
	weld.Name = "ItemWeld"
	weld.Part0 = layerVisual.Part
	weld.Part1 = part
	weld.C0 = startLocal
	weld.C1 = CFrame.new()
	weld.Parent = part

	entry.Visual = part
	entry.VisualWeld = weld

	local definition = ItemConfig[entry.ItemId]
	local duration = CarryConfig.Feel.GrabTweenBaseSeconds
		+ definition.Weight * CarryConfig.Feel.GrabTweenPerWeightSeconds

	TweenService:Create(
		weld,
		TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ C0 = targetLocal }
	):Play()

	TweenService:Create(
		part,
		TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = visual.Size }
	):Play()
end

local function recompute(player: Player, state: CarryState)
	state.Weight = 0
	state.Bulk = 0
	state.RunValue = 0
	state.WideItemCount = 0
	state.MaxLayer = 0

	for index, entry in state.Items do
		local definition = ItemConfig[entry.ItemId]
		if definition then
			local _, layer = placementFor(index, entry.ItemId)
			entry.Layer = layer
			state.MaxLayer = math.max(state.MaxLayer, layer)
			state.Weight += definition.Weight
			state.Bulk += definition.Bulk
			state.RunValue += definition.Value

			if definition.ShapeTag == "Wide" then
				state.WideItemCount += 1
			end
		end
	end

	state.BaseInstability = calculateBaseInstability(player, state)
	state.StrainLoadSeverity = calculateStrainLoadSeverity(player, state)

	if state.Humanoid then
		state.Humanoid.WalkSpeed = movementSpeedFor(player, state)
	end

	cleanupUnusedLayers(state)
end

local function sendState(player: Player, state: CarryState, force: boolean?)
	if not player.Parent then
		return
	end

	if not force and state.StateAccumulator < (1 / CarryConfig.Movement.StateUpdateHz) then
		return
	end

	state.StateAccumulator = 0

	carryStateRemote:FireClient(player, {
		weight = state.Weight,
		bulk = state.Bulk,
		itemCount = #state.Items,
		runValue = state.RunValue,
		sessionScore = state.SessionScore,
		baseInstability = state.BaseInstability,
		currentSway = state.CurrentSway.Magnitude,
		strain = state.Strain,
		strainLoadSeverity = state.StrainLoadSeverity,
		strainStage = state.StrainStage,
		dangerState = state.DangerState,
		preset = player:GetAttribute("CarryPreset") or "Beginner",
	})
end

local function resetMotion(state: CarryState)
	state.BaseInstability = 0
	state.Strain = 0
	state.StrainLoadSeverity = 0
	state.StrainStage = "None"
	state.StrainPhase = 0
	state.DynamicSway = Vector2.zero
	state.CurrentSway = Vector2.zero
	state.CollapseStartedAt = nil
	state.DangerState = "Stable"
	state.LastVelocity = Vector3.zero
	state.LastDirection = nil
	state.MaxLayer = 0
	state.WideItemCount = 0
end

local function resetState(player: Player, state: CarryState, keepSessionScore: boolean)
	clearCarryRig(state)
	table.clear(state.Items)

	state.Weight = 0
	state.Bulk = 0
	state.RunValue = 0
	resetMotion(state)

	if not keepSessionScore then
		state.SessionScore = 0
	end

	if state.Humanoid then
		state.Humanoid.WalkSpeed = CarryConfig.BaseWalkSpeed
	end

	sendState(player, state, true)
end

local function attachCharacter(player: Player, character: Model)
	local state = states[player]
	if not state then
		return
	end

	local humanoid = character:WaitForChild("Humanoid", 8)
	local root = character:WaitForChild("HumanoidRootPart", 8)
	if not humanoid
		or not root
		or not humanoid:IsA("Humanoid")
		or not root:IsA("BasePart")
	then
		return
	end

	state.Character = character
	state.Humanoid = humanoid
	state.Root = root
	state.RigFolder = nil
	state.RigRoot = nil
	state.RigWeld = nil

	resetState(player, state, true)
	ensureRig(state)

	humanoid.Died:Connect(function()
		if states[player] == state then
			resetState(player, state, true)
		end
	end)
end

local function initializePlayer(player: Player)
	if states[player] then
		return
	end

	if player:GetAttribute("CarryPreset") == nil then
		player:SetAttribute("CarryPreset", "Beginner")
	end

	local state: CarryState = {
		Items = {},
		Weight = 0,
		Bulk = 0,
		RunValue = 0,
		SessionScore = 0,
		BaseInstability = 0,
		Strain = 0,
		StrainLoadSeverity = 0,
		StrainStage = "None",
		StrainPhase = 0,
		DynamicSway = Vector2.zero,
		CurrentSway = Vector2.zero,
		Phase = 0,
		LastVelocity = Vector3.zero,
		LastDirection = nil,
		DangerState = "Stable",
		CollapseStartedAt = nil,
		LastRecoveryFeedbackAt = -math.huge,
		TutorialWarningsEnabled = true,
		TutorialStrainMessageShown = false,
		Character = nil,
		Humanoid = nil,
		Root = nil,
		RigFolder = nil,
		RigRoot = nil,
		RigWeld = nil,
		LayerVisuals = {},
		MaxLayer = 0,
		LastGrabAt = 0,
		VisualAccumulator = 0,
		StateAccumulator = 0,
		WideItemCount = 0,
	}

	states[player] = state

	player:GetAttributeChangedSignal("CarryPreset"):Connect(function()
		if states[player] == state then
			recompute(player, state)
			sendState(player, state, true)
		end
	end)

	player.CharacterAdded:Connect(function(character)
		attachCharacter(player, character)
	end)

	if player.Character then
		task.spawn(attachCharacter, player, player.Character)
	end
end

local function applyGrabRecoil(player: Player, state: CarryState, itemId: string)
	local definition = ItemConfig[itemId]
	local stats = getStats(player)
	local side = if #state.Items % 2 == 0 then 1 else -1

	local weightRatio = definition.Weight / math.max(stats.Strength, 0.1)
	local bulkRatio = definition.Bulk / math.max(stats.CarrySpace, 0.1)

	local recoil = CarryConfig.Feel.GrabRecoilBase
		+ weightRatio * CarryConfig.Feel.GrabRecoilPerWeightRatio
		+ bulkRatio * CarryConfig.Feel.GrabRecoilPerBulkRatio

	state.DynamicSway += Vector2.new(side * recoil, recoil * 0.38)
	state.DynamicSway = clampVector2(
		state.DynamicSway,
		CarryConfig.Movement.MaxDynamicSway
	)
end

local function removeEntries(
	player: Player,
	state: CarryState,
	startIndex: number,
	notice: string,
	lostFromCollapse: boolean
)
	local removed: {{ItemId: string, StartCFrame: CFrame}} = {}

	for index = #state.Items, startIndex, -1 do
		local entry = table.remove(state.Items, index)
		if entry then
			local startCFrame = if entry.Visual and entry.Visual.Parent
				then entry.Visual.CFrame
				elseif state.Root
				then state.Root.CFrame
				else CFrame.new()

			table.insert(removed, {
				ItemId = entry.ItemId,
				StartCFrame = startCFrame,
			})

			if entry.Visual and entry.Visual.Parent then
				entry.Visual:Destroy()
			end
		end
	end

	recompute(player, state)

	state.DynamicSway *= 0.38
	state.CurrentSway = state.DynamicSway
	state.CollapseStartedAt = nil

	for index, dropped in removed do
		if lostFromCollapse then
			itemService.SpawnCollapseLoss(
				dropped.ItemId,
				dropped.StartCFrame,
				index
			)
		else
			itemService.SpawnDropped(
				dropped.ItemId,
				dropped.StartCFrame,
				player.UserId,
				index
			)
		end
	end

	if #removed > 0 then
		noticeRemote:FireClient(player, notice)
	end

	sendState(player, state, true)
end

local function calculateCollapseSeverity(
	state: CarryState,
	risk: number,
	warningDuration: number
): number
	local failure = CarryConfig.Failure
	local danger = CarryConfig.Danger

	local riskSeverity = math.clamp(
		(risk - danger.CollapseRisk)
			/ math.max(0.01, failure.RiskOvershootForMaxSeverity),
		0,
		1
	)

	local baseSeverity = math.clamp(
		(state.BaseInstability - danger.MinimumBaseForCollapse)
			/ math.max(
				0.01,
				failure.BaseInstabilityForMaxSeverity - danger.MinimumBaseForCollapse
			),
		0,
		1
	)

	local timeSeverity = math.clamp(
		(warningDuration - danger.CollapseWarningSeconds)
			/ math.max(0.01, failure.ExtraWarningSecondsForMaxSeverity),
		0,
		1
	)

	return math.clamp(
		riskSeverity * failure.RiskSeverityWeight
			+ baseSeverity * failure.BaseSeverityWeight
			+ timeSeverity * failure.TimeSeverityWeight,
		0,
		1
	)
end

local function collapseLossCount(itemCount: number, severity: number): number
	local failure = CarryConfig.Failure

	if severity <= failure.MinorSeverityMax then
		return math.min(itemCount, failure.MinimumDroppedItems)
	end

	local fraction = failure.NormalLossFraction
	if severity >= failure.SevereSeverityMin then
		fraction = failure.SevereLossFraction
	else
		local alpha = math.clamp(
			(severity - failure.MinorSeverityMax)
				/ math.max(0.01, failure.SevereSeverityMin - failure.MinorSeverityMax),
			0,
			1
		)
		fraction = failure.NormalLossFraction
			+ (failure.SevereLossFraction - failure.NormalLossFraction) * alpha
	end

	return math.clamp(
		math.max(failure.MinimumDroppedItems, math.ceil(itemCount * fraction)),
		1,
		itemCount
	)
end

local function partialCollapse(
	player: Player,
	state: CarryState,
	risk: number,
	warningDuration: number
)
	if #state.Items == 0 then
		return
	end

	local severity = calculateCollapseSeverity(state, risk, warningDuration)
	local count = collapseLossCount(#state.Items, severity)
	local startIndex = math.max(1, #state.Items - count + 1)

	removeEntries(
		player,
		state,
		startIndex,
		("NOOO - %d items lost!"):format(count),
		true
	)

	feedbackRemote:FireClient(player, "Collapse", {
		droppedCount = count,
		severity = severity,
	})
end

local function handleGrab(player: Player, candidate: any)
	if typeof(candidate) ~= "Instance" then
		return
	end

	local state = states[player]
	if not state
		or not state.Root
		or not state.Humanoid
		or state.Humanoid.Health <= 0
	then
		return
	end

	if #state.Items >= CarryConfig.TechnicalMaxItems then
		noticeRemote:FireClient(player, "Prototype guardrail reached.")
		return
	end

	local now = os.clock()
	if now - state.LastGrabAt < 0.08 then
		return
	end
	state.LastGrabAt = now

	local success, itemId, pickupCFrame = itemService.TryTake(player, candidate)
	if not success or not itemId then
		return
	end

	local entry: ItemEntry = {
		ItemId = itemId,
		Layer = 1,
		Visual = nil,
		VisualWeld = nil,
	}

	table.insert(state.Items, entry)
	addVisual(state, entry, #state.Items, pickupCFrame)
	recompute(player, state)
	applyGrabRecoil(player, state, itemId)

	local definition = ItemConfig[itemId]

	feedbackRemote:FireClient(player, "Grab", {
		itemId = itemId,
		weight = definition.Weight,
		bulk = definition.Bulk,
		value = definition.Value,
	})

	sendState(player, state, true)
end

local function handleDrop(player: Player)
	local state = states[player]
	if not state or #state.Items == 0 then
		return
	end

	removeEntries(player, state, #state.Items, "Dropped the top item.", false)
end

local function updateLayerVisuals(state: CarryState, risk: number, dt: number)
	if state.MaxLayer <= 0 then
		return
	end

	local stack = CarryConfig.Stack
	local dangerRange = math.max(
		0.01,
		CarryConfig.Danger.CollapseRisk - CarryConfig.Danger.Dangerous
	)
	local dangerAlpha = math.clamp(
		(risk - CarryConfig.Danger.Dangerous) / dangerRange,
		0,
		1
	)

	if state.CollapseStartedAt then
		dangerAlpha = math.max(dangerAlpha, 0.92)
	end

	for layerIndex, layerVisual in state.LayerVisuals do
		if layerVisual.Part.Parent then
			local layerMultiplier = math.min(
				stack.MaxLayerVisualMultiplier,
				1 + (layerIndex - 1) * stack.LayerSwayAmplification
			)

			local target = state.CurrentSway * layerMultiplier
			local followRate = math.max(
				stack.MinimumLayerFollowRate,
				stack.LayerFollowRate - (layerIndex - 1) * stack.LayerLagPerLevel
			)
			local alpha = 1 - math.exp(-followRate * dt)
			layerVisual.Sway = layerVisual.Sway:Lerp(target, alpha)

			local topFactor = (layerIndex / math.max(1, state.MaxLayer)) ^ 1.35
			local shake = math.sin(
				state.Phase * stack.NearCollapseShakeSpeed + layerIndex * 1.73
			) * stack.NearCollapseShake * dangerAlpha * topFactor

			local strainAlpha = math.clamp(
				state.Strain / math.max(0.01, CarryConfig.Strain.Max),
				0,
				1
			)
			local strainShake = math.sin(
				state.StrainPhase * 1.55 + layerIndex * 2.11
			) * CarryConfig.Strain.VisualShakeAtMax * strainAlpha * topFactor

			local visualX = layerVisual.Sway.X + shake + strainShake
			local visualY = layerVisual.Sway.Y
				+ math.cos(state.Phase * 0.81 + layerIndex) * shake * 0.35
				+ strainShake * 0.30

			local lean = math.clamp(visualX, -1.35, 1.35)
				* math.rad(stack.MaxVisualLeanDegrees)
			local pitch = math.clamp(visualY, -1.20, 1.20)
				* math.rad(stack.MaxVisualPitchDegrees)

			local slipDirection = if visualX >= 0 then 1 else -1
			local slip = slipDirection
				* stack.NearCollapseSlipStuds
				* dangerAlpha
				* topFactor

			local xOffset = math.clamp(visualX, -1, 1)
				* stack.MaxVisualOffsetStuds
				+ slip

			layerVisual.Weld.C0 = CFrame.new(xOffset, 0, 0)
				* CFrame.Angles(pitch, 0, -lean)
		end
	end
end

local function updateMovement(player: Player, state: CarryState, dt: number)
	local root = state.Root
	local humanoid = state.Humanoid

	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end

	local velocity3 = root.AssemblyLinearVelocity
	local horizontalVelocity = Vector3.new(velocity3.X, 0, velocity3.Z)
	local speed = horizontalVelocity.Magnitude
	local movement = CarryConfig.Movement
	local strainTuning = CarryConfig.Strain

	updateStrain(player, state, dt)

	local strainAlpha = math.clamp(
		state.Strain / math.max(0.01, strainTuning.Max),
		0,
		1
	)
	local swayGenerationMultiplier = 1
		+ (strainTuning.SwayGenerationMultiplierAtMax - 1) * strainAlpha
	local recoveryMultiplier = 1
		- (1 - strainTuning.MinimumRecoveryMultiplierAtMax) * strainAlpha

	local acceleration = (horizontalVelocity - state.LastVelocity)
		/ math.max(dt, 1 / 240)
	state.LastVelocity = horizontalVelocity

	local decayRate = if speed <= movement.VelocityDeadzone
		then movement.StoppedRecoveryRate
		else movement.MovingRecoveryRate
	decayRate *= recoveryMultiplier

	state.DynamicSway *= math.exp(-decayRate * dt)

	if acceleration.Magnitude > movement.AccelerationDeadzone then
		local localAcceleration = root.CFrame:VectorToObjectSpace(acceleration)
		local filtered = Vector2.new(localAcceleration.X, -localAcceleration.Z)

		local excessScale = math.clamp(
			(acceleration.Magnitude - movement.AccelerationDeadzone)
				/ math.max(acceleration.Magnitude, 0.001),
			0,
			1
		)

		state.DynamicSway += filtered
			* movement.AccelerationGain
			* dt
			* excessScale
			* swayGenerationMultiplier
	end

	if speed >= movement.TurnMinimumSpeed then
		local direction = horizontalVelocity.Unit
		local previous = state.LastDirection

		if previous then
			local dot = math.clamp(previous:Dot(direction), -1, 1)
			local angle = math.acos(dot)

			if math.deg(angle) >= movement.TurnAngleDeadzoneDegrees then
				local sign = math.sign(previous:Cross(direction).Y)
				local wideMultiplier = 1
					+ state.WideItemCount * movement.WideTurnMultiplierPerItem

				state.DynamicSway += Vector2.new(
					sign * angle * movement.TurnGain * wideMultiplier * swayGenerationMultiplier,
					0
				)
			end
		end

		state.LastDirection = direction
	elseif speed <= movement.VelocityDeadzone then
		state.LastDirection = nil
	end

	state.DynamicSway = clampVector2(
		state.DynamicSway,
		movement.MaxDynamicSway
	)

	state.Phase += speed * dt * 0.55
	state.StrainPhase += dt * strainTuning.TremorFrequency

	local movementRatio = math.clamp(
		speed / CarryConfig.BaseWalkSpeed,
		0,
		1.5
	)

	local oscillationAmplitude = state.BaseInstability
		* movement.MovementOscillationScale
		* movementRatio

	local oscillation = Vector2.new(
		math.sin(state.Phase) * oscillationAmplitude,
		math.cos(state.Phase * 0.73)
			* oscillationAmplitude
			* 0.38
	)

	local tremorAlpha = math.clamp(
		(state.Strain - strainTuning.TremorStart)
			/ math.max(0.01, strainTuning.Max - strainTuning.TremorStart),
		0,
		1
	)
	local tremorAmplitude = tremorAlpha * strainTuning.TremorAmplitudeAtMax
	local strainTremor = Vector2.new(
		math.sin(state.StrainPhase) * tremorAmplitude,
		math.cos(state.StrainPhase) * tremorAmplitude * strainTuning.TremorVerticalRatio
	)

	state.CurrentSway = state.DynamicSway + oscillation + strainTremor

	local risk = riskValue(state)
	local newDanger = dangerName(risk)

	if newDanger ~= state.DangerState then
		state.DangerState = newDanger
		sendState(player, state, true)
	end

	if state.BaseInstability >= CarryConfig.Danger.MinimumBaseForCollapse
		and state.CurrentSway.Magnitude >= CarryConfig.Danger.MinimumSwayForCollapse
		and risk >= CarryConfig.Danger.CollapseRisk
	then
		if not state.CollapseStartedAt then
			state.CollapseStartedAt = os.clock()
			if state.TutorialWarningsEnabled then
				noticeRemote:FireClient(player, "STOP OR IT WILL FALL!")
			end
			feedbackRemote:FireClient(player, "Warning", {})
		elseif os.clock() - state.CollapseStartedAt
			>= CarryConfig.Danger.CollapseWarningSeconds
		then
			local warningDuration = os.clock() - state.CollapseStartedAt
			partialCollapse(player, state, risk, warningDuration)
		end
	elseif risk <= CarryConfig.Danger.RecoveryRisk
		or state.CurrentSway.Magnitude
			< CarryConfig.Danger.MinimumSwayForCollapse * 0.75
	then
		if state.CollapseStartedAt then
			local warningDuration = os.clock() - state.CollapseStartedAt
			local sinceLastRecovery = os.clock() - state.LastRecoveryFeedbackAt

			state.CollapseStartedAt = nil

			if warningDuration >= CarryConfig.Danger.RecoveryFeedbackMinWarningSeconds
				and sinceLastRecovery >= CarryConfig.Danger.RecoveryFeedbackCooldownSeconds
			then
				state.LastRecoveryFeedbackAt = os.clock()
				if state.TutorialWarningsEnabled then
					noticeRemote:FireClient(player, "SAVED IT.")
				end
				feedbackRemote:FireClient(player, "Recovered", {
					showText = state.TutorialWarningsEnabled,
				})
			end
		end
	end

	state.VisualAccumulator += dt
	state.StateAccumulator += dt

	if state.VisualAccumulator >= (1 / movement.VisualUpdateHz) then
		local visualDt = state.VisualAccumulator
		state.VisualAccumulator = 0
		updateLayerVisuals(state, risk, visualDt)
	end

	sendState(player, state, false)
end

local function animateUnloadVisuals(state: CarryState, unloadCFrame: CFrame)
	local root = Workspace:FindFirstChild("OneTripPrototype")
	local feedbackFolder = root and root:FindFirstChild("Feedback")

	for index, entry in state.Items do
		local part = entry.Visual

		if part and part.Parent then
			if entry.VisualWeld and entry.VisualWeld.Parent then
				entry.VisualWeld:Destroy()
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Parent = feedbackFolder or Workspace

			local row = math.floor((index - 1) / 4)
			local column = (index - 1) % 4
			local x = (column - 1.5) * 1.2
			local target = unloadCFrame
				* CFrame.new(x, 1 + row * 0.20, 0)
				* CFrame.Angles(
					math.rad(12 * row),
					math.rad(index * 29),
					math.rad((column - 1.5) * 10)
				)

			local originalSize = part.Size
			local delaySeconds = (index - 1)
				* CarryConfig.Feel.UnloadStaggerSeconds

			task.delay(delaySeconds, function()
				if not part.Parent then
					return
				end

				local tween = TweenService:Create(
					part,
					TweenInfo.new(
						CarryConfig.Feel.UnloadTweenSeconds,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In
					),
					{
						CFrame = target,
						Size = originalSize * 0.18,
						Transparency = 0.55,
					}
				)

				tween:Play()
				tween.Completed:Once(function()
					if part.Parent then
						part:Destroy()
					end
				end)
			end)

			entry.Visual = nil
			entry.VisualWeld = nil
		end
	end
end

function CarryService.Unload(player: Player, unloadCFrame: CFrame?): number
	local state = states[player]
	if not state or #state.Items == 0 then
		return 0
	end

	local score = state.RunValue
	local itemCount = #state.Items
	state.SessionScore += score

	-- The first successful delivery ends the temporary teaching phase for this
	-- play session. From then on, players must read the pile itself.
	state.TutorialWarningsEnabled = false

	animateUnloadVisuals(
		state,
		unloadCFrame or CFrame.new(0, 1, 0)
	)

	table.clear(state.Items)
	clearCarryRig(state)

	state.Weight = 0
	state.Bulk = 0
	state.RunValue = 0
	resetMotion(state)

	if state.Humanoid then
		state.Humanoid.WalkSpeed = CarryConfig.BaseWalkSpeed
	end

	noticeRemote:FireClient(
		player,
		("MADE IT! +%d TEST SCORE"):format(score)
	)

	feedbackRemote:FireClient(player, "Unload", {
		score = score,
		itemCount = itemCount,
	})

	sendState(player, state, true)
	return score
end

function CarryService.Start(itemServiceModule: any)
	itemService = itemServiceModule

	requestGrab = RemoteService.Get(RemoteNames.RequestGrab)
	requestDrop = RemoteService.Get(RemoteNames.RequestDrop)
	carryStateRemote = RemoteService.Get(RemoteNames.CarryState)
	noticeRemote = RemoteService.Get(RemoteNames.PrototypeNotice)
	feedbackRemote = RemoteService.Get(RemoteNames.PrototypeFeedback)

	requestGrab.OnServerEvent:Connect(handleGrab)
	requestDrop.OnServerEvent:Connect(handleDrop)

	Players.PlayerAdded:Connect(initializePlayer)

	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		initializePlayer(player)
	end

	RunService.Heartbeat:Connect(function(dt)
		for player, state in states do
			updateMovement(player, state, dt)
		end
	end)
end

return CarryService
