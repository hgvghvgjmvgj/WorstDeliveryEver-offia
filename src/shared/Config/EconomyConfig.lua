--!strict

local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))
local LootEconomy = require(script.Parent:WaitForChild("LootEconomy"))
local RarityConfig = require(script.Parent:WaitForChild("RarityConfig"))

local items = {}

for baseItemId in LootCatalog.ById do
	for _, rarity in RarityConfig.Order do
		local economy = LootEconomy.For(baseItemId, rarity)
		if economy then
			local variantId = RarityConfig.MakeVariantId(baseItemId, rarity)
			items[variantId] = table.freeze({
				PassivePerMinute = economy.PassivePerMinute,
				TargetBreakEvenMinutes = economy.BreakEvenMinutes,
				EconomicTier = rarity,
				BaseItemId = baseItemId,
				SectionId = economy.SectionId,
				SectionMultiplier = economy.SectionMultiplier,
				Rarity = rarity,
				RarityMultiplier = economy.RarityMultiplier,
			})
		end
	end
end

-- Preserve M4/M4.2 Stock already written to profiles. These IDs are no longer
-- selected by the M5B warehouse catalog, but old Stock must hydrate safely.
local legacy = {
	Box = { PassivePerMinute = 400, TargetBreakEvenMinutes = 2.25, EconomicTier = "Legacy" },
	Lamp = { PassivePerMinute = 500, TargetBreakEvenMinutes = 3.36, EconomicTier = "Legacy" },
	Microwave = { PassivePerMinute = 650, TargetBreakEvenMinutes = 224 / 65, EconomicTier = "Legacy" },
	Tire = { PassivePerMinute = 850, TargetBreakEvenMinutes = 72 / 17, EconomicTier = "Legacy" },
	Chair = { PassivePerMinute = 1000, TargetBreakEvenMinutes = 4.8, EconomicTier = "Legacy" },
	TV = { PassivePerMinute = 1300, TargetBreakEvenMinutes = 90 / 13, EconomicTier = "Legacy" },
	Couch = { PassivePerMinute = 1700, TargetBreakEvenMinutes = 168 / 17, EconomicTier = "Legacy" },
	Safe = { PassivePerMinute = 2000, TargetBreakEvenMinutes = 12, EconomicTier = "Legacy" },
}
for itemId, tuning in legacy do
	if not items[itemId] then
		items[itemId] = table.freeze(tuning)
	end
end

table.freeze(items)

local EconomyConfig = {
	StartingCash = 0,
	DefaultStockSlots = 3,
	MaxStockSlots = 10,

	StockSlotCapacityAttribute = "StockSlotCapacity",
	PassiveIncomeMultiplierAttribute = "DevPassiveIncomeMultiplier",
	DefaultPassiveIncomeMultiplier = 1,
	MinPassiveIncomeMultiplier = 0.1,
	MaxPassiveIncomeMultiplier = 120,

	Review = table.freeze({
		ActionCooldownSeconds = 0.08,
	}),

	Passive = table.freeze({
		CalculationIntervalSeconds = 1.0,
	}),

	DefaultSalvageRatio = 0.20,
	Items = items,

	-- Numerical headroom for M5's much larger values. NumberFormat already
	-- presents K/M/B/T; values remain far below exact-integer safety limits.
	ProgressionBands = table.freeze({
		BeginnerPassivePerMinute = Vector2.new(100, 10_000),
		EarlyPassivePerMinute = Vector2.new(10_000, 250_000),
		EstablishedPassivePerMinute = Vector2.new(250_000, 10_000_000),
		LatePassivePerMinute = Vector2.new(10_000_000, 1_000_000_000),
	}),
}

return table.freeze(EconomyConfig)
