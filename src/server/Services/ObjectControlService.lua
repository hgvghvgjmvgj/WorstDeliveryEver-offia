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

	local parts = Workspace:GetPartBoundsInBox(candidateCFrame, couch.Size * 0.97, overlapParams)
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

local function restoreCharacter(player)
	local _, humanoid, root = getCharacterPieces(player)
	if humanoid then
		humanoid.WalkSpeed = Config.BaseWalkSpeed
		humanoid.AutoRotate = true
	end
	if root then
		root.Anchored = false
	end
end

local function release(player, message)
	if holder ~= player then
		return
	end

	holder = nil
	local state = stateByPlayer[player]
	if state then
		state.moveVector = Vector3.zero
	end

	restoreCharacter(player)

	local couch = getCouch()
	if couch then
		local prompt = couch:FindFirstChild("GrabPrompt")
		if prompt then
			prompt.Enabled = true
		end
	end

	sendState(player, message or "Dropped. Walk around it and grab again if you need a new angle.", false)
end

local function grab(player)
	if completed or holder then
		return
	end

	local couch = getCouch()
	local _, humanoid, root = getCharacterPieces(player)
	if not couch or not humanoid or not root then
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

	state.moveVector = Vector3.zero
	state.tilted = math.abs(couch.CFrame.RightVector.Y) > 0.5

	humanoid.WalkSpeed = 0
	humanoid.AutoRotate = false
	root.Anchored = true

	local prompt = couch:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = false
	end

	sendState(player, "You control the couch now. Move it, rotate it, tilt it, or drop it.", true)
end

local function trySetCFrame(player, candidateCFrame, blockedMessage)
	local couch = getCouch()
	local character = player.Character
	if not couch or not character then
		return false
	end

	candidateCFrame = placeOnFloor(candidateCFrame, couch.Size)
	if isBlocked(candidateCFrame, couch, character) then
		local state = stateByPlayer[player]
		local now = os.clock()
		if state and now - (state.lastBlockedMessage or 0) > 0.8 then
			state.lastBlockedMessage = now
			sendState(player, blockedMessage or "Blocked. Try a different angle.")
		end
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
	trySetCFrame(player, candidate, "No room to rotate that way here.")
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

	if trySetCFrame(player, candidate, "Not enough room to tilt here.") then
		state.tilted = not state.tilted
		sendState(player, state.tilted and "Tilted upright." or "Set flat again.")
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

local function updateHolderVisual(player, couch)
	local _, _, root = getCharacterPieces(player)
	if not root then
		return
	end

	local forward = Vector3.new(couch.CFrame.LookVector.X, 0, couch.CFrame.LookVector.Z)
	if forward.Magnitude < 0.01 then
		forward = Vector3.new(0, 0, -1)
	else
		forward = forward.Unit
	end

	local halfDepth = couch.Size.Z * 0.5
	local holderPosition = couch.Position - forward * (halfDepth + Config.HolderGap)
	holderPosition = Vector3.new(holderPosition.X, 3.0, holderPosition.Z)

	root.CFrame = CFrame.lookAt(holderPosition, Vector3.new(couch.Position.X, holderPosition.Y, couch.Position.Z))
end

local function moveObject(player, state, dt)
	local couch = getCouch()
	if not couch then
		return
	end

	local move = state.moveVector or Vector3.zero
	move = Vector3.new(move.X, 0, move.Z)
	if move.Magnitude > 1 then
		move = move.Unit
	end

	if move.Magnitude > 0.02 then
		local delta = move * Config.ObjectMoveSpeed * dt
		local original = couch.CFrame
		local fullCandidate = original + delta

		if not trySetCFrame(player, fullCandidate, "Jammed. Rotate, tilt, or back it out.") then
			local moved = false

			if math.abs(delta.X) > 0.0001 then
				moved = trySetCFrame(player, original + Vector3.new(delta.X, 0, 0))
			end

			if math.abs(delta.Z) > 0.0001 then
				local base = couch.CFrame
				moved = trySetCFrame(player, base + Vector3.new(0, 0, delta.Z)) or moved
			end

			if not moved then
				state.moveVector = Vector3.zero
			end
		end
	end

	updateHolderVisual(player, couch)

	if couch.Position.Z >= Config.SuccessZ then
		complete()
	end
end

local function setupPlayer(player)
	stateByPlayer[player] = {
		moveVector = Vector3.zero,
		tilted = false,
		lastBlockedMessage = 0,
	}

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		if holder == player then
			holder = nil
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

	actionRemote.OnServerEvent:Connect(function(player, action, value)
		local state = stateByPlayer[player]
		if not state then
			return
		end

		if action == "Move" then
			if holder ~= player or typeof(value) ~= "Vector3" then
				return
			end

			local horizontal = Vector3.new(value.X, 0, value.Z)
			if horizontal.Magnitude > 1.15 then
				horizontal = horizontal.Unit
			end
			state.moveVector = horizontal
		elseif action == "RotateLeft" then
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
		stateByPlayer[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end

	RunService.Heartbeat:Connect(function(dt)
		local player = holder
		if not player or not player.Parent then
			return
		end

		local state = stateByPlayer[player]
		if state then
			moveObject(player, state, dt)
		end
	end)
end

return ObjectControlService
