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

	-- M5B produces much larger passive values. Offline Stock remains rewarding,
	-- but earns at a reduced fraction of live passive and stops after 20 minutes.
	-- This is a test value, not a permanent live-service promise.
	OfflineEarningsCapSeconds = 20 * 60,
	OfflineEarningsMultiplier = 0.20,
	MaximumTrustedElapsedSeconds = 30 * 24 * 60 * 60,

	FailOpenInStudio = true,

	ProfileLoadedAttribute = "ProfileLoaded",
	PersistenceStatusAttribute = "PersistenceStatus",
	SchemaVersionAttribute = "DataSchemaVersion",
	OfflineEarningsAttribute = "OfflineEarnings",
})
