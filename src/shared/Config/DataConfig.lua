--!strict

return table.freeze({
	SchemaVersion = 1,
	-- Fresh M6A.3 economy-test namespace. The prior M6A.2 runway-test data stays
	-- intact, but this balance pass must be measured from zero rather than with a
	-- rich developer profile or previously purchased upgrades.
	DataStoreName = "OneTripPlayerData_M6A_3EconomyTest_v1",
	KeyPrefix = "player_",

	AutosaveSeconds = 60,
	SaveDebounceSeconds = 2.0,
	MaxAttempts = 4,
	RetryBaseSeconds = 1.0,
	SessionLockTimeoutSeconds = 180,
	BindToCloseTimeoutSeconds = 25,

	OfflineEarningsCapSeconds = 5 * 60,
	MaximumTrustedElapsedSeconds = 30 * 24 * 60 * 60,

	FailOpenInStudio = true,

	ProfileLoadedAttribute = "ProfileLoaded",
	PersistenceStatusAttribute = "PersistenceStatus",
	SchemaVersionAttribute = "DataSchemaVersion",
	OfflineEarningsAttribute = "OfflineEarnings",
})
