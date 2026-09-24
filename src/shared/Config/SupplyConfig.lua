--!strict

-- Central warehouse supply tuning. M6A.3 keeps the 15-section population model
-- but rebases absolute value bands for the corrected big-number economy. Rarity
-- service still owns Legendary+ warehouse caps/cooldowns; these bands only shape
-- how quickly a consumed spawn location becomes eligible again.
return table.freeze({
	FullServerPlayers = 12,

	-- 15 sections × 12 full-server target = ~180 active cargo when all sections
	-- are healthy. Every section still owns 16 possible marker positions, so
	-- visible opportunities can rotate without all markers being occupied.
	InitialPopulationPerSector = table.freeze({
		Solo = 8,
		FullServer = 12,
	}),

	SupplyTickSeconds = 4.0,
	RestocksPerTick = table.freeze({
		Solo = 1,
		FullServer = 5,
	}),
	SevereDepletionBonusRestocks = 1,
	FullServerCooldownScale = 0.65,

	Health = table.freeze({
		HealthyRatio = 0.80,
		ReducedRatio = 0.55,
		LowRatio = 0.30,
	}),

	-- Previous 4,999 / 11,999 cutoffs came from the small M4 economy and made
	-- ordinary deep-section cargo behave like scarce premium cargo. These test
	-- bands preserve replenishment cadence under the 15-section value curve.
	ValueBands = table.freeze({
		Ordinary = table.freeze({ MaxSellValue = 149_999, MinVacancySeconds = 11, MaxVacancySeconds = 26, SelectionWeight = 1.00 }),
		Strong = table.freeze({ MaxSellValue = 399_999, MinVacancySeconds = 26, MaxVacancySeconds = 56, SelectionWeight = 0.55 }),
		High = table.freeze({ MaxSellValue = math.huge, MinVacancySeconds = 41, MaxVacancySeconds = 86, SelectionWeight = 0.22 }),
	}),

	SameItemAtSameSpawnWeight = 0.06,
	SevereDepletionOrdinaryWeightMultiplier = 1.60,
	SevereDepletionStrongWeightMultiplier = 1.15,
	SevereDepletionHighWeightMultiplier = 0.15,
	TelemetrySummarySeconds = 30,
})
