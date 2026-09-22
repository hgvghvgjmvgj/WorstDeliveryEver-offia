--!strict

return table.freeze({
	GameName = "ONE TRIP",
	PrototypeVersion = "M1.1",

	MaxPlayersTarget = 12,

	World = table.freeze({
		FootprintSize = Vector3.new(150, 1, 150),
		ItemFloorSize = Vector3.new(76, 1, 58),
		ItemFloorCenter = Vector3.new(0, 0.06, 5),
		UnloadCenter = Vector3.new(0, 0.15, -50),
		UnloadSize = Vector3.new(28, 0.3, 12),
		SpawnPosition = Vector3.new(0, 0.6, -65),

		TestItemSpawns = table.freeze({
			table.freeze({ ItemId = "Safe", Position = Vector3.new(-27, 0.16, 26) }),
			table.freeze({ ItemId = "TV", Position = Vector3.new(-10, 0.16, 25) }),
			table.freeze({ ItemId = "Couch", Position = Vector3.new(12, 0.16, 25) }),
			table.freeze({ ItemId = "Lamp", Position = Vector3.new(29, 0.16, 24) }),

			table.freeze({ ItemId = "Box", Position = Vector3.new(-30, 0.16, 10) }),
			table.freeze({ ItemId = "Microwave", Position = Vector3.new(-15, 0.16, 9) }),
			table.freeze({ ItemId = "Chair", Position = Vector3.new(0, 0.16, 10) }),
			table.freeze({ ItemId = "Tire", Position = Vector3.new(15, 0.16, 8) }),
			table.freeze({ ItemId = "Box", Position = Vector3.new(30, 0.16, 9) }),

			table.freeze({ ItemId = "Couch", Position = Vector3.new(-29, 0.16, -7) }),
			table.freeze({ ItemId = "TV", Position = Vector3.new(-12, 0.16, -5) }),
			table.freeze({ ItemId = "Microwave", Position = Vector3.new(5, 0.16, -6) }),
			table.freeze({ ItemId = "Chair", Position = Vector3.new(22, 0.16, -8) }),

			table.freeze({ ItemId = "Lamp", Position = Vector3.new(-17, 0.16, -17) }),
			table.freeze({ ItemId = "Box", Position = Vector3.new(-2, 0.16, -16) }),
			table.freeze({ ItemId = "Safe", Position = Vector3.new(23, 0.16, -18) }),
		}),
	}),

	Prototype = table.freeze({
		StockRespawnSeconds = 1.4,
		DroppedItemLifetimeSeconds = 20,
	}),
})
