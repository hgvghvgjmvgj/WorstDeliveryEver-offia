--!strict

return table.freeze({
	GameName = "ONE TRIP",
	PrototypeVersion = "M2",

	MaxPlayersTarget = 12,

	World = table.freeze({
		FootprintSize = Vector3.new(216, 1, 216),
		ItemFloorSize = Vector3.new(116, 1, 116),
		ItemFloorCenter = Vector3.new(0, 0.06, 0),

		BayCount = 12,
		BayRadius = 88,
		BayPadSize = Vector3.new(24, 0.35, 18),
		BayUnloadSize = Vector3.new(17, 0.25, 9),
		BaySpawnOffset = CFrame.new(0, 2.9, -6.0),
		BayUnloadOffset = CFrame.new(0, 0.30, -1.5),
		BayVanOffset = CFrame.new(0, 2.4, 6.2),

		FallbackSpawnPosition = Vector3.new(0, 0.6, -99),
	}),

	Items = table.freeze({
		RestockSeconds = table.freeze({
			Box = 1.2,
			Microwave = 1.55,
			Lamp = 1.45,
			Chair = 1.70,
			Tire = 1.35,
			TV = 1.90,
			Couch = 2.25,
			Safe = 2.50,
		}),

		Clusters = table.freeze({
			table.freeze({
				Name = "GENERAL",
				Center = Vector3.new(-28, 0.16, -26),
				Items = table.freeze({
					"Box", "Box", "Tire", "Microwave",
					"Box", "Tire", "Box", "Microwave",
				}),
			}),
			table.freeze({
				Name = "ELECTRONICS",
				Center = Vector3.new(29, 0.16, -26),
				Items = table.freeze({
					"Microwave", "TV", "TV", "Microwave",
					"TV", "Box", "Microwave", "TV",
				}),
			}),
			table.freeze({
				Name = "FURNITURE",
				Center = Vector3.new(-28, 0.16, 28),
				Items = table.freeze({
					"Chair", "Couch", "Lamp", "Chair",
					"Couch", "Lamp", "Chair", "Couch",
				}),
			}),
			table.freeze({
				Name = "HEAVY",
				Center = Vector3.new(29, 0.16, 28),
				Items = table.freeze({
					"Safe", "Safe", "Tire", "Safe",
					"Couch", "Tire", "Safe", "TV",
				}),
			}),
		}),

		ClusterColumns = 4,
		ClusterSpacingX = 10.5,
		ClusterSpacingZ = 11.0,
		ExpectedAvailableAtFullServer = 32,
	}),

	Prototype = table.freeze({
		DroppedItemLifetimeSeconds = 20,
	}),
})
