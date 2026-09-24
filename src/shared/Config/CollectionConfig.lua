--!strict

local ItemConfig = require(script.Parent:WaitForChild("ItemConfig"))
local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))
local RarityConfig = require(script.Parent:WaitForChild("RarityConfig"))

local Config = {}

Config.Milestones = table.freeze({
	table.freeze({ Key = "25", Ratio = 0.25, BaseCash = 2_500, Cosmetic = nil }),
	table.freeze({ Key = "50", Ratio = 0.50, BaseCash = 7_000, Cosmetic = "SECTION PLAQUE" }),
	table.freeze({ Key = "75", Ratio = 0.75, BaseCash = 15_000, Cosmetic = "SECTION BANNER" }),
	table.freeze({ Key = "100", Ratio = 1.00, BaseCash = 30_000, Cosmetic = nil }),
})

Config.SectionRewardScale = table.freeze({
	Receiving = 1.00,
	HomeBasics = 1.20,
	Appliances = 1.50,
	Furniture = 2.00,
	Electronics = 2.30,
	Recreation = 2.50,
	GarageAuto = 2.70,
	Construction = 2.90,
	HeavyGoods = 3.00,
	Industrial = 4.50,
	PremiumInteriors = 5.00,
	LuxuryGoods = 5.50,
	ArtCollectibles = 6.20,
	Secure = 7.00,
	RestrictedPrototype = 8.50,
})

Config.Trophies = table.freeze({
	Receiving = table.freeze({ Name = "GOLDEN PALLET JACK", Color = Color3.fromRGB(222,177,67), Shape = "Cart" }),
	HomeBasics = table.freeze({ Name = "HOME BASICS AWARD", Color = Color3.fromRGB(205,171,117), Shape = "Chair" }),
	Appliances = table.freeze({ Name = "PROTOTYPE APPLIANCE AWARD", Color = Color3.fromRGB(106,193,218), Shape = "Appliance" }),
	Furniture = table.freeze({ Name = "ROYAL FURNITURE AWARD", Color = Color3.fromRGB(187,135,82), Shape = "Chair" }),
	Electronics = table.freeze({ Name = "ELECTRONICS COMMAND AWARD", Color = Color3.fromRGB(102,153,221), Shape = "Appliance" }),
	Recreation = table.freeze({ Name = "ARCADE MASTER AWARD", Color = Color3.fromRGB(170,103,219), Shape = "Appliance" }),
	GarageAuto = table.freeze({ Name = "GARAGE MASTER AWARD", Color = Color3.fromRGB(187,91,72), Shape = "Cart" }),
	Construction = table.freeze({ Name = "CONSTRUCTION MASTER AWARD", Color = Color3.fromRGB(194,163,77), Shape = "Case" }),
	HeavyGoods = table.freeze({ Name = "GOLDEN VAULT AWARD", Color = Color3.fromRGB(217,177,67), Shape = "Safe" }),
	Industrial = table.freeze({ Name = "INDUSTRIAL REACTOR AWARD", Color = Color3.fromRGB(89,204,218), Shape = "Core" }),
	PremiumInteriors = table.freeze({ Name = "PREMIUM INTERIORS AWARD", Color = Color3.fromRGB(210,186,145), Shape = "Chair" }),
	LuxuryGoods = table.freeze({ Name = "LUXURY COLLECTION AWARD", Color = Color3.fromRGB(216,176,112), Shape = "Case" }),
	ArtCollectibles = table.freeze({ Name = "COLLECTOR MASTERPIECE AWARD", Color = Color3.fromRGB(184,153,103), Shape = "Core" }),
	Secure = table.freeze({ Name = "SECURE CONTAINMENT AWARD", Color = Color3.fromRGB(214,202,145), Shape = "Case" }),
	RestrictedPrototype = table.freeze({ Name = "RESTRICTED PROTOTYPE AWARD", Color = Color3.fromRGB(99,220,230), Shape = "Core" }),
})

Config.RareFindMinimumRank = 7
Config.HeroAnnouncementMinimumRank = 6
Config.ServerAnnouncementMinimumRank = 7

local milestoneKeys = table.freeze({ ["25"] = true, ["50"] = true, ["75"] = true, ["100"] = true })

local function validRarity(value: any): string
	if typeof(value) == "string" and RarityConfig.Tiers[value] then return value end
	return "Common"
end

local function finiteNumber(value: any, fallback: number): number
	if typeof(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return fallback end
	return value
end

local function newEntry(rarity: string, nowUnix: number, sellValue: number?): any
	return {
		BestRarity = rarity,
		FirstDiscoveredUnix = nowUnix,
		TimesDelivered = 1,
		BestSellValueDelivered = math.max(0, math.floor(finiteNumber(sellValue, 0) + 0.5)),
	}
end

function Config.NewProfile(): any
	local sections = {}
	for _, sectionId in LootCatalog.SectionOrder do
		sections[sectionId] = { Discovered = {}, RewardMilestones = {} }
	end
	return { Sections = sections, RareFinds = {} }
end

local function sanitizeEntry(raw: any, nowUnix: number): any?
	if typeof(raw) ~= "table" then return nil end
	return {
		BestRarity = validRarity(raw.BestRarity),
		FirstDiscoveredUnix = math.max(0, math.floor(finiteNumber(raw.FirstDiscoveredUnix, nowUnix))),
		TimesDelivered = math.max(1, math.floor(finiteNumber(raw.TimesDelivered, 1) + 0.5)),
		BestSellValueDelivered = math.max(0, math.floor(finiteNumber(raw.BestSellValueDelivered, 0) + 0.5)),
	}
end

function Config.Sanitize(raw: any, nowUnix: number): any
	local result = Config.NewProfile()
	if typeof(raw) ~= "table" then return result end
	local sourceSections = if typeof(raw.Sections) == "table" then raw.Sections else {}

	for _, sectionId in LootCatalog.SectionOrder do
		local destination = result.Sections[sectionId]
		local source = sourceSections[sectionId]
		if typeof(source) == "table" then
			local discovered = if typeof(source.Discovered) == "table" then source.Discovered else {}
			for baseItemId, rawEntry in discovered do
				local base = LootCatalog.ById[baseItemId]
				if typeof(baseItemId) == "string" and base and base.SectionId == sectionId and base.Core == true then
					local clean = sanitizeEntry(rawEntry, nowUnix)
					if clean then destination.Discovered[baseItemId] = clean end
				end
			end
			local rewards = if typeof(source.RewardMilestones) == "table" then source.RewardMilestones else {}
			for key, value in rewards do
				if milestoneKeys[tostring(key)] and value == true then
					destination.RewardMilestones[tostring(key)] = true
				end
			end
		end
	end

	local sourceRare = if typeof(raw.RareFinds) == "table" then raw.RareFinds else {}
	for baseItemId, rawEntry in sourceRare do
		local base = LootCatalog.ById[baseItemId]
		if typeof(baseItemId) == "string" and base then
			local clean = sanitizeEntry(rawEntry, nowUnix)
			if clean then
				clean.SectionId = base.SectionId
				result.RareFinds[baseItemId] = clean
			end
		end
	end
	return result
end

function Config.CashReward(sectionId: string, milestoneKey: string): number
	local scale = Config.SectionRewardScale[sectionId] or 1
	for _, milestone in Config.Milestones do
		if milestone.Key == milestoneKey then
			return math.max(0, math.floor(milestone.BaseCash * scale + 0.5))
		end
	end
	return 0
end

function Config.CoreCount(sectionId: string): number
	local pool = LootCatalog.CoreBySection[sectionId]
	return if pool then #pool else 0
end

function Config.DiscoveredCount(collection: any, sectionId: string): number
	local section = collection and collection.Sections and collection.Sections[sectionId]
	local discovered = section and section.Discovered
	if typeof(discovered) ~= "table" then return 0 end
	local count = 0
	for baseItemId in discovered do
		local base = LootCatalog.ById[baseItemId]
		if base and base.SectionId == sectionId and base.Core == true then count += 1 end
	end
	return count
end

function Config.IsRareFind(baseItemId: string, rarity: string): boolean
	local base = LootCatalog.ById[baseItemId]
	if not base then return false end
	if base.Core == false then return true end
	return RarityConfig.Rank(rarity) >= Config.RareFindMinimumRank
end

local function upgradeEntry(entry: any?, rarity: string, nowUnix: number, sellValue: number?): (any, boolean, string?)
	if not entry then return newEntry(rarity, nowUnix, sellValue), true, nil end
	local oldRarity = validRarity(entry.BestRarity)
	entry.TimesDelivered = math.max(1, math.floor(finiteNumber(entry.TimesDelivered, 1) + 0.5)) + 1
	entry.BestSellValueDelivered = math.max(
		math.max(0, math.floor(finiteNumber(entry.BestSellValueDelivered, 0) + 0.5)),
		math.max(0, math.floor(finiteNumber(sellValue, 0) + 0.5))
	)
	if RarityConfig.Rank(rarity) > RarityConfig.Rank(oldRarity) then
		entry.BestRarity = rarity
		return entry, false, oldRarity
	end
	entry.BestRarity = oldRarity
	return entry, false, nil
end

function Config.RecordCore(collection: any, baseItemId: string, rarity: string, nowUnix: number, sellValue: number?): (boolean, string?)
	local base = LootCatalog.ById[baseItemId]
	if not base or base.Core ~= true then return false, nil end
	local section = collection.Sections[base.SectionId]
	if not section then return false, nil end
	local updated, isNew, oldBest = upgradeEntry(section.Discovered[baseItemId], validRarity(rarity), nowUnix, sellValue)
	section.Discovered[baseItemId] = updated
	return isNew, oldBest
end

function Config.RecordRareFind(collection: any, baseItemId: string, rarity: string, nowUnix: number, sellValue: number?): (boolean, string?)
	local base = LootCatalog.ById[baseItemId]
	if not base or not Config.IsRareFind(baseItemId, rarity) then return false, nil end
	local updated, isNew, oldBest = upgradeEntry(collection.RareFinds[baseItemId], validRarity(rarity), nowUnix, sellValue)
	updated.SectionId = base.SectionId
	collection.RareFinds[baseItemId] = updated
	return isNew, oldBest
end

function Config.BackfillFromStock(collection: any, stock: any, nowUnix: number)
	local changedSections: {[string]: boolean} = {}
	local slots = stock and stock.Slots
	if typeof(slots) ~= "table" then return end

	for _, raw in slots do
		if typeof(raw) == "table" and typeof(raw.ItemId) == "string" then
			local definition = ItemConfig[raw.ItemId]
			if definition then
				local baseItemId = definition.BaseItemId or raw.ItemId
				local base = LootCatalog.ById[baseItemId]
				local rarity = validRarity(definition.Rarity)
				if base then
					local stockTime = math.max(0, math.floor(finiteNumber(raw.StockedAtUnix, nowUnix)))
					local stockSell = math.max(0, math.floor(finiteNumber(raw.OriginalSellValue, 0) + 0.5))
					if base.Core == true then
						local section = collection.Sections[base.SectionId]
						local previous = section and section.Discovered[baseItemId]
						if section then
							if not previous then
								section.Discovered[baseItemId] = newEntry(rarity, stockTime, stockSell)
								changedSections[base.SectionId] = true
							else
								if RarityConfig.Rank(rarity) > RarityConfig.Rank(validRarity(previous.BestRarity)) then
									previous.BestRarity = rarity
								end
								previous.BestSellValueDelivered = math.max(finiteNumber(previous.BestSellValueDelivered, 0), stockSell)
							end
						end
					end
					if Config.IsRareFind(baseItemId, rarity) then
						local rare = collection.RareFinds[baseItemId]
						if not rare then
							rare = newEntry(rarity, stockTime, stockSell)
							rare.SectionId = base.SectionId
							collection.RareFinds[baseItemId] = rare
						else
							if RarityConfig.Rank(rarity) > RarityConfig.Rank(validRarity(rare.BestRarity)) then
								rare.BestRarity = rarity
							end
							rare.BestSellValueDelivered = math.max(finiteNumber(rare.BestSellValueDelivered, 0), stockSell)
						end
					end
				end
			end
		end
	end

	for sectionId in changedSections do
		local total = Config.CoreCount(sectionId)
		local count = Config.DiscoveredCount(collection, sectionId)
		local ratio = if total > 0 then count / total else 0
		local section = collection.Sections[sectionId]
		for _, milestone in Config.Milestones do
			if ratio + 1e-6 >= milestone.Ratio then
				section.RewardMilestones[milestone.Key] = true
			end
		end
	end
end

return table.freeze(Config)
