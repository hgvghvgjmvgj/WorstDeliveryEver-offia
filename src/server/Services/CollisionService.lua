--!strict

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local CollisionService = {}

local MAX_RIG = 5
local characterConnections: {[Player]: RBXScriptConnection} = {}
local tierConnections: {[Player]: RBXScriptConnection} = {}

local function playerGroup(tier: number): string
	return ("PlayerRig%d"):format(math.clamp(math.floor(tier + 0.5), 0, MAX_RIG))
end

local function gateGroup(tier: number): string
	return ("GateRig%d"):format(math.clamp(math.floor(tier + 0.5), 1, MAX_RIG))
end

local function register(name: string)
	pcall(function()
		PhysicsService:RegisterCollisionGroup(name)
	end)
end

local function currentTier(player: Player): number
	return math.clamp(math.floor((tonumber(player:GetAttribute("HandlingRigTier")) or 0) + 0.5), 0, MAX_RIG)
end

local function assignCharacter(player: Player, character: Model)
	local group = playerGroup(currentTier(player))
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = group
		end
	end

	if characterConnections[player] then characterConnections[player]:Disconnect() end
	characterConnections[player] = character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = playerGroup(currentTier(player))
		end
	end)
end

function CollisionService.RefreshPlayer(player: Player)
	local character = player.Character
	if character then assignCharacter(player, character) end
end

function CollisionService.SetGatePart(part: BasePart, requiredTier: number)
	local tier = math.clamp(math.floor(requiredTier + 0.5), 1, MAX_RIG)
	part.CollisionGroup = gateGroup(tier)
	part:SetAttribute("GateRequiredRig", tier)
end

function CollisionService.Start()
	for tier = 0, MAX_RIG do register(playerGroup(tier)) end
	for tier = 1, MAX_RIG do register(gateGroup(tier)) end

	-- Every player Rig group remains non-collidable with every other player Rig
	-- group. M6A.3 clearance must never reintroduce body blocking.
	for a = 0, MAX_RIG do
		for b = 0, MAX_RIG do
			PhysicsService:CollisionGroupSetCollidable(playerGroup(a), playerGroup(b), false)
		end
	end

	-- A player passes gates at or below their derived Rig tier and collides with
	-- checkpoints above it. Gate state is therefore per character, not global.
	for playerTier = 0, MAX_RIG do
		for requiredTier = 1, MAX_RIG do
			PhysicsService:CollisionGroupSetCollidable(
				playerGroup(playerTier),
				gateGroup(requiredTier),
				requiredTier > playerTier
			)
		end
	end

	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(function(character)
			assignCharacter(player, character)
		end)
		if tierConnections[player] then tierConnections[player]:Disconnect() end
		tierConnections[player] = player:GetAttributeChangedSignal("HandlingRigTier"):Connect(function()
			CollisionService.RefreshPlayer(player)
		end)
		if player.Character then assignCharacter(player, player.Character) end
	end

	Players.PlayerAdded:Connect(onPlayer)
	Players.PlayerRemoving:Connect(function(player)
		if characterConnections[player] then characterConnections[player]:Disconnect() end
		if tierConnections[player] then tierConnections[player]:Disconnect() end
		characterConnections[player] = nil
		tierConnections[player] = nil
	end)
	for _, player in Players:GetPlayers() do onPlayer(player) end
end

return CollisionService
