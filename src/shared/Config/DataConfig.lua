--!strict

return table.freeze({
	SchemaVersion = 1,
	-- Keep the existing M4.2 test namespace during M5B so persistence/legacy
	-- Stock compatibility can be validated instead of hiding migration problems.
	DataStoreName = "OneTripPlayerData_M4_2PassiveTest_v1",
	KeyPrefix = "player_",

	AutosaveSeconds = 60,
	SaveDebounceSeconds = 2.0,
	MaxAttempts = 4,
	RetryBaseSeconds = 1.0,
	SessionLockTimeoutSeconds = 180,
	BindToCloseTimeoutSeconds = 25,

	-- M5B produces much larger passive values. Until the wider M5 progression
	-- economy exists, cap offline accrual to five minutes of live Stock output.
	-- This keeps persistence testable without one reconnect skipping the current
	-- finite upgrade tree. Revisit when M5 progression sinks are finalized.
	OfflineEarningsCapSeconds = 5 * 60,
	MaximumTrustedElapsedSeconds = 30 * 24 * 60 * 60,

	FailOpenInStudio = true,

	ProfileLoadedAttribute = "ProfileLoaded",
	PersistenceStatusAttribute = "PersistenceStatus",
	SchemaVersionAttribute = "DataSchemaVersion",
	OfflineEarningsAttribute = "OfflineEarnings",
})
