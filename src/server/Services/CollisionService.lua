--!strict

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local CollisionService = {}

local PLAYER_GROUP = "OneTripPlayers"

local function assignCharacter(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = PLAYER_GROUP
		end
	end

	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = PLAYER_GROUP
		end
	end)
end

function CollisionService.Start()
	pcall(function()
		PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
	end)
	PhysicsService:CollisionGroupSetCollidable(PLAYER_GROUP, PLAYER_GROUP, false)

	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(assignCharacter)
		if player.Character then
			assignCharacter(player.Character)
		end
	end

	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return CollisionService
