--!strict

return table.freeze({
	GameName = "ONE TRIP",
	PrototypeVersion = "M1",

	MaxPlayersTarget = 12,

	World = table.freeze({
		FootprintSize = Vector3.new(150, 1, 150),
		ItemFloorSize = Vector3.new(70, 1, 54),
		ItemFloorCenter = Vector3.new(0, 0.06, 6),
		UnloadCenter = Vector3.new(0, 0.15, -50),
		UnloadSize = Vector3.new(28, 0.3, 12),
		SpawnPosition = Vector3.new(0, 0.6, -65),
	}),

	Prototype = table.freeze({
		StockRespawnSeconds = 1.75,
		DroppedItemLifetimeSeconds = 20,
	}),
})
