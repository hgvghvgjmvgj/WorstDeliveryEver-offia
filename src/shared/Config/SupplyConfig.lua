--!strict

-- Central warehouse supply tuning. M6A.2 expands from six to fifteen sections,
-- so the active population target is intentionally reduced rather than blindly
-- turning 15 × 16 into 240 active world cargo objects.
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

	ValueBands = table.freeze({
		Ordinary = table.freeze({ MaxSellValue = 4_999, MinVacancySeconds = 11, MaxVacancySeconds = 26, SelectionWeight = 1.00 }),
		Strong = table.freeze({ MaxSellValue = 11_999, MinVacancySeconds = 26, MaxVacancySeconds = 56, SelectionWeight = 0.55 }),
		High = table.freeze({ MaxSellValue = math.huge, MinVacancySeconds = 41, MaxVacancySeconds = 86, SelectionWeight = 0.22 }),
	}),

	SameItemAtSameSpawnWeight = 0.06,
	SevereDepletionOrdinaryWeightMultiplier = 1.60,
	SevereDepletionStrongWeightMultiplier = 1.15,
	SevereDepletionHighWeightMultiplier = 0.15,
	TelemetrySummarySeconds = 30,
})
