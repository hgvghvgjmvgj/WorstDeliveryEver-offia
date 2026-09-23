--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("DataConfig"))
local EconomyConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("EconomyConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local ProgressionConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ProgressionConfig"))

local PlayerDataService = {}

local MAX_SAFE_CASH = 9_000_000_000_000_000
local store = DataStoreService:GetDataStore(DataConfig.DataStoreName)
local profiles: {[Player]: any} = {}
local offlineAwards: {[Player]: number} = {}
local temporaryProfiles: {[Player]: boolean} = {}
local dirty: {[Player]: boolean} = {}
local saving: {[Player]: boolean} = {}
local saveAgain: {[Player]: boolean} = {}
local saveScheduled: {[Player]: boolean} = {}
local loadedCallbacks: {(Player, any) -> ()} = {}
local beforeSaveCallbacks: {(Player, any) -> ()} = {}
local started = false
local shuttingDown = false

local function finiteNumber(value: any, fallback: number): number
	if typeof(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return fallback
	end
	return value
end

local function deepCopy(value: any): any
	if typeof(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value do
		copy[deepCopy(key)] = deepCopy(child)
	end
	return copy
end

local function currentEconomy(itemId: string): (number, number, number)
	local tuning = EconomyConfig.Items[itemId]
	if not tuning then
		return 0, 0, 0
	end
	local passive = math.max(0, finiteNumber(tuning.PassivePerMinute, 0))
	local sell = math.max(0, math.floor(passive * finiteNumber(tuning.TargetBreakEvenMinutes, 0) + 0.5))
	local ratio = EconomyConfig.DefaultSalvageRatio
	if typeof(tuning.SalvageRatio) == "number" then
		ratio = tuning.SalvageRatio
	end
	local salvage = math.max(0, math.floor(sell * math.clamp(ratio, 0, 1) + 0.5))
	return passive, sell, salvage
end

local function defaultProfile(nowUnix: number): any
	return {
		SchemaVersion = DataConfig.SchemaVersion,
		Cash = EconomyConfig.StartingCash,
		Progression = {
			StrengthLevel = 1,
			CarrySpaceLevel = 1,
			ControlLevel = 1,
			MobilityLevel = 1,
			StockSlotLevel = 1,
			CarryRigTier = ProgressionConfig.DefaultCarryRigTier,
		},
		Stock = { Slots = {} },
		PassiveRemainder = 0,
		LastSeenUnix = nowUnix,
		Session = nil,
	}
end

local function sanitizeLevel(value: any, trackName: string): number
	local track = ProgressionConfig.Tracks[trackName]
	return math.clamp(math.floor(finiteNumber(value, 1) + 0.5), 1, #track.Levels)
end

local function sanitizeStock(rawStock: any, nowUnix: number): any
	local result = { Slots = {} }
	local sourceSlots = if typeof(rawStock) == "table" and typeof(rawStock.Slots) == "table" then rawStock.Slots else {}
	for slotIndex = 1, EconomyConfig.MaxStockSlots do
		local key = tostring(slotIndex)
		local raw = sourceSlots[key]
		if raw == nil then raw = sourceSlots[slotIndex] end
		if typeof(raw) == "table" and typeof(raw.ItemId) == "string" and ItemConfig[raw.ItemId] then
			local passive, sell, salvage = currentEconomy(raw.ItemId)
			local savedPassive = math.clamp(finiteNumber(raw.PassiveRatePerMinute, passive), 0, MAX_SAFE_CASH)
			local savedSell = math.clamp(finiteNumber(raw.OriginalSellValue, sell), 0, MAX_SAFE_CASH)
			local savedSalvage = math.clamp(finiteNumber(raw.SalvageValue, salvage), 0, savedSell)
			result.Slots[key] = {
				StockId = if typeof(raw.StockId) == "string" and raw.StockId ~= "" then raw.StockId else "",
				ItemId = raw.ItemId,
				SlotIndex = slotIndex,
				StockedAtUnix = math.max(0, math.floor(finiteNumber(raw.StockedAtUnix, nowUnix))),
				PassiveRatePerMinute = savedPassive,
				OriginalSellValue = savedSell,
				SalvageValue = savedSalvage,
			}
		end
	end
	return result
end

local function migrateAndSanitize(raw: any, nowUnix: number): (any?, string?)
	if typeof(raw) ~= "table" then
		return defaultProfile(nowUnix), nil
	end
	local rawVersion = math.floor(finiteNumber(raw.SchemaVersion, 0))
	if rawVersion > DataConfig.SchemaVersion then
		return nil, "NEWER_SCHEMA"
	end
	local result = defaultProfile(nowUnix)
	result.Cash = math.clamp(math.floor(finiteNumber(raw.Cash, result.Cash)), 0, MAX_SAFE_CASH)
	local sourceProgression = if typeof(raw.Progression) == "table" then raw.Progression else raw
	result.Progression.StrengthLevel = sanitizeLevel(sourceProgression.StrengthLevel, "Strength")
	result.Progression.CarrySpaceLevel = sanitizeLevel(sourceProgression.CarrySpaceLevel, "CarrySpace")
	result.Progression.ControlLevel = sanitizeLevel(sourceProgression.ControlLevel, "Control")
	result.Progression.MobilityLevel = sanitizeLevel(sourceProgression.MobilityLevel, "Mobility")
	result.Progression.StockSlotLevel = sanitizeLevel(sourceProgression.StockSlotLevel, "StockSlots")
	result.Progression.CarryRigTier = math.max(1, math.floor(finiteNumber(sourceProgression.CarryRigTier, ProgressionConfig.DefaultCarryRigTier) + 0.5))
	result.Stock = sanitizeStock(raw.Stock, nowUnix)
	result.PassiveRemainder = math.clamp(finiteNumber(raw.PassiveRemainder, 0), 0, 0.999999)
	result.LastSeenUnix = math.max(0, math.floor(finiteNumber(raw.LastSeenUnix, nowUnix)))
	result.SchemaVersion = DataConfig.SchemaVersion
	return result, nil
end

local function totalSavedPassive(profile: any): number
	local total = 0
	local slots = profile.Stock and profile.Stock.Slots
	if typeof(slots) ~= "table" then return 0 end
	for _, entry in slots do
		if typeof(entry) == "table" then
			total += math.max(0, finiteNumber(entry.PassiveRatePerMinute, 0))
		end
	end
	return total
end

local function keyFor(player: Player): string
	return DataConfig.KeyPrefix .. tostring(player.UserId)
end

local function retryDelay(attempt: number): number
	return DataConfig.RetryBaseSeconds * (2 ^ math.max(0, attempt - 1))
end

local function fireLoaded(player: Player, profile: any)
	for _, callback in loadedCallbacks do
		task.spawn(function()
			local ok, err = pcall(callback, player, profile)
			if not ok then warn("[ONE TRIP] profile loaded callback failed:", err) end
		end)
	end
end

local function setProfileAttributes(player: Player, profile: any, status: string, offline: number)
	player:SetAttribute(DataConfig.ProfileLoadedAttribute, true)
	player:SetAttribute(DataConfig.PersistenceStatusAttribute, status)
	player:SetAttribute(DataConfig.SchemaVersionAttribute, profile.SchemaVersion)
	player:SetAttribute(DataConfig.OfflineEarningsAttribute, offline)
	player:SetAttribute("Cash", profile.Cash)
end

local function loadTemporary(player: Player, reason: string)
	local nowUnix = os.time()
	local profile = defaultProfile(nowUnix)
	profiles[player] = profile
	temporaryProfiles[player] = true
	dirty[player] = false
	offlineAwards[player] = 0
	setProfileAttributes(player, profile, "TEMPORARY_STUDIO:" .. reason, 0)
	fireLoaded(player, profile)
end

local function loadPlayer(player: Player)
	if profiles[player] or not player.Parent then return end
	player:SetAttribute(DataConfig.ProfileLoadedAttribute, false)
	player:SetAttribute(DataConfig.PersistenceStatusAttribute, "LOADING")

	local blockedBySession = false
	local unsupportedSchema = false
	local loadedProfile: any = nil
	local awardedOffline = 0
	local lastError = "unknown"

	for attempt = 1, DataConfig.MaxAttempts do
		blockedBySession = false
		unsupportedSchema = false
		local nowUnix = os.time()
		local ok, result = pcall(function()
			return store:UpdateAsync(keyFor(player), function(raw)
				local profile, migrationError = migrateAndSanitize(raw, nowUnix)
				if not profile then
					unsupportedSchema = migrationError == "NEWER_SCHEMA"
					return nil
				end
				local session = if typeof(raw) == "table" then raw.Session else nil
				if typeof(session) == "table" and typeof(session.JobId) == "string" and session.JobId ~= "" and session.JobId ~= game.JobId then
					local updatedAt = math.max(0, math.floor(finiteNumber(session.UpdatedAt, 0)))
					if nowUnix - updatedAt < DataConfig.SessionLockTimeoutSeconds then
						blockedBySession = true
						return nil
					end
				end

				local lastSeen = profile.LastSeenUnix
				local rawElapsed = nowUnix - lastSeen
				local elapsed = 0
				if lastSeen > 0 and rawElapsed > 0 and rawElapsed <= DataConfig.MaximumTrustedElapsedSeconds then
					elapsed = math.min(rawElapsed, DataConfig.OfflineEarningsCapSeconds)
				end
				local exactOffline = (totalSavedPassive(profile) / 60) * elapsed + profile.PassiveRemainder
				local offlineWhole = math.max(0, math.floor(exactOffline + 0.000001))
				profile.PassiveRemainder = exactOffline - offlineWhole
				profile.Cash = math.clamp(profile.Cash + offlineWhole, 0, MAX_SAFE_CASH)
				profile.LastSeenUnix = nowUnix
				profile.Session = { JobId = game.JobId, PlaceId = game.PlaceId, UpdatedAt = nowUnix }
				profile.SchemaVersion = DataConfig.SchemaVersion
				awardedOffline = offlineWhole
				return profile
			end)
		end)
		if ok and result ~= nil and not blockedBySession and not unsupportedSchema then
			loadedProfile = result
			break
		end
		lastError = if ok then (if blockedBySession then "SESSION_LOCKED" elseif unsupportedSchema then "NEWER_SCHEMA" else "UPDATE_CANCELLED") else tostring(result)
		if blockedBySession or unsupportedSchema then break end
		if attempt < DataConfig.MaxAttempts then task.wait(retryDelay(attempt)) end
	end

	if not loadedProfile then
		if RunService:IsStudio() and DataConfig.FailOpenInStudio then
			warn("[ONE TRIP] DataStore unavailable; using temporary Studio profile:", lastError)
			loadTemporary(player, lastError)
			return
		end
		player:Kick(if blockedBySession
			then "Your ONE TRIP data is still active in another server. Please try again shortly."
			elseif unsupportedSchema
			then "Your ONE TRIP data was created by a newer game version. Please rejoin an updated server."
			else "Your ONE TRIP data could not be loaded safely. Please rejoin.")
		return
	end

	if not player.Parent then return end
	profiles[player] = loadedProfile
	temporaryProfiles[player] = nil
	dirty[player] = false
	offlineAwards[player] = awardedOffline
	setProfileAttributes(player, loadedProfile, "PERSISTENT", awardedOffline)
	fireLoaded(player, loadedProfile)
end

local function runBeforeSave(player: Player, profile: any)
	for _, callback in beforeSaveCallbacks do
		local ok, err = pcall(callback, player, profile)
		if not ok then warn("[ONE TRIP] before-save callback failed:", err) end
	end
end

local function savePlayerInternal(player: Player, releaseSession: boolean): boolean
	local profile = profiles[player]
	if not profile or temporaryProfiles[player] then return true end

	if saving[player] then
		if not releaseSession then
			saveAgain[player] = true
			return false
		end
		-- Final save/release must not be dropped just because an autosave is in flight.
		local waitStarted = os.clock()
		while saving[player] and os.clock() - waitStarted < 10 do
			task.wait(0.05)
		end
		if saving[player] then
			warn("[ONE TRIP] timed out waiting for in-flight save before release", player.UserId)
			return false
		end
		profile = profiles[player]
		if not profile then return true end
	end

	saving[player] = true
	runBeforeSave(player, profile)
	local nowUnix = os.time()
	profile.LastSeenUnix = nowUnix
	profile.SchemaVersion = DataConfig.SchemaVersion
	local payload = deepCopy(profile)
	payload.Session = if releaseSession then nil else { JobId = game.JobId, PlaceId = game.PlaceId, UpdatedAt = nowUnix }

	local succeeded = false
	for attempt = 1, DataConfig.MaxAttempts do
		local lostOwnership = false
		local ok, err = pcall(function()
			store:UpdateAsync(keyFor(player), function(current)
				if typeof(current) == "table" and typeof(current.Session) == "table" then
					local owner = current.Session.JobId
					if typeof(owner) == "string" and owner ~= "" and owner ~= game.JobId then
						lostOwnership = true
						return nil
					end
				end
				return payload
			end)
		end)
		if ok and not lostOwnership then
			succeeded = true
			break
		end
		if lostOwnership then
			warn("[ONE TRIP] refused to save profile after losing session ownership", player.UserId)
			break
		end
		warn(("[ONE TRIP] save attempt %d failed for %d: %s"):format(attempt, player.UserId, tostring(err)))
		if attempt < DataConfig.MaxAttempts then task.wait(retryDelay(attempt)) end
	end

	if succeeded then
		dirty[player] = false
		profile.Session = payload.Session
	end
	saving[player] = nil

	if saveAgain[player] and player.Parent and not releaseSession then
		saveAgain[player] = nil
		task.defer(function() savePlayerInternal(player, false) end)
	else
		saveAgain[player] = nil
	end
	return succeeded
end

function PlayerDataService.GetProfile(player: Player): any?
	return profiles[player]
end

function PlayerDataService.IsLoaded(player: Player): boolean
	return profiles[player] ~= nil
end

function PlayerDataService.GetOfflineAward(player: Player): number
	return offlineAwards[player] or 0
end

function PlayerDataService.MarkDirty(player: Player)
	if profiles[player] then dirty[player] = true end
end

function PlayerDataService.RequestSave(player: Player)
	if not profiles[player] or temporaryProfiles[player] or saveScheduled[player] then return end
	saveScheduled[player] = true
	task.delay(DataConfig.SaveDebounceSeconds, function()
		saveScheduled[player] = nil
		if profiles[player] and player.Parent and dirty[player] then
			savePlayerInternal(player, false)
		end
	end)
end

function PlayerDataService.SaveNow(player: Player): boolean
	return savePlayerInternal(player, false)
end

function PlayerDataService.GetCash(player: Player): number
	local profile = profiles[player]
	return if profile then profile.Cash else 0
end

function PlayerDataService.AddCash(player: Player, amount: number): number
	local profile = profiles[player]
	if not profile then return 0 end
	local clean = math.max(0, math.floor(finiteNumber(amount, 0) + 0.000001))
	if clean <= 0 then return profile.Cash end
	profile.Cash = math.clamp(profile.Cash + clean, 0, MAX_SAFE_CASH)
	player:SetAttribute("Cash", profile.Cash)
	dirty[player] = true
	return profile.Cash
end

function PlayerDataService.TrySpendCash(player: Player, amount: number): boolean
	local profile = profiles[player]
	if not profile then return false end
	local clean = math.max(0, math.floor(finiteNumber(amount, 0) + 0.5))
	if clean <= 0 or profile.Cash < clean then return false end
	profile.Cash -= clean
	player:SetAttribute("Cash", profile.Cash)
	dirty[player] = true
	return true
end

function PlayerDataService.OnLoaded(callback: (Player, any) -> ())
	table.insert(loadedCallbacks, callback)
	for player, profile in profiles do task.spawn(callback, player, profile) end
end

function PlayerDataService.RegisterBeforeSave(callback: (Player, any) -> ())
	table.insert(beforeSaveCallbacks, callback)
end

function PlayerDataService.Start()
	if started then return end
	started = true

	Players.PlayerAdded:Connect(function(player) task.spawn(loadPlayer, player) end)

	Players.PlayerRemoving:Connect(function(player)
		saveScheduled[player] = nil
		if profiles[player] then
			local released = savePlayerInternal(player, true)
			if not released then
				warn("[ONE TRIP] final save/session release failed for", player.UserId)
			end
		end
		profiles[player] = nil
		offlineAwards[player] = nil
		temporaryProfiles[player] = nil
		dirty[player] = nil
		saving[player] = nil
		saveAgain[player] = nil
	end)

	for _, player in Players:GetPlayers() do task.spawn(loadPlayer, player) end

	task.spawn(function()
		while not shuttingDown do
			task.wait(DataConfig.AutosaveSeconds)
			if shuttingDown then break end
			for player in profiles do
				if player.Parent then task.spawn(savePlayerInternal, player, false) end
			end
		end
	end)

	game:BindToClose(function()
		shuttingDown = true
		local pending = 0
		for player in profiles do
			pending += 1
			task.spawn(function()
				savePlayerInternal(player, true)
				pending -= 1
			end)
		end
		local startedAt = os.clock()
		while pending > 0 and os.clock() - startedAt < DataConfig.BindToCloseTimeoutSeconds do task.wait(0.05) end
	end)
end

return PlayerDataService
