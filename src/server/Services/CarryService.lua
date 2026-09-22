--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local CarryService = {}

type ItemEntry = {
	ItemId: string,
	Layer: number,
	Visual: BasePart?,
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
	RigRoot: BasePart?,
	RigWeld: Weld?,
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

local function getStats(player: Player)
	local presetName = player:GetAttribute("CarryPreset")
	if presetName == "Veteran" then
		return CarryConfig.Veteran
	end
	return CarryConfig.Beginner
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
	local xSlots = { -stack.SideSpacing, 0, stack.SideSpacing }

	local x = xSlots[slot + 1]
	local y = stack.BaseHeight + (layer - 1) * stack.LayerHeight + visual.Size.Y * 0.5
	local z = stack.BaseForwardOffset

	if definition.ShapeTag == "Wide" then
		x *= 0.65
		z -= 0.25 * ((layer - 1) % 2)
	elseif definition.ShapeTag == "Tall" then
		x *= 0.8
	end

	return CFrame.new(x, y, z), layer
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
				shapeContribution += tuning.TallBaseContribution + (entry.Layer - 1) * tuning.TallLayerContribution
			elseif definition.ShapeTag == "Wide" then
				shapeContribution += tuning.WideContribution
			end

			if entry.Layer > 1 then
				highWeightContribution += definition.Weight * (entry.Layer - 1) * tuning.HighWeightPerLayer
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
	if ratio <= 0.5 then
		return CarryConfig.BaseWalkSpeed
	end

	local alpha = math.clamp((ratio - 0.5) / 1.0, 0, 1)
	alpha = alpha * alpha * (3 - 2 * alpha)
	return CarryConfig.BaseWalkSpeed
		+ (CarryConfig.MinimumLoadedWalkSpeed - CarryConfig.BaseWalkSpeed) * alpha
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

	state.RigRoot = rigRoot
	state.RigWeld = weld
end

local function clearVisuals(state: CarryState)
	for _, entry in state.Items do
		if entry.Visual and entry.Visual.Parent then
			entry.Visual:Destroy()
		end
		entry.Visual = nil
	end
end

local function rebuildVisuals(state: CarryState)
	ensureRig(state)
	local rigRoot = state.RigRoot
	if not rigRoot then
		return
	end

	clearVisuals(state)

	for index, entry in state.Items do
		local visual = PrototypeVisualConfig.Items[entry.ItemId]
		if visual then
			local localCFrame, layer = placementFor(index, entry.ItemId)
			entry.Layer = layer

			local part = Instance.new("Part")
			part.Name = ("Carry_%s_%02d"):format(entry.ItemId, index)
			part.Size = visual.Size
			part.Color = visual.Color
			part.Material = Enum.Material.SmoothPlastic
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.CFrame = rigRoot.CFrame * localCFrame
			part.Parent = rigRoot.Parent

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = rigRoot
			weld.Part1 = part
			weld.Parent = part

			entry.Visual = part
		end
	end
end

local function recompute(player: Player, state: CarryState)
	state.Weight = 0
	state.Bulk = 0
	state.RunValue = 0
	state.WideItemCount = 0

	for index, entry in state.Items do
		local definition = ItemConfig[entry.ItemId]
		if definition then
			local _, layer = placementFor(index, entry.ItemId)
			entry.Layer = layer
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
end

local function riskValue(state: CarryState): number
	return state.BaseInstability + state.CurrentSway.Magnitude * CarryConfig.Danger.SwayRiskScale
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

local function resetState(player: Player, state: CarryState, keepSessionScore: boolean)
	clearVisuals(state)
	table.clear(state.Items)
	state.Weight = 0
	state.Bulk = 0
	state.RunValue = 0
	state.BaseInstability = 0
	state.DynamicSway = Vector2.zero
	state.CurrentSway = Vector2.zero
	state.CollapseStartedAt = nil
	state.DangerState = "Stable"
	state.LastVelocity = Vector3.zero
	state.LastDirection = nil

	if not keepSessionScore then
		state.SessionScore = 0
	end
	if state.Humanoid then
		state.Humanoid.WalkSpeed = CarryConfig.BaseWalkSpeed
	end
	if state.RigWeld then
		state.RigWeld.C0 = CFrame.new()
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
	if not humanoid or not root or not humanoid:IsA("Humanoid") or not root:IsA("BasePart") then
		return
	end

	state.Character = character
	state.Humanoid = humanoid
	state.Root = root
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
		RigRoot = nil,
		RigWeld = nil,
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

local function dropEntries(player: Player, state: CarryState, startIndex: number, notice: string)
	local root = state.Root
	if not root then
		return
	end

	local removed: {string} = {}

	for index = #state.Items, startIndex, -1 do
		local entry = table.remove(state.Items, index)
		if entry then
			table.insert(removed, entry.ItemId)
			if entry.Visual and entry.Visual.Parent then
				entry.Visual:Destroy()
			end
		end
	end

	rebuildVisuals(state)
	recompute(player, state)

	state.DynamicSway *= 0.45
	state.CurrentSway = state.DynamicSway
	state.CollapseStartedAt = nil

	for index, itemId in removed do
		itemService.SpawnDropped(itemId, root.CFrame, player.UserId, index)
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
	dropEntries(player, state, startIndex, "PARTIAL COLLAPSE - you pushed it too far.")
end

local function handleGrab(player: Player, candidate: Instance)
	local state = states[player]
	if not state or not state.Root or not state.Humanoid or state.Humanoid.Health <= 0 then
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

	local success, itemId = itemService.TryTake(player, candidate)
	if not success or not itemId then
		return
	end

	table.insert(state.Items, {
		ItemId = itemId,
		Layer = 1,
		Visual = nil,
	})

	rebuildVisuals(state)
	recompute(player, state)

	local definition = ItemConfig[itemId]
	if definition then
		noticeRemote:FireClient(
			player,
			("Grabbed %s (+%d test value)"):format(definition.Name, definition.Value)
		)
	end

	sendState(player, state, true)
end

local function handleDrop(player: Player)
	local state = states[player]
	if not state or #state.Items == 0 then
		return
	end
	dropEntries(player, state, #state.Items, "Dropped top item.")
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

	local acceleration = (horizontalVelocity - state.LastVelocity) / math.max(dt, 1 / 240)
	state.LastVelocity = horizontalVelocity

	local decayRate = if speed <= movement.VelocityDeadzone
		then movement.StoppedRecoveryRate
		else movement.MovingRecoveryRate
	state.DynamicSway *= math.exp(-decayRate * dt)

	if acceleration.Magnitude > movement.AccelerationDeadzone then
		local localAcceleration = root.CFrame:VectorToObjectSpace(acceleration)
		local filtered = Vector2.new(localAcceleration.X, -localAcceleration.Z)
		local excessScale = math.clamp(
			(acceleration.Magnitude - movement.AccelerationDeadzone) / math.max(acceleration.Magnitude, 0.001),
			0,
			1
		)
		state.DynamicSway += filtered * movement.AccelerationGain * dt * excessScale
	end

	if speed >= movement.TurnMinimumSpeed then
		local direction = horizontalVelocity.Unit
		local previous = state.LastDirection

		if previous then
			local dot = math.clamp(previous:Dot(direction), -1, 1)
			local angle = math.acos(dot)
			if math.deg(angle) >= movement.TurnAngleDeadzoneDegrees then
				local sign = math.sign(previous:Cross(direction).Y)
				local wideMultiplier = 1 + state.WideItemCount * movement.WideTurnMultiplierPerItem
				state.DynamicSway += Vector2.new(sign * angle * movement.TurnGain * wideMultiplier, 0)
			end
		end

		state.LastDirection = direction
	elseif speed <= movement.VelocityDeadzone then
		state.LastDirection = nil
	end

	state.Phase += speed * dt * 0.55
	local movementRatio = math.clamp(speed / CarryConfig.BaseWalkSpeed, 0, 1.5)
	local oscillationAmplitude = state.BaseInstability
		* movement.MovementOscillationScale
		* movementRatio
	local oscillation = Vector2.new(
		math.sin(state.Phase) * oscillationAmplitude,
		math.cos(state.Phase * 0.73) * oscillationAmplitude * 0.38
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
			noticeRemote:FireClient(player, "THE PILE IS GOING - recover!")
		elseif os.clock() - state.CollapseStartedAt >= CarryConfig.Danger.CollapseWarningSeconds then
			partialCollapse(player, state)
		end
	elseif risk <= CarryConfig.Danger.RecoveryRisk
		or state.CurrentSway.Magnitude < CarryConfig.Danger.MinimumSwayForCollapse * 0.75
	then
		state.CollapseStartedAt = nil
	end

	state.VisualAccumulator += dt
	state.StateAccumulator += dt

	if state.RigWeld and state.VisualAccumulator >= (1 / movement.VisualUpdateHz) then
		state.VisualAccumulator = 0

		local maxLean = math.rad(CarryConfig.Stack.MaxVisualLeanDegrees)
		local maxPitch = math.rad(CarryConfig.Stack.MaxVisualPitchDegrees)
		local lean = math.clamp(state.CurrentSway.X, -1, 1) * maxLean
		local pitch = math.clamp(state.CurrentSway.Y, -1, 1) * maxPitch
		local offset = math.clamp(state.CurrentSway.X, -1, 1)
			* CarryConfig.Stack.MaxVisualOffsetStuds

		state.RigWeld.C0 = CFrame.new(offset, 0, 0) * CFrame.Angles(pitch, 0, -lean)
	end

	sendState(player, state, false)
end

function CarryService.Unload(player: Player): number
	local state = states[player]
	if not state or #state.Items == 0 then
		return 0
	end

	local score = state.RunValue
	state.SessionScore += score

	clearVisuals(state)
	table.clear(state.Items)

	state.Weight = 0
	state.Bulk = 0
	state.RunValue = 0
	state.BaseInstability = 0
	state.DynamicSway = Vector2.zero
	state.CurrentSway = Vector2.zero
	state.CollapseStartedAt = nil
	state.DangerState = "Stable"

	if state.Humanoid then
		state.Humanoid.WalkSpeed = CarryConfig.BaseWalkSpeed
	end
	if state.RigWeld then
		state.RigWeld.C0 = CFrame.new()
	end

	noticeRemote:FireClient(player, ("DELIVERED +%d TEST SCORE"):format(score))
	sendState(player, state, true)

	return score
end

function CarryService.Start(itemServiceModule: any)
	itemService = itemServiceModule

	requestGrab = RemoteService.Get(RemoteNames.RequestGrab)
	requestDrop = RemoteService.Get(RemoteNames.RequestDrop)
	carryStateRemote = RemoteService.Get(RemoteNames.CarryState)
	noticeRemote = RemoteService.Get(RemoteNames.PrototypeNotice)

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
