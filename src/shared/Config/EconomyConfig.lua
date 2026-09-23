--!strict

local EconomyConfig = {
	StartingCash = 0,
	DefaultStockSlots = 3,
	AllowedDevStockSlots = table.freeze({ 3, 5, 7, 10 }),
	MaxStockSlots = 10,

	-- Change these Player attributes on the SERVER while testing. No code edits needed.
	StockSlotCapacityAttribute = "StockSlotCapacity",
	SaleSpeedAttribute = "DevSaleSpeedMultiplier",
	DefaultSaleSpeedMultiplier = 1,
	MinSaleSpeedMultiplier = 0.1,
	MaxSaleSpeedMultiplier = 30,

	-- Delivery review is temporary server state only in M3. M4 will persist Cash/listings.
	Review = table.freeze({
		ActionCooldownSeconds = 0.08,
	}),

	-- Per-item economics deliberately differ a little so Stock is not simply one
	-- identical multiplier/timer applied to every object. Values are prototype tuning.
	Items = table.freeze({
		Box = table.freeze({ StockMultiplier = 1.30, BaseSaleDuration = 20 }),
		Microwave = table.freeze({ StockMultiplier = 1.38, BaseSaleDuration = 30 }),
		Lamp = table.freeze({ StockMultiplier = 1.48, BaseSaleDuration = 38 }),
		Chair = table.freeze({ StockMultiplier = 1.34, BaseSaleDuration = 42 }),
		Tire = table.freeze({ StockMultiplier = 1.50, BaseSaleDuration = 32 }),
		TV = table.freeze({ StockMultiplier = 1.45, BaseSaleDuration = 50 }),
		Couch = table.freeze({ StockMultiplier = 1.40, BaseSaleDuration = 65 }),
		Safe = table.freeze({ StockMultiplier = 1.55, BaseSaleDuration = 75 }),
	}),
}

return table.freeze(EconomyConfig)
