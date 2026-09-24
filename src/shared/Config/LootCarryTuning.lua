--!strict

-- Physical section tuning stays separate from rarity. A Common and Eternal
-- version of the same base object keep identical Weight/Bulk; deeper sections
-- become harder because their object families are physically more demanding.
local Tuning = {
	Section = table.freeze({
		Receiving = table.freeze({ WeightScale = 1.00, BulkScale = 1.00 }),
		HomeBasics = table.freeze({ WeightScale = 1.00, BulkScale = 1.05 }),
		Appliances = table.freeze({ WeightScale = 1.05, BulkScale = 1.05 }),
		Furniture = table.freeze({ WeightScale = 1.05, BulkScale = 1.25 }),
		Electronics = table.freeze({ WeightScale = 1.10, BulkScale = 1.10 }),
		Recreation = table.freeze({ WeightScale = 1.15, BulkScale = 1.15 }),
		GarageAuto = table.freeze({ WeightScale = 1.20, BulkScale = 1.10 }),
		Construction = table.freeze({ WeightScale = 1.25, BulkScale = 1.15 }),
		HeavyGoods = table.freeze({ WeightScale = 1.25, BulkScale = 1.10 }),
		Industrial = table.freeze({ WeightScale = 1.40, BulkScale = 1.20 }),
		PremiumInteriors = table.freeze({ WeightScale = 1.25, BulkScale = 1.30 }),
		LuxuryGoods = table.freeze({ WeightScale = 1.30, BulkScale = 1.35 }),
		ArtCollectibles = table.freeze({ WeightScale = 1.30, BulkScale = 1.40 }),
		Secure = table.freeze({ WeightScale = 1.50, BulkScale = 1.30 }),
		RestrictedPrototype = table.freeze({ WeightScale = 1.55, BulkScale = 1.35 }),
	}),

	HeroWeightScale = 1.10,
	HeroBulkScale = 1.10,
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
