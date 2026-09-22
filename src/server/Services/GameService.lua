local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ItemConfig = require(ReplicatedStorage:WaitForChild("ItemConfig"))
local PrototypeConfig = require(ReplicatedStorage:WaitForChild("PrototypeConfig"))

local GameService = {}

local playerStates = {}
local stateChangedRemote

local function getCharacterPieces(player)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	return character, humanoid, root
end

local function getPayout(state)
	if #state.items == 0 then
		return 0
	end

	return math.floor(state.baseReward * PrototypeConfig.GetPayoutMultiplier(#state.items))
end

local function makeSnapshot(state, message)
	return {
		phase = state.phase,
		count = #state.items,
		weight = state.weight,
		balance = math.floor(state.balance + 0.5),
		possiblePayout = getPayout(state),
		cash = state.cash,
		message = message,
	}
end

local function publish(player, message)
	local state = playerStates[player]
	if state and stateChangedRemote then
		stateChangedRemote:FireClient(player, makeSnapshot(state, message))
	end
end

local function clearCarryVisuals(state)
	for _, visual in state.visuals do
		if visual.part and visual.part.Parent then
			visual.part:Destroy()
		end
	end
	table.clear(state.visuals)
end

local function restoreMovement(player)
	local _, humanoid = getCharacterPieces(player)
	if humanoid then
		humanoid.WalkSpeed = PrototypeConfig.BaseWalkSpeed
	end
end

local function teleportToSpawn(player)
	local _, _, root = getCharacterPieces(player)
	local world = Workspace:FindFirstChild("OneTripPrototype")
	local spawn = world and world:FindFirstChild("PrototypeSpawn")
	if root and spawn then
		root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
	end
end

local function restorePickupItems()
	local world = Workspace:FindFirstChild("OneTripPrototype")
	local itemsFolder = world and world:FindFirstChild("PickupItems")
	if not itemsFolder then
		return
	end

	for _, itemPart in itemsFolder:GetChildren() do
		if itemPart:IsA("BasePart") then
			itemPart.Transparency = 0
			itemPart.CanCollide = true
			local prompt = itemPart:FindFirstChild("InteractionPrompt")
			if prompt and prompt:IsA("ProximityPrompt") then
				prompt.Enabled = true
			end
		end
	end
end

local function resetTrip(player, message)
	local state = playerStates[player]
	if not state then
		return
	end

	clearCarryVisuals(state)
	restorePickupItems()

	state.phase = "Loading"
	state.items = {}
	state.taken = {}
	state.weight = 0
	state.baseReward = 0
	state.balance = 0
	state.lastVelocity = Vector3.zero
	state.lastLook = Vector3.new(0, 0, -1)
	state.wasGrounded = true
	state.lastHazardHit = 0

	restoreMovement(player)
	teleportToSpawn(player)
	publish(player, message or "Grab groceries → START TRIP → reach the front door. More = more cash + more risk.")
end

local function getCarryOffset(index)
	local offsets = PrototypeConfig.CarryOffsets
	local base = offsets[((index - 1) % #offsets) + 1]
	local layer = math.floor((index - 1) / #offsets)
	return base * CFrame.new(0, layer * 1.5, 0)
end

local function attachItemVisual(player, itemId, itemIndex)
	local state = playerStates[player]
	local definition = ItemConfig.Get(itemId)
	local character, _, root = getCharacterPieces(player)
	if not state or not definition or not character or not root then
		return
	end

	local part = Instance.new("Part")
	part.Name = "Carried_" .. itemId
	part.Size = definition.Size
	part.Color = definition.Color
	part.Material = Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Parent = character

	local baseOffset = getCarryOffset(itemIndex)
	part.CFrame = root.CFrame * baseOffset

	local weld = Instance.new("Weld")
	weld.Name = "CarryWeld"
	weld.Part0 = root
	weld.Part1 = part
	weld.C0 = baseOffset
	weld.Parent = part

	table.insert(state.visuals, {
		part = part,
		weld = weld,
		baseOffset = baseOffset,
	})
end

local function applyCarrySpeed(player)
	local state = playerStates[player]
	local _, humanoid = getCharacterPieces(player)
	if not state or not humanoid then
		return
	end

	local speed = PrototypeConfig.BaseWalkSpeed - (state.weight * PrototypeConfig.WalkSpeedLossPerWeight)
	humanoid.WalkSpeed = math.max(PrototypeConfig.MinimumWalkSpeed, speed)
end

local function takeItem(player, itemId)
	local state = playerStates[player]
	local definition = ItemConfig.Get(itemId)

	if not state or state.phase ~= "Loading" or not definition then
		return
	end

	if state.taken[itemId] then
		publish(player, "You already grabbed that one.")
		return
	end

	local oldPayout = getPayout(state)

	state.taken[itemId] = true
	table.insert(state.items, itemId)
	state.weight += definition.Weight
	state.baseReward += definition.Reward

	local world = Workspace:FindFirstChild("OneTripPrototype")
	local itemsFolder = world and world:FindFirstChild("PickupItems")
	local pickupPart = itemsFolder and itemsFolder:FindFirstChild(itemId)
	if pickupPart and pickupPart:IsA("BasePart") then
		pickupPart.Transparency = 1
		pickupPart.CanCollide = false
		local prompt = pickupPart:FindFirstChild("InteractionPrompt")
		if prompt and prompt:IsA("ProximityPrompt") then
			prompt.Enabled = false
		end
	end

	attachItemVisual(player, itemId, #state.items)
	applyCarrySpeed(player)

	local newPayout = getPayout(state)
	if #state.items == 1 then
		publish(player, ("+$%d possible. Take more for a bigger multiplier."):format(newPayout))
	elseif #state.items >= 5 then
		publish(player, ("FULL LOAD: $%d possible. This should be dangerous."):format(newPayout))
	else
		publish(player, ("Payout $%d → $%d. Take another?"):format(oldPayout, newPayout))
	end
end

local function startTrip(player)
	local state = playerStates[player]
	if not state or state.phase ~= "Loading" then
		return
	end

	if #state.items == 0 then
		publish(player, "Grab at least one item first.")
		return
	end

	local _, humanoid, root = getCharacterPieces(player)
	state.phase = "Carrying"
	state.balance = 0
	state.lastVelocity = root and root.AssemblyLinearVelocity or Vector3.zero
	state.lastLook = root and root.CFrame.LookVector or Vector3.new(0, 0, -1)
	state.wasGrounded = humanoid and humanoid.FloorMaterial ~= Enum.Material.Air or true

	if state.weight <= PrototypeConfig.SafeWeight then
		publish(player, "Light load. Get it to the front door.")
	elseif state.weight >= PrototypeConfig.HeavyWeightThreshold then
		publish(player, "HEAVY LOAD. Move smoothly, avoid hazards, and stop to recover.")
	else
		publish(player, "Watch your BALANCE. Sharp turns and obstacles hurt.")
	end
end

local function explodeGroceries(player)
	local state = playerStates[player]
	if not state then
		return
	end

	for index, visual in state.visuals do
		if visual.weld and visual.weld.Parent then
			visual.weld:Destroy()
		end

		local part = visual.part
		if part and part.Parent then
			part.Parent = Workspace
			part.CanCollide = true
			part.CanTouch = true
			part.Massless = false

			local side = (index % 2 == 0) and 1 or -1
			part:ApplyImpulse(Vector3.new(side * 28, 35 + index * 2, 18) * part.AssemblyMass)
			game:GetService("Debris"):AddItem(part, PrototypeConfig.ResultDelay)
		end
	end

	table.clear(state.visuals)
end

local function failTrip(player)
	local state = playerStates[player]
	if not state or state.phase ~= "Carrying" then
		return
	end

	state.phase = "Failed"
	state.balance = PrototypeConfig.MaxBalance
	restoreMovement(player)
	explodeGroceries(player)
	publish(player, "YOU DROPPED EVERYTHING")

	task.delay(PrototypeConfig.ResultDelay, function()
		if player.Parent and playerStates[player] == state and state.phase == "Failed" then
			resetTrip(player, "Try again. Take less—or move smarter.")
		end
	end)
end

local function completeTrip(player)
	local state = playerStates[player]
	if not state or state.phase ~= "Carrying" then
		return
	end

	local payout = getPayout(state)

	state.cash += payout
	state.phase = "Delivered"
	state.balance = 0

	clearCarryVisuals(state)
	restoreMovement(player)
	publish(player, ("ONE TRIP COMPLETE! +$%d"):format(payout))

	task.delay(PrototypeConfig.ResultDelay, function()
		if player.Parent and playerStates[player] == state and state.phase == "Delivered" then
			resetTrip(player, "New run. How greedy are you feeling?")
		end
	end)
end

local function addBalanceSpike(player, amount, message)
	local state = playerStates[player]
	if not state or state.phase ~= "Carrying" then
		return
	end

	state.balance = math.clamp(state.balance + amount, 0, PrototypeConfig.MaxBalance)
	publish(player, message)

	if state.balance >= PrototypeConfig.MaxBalance then
		failTrip(player)
	end
end

local function setupPlayer(player)
	local existingCash = 0
	local oldState = playerStates[player]
	if oldState then
		existingCash = oldState.cash
	end

	playerStates[player] = {
		phase = "Loading",
		items = {},
		taken = {},
		weight = 0,
		baseReward = 0,
		balance = 0,
		cash = existingCash,
		lastVelocity = Vector3.zero,
		lastLook = Vector3.new(0, 0, -1),
		wasGrounded = true,
		lastHazardHit = 0,
		visuals = {},
	}

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		resetTrip(player)
	end)

	if player.Character then
		task.defer(function()
			resetTrip(player)
		end)
	end
end

local function connectWorldPrompts()
	local world = Workspace:WaitForChild("OneTripPrototype")
	local itemsFolder = world:WaitForChild("PickupItems")

	for _, itemPart in itemsFolder:GetChildren() do
		local itemId = itemPart:GetAttribute("ItemId")
		local prompt = itemPart:FindFirstChild("InteractionPrompt")
		if itemId and prompt and prompt:IsA("ProximityPrompt") then
			prompt.Triggered:Connect(function(player)
				takeItem(player, itemId)
			end)
		end
	end

	local goPrompt = world:WaitForChild("GoPart"):WaitForChild("InteractionPrompt")
	goPrompt.Triggered:Connect(startTrip)

	local obstacleFolder = world:WaitForChild("Obstacles")
	for _, obstacle in obstacleFolder:GetChildren() do
		if obstacle:IsA("BasePart") and obstacle:GetAttribute("BalanceHazard") then
			obstacle.Touched:Connect(function(hit)
				local character = hit:FindFirstAncestorOfClass("Model")
				local player = character and Players:GetPlayerFromCharacter(character)
				local state = player and playerStates[player]
				if not state or state.phase ~= "Carrying" then
					return
				end

				local now = os.clock()
				if now - state.lastHazardHit < PrototypeConfig.HazardHitCooldown then
					return
				end
				state.lastHazardHit = now

				local spike = PrototypeConfig.HazardBaseSpike + state.weight * PrototypeConfig.HazardSpikePerWeight
				addBalanceSpike(player, spike, ("BUMP! +%d%% balance"):format(math.floor(spike + 0.5)))
			end)
		end
	end

	for _, part in {world:WaitForChild("FrontStep1"), world:WaitForChild("FrontStep2")} do
		part.Touched:Connect(function(hit)
			local character = hit:FindFirstAncestorOfClass("Model")
			local player = character and Players:GetPlayerFromCharacter(character)
			local state = player and playerStates[player]
			if not state or state.phase ~= "Carrying" then
				return
			end

			local now = os.clock()
			if now - state.lastHazardHit < PrototypeConfig.HazardHitCooldown then
				return
			end
			state.lastHazardHit = now

			local spike = 5 + state.weight * 0.75
			addBalanceSpike(player, spike, "Careful on the steps!")
		end)
	end

	local finish = world:WaitForChild("FinishZone")
	finish.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if player then
			completeTrip(player)
		end
	end)
end

local function updateBalance(player, state, dt, elapsed)
	if state.phase ~= "Carrying" then
		return
	end

	local _, humanoid, root = getCharacterPieces(player)
	if not humanoid or not root or humanoid.Health <= 0 then
		return
	end

	local velocity = root.AssemblyLinearVelocity
	local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
	local speed = horizontalVelocity.Magnitude
	local currentLook = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)

	if currentLook.Magnitude > 0 then
		currentLook = currentLook.Unit
	else
		currentLook = state.lastLook
	end

	local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
	if state.wasGrounded and not grounded and velocity.Y > 2 then
		local jumpSpike = PrototypeConfig.JumpBaseSpike + state.weight * PrototypeConfig.JumpSpikePerWeight
		state.balance += jumpSpike
		publish(player, ("JUMP! +%d%% balance"):format(math.floor(jumpSpike + 0.5)))
	end
	state.wasGrounded = grounded

	if speed > PrototypeConfig.MovingSpeedThreshold then
		local excessWeight = math.max(0, state.weight - PrototypeConfig.SafeWeight)
		state.balance += dt * excessWeight * PrototypeConfig.MovementStrainPerExcessWeight

		local heavyExcess = math.max(0, state.weight - PrototypeConfig.HeavyWeightThreshold)
		state.balance += dt * heavyExcess * PrototypeConfig.HeavyMovementStrainPerExcessWeight

		local dot = math.clamp(state.lastLook:Dot(currentLook), -1, 1)
		if dot < PrototypeConfig.SharpTurnDotThreshold then
			local turnSeverity = (1 - dot) / (1 - PrototypeConfig.SharpTurnDotThreshold)
			state.balance += math.min(turnSeverity, 1.8) * state.weight * PrototypeConfig.TurnStrainPerWeight
		end
	else
		state.balance -= PrototypeConfig.RecoveryPerSecond * dt
	end

	state.balance = math.clamp(state.balance, 0, PrototypeConfig.MaxBalance)

	local balanceRatio = state.balance / PrototypeConfig.MaxBalance
	local loadRatio = math.clamp(state.weight / 13, 0, 1)
	for index, visual in state.visuals do
		if visual.weld and visual.weld.Parent then
			local direction = (index % 2 == 0) and 1 or -1
			local wobbleDegrees = 2 + (5 * loadRatio) + (20 * balanceRatio)
			local zAngle = math.sin(elapsed * 8 + index) * math.rad(wobbleDegrees) * direction
			local yAngle = math.sin(elapsed * 5.5 + index * 0.6) * math.rad(wobbleDegrees * 0.35)
			visual.weld.C0 = visual.baseOffset * CFrame.Angles(0, yAngle, zAngle)
		end
	end

	state.lastVelocity = velocity
	state.lastLook = currentLook

	if state.balance >= PrototypeConfig.MaxBalance then
		failTrip(player)
	else
		state.publishAccumulator = (state.publishAccumulator or 0) + dt
		if state.publishAccumulator >= 0.08 then
			state.publishAccumulator = 0
			publish(player)
		end
	end
end

function GameService.Start()
	local remotesFolder = ReplicatedStorage:FindFirstChild("OneTripRemotes")
	if not remotesFolder then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "OneTripRemotes"
		remotesFolder.Parent = ReplicatedStorage
	end

	stateChangedRemote = remotesFolder:FindFirstChild("StateChanged")
	if not stateChangedRemote then
		stateChangedRemote = Instance.new("RemoteEvent")
		stateChangedRemote.Name = "StateChanged"
		stateChangedRemote.Parent = remotesFolder
	end

	connectWorldPrompts()

	Players.PlayerAdded:Connect(setupPlayer)
	Players.PlayerRemoving:Connect(function(player)
		playerStates[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end

	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		for player, state in playerStates do
			if player.Parent then
				updateBalance(player, state, dt, elapsed)
			end
		end
	end)
end

return GameService
