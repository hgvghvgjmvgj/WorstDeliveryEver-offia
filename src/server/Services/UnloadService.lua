--!strict

local Players = game:GetService("Players")

local UnloadService = {}

local lastUnloadAt: {[Player]: number} = {}

local function playerFromHit(hit: BasePart): Player?
	local current: Instance? = hit
	while current and current ~= workspace do
		if current:IsA("Model") then
			local player = Players:GetPlayerFromCharacter(current)
			if player then
				return player
			end
		end
		current = current.Parent
	end
	return nil
end

function UnloadService.Start(worldRoot: Folder, carryService: any)
	local zone = worldRoot:WaitForChild("UnloadZone")
	assert(zone:IsA("BasePart"), "UnloadZone must be a BasePart")

	zone.Touched:Connect(function(hit)
		local player = playerFromHit(hit)
		if not player then
			return
		end

		local now = os.clock()
		local previous = lastUnloadAt[player] or 0
		if now - previous < 0.8 then
			return
		end
		lastUnloadAt[player] = now
		carryService.Unload(player, zone.CFrame)
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastUnloadAt[player] = nil
	end)
end

return UnloadService
