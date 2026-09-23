--!strict

local EconomyConfig = require(script.Parent:WaitForChild("EconomyConfig"))
local HandlingConfig = require(script.Parent:WaitForChild("HandlingConfig"))
local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))
local LootCarryTuning = require(script.Parent:WaitForChild("LootCarryTuning"))
local RarityConfig = require(script.Parent:WaitForChild("RarityConfig"))

export type ShapeTag = "Compact" | "Tall" | "Wide"

export type ItemDefinition = {
	Name: string,
	Value: number,
	Weight: number,
	Bulk: number,
	ShapeTag: ShapeTag,
	Handling: { Strength: number, CarrySpace: number, Control: number }?,
	BaseItemId: string?,
	SectionId: string?,
	Rarity: string?,
	RarityRank: number?,
	ModelKind: string?,
	CoreCollectionItem: boolean?,
}

local function sellValue(itemId: string): number
	local tuning = EconomyConfig.Items[itemId]
	if not tuning then
		return 0
	end
	return math.max(0, math.floor(tuning.PassivePerMinute * tuning.TargetBreakEvenMinutes + 0.5))
end

local items: {[string]: ItemDefinition} = {}

for baseItemId, base in LootCatalog.ById do
	local tunedWeight, tunedBulk = LootCarryTuning.For(base)
	local handling = HandlingConfig.RequirementsFor(base, tunedWeight, tunedBulk)
	for _, rarity in RarityConfig.Order do
		local variantId = RarityConfig.MakeVariantId(baseItemId, rarity)
		local tier = RarityConfig.Tiers[rarity]
		items[variantId] = table.freeze({
			Name = if rarity == "Common" then base.Name else (rarity .. " " .. base.Name),
			Value = sellValue(variantId),
			Weight = tunedWeight,
			Bulk = tunedBulk,
			ShapeTag = base.ShapeTag,
			Handling = handling,
			BaseItemId = baseItemId,
			SectionId = base.SectionId,
			Rarity = rarity,
			RarityRank = tier.Rank,
			ModelKind = base.ModelKind,
			CoreCollectionItem = base.Core,
		})
	end
end

-- Legacy world/profile compatibility for prototype IDs that no longer appear in
-- the authored M5 warehouse. Overlapping IDs use their new catalog definitions;
-- persisted Stock keeps its saved rate/value metadata.
local legacy = {
	Box = { Name = "Box", Weight = 1, Bulk = 1, ShapeTag = "Compact" },
	Lamp = { Name = "Lamp", Weight = 1, Bulk = 1, ShapeTag = "Tall" },
	Chair = { Name = "Chair", Weight = 2, Bulk = 2, ShapeTag = "Wide" },
	Tire = { Name = "Tire", Weight = 2, Bulk = 1, ShapeTag = "Compact" },
	TV = { Name = "TV", Weight = 3, Bulk = 2, ShapeTag = "Wide" },
}
for itemId, definition in legacy do
	if not items[itemId] then
		items[itemId] = table.freeze({
			Name = definition.Name,
			Value = sellValue(itemId),
			Weight = definition.Weight,
			Bulk = definition.Bulk,
			ShapeTag = definition.ShapeTag,
			Handling = table.freeze({ Strength = definition.Weight, CarrySpace = definition.Bulk, Control = 1.0 }),
			BaseItemId = itemId,
			SectionId = "Legacy",
			Rarity = "Common",
			RarityRank = 1,
			ModelKind = "Legacy",
			CoreCollectionItem = false,
		})
	end
end

return table.freeze(items)
