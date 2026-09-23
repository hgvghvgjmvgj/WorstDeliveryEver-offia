--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CollectionConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local RemoteService = require(script.Parent:WaitForChild("RemoteService"))
local TrophyService = require(script.Parent:WaitForChild("TrophyService"))

local CollectionService = {}

local stateRemote: RemoteEvent
local actionRemote: RemoteEvent
local eventRemote: RemoteEvent

local function sectionDisplayName(sectionId: string): string
	local section = LootCatalog.Sections[sectionId]
	return if section then section.DisplayName else sectionId
end

local function ensureCollection(profile: any): any
	if typeof(profile.Collection) ~= "table" then
		profile.Collection = CollectionConfig.NewProfile()
	end
	return profile.Collection
end

local function snapshotFor(profile: any): any
	local collection = ensureCollection(profile)
	local sections = {}
	for _, sectionId in LootCatalog.SectionOrder do
		local pool = LootCatalog.CoreBySection[sectionId] or {}
		local sectionState = collection.Sections[sectionId] or { Discovered = {}, RewardMilestones = {} }
		local entries = {}
		for _, baseItemId in pool do
			local base = LootCatalog.ById[baseItemId]
			local record = sectionState.Discovered[baseItemId]
			table.insert(entries, {
				discovered = record ~= nil,
				name = if record and base then base.Name else "???",
				bestRarity = if record then record.BestRarity else nil,
				timesDelivered = if record then record.TimesDelivered else 0,
			})
		end
		local discovered = CollectionConfig.DiscoveredCount(collection, sectionId)
		local total = #pool
		table.insert(sections, {
			id = sectionId,
			name = sectionDisplayName(sectionId),
			discovered = discovered,
			total = total,
			mastery = if total > 0 then discovered / total else 0,
			rewardMilestones = sectionState.RewardMilestones,
			entries = entries,
		})
	end

	local rareEntries = {}
	local included: {[string]: boolean} = {}
	for _, sectionId in LootCatalog.SectionOrder do
		local heroes = LootCatalog.HeroBySection[sectionId] or {}
		for _, baseItemId in heroes do
			included[baseItemId] = true
			local base = LootCatalog.ById[baseItemId]
			local record = collection.RareFinds[baseItemId]
			table.insert(rareEntries, {
				baseItemId = baseItemId,
				discovered = record ~= nil,
				name = if record and base then base.Name else "???",
				sectionId = sectionId,
				sectionName = sectionDisplayName(sectionId),
				bestRarity = if record then record.BestRarity else nil,
				timesDelivered = if record then record.TimesDelivered else 0,
				hero = true,
			})
		end
	end
	-- Cosmic/Eternal versions of ordinary core cargo are prestige finds too.
	-- They are appended only after being discovered, so the Rare Finds menu does
	-- not become a second copy of every normal collection entry.
	for baseItemId, record in collection.RareFinds do
		if not included[baseItemId] then
			local base = LootCatalog.ById[baseItemId]
			if base then
				table.insert(rareEntries, {
					baseItemId = baseItemId,
					discovered = true,
					name = base.Name,
					sectionId = base.SectionId,
					sectionName = sectionDisplayName(base.SectionId),
					bestRarity = record.BestRarity,
					timesDelivered = record.TimesDelivered or 1,
					hero = false,
				})
			end
		end
	end

	return {
		sections = sections,
		rareFinds = rareEntries,
	}
end

local function sendState(player: Player)
	local profile = PlayerDataService.GetProfile(player)
	if profile and player.Parent then
		stateRemote:FireClient(player, snapshotFor(profile))
	end
end

local function firePlayerEvent(player: Player, kind: string, data: any)
	if player.Parent then
		eventRemote:FireClient(player, kind, data)
	end
end

local function evaluateMilestones(player: Player, profile: any, affectedSections: {[string]: boolean})
	local collection = ensureCollection(profile)
	for sectionId in affectedSections do
		local section = collection.Sections[sectionId]
		if section then
			local total = CollectionConfig.CoreCount(sectionId)
			local discovered = CollectionConfig.DiscoveredCount(collection, sectionId)
			local ratio = if total > 0 then discovered / total else 0
			for _, milestone in CollectionConfig.Milestones do
				if ratio + 1e-6 >= milestone.Ratio and section.RewardMilestones[milestone.Key] ~= true then
					section.RewardMilestones[milestone.Key] = true
					local cash = CollectionConfig.CashReward(sectionId, milestone.Key)
					if cash > 0 then PlayerDataService.AddCash(player, cash) end
					firePlayerEvent(player, "MasteryMilestone", {
						sectionId = sectionId,
						sectionName = sectionDisplayName(sectionId),
						percent = tonumber(milestone.Key) or math.floor(milestone.Ratio * 100 + 0.5),
						cash = cash,
						cosmetic = milestone.Cosmetic,
						trophy = milestone.Key == "100",
						discovered = discovered,
						total = total,
					})
					if milestone.Key == "100" then
						task.defer(TrophyService.RefreshPlayer, player)
					end
				end
			end
		end
	end
end

local function extraordinaryCandidate(current: any?, base: any, definition: any): any?
	local rarity = definition.Rarity or "Common"
	local rank = RarityConfig.Rank(rarity)
	local qualifies = rank >= CollectionConfig.ServerAnnouncementMinimumRank
		or (base.Core == false and rank >= CollectionConfig.HeroAnnouncementMinimumRank)
	if not qualifies then return current end
	local candidate = {
		name = base.Name,
		rarity = rarity,
		rank = rank,
		value = definition.Value or 0,
	}
	if not current or candidate.rank > current.rank or (candidate.rank == current.rank and candidate.value > current.value) then
		return candidate
	end
	return current
end

function CollectionService.RecordDelivery(player: Player, itemIds: {string}): boolean
	local profile = PlayerDataService.GetProfile(player)
	if not profile or #itemIds == 0 then return false end
	local collection = ensureCollection(profile)
	local nowUnix = os.time()
	local affectedSections: {[string]: boolean} = {}
	local changed = false
	local announcement: any? = nil

	for _, itemId in itemIds do
		local definition = ItemConfig[itemId]
		if definition then
			local baseItemId = definition.BaseItemId or itemId
			local base = LootCatalog.ById[baseItemId]
			if base then
				local rarity = definition.Rarity or "Common"
				announcement = extraordinaryCandidate(announcement, base, definition)
				if base.Core == true then
					local isNew, oldBest = CollectionConfig.RecordCore(collection, baseItemId, rarity, nowUnix, definition.Value)
					affectedSections[base.SectionId] = true
					changed = true
					if isNew then
						local count = CollectionConfig.DiscoveredCount(collection, base.SectionId)
						local total = CollectionConfig.CoreCount(base.SectionId)
						firePlayerEvent(player, "NewDiscovery", {
							name = base.Name,
							rarity = rarity,
							sectionId = base.SectionId,
							sectionName = sectionDisplayName(base.SectionId),
							discovered = count,
							total = total,
						})
					elseif oldBest then
						firePlayerEvent(player, "BestRarity", {
							name = base.Name,
							oldRarity = oldBest,
							newRarity = rarity,
							sectionName = sectionDisplayName(base.SectionId),
							rareFind = false,
						})
					end
				end

				if CollectionConfig.IsRareFind(baseItemId, rarity) then
					local rareNew, oldRareBest = CollectionConfig.RecordRareFind(collection, baseItemId, rarity, nowUnix, definition.Value)
					changed = true
					if rareNew then
						firePlayerEvent(player, "RareFind", {
							name = base.Name,
							rarity = rarity,
							sectionId = base.SectionId,
							sectionName = sectionDisplayName(base.SectionId),
							hero = base.Core == false,
						})
					elseif oldRareBest and base.Core == false then
						firePlayerEvent(player, "BestRarity", {
							name = base.Name,
							oldRarity = oldRareBest,
							newRarity = rarity,
							sectionName = sectionDisplayName(base.SectionId),
							rareFind = true,
						})
					end
				end
			end
		end
	end

	if not changed then return false end
	evaluateMilestones(player, profile, affectedSections)
	PlayerDataService.MarkDirty(player)
	PlayerDataService.RequestSave(player)
	sendState(player)

	-- One extraordinary announcement per delivery keeps spectacle without a
	-- multi-item Cosmic haul spamming the whole server.
	if announcement then
		eventRemote:FireAllClients("ServerAnnouncement", {
			playerName = player.DisplayName,
			itemName = announcement.name,
			rarity = announcement.rarity,
		})
	end
	return true
end

local function handleAction(player: Player, action: any, _payload: any)
	if action == "RequestState" and PlayerDataService.IsLoaded(player) then
		sendState(player)
	end
end

function CollectionService.Start()
	stateRemote = RemoteService.Get(RemoteNames.CollectionState)
	actionRemote = RemoteService.Get(RemoteNames.CollectionAction)
	eventRemote = RemoteService.Get(RemoteNames.CollectionEvent)
	actionRemote.OnServerEvent:Connect(handleAction)
	PlayerDataService.OnLoaded(function(player)
		sendState(player)
	end)
end

return CollectionService
