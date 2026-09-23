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

	-- M4.2 final passive-economy test curve.
	--
	-- Important: current SELL values are intentionally preserved from M4/M4.1 so
	-- this pass measures KEEP attractiveness without moving the already-measured
	-- active-income baseline. EconomyService/ItemConfig derive SELL from
	-- PassivePerMinute * TargetBreakEvenMinutes, so the decimal break-even values
	-- below are chosen to preserve those SELL values exactly.
	--
	-- M4.2 also records a relative EconomicTier and neutral future multiplier
	-- placeholders centrally. M5 can extend these into section/rarity economics
	-- without scattering economic constants into gameplay scripts.
	Items = table.freeze({
		Box = table.freeze({
			PassivePerMinute = 400,
			TargetBreakEvenMinutes = 2.25, -- SELL $900
			EconomicTier = "Weak",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
		Lamp = table.freeze({
			PassivePerMinute = 500,
			TargetBreakEvenMinutes = 3.36, -- SELL $1,680
			EconomicTier = "Weak",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
		Microwave = table.freeze({
			PassivePerMinute = 650,
			TargetBreakEvenMinutes = 224 / 65, -- SELL $2,240
			EconomicTier = "Early",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
		Tire = table.freeze({
			PassivePerMinute = 850,
			TargetBreakEvenMinutes = 72 / 17, -- SELL $3,600
			EconomicTier = "Early",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
		Chair = table.freeze({
			PassivePerMinute = 1000,
			TargetBreakEvenMinutes = 4.8, -- SELL $4,800
			EconomicTier = "Early",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
		TV = table.freeze({
			PassivePerMinute = 1300,
			TargetBreakEvenMinutes = 90 / 13, -- SELL $9,000
			EconomicTier = "Strong",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
		Couch = table.freeze({
			PassivePerMinute = 1700,
			TargetBreakEvenMinutes = 168 / 17, -- SELL $16,800
			EconomicTier = "Strong",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
		Safe = table.freeze({
			PassivePerMinute = 2000,
			TargetBreakEvenMinutes = 12, -- SELL $24,000
			EconomicTier = "Exceptional",
			FutureRarityMultiplier = 1,
			FutureSectionMultiplier = 1,
		}),
	}),

	-- Architectural headroom only; these are not M5 rarity assignments.
	ProgressionBands = table.freeze({
		BeginnerPassivePerMinute = Vector2.new(400, 1_300),
		EarlyPassivePerMinute = Vector2.new(1_300, 20_000),
		EstablishedPassivePerMinute = Vector2.new(20_000, 500_000),
		LatePassivePerMinute = Vector2.new(500_000, 10_000_000),
	}),
}

return table.freeze(EconomyConfig)
