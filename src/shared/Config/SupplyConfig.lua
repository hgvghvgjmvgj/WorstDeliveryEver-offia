--!strict

-- M4.1/M4.2 warehouse supply tuning. This stays separate from warehouse
-- geometry so future rarity/section systems can evolve supply without
-- rewriting the approved V2 map.
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

	-- Current value bands use immediate SELL value. M5 can replace/extend this
	-- with section baseline + rarity without changing the controller API.
	-- Playtest feedback: original 15-30 / 30-60 / 45-90 windows felt good but
	-- just slightly slow, so each band is shortened by about four seconds.
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

	-- M4.2 opportunity-economy correction. These are warehouse-wide simultaneous
	-- availability budgets, NOT rarity tiers. A healthy solo warehouse still has
	-- 48 visible objects, but premium substitutes cannot fill every aisle at once.
	-- Budgets scale only modestly for 12 players so premium finds retain competition.
	PremiumInventory = table.freeze({
		TV = table.freeze({
			SoloCap = 4,
			FullServerCap = 6,
			MinReplacementSeconds = 35,
			MaxReplacementSeconds = 55,
		}),
		Couch = table.freeze({
			SoloCap = 2,
			FullServerCap = 3,
			MinReplacementSeconds = 55,
			MaxReplacementSeconds = 80,
		}),
		Safe = table.freeze({
			SoloCap = 1,
			FullServerCap = 2,
			MinReplacementSeconds = 70,
			MaxReplacementSeconds = 105,
		}),
	}),

	-- If the underlying sector controller proposes a premium item while its
	-- warehouse-wide budget/gate is unavailable, the visible slot is converted
	-- into a believable lower-value substitute instead of leaving the map empty.
	PremiumFallbacksByDepth = table.freeze({
		[1] = table.freeze({ "Box", "Lamp", "Microwave" }),
		[2] = table.freeze({ "Chair", "Tire", "Microwave", "Lamp" }),
		[3] = table.freeze({ "Chair", "Tire", "Microwave" }),
	}),

	-- The item just removed from a location is intentionally unlikely to be
	-- selected when that vacancy eventually refills.
	SameItemAtSameSpawnWeight = 0.06,

	-- When a section is badly depleted, ordinary/mid goods receive recovery
	-- pressure. Premium objects are not used as emergency filler.
	SevereDepletionOrdinaryWeightMultiplier = 1.60,
	SevereDepletionStrongWeightMultiplier = 1.15,
	SevereDepletionHighWeightMultiplier = 0.15,

	-- Debug telemetry is stored as attributes on OneTripPrototype. Set
	-- SupplyDebugPrintEnabled=true on that folder during a Studio run for a
	-- concise periodic server summary; it is quiet by default.
	TelemetrySummarySeconds = 30,
})
