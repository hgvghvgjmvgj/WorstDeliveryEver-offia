local DataStoreService = game:GetService("DataStoreService")

local PlayerDataService = {}

PlayerDataService.AutosaveInterval = 60

local STORE_NAME = "GetItIn_PlayerData_v1"
local SCHEMA_VERSION = 1
local MAX_RETRIES = 3

local store = DataStoreService:GetDataStore(STORE_NAME)

local function keyFor(player)
	return "u_" .. tostring(player.UserId)
end

local function sanitizeCash(value)
	if type(value) ~= "number" then
		return 0
	end

	if value ~= value or value == math.huge or value == -math.huge then
		return 0
	end

	return math.max(0, math.floor(value))
end

local function readCash(raw)
	if type(raw) == "table" then
		return sanitizeCash(raw.cash)
	end

	if type(raw) == "number" then
		return sanitizeCash(raw)
	end

	return 0
end

function PlayerDataService.LoadCash(player)
	for attempt = 1, MAX_RETRIES do
		local success, result = pcall(function()
			return store:GetAsync(keyFor(player))
		end)

		if success then
			return true, readCash(result)
		end

		warn(("[GET IT IN] Data load failed for %s (attempt %d/%d): %s")
			:format(player.Name, attempt, MAX_RETRIES, tostring(result)))

		if attempt < MAX_RETRIES then
			task.wait(attempt)
		end
	end

	return false, 0
end

function PlayerDataService.SaveCash(player, cash)
	local sanitizedCash = sanitizeCash(cash)

	for attempt = 1, MAX_RETRIES do
		local success, result = pcall(function()
			return store:UpdateAsync(keyFor(player), function(oldValue)
				local oldCash = readCash(oldValue)

				return {
					schemaVersion = SCHEMA_VERSION,
					-- Cash only increases in the current build. Keeping the larger value
					-- prevents an older server/session from overwriting newer progress.
					cash = math.max(oldCash, sanitizedCash),
					updatedAt = os.time(),
				}
			end)
		end)

		if success then
			return true
		end

		warn(("[GET IT IN] Data save failed for %s (attempt %d/%d): %s")
			:format(player.Name, attempt, MAX_RETRIES, tostring(result)))

		if attempt < MAX_RETRIES then
			task.wait(attempt)
		end
	end

	return false
end

return PlayerDataService
