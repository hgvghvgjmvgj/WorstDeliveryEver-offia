--!strict

-- M5B carry-difficulty tuning for the expanded loot catalog.
--
-- This does NOT change the carry mechanic. It translates each authored base
-- object's Weight/Bulk into the intended section difficulty while preserving
-- the object's relative identity. Rarity variants of the same base object keep
-- identical carry stats; rare-only hero objects receive a modest extra burden.
local Tuning = {
	Section = table.freeze({
		Receiving = table.freeze({ WeightScale = 1.00, BulkScale = 1.00 }),
		Appliances = table.freeze({ WeightScale = 1.05, BulkScale = 1.05 }),
		Furniture = table.freeze({ WeightScale = 1.05, BulkScale = 1.25 }),
		HeavyGoods = table.freeze({ WeightScale = 1.25, BulkScale = 1.10 }),
		Industrial = table.freeze({ WeightScale = 1.40, BulkScale = 1.20 }),
		Secure = table.freeze({ WeightScale = 1.50, BulkScale = 1.30 }),
	}),

	HeroWeightScale = 1.10,
	HeroBulkScale = 1.10,

	-- Half-point granularity keeps debug numbers understandable while still
	-- giving enough resolution for the existing pressure ratios.
	Granularity = 0.5,
}

local function roundTo(value: number, granularity: number): number
	return math.floor(value / granularity + 0.5) * granularity
end

function Tuning.For(base): (number, number)
	local section = Tuning.Section[base.SectionId] or { WeightScale = 1, BulkScale = 1 }
	local heroWeight = if base.Core == false then Tuning.HeroWeightScale else 1
	local heroBulk = if base.Core == false then Tuning.HeroBulkScale else 1
	return math.max(0.5, roundTo(base.Weight * section.WeightScale * heroWeight, Tuning.Granularity)),
		math.max(0.5, roundTo(base.Bulk * section.BulkScale * heroBulk, Tuning.Granularity))
end

return table.freeze(Tuning)
