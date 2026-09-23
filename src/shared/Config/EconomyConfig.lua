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

	-- M3 prototype values. SELL is deliberately worth far more in the short term.
	-- KEEP sacrifices that immediate payout for slow indefinite passive income.
	-- Future rarity/buyer/progression modifiers should be applied through the
	-- centralized economy calculation path, not scattered through gameplay code.
	Items = table.freeze({
		Box = table.freeze({ SellValue = 150, PassivePerMinute = 1 }),
		Microwave = table.freeze({ SellValue = 400, PassivePerMinute = 2 }),
		Lamp = table.freeze({ SellValue = 400, PassivePerMinute = 2 }),
		Chair = table.freeze({ SellValue = 550, PassivePerMinute = 3 }),
		Tire = table.freeze({ SellValue = 300, PassivePerMinute = 2 }),
		TV = table.freeze({ SellValue = 700, PassivePerMinute = 4 }),
		Couch = table.freeze({ SellValue = 1000, PassivePerMinute = 5 }),
		Safe = table.freeze({ SellValue = 1000, PassivePerMinute = 6 }),
	}),
}

return table.freeze(EconomyConfig)
