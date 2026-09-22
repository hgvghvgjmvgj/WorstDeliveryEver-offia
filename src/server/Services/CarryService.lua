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
	DynamicSway: Vector2,
	CurrentSway: Vector2,
	Phase: number,
	LastVelocity: Vector3,
	LastDirection: Vector3?,
	DangerState: string,
	CollapseStartedAt: number?,
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
		dangerState = state.DangerState,
		preset = player:GetAttribute("CarryPreset") or "Beginner",
	})
end

local function resetMotion(state: CarryState)
	state.BaseInstability = 0
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
		DynamicSway = Vector2.zero,
		CurrentSway = Vector2.zero,
		Phase = 0,
		LastVelocity = Vector3.zero,
		LastDirection = nil,
		DangerState = "Stable",
		CollapseStartedAt = nil,
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

local function dropEntries(player: Player, state: CarryState, startIndex: number, notice: string)
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
		itemService.SpawnDropped(
			dropped.ItemId,
			dropped.StartCFrame,
			player.UserId,
			index
		)
	end

	if #removed > 0 then
		noticeRemote:FireClient(player, notice)
	end

	sendState(player, state, true)
end

local function partialCollapse(player: Player, state: CarryState)
	if #state.Items == 0 then
		return
	end

	local count = math.max(
		CarryConfig.Failure.MinimumDroppedItems,
		math.ceil(#state.Items * CarryConfig.Failure.PartialCollapseFraction)
	)

	local startIndex = math.max(1, #state.Items - count + 1)
	dropEntries(
		player,
		state,
		startIndex,
		("NOOO - %d items fell!"):format(count)
	)

	feedbackRemote:FireClient(player, "Collapse", {
		droppedCount = count,
	})
end

local function handleGrab(player: Player, candidate: Instance)
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

	dropEntries(player, state, #state.Items, "Dropped the top item.")
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

			local visualX = layerVisual.Sway.X + shake
			local visualY = layerVisual.Sway.Y
				+ math.cos(state.Phase * 0.81 + layerIndex) * shake * 0.35

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

	local acceleration = (horizontalVelocity - state.LastVelocity)
		/ math.max(dt, 1 / 240)
	state.LastVelocity = horizontalVelocity

	local decayRate = if speed <= movement.VelocityDeadzone
		then movement.StoppedRecoveryRate
		else movement.MovingRecoveryRate

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
					sign * angle * movement.TurnGain * wideMultiplier,
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

	state.CurrentSway = state.DynamicSway + oscillation

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
			noticeRemote:FireClient(player, "OH SHIT - STOP OR CORRECT!")
			feedbackRemote:FireClient(player, "Warning", {})
		elseif os.clock() - state.CollapseStartedAt
			>= CarryConfig.Danger.CollapseWarningSeconds
		then
			partialCollapse(player, state)
		end
	elseif risk <= CarryConfig.Danger.RecoveryRisk
		or state.CurrentSway.Magnitude
			< CarryConfig.Danger.MinimumSwayForCollapse * 0.75
	then
		if state.CollapseStartedAt then
			state.CollapseStartedAt = nil
			noticeRemote:FireClient(player, "SAVED IT.")
			feedbackRemote:FireClient(player, "Recovered", {})
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
