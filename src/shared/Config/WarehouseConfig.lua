--!strict

return table.freeze({
	FootprintSize = Vector3.new(500, 1, 500),
	WallHeight = 28,
	CeilingClearance = 46,
	MainLaneWidth = 24,

	Bay = table.freeze({
		Count = 12,
		Radius = 205,
		PadSize = Vector3.new(36, 0.35, 34),
		UnloadSize = Vector3.new(19, 0.25, 10),
		ProcessingSize = Vector3.new(23, 0.16, 12),

		SpawnOffset = CFrame.new(0, 2.9, -12.5),
		UnloadOffset = CFrame.new(0, 0.30, -7.0),
		ProcessingOffset = CFrame.new(0, 0.24, -6.8),
		VanOffset = CFrame.new(0, 2.5, 23.0),
		OwnerLabelOffset = CFrame.new(0, 4.4, 15.5),

		InitialStockSlots = 3,
		MaxPlannedStockSlots = 10,
		StockSlotSize = Vector3.new(7.5, 0.18, 5.5),
		StockSlotPositions = table.freeze({
			CFrame.new(-11.5, 0.30, 2.0),
			CFrame.new(0, 0.30, 4.5),
			CFrame.new(11.5, 0.30, 2.0),

			CFrame.new(-11.5, 0.30, 8.5),
			CFrame.new(11.5, 0.30, 8.5),
			CFrame.new(-7.8, 0.30, 13.5),
			CFrame.new(0, 0.30, 13.5),
			CFrame.new(7.8, 0.30, 13.5),
			CFrame.new(-15.0, 0.30, 13.5),
			CFrame.new(15.0, 0.30, 13.5),
		}),
	}),

	Zones = table.freeze({
		Near = table.freeze({
			Name = "NEAR / GENERAL GOODS",
			DisplayName = "NEAR GOODS",
			FloorSize = Vector3.new(360, 0.10, 360),
			FloorColor = Color3.fromRGB(78, 87, 98),
			SignRadius = 152,
			Clusters = table.freeze({
				table.freeze({
					Name = "NEAR_N",
					Center = Vector3.new(0, 0.16, -135),
					Items = table.freeze({ "Box", "Microwave" }),
				}),
				table.freeze({
					Name = "NEAR_NE",
					Center = Vector3.new(95, 0.16, -95),
					Items = table.freeze({ "Box", "Lamp" }),
				}),
				table.freeze({
					Name = "NEAR_E",
					Center = Vector3.new(135, 0.16, 0),
					Items = table.freeze({ "Box", "Chair" }),
				}),
				table.freeze({
					Name = "NEAR_SE",
					Center = Vector3.new(95, 0.16, 95),
					Items = table.freeze({ "Microwave", "TV" }),
				}),
				table.freeze({
					Name = "NEAR_S",
					Center = Vector3.new(0, 0.16, 135),
					Items = table.freeze({ "Box", "Microwave" }),
				}),
				table.freeze({
					Name = "NEAR_SW",
					Center = Vector3.new(-95, 0.16, 95),
					Items = table.freeze({ "Box", "Lamp" }),
				}),
				table.freeze({
					Name = "NEAR_W",
					Center = Vector3.new(-135, 0.16, 0),
					Items = table.freeze({ "Chair", "Microwave" }),
				}),
				table.freeze({
					Name = "NEAR_NW",
					Center = Vector3.new(-95, 0.16, -95),
					Items = table.freeze({ "Box", "TV" }),
				}),
			}),
		}),

		Mid = table.freeze({
			Name = "MID WAREHOUSE",
			DisplayName = "MID WAREHOUSE",
			FloorSize = Vector3.new(210, 0.12, 210),
			FloorColor = Color3.fromRGB(87, 79, 70),
			SignRadius = 94,
			Clusters = table.freeze({
				table.freeze({
					Name = "MID_N",
					Center = Vector3.new(0, 0.20, -85),
					Items = table.freeze({ "TV", "Chair", "Couch" }),
				}),
				table.freeze({
					Name = "MID_E",
					Center = Vector3.new(85, 0.20, 0),
					Items = table.freeze({ "TV", "Safe", "Chair" }),
				}),
				table.freeze({
					Name = "MID_S",
					Center = Vector3.new(0, 0.20, 85),
					Items = table.freeze({ "Couch", "TV", "Lamp" }),
				}),
				table.freeze({
					Name = "MID_W",
					Center = Vector3.new(-85, 0.20, 0),
					Items = table.freeze({ "Chair", "Safe", "TV" }),
				}),
			}),
		}),

		Deep = table.freeze({
			Name = "DEEP / HIGH VALUE TEST",
			DisplayName = "DEEP GOODS",
			FloorSize = Vector3.new(82, 0.14, 82),
			FloorColor = Color3.fromRGB(76, 67, 89),
			SignRadius = 39,
			Clusters = table.freeze({
				table.freeze({
					Name = "DEEP_W",
					Center = Vector3.new(-18, 0.24, 0),
					Items = table.freeze({ "Safe", "Couch", "TV", "Safe" }),
				}),
				table.freeze({
					Name = "DEEP_E",
					Center = Vector3.new(18, 0.24, 0),
					Items = table.freeze({ "Couch", "Safe", "TV", "Safe" }),
				}),
			}),
		}),
	}),

	SpawnLayout = table.freeze({
		ClusterColumns = 2,
		SpacingX = 9.5,
		SpacingZ = 8.5,
	}),

	RestockSeconds = table.freeze({
		Box = 1.20,
		Microwave = 1.55,
		Lamp = 1.45,
		Chair = 1.70,
		Tire = 1.35,
		TV = 1.90,
		Couch = 2.25,
		Safe = 2.50,
	}),

	ExpectedAvailableAtFullServer = 36,

	ExpansionPoints = table.freeze({
		CFrame.new(0, 0.5, -54),
		CFrame.new(54, 0.5, 0),
		CFrame.new(0, 0.5, 54),
		CFrame.new(-54, 0.5, 0),
	}),

	FallbackSpawnPosition = Vector3.new(0, 0.6, -238),
})
