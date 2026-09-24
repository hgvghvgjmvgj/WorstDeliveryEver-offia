--!strict

local SectionConfig = require(script.Parent:WaitForChild("SectionConfig"))

export type ShapeTag = "Compact" | "Tall" | "Wide"

local function item(id: string, name: string, baseSell: number, weight: number, bulk: number, shape: ShapeTag, size: Vector3, color: Color3, modelKind: string, core: boolean?, heroMinRarity: string?)
	return table.freeze({
		Id = id,
		Name = name,
		BaseSell = baseSell,
		Weight = weight,
		Bulk = bulk,
		ShapeTag = shape,
		Size = size,
		Color = color,
		ModelKind = modelKind,
		Core = if core == nil then true else core,
		HeroMinRarity = heroMinRarity,
	})
end

local function section(sectionId: string, items)
	local meta = SectionConfig.Sections[sectionId]
	return table.freeze({
		Index = meta.Index,
		DisplayName = meta.DisplayName,
		EconomicScale = meta.EconomicScale,
		Items = table.freeze(items),
	})
end

local sections = table.freeze({
	Receiving = section("Receiving", {
		item("ShippingBox", "Shipping Box", 900, 1, 1, "Compact", Vector3.new(3.2,3.2,3.2), Color3.fromRGB(202,151,93), "Crate"),
		item("Toolbox", "Toolbox", 1200, 2, 1, "Compact", Vector3.new(4.2,2.0,2.2), Color3.fromRGB(173,59,49), "Case"),
		item("Suitcase", "Suitcase", 1350, 1, 2, "Tall", Vector3.new(3.0,4.7,1.7), Color3.fromRGB(61,82,110), "Case"),
		item("Cooler", "Cooler", 1450, 2, 2, "Compact", Vector3.new(4.1,2.8,2.8), Color3.fromRGB(83,151,188), "Crate"),
		item("OfficeChair", "Office Chair", 1700, 2, 2, "Wide", Vector3.new(4.8,5.2,4.2), Color3.fromRGB(78,83,92), "Chair"),
		item("RollingCart", "Rolling Cart", 1850, 2, 3, "Wide", Vector3.new(5.4,4.2,3.4), Color3.fromRGB(137,145,151), "Cart"),
		item("PackageBundle", "Package Bundle", 1100, 2, 2, "Compact", Vector3.new(4.4,3.0,3.3), Color3.fromRGB(186,139,83), "Bundle"),
		item("StorageBin", "Storage Bin", 1250, 1, 2, "Compact", Vector3.new(4.4,2.8,3.1), Color3.fromRGB(91,132,157), "Crate"),
		item("Printer", "Office Printer", 2100, 2, 2, "Compact", Vector3.new(4.2,2.5,3.5), Color3.fromRGB(181,184,187), "Appliance"),
		item("FilingCabinet", "Filing Cabinet", 2300, 3, 2, "Tall", Vector3.new(3.2,5.8,3.0), Color3.fromRGB(119,127,135), "Cabinet"),
		item("FoldingTable", "Folding Table", 1950, 2, 3, "Wide", Vector3.new(7.2,2.8,3.0), Color3.fromRGB(154,136,111), "Table"),
		item("MailTub", "Mail Tub", 1050, 1, 1, "Compact", Vector3.new(3.5,2.0,2.6), Color3.fromRGB(93,118,154), "Crate"),
		item("GoldenPalletJack", "Golden Pallet Jack", 4200, 4, 4, "Wide", Vector3.new(8.0,3.5,4.5), Color3.fromRGB(199,158,58), "Cart", false, "Legendary"),
	}),

	HomeBasics = section("HomeBasics", {
		item("DeskLamp", "Desk Lamp", 950, 1, 1, "Tall", Vector3.new(2.2,4.2,2.2), Color3.fromRGB(226,204,123), "Lamp"),
		item("DiningChairBasic", "Dining Chair", 1150, 2, 2, "Wide", Vector3.new(4.2,5.0,4.0), Color3.fromRGB(151,111,79), "Chair"),
		item("BoxFan", "Box Fan", 1250, 2, 2, "Wide", Vector3.new(4.7,4.7,2.0), Color3.fromRGB(177,184,188), "Fan"),
		item("WallShelfBundle", "Shelf Bundle", 1350, 2, 3, "Wide", Vector3.new(7.0,2.0,2.8), Color3.fromRGB(134,101,73), "Bundle"),
		item("CountertopOven", "Countertop Oven", 1550, 3, 2, "Compact", Vector3.new(4.6,3.0,3.8), Color3.fromRGB(160,164,169), "Appliance"),
		item("SideTable", "Side Table", 1300, 2, 3, "Wide", Vector3.new(5.2,3.2,4.3), Color3.fromRGB(136,96,67), "Table"),
		item("KitchenCart", "Kitchen Cart", 1750, 3, 4, "Wide", Vector3.new(6.5,4.7,3.8), Color3.fromRGB(150,151,145), "Cart"),
		item("HomeStorageShelf", "Home Storage Shelf", 1850, 3, 3, "Tall", Vector3.new(4.8,7.0,2.6), Color3.fromRGB(128,102,77), "Cabinet"),
		item("ModelHomeStarterSet", "Model Home Starter Set", 3900, 5, 6, "Wide", Vector3.new(9.0,5.0,6.0), Color3.fromRGB(184,143,100), "Bundle", false, "Legendary"),
	}),

	Appliances = section("Appliances", {
		item("Microwave", "Microwave", 1100, 2, 2, "Compact", Vector3.new(4.4,2.7,3.2), Color3.fromRGB(180,184,190), "Appliance"),
		item("Television", "Television", 1800, 3, 2, "Wide", Vector3.new(7.2,4.5,1.6), Color3.fromRGB(58,68,83), "Screen"),
		item("Vacuum", "Vacuum Cleaner", 1250, 2, 2, "Tall", Vector3.new(2.3,5.6,2.2), Color3.fromRGB(105,88,130), "TallAppliance"),
		item("MiniFridge", "Mini Fridge", 1650, 3, 2, "Tall", Vector3.new(3.4,5.0,3.3), Color3.fromRGB(191,197,204), "Appliance"),
		item("Refrigerator", "Refrigerator", 2600, 5, 4, "Tall", Vector3.new(4.6,8.0,4.4), Color3.fromRGB(206,211,215), "Appliance"),
		item("Washer", "Washing Machine", 2350, 5, 4, "Compact", Vector3.new(5.2,5.4,4.8), Color3.fromRGB(201,205,210), "Washer"),
		item("Dryer", "Clothes Dryer", 2250, 5, 4, "Compact", Vector3.new(5.2,5.4,4.8), Color3.fromRGB(187,192,198), "Washer"),
		item("Dishwasher", "Dishwasher", 2150, 4, 3, "Tall", Vector3.new(4.4,5.4,4.0), Color3.fromRGB(175,183,190), "Appliance"),
		item("OvenRange", "Oven Range", 2750, 6, 4, "Compact", Vector3.new(5.5,5.0,5.0), Color3.fromRGB(123,126,132), "Appliance"),
		item("SpeakerSystem", "Speaker System", 1900, 3, 3, "Tall", Vector3.new(3.2,6.8,3.1), Color3.fromRGB(47,50,58), "Speaker"),
		item("GamingMonitor", "Gaming Monitor", 2050, 2, 2, "Wide", Vector3.new(6.5,4.0,1.5), Color3.fromRGB(49,62,79), "Screen"),
		item("CommercialMixer", "Commercial Mixer", 3200, 5, 3, "Tall", Vector3.new(4.0,6.2,4.0), Color3.fromRGB(151,157,163), "Machine"),
		item("PrototypeSmartFridge", "Prototype Smart Fridge", 5200, 6, 4, "Tall", Vector3.new(5.0,8.3,4.6), Color3.fromRGB(119,180,196), "Appliance", false, "Mythic"),
	}),

	Furniture = section("Furniture", {
		item("FloorLamp", "Floor Lamp", 850, 1, 2, "Tall", Vector3.new(1.7,8.5,1.7), Color3.fromRGB(242,214,100), "Lamp"),
		item("Armchair", "Armchair", 1350, 3, 3, "Wide", Vector3.new(5.5,5.2,5.0), Color3.fromRGB(145,100,76), "Chair"),
		item("OfficeDesk", "Office Desk", 1600, 4, 4, "Wide", Vector3.new(8.0,4.2,4.0), Color3.fromRGB(116,82,60), "Table"),
		item("CoffeeTable", "Coffee Table", 1200, 3, 3, "Wide", Vector3.new(6.7,2.5,4.2), Color3.fromRGB(126,91,65), "Table"),
		item("DiningTable", "Dining Table", 2100, 5, 5, "Wide", Vector3.new(9.2,3.3,5.2), Color3.fromRGB(121,79,53), "Table"),
		item("Couch", "Couch", 2400, 4, 5, "Wide", Vector3.new(10.5,4.4,4.1), Color3.fromRGB(87,139,184), "Sofa"),
		item("Mattress", "Mattress", 1850, 3, 5, "Wide", Vector3.new(8.0,1.8,6.2), Color3.fromRGB(221,215,196), "Mattress"),
		item("Wardrobe", "Wardrobe", 2550, 6, 5, "Tall", Vector3.new(6.0,9.0,4.2), Color3.fromRGB(109,76,52), "Cabinet"),
		item("Recliner", "Recliner", 2000, 4, 4, "Wide", Vector3.new(6.2,5.3,5.2), Color3.fromRGB(103,83,74), "Chair"),
		item("SectionalSofa", "Sectional Sofa", 3150, 6, 7, "Wide", Vector3.new(12.0,4.6,6.4), Color3.fromRGB(94,118,139), "Sofa"),
		item("Bookcase", "Bookcase", 1750, 4, 4, "Tall", Vector3.new(5.0,8.5,2.4), Color3.fromRGB(124,88,60), "Cabinet"),
		item("UprightPiano", "Upright Piano", 3900, 8, 6, "Wide", Vector3.new(9.0,6.0,3.8), Color3.fromRGB(54,47,45), "Piano"),
		item("RoyalGrandPiano", "Royal Grand Piano", 6800, 10, 8, "Wide", Vector3.new(11.5,5.2,8.0), Color3.fromRGB(166,127,54), "Piano", false, "Legendary"),
	}),

	Electronics = section("Electronics", {
		item("GamingPC", "Gaming PC Tower", 2200, 4, 2, "Tall", Vector3.new(3.2,6.2,3.0), Color3.fromRGB(55,63,78), "Cabinet"),
		item("DualMonitorCrate", "Dual Monitor Crate", 2450, 4, 4, "Wide", Vector3.new(8.4,4.5,2.2), Color3.fromRGB(59,70,86), "Screen"),
		item("ConsoleBundle", "Console Bundle", 1950, 3, 2, "Compact", Vector3.new(4.5,2.8,3.5), Color3.fromRGB(63,66,76), "Case"),
		item("StudioSpeakerPair", "Studio Speaker Pair", 2300, 4, 3, "Tall", Vector3.new(4.0,7.2,3.6), Color3.fromRGB(42,45,53), "Speaker"),
		item("HomeTheaterRack", "Home Theater Rack", 2850, 5, 4, "Tall", Vector3.new(5.0,7.5,4.3), Color3.fromRGB(53,58,69), "Cabinet"),
		item("PremiumWorkstation", "Premium Workstation", 3200, 6, 4, "Wide", Vector3.new(7.4,5.8,4.4), Color3.fromRGB(61,72,88), "Machine"),
		item("NetworkStation", "Network Station", 3000, 6, 3, "Tall", Vector3.new(4.4,8.0,4.0), Color3.fromRGB(55,69,78), "Cabinet"),
		item("DisplayWallCrate", "Display Wall Crate", 3500, 7, 5, "Wide", Vector3.new(9.0,5.5,2.6), Color3.fromRGB(47,58,72), "Crate"),
		item("CreatorCommandCenter", "Creator Command Center", 6100, 9, 7, "Wide", Vector3.new(11.0,7.0,6.5), Color3.fromRGB(63,87,110), "Machine", false, "Mythic"),
	}),

	Recreation = section("Recreation", {
		item("ArcadeCabinet", "Arcade Cabinet", 2500, 6, 4, "Tall", Vector3.new(4.8,8.4,4.6), Color3.fromRGB(86,62,116), "Cabinet"),
		item("Treadmill", "Treadmill", 2700, 7, 6, "Wide", Vector3.new(9.0,5.5,4.0), Color3.fromRGB(74,78,84), "Machine"),
		item("ExerciseBike", "Exercise Bike", 2200, 5, 4, "Tall", Vector3.new(6.0,6.0,3.4), Color3.fromRGB(67,76,84), "Machine"),
		item("BicycleCrate", "Bicycle Shipping Crate", 2350, 5, 5, "Wide", Vector3.new(9.0,5.2,2.6), Color3.fromRGB(143,106,67), "Crate"),
		item("GamingChairPremium", "Premium Gaming Chair", 2100, 4, 4, "Wide", Vector3.new(5.6,6.0,5.0), Color3.fromRGB(68,61,84), "Chair"),
		item("FoosballTable", "Foosball Table", 2800, 7, 6, "Wide", Vector3.new(8.5,4.5,5.2), Color3.fromRGB(112,80,56), "Table"),
		item("SportsEquipmentRack", "Sports Equipment Rack", 2000, 5, 5, "Tall", Vector3.new(5.0,7.0,4.5), Color3.fromRGB(102,112,92), "Rack"),
		item("RowingMachine", "Rowing Machine", 2600, 6, 6, "Wide", Vector3.new(10.0,3.8,3.5), Color3.fromRGB(77,83,89), "Machine"),
		item("DeluxeArcadePod", "Deluxe Arcade Pod", 6400, 10, 8, "Tall", Vector3.new(7.0,9.0,7.0), Color3.fromRGB(104,65,137), "Cabinet", false, "Mythic"),
	}),

	GarageAuto = section("GarageAuto", {
		item("ProToolCabinet", "Pro Tool Cabinet", 2600, 7, 4, "Wide", Vector3.new(7.0,5.5,3.8), Color3.fromRGB(157,56,50), "Cabinet"),
		item("PerformanceWheelSet", "Performance Wheel Set", 2900, 8, 5, "Wide", Vector3.new(7.5,5.0,5.0), Color3.fromRGB(49,51,56), "Cylinder"),
		item("EngineCrate", "Engine Shipping Crate", 3300, 10, 5, "Compact", Vector3.new(6.5,5.5,5.5), Color3.fromRGB(101,87,69), "Crate"),
		item("FloorJack", "Garage Floor Jack", 2100, 6, 3, "Wide", Vector3.new(7.0,2.8,3.8), Color3.fromRGB(120,57,49), "Cart"),
		item("ShopCompressor", "Shop Compressor", 3000, 9, 4, "Wide", Vector3.new(7.0,5.0,4.0), Color3.fromRGB(72,107,132), "Cylinder"),
		item("WorkshopBench", "Workshop Bench", 2400, 7, 5, "Wide", Vector3.new(8.5,5.0,4.0), Color3.fromRGB(112,84,59), "Table"),
		item("AxleAssembly", "Axle Assembly", 3100, 9, 4, "Wide", Vector3.new(9.0,3.5,3.5), Color3.fromRGB(72,75,77), "Machine"),
		item("PremiumWheelRack", "Premium Wheel Rack", 3500, 10, 6, "Tall", Vector3.new(6.0,8.0,5.0), Color3.fromRGB(57,60,66), "Rack"),
		item("ShowCarEngine", "Show-Car Engine Assembly", 7000, 14, 7, "Compact", Vector3.new(7.2,6.0,6.2), Color3.fromRGB(79,82,85), "Engine", false, "Mythic"),
	}),

	Construction = section("Construction", {
		item("JobsitePowerUnit", "Jobsite Power Unit", 2800, 8, 4, "Compact", Vector3.new(6.2,4.8,4.5), Color3.fromRGB(121,113,68), "Machine"),
		item("ConcreteMixer", "Concrete Mixer", 3200, 10, 6, "Wide", Vector3.new(8.0,6.8,5.5), Color3.fromRGB(117,122,124), "Machine"),
		item("ContractorToolCrate", "Contractor Tool Crate", 2500, 7, 5, "Wide", Vector3.new(7.5,4.5,4.8), Color3.fromRGB(132,96,57), "Crate"),
		item("DemolitionSaw", "Demolition Saw Case", 2600, 8, 3, "Wide", Vector3.new(7.8,3.4,3.4), Color3.fromRGB(118,75,51), "Case"),
		item("PortableLightRig", "Portable Light Rig", 2400, 7, 5, "Tall", Vector3.new(4.5,8.8,4.2), Color3.fromRGB(148,140,85), "TallAppliance"),
		item("PlateCompactor", "Plate Compactor", 3300, 11, 4, "Compact", Vector3.new(6.0,5.3,5.0), Color3.fromRGB(99,105,84), "Machine"),
		item("ScaffoldBundle", "Scaffold Bundle", 2950, 9, 7, "Wide", Vector3.new(10.0,4.2,4.8), Color3.fromRGB(135,138,139), "Bundle"),
		item("MasonryCutter", "Masonry Cutter", 3600, 12, 5, "Wide", Vector3.new(7.8,5.6,5.2), Color3.fromRGB(103,108,101), "Machine"),
		item("SiteMachineAttachment", "Heavy Site Machine Attachment", 7600, 16, 8, "Wide", Vector3.new(9.5,6.0,7.0), Color3.fromRGB(126,112,65), "Machine", false, "Mythic"),
	}),

	HeavyGoods = section("HeavyGoods", {
		item("Safe", "Commercial Safe", 1700, 6, 2, "Compact", Vector3.new(4.8,5.4,4.8), Color3.fromRGB(89,99,110), "Safe"),
		item("Generator", "Generator", 1850, 7, 3, "Compact", Vector3.new(6.0,4.5,4.0), Color3.fromRGB(96,111,83), "Machine"),
		item("TireStack", "Tire Stack", 1250, 5, 3, "Tall", Vector3.new(4.2,6.2,4.2), Color3.fromRGB(49,51,56), "Cylinder"),
		item("ToolChest", "Rolling Tool Chest", 1550, 6, 3, "Wide", Vector3.new(6.4,4.8,3.6), Color3.fromRGB(166,54,47), "Cabinet"),
		item("AirCompressor", "Air Compressor", 1950, 7, 3, "Wide", Vector3.new(6.8,4.8,3.7), Color3.fromRGB(72,112,142), "Cylinder"),
		item("VendingMachine", "Vending Machine", 2300, 8, 4, "Tall", Vector3.new(5.5,9.0,4.2), Color3.fromRGB(57,75,91), "Appliance"),
		item("IndustrialFan", "Industrial Fan", 1450, 5, 4, "Wide", Vector3.new(7.0,7.0,2.5), Color3.fromRGB(111,116,121), "Fan"),
		item("BatteryUnit", "Heavy Battery Unit", 2050, 9, 3, "Compact", Vector3.new(5.0,4.2,4.3), Color3.fromRGB(70,79,77), "Machine"),
		item("CommercialFreezer", "Commercial Freezer", 2600, 9, 5, "Tall", Vector3.new(6.0,8.2,5.0), Color3.fromRGB(189,196,202), "Appliance"),
		item("EquipmentCase", "Large Equipment Case", 1800, 6, 4, "Wide", Vector3.new(7.5,3.6,4.5), Color3.fromRGB(70,76,74), "Case"),
		item("PressureWasher", "Pressure Washer", 1650, 5, 3, "Tall", Vector3.new(4.0,5.5,3.8), Color3.fromRGB(73,117,91), "Machine"),
		item("EquipmentCart", "Equipment Cart", 2150, 7, 4, "Wide", Vector3.new(7.5,5.0,4.2), Color3.fromRGB(120,126,128), "Cart"),
		item("TitanVaultSafe", "Titan Vault Safe", 4200, 12, 5, "Compact", Vector3.new(6.4,7.4,6.2), Color3.fromRGB(72,79,88), "Safe", false, "Mythic"),
	}),

	Industrial = section("Industrial", {
		item("EngineBlock", "Engine Block", 1650, 9, 3, "Compact", Vector3.new(5.8,4.5,4.6), Color3.fromRGB(78,82,84), "Engine"),
		item("CableReel", "Cable Reel", 1250, 7, 4, "Wide", Vector3.new(6.5,6.5,3.6), Color3.fromRGB(93,74,57), "Cylinder"),
		item("IndustrialPump", "Industrial Pump", 1900, 10, 4, "Compact", Vector3.new(6.0,5.0,5.0), Color3.fromRGB(67,91,105), "Machine"),
		item("Transformer", "Transformer", 2450, 12, 5, "Tall", Vector3.new(6.0,7.5,5.2), Color3.fromRGB(88,96,80), "Machine"),
		item("MotorAssembly", "Motor Assembly", 2000, 10, 3, "Compact", Vector3.new(5.4,4.4,4.6), Color3.fromRGB(74,79,82), "Engine"),
		item("MachineGearbox", "Machine Gearbox", 1850, 11, 3, "Compact", Vector3.new(5.2,4.8,4.7), Color3.fromRGB(91,83,71), "Machine"),
		item("SteelDrum", "Steel Drum", 1150, 8, 3, "Tall", Vector3.new(4.2,6.4,4.2), Color3.fromRGB(71,91,111), "Cylinder"),
		item("HydraulicUnit", "Hydraulic Unit", 2250, 12, 4, "Compact", Vector3.new(6.4,5.2,4.8), Color3.fromRGB(95,79,62), "Machine"),
		item("ControlCabinet", "Industrial Control Cabinet", 2350, 10, 4, "Tall", Vector3.new(5.5,8.2,3.8), Color3.fromRGB(134,139,132), "Cabinet"),
		item("WeldingRig", "Fabrication Welding Rig", 1750, 9, 4, "Wide", Vector3.new(6.6,5.4,4.2), Color3.fromRGB(68,73,78), "Cart"),
		item("CompressorSkid", "Compressor Skid", 2700, 14, 6, "Wide", Vector3.new(8.5,5.0,5.6), Color3.fromRGB(71,84,93), "Machine"),
		item("ProductionMachine", "Production Machine", 3400, 16, 7, "Wide", Vector3.new(9.5,7.5,6.5), Color3.fromRGB(83,88,82), "Machine"),
		item("CosmicReactorCore", "Experimental Reactor Core", 6200, 14, 6, "Tall", Vector3.new(6.5,8.0,6.5), Color3.fromRGB(74,111,122), "Core", false, "Cosmic"),
	}),

	PremiumInteriors = section("PremiumInteriors", {
		item("LuxurySofa", "Luxury Sofa", 3000, 7, 8, "Wide", Vector3.new(11.0,4.8,5.2), Color3.fromRGB(126,104,92), "Sofa"),
		item("DesignerChair", "Designer Chair", 2750, 5, 5, "Wide", Vector3.new(5.8,6.0,5.2), Color3.fromRGB(141,111,91), "Chair"),
		item("ChandelierCrate", "Chandelier Transport Crate", 3200, 7, 6, "Tall", Vector3.new(6.0,8.5,6.0), Color3.fromRGB(174,147,90), "Crate"),
		item("MarbleTable", "Marble Table", 3900, 11, 8, "Wide", Vector3.new(9.0,4.0,6.0), Color3.fromRGB(188,184,174), "Table"),
		item("PremiumDecorCrate", "Premium Decor Crate", 2800, 6, 5, "Compact", Vector3.new(6.0,5.0,5.5), Color3.fromRGB(138,112,89), "Crate"),
		item("DesignerCabinet", "Designer Cabinet", 3650, 9, 7, "Tall", Vector3.new(6.0,9.0,4.8), Color3.fromRGB(114,83,67), "Cabinet"),
		item("SculpturalBench", "Sculptural Bench", 3400, 8, 7, "Wide", Vector3.new(9.5,4.0,4.5), Color3.fromRGB(154,145,132), "Table"),
		item("PremiumLightingCase", "Premium Lighting Case", 3100, 7, 6, "Tall", Vector3.new(5.5,8.0,4.6), Color3.fromRGB(168,148,92), "Case"),
		item("GrandCrystalChandelier", "Grand Crystal Chandelier", 7800, 12, 10, "Tall", Vector3.new(8.0,10.0,8.0), Color3.fromRGB(210,196,153), "Display", false, "Mythic"),
	}),

	LuxuryGoods = section("LuxuryGoods", {
		item("DesignerFragranceTrunk", "Designer Fragrance Trunk", 3600, 7, 6, "Wide", Vector3.new(8.0,4.8,5.0), Color3.fromRGB(111,86,67), "Chest"),
		item("LuxuryParfumCase", "Luxury Parfum Case", 3200, 6, 4, "Compact", Vector3.new(5.5,4.2,4.5), Color3.fromRGB(135,104,78), "Case"),
		item("PremiumLuggageSet", "Premium Luggage Set", 3500, 7, 7, "Tall", Vector3.new(6.5,8.0,5.0), Color3.fromRGB(76,74,81), "Bundle"),
		item("WatchDisplayCase", "Watch Display Case", 4200, 8, 5, "Wide", Vector3.new(7.0,4.5,5.0), Color3.fromRGB(87,72,61), "Display"),
		item("JewelryDisplay", "Jewelry Display Cabinet", 4500, 9, 6, "Tall", Vector3.new(6.0,8.0,4.5), Color3.fromRGB(83,75,70), "Display"),
		item("FashionTrunk", "Fashion House Trunk", 3800, 8, 6, "Wide", Vector3.new(8.2,5.0,5.0), Color3.fromRGB(105,78,63), "Chest"),
		item("HandbagDisplayCrate", "Luxury Accessory Display Crate", 3900, 7, 6, "Wide", Vector3.new(7.8,5.5,4.5), Color3.fromRGB(141,104,78), "Crate"),
		item("RoyalOudCabinet", "Royal Oud Cabinet", 4700, 10, 7, "Tall", Vector3.new(6.5,8.5,5.0), Color3.fromRGB(88,61,47), "Cabinet"),
		item("MasterPerfumerCollection", "Master Perfumer Collection", 9200, 13, 9, "Wide", Vector3.new(9.0,7.0,6.0), Color3.fromRGB(143,109,70), "Display", false, "Cosmic"),
	}),

	ArtCollectibles = section("ArtCollectibles", {
		item("PaintingTransportCrate", "Painting Transport Crate", 3900, 7, 6, "Wide", Vector3.new(9.0,7.5,2.5), Color3.fromRGB(151,111,71), "Crate"),
		item("BronzeSculpture", "Bronze Sculpture", 4300, 9, 6, "Tall", Vector3.new(5.5,9.0,5.5), Color3.fromRGB(132,90,57), "Display"),
		item("RareInstrumentCase", "Rare Instrument Case", 4100, 7, 6, "Wide", Vector3.new(9.5,3.4,4.8), Color3.fromRGB(64,54,49), "Case"),
		item("CollectorDisplayCase", "Collector Display Case", 4500, 8, 7, "Tall", Vector3.new(6.0,8.5,5.0), Color3.fromRGB(83,92,99), "Display"),
		item("AntiqueCabinet", "Antique Cabinet", 4700, 10, 8, "Tall", Vector3.new(6.5,9.0,5.0), Color3.fromRGB(91,65,49), "Cabinet"),
		item("MuseumArtifactCrate", "Museum Artifact Crate", 5200, 11, 7, "Compact", Vector3.new(7.0,6.5,6.5), Color3.fromRGB(132,96,61), "Crate"),
		item("GrandfatherClock", "Rare Hall Clock", 4400, 8, 6, "Tall", Vector3.new(4.5,10.0,3.5), Color3.fromRGB(104,73,51), "Cabinet"),
		item("MarbleSculpture", "Marble Sculpture", 5600, 13, 8, "Tall", Vector3.new(6.5,9.5,6.5), Color3.fromRGB(190,187,178), "Display"),
		item("CrownGalleryPiece", "Crown Gallery Masterpiece", 10500, 15, 10, "Tall", Vector3.new(8.0,10.0,7.0), Color3.fromRGB(185,151,87), "Display", false, "Cosmic"),
	}),

	Secure = section("Secure", {
		item("LuxuryDisplayCase", "Luxury Display Case", 1800, 6, 4, "Tall", Vector3.new(5.5,7.0,4.0), Color3.fromRGB(91,105,116), "Display"),
		item("ArtworkCrate", "Fine Art Crate", 1600, 5, 4, "Wide", Vector3.new(7.0,6.0,2.3), Color3.fromRGB(157,116,73), "Crate"),
		item("HighSecurityCase", "High-Security Case", 2100, 7, 3, "Compact", Vector3.new(5.5,3.3,4.0), Color3.fromRGB(50,58,65), "Case"),
		item("PrototypeServer", "Prototype Server Rack", 2600, 9, 4, "Tall", Vector3.new(4.8,8.8,4.0), Color3.fromRGB(56,69,79), "Cabinet"),
		item("PremiumMedicalMachine", "Premium Medical Machine", 2800, 8, 5, "Tall", Vector3.new(6.0,7.8,5.0), Color3.fromRGB(205,214,214), "Machine"),
		item("CollectorChest", "Collector Cargo Chest", 2300, 8, 4, "Compact", Vector3.new(6.0,4.5,4.8), Color3.fromRGB(111,82,47), "Chest"),
		item("ConcertInstrumentCase", "Concert Instrument Case", 2450, 6, 5, "Wide", Vector3.new(9.0,3.0,4.8), Color3.fromRGB(62,53,48), "Case"),
		item("PrecisionOpticsCase", "Precision Optics Case", 2550, 6, 3, "Wide", Vector3.new(7.0,3.3,4.0), Color3.fromRGB(72,78,83), "Case"),
		item("JewelrySafe", "Jewelry Safe", 3200, 10, 3, "Compact", Vector3.new(5.0,5.8,4.8), Color3.fromRGB(73,79,88), "Safe"),
		item("AuctionCrate", "Auction House Crate", 2700, 7, 5, "Wide", Vector3.new(8.0,5.5,4.6), Color3.fromRGB(135,98,61), "Crate"),
		item("ResearchPrototype", "Research Prototype", 3600, 9, 4, "Compact", Vector3.new(5.8,5.8,5.8), Color3.fromRGB(83,104,114), "Core"),
		item("ExecutiveVault", "Executive Vault Unit", 4200, 14, 5, "Compact", Vector3.new(6.4,7.2,6.2), Color3.fromRGB(61,67,74), "Safe"),
		item("BlackProjectContainmentUnit", "Black-Project Containment Unit", 7800, 16, 7, "Tall", Vector3.new(7.0,8.8,7.0), Color3.fromRGB(40,50,57), "Core", false, "Cosmic"),
	}),

	RestrictedPrototype = section("RestrictedPrototype", {
		item("ExperimentalPowerCore", "Experimental Power Core", 5200, 13, 6, "Compact", Vector3.new(6.0,6.0,6.0), Color3.fromRGB(62,100,110), "Core"),
		item("PrototypeDroneCrate", "Prototype Drone Crate", 4800, 11, 7, "Wide", Vector3.new(8.5,5.5,6.0), Color3.fromRGB(62,72,82), "Crate"),
		item("ContainmentCylinder", "Containment Cylinder", 5600, 14, 7, "Tall", Vector3.new(6.0,9.0,6.0), Color3.fromRGB(57,85,90), "Cylinder"),
		item("AdvancedScanner", "Advanced Scanner Array", 5900, 14, 8, "Wide", Vector3.new(9.0,6.5,6.0), Color3.fromRGB(69,91,105), "Machine"),
		item("ResearchServerPod", "Research Server Pod", 6100, 15, 7, "Tall", Vector3.new(6.0,9.5,5.5), Color3.fromRGB(46,66,80), "Cabinet"),
		item("MagneticAssembly", "Magnetic Assembly", 6500, 17, 8, "Compact", Vector3.new(7.0,6.5,6.5), Color3.fromRGB(75,82,86), "Machine"),
		item("SecretProjectCrate", "Secret Project Crate", 6800, 16, 9, "Wide", Vector3.new(9.0,6.5,6.5), Color3.fromRGB(48,56,61), "Crate"),
		item("EngineeredArtifact", "Engineered Artifact", 7600, 18, 9, "Tall", Vector3.new(7.0,10.0,7.0), Color3.fromRGB(61,91,99), "Core"),
		item("ZeroPointContainmentUnit", "Zero-Point Containment Unit", 14000, 22, 11, "Tall", Vector3.new(8.5,11.0,8.0), Color3.fromRGB(45,77,86), "Core", false, "Eternal"),
	}),
})

local byId = {}
local coreBySection = {}
local heroBySection = {}
for sectionId, sectionDefinition in sections do
	coreBySection[sectionId] = {}
	heroBySection[sectionId] = {}
	for _, definition in sectionDefinition.Items do
		byId[definition.Id] = table.freeze({
			Id = definition.Id,
			Name = definition.Name,
			BaseSell = definition.BaseSell,
			Weight = definition.Weight,
			Bulk = definition.Bulk,
			ShapeTag = definition.ShapeTag,
			Size = definition.Size,
			Color = definition.Color,
			ModelKind = definition.ModelKind,
			Core = definition.Core,
			HeroMinRarity = definition.HeroMinRarity,
			SectionId = sectionId,
			SectionIndex = sectionDefinition.Index,
			SectionEconomicScale = sectionDefinition.EconomicScale,
		})
		if definition.Core then table.insert(coreBySection[sectionId], definition.Id) else table.insert(heroBySection[sectionId], definition.Id) end
	end
	table.freeze(coreBySection[sectionId])
	table.freeze(heroBySection[sectionId])
end

table.freeze(byId)
table.freeze(coreBySection)
table.freeze(heroBySection)

local LootCatalog = {
	Sections = sections,
	ById = byId,
	CoreBySection = coreBySection,
	HeroBySection = heroBySection,
	SectionOrder = SectionConfig.Order,
}

function LootCatalog.Get(itemId: string)
	return byId[itemId]
end

return table.freeze(LootCatalog)
