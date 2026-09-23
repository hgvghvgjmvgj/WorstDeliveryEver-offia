--!strict

return table.freeze({
	SchemaVersion = 1,
	-- Keep the M5B.1 namespace for M5C so real pre-Collection profiles exercise
	-- additive migration/backfill instead of being hidden behind another reset.
	-- Collection is optional/sanitized data, so no breaking schema bump is needed.
	DataStoreName = "OneTripPlayerData_M5B_1HandlingTest_v1",
	KeyPrefix = "player_",

	AutosaveSeconds = 60,
	SaveDebounceSeconds = 2.0,
	MaxAttempts = 4,
	RetryBaseSeconds = 1.0,
	SessionLockTimeoutSeconds = 180,
	BindToCloseTimeoutSeconds = 25,

	-- M5B produces much larger passive values. Until the wider M5 progression
	-- economy exists, cap offline accrual to five minutes of live Stock output.
	OfflineEarningsCapSeconds = 5 * 60,
	MaximumTrustedElapsedSeconds = 30 * 24 * 60 * 60,

	FailOpenInStudio = true,

	ProfileLoadedAttribute = "ProfileLoaded",
	PersistenceStatusAttribute = "PersistenceStatus",
	SchemaVersionAttribute = "DataSchemaVersion",
	OfflineEarningsAttribute = "OfflineEarnings",
})
