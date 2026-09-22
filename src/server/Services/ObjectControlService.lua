local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("GetItInConfig"))
local ObjectConfig = require(ReplicatedStorage:WaitForChild("ObjectConfig"))

local ObjectControlService = {}

local actionRemote
local stateRemote
local holder = nil
local stateByPlayer = {}
local completed = false
local currentObjectIndex = 1
local activeObject = nil
local activeObjectId = nil

local function getWorld()
	return Workspace:FindFirstChild("GetItInPrototype")
end

local function getCharacterPieces(player)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end

	return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function currentDefinition()
	return activeObjectId and ObjectConfig.Get(activeObjectId) or nil
end

local function sendState(player, message, overrideHolding)
	if not player or not player.Parent or not stateRemote then
		return
	end

	local state = stateByPlayer[player]
	local isHolding = overrideHolding
	if isHolding == nil then
		isHolding = holder == player
	end

	local definition = currentDefinition()

	stateRemote:FireClient(player, {
		holding = isHolding,
		message = message,
		tilted = state and state.tilted or false,
		objectName = definition and definition.DisplayName or "",
		roundIndex = currentObjectIndex,
		roundCount = #ObjectConfig.Order,
	})
end

local function broadcastState(message)
	for _, player in Players:GetPlayers() do
		sendState(player, message, false)
	end
end

local function getHalfHeight(cframe, size)
	local right = cframe.RightVector
	local up = cframe.UpVector
	local look = cframe.LookVector

	return
		math.abs(right.Y) * size.X * 0.5
		+ math.abs(up.Y) * size.Y * 0.5
		+ math.abs(look.Y) * size.Z * 0.5
end

local function placeOnFloor(cframe, size)
	local halfHeight = getHalfHeight(cframe, size)
	local position = cframe.Position
	local rotationOnly = cframe - position

	return CFrame.new(position.X, Config.FloorTopY + halfHeight + 0.03, position.Z) * rotationOnly
end

local function isBlocked(candidateCFrame, object, character)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {object, character}
	overlapParams.RespectCanCollide = true

	local parts = Workspace:GetPartBoundsInBox(candidateCFrame, object.Size * 0.965, overlapParams)
	for _, part in parts do
		if part:GetAttribute("MoveBlocker") then
			return true
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

	if activeObject then
		local prompt = activeObject:FindFirstChild("GrabPrompt")
		if prompt then
			prompt.Enabled = not completed
		end
	end

	sendState(player, message or "Dropped. Walk around it and grab again from another side.", false)
end

local function addHolderNoCollision(character, object, state)
	state.noCollisionConstraints = {}

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			local constraint = Instance.new("NoCollisionConstraint")
			constraint.Name = "HolderNoCollision"
			constraint.Part0 = object
			constraint.Part1 = descendant
			constraint.Parent = object
			table.insert(state.noCollisionConstraints, constraint)
		end
	end
end

local function grab(player)
	if completed or holder or not activeObject then
		return
	end

	local character, humanoid, root = getCharacterPieces(player)
	if not character or not humanoid or not root then
		return
	end

	if (activeObject.Position - root.Position).Magnitude > Config.PromptGrabLimit then
		return
	end

	holder = player

	local state = stateByPlayer[player]
	if not state then
		state = {}
		stateByPlayer[player] = state
	end

	state.tilted = false
	state.lastRootPosition = root.Position
	state.lastBlockedMessage = 0

	addHolderNoCollision(character, activeObject, state)

	humanoid.WalkSpeed = Config.CarryWalkSpeed
	humanoid.AutoRotate = true

	local prompt = activeObject:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = false
	end

	sendState(player, "Walk normally. Rotate, tilt, drop, and re-grab whenever you need.", true)
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

local function trySetCFrame(player, candidateCFrame, blockedMessage)
	local object = activeObject
	local character = player.Character
	if not object or not character then
		return false
	end

	candidateCFrame = placeOnFloor(candidateCFrame, object.Size)
	if isBlocked(candidateCFrame, object, character) then
		notifyBlocked(player, blockedMessage)
		return false
	end

	object.CFrame = candidateCFrame
	return true
end

local function rotate(player, direction)
	if holder ~= player or not activeObject then
		return
	end

	local candidate = activeObject.CFrame * CFrame.Angles(0, math.rad(Config.RotateStepDegrees * direction), 0)
	trySetCFrame(player, candidate, "No room to rotate there. Back up first.")
end

local function getTiltRotation(definition, direction)
	local angle = math.rad(Config.TiltDegrees * direction)
	if definition.TiltAxis == "X" then
		return CFrame.Angles(angle, 0, 0)
	end

	return CFrame.Angles(0, 0, angle)
end

local function toggleTilt(player)
	if holder ~= player or not activeObject then
		return
	end

	local state = stateByPlayer[player]
	local definition = currentDefinition()
	if not state or not definition then
		return
	end

	local direction = state.tilted and -1 or 1
	local candidate = activeObject.CFrame * getTiltRotation(definition, direction)

	if trySetCFrame(player, candidate, "No room to tilt here. Back away from the wall.") then
		state.tilted = not state.tilted
		sendState(player, state.tilted and "Reoriented." or "Returned to the starting orientation.")
	end
end

local function addObjectBillboard(object, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = "ObjectLabel"
	gui.Size = UDim2.fromOffset(330, 60)
	gui.StudsOffset = Vector3.new(0, object.Size.Y * 0.5 + 1.8, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 45
	gui.Parent = object

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
	holder = nil

	activeObjectId = ObjectConfig.Order[currentObjectIndex]
	local definition = ObjectConfig.Get(activeObjectId)
	if not definition then
		return
	end

	local object = Instance.new("Part")
	object.Name = "MoveObject"
	object.Size = definition.Size
	object.Anchored = true
	object.CanCollide = true
	object.Material = Enum.Material.SmoothPlastic
	object.Color = definition.Color
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth

	local start = CFrame.new(Config.ObjectStartPosition)
	object.CFrame = placeOnFloor(start, object.Size)
	object.Parent = folder
	activeObject = object

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GrabPrompt"
	prompt.ActionText = "GRAB"
	prompt.ObjectText = definition.DisplayName
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.G
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Parent = object
	prompt.Triggered:Connect(grab)

	addObjectBillboard(object, definition.ChallengeText)

	for _, state in stateByPlayer do
		state.tilted = false
		state.lastRootPosition = nil
		clearNoCollision(state)
	end

	broadcastState(("OBJECT %d/%d — %s"):format(currentObjectIndex, #ObjectConfig.Order, definition.DisplayName))
end

local function advanceRound()
	currentObjectIndex += 1
	if currentObjectIndex > #ObjectConfig.Order then
		currentObjectIndex = 1
		spawnCurrentObject()
		broadcastState("ALL 3 DELIVERED! Looping the prototype set.")
		return
	end

	spawnCurrentObject()
end

local function complete()
	if completed or not activeObject then
		return
	end

	completed = true
	local player = holder

	if player then
		release(player, "DELIVERED!")
		sendState(player, "DELIVERED! Next object incoming...", false)
	end

	local prompt = activeObject:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = false
	end

	task.delay(Config.NextObjectDelay, function()
		completed = false
		advanceRound()
	end)
end

local function applyMirroredMovement(player, state)
	local object = activeObject
	local _, _, root = getCharacterPieces(player)
	if not object or not root then
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
		local originalObject = object.CFrame

		local fullCandidate = originalObject + delta
		if not trySetCFrame(player, fullCandidate, "Jammed — you can move freely. Back up, sidestep, rotate, or tilt.") then
			if math.abs(delta.X) > 0.001 then
				local xDelta = Vector3.new(delta.X, 0, 0)
				trySetCFrame(player, originalObject + xDelta)
			end

			if math.abs(delta.Z) > 0.001 then
				local zDelta = Vector3.new(0, 0, delta.Z)
				trySetCFrame(player, object.CFrame + zDelta)
			end
		end
	end

	state.lastRootPosition = root.Position

	if (root.Position - object.Position).Magnitude > Config.MaxCarryDistance then
		release(player, "You let go. Grab it again from a better side.")
		return
	end

	if object.Position.Z >= Config.SuccessZ then
		complete()
	end
end

local function setupPlayer(player)
	stateByPlayer[player] = {
		tilted = false,
		lastRootPosition = nil,
		lastBlockedMessage = 0,
		noCollisionConstraints = {},
	}

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		if holder == player then
			holder = nil
		end

		local state = stateByPlayer[player]
		if state then
			clearNoCollision(state)
			state.lastRootPosition = nil
		end

		local definition = currentDefinition()
		local message = definition
			and ("Get the %s through the doorway."):format(definition.DisplayName)
			or "Get the object through the doorway."
		sendState(player, message, false)
	end)

	if player.Character then
		task.defer(function()
			local definition = currentDefinition()
			local message = definition
				and ("Get the %s through the doorway."):format(definition.DisplayName)
				or "Get the object through the doorway."
			sendState(player, message, false)
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
