--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProgressionConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ProgressionConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local ProgressionService = {}

local progressionStateRemote: RemoteEvent
local progressionActionRemote: RemoteEvent
local noticeRemote: RemoteEvent
local lastActionAt: {[Player]: number} = {}

local function levelValue(trackName: string, levelIndex: number): number
	local track = ProgressionConfig.Tracks[trackName]
	local clamped = math.clamp(levelIndex, 1, #track.Levels)
	return track.Levels[clamped].Value
end

local function getLevel(profile: any, trackName: string): number
	local track = ProgressionConfig.Tracks[trackName]
	return math.clamp(
		math.floor((profile.Progression[track.ProfileField] or 1) + 0.5),
		1,
		#track.Levels
	)
end

local function applyTrack(player: Player, profile: any, trackName: string)
	local track = ProgressionConfig.Tracks[trackName]
	local levelIndex = getLevel(profile, trackName)
	player:SetAttribute(track.ProfileField, levelIndex)
	player:SetAttribute(track.Attribute, levelValue(trackName, levelIndex))
end

local function applyAll(player: Player, profile: any)
	for _, trackName in ProgressionConfig.TrackOrder do
		applyTrack(player, profile, trackName)
	end
	player:SetAttribute("CarryRigTier", profile.Progression.CarryRigTier or ProgressionConfig.DefaultCarryRigTier)
	player:SetAttribute("ProgressionReady", true)
end

local function snapshotFor(player: Player, profile: any)
	local tracks = {}
	for _, trackName in ProgressionConfig.TrackOrder do
		local track = ProgressionConfig.Tracks[trackName]
		local currentLevel = getLevel(profile, trackName)
		local nextLevel = currentLevel + 1
		local isMax = nextLevel > #track.Levels
		table.insert(tracks, {
			id = trackName,
			name = track.DisplayName,
			description = track.Description,
			level = currentLevel,
			maxLevel = #track.Levels,
			currentValue = track.Levels[currentLevel].Value,
			nextValue = if isMax then track.Levels[currentLevel].Value else track.Levels[nextLevel].Value,
			nextCost = if isMax then 0 else track.Levels[nextLevel].Cost,
			isMax = isMax,
		})
	end
	return {
		cash = PlayerDataService.GetCash(player),
		tracks = tracks,
		carryRigTier = profile.Progression.CarryRigTier or ProgressionConfig.DefaultCarryRigTier,
	}
end

local function sendState(player: Player)
	local profile = PlayerDataService.GetProfile(player)
	if profile and player.Parent then
		progressionStateRemote:FireClient(player, snapshotFor(player, profile))
	end
end

local function purchase(player: Player, trackName: string): boolean
	local track = ProgressionConfig.Tracks[trackName]
	local profile = PlayerDataService.GetProfile(player)
	if not track or not profile then
		return false
	end

	local currentLevel = getLevel(profile, trackName)
	local nextLevel = currentLevel + 1
	if nextLevel > #track.Levels then
		noticeRemote:FireClient(player, track.DisplayName .. " IS MAXED FOR M4.")
		return false
	end

	local cost = track.Levels[nextLevel].Cost
	if not PlayerDataService.TrySpendCash(player, cost) then
		noticeRemote:FireClient(player, "NOT ENOUGH CASH.")
		return false
	end

	profile.Progression[track.ProfileField] = nextLevel
	applyTrack(player, profile, trackName)
	PlayerDataService.MarkDirty(player)
	PlayerDataService.RequestSave(player)
	noticeRemote:FireClient(player, ("%s UPGRADED TO LEVEL %d"):format(track.DisplayName, nextLevel))
	return true
end

local function handleAction(player: Player, action: any, payload: any)
	if typeof(action) ~= "string" or typeof(payload) ~= "table" then
		return
	end
	if not PlayerDataService.IsLoaded(player) then
		return
	end

	if action == "RequestState" then
		sendState(player)
		return
	end

	local now = os.clock()
	local previous = lastActionAt[player] or -math.huge
	if now - previous < ProgressionConfig.PurchaseCooldownSeconds then
		return
	end
	lastActionAt[player] = now

	if action == "PurchaseUpgrade" and typeof(payload.trackId) == "string" then
		if purchase(player, payload.trackId) then
			sendState(player)
		end
	end
end

function ProgressionService.RefreshPlayer(player: Player)
	local profile = PlayerDataService.GetProfile(player)
	if profile then
		applyAll(player, profile)
		sendState(player)
	end
end

function ProgressionService.Start()
	progressionStateRemote = RemoteService.Get(RemoteNames.ProgressionState)
	progressionActionRemote = RemoteService.Get(RemoteNames.ProgressionAction)
	noticeRemote = RemoteService.Get(RemoteNames.PrototypeNotice)
	progressionActionRemote.OnServerEvent:Connect(handleAction)

	PlayerDataService.OnLoaded(function(player, profile)
		applyAll(player, profile)
		sendState(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastActionAt[player] = nil
	end)
end

return ProgressionService
