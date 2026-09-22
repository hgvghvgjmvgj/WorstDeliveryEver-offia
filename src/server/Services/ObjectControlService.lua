local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("GetItInConfig"))
local ObjectConfig = require(ReplicatedStorage:WaitForChild("ObjectConfig"))
local ProgressionConfig = require(ReplicatedStorage:WaitForChild("ProgressionConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local JobPlotService = require(script.Parent:WaitForChild("JobPlotService"))

local ObjectControlService = {}

local actionRemote
local stateRemote

local playerState = {}
local jobsByPlayer = {}

local function currentContract(job)
	return ProgressionConfig.GetContract(job.currentContractIndex)
end

local function currentDefinition(job)
	local contract = currentContract(job)
	return contract and ObjectConfig.Get(contract.ObjectId) or nil
end

local function getCharacterPieces(player)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end

	return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerCash(player)
	local state = playerState[player]
	return state and state.cash or 0
end

local function savePlayerProgress(player)
	local state = playerState[player]
	if not state or not state.dataLoaded or not state.canSave then
		return false
	end

	local success = PlayerDataService.SaveCash(player, state.cash)
	if success then
		state.dirty = false
	end

	return success
end

local function sendState(player, job, message, overrideHolding)
	if not player or not player.Parent or not stateRemote then
		return
	end

	local state = playerState[player]
	local cash = state and state.cash or 0
	local definition = job and currentDefinition(job) or nil
	local contract = job and currentContract(job) or nil
	local _, nextContract = ProgressionConfig.GetNextLocked(cash)
	local nextDefinition = nextContract and ObjectConfig.Get(nextContract.ObjectId) or nil

	local isHolding = false
	if job then
		isHolding = overrideHolding
		if isHolding == nil then
			isHolding = job.holder == player
		end
	end

	stateRemote:FireClient(player, {
		holding = isHolding == true,
		message = message,
		tilted = job and job.objectTilted or false,
		objectName = definition and definition.DisplayName or "",
		contractIndex = job and job.currentContractIndex or 0,
		contractCount = #ProgressionConfig.Contracts,
		payout = contract and contract.Payout or 0,
		cash = cash,
		unlockedCount = ProgressionConfig.GetUnlockedCount(cash),
		nextUnlockName = nextDefinition and nextDefinition.DisplayName or "",
		nextUnlockCash = nextContract and nextContract.UnlockCash or nil,
		allUnlocked = nextContract == nil,
		plotIndex = job and job.plot:GetAttribute("PlotIndex") or nil,
	})
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

local function placePlayerAtPlot(player, plot)
	local spawn = JobPlotService.GetPlayerSpawn(plot)
	local _, _, root = getCharacterPieces(player)
	if root and spawn then
		root.CFrame = spawn.CFrame + Vector3.new(0, 3.5, 0)
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
	part.Color = Color3.fromRGB(255, 225, 172)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("MoveBlocker", true)
	part.Parent = parent
	return part
end

local function makeDecoration(parent, name, size, cframe, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.Parent = parent
	return part
end

local function makeMarker(parent, originCFrame, center, size)
	local part = Instance.new("Part")
	part.Name = "SuccessZone"
	part.Size = Vector3.new(size.X, 0.12, size.Z)
	part.CFrame = originCFrame * CFrame.new(center.X, Config.FloorTopY + 0.08, center.Z)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(92, 231, 132)
	part.Transparency = 0.48
	part.Parent = parent
	return part
end

local function addWallWithDoor(job, parent, z, doorCenterX, doorWidth, doorHeight, totalWidth, wallHeight)
	totalWidth = totalWidth or 86
	wallHeight = wallHeight or 12
	local thickness = 2
	local leftEdge = -totalWidth * 0.5
	local rightEdge = totalWidth * 0.5
	local doorLeft = doorCenterX - doorWidth * 0.5
	local doorRight = doorCenterX + doorWidth * 0.5
	local origin = job.origin.CFrame

	local leftWidth = doorLeft - leftEdge
	if leftWidth > 0.1 then
		makeBlocker(
			parent,
			"WallLeft_" .. tostring(z),
			Vector3.new(leftWidth, wallHeight, thickness),
			origin * CFrame.new(leftEdge + leftWidth * 0.5, wallHeight * 0.5, z)
		)
	end

	local rightWidth = rightEdge - doorRight
	if rightWidth > 0.1 then
		makeBlocker(
			parent,
			"WallRight_" .. tostring(z),
			Vector3.new(rightWidth, wallHeight, thickness),
			origin * CFrame.new(doorRight + rightWidth * 0.5, wallHeight * 0.5, z)
		)
	end

	local headerHeight = wallHeight - doorHeight
	if headerHeight > 0.1 then
		makeBlocker(
			parent,
			"WallHeader_" .. tostring(z),
			Vector3.new(doorWidth, headerHeight, thickness),
			origin * CFrame.new(doorCenterX, doorHeight + headerHeight * 0.5, z)
		)
	end

	local trimColor = Color3.fromRGB(72, 177, 196)
	local trimDepth = 0.38
	local frontZ = z - thickness * 0.5 - trimDepth * 0.5
	makeDecoration(parent, "DoorTrimLeft_" .. tostring(z), Vector3.new(0.42, doorHeight + 0.3, trimDepth), origin * CFrame.new(doorLeft - 0.21, doorHeight * 0.5, frontZ), trimColor)
	makeDecoration(parent, "DoorTrimRight_" .. tostring(z), Vector3.new(0.42, doorHeight + 0.3, trimDepth), origin * CFrame.new(doorRight + 0.21, doorHeight * 0.5, frontZ), trimColor)
	makeDecoration(parent, "DoorTrimTop_" .. tostring(z), Vector3.new(doorWidth + 0.84, 0.42, trimDepth), origin * CFrame.new(doorCenterX, doorHeight + 0.21, frontZ), trimColor)
end

local function buildChallenge(job, definition)
	local challengeFolder = job.plot:FindFirstChild("ChallengeGeometry")
	local markerFolder = job.plot:FindFirstChild("RoundMarkers")
	if not challengeFolder or not markerFolder then
		return
	end

	challengeFolder:ClearAllChildren()
	markerFolder:ClearAllChildren()

	local challenge = definition.Challenge

	if challenge.Kind == "NarrowDoor" then
		addWallWithDoor(job, challengeFolder, Config.DoorCenterZ, 0, challenge.DoorWidth, challenge.DoorHeight)
	elseif challenge.Kind == "LowThenOffset" then
		addWallWithDoor(job, challengeFolder, Config.DoorCenterZ, 0, challenge.FirstDoorWidth, challenge.FirstDoorHeight)
		addWallWithDoor(job, challengeFolder, Config.DoorCenterZ + (challenge.SecondDoorOffsetZ or 9), challenge.SecondDoorCenterX, challenge.SecondDoorWidth, challenge.SecondDoorHeight)
	elseif challenge.Kind == "OffsetEntry" then
		addWallWithDoor(job, challengeFolder, Config.DoorCenterZ, challenge.FirstDoorCenterX, challenge.DoorWidth, challenge.DoorHeight)
		addWallWithDoor(job, challengeFolder, Config.DoorCenterZ + 9, challenge.SecondDoorCenterX, challenge.DoorWidth, challenge.DoorHeight)
	elseif challenge.Kind == "CornerHall" then
		addWallWithDoor(job, challengeFolder, Config.DoorCenterZ, 0, challenge.EntryWidth, 9.5)

		local origin = job.origin.CFrame
		local halfHall = challenge.HallWidth * 0.5
		makeBlocker(challengeFolder, "HallLeft", Vector3.new(2, 12, 16), origin * CFrame.new(-halfHall - 1, 6, Config.DoorCenterZ + 8))
		makeBlocker(challengeFolder, "HallRightShort", Vector3.new(2, 12, 7), origin * CFrame.new(halfHall + 1, 6, Config.DoorCenterZ + 4.5))
		makeBlocker(challengeFolder, "HallEnd", Vector3.new(17, 12, 2), origin * CFrame.new(-3.7, 6, Config.DoorCenterZ + 15))
		makeBlocker(challengeFolder, "OuterRight", Vector3.new(2, 12, 26), origin * CFrame.new(challenge.ExitClearanceX or 19, 6, Config.DoorCenterZ + 12))
		makeBlocker(challengeFolder, "CornerCeiling", Vector3.new(24, 1.5, 20), origin * CFrame.new(6, challenge.CeilingHeight + 0.75, Config.DoorCenterZ + 10))
	end

	makeMarker(markerFolder, job.origin.CFrame, challenge.SuccessCenter, challenge.SuccessSize)
end

local function buildOrientationCFrame(job, worldPosition, yawDegrees, tilted, definition)
	local localPosition = job.origin.CFrame:PointToObjectSpace(worldPosition)
	local orientation = CFrame.Angles(0, math.rad(yawDegrees), 0)

	if tilted then
		if definition.TiltAxis == "X" then
			orientation *= CFrame.Angles(math.rad(Config.TiltDegrees), 0, 0)
		else
			orientation *= CFrame.Angles(0, 0, math.rad(Config.TiltDegrees))
		end
	end

	return job.origin.CFrame * CFrame.new(localPosition) * orientation
end

local function getPartHalfHeight(cframe, size)
	local right = cframe.RightVector
	local up = cframe.UpVector
	local look = cframe.LookVector
	return math.abs(right.Y) * size.X * 0.5
		+ math.abs(up.Y) * size.Y * 0.5
		+ math.abs(look.Y) * size.Z * 0.5
end

local function placeModelOnFloor(job, candidatePivot)
	local minimumY = math.huge

	for _, entry in job.activePieceLocals do
		local worldCFrame = candidatePivot * entry.LocalCFrame
		local bottom = worldCFrame.Position.Y - getPartHalfHeight(worldCFrame, entry.Part.Size)
		minimumY = math.min(minimumY, bottom)
	end

	if minimumY == math.huge then
		return candidatePivot
	end

	return candidatePivot + Vector3.new(0, Config.FloorTopY + 0.03 - minimumY, 0)
end

local function isBlocked(job, candidatePivot, character)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {job.activeObject, character}
	overlapParams.RespectCanCollide = true

	for _, entry in job.activePieceLocals do
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

local function addHolderNoCollision(job, character, state)
	state.noCollisionConstraints = {}

	for _, entry in job.activePieceLocals do
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

local function getObjectPosition(job)
	return job.activeObject and job.activeObject:GetPivot().Position or Vector3.zero
end

local function release(job, player, message)
	if job.holder ~= player then
		return
	end

	local state = playerState[player]
	job.holder = nil

	if state then
		clearNoCollision(state)
		state.lastRootPosition = nil
	end

	restoreCharacter(player)

	if job.activeRoot then
		local prompt = job.activeRoot:FindFirstChild("GrabPrompt")
		if prompt then
			prompt.Enabled = not job.completed
		end
	end

	sendState(player, job, message or "Dropped. Reposition and grab it again.", false)
end

local function notifyBlocked(job, player, message)
	local state = playerState[player]
	if not state then
		return
	end

	local now = os.clock()
	if now - (state.lastBlockedMessage or 0) >= 0.8 then
		state.lastBlockedMessage = now
		sendState(player, job, message or "Jammed. Back up, rotate, or tilt.")
	end
end

local function tryPlace(job, player, candidatePivot, blockedMessage)
	local character = player.Character
	if not job.activeObject or not character then
		return false
	end

	candidatePivot = placeModelOnFloor(job, candidatePivot)

	if isBlocked(job, candidatePivot, character) then
		notifyBlocked(job, player, blockedMessage)
		return false
	end

	job.activeObject:PivotTo(candidatePivot)
	return true
end

local function rotate(job, player, direction)
	if job.holder ~= player or not job.activeObject then
		return
	end

	local definition = currentDefinition(job)
	if not definition then
		return
	end

	local candidateYaw = job.objectYawDegrees + Config.RotateStepDegrees * direction
	local candidate = buildOrientationCFrame(job, getObjectPosition(job), candidateYaw, job.objectTilted, definition)

	if tryPlace(job, player, candidate, "Rotation blocked. Give it more room.") then
		job.objectYawDegrees = candidateYaw
		sendState(player, job, direction < 0 and "ROTATED LEFT" or "ROTATED RIGHT")
	end
end

local function toggleTilt(job, player)
	if job.holder ~= player or not job.activeObject then
		return
	end

	local definition = currentDefinition(job)
	if not definition then
		return
	end

	local candidateTilted = not job.objectTilted
	local candidate = buildOrientationCFrame(job, getObjectPosition(job), job.objectYawDegrees, candidateTilted, definition)

	if tryPlace(job, player, candidate, "Tilt blocked. Give it more room.") then
		job.objectTilted = candidateTilted
		sendState(player, job, job.objectTilted and "TILTED / REORIENTED" or "RETURNED FLAT")
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

local function spawnCurrentObject(job)
	local folder = job.plot:FindFirstChild("RoundObject")
	if not folder then
		return
	end

	folder:ClearAllChildren()
	job.activeObject = nil
	job.activeRoot = nil
	job.activePieceLocals = {}
	job.holder = nil

	local contract = currentContract(job)
	if not contract then
		return
	end

	local definition = ObjectConfig.Get(contract.ObjectId)
	if not definition then
		return
	end

	job.objectYawDegrees = 0
	job.objectTilted = false
	buildChallenge(job, definition)

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
	root.Parent = model
	model.PrimaryPart = root

	for index, pieceDefinition in definition.Pieces do
		local part = Instance.new("Part")
		part.Name = "Piece" .. index
		part.Size = pieceDefinition.Size
		part.Anchored = true
		local hasCollision = pieceDefinition.Collision ~= false
		part.CanCollide = hasCollision
		part.CanTouch = hasCollision
		part.CanQuery = hasCollision
		part.Material = pieceDefinition.Material or Enum.Material.SmoothPlastic
		part.Color = pieceDefinition.Color
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model

		if hasCollision then
			table.insert(job.activePieceLocals, {
				Part = part,
				LocalCFrame = pieceDefinition.Offset,
			})
		end
	end

	job.activeObject = model
	job.activeRoot = root

	local startWorld = job.origin.CFrame:PointToWorldSpace(Config.ObjectStartPosition)
	local startPivot = buildOrientationCFrame(job, startWorld, 0, false, definition)

	root.CFrame = startPivot
	for _, pieceDefinition in definition.Pieces do
		-- Individual piece CFrames are corrected by the PivotTo below.
	end

	model:PivotTo(placeModelOnFloor(job, startPivot))

	-- PivotTo uses the root pivot, but the parts still need their configured local offsets
	-- on first spawn because they were created at the origin.
	for index, pieceDefinition in definition.Pieces do
		local part = model:FindFirstChild("Piece" .. index)
		if part then
			part.CFrame = model:GetPivot() * pieceDefinition.Offset
		end
	end

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
	prompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer ~= job.owner or job.completed or job.holder then
			return
		end

		local state = playerState[triggeringPlayer]
		local character, humanoid, playerRoot = getCharacterPieces(triggeringPlayer)
		if not state or not state.dataLoaded or not character or not humanoid or not playerRoot then
			return
		end

		if (getObjectPosition(job) - playerRoot.Position).Magnitude > Config.PromptGrabLimit then
			return
		end

		job.holder = triggeringPlayer
		state.lastRootPosition = playerRoot.Position
		state.lastBlockedMessage = 0
		addHolderNoCollision(job, character, state)

		humanoid.WalkSpeed = Config.CarryWalkSpeed
		humanoid.AutoRotate = true
		prompt.Enabled = false

		sendState(triggeringPlayer, job, "YOUR JOB • Q/E rotate • R tilt • F drop", true)
	end)

	addObjectBillboard(root, definition.ChallengeText)
	sendState(job.owner, job, ("JOB SITE %d • %s • PAYS $%d"):format(job.plot:GetAttribute("PlotIndex") or 0, definition.DisplayName, contract.Payout), false)
end

local function allObjectCornersInsideZone(job)
	local definition = currentDefinition(job)
	if not definition or not job.activeObject then
		return false
	end

	local center = definition.Challenge.SuccessCenter
	local size = definition.Challenge.SuccessSize
	local minCorner = center - size * 0.5
	local maxCorner = center + size * 0.5

	for _, entry in job.activePieceLocals do
		local cf = job.activeObject:GetPivot() * entry.LocalCFrame
		local half = entry.Part.Size * 0.5

		for sx = -1, 1, 2 do
			for sy = -1, 1, 2 do
				for sz = -1, 1, 2 do
					local worldCorner = cf:PointToWorldSpace(Vector3.new(half.X * sx, half.Y * sy, half.Z * sz))
					local corner = job.origin.CFrame:PointToObjectSpace(worldCorner)

					if corner.X < minCorner.X or corner.X > maxCorner.X
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

local function advanceRound(job)
	local cash = getPlayerCash(job.owner)
	local unlockedCount = ProgressionConfig.GetUnlockedCount(cash)

	job.currentContractIndex += 1
	if job.currentContractIndex > unlockedCount then
		job.currentContractIndex = 1
	end

	spawnCurrentObject(job)
end

local function complete(job)
	if job.completed or not job.activeObject then
		return
	end

	local player = job.holder
	local contract = currentContract(job)
	if not player or player ~= job.owner or not contract then
		return
	end

	job.completed = true

	local state = playerState[player]
	local oldUnlocked = ProgressionConfig.GetUnlockedCount(state.cash)
	state.cash += contract.Payout
	state.dirty = true
	local newUnlocked = ProgressionConfig.GetUnlockedCount(state.cash)

	task.spawn(function()
		savePlayerProgress(player)
	end)

	release(job, player, ("DELIVERED! +$%d"):format(contract.Payout))

	local message = ("DELIVERED! +$%d"):format(contract.Payout)
	if newUnlocked > oldUnlocked then
		local unlockedContract = ProgressionConfig.GetContract(newUnlocked)
		local unlockedDefinition = unlockedContract and ObjectConfig.Get(unlockedContract.ObjectId)
		if unlockedDefinition then
			message = "NEW CONTRACT UNLOCKED: " .. string.upper(unlockedDefinition.DisplayName)
		end
	end

	sendState(player, job, message, false)

	if job.activeRoot then
		local prompt = job.activeRoot:FindFirstChild("GrabPrompt")
		if prompt then
			prompt.Enabled = false
		end
	end

	task.delay(Config.NextObjectDelay, function()
		if jobsByPlayer[player] ~= job then
			return
		end
		job.completed = false
		advanceRound(job)
	end)
end

local function applyMirroredMovement(job, player, state)
	if not job.activeObject then
		release(job, player)
		return
	end

	local _, _, root = getCharacterPieces(player)
	if not root then
		release(job, player)
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
		local originalPivot = job.activeObject:GetPivot()
		local fullCandidate = originalPivot + delta

		if not tryPlace(job, player, fullCandidate, "Jammed — back up, sidestep, rotate, or tilt.") then
			if math.abs(delta.X) > 0.001 then
				tryPlace(job, player, originalPivot + Vector3.new(delta.X, 0, 0))
			end

			if math.abs(delta.Z) > 0.001 then
				tryPlace(job, player, job.activeObject:GetPivot() + Vector3.new(0, 0, delta.Z))
			end
		end
	end

	state.lastRootPosition = root.Position

	if (root.Position - getObjectPosition(job)).Magnitude > Config.MaxCarryDistance then
		release(job, player, "You let go. Grab it again from a better side.")
		return
	end

	if allObjectCornersInsideZone(job) then
		complete(job)
	end
end

local function createJobForPlayer(player, plot)
	local origin = JobPlotService.GetOrigin(plot)
	if not origin then
		return nil
	end

	local job = {
		owner = player,
		plot = plot,
		origin = origin,
		currentContractIndex = 1,
		activeObject = nil,
		activeRoot = nil,
		activePieceLocals = {},
		objectYawDegrees = 0,
		objectTilted = false,
		holder = nil,
		completed = false,
	}

	jobsByPlayer[player] = job
	spawnCurrentObject(job)
	return job
end

local function setupPlayer(player)
	playerState[player] = {
		cash = 0,
		dataLoaded = false,
		canSave = false,
		dirty = false,
		lastRootPosition = nil,
		lastBlockedMessage = 0,
		noCollisionConstraints = {},
	}

	local success, savedCash = PlayerDataService.LoadCash(player)
	local state = playerState[player]
	if not state or not player.Parent then
		return
	end

	state.cash = savedCash
	state.dataLoaded = true
	state.canSave = success

	local plot = JobPlotService.Claim(player)
	if not plot then
		sendState(player, nil, "All 4 prototype job sites are busy. Stay at HQ until one opens.", false)
		return
	end

	local job = createJobForPlayer(player, plot)

	local function onCharacter(character)
		task.wait(0.15)
		if job and jobsByPlayer[player] == job then
			placePlayerAtPlot(player, plot)
			sendState(player, job, ("ASSIGNED JOB SITE %d"):format(plot:GetAttribute("PlotIndex") or 0), false)
		end
	end

	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		task.defer(onCharacter, player.Character)
	end

	if not success then
		sendState(player, job, "Saving unavailable this session; existing saved data will not be overwritten.", false)
	end
end

function ObjectControlService.Start()
	JobPlotService.Initialize()

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
		local job = jobsByPlayer[player]
		if not job then
			return
		end

		if action == "RotateLeft" then
			rotate(job, player, -1)
		elseif action == "RotateRight" then
			rotate(job, player, 1)
		elseif action == "Tilt" then
			toggleTilt(job, player)
		elseif action == "Release" then
			release(job, player)
		end
	end)

	Players.PlayerAdded:Connect(setupPlayer)
	Players.PlayerRemoving:Connect(function(player)
		local job = jobsByPlayer[player]
		if job and job.holder == player then
			release(job, player)
		end

		local state = playerState[player]
		if state then
			clearNoCollision(state)
			if state.dirty then
				savePlayerProgress(player)
			end
		end

		jobsByPlayer[player] = nil
		JobPlotService.Release(player)
		playerState[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(setupPlayer, player)
	end

	task.spawn(function()
		while true do
			task.wait(PlayerDataService.AutosaveInterval)
			for _, player in Players:GetPlayers() do
				local state = playerState[player]
				if state and state.dirty then
					task.spawn(function()
						savePlayerProgress(player)
					end)
				end
			end
		end
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			local state = playerState[player]
			if state and state.dirty then
				savePlayerProgress(player)
			end
		end
	end)

	RunService.Heartbeat:Connect(function()
		for player, job in jobsByPlayer do
			if job.holder == player and player.Parent then
				local state = playerState[player]
				if state then
					applyMirroredMovement(job, player, state)
				end
			end
		end
	end)
end

return ObjectControlService
