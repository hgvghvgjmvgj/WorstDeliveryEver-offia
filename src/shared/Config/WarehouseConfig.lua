--!strict

local function frozen<T>(value: T): T
	return table.freeze(value)
end

local function structure(name: string, kind: string, size: Vector3, position: Vector3)
	return frozen({ Name = name, Kind = kind, Size = size, Position = position })
end

local OPPORTUNITY_SLOTS = frozen({
	frozen({ X = -270, Z = 30, Kind = "OuterStorage" }),
	frozen({ X = -110, Z = 28, Kind = "InnerStorage" }),
	frozen({ X = 110, Z = 30, Kind = "InnerStorage" }),
	frozen({ X = 270, Z = 26, Kind = "OuterStorage" }),
	frozen({ X = -250, Z = 8, Kind = "StagingPocket" }),
	frozen({ X = -88, Z = 6, Kind = "InnerBay" }),
	frozen({ X = 88, Z = 8, Kind = "InnerBay" }),
	frozen({ X = 250, Z = 4, Kind = "StagingPocket" }),
	frozen({ X = -270, Z = -18, Kind = "OuterStorage" }),
	frozen({ X = -112, Z = -20, Kind = "InnerStorage" }),
	frozen({ X = 112, Z = -18, Kind = "InnerStorage" }),
	frozen({ X = 270, Z = -22, Kind = "OuterStorage" }),
	frozen({ X = -232, Z = -36, Kind = "RearStaging" }),
	frozen({ X = -68, Z = -34, Kind = "RearInnerBay" }),
	frozen({ X = 68, Z = -36, Kind = "RearInnerBay" }),
	frozen({ X = 232, Z = -32, Kind = "RearStaging" }),
})

local function opportunities(prefix: string, centerZ: number, supplyDepth: number, itemIds: {string})
	local result = {}
	for index, slot in OPPORTUNITY_SLOTS do
		local itemId = itemIds[((index - 1) % #itemIds) + 1]
		table.insert(result, frozen({
			Name = ("%s_%02d"):format(prefix, index),
			Position = Vector3.new(slot.X, 0.18, centerZ + slot.Z),
			SupplyDepth = supplyDepth,
			ItemId = itemId,
			Kind = slot.Kind,
		}))
	end
	return frozen(result)
end

local function receivingStructures(centerZ: number)
	return frozen({
		structure("LeftReceivingPadA", "Low", Vector3.new(58, 1.2, 24), Vector3.new(-258, 0.6, centerZ + 24)),
		structure("LeftReceivingPadB", "Low", Vector3.new(48, 1.2, 22), Vector3.new(-105, 0.6, centerZ - 24)),
		structure("RightReceivingPadA", "Low", Vector3.new(52, 1.2, 24), Vector3.new(105, 0.6, centerZ + 24)),
		structure("RightReceivingPadB", "Low", Vector3.new(58, 1.2, 22), Vector3.new(258, 0.6, centerZ - 24)),
		structure("LeftRackEnd", "Rack", Vector3.new(16, 12, 28), Vector3.new(-300, 6, centerZ - 8)),
		structure("RightRackEnd", "Rack", Vector3.new(16, 12, 28), Vector3.new(300, 6, centerZ + 8)),
	})
end

local function applianceStructures(centerZ: number)
	return frozen({
		structure("LeftOuterBayA", "Block", Vector3.new(42, 11, 28), Vector3.new(-276, 5.5, centerZ + 26)),
		structure("LeftInnerBayA", "Block", Vector3.new(34, 11, 30), Vector3.new(-108, 5.5, centerZ + 24)),
		structure("RightInnerBayA", "Block", Vector3.new(34, 11, 30), Vector3.new(108, 5.5, centerZ - 24)),
		structure("RightOuterBayA", "Block", Vector3.new(42, 11, 28), Vector3.new(276, 5.5, centerZ - 26)),
		structure("LeftDisplay", "Low", Vector3.new(50, 1.4, 18), Vector3.new(-110, 0.7, centerZ - 28)),
		structure("RightDisplay", "Low", Vector3.new(50, 1.4, 18), Vector3.new(110, 0.7, centerZ + 28)),
	})
end

local function furnitureStructures(centerZ: number)
	return frozen({
		structure("LeftStageA", "Staging", Vector3.new(66, 0.6, 32), Vector3.new(-265, 0.3, centerZ + 24)),
		structure("LeftStageB", "Staging", Vector3.new(58, 0.6, 30), Vector3.new(-105, 0.3, centerZ - 24)),
		structure("RightStageA", "Staging", Vector3.new(58, 0.6, 30), Vector3.new(105, 0.3, centerZ + 24)),
		structure("RightStageB", "Staging", Vector3.new(66, 0.6, 32), Vector3.new(265, 0.3, centerZ - 24)),
		structure("LeftDivider", "Divider", Vector3.new(5, 9, 34), Vector3.new(-225, 4.5, centerZ - 2)),
		structure("RightDivider", "Divider", Vector3.new(5, 9, 34), Vector3.new(225, 4.5, centerZ + 2)),
	})
end

local function heavyStructures(centerZ: number)
	return frozen({
		structure("LeftCageA", "Cage", Vector3.new(48, 11, 30), Vector3.new(-275, 5.5, centerZ + 24)),
		structure("LeftHeavyPad", "Low", Vector3.new(48, 1.8, 26), Vector3.new(-105, 0.9, centerZ - 24)),
		structure("RightHeavyPad", "Low", Vector3.new(48, 1.8, 26), Vector3.new(105, 0.9, centerZ + 24)),
		structure("RightCageA", "Cage", Vector3.new(48, 11, 30), Vector3.new(275, 5.5, centerZ - 24)),
		structure("LeftToolWall", "Rack", Vector3.new(14, 13, 34), Vector3.new(-296, 6.5, centerZ - 16)),
		structure("RightToolWall", "Rack", Vector3.new(14, 13, 34), Vector3.new(296, 6.5, centerZ + 16)),
	})
end

local function industrialStructures(centerZ: number)
	return frozen({
		structure("LeftMachineBayA", "MachineBay", Vector3.new(54, 9, 30), Vector3.new(-270, 4.5, centerZ + 24)),
		structure("LeftMachineBayB", "MachineBay", Vector3.new(42, 9, 28), Vector3.new(-108, 4.5, centerZ - 24)),
		structure("RightMachineBayA", "MachineBay", Vector3.new(42, 9, 28), Vector3.new(108, 4.5, centerZ + 24)),
		structure("RightMachineBayB", "MachineBay", Vector3.new(54, 9, 30), Vector3.new(270, 4.5, centerZ - 24)),
		structure("LeftReinforcedRack", "Rack", Vector3.new(14, 15, 32), Vector3.new(-300, 7.5, centerZ - 14)),
		structure("RightReinforcedRack", "Rack", Vector3.new(14, 15, 32), Vector3.new(300, 7.5, centerZ + 14)),
	})
end

local function secureStructures(centerZ: number)
	return frozen({
		structure("LeftSecureCageA", "Cage", Vector3.new(54, 13, 30), Vector3.new(-272, 6.5, centerZ + 24)),
		structure("LeftSecureCageB", "Cage", Vector3.new(42, 13, 28), Vector3.new(-108, 6.5, centerZ - 24)),
		structure("RightSecureCageA", "Cage", Vector3.new(42, 13, 28), Vector3.new(108, 6.5, centerZ + 24)),
		structure("RightSecureCageB", "Cage", Vector3.new(54, 13, 30), Vector3.new(272, 6.5, centerZ - 24)),
		structure("LeftSecurityDivider", "Divider", Vector3.new(6, 12, 30), Vector3.new(-222, 6, centerZ)),
		structure("RightSecurityDivider", "Divider", Vector3.new(6, 12, 30), Vector3.new(222, 6, centerZ)),
	})
end

local sectionDefinitions = {
	Receiving = {
		Index = 1,
		DisplayName = "RECEIVING & GENERAL STORAGE",
		FrontZ = 292,
		BackZ = 202,
		CenterZ = 247,
		SupplyDepth = 1,
		Color = Color3.fromRGB(76, 92, 104),
		Style = "OpenReceiving",
		Structures = receivingStructures(247),
		Opportunities = opportunities("RCV", 247, 1, { "Box", "Lamp", "Box", "Microwave", "Box", "Chair" }),
	},
	Appliances = {
		Index = 2,
		DisplayName = "APPLIANCES & ELECTRONICS",
		FrontZ = 192,
		BackZ = 102,
		CenterZ = 147,
		SupplyDepth = 1,
		Color = Color3.fromRGB(70, 91, 116),
		Style = "StorageBays",
		Structures = applianceStructures(147),
		Opportunities = opportunities("APP", 147, 1, { "Microwave", "Box", "TV", "Microwave", "Lamp", "TV" }),
	},
	Furniture = {
		Index = 3,
		DisplayName = "FURNITURE & OVERSIZED",
		FrontZ = 92,
		BackZ = 2,
		CenterZ = 47,
		SupplyDepth = 2,
		Color = Color3.fromRGB(104, 83, 68),
		Style = "OpenStaging",
		Structures = furnitureStructures(47),
		Opportunities = opportunities("FUR", 47, 2, { "Chair", "Lamp", "Couch", "Chair", "Box", "Couch" }),
	},
	HeavyGoods = {
		Index = 4,
		DisplayName = "HEAVY GOODS & EQUIPMENT",
		FrontZ = -8,
		BackZ = -98,
		CenterZ = -53,
		SupplyDepth = 2,
		Color = Color3.fromRGB(93, 89, 73),
		Style = "HeavyCages",
		Structures = heavyStructures(-53),
		Opportunities = opportunities("HVG", -53, 2, { "Tire", "Chair", "Safe", "Tire", "Box", "TV" }),
	},
	Industrial = {
		Index = 5,
		DisplayName = "INDUSTRIAL STORAGE",
		FrontZ = -108,
		BackZ = -198,
		CenterZ = -153,
		SupplyDepth = 3,
		Color = Color3.fromRGB(82, 86, 78),
		Style = "MachineBays",
		Structures = industrialStructures(-153),
		Opportunities = opportunities("IND", -153, 3, { "Tire", "Safe", "TV", "Tire", "Chair", "Safe" }),
	},
	Secure = {
		Index = 6,
		DisplayName = "SECURE HIGH-VALUE STORAGE",
		FrontZ = -208,
		BackZ = -298,
		CenterZ = -253,
		SupplyDepth = 3,
		Color = Color3.fromRGB(79, 73, 70),
		Style = "SecureCages",
		Structures = secureStructures(-253),
		Opportunities = opportunities("SEC", -253, 3, { "Safe", "TV", "Couch", "Safe", "TV", "Couch" }),
	},
}

for key, value in sectionDefinitions do
	sectionDefinitions[key] = frozen(value)
end

return frozen({
	-- M5A shell: deliberately longer than the currently playable storage run so
	-- later expansion can continue behind Secure without moving the 12 bay front.
	FootprintSize = Vector3.new(700, 1, 900),
	WallHeight = 32,
	CeilingClearance = 50,

	LoadingApron = frozen({
		Center = Vector3.new(0, 0.06, 352),
		Size = Vector3.new(670, 0.12, 76),
		FreightCrossingZ = 308,
	}),

	Bay = frozen({
		Count = 12,
		StartX = -275,
		Spacing = 50,
		Z = 410,
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
		StockSlotPositions = frozen({
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

	Routes = frozen({
		MainFreight = frozen({
			Start = Vector3.new(0, 0, 308),
			Finish = Vector3.new(0, 0, -310),
			Width = 34,
		}),
		ServiceWidth = 18,
		LeftService = frozen({
			Vector3.new(-180, 0, 300),
			Vector3.new(-215, 0, 247),
			Vector3.new(-172, 0, 197),
			Vector3.new(-214, 0, 147),
			Vector3.new(-174, 0, 97),
			Vector3.new(-216, 0, 47),
			Vector3.new(-174, 0, -3),
			Vector3.new(-216, 0, -53),
			Vector3.new(-174, 0, -103),
			Vector3.new(-216, 0, -153),
			Vector3.new(-174, 0, -203),
			Vector3.new(-214, 0, -253),
			Vector3.new(-180, 0, -304),
		}),
		RightService = frozen({
			Vector3.new(180, 0, 300),
			Vector3.new(215, 0, 247),
			Vector3.new(172, 0, 197),
			Vector3.new(214, 0, 147),
			Vector3.new(174, 0, 97),
			Vector3.new(216, 0, 47),
			Vector3.new(174, 0, -3),
			Vector3.new(216, 0, -53),
			Vector3.new(174, 0, -103),
			Vector3.new(216, 0, -153),
			Vector3.new(174, 0, -203),
			Vector3.new(214, 0, -253),
			Vector3.new(180, 0, -304),
		}),
	}),

	CrossAisles = frozen({
		frozen({ Name = "CROSS_AISLE_A", Z = 197, Width = 22 }),
		frozen({ Name = "CROSS_AISLE_B", Z = 97, Width = 22 }),
		frozen({ Name = "CROSS_AISLE_C", Z = -3, Width = 22 }),
		frozen({ Name = "CROSS_AISLE_D", Z = -103, Width = 22 }),
		frozen({ Name = "CROSS_AISLE_E", Z = -203, Width = 22 }),
	}),

	Section = frozen({
		Width = 620,
		FreightLaneWidth = 34,
		ServiceLaneWidth = 18,
		InternalConnectorWidth = 14,
	}),

	SectionOrder = frozen({ "Receiving", "Appliances", "Furniture", "HeavyGoods", "Industrial", "Secure" }),
	Sectors = frozen(sectionDefinitions),

	-- Supply remains the M4.1 centralized controller. M5A only supplies more
	-- authored positions because the playable warehouse now has six sections.
	Density = frozen({
		MinActivePerSector = 12,
		MaxActivePerSector = 16,
		FullServerPlayers = 12,
		ReconcileDelaySeconds = 0.45,
	}),

	-- Retained for compatibility/debug metadata. ItemService no longer performs
	-- independent per-spawn timer restocks.
	RestockSeconds = frozen({
		Box = 1.20,
		Microwave = 1.55,
		Lamp = 1.45,
		Chair = 1.70,
		Tire = 1.35,
		TV = 1.90,
		Couch = 2.25,
		Safe = 2.50,
	}),

	ExpectedAvailableAtFullServer = 96,

	ExpansionPoints = frozen({
		CFrame.new(-240, 0.5, -326),
		CFrame.new(0, 0.5, -326),
		CFrame.new(240, 0.5, -326),
		CFrame.new(-330, 0.5, -153),
		CFrame.new(330, 0.5, -153),
	}),

	FallbackSpawnPosition = Vector3.new(0, 0.6, 382),
})