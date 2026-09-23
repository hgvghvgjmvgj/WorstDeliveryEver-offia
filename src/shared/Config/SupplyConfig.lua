--!strict

-- Warehouse supply tuning. Geometry stays in WarehouseConfig so supply,
-- depletion, and later rarity work can evolve without rewriting the map.
return table.freeze({
	FullServerPlayers = 12,

	-- A healthy warehouse starts visibly stocked. Population can rise with
	-- player count, but replenishment remains much slower than consumption.
	InitialPopulationPerSector = table.freeze({
		Solo = 12,
		FullServer = 16,
	}),

	SupplyTickSeconds = 4.0,
	RestocksPerTick = table.freeze({
		Solo = 1,
		FullServer = 5,
	}),
	SevereDepletionBonusRestocks = 1,

	-- Full servers get somewhat shorter effective vacancy windows, but never
	-- twelve-times-fast restocks. This preserves competition and depletion.
	FullServerCooldownScale = 0.65,

	Health = table.freeze({
		HealthyRatio = 0.80,
		ReducedRatio = 0.55,
		LowRatio = 0.30,
	}),

	-- Value bands still drive vacancy pacing underneath M5 rarity. They classify
	-- the final picked-up ItemId when a slot becomes vacant. Refill selection is
	-- currently layered with the M5 transform service and should be unified in a
	-- later supply-architecture cleanup.
	ValueBands = table.freeze({
		Ordinary = table.freeze({
			MaxSellValue = 4_999,
			MinVacancySeconds = 11,
			MaxVacancySeconds = 26,
			SelectionWeight = 1.00,
		}),
		Strong = table.freeze({
			MaxSellValue = 11_999,
			MinVacancySeconds = 26,
			MaxVacancySeconds = 56,
			SelectionWeight = 0.55,
		}),
		High = table.freeze({
			MaxSellValue = math.huge,
			MinVacancySeconds = 41,
			MaxVacancySeconds = 86,
			SelectionWeight = 0.22,
		}),
	}),

	-- The item just removed from a location is intentionally unlikely to be
	-- selected when that vacancy eventually refills.
	SameItemAtSameSpawnWeight = 0.06,

	-- When a section is badly depleted, ordinary/mid goods receive recovery
	-- pressure. High-value objects are not used as emergency filler.
	SevereDepletionOrdinaryWeightMultiplier = 1.60,
	SevereDepletionStrongWeightMultiplier = 1.15,
	SevereDepletionHighWeightMultiplier = 0.15,

	-- Debug telemetry is stored as attributes on OneTripPrototype. Set
	-- SupplyDebugPrintEnabled=true on that folder during a Studio run for a
	-- concise periodic server summary; it is quiet by default.
	TelemetrySummarySeconds = 30,
})
