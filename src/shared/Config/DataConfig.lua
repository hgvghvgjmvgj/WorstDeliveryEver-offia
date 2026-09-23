--!strict

return table.freeze({
	SchemaVersion = 1,
	-- Separate temporary namespace so M4.2 starts with fresh Cash/upgrades/Stock
	-- and does not inherit persisted M4.1 Stock rates.
	DataStoreName = "OneTripPlayerData_M4_2PassiveTest_v1",
	KeyPrefix = "player_",

	AutosaveSeconds = 60,
	SaveDebounceSeconds = 2.0,
	MaxAttempts = 4,
	RetryBaseSeconds = 1.0,
	SessionLockTimeoutSeconds = 180,
	BindToCloseTimeoutSeconds = 25,

	-- M4.2 temporary offline sanity cap. Stronger passive Stock makes the former
	-- two-hour cap disproportionately large for the finite M4 test progression.
	-- Thirty minutes still makes returning rewarding without letting idle time
	-- replace a large amount of active warehouse play.
	OfflineEarningsCapSeconds = 30 * 60,
	MaximumTrustedElapsedSeconds = 30 * 24 * 60 * 60,

	-- Studio can still be playtested when API Services are disabled, but that
	-- session is explicitly marked temporary and must not be mistaken for a
	-- persistence pass.
	FailOpenInStudio = true,

	ProfileLoadedAttribute = "ProfileLoaded",
	PersistenceStatusAttribute = "PersistenceStatus",
	SchemaVersionAttribute = "DataSchemaVersion",
	OfflineEarningsAttribute = "OfflineEarnings",
})
