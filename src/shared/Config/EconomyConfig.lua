--!strict

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

	-- Once an item is KEPT, the original immediate SELL opportunity was sacrificed.
	-- Liquidating Stock later only returns a fraction of that original value.
	DefaultSalvageRatio = 0.20,

	-- M4 economy-tuning patch:
	-- KEEP was too weak relative to real early active hauling. These values are
	-- deliberately temporary and make current Stock relevant enough to test before
	-- M5 introduces section baseline power + rarity. SELL remains derived from the
	-- passive rate through a short early break-even window rather than being tuned
	-- independently.
	--
	-- Old -> new passive direction:
	-- Box 50 -> 150, Microwave 120 -> 320, Lamp 90 -> 240,
	-- Tire 180 -> 450, Chair 220 -> 600, TV 500 -> 900,
	-- Couch 850 -> 1400, Safe 1200 -> 2000.
	Items = table.freeze({
		Box = table.freeze({ PassivePerMinute = 150, TargetBreakEvenMinutes = 6 }),
		Microwave = table.freeze({ PassivePerMinute = 320, TargetBreakEvenMinutes = 7 }),
		Lamp = table.freeze({ PassivePerMinute = 240, TargetBreakEvenMinutes = 7 }),
		Chair = table.freeze({ PassivePerMinute = 600, TargetBreakEvenMinutes = 8 }),
		Tire = table.freeze({ PassivePerMinute = 450, TargetBreakEvenMinutes = 8 }),
		TV = table.freeze({ PassivePerMinute = 900, TargetBreakEvenMinutes = 10 }),
		Couch = table.freeze({ PassivePerMinute = 1400, TargetBreakEvenMinutes = 12 }),
		Safe = table.freeze({ PassivePerMinute = 2000, TargetBreakEvenMinutes = 12 }),
	}),

	-- These are architectural headroom bands, not M5 rarity/content assignments.
	ProgressionBands = table.freeze({
		BeginnerPassivePerMinute = Vector2.new(150, 900),
		EarlyPassivePerMinute = Vector2.new(900, 20_000),
		EstablishedPassivePerMinute = Vector2.new(20_000, 500_000),
		LatePassivePerMinute = Vector2.new(500_000, 10_000_000),
	}),
}

return table.freeze(EconomyConfig)
