--!strict

return table.freeze({
	-- V2 uses the footprint as a real facility: long across the loading face and
	-- deep enough to create commitment without turning every run into dead travel.
	FootprintSize = Vector3.new(660, 1, 420),
	WallHeight = 32,
	CeilingClearance = 50,

	LoadingApron = table.freeze({
		Center = Vector3.new(0, 0.06, 135),
		Size = Vector3.new(640, 0.12, 70),
		FreightCrossingZ = 118,
	}),

	Bay = table.freeze({
		Count = 12,
		StartX = -275,
		Spacing = 50,
		Z = 178,
		PadSize = Vector3.new(44, 0.35, 34),
		UnloadSize = Vector3.new(20, 0.25, 10),
		ProcessingSize = Vector3.new(25, 0.16, 12),

		SpawnOffset = CFrame.new(0, 2.9, -13.5),
		UnloadOffset = CFrame.new(0, 0.30, -8.0),
		ProcessingOffset = CFrame.new(0, 0.24, -7.8),
		VanOffset = CFrame.new(0, 2.5, 20.0),
		OwnerLabelOffset = CFrame.new(0, 4.4, 14.5),

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

	-- Cross-aisles are major social/route-switching spaces, not tiny connectors.
	CrossAisles = table.freeze({
		table.freeze({ Name = "MID_CROSS_AISLE", Z = 18, Width = 30 }),
		table.freeze({ Name = "DEEP_CROSS_AISLE", Z = -92, Width = 34 }),
	}),

	Sector = table.freeze({
		FrontZ = 105,
		BackZ = -190,
		Width = 140,
		FreightLaneWidth = 30,
		ServiceLaneWidth = 18,
	}),

	-- Each sector intentionally uses a different structure recipe. The Structures
	-- table is graybox level-design data, not final art.
	Sectors = table.freeze({
		General = table.freeze({
			DisplayName = "GENERAL GOODS",
			CenterX = -240,
			Color = Color3.fromRGB(76, 92, 104),
			Style = "OpenRacks",
			Structures = table.freeze({
				table.freeze({ Name = "Rack_A", Kind = "Rack", Size = Vector3.new(12, 16, 46), Position = Vector3.new(-282, 8, 76) }),
				table.freeze({ Name = "Rack_B", Kind = "Rack", Size = Vector3.new(12, 16, 42), Position = Vector3.new(-198, 8, 50) }),
				table.freeze({ Name = "Rack_C", Kind = "Rack", Size = Vector3.new(12, 16, 44), Position = Vector3.new(-282, 8, -34) }),
				table.freeze({ Name = "Rack_D", Kind = "Rack", Size = Vector3.new(12, 16, 42), Position = Vector3.new(-198, 8, -142) }),
				table.freeze({ Name = "Pallet_A", Kind = "Low", Size = Vector3.new(24, 2, 18), Position = Vector3.new(-202, 1, 94) }),
				table.freeze({ Name = "Pallet_B", Kind = "Low", Size = Vector3.new(28, 2, 18), Position = Vector3.new(-278, 1, -118) }),
			}),
			ServiceRoute = table.freeze({
				Vector3.new(-206, 0, 98),
				Vector3.new(-286, 0, 52),
				Vector3.new(-205, 0, 3),
				Vector3.new(-282, 0, -70),
				Vector3.new(-210, 0, -176),
			}),
			Opportunities = table.freeze({
				table.freeze({ Name = "GEN_NEAR_A", Position = Vector3.new(-252, 0.18, 88), Depth = 1, ItemId = "Box", Kind = "ReceivingPallet" }),
				table.freeze({ Name = "GEN_NEAR_B", Position = Vector3.new(-207, 0.18, 72), Depth = 1, ItemId = "Lamp", Kind = "RackBay" }),
				table.freeze({ Name = "GEN_NEAR_C", Position = Vector3.new(-274, 0.18, 48), Depth = 1, ItemId = "Box", Kind = "SidePallet" }),
				table.freeze({ Name = "GEN_MID_A", Position = Vector3.new(-222, 0.18, 5), Depth = 2, ItemId = "Microwave", Kind = "RackBay" }),
				table.freeze({ Name = "GEN_MID_B", Position = Vector3.new(-273, 0.18, -32), Depth = 2, ItemId = "Chair", Kind = "SideAisle" }),
				table.freeze({ Name = "GEN_MID_C", Position = Vector3.new(-210, 0.18, -68), Depth = 2, ItemId = "TV", Kind = "PalletBay" }),
				table.freeze({ Name = "GEN_DEEP_A", Position = Vector3.new(-267, 0.18, -118), Depth = 3, ItemId = "TV", Kind = "DeepRack" }),
				table.freeze({ Name = "GEN_DEEP_B", Position = Vector3.new(-215, 0.18, -151), Depth = 3, ItemId = "Couch", Kind = "DeepStaging" }),
				table.freeze({ Name = "GEN_DEEP_C", Position = Vector3.new(-258, 0.18, -180), Depth = 3, ItemId = "Safe", Kind = "SecurePallet" }),
			}),
		}),

		Appliances = table.freeze({
			DisplayName = "APPLIANCES / ELECTRONICS",
			CenterX = -80,
			Color = Color3.fromRGB(70, 91, 116),
			Style = "StorageBays",
			Structures = table.freeze({
				table.freeze({ Name = "Bay_A", Kind = "Block", Size = Vector3.new(30, 11, 30), Position = Vector3.new(-124, 5.5, 72) }),
				table.freeze({ Name = "Bay_B", Kind = "Block", Size = Vector3.new(26, 11, 34), Position = Vector3.new(-38, 5.5, 38) }),
				table.freeze({ Name = "Bay_C", Kind = "Block", Size = Vector3.new(30, 11, 36), Position = Vector3.new(-121, 5.5, -41) }),
				table.freeze({ Name = "Bay_D", Kind = "Block", Size = Vector3.new(28, 11, 38), Position = Vector3.new(-39, 5.5, -133) }),
				table.freeze({ Name = "Display_A", Kind = "Low", Size = Vector3.new(32, 1.5, 18), Position = Vector3.new(-48, 0.75, 91) }),
				table.freeze({ Name = "Display_B", Kind = "Low", Size = Vector3.new(34, 1.5, 18), Position = Vector3.new(-111, 0.75, -106) }),
			}),
			ServiceRoute = table.freeze({
				Vector3.new(-42, 0, 98),
				Vector3.new(-122, 0, 58),
				Vector3.new(-43, 0, 10),
				Vector3.new(-118, 0, -61),
				Vector3.new(-48, 0, -176),
			}),
			Opportunities = table.freeze({
				table.freeze({ Name = "APP_NEAR_A", Position = Vector3.new(-91, 0.18, 91), Depth = 1, ItemId = "Microwave", Kind = "DisplayBay" }),
				table.freeze({ Name = "APP_NEAR_B", Position = Vector3.new(-45, 0.18, 68), Depth = 1, ItemId = "Box", Kind = "ReceivingPallet" }),
				table.freeze({ Name = "APP_NEAR_C", Position = Vector3.new(-115, 0.18, 43), Depth = 1, ItemId = "Microwave", Kind = "StorageBay" }),
				table.freeze({ Name = "APP_MID_A", Position = Vector3.new(-49, 0.18, 5), Depth = 2, ItemId = "TV", Kind = "DisplayBay" }),
				table.freeze({ Name = "APP_MID_B", Position = Vector3.new(-112, 0.18, -37), Depth = 2, ItemId = "TV", Kind = "StorageBay" }),
				table.freeze({ Name = "APP_MID_C", Position = Vector3.new(-46, 0.18, -67), Depth = 2, ItemId = "Chair", Kind = "SideBay" }),
				table.freeze({ Name = "APP_DEEP_A", Position = Vector3.new(-111, 0.18, -121), Depth = 3, ItemId = "TV", Kind = "SecureElectronics" }),
				table.freeze({ Name = "APP_DEEP_B", Position = Vector3.new(-48, 0.18, -150), Depth = 3, ItemId = "Safe", Kind = "SecureBay" }),
				table.freeze({ Name = "APP_DEEP_C", Position = Vector3.new(-97, 0.18, -181), Depth = 3, ItemId = "Couch", Kind = "DeepStaging" }),
			}),
		}),

		Furniture = table.freeze({
			DisplayName = "FURNITURE / OVERSIZED",
			CenterX = 80,
			Color = Color3.fromRGB(104, 83, 68),
			Style = "OpenStaging",
			Structures = table.freeze({
				table.freeze({ Name = "Stage_A", Kind = "Staging", Size = Vector3.new(44, 0.5, 34), Position = Vector3.new(37, 0.25, 75) }),
				table.freeze({ Name = "Stage_B", Kind = "Staging", Size = Vector3.new(40, 0.5, 42), Position = Vector3.new(121, 0.25, 25) }),
				table.freeze({ Name = "Stage_C", Kind = "Staging", Size = Vector3.new(46, 0.5, 38), Position = Vector3.new(37, 0.25, -58) }),
				table.freeze({ Name = "Divider_A", Kind = "Divider", Size = Vector3.new(5, 10, 45), Position = Vector3.new(124, 5, -119) }),
				table.freeze({ Name = "Stage_D", Kind = "Staging", Size = Vector3.new(42, 0.5, 32), Position = Vector3.new(43, 0.25, -151) }),
			}),
			ServiceRoute = table.freeze({
				Vector3.new(122, 0, 98),
				Vector3.new(43, 0, 70),
				Vector3.new(120, 0, 6),
				Vector3.new(45, 0, -54),
				Vector3.new(112, 0, -176),
			}),
			Opportunities = table.freeze({
				table.freeze({ Name = "FUR_NEAR_A", Position = Vector3.new(65, 0.18, 91), Depth = 1, ItemId = "Chair", Kind = "FrontDisplay" }),
				table.freeze({ Name = "FUR_NEAR_B", Position = Vector3.new(115, 0.18, 68), Depth = 1, ItemId = "Lamp", Kind = "OpenStaging" }),
				table.freeze({ Name = "FUR_NEAR_C", Position = Vector3.new(44, 0.18, 42), Depth = 1, ItemId = "Chair", Kind = "SideDisplay" }),
				table.freeze({ Name = "FUR_MID_A", Position = Vector3.new(112, 0.18, 5), Depth = 2, ItemId = "Couch", Kind = "OversizedStaging" }),
				table.freeze({ Name = "FUR_MID_B", Position = Vector3.new(48, 0.18, -35), Depth = 2, ItemId = "Chair", Kind = "SideStaging" }),
				table.freeze({ Name = "FUR_MID_C", Position = Vector3.new(111, 0.18, -68), Depth = 2, ItemId = "Couch", Kind = "OversizedStaging" }),
				table.freeze({ Name = "FUR_DEEP_A", Position = Vector3.new(50, 0.18, -119), Depth = 3, ItemId = "Couch", Kind = "DeepDisplay" }),
				table.freeze({ Name = "FUR_DEEP_B", Position = Vector3.new(111, 0.18, -151), Depth = 3, ItemId = "TV", Kind = "SecureDisplay" }),
				table.freeze({ Name = "FUR_DEEP_C", Position = Vector3.new(62, 0.18, -181), Depth = 3, ItemId = "Safe", Kind = "SecureStaging" }),
			}),
		}),

		Industrial = table.freeze({
			DisplayName = "INDUSTRIAL / HEAVY",
			CenterX = 240,
			Color = Color3.fromRGB(91, 91, 76),
			Style = "HeavyCages",
			Structures = table.freeze({
				table.freeze({ Name = "HeavyPad_A", Kind = "Staging", Size = Vector3.new(38, 0.6, 30), Position = Vector3.new(198, 0.3, 80) }),
				table.freeze({ Name = "CageWall_A", Kind = "Cage", Size = Vector3.new(5, 13, 48), Position = Vector3.new(282, 6.5, 49) }),
				table.freeze({ Name = "HeavyPad_B", Kind = "Staging", Size = Vector3.new(42, 0.6, 32), Position = Vector3.new(281, 0.3, -28) }),
				table.freeze({ Name = "CageWall_B", Kind = "Cage", Size = Vector3.new(5, 13, 54), Position = Vector3.new(198, 6.5, -92) }),
				table.freeze({ Name = "HeavyPad_C", Kind = "Staging", Size = Vector3.new(42, 0.6, 34), Position = Vector3.new(279, 0.3, -154) }),
			}),
			ServiceRoute = table.freeze({
				Vector3.new(201, 0, 98),
				Vector3.new(281, 0, 58),
				Vector3.new(204, 0, 6),
				Vector3.new(282, 0, -57),
				Vector3.new(208, 0, -176),
			}),
			Opportunities = table.freeze({
				table.freeze({ Name = "IND_NEAR_A", Position = Vector3.new(224, 0.18, 91), Depth = 1, ItemId = "Tire", Kind = "HeavyPad" }),
				table.freeze({ Name = "IND_NEAR_B", Position = Vector3.new(278, 0.18, 68), Depth = 1, ItemId = "Box", Kind = "ReceivingPallet" }),
				table.freeze({ Name = "IND_NEAR_C", Position = Vector3.new(201, 0.18, 43), Depth = 1, ItemId = "Tire", Kind = "HeavyRack" }),
				table.freeze({ Name = "IND_MID_A", Position = Vector3.new(278, 0.18, 5), Depth = 2, ItemId = "Safe", Kind = "HeavyStaging" }),
				table.freeze({ Name = "IND_MID_B", Position = Vector3.new(207, 0.18, -38), Depth = 2, ItemId = "Tire", Kind = "CageBay" }),
				table.freeze({ Name = "IND_MID_C", Position = Vector3.new(277, 0.18, -68), Depth = 2, ItemId = "TV", Kind = "HeavyDisplay" }),
				table.freeze({ Name = "IND_DEEP_A", Position = Vector3.new(210, 0.18, -120), Depth = 3, ItemId = "Safe", Kind = "SecureCage" }),
				table.freeze({ Name = "IND_DEEP_B", Position = Vector3.new(279, 0.18, -151), Depth = 3, ItemId = "Couch", Kind = "HeavyStaging" }),
				table.freeze({ Name = "IND_DEEP_C", Position = Vector3.new(222, 0.18, -181), Depth = 3, ItemId = "Safe", Kind = "SecureCage" }),
			}),
		}),
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

	-- V2 leaves logical future connections at the deep wall and both side edges.
	ExpansionPoints = table.freeze({
		CFrame.new(-240, 0.5, -202),
		CFrame.new(-80, 0.5, -202),
		CFrame.new(80, 0.5, -202),
		CFrame.new(240, 0.5, -202),
		CFrame.new(-320, 0.5, -92),
		CFrame.new(320, 0.5, -92),
	}),

	FallbackSpawnPosition = Vector3.new(0, 0.6, 154),
})
