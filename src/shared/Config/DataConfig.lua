--!strict

return table.freeze({
	SchemaVersion = 1,
	-- Fresh M6A.2 test namespace. This resets current test progress without
	-- deleting the older M5B.1/M5C profile data, so we can still restore the
	-- previous namespace later if migration/regression testing is needed.
	DataStoreName = "OneTripPlayerData_M6A_2RunwayTest_v1",
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
