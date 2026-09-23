--!strict

return table.freeze({
	SchemaVersion = 1,
	-- Temporary fresh namespace for the M5B.1 starter sequence-break and
	-- handling-progression tests. Older M4/M5 test data remains untouched.
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
