--!strict

return table.freeze({
	SchemaVersion = 1,
	-- Intentionally keep the existing M5B.1/M5C test namespace through M6A.2.
	-- The 15-section Collection expansion is additive: the six persistent section
	-- IDs and item IDs remain valid, while nine new section tables sanitize in as
	-- empty. This lets the old-save regression test exercise real migration rather
	-- than hiding compatibility behind another DataStore reset.
	DataStoreName = "OneTripPlayerData_M5B_1HandlingTest_v1",
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
