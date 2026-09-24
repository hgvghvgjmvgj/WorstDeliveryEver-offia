--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}
local player = Players.LocalPlayer

local tripActive = false
local reviewSeen = false
local tripStartedAt = 0
local sessionStartedAt = 0
local firstSellRecorded = false
local previousItemCount = 0
local peakItemCount = 0
local peakSellPotential = 0
local cashAtStart = 0
local passiveRateAtStart = 0

local function resetTrip()
	tripActive = false
	reviewSeen = false
	tripStartedAt = 0
	peakItemCount = 0
	peakSellPotential = 0
	cashAtStart = 0
	passiveRateAtStart = 0
end

local function beginTrip(snapshot: any)
	tripActive = true
	reviewSeen = false
	tripStartedAt = os.clock()
	peakItemCount = tonumber(snapshot.itemCount) or 0
	peakSellPotential = tonumber(snapshot.runValue) or 0
	cashAtStart = tonumber(player:GetAttribute("Cash")) or 0
	passiveRateAtStart = tonumber(player:GetAttribute("DevCurrentPassiveRate")) or 0
end

local function finishTrip()
	if not tripActive or not reviewSeen then
		return
	end

	local elapsed = math.max(0.1, os.clock() - tripStartedAt)
	local potentialPerMinute = peakSellPotential * 60 / elapsed
	local cashAfter = tonumber(player:GetAttribute("Cash")) or cashAtStart
	local rawCashDelta = cashAfter - cashAtStart
	local estimatedPassiveDuringTrip = (passiveRateAtStart / 60) * elapsed
	local adjustedCashDelta = math.max(0, rawCashDelta - estimatedPassiveDuringTrip)
	local adjustedCashPerMinute = adjustedCashDelta * 60 / elapsed
	local passiveToActiveRatio = if adjustedCashPerMinute > 0 then passiveRateAtStart / adjustedCashPerMinute else 0

	player:SetAttribute("DevLastTripSeconds", elapsed)
	player:SetAttribute("DevLastTripItems", peakItemCount)
	player:SetAttribute("DevLastTripSellPotential", peakSellPotential)
	player:SetAttribute("DevLastTripPotentialCashPerMinute", potentialPerMinute)
	player:SetAttribute("DevLastTripCashDelta", rawCashDelta)
	player:SetAttribute("DevLastTripAdjustedCashPerMinute", adjustedCashPerMinute)
	player:SetAttribute("DevLastTripPassiveToActiveRatio", passiveToActiveRatio)

	if adjustedCashDelta > 0 and not firstSellRecorded then
		firstSellRecorded = true
		player:SetAttribute("DevFirstSellSeconds", math.max(0, os.clock() - sessionStartedAt))
	end

	print(string.format(
		"[ONE TRIP][M6A.3 ECON] %d items | %s SELL potential | %.1fs | %s/min potential | cash delta %s | adjusted active ~%s/min | passive/active %.1f%%",
		peakItemCount,
		NumberFormat.Cash(peakSellPotential),
		elapsed,
		NumberFormat.Cash(potentialPerMinute),
		NumberFormat.Cash(rawCashDelta),
		NumberFormat.Cash(adjustedCashPerMinute),
		passiveToActiveRatio * 100
	))

	resetTrip()
end

function Controller.Start()
	sessionStartedAt = os.clock()
	firstSellRecorded = false
	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local carryState = remoteFolder:WaitForChild(RemoteNames.CarryState) :: RemoteEvent
	local economyState = remoteFolder:WaitForChild(RemoteNames.EconomyState) :: RemoteEvent

	carryState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) ~= "table" then
			return
		end

		local itemCount = tonumber(snapshot.itemCount) or 0
		if itemCount > 0 and previousItemCount == 0 then
			-- A zero-load state with no Delivery Review means the previous attempt was
			-- abandoned/ditched rather than sold. Start a fresh measurement here.
			if not tripActive or not reviewSeen then
				beginTrip(snapshot)
			end
		end

		if tripActive and itemCount > 0 then
			peakItemCount = math.max(peakItemCount, itemCount)
			peakSellPotential = math.max(peakSellPotential, tonumber(snapshot.runValue) or 0)
		end
		previousItemCount = itemCount
	end)

	economyState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) ~= "table" then
			return
		end
		player:SetAttribute("DevCurrentPassiveRate", tonumber(snapshot.totalPassiveRate) or 0)

		local reviewId = snapshot.reviewId
		local hasReview = typeof(reviewId) == "string" and reviewId ~= ""
		if tripActive and hasReview then
			reviewSeen = true
		elseif tripActive and reviewSeen and not hasReview then
			-- For the active-income benchmark, resolve the Delivery Review with SELL ALL.
			-- KEEP/partial-SELL paths are legitimate gameplay but are not a pure active
			-- cash-per-minute sample, so compare the SELL-potential metric in that case.
			finishTrip()
		end
	end)
end

return Controller
