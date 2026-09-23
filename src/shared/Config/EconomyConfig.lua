--!strict

local EconomyConfig = {
	StartingCash = 0,
	DefaultStockSlots = 3,
	AllowedDevStockSlots = table.freeze({ 3, 5, 7, 10 }),
	MaxStockSlots = 10,

	-- Change these Player attributes on the SERVER while testing. No code edits needed.
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

	-- SELL value is derived from PassivePerMinute * TargetBreakEvenMinutes.
	-- This lets us change the visual number scale without scattering unrelated
	-- cash constants throughout gameplay logic. These are correction-pass test
	-- values, NOT final live balance.
	Items = table.freeze({
		Box = table.freeze({ PassivePerMinute = 50, TargetBreakEvenMinutes = 12 }),
		Microwave = table.freeze({ PassivePerMinute = 120, TargetBreakEvenMinutes = 15 }),
		Lamp = table.freeze({ PassivePerMinute = 90, TargetBreakEvenMinutes = 15 }),
		Chair = table.freeze({ PassivePerMinute = 220, TargetBreakEvenMinutes = 18 }),
		Tire = table.freeze({ PassivePerMinute = 180, TargetBreakEvenMinutes = 18 }),
		TV = table.freeze({ PassivePerMinute = 500, TargetBreakEvenMinutes = 20 }),
		Couch = table.freeze({ PassivePerMinute = 850, TargetBreakEvenMinutes = 22 }),
		Safe = table.freeze({ PassivePerMinute = 1200, TargetBreakEvenMinutes = 25 }),
	}),

	-- Architectural progression bands for later tuning/tests. These do not grant
	-- progression or change loot by themselves; they document supported scale.
	ProgressionBands = table.freeze({
		BeginnerPassivePerMinute = Vector2.new(50, 500),
		EarlyPassivePerMinute = Vector2.new(500, 10_000),
		EstablishedPassivePerMinute = Vector2.new(10_000, 250_000),
		LatePassivePerMinute = Vector2.new(250_000, 10_000_000),
	}),
}

return table.freeze(EconomyConfig)
