--!strict

return table.freeze({
	SchemaVersion = 1,
	DataStoreName = "OneTripPlayerData_v1",
	KeyPrefix = "player_",

	AutosaveSeconds = 60,
	SaveDebounceSeconds = 2.0,
	MaxAttempts = 4,
	RetryBaseSeconds = 1.0,
	SessionLockTimeoutSeconds = 180,
	BindToCloseTimeoutSeconds = 25,

	-- Temporary M4 test value. Returning should feel rewarding without allowing
	-- a long absence to skip the active game.
	OfflineEarningsCapSeconds = 4 * 60 * 60,
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
