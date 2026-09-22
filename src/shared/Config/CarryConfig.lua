--!strict

return table.freeze({
	BaseWalkSpeed = 16,
	MinimumLoadedWalkSpeed = 9.5,

	Beginner = table.freeze({
		Strength = 7,
		ComfortBulk = 5,
		Control = 1.0,
	}),

	Veteran = table.freeze({
		Strength = 30,
		ComfortBulk = 20,
		Control = 2.6,
	}),

	DangerStates = table.freeze({
		Stable = 1,
		SlightWobble = 2,
		Unstable = 3,
		Dangerous = 4,
		NearCollapse = 5,
	}),

	-- Not a player-facing hard capacity. This is only a technical guardrail so a
	-- broken test cannot attach unlimited parts to one character.
	TechnicalMaxItems = 28,
})
