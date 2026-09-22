local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("GetItInConfig"))

local CarryService = {}

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

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	return character, humanoid, root
end

local function flatYawFromCFrame(cframe)
	local look = cframe.LookVector
	return math.atan2(-look.X, -look.Z)
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
		yawDegrees = state and math.deg(state.yawOffset or 0) or 0,
		tilted = state and state.roll ~= 0 or false,
	})
end

local function resetCouch()
	local couch = getCouch()
	if not couch then
		return
	end

	couch.Anchored = true
	couch.AssemblyLinearVelocity = Vector3.zero
	couch.AssemblyAngularVelocity = Vector3.zero
	couch.CFrame = Config.CouchStartCFrame
	couch.Anchored = false

	local prompt = couch:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = true
	end

	pcall(function()
		couch:SetNetworkOwner(nil)
	end)
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

local function cleanupConstraints(state)
	if not state then
		return
	end

	clearNoCollision(state)

	for _, instance in {
		state.alignPosition,
		state.alignOrientation,
		state.couchAttachment,
		state.targetPart,
	} do
		if instance and instance.Parent then
			instance:Destroy()
		end
	end

	state.alignPosition = nil
	state.alignOrientation = nil
	state.couchAttachment = nil
	state.targetPart = nil
	state.targetAttachment = nil
end

local function release(player, message)
	if holder ~= player then
		return
	end

	local state = stateByPlayer[player]
	local couch = getCouch()

	holder = nil
	cleanupConstraints(state)

	local _, humanoid = getCharacterPieces(player)
	if humanoid then
		humanoid.WalkSpeed = Config.BaseWalkSpeed
	end

	if couch then
		couch.AssemblyLinearVelocity *= 0.35
		couch.AssemblyAngularVelocity *= 0.35

		local prompt = couch:FindFirstChild("GrabPrompt")
		if prompt then
			prompt.Enabled = true
		end

		pcall(function()
			couch:SetNetworkOwner(nil)
		end)
	end

	sendState(player, message or "Dropped. Reposition and grab it again.", false)
end

local function makeTargetPart()
	local part = Instance.new("Part")
	part.Name = "CarryTarget"
	part.Size = Vector3.new(0.4, 0.4, 0.4)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Parent = getWorld()

	local attachment = Instance.new("Attachment")
	attachment.Name = "TargetAttachment"
	attachment.Parent = part

	return part, attachment
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

	local rootYaw = flatYawFromCFrame(root.CFrame)
	local couchYaw = flatYawFromCFrame(couch.CFrame)
	state.yawOffset = couchYaw - rootYaw
	state.roll = 0

	local couchAttachment = Instance.new("Attachment")
	couchAttachment.Name = "CarryAttachment"
	couchAttachment.Parent = couch

	local targetPart, targetAttachment = makeTargetPart()

	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Name = "CarryPosition"
	alignPosition.Attachment0 = couchAttachment
	alignPosition.Attachment1 = targetAttachment
	alignPosition.MaxForce = Config.MaxMoveForce
	alignPosition.MaxVelocity = Config.MaxMoveVelocity
	alignPosition.Responsiveness = Config.PositionResponsiveness
	alignPosition.RigidityEnabled = false
	alignPosition.ReactionForceEnabled = false
	alignPosition.ApplyAtCenterOfMass = true
	alignPosition.Parent = couch

	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "CarryOrientation"
	alignOrientation.Attachment0 = couchAttachment
	alignOrientation.Attachment1 = targetAttachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.TwoAttachment
	alignOrientation.MaxTorque = Config.MaxTurnTorque
	alignOrientation.MaxAngularVelocity = Config.MaxAngularVelocity
	alignOrientation.Responsiveness = Config.OrientationResponsiveness
	alignOrientation.RigidityEnabled = false
	alignOrientation.ReactionTorqueEnabled = false
	alignOrientation.Parent = couch

	state.couchAttachment = couchAttachment
	state.targetPart = targetPart
	state.targetAttachment = targetAttachment
	state.alignPosition = alignPosition
	state.alignOrientation = alignOrientation

	addHolderNoCollision(character, couch, state)

	humanoid.WalkSpeed = Config.CarryWalkSpeed

	local prompt = couch:FindFirstChild("GrabPrompt")
	if prompt then
		prompt.Enabled = false
	end

	pcall(function()
		couch:SetNetworkOwner(player)
	end)

	sendState(player, "Move normally. If it jams, rotate, tilt, drop, or reposition.", true)
end

local function rotate(player, direction)
	if holder ~= player then
		return
	end

	local state = stateByPlayer[player]
	if not state then
		return
	end

	state.yawOffset += math.rad(Config.RotateStepDegrees * direction)
	sendState(player)
end

local function toggleTilt(player)
	if holder ~= player then
		return
	end

	local state = stateByPlayer[player]
	if not state then
		return
	end

	if math.abs(state.roll) < 0.01 then
		state.roll = math.rad(Config.TiltDegrees)
	else
		state.roll = 0
	end

	sendState(player)
end

local function complete()
	if completed then
		return
	end

	completed = true
	local player = holder

	if player then
		release(player, "IT FIT! Prototype Zero passed this run.")
		sendState(player, "IT FIT! Try another approach if you want.", false)
	end

	task.delay(Config.ResetDelay, function()
		resetCouch()
		completed = false
	end)
end

local function setupPlayer(player)
	stateByPlayer[player] = {
		yawOffset = 0,
		roll = 0,
		noCollisionConstraints = {},
	}

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		if holder == player then
			release(player)
		end
		sendState(player, "Grab the couch. Figure out how to get it through the doorway.", false)
	end)

	if player.Character then
		task.defer(function()
			sendState(player, "Grab the couch. Figure out how to get it through the doorway.", false)
		end)
	end
end

function CarryService.Start()
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
			release(player)
		end
		stateByPlayer[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end

	RunService.Heartbeat:Connect(function()
		local player = holder
		if not player then
			return
		end

		local state = stateByPlayer[player]
		local currentCouch = getCouch()
		local _, _, root = getCharacterPieces(player)
		if not state or not currentCouch or not root or not state.targetPart then
			release(player)
			return
		end

		local separation = (currentCouch.Position - root.Position).Magnitude
		if separation > Config.AutoReleaseDistance then
			release(player, "It got stuck behind you. Reposition and grab it again.")
			return
		end

		local rootYaw = flatYawFromCFrame(root.CFrame)
		local targetPosition =
			root.Position
			+ root.CFrame.LookVector * Config.GrabDistance
			+ Vector3.new(0, Config.CarryHeightOffset, 0)

		state.targetPart.CFrame =
			CFrame.new(targetPosition)
			* CFrame.Angles(0, rootYaw + state.yawOffset, 0)
			* CFrame.Angles(0, 0, state.roll)

		if currentCouch.Position.Z >= Config.SuccessZ then
			complete()
		end
	end)
end

return CarryService
