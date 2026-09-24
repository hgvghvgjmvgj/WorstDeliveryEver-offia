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

local function connectZone(zone: BasePart, carryService: any, economyService: any, collectionService: any)
	zone.Touched:Connect(function(hit)
		local player = playerFromHit(hit)
		if not player then
			return
		end

		local bayIndex = player:GetAttribute("BayIndex")
		local zoneBayIndex = zone:GetAttribute("BayIndex")

		if typeof(bayIndex) ~= "number"
			or typeof(zoneBayIndex) ~= "number"
			or bayIndex ~= zoneBayIndex
		then
			return
		end

		local now = os.clock()
		local previous = lastUnloadAt[player] or 0
		if now - previous < 0.8 then
			return
		end

		if not economyService.CanAcceptDelivery(player) then
			return
		end

		-- This is the same server-owned delivery list consumed by Economy. M5C
		-- never trusts client-provided discovery IDs and never grants on pickup,
		-- preview, collapse, ditch, or disconnect.
		local deliveredItems = economyService.CaptureCarriedItems(player)
		if #deliveredItems == 0 then
			return
		end

		lastUnloadAt[player] = now
		local unloadResult = carryService.Unload(player, zone.CFrame)
		if typeof(unloadResult) ~= "number" or unloadResult <= 0 then
			return
		end

		-- M6A.3 economy telemetry. A successful delivery is counted before the
		-- SELL/KEEP decision because both are legitimate completed hauls.
		local haulCount = math.max(0, math.floor(tonumber(player:GetAttribute("DevSuccessfulHauls")) or 0)) + 1
		player:SetAttribute("DevSuccessfulHauls", haulCount)
		player:SetAttribute("DevLastDeliveryItems", #deliveredItems)
		player:SetAttribute("DevLastDeliverySellPotential", unloadResult)

		-- Delivery itself is the accomplishment. Collection credit happens before
		-- the SELL/KEEP decision, so both review outcomes count exactly once.
		collectionService.RecordDelivery(player, deliveredItems)
		economyService.BeginDelivery(player, deliveredItems)
	end)
end

function UnloadService.Start(worldRoot: Folder, carryService: any, economyService: any, collectionService: any)
	local bays = worldRoot:WaitForChild("Bays")

	for _, bay in bays:GetChildren() do
		if bay:IsA("Model") then
			local zone = bay:FindFirstChild("UnloadZone")
			if zone and zone:IsA("BasePart") then
				connectZone(zone, carryService, economyService, collectionService)
			end
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		lastUnloadAt[player] = nil
	end)
end

return UnloadService
