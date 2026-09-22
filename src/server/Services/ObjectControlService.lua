local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("GetItInConfig"))

local ObjectControlService = {}

local actionRemote
local stateRemote
local holder = nil
local stateByPlayer = {}
local completed = false

local function getWorld()
	return Workspace:FindFirstChild("GetItInPrototype")
end

local function getCouch()
	local world = getWorld()
	return world and world:FindFirstChild("Couch")
end

local function getCharacterPieces(player)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end

	return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function sendState(player, message, overrideHolding)
	if not player or not player.Parent then
		return
	end

	local state = stateByPlayer[player]
	local isHolding = overrideHolding
	if isHolding == nil then
		isHolding = holder == player
	end

	stateRemote:FireClient(player, {
		holding = isHolding,
		message = message,
		tilted = state and state.tilted or false,
	})
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

local function isBlocked(candidateCFrame, couch, character)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {couch, character}
	overlapParams.RespectCanCollide = true

	local parts = Workspace:GetPartBoundsInBox(candidateCFrame, couch.Size * 0.965, overlapParams)
	for _, part in parts do
		if part:GetAttribute("MoveBlocker") then
			return true
		end
	end

	return false
end

local function resetCouch()
	local couch = getCouch()
	if not couch then
		return
	end

	couch.CFrame = Config.CouchStartCFrame

	local prompt = couch:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = true
	end
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

	local couch = getCouch()
	if couch then
		local prompt = couch:FindFirstChild("GrabPrompt")
		if prompt then
			prompt.Enabled = true
		end
	end

	sendState(player, message or "Dropped. Walk around it and grab again from another side.", false)
end

local function addHolderNoCollision(character, couch, state)
	state.noCollisionConstraints = {}

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			local constraint = Instance.new("NoCollisionConstraint")
			constraint.Name = "HolderNoCollision"
			constraint.Part0 = couch
			constraint.Part1 = descendant
			constraint.Parent = couch
			table.insert(state.noCollisionConstraints, constraint)
		end
	end
end

local function grab(player)
	if completed or holder then
		return
	end

	local couch = getCouch()
	local character, humanoid, root = getCharacterPieces(player)
	if not couch or not character or not humanoid or not root then
		return
	end

	if (couch.Position - root.Position).Magnitude > Config.PromptGrabLimit then
		return
	end

	holder = player

	local state = stateByPlayer[player]
	if not state then
		state = {}
		stateByPlayer[player] = state
	end

	state.tilted = math.abs(couch.CFrame.RightVector.Y) > 0.5
	state.lastRootPosition = root.Position
	state.lastBlockedMessage = 0

	addHolderNoCollision(character, couch, state)

	humanoid.WalkSpeed = Config.CarryWalkSpeed
	humanoid.AutoRotate = true

	local prompt = couch:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = false
	end

	sendState(player, "Walk normally. The couch moves with you; rotate or tilt only when you need to.", true)
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
	local couch = getCouch()
	local character = player.Character
	if not couch or not character then
		return false
	end

	candidateCFrame = placeOnFloor(candidateCFrame, couch.Size)
	if isBlocked(candidateCFrame, couch, character) then
		notifyBlocked(player, blockedMessage)
		return false
	end

	couch.CFrame = candidateCFrame
	return true
end

local function rotate(player, direction)
	if holder ~= player then
		return
	end

	local couch = getCouch()
	if not couch then
		return
	end

	local candidate = couch.CFrame * CFrame.Angles(0, math.rad(Config.RotateStepDegrees * direction), 0)
	trySetCFrame(player, candidate, "No room to rotate there. Back up first.")
end

local function toggleTilt(player)
	if holder ~= player then
		return
	end

	local couch = getCouch()
	local state = stateByPlayer[player]
	if not couch or not state then
		return
	end

	local candidate
	if state.tilted then
		candidate = couch.CFrame * CFrame.Angles(0, 0, math.rad(-Config.TiltDegrees))
	else
		candidate = couch.CFrame * CFrame.Angles(0, 0, math.rad(Config.TiltDegrees))
	end

	if trySetCFrame(player, candidate, "No room to tilt here. Back away from the wall.") then
		state.tilted = not state.tilted
		sendState(player, state.tilted and "Couch stood upright." or "Couch laid back down.")
	end
end

local function complete()
	if completed then
		return
	end

	completed = true
	local player = holder

	if player then
		release(player, "IT FIT! That is the Prototype Zero win.")
		sendState(player, "IT FIT! The couch will reset in a moment.", false)
	end

	task.delay(Config.ResetDelay, function()
		resetCouch()
		completed = false
	end)
end

local function applyMirroredMovement(player, state)
	local couch = getCouch()
	local _, _, root = getCharacterPieces(player)
	if not couch or not root then
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
		local originalCouch = couch.CFrame
		local originalRootCFrame = root.CFrame
		local actualDelta = Vector3.zero

		local fullCandidate = originalCouch + delta
		if trySetCFrame(player, fullCandidate, "Jammed. Back up, rotate, or tilt.") then
			actualDelta = delta
		else
			if math.abs(delta.X) > 0.001 then
				local xDelta = Vector3.new(delta.X, 0, 0)
				if trySetCFrame(player, originalCouch + xDelta) then
					actualDelta += xDelta
				end
			end

			if math.abs(delta.Z) > 0.001 then
				local zDelta = Vector3.new(0, 0, delta.Z)
				local zStart = couch.CFrame
				if trySetCFrame(player, zStart + zDelta) then
					actualDelta += zDelta
				end
			end
		end

		local blockedDelta = delta - actualDelta
		if blockedDelta.Magnitude > 0.001 then
			root.CFrame = originalRootCFrame - blockedDelta
		end
	end

	state.lastRootPosition = root.Position

	if (root.Position - couch.Position).Magnitude > Config.MaxCarryDistance then
		release(player, "You let go. Grab it again from a better side.")
		return
	end

	if couch.Position.Z >= Config.SuccessZ then
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
		sendState(player, "Grab the couch. Figure out how to get it through the doorway.", false)
	end)

	if player.Character then
		task.defer(function()
			sendState(player, "Grab the couch. Figure out how to get it through the doorway.", false)
		end)
	end
end

function ObjectControlService.Start()
	local world = getWorld()
	local couch = world:WaitForChild("Couch")
	local prompt = couch:WaitForChild("GrabPrompt")

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

	prompt.Triggered:Connect(grab)

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
