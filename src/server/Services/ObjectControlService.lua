local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("GetItInConfig"))
local ObjectConfig = require(ReplicatedStorage:WaitForChild("ObjectConfig"))
local ProgressionConfig = require(ReplicatedStorage:WaitForChild("ProgressionConfig"))

local ObjectControlService = {}

local actionRemote
local stateRemote
local holder = nil
local stateByPlayer = {}
local completed = false
local currentContractIndex = 1
local activeObject = nil
local activeRoot = nil
local activeObjectId = nil
local activePieceLocals = {}
local objectYawDegrees = 0
local objectTilted = false

local function getWorld()
	return Workspace:FindFirstChild("GetItInPrototype")
end

local function getPrototypeSpawn()
	local world = getWorld()
	return world and world:FindFirstChild("PrototypeSpawn")
end

local function getCharacterPieces(player)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end

	return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function placePlayerAtPrototypeSpawn(player)
	local spawn = getPrototypeSpawn()
	if spawn and spawn:IsA("SpawnLocation") then
		player.RespawnLocation = spawn
	end

	local _, _, root = getCharacterPieces(player)
	if root and spawn then
		root.CFrame = spawn.CFrame + Vector3.new(0, 3.5, 0)
	end
end

local function currentContract()
	return ProgressionConfig.GetContract(currentContractIndex)
end

local function currentDefinition()
	local contract = currentContract()
	return contract and ObjectConfig.Get(contract.ObjectId) or nil
end

local function getPlayerCash(player)
	local state = stateByPlayer[player]
	return state and state.cash or 0
end

local function sendState(player, message, overrideHolding)
	if not player or not player.Parent or not stateRemote then
		return
	end

	local isHolding = overrideHolding
	if isHolding == nil then
		isHolding = holder == player
	end

	local state = stateByPlayer[player]
	local cash = state and state.cash or 0
	local definition = currentDefinition()
	local contract = currentContract()
	local nextIndex, nextContract = ProgressionConfig.GetNextLocked(cash)
	local nextDefinition = nextContract and ObjectConfig.Get(nextContract.ObjectId) or nil

	stateRemote:FireClient(player, {
		holding = isHolding,
		message = message,
		tilted = objectTilted,
		objectName = definition and definition.DisplayName or "",
		contractIndex = currentContractIndex,
		contractCount = #ProgressionConfig.Contracts,
		payout = contract and contract.Payout or 0,
		cash = cash,
		unlockedCount = ProgressionConfig.GetUnlockedCount(cash),
		nextUnlockName = nextDefinition and nextDefinition.DisplayName or "",
		nextUnlockCash = nextContract and nextContract.UnlockCash or nil,
		allUnlocked = nextContract == nil,
	})
end

local function broadcastState(message)
	for _, player in Players:GetPlayers() do
		sendState(player, message, holder == player)
	end
end

local function makeBlocker(parent, name, size, cframe)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = true
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(255, 201, 74)
	part:SetAttribute("MoveBlocker", true)
	part.Parent = parent
	return part
end

local function makeMarker(parent, name, center, size)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = CFrame.new(center)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(75, 235, 116)
	part.Transparency = 0.72
	part.Parent = parent
	return part
end

local function addWallWithDoor(parent, z, doorCenterX, doorWidth, doorHeight, totalWidth, wallHeight)
	totalWidth = totalWidth or 86
	wallHeight = wallHeight or 12
	local thickness = 2
	local leftEdge = -totalWidth * 0.5
	local rightEdge = totalWidth * 0.5
	local doorLeft = doorCenterX - doorWidth * 0.5
	local doorRight = doorCenterX + doorWidth * 0.5

	local leftWidth = doorLeft - leftEdge
	if leftWidth > 0.1 then
		makeBlocker(
			parent,
			"WallLeft_" .. tostring(z),
			Vector3.new(leftWidth, wallHeight, thickness),
			CFrame.new(leftEdge + leftWidth * 0.5, wallHeight * 0.5, z)
		)
	end

	local rightWidth = rightEdge - doorRight
	if rightWidth > 0.1 then
		makeBlocker(
			parent,
			"WallRight_" .. tostring(z),
			Vector3.new(rightWidth, wallHeight, thickness),
			CFrame.new(doorRight + rightWidth * 0.5, wallHeight * 0.5, z)
		)
	end

	local headerHeight = wallHeight - doorHeight
	if headerHeight > 0.1 then
		makeBlocker(
			parent,
			"WallHeader_" .. tostring(z),
			Vector3.new(doorWidth, headerHeight, thickness),
			CFrame.new(doorCenterX, doorHeight + headerHeight * 0.5, z)
		)
	end
end

local function buildChallenge(definition)
	local world = getWorld()
	local challengeFolder = world and world:FindFirstChild("ChallengeGeometry")
	local markerFolder = world and world:FindFirstChild("RoundMarkers")
	if not challengeFolder or not markerFolder then
		return
	end

	challengeFolder:ClearAllChildren()
	markerFolder:ClearAllChildren()

	local challenge = definition.Challenge

	if challenge.Kind == "NarrowDoor" then
		addWallWithDoor(
			challengeFolder,
			Config.DoorCenterZ,
			0,
			challenge.DoorWidth,
			challenge.DoorHeight
		)
	elseif challenge.Kind == "LowThenOffset" then
		addWallWithDoor(
			challengeFolder,
			Config.DoorCenterZ,
			0,
			challenge.FirstDoorWidth,
			challenge.FirstDoorHeight
		)
		addWallWithDoor(
			challengeFolder,
			Config.DoorCenterZ + (challenge.SecondDoorOffsetZ or 9),
			challenge.SecondDoorCenterX,
			challenge.SecondDoorWidth,
			challenge.SecondDoorHeight
		)
	elseif challenge.Kind == "OffsetEntry" then
		addWallWithDoor(
			challengeFolder,
			Config.DoorCenterZ,
			challenge.FirstDoorCenterX,
			challenge.DoorWidth,
			challenge.DoorHeight
		)
		addWallWithDoor(
			challengeFolder,
			Config.DoorCenterZ + 9,
			challenge.SecondDoorCenterX,
			challenge.DoorWidth,
			challenge.DoorHeight
		)
	elseif challenge.Kind == "CornerHall" then
		addWallWithDoor(
			challengeFolder,
			Config.DoorCenterZ,
			0,
			challenge.EntryWidth,
			9.5
		)

		local halfHall = challenge.HallWidth * 0.5
		makeBlocker(
			challengeFolder,
			"HallLeft",
			Vector3.new(2, 12, 16),
			CFrame.new(-halfHall - 1, 6, Config.DoorCenterZ + 8)
		)
		makeBlocker(
			challengeFolder,
			"HallRightShort",
			Vector3.new(2, 12, 7),
			CFrame.new(halfHall + 1, 6, Config.DoorCenterZ + 4.5)
		)
		makeBlocker(
			challengeFolder,
			"HallEnd",
			Vector3.new(17, 12, 2),
			CFrame.new(-3.7, 6, Config.DoorCenterZ + 15)
		)
		makeBlocker(
			challengeFolder,
			"OuterRight",
			Vector3.new(2, 12, 26),
			CFrame.new(challenge.ExitClearanceX or 19, 6, Config.DoorCenterZ + 12)
		)
		makeBlocker(
			challengeFolder,
			"CornerCeiling",
			Vector3.new(24, 1.5, 20),
			CFrame.new(6, challenge.CeilingHeight + 0.75, Config.DoorCenterZ + 10)
		)
	end

	makeMarker(
		markerFolder,
		"SuccessZone",
		challenge.SuccessCenter,
		challenge.SuccessSize
	)
end

local function buildOrientationCFrame(position, yawDegrees, tilted, definition)
	local orientation = CFrame.Angles(0, math.rad(yawDegrees), 0)

	if tilted then
		if definition.TiltAxis == "X" then
			orientation *= CFrame.Angles(math.rad(Config.TiltDegrees), 0, 0)
		else
			orientation *= CFrame.Angles(0, 0, math.rad(Config.TiltDegrees))
		end
	end

	return CFrame.new(position) * orientation
end

local function getPartHalfHeight(cframe, size)
	local right = cframe.RightVector
	local up = cframe.UpVector
	local look = cframe.LookVector

	return
		math.abs(right.Y) * size.X * 0.5
		+ math.abs(up.Y) * size.Y * 0.5
		+ math.abs(look.Y) * size.Z * 0.5
end

local function placeModelOnFloor(candidatePivot)
	local minimumY = math.huge

	for _, entry in activePieceLocals do
		local worldCFrame = candidatePivot * entry.LocalCFrame
		local bottom = worldCFrame.Position.Y - getPartHalfHeight(worldCFrame, entry.Part.Size)
		minimumY = math.min(minimumY, bottom)
	end

	if minimumY == math.huge then
		return candidatePivot
	end

	return candidatePivot + Vector3.new(0, Config.FloorTopY + 0.03 - minimumY, 0)
end

local function isBlocked(candidatePivot, character)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {activeObject, character}
	overlapParams.RespectCanCollide = true

	for _, entry in activePieceLocals do
		local worldCFrame = candidatePivot * entry.LocalCFrame
		local parts = Workspace:GetPartBoundsInBox(worldCFrame, entry.Part.Size * 0.96, overlapParams)

		for _, part in parts do
			if part:GetAttribute("MoveBlocker") then
				return true
			end
		end
	end

	return false
end

local function clearNoCollision(state)
	if not state or not state.noCollisionConstraints then
		return
	end

	for _, constraint in state.noCollisionConstraints do
		if constraint and constraint.Parent then
			constraint:Destroy()
		end
	end

	table.clear(state.noCollisionConstraints)
end

local function restoreCharacter(player)
	local _, humanoid = getCharacterPieces(player)
	if humanoid then
		humanoid.WalkSpeed = Config.BaseWalkSpeed
		humanoid.AutoRotate = true
	end
end

local function release(player, message)
	if holder ~= player then
		return
	end

	local state = stateByPlayer[player]
	holder = nil

	if state then
		clearNoCollision(state)
		state.lastRootPosition = nil
	end

	restoreCharacter(player)

	if activeRoot then
		local prompt = activeRoot:FindFirstChild("GrabPrompt")
		if prompt then
			prompt.Enabled = not completed
		end
	end

	sendState(player, message or "Dropped. Walk around it and grab again from another side.", false)
end

local function addHolderNoCollision(character, state)
	state.noCollisionConstraints = {}

	for _, entry in activePieceLocals do
		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") then
				local constraint = Instance.new("NoCollisionConstraint")
				constraint.Name = "HolderNoCollision"
				constraint.Part0 = entry.Part
				constraint.Part1 = descendant
				constraint.Parent = entry.Part
				table.insert(state.noCollisionConstraints, constraint)
			end
		end
	end
end

local function getObjectPosition()
	return activeObject and activeObject:GetPivot().Position or Vector3.zero
end

local function grab(player)
	if completed or holder or not activeObject or not activeRoot then
		return
	end

	local character, humanoid, root = getCharacterPieces(player)
	if not character or not humanoid or not root then
		return
	end

	if (getObjectPosition() - root.Position).Magnitude > Config.PromptGrabLimit then
		return
	end

	holder = player

	local state = stateByPlayer[player]
	if not state then
		state = {
			cash = 0,
		}
		stateByPlayer[player] = state
	end

	state.lastRootPosition = root.Position
	state.lastBlockedMessage = 0

	addHolderNoCollision(character, state)

	humanoid.WalkSpeed = Config.CarryWalkSpeed
	humanoid.AutoRotate = true

	local prompt = activeRoot:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = false
	end

	sendState(player, "Walk normally. Q/E rotate, R tilts, F drops.", true)
end

local function notifyBlocked(player, message)
	local state = stateByPlayer[player]
	if not state then
		return
	end

	local now = os.clock()
	if now - (state.lastBlockedMessage or 0) >= 0.8 then
		state.lastBlockedMessage = now
		sendState(player, message or "Jammed. Back up, rotate, or tilt.")
	end
end

local function tryPlace(player, candidatePivot, blockedMessage)
	local character = player.Character
	if not activeObject or not character then
		return false
	end

	candidatePivot = placeModelOnFloor(candidatePivot)

	if isBlocked(candidatePivot, character) then
		notifyBlocked(player, blockedMessage)
		return false
	end

	activeObject:PivotTo(candidatePivot)
	return true
end

local function rotate(player, direction)
	if holder ~= player or not activeObject then
		return
	end

	local definition = currentDefinition()
	if not definition then
		return
	end

	local candidateYaw = objectYawDegrees + Config.RotateStepDegrees * direction
	local candidate = buildOrientationCFrame(getObjectPosition(), candidateYaw, objectTilted, definition)

	if tryPlace(player, candidate, "Rotation blocked. Give it more room.") then
		objectYawDegrees = candidateYaw
		sendState(player, ("ROTATED %s"):format(direction < 0 and "LEFT" or "RIGHT"))
	end
end

local function toggleTilt(player)
	if holder ~= player or not activeObject then
		return
	end

	local definition = currentDefinition()
	if not definition then
		return
	end

	local candidateTilted = not objectTilted
	local candidate = buildOrientationCFrame(getObjectPosition(), objectYawDegrees, candidateTilted, definition)

	if tryPlace(player, candidate, "Tilt blocked. Give it more room.") then
		objectTilted = candidateTilted
		sendState(player, objectTilted and "TILTED / REORIENTED" or "RETURNED FLAT")
	end
end

local function addObjectBillboard(root, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = "ObjectLabel"
	gui.Size = UDim2.fromOffset(350, 60)
	gui.StudsOffset = Vector3.new(0, 7.5, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 50
	gui.Parent = root

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.16
	label.BackgroundColor3 = Color3.fromRGB(27, 28, 35)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = text
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

local function spawnCurrentObject()
	local world = getWorld()
	local folder = world and world:FindFirstChild("RoundObject")
	if not folder then
		return
	end

	folder:ClearAllChildren()
	activeObject = nil
	activeRoot = nil
	activePieceLocals = {}
	holder = nil

	local contract = currentContract()
	if not contract then
		return
	end

	activeObjectId = contract.ObjectId
	local definition = ObjectConfig.Get(activeObjectId)
	if not definition then
		return
	end

	objectYawDegrees = 0
	objectTilted = false
	buildChallenge(definition)

	local model = Instance.new("Model")
	model.Name = "MoveObject"
	model.Parent = folder

	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(1, 1, 1)
	root.Anchored = true
	root.CanCollide = false
	root.CanTouch = false
	root.CanQuery = false
	root.Transparency = 1
	root.CFrame = CFrame.new(Config.ObjectStartPosition)
	root.Parent = model
	model.PrimaryPart = root

	for index, pieceDefinition in definition.Pieces do
		local part = Instance.new("Part")
		part.Name = "Piece" .. index
		part.Size = pieceDefinition.Size
		part.Anchored = true
		part.CanCollide = true
		part.Material = Enum.Material.SmoothPlastic
		part.Color = pieceDefinition.Color
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.CFrame = root.CFrame * pieceDefinition.Offset
		part.Parent = model

		table.insert(activePieceLocals, {
			Part = part,
			LocalCFrame = pieceDefinition.Offset,
		})
	end

	activeObject = model
	activeRoot = root

	local startPivot = buildOrientationCFrame(Config.ObjectStartPosition, 0, false, definition)
	model:PivotTo(placeModelOnFloor(startPivot))

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GrabPrompt"
	prompt.ActionText = "GRAB"
	prompt.ObjectText = definition.DisplayName
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.G
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Parent = root
	prompt.Triggered:Connect(grab)

	addObjectBillboard(root, definition.ChallengeText)

	for _, state in stateByPlayer do
		state.lastRootPosition = nil
		clearNoCollision(state)
	end

	broadcastState(
		("CONTRACT %d — %s — PAYS $%d"):format(currentContractIndex, definition.DisplayName, contract.Payout)
	)
end

local function allObjectCornersInsideZone()
	local definition = currentDefinition()
	if not definition then
		return false
	end

	local center = definition.Challenge.SuccessCenter
	local size = definition.Challenge.SuccessSize
	local minCorner = center - size * 0.5
	local maxCorner = center + size * 0.5

	for _, entry in activePieceLocals do
		local cf = activeObject:GetPivot() * entry.LocalCFrame
		local half = entry.Part.Size * 0.5

		for sx = -1, 1, 2 do
			for sy = -1, 1, 2 do
				for sz = -1, 1, 2 do
					local corner = cf:PointToWorldSpace(Vector3.new(half.X * sx, half.Y * sy, half.Z * sz))
					if
						corner.X < minCorner.X or corner.X > maxCorner.X
						or corner.Y < minCorner.Y or corner.Y > maxCorner.Y
						or corner.Z < minCorner.Z or corner.Z > maxCorner.Z
					then
						return false
					end
				end
			end
		end
	end

	return true
end

local function advanceRoundFor(player)
	local cash = getPlayerCash(player)
	local unlockedCount = ProgressionConfig.GetUnlockedCount(cash)

	currentContractIndex += 1
	if currentContractIndex > unlockedCount then
		currentContractIndex = 1
	end

	spawnCurrentObject()
end

local function complete()
	if completed or not activeObject then
		return
	end

	completed = true
	local player = holder
	local contract = currentContract()

	if player and contract then
		local state = stateByPlayer[player]
		local oldUnlocked = ProgressionConfig.GetUnlockedCount(state.cash)
		state.cash += contract.Payout
		local newUnlocked = ProgressionConfig.GetUnlockedCount(state.cash)

		release(player, ("DELIVERED! +$%d"):format(contract.Payout))

		local message
		if newUnlocked > oldUnlocked then
			local unlockedContract = ProgressionConfig.GetContract(newUnlocked)
			local unlockedDefinition = unlockedContract and ObjectConfig.Get(unlockedContract.ObjectId)
			message = unlockedDefinition
				and ("NEW CONTRACT UNLOCKED: %s"):format(string.upper(unlockedDefinition.DisplayName))
				or "NEW CONTRACT UNLOCKED!"
		else
			message = ("DELIVERED! +$%d"):format(contract.Payout)
		end

		sendState(player, message, false)

		if activeRoot then
			local prompt = activeRoot:FindFirstChild("GrabPrompt")
			if prompt then
				prompt.Enabled = false
			end
		end

		task.delay(Config.NextObjectDelay, function()
			completed = false
			advanceRoundFor(player)
		end)
	else
		completed = false
	end
end

local function applyMirroredMovement(player, state)
	if not activeObject then
		release(player)
		return
	end

	local _, _, root = getCharacterPieces(player)
	if not root then
		release(player)
		return
	end

	local previousRoot = state.lastRootPosition
	if not previousRoot then
		state.lastRootPosition = root.Position
		return
	end

	local rawDelta = root.Position - previousRoot
	local delta = Vector3.new(rawDelta.X, 0, rawDelta.Z)

	if delta.Magnitude > Config.MaxFrameMove then
		delta = delta.Unit * Config.MaxFrameMove
	end

	if delta.Magnitude > 0.001 then
		local originalPivot = activeObject:GetPivot()
		local fullCandidate = originalPivot + delta

		if not tryPlace(player, fullCandidate, "Jammed — back up, sidestep, rotate, or tilt.") then
			if math.abs(delta.X) > 0.001 then
				tryPlace(player, originalPivot + Vector3.new(delta.X, 0, 0))
			end

			if math.abs(delta.Z) > 0.001 then
				tryPlace(player, activeObject:GetPivot() + Vector3.new(0, 0, delta.Z))
			end
		end
	end

	state.lastRootPosition = root.Position

	if (root.Position - getObjectPosition()).Magnitude > Config.MaxCarryDistance then
		release(player, "You let go. Grab it again from a better side.")
		return
	end

	if allObjectCornersInsideZone() then
		complete()
	end
end

local function setupPlayer(player)
	stateByPlayer[player] = {
		cash = 0,
		lastRootPosition = nil,
		lastBlockedMessage = 0,
		noCollisionConstraints = {},
	}

	local spawn = getPrototypeSpawn()
	if spawn and spawn:IsA("SpawnLocation") then
		player.RespawnLocation = spawn
	end

	player.CharacterAdded:Connect(function()
		task.wait(0.15)
		placePlayerAtPrototypeSpawn(player)

		if holder == player then
			holder = nil
		end

		local state = stateByPlayer[player]
		if state then
			clearNoCollision(state)
			state.lastRootPosition = nil
		end

		local definition = currentDefinition()
		sendState(
			player,
			definition and ("Solve: %s"):format(definition.DisplayName) or "Get the object inside.",
			false
		)
	end)

	if player.Character then
		task.defer(function()
			placePlayerAtPrototypeSpawn(player)
			local definition = currentDefinition()
			sendState(
				player,
				definition and ("Solve: %s"):format(definition.DisplayName) or "Get the object inside.",
				false
			)
		end)
	end
end

function ObjectControlService.Start()
	local remotes = ReplicatedStorage:FindFirstChild("GetItInRemotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "GetItInRemotes"
		remotes.Parent = ReplicatedStorage
	end

	actionRemote = remotes:FindFirstChild("Action")
	if not actionRemote then
		actionRemote = Instance.new("RemoteEvent")
		actionRemote.Name = "Action"
		actionRemote.Parent = remotes
	end

	stateRemote = remotes:FindFirstChild("State")
	if not stateRemote then
		stateRemote = Instance.new("RemoteEvent")
		stateRemote.Name = "State"
		stateRemote.Parent = remotes
	end

	actionRemote.OnServerEvent:Connect(function(player, action)
		if action == "RotateLeft" then
			rotate(player, -1)
		elseif action == "RotateRight" then
			rotate(player, 1)
		elseif action == "Tilt" then
			toggleTilt(player)
		elseif action == "Release" then
			release(player)
		end
	end)

	Players.PlayerAdded:Connect(setupPlayer)
	Players.PlayerRemoving:Connect(function(player)
		if holder == player then
			holder = nil
		end

		local state = stateByPlayer[player]
		if state then
			clearNoCollision(state)
		end
		stateByPlayer[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end

	spawnCurrentObject()

	RunService.Heartbeat:Connect(function()
		local player = holder
		if player and player.Parent then
			local state = stateByPlayer[player]
			if state then
				applyMirroredMovement(player, state)
			end
		end
	end)
end

return ObjectControlService
