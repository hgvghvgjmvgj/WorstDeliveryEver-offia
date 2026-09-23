--!strict

return table.freeze({
	FootprintSize = Vector3.new(620, 1, 620),
	WallHeight = 30,
	CeilingClearance = 48,
	MainLaneWidth = 28,

	LoadingApron = table.freeze({
		Center = Vector3.new(0, 0.06, 245),
		Size = Vector3.new(600, 0.12, 105),
	}),

	Bay = table.freeze({
		Count = 12,
		StartX = -253,
		Spacing = 46,
		Z = 286,
		PadSize = Vector3.new(40, 0.35, 36),
		UnloadSize = Vector3.new(20, 0.25, 10),
		ProcessingSize = Vector3.new(25, 0.16, 12),

		SpawnOffset = CFrame.new(0, 2.9, -13.5),
		UnloadOffset = CFrame.new(0, 0.30, -8.0),
		ProcessingOffset = CFrame.new(0, 0.24, -7.8),
		VanOffset = CFrame.new(0, 2.5, 22.0),
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

	CrossAisles = table.freeze({
		table.freeze({ Name = "CROSS_AISLE_1", Z = 140, Width = 34 }),
		table.freeze({ Name = "CROSS_AISLE_2", Z = 15, Width = 36 }),
	}),

	Sector = table.freeze({
		Width = 116,
		FrontZ = 225,
		BackZ = -85,
		FreightLaneWidth = 30,
		ServiceLaneWidth = 17,
		RackOffsetX = 43,
		RackSize = Vector3.new(10, 17, 48),
	}),

	Sectors = table.freeze({
		General = table.freeze({
			DisplayName = "GENERAL GOODS",
			CenterX = -210,
			Color = Color3.fromRGB(76, 92, 104),
			Opportunities = table.freeze({
				table.freeze({ Name = "GEN_RECEIVING_A", Position = Vector3.new(-232, 0.18, 205), Depth = 1, ItemId = "Box", Kind = "ReceivingPallet" }),
				table.freeze({ Name = "GEN_RECEIVING_B", Position = Vector3.new(-188, 0.18, 178), Depth = 1, ItemId = "Lamp", Kind = "LoosePallet" }),
				table.freeze({ Name = "GEN_FRONT_RACK", Position = Vector3.new(-224, 0.18, 154), Depth = 1, ItemId = "Box", Kind = "RackBay" }),
				table.freeze({ Name = "GEN_MID_A", Position = Vector3.new(-190, 0.18, 116), Depth = 2, ItemId = "Chair", Kind = "RackBay" }),
				table.freeze({ Name = "GEN_MID_B", Position = Vector3.new(-232, 0.18, 82), Depth = 2, ItemId = "Microwave", Kind = "Staging" }),
				table.freeze({ Name = "GEN_MID_C", Position = Vector3.new(-190, 0.18, 48), Depth = 2, ItemId = "TV", Kind = "SideAisle" }),
				table.freeze({ Name = "GEN_DEEP_A", Position = Vector3.new(-230, 0.18, 4), Depth = 3, ItemId = "TV", Kind = "SecureRack" }),
				table.freeze({ Name = "GEN_DEEP_B", Position = Vector3.new(-188, 0.18, -31), Depth = 3, ItemId = "Couch", Kind = "DeepStaging" }),
				table.freeze({ Name = "GEN_DEEP_C", Position = Vector3.new(-226, 0.18, -66), Depth = 3, ItemId = "Safe", Kind = "SecureCage" }),
			}),
		}),

		Appliances = table.freeze({
			DisplayName = "APPLIANCES / ELECTRONICS",
			CenterX = -70,
			Color = Color3.fromRGB(70, 91, 116),
			Opportunities = table.freeze({
				table.freeze({ Name = "APP_FRONT_A", Position = Vector3.new(-92, 0.18, 204), Depth = 1, ItemId = "Microwave", Kind = "ReceivingPallet" }),
				table.freeze({ Name = "APP_FRONT_B", Position = Vector3.new(-48, 0.18, 178), Depth = 1, ItemId = "Box", Kind = "RackBay" }),
				table.freeze({ Name = "APP_FRONT_C", Position = Vector3.new(-84, 0.18, 154), Depth = 1, ItemId = "Microwave", Kind = "RackBay" }),
				table.freeze({ Name = "APP_MID_A", Position = Vector3.new(-50, 0.18, 116), Depth = 2, ItemId = "TV", Kind = "DisplayPallet" }),
				table.freeze({ Name = "APP_MID_B", Position = Vector3.new(-92, 0.18, 82), Depth = 2, ItemId = "TV", Kind = "RackBay" }),
				table.freeze({ Name = "APP_MID_C", Position = Vector3.new(-50, 0.18, 48), Depth = 2, ItemId = "Chair", Kind = "SideAisle" }),
				table.freeze({ Name = "APP_DEEP_A", Position = Vector3.new(-90, 0.18, 4), Depth = 3, ItemId = "TV", Kind = "SecureRack" }),
				table.freeze({ Name = "APP_DEEP_B", Position = Vector3.new(-48, 0.18, -31), Depth = 3, ItemId = "Safe", Kind = "SecureCage" }),
				table.freeze({ Name = "APP_DEEP_C", Position = Vector3.new(-86, 0.18, -66), Depth = 3, ItemId = "Couch", Kind = "DeepStaging" }),
			}),
		}),

		Furniture = table.freeze({
			DisplayName = "FURNITURE / OVERSIZED",
			CenterX = 70,
			Color = Color3.fromRGB(104, 83, 68),
			Opportunities = table.freeze({
				table.freeze({ Name = "FUR_FRONT_A", Position = Vector3.new(48, 0.18, 204), Depth = 1, ItemId = "Chair", Kind = "FloorStaging" }),
				table.freeze({ Name = "FUR_FRONT_B", Position = Vector3.new(92, 0.18, 178), Depth = 1, ItemId = "Lamp", Kind = "LoosePallet" }),
				table.freeze({ Name = "FUR_FRONT_C", Position = Vector3.new(56, 0.18, 154), Depth = 1, ItemId = "Chair", Kind = "FloorStaging" }),
				table.freeze({ Name = "FUR_MID_A", Position = Vector3.new(90, 0.18, 116), Depth = 2, ItemId = "Couch", Kind = "OversizedZone" }),
				table.freeze({ Name = "FUR_MID_B", Position = Vector3.new(48, 0.18, 82), Depth = 2, ItemId = "Chair", Kind = "SideAisle" }),
				table.freeze({ Name = "FUR_MID_C", Position = Vector3.new(90, 0.18, 48), Depth = 2, ItemId = "Couch", Kind = "OversizedZone" }),
				table.freeze({ Name = "FUR_DEEP_A", Position = Vector3.new(50, 0.18, 4), Depth = 3, ItemId = "Couch", Kind = "DeepStaging" }),
				table.freeze({ Name = "FUR_DEEP_B", Position = Vector3.new(92, 0.18, -31), Depth = 3, ItemId = "TV", Kind = "SecureRack" }),
				table.freeze({ Name = "FUR_DEEP_C", Position = Vector3.new(54, 0.18, -66), Depth = 3, ItemId = "Safe", Kind = "SecureCage" }),
			}),
		}),

		Industrial = table.freeze({
			DisplayName = "INDUSTRIAL / HEAVY",
			CenterX = 210,
			Color = Color3.fromRGB(91, 91, 76),
			Opportunities = table.freeze({
				table.freeze({ Name = "IND_FRONT_A", Position = Vector3.new(188, 0.18, 204), Depth = 1, ItemId = "Tire", Kind = "FloorStaging" }),
				table.freeze({ Name = "IND_FRONT_B", Position = Vector3.new(232, 0.18, 178), Depth = 1, ItemId = "Box", Kind = "ReceivingPallet" }),
				table.freeze({ Name = "IND_FRONT_C", Position = Vector3.new(196, 0.18, 154), Depth = 1, ItemId = "Tire", Kind = "RackBay" }),
				table.freeze({ Name = "IND_MID_A", Position = Vector3.new(230, 0.18, 116), Depth = 2, ItemId = "Safe", Kind = "HeavyStaging" }),
				table.freeze({ Name = "IND_MID_B", Position = Vector3.new(188, 0.18, 82), Depth = 2, ItemId = "Tire", Kind = "RackBay" }),
				table.freeze({ Name = "IND_MID_C", Position = Vector3.new(230, 0.18, 48), Depth = 2, ItemId = "TV", Kind = "SideAisle" }),
				table.freeze({ Name = "IND_DEEP_A", Position = Vector3.new(190, 0.18, 4), Depth = 3, ItemId = "Safe", Kind = "SecureCage" }),
				table.freeze({ Name = "IND_DEEP_B", Position = Vector3.new(232, 0.18, -31), Depth = 3, ItemId = "Couch", Kind = "HeavyStaging" }),
				table.freeze({ Name = "IND_DEEP_C", Position = Vector3.new(194, 0.18, -66), Depth = 3, ItemId = "Safe", Kind = "SecureCage" }),
			}),
		}),
	}),

	RackBands = table.freeze({ 190, 105, 42, -45 }),

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
		CFrame.new(-210, 0.5, -145),
		CFrame.new(-70, 0.5, -145),
		CFrame.new(70, 0.5, -145),
		CFrame.new(210, 0.5, -145),
		CFrame.new(0, 0.5, -235),
	}),

	FallbackSpawnPosition = Vector3.new(0, 0.6, 270),
})
