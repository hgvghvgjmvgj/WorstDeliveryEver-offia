--!strict

local function part(name: string, kind: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, rotation: Vector3?, transparency: number?)
	return table.freeze({
		Name = name,
		Type = kind,
		Size = size,
		Position = position,
		Rotation = rotation or Vector3.zero,
		Color = color,
		Material = material,
		Transparency = transparency or 0,
	})
end

local SMOOTH = Enum.Material.SmoothPlastic
local METAL = Enum.Material.Metal
local GLASS = Enum.Material.Glass
local NEON = Enum.Material.Neon

local Recipes = table.freeze({
	ShippingBox = table.freeze({
		SectionId = "Receiving", Family = "CRATE", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("Body","Block",Vector3.new(3.2,3.2,3.2),Vector3.zero,Color3.fromRGB(202,151,93),SMOOTH),
			part("TapeTop","Block",Vector3.new(0.42,0.10,3.28),Vector3.new(0,1.63,0),Color3.fromRGB(235,205,145),SMOOTH),
			part("TapeFront","Block",Vector3.new(0.42,3.0,0.10),Vector3.new(0,0,-1.63),Color3.fromRGB(235,205,145),SMOOTH),
			part("Label","Block",Vector3.new(1.25,0.82,0.08),Vector3.new(0.65,0.35,-1.67),Color3.fromRGB(237,239,232),SMOOTH),
			part("BottomBand","Block",Vector3.new(3.28,0.14,3.28),Vector3.new(0,-1.54,0),Color3.fromRGB(152,105,61),SMOOTH),
		}),
	}),

	Refrigerator = table.freeze({
		SectionId = "Appliances", Family = "APPLIANCE", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("Body","Block",Vector3.new(4.6,8.0,4.4),Vector3.zero,Color3.fromRGB(206,211,215),SMOOTH),
			part("LeftDoor","Block",Vector3.new(2.08,7.45,0.30),Vector3.new(-1.08,0,-2.29),Color3.fromRGB(232,236,239),SMOOTH),
			part("RightDoor","Block",Vector3.new(2.08,7.45,0.30),Vector3.new(1.08,0,-2.29),Color3.fromRGB(232,236,239),SMOOTH),
			part("HandleL","Block",Vector3.new(0.20,4.2,0.26),Vector3.new(-0.33,0,-2.53),Color3.fromRGB(69,75,82),METAL),
			part("HandleR","Block",Vector3.new(0.20,4.2,0.26),Vector3.new(0.33,0,-2.53),Color3.fromRGB(69,75,82),METAL),
			part("Display","Block",Vector3.new(0.85,0.62,0.12),Vector3.new(1.03,1.65,-2.56),Color3.fromRGB(53,142,181),NEON),
			part("KickPlate","Block",Vector3.new(3.95,0.42,0.18),Vector3.new(0,-3.62,-2.40),Color3.fromRGB(91,98,104),METAL),
		}),
	}),

	Couch = table.freeze({
		SectionId = "Furniture", Family = "FURNITURE", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("SeatBase","Block",Vector3.new(9.5,1.15,3.55),Vector3.new(0,-0.45,0.10),Color3.fromRGB(74,124,170),SMOOTH),
			part("BackFrame","Block",Vector3.new(9.35,2.75,0.72),Vector3.new(0,1.15,1.38),Color3.fromRGB(67,113,157),SMOOTH,Vector3.new(-7,0,0)),
			part("ArmL","Block",Vector3.new(0.82,2.25,3.72),Vector3.new(-4.75,0.25,0.04),Color3.fromRGB(61,105,147),SMOOTH),
			part("ArmR","Block",Vector3.new(0.82,2.25,3.72),Vector3.new(4.75,0.25,0.04),Color3.fromRGB(61,105,147),SMOOTH),
			part("Seat1","Block",Vector3.new(2.75,0.58,2.80),Vector3.new(-3.0,0.25,-0.12),Color3.fromRGB(96,151,196),SMOOTH),
			part("Seat2","Block",Vector3.new(2.75,0.58,2.80),Vector3.new(0,0.25,-0.12),Color3.fromRGB(101,157,201),SMOOTH),
			part("Seat3","Block",Vector3.new(2.75,0.58,2.80),Vector3.new(3.0,0.25,-0.12),Color3.fromRGB(96,151,196),SMOOTH),
			part("Back1","Block",Vector3.new(2.72,1.75,0.56),Vector3.new(-3.0,1.18,1.04),Color3.fromRGB(99,153,197),SMOOTH,Vector3.new(-8,0,0)),
			part("Back2","Block",Vector3.new(2.72,1.75,0.56),Vector3.new(0,1.18,1.04),Color3.fromRGB(104,159,202),SMOOTH,Vector3.new(-8,0,0)),
			part("Back3","Block",Vector3.new(2.72,1.75,0.56),Vector3.new(3.0,1.18,1.04),Color3.fromRGB(99,153,197),SMOOTH,Vector3.new(-8,0,0)),
			part("FootL","Block",Vector3.new(0.45,0.55,0.45),Vector3.new(-4.0,-1.85,1.15),Color3.fromRGB(59,46,38),METAL),
			part("FootR","Block",Vector3.new(0.45,0.55,0.45),Vector3.new(4.0,-1.85,1.15),Color3.fromRGB(59,46,38),METAL),
	}),
	}),

	GamingPC = table.freeze({
		SectionId = "Electronics", Family = "TECH", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("Chassis","Block",Vector3.new(3.2,6.2,3.0),Vector3.zero,Color3.fromRGB(43,49,62),SMOOTH),
			part("GlassSide","Block",Vector3.new(0.12,5.35,2.45),Vector3.new(-1.66,0,-0.08),Color3.fromRGB(78,142,171),GLASS,nil,0.34),
			part("FrontPanel","Block",Vector3.new(2.55,5.40,0.18),Vector3.new(0,0,-1.58),Color3.fromRGB(28,33,43),SMOOTH),
			part("Fan1","Cylinder",Vector3.new(0.20,0.95,0.95),Vector3.new(0,1.65,-1.72),Color3.fromRGB(70,215,235),NEON,Vector3.new(0,0,90)),
			part("Fan2","Cylinder",Vector3.new(0.20,0.95,0.95),Vector3.new(0,0.15,-1.72),Color3.fromRGB(70,215,235),NEON,Vector3.new(0,0,90)),
			part("Fan3","Cylinder",Vector3.new(0.20,0.95,0.95),Vector3.new(0,-1.35,-1.72),Color3.fromRGB(70,215,235),NEON,Vector3.new(0,0,90)),
			part("GPU","Block",Vector3.new(2.10,0.55,0.72),Vector3.new(-0.15,-0.15,-0.15),Color3.fromRGB(93,55,143),METAL),
			part("Motherboard","Block",Vector3.new(0.16,2.65,2.10),Vector3.new(-1.38,0.55,0.10),Color3.fromRGB(40,75,72),SMOOTH),
			part("PSU","Block",Vector3.new(2.40,1.0,2.20),Vector3.new(0,-2.35,0.10),Color3.fromRGB(31,34,39),METAL),
			part("TopVent","Block",Vector3.new(2.45,0.12,1.75),Vector3.new(0,3.16,0.25),Color3.fromRGB(79,85,94),METAL),
	}),
	}),

	ArcadeCabinet = table.freeze({
		SectionId = "Recreation", Family = "TECH", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("Body","Block",Vector3.new(4.8,8.0,4.2),Vector3.new(0,-0.15,0.18),Color3.fromRGB(74,52,104),SMOOTH),
			part("Marquee","Block",Vector3.new(4.55,1.05,0.50),Vector3.new(0,3.52,-1.93),Color3.fromRGB(180,70,232),NEON),
			part("Screen","Block",Vector3.new(3.70,2.65,0.18),Vector3.new(0,1.35,-2.18),Color3.fromRGB(35,78,112),GLASS,nil,0.08),
			part("ControlDeck","Wedge",Vector3.new(4.25,0.95,1.55),Vector3.new(0,-0.45,-1.78),Color3.fromRGB(49,37,70),SMOOTH,Vector3.new(0,180,0)),
			part("JoystickStem","Block",Vector3.new(0.16,0.52,0.16),Vector3.new(-0.8,0.15,-2.42),Color3.fromRGB(47,48,54),METAL),
			part("JoystickBall","Ball",Vector3.new(0.35,0.35,0.35),Vector3.new(-0.8,0.45,-2.42),Color3.fromRGB(235,70,91),SMOOTH),
			part("ButtonA","Ball",Vector3.new(0.26,0.26,0.26),Vector3.new(0.55,0.12,-2.45),Color3.fromRGB(70,216,233),NEON),
			part("ButtonB","Ball",Vector3.new(0.26,0.26,0.26),Vector3.new(0.95,0.12,-2.45),Color3.fromRGB(238,178,55),NEON),
	}),
	}),

	ShowCarEngine = table.freeze({
		SectionId = "GarageAuto", Family = "MACHINE", ModelSource = "MODEL_BUILDER_HERO",
		Parts = table.freeze({
			part("Block","Block",Vector3.new(4.7,3.3,4.2),Vector3.new(0,-0.35,0),Color3.fromRGB(74,78,82),METAL),
			part("HeadL","Block",Vector3.new(1.65,1.25,3.75),Vector3.new(-1.85,1.10,0),Color3.fromRGB(111,116,121),METAL,Vector3.new(0,0,-10)),
			part("HeadR","Block",Vector3.new(1.65,1.25,3.75),Vector3.new(1.85,1.10,0),Color3.fromRGB(111,116,121),METAL,Vector3.new(0,0,10)),
			part("Intake","Block",Vector3.new(2.30,0.95,2.30),Vector3.new(0,1.80,0),Color3.fromRGB(43,48,53),METAL),
			part("AirStack","Cylinder",Vector3.new(1.05,1.05,1.05),Vector3.new(0,2.52,0),Color3.fromRGB(186,192,197),METAL,Vector3.new(90,0,0)),
			part("Pulley1","Cylinder",Vector3.new(0.48,1.35,1.35),Vector3.new(-1.0,-0.25,-2.28),Color3.fromRGB(38,41,45),METAL,Vector3.new(0,0,90)),
			part("Pulley2","Cylinder",Vector3.new(0.48,1.05,1.05),Vector3.new(0.85,-0.55,-2.28),Color3.fromRGB(38,41,45),METAL,Vector3.new(0,0,90)),
			part("ValveCoverL","Block",Vector3.new(1.38,0.60,3.2),Vector3.new(-1.8,1.62,0),Color3.fromRGB(177,58,51),METAL,Vector3.new(0,0,-10)),
			part("ValveCoverR","Block",Vector3.new(1.38,0.60,3.2),Vector3.new(1.8,1.62,0),Color3.fromRGB(177,58,51),METAL,Vector3.new(0,0,10)),
	}),
	}),

	EngineBlock = table.freeze({
		SectionId = "Industrial", Family = "MACHINE", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("MainBlock","Block",Vector3.new(4.8,3.0,3.8),Vector3.new(0,-0.45,0),Color3.fromRGB(78,82,84),METAL),
			part("Head","Block",Vector3.new(4.55,1.10,3.45),Vector3.new(0,1.20,0),Color3.fromRGB(103,109,112),METAL),
			part("TopCover","Block",Vector3.new(3.6,0.55,2.65),Vector3.new(0,2.00,0),Color3.fromRGB(58,65,70),METAL),
			part("Shaft","Cylinder",Vector3.new(0.65,1.35,1.35),Vector3.new(0,-0.45,-2.20),Color3.fromRGB(41,44,47),METAL,Vector3.new(0,0,90)),
			part("PipeL","Cylinder",Vector3.new(2.3,0.42,0.42),Vector3.new(-2.15,0.55,0.45),Color3.fromRGB(92,100,104),METAL,Vector3.new(0,0,90)),
			part("PipeR","Cylinder",Vector3.new(2.3,0.42,0.42),Vector3.new(2.15,0.55,0.45),Color3.fromRGB(92,100,104),METAL,Vector3.new(0,0,90)),
			part("StatusPanel","Block",Vector3.new(1.35,0.68,0.14),Vector3.new(1.2,0.55,-1.98),Color3.fromRGB(51,145,164),NEON),
	}),
	}),

	DesignerFragranceTrunk = table.freeze({
		SectionId = "LuxuryGoods", Family = "LUXURY", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("Case","Block",Vector3.new(8.0,4.8,5.0),Vector3.zero,Color3.fromRGB(75,45,64),SMOOTH),
			part("FrontFrame","Block",Vector3.new(7.4,3.65,0.36),Vector3.new(0,0.10,-2.62),Color3.fromRGB(37,24,36),SMOOTH),
			part("Glass","Block",Vector3.new(6.5,2.70,0.16),Vector3.new(0,0.10,-2.84),Color3.fromRGB(176,214,235),GLASS,nil,0.30),
			part("TopTrim","Block",Vector3.new(8.18,0.24,0.28),Vector3.new(0,2.28,-2.60),Color3.fromRGB(184,142,67),METAL),
			part("BottomTrim","Block",Vector3.new(8.18,0.24,0.28),Vector3.new(0,-2.28,-2.60),Color3.fromRGB(184,142,67),METAL),
			part("ClaspL","Block",Vector3.new(0.62,1.05,0.32),Vector3.new(-2.45,-0.38,-2.78),Color3.fromRGB(215,169,77),METAL),
			part("ClaspR","Block",Vector3.new(0.62,1.05,0.32),Vector3.new(2.45,-0.38,-2.78),Color3.fromRGB(215,169,77),METAL),
			part("BottleA","Block",Vector3.new(1.0,1.85,0.75),Vector3.new(-2.15,0.15,-2.98),Color3.fromRGB(210,92,118),GLASS,nil,0.10),
			part("BottleB","Cylinder",Vector3.new(0.95,1.95,0.95),Vector3.new(-0.75,0.12,-2.98),Color3.fromRGB(237,165,71),GLASS,Vector3.new(0,0,90),0.10),
			part("BottleC","Block",Vector3.new(1.0,2.25,0.75),Vector3.new(0.75,0.30,-2.98),Color3.fromRGB(79,153,223),GLASS,nil,0.10),
			part("BottleD","Cylinder",Vector3.new(0.95,1.80,0.95),Vector3.new(2.15,0.05,-2.98),Color3.fromRGB(147,91,196),GLASS,Vector3.new(0,0,90),0.10),
			part("BottleCapA","Block",Vector3.new(0.62,0.28,0.62),Vector3.new(-2.15,1.20,-2.98),Color3.fromRGB(218,178,88),METAL),
			part("BottleCapC","Block",Vector3.new(0.62,0.28,0.62),Vector3.new(0.75,1.58,-2.98),Color3.fromRGB(218,178,88),METAL),
	}),
	}),

	PaintingTransportCrate = table.freeze({
		SectionId = "ArtCollectibles", Family = "ART", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("Crate","Block",Vector3.new(9.0,7.5,2.5),Vector3.zero,Color3.fromRGB(151,111,71),SMOOTH),
			part("OuterFrame","Block",Vector3.new(8.55,7.0,0.24),Vector3.new(0,0,-1.38),Color3.fromRGB(90,62,41),METAL),
			part("InnerPanel","Block",Vector3.new(7.45,5.85,0.18),Vector3.new(0,0,-1.52),Color3.fromRGB(187,151,99),SMOOTH),
			part("BraceA","Block",Vector3.new(0.28,8.6,0.18),Vector3.new(0,0,-1.64),Color3.fromRGB(102,70,44),METAL,Vector3.new(0,0,50)),
			part("BraceB","Block",Vector3.new(0.28,8.6,0.18),Vector3.new(0,0,-1.64),Color3.fromRGB(102,70,44),METAL,Vector3.new(0,0,-50)),
			part("MuseumLabel","Block",Vector3.new(2.7,0.95,0.08),Vector3.new(2.5,-2.35,-1.70),Color3.fromRGB(235,224,197),SMOOTH),
	}),
	}),

	JewelrySafe = table.freeze({
		SectionId = "Secure", Family = "SECURE", ModelSource = "MODEL_BUILDER",
		Parts = table.freeze({
			part("SafeBody","Block",Vector3.new(5.0,5.8,4.8),Vector3.zero,Color3.fromRGB(73,79,88),METAL),
			part("Door","Block",Vector3.new(4.35,5.0,0.42),Vector3.new(0,0,-2.58),Color3.fromRGB(86,94,104),METAL),
			part("LockWheel","Cylinder",Vector3.new(0.34,1.48,1.48),Vector3.new(0.55,0.15,-2.84),Color3.fromRGB(166,174,181),METAL,Vector3.new(0,0,90)),
			part("SpokeH","Block",Vector3.new(1.85,0.16,0.16),Vector3.new(0.55,0.15,-3.03),Color3.fromRGB(46,50,56),METAL),
			part("SpokeV","Block",Vector3.new(0.16,1.85,0.16),Vector3.new(0.55,0.15,-3.03),Color3.fromRGB(46,50,56),METAL),
			part("Keypad","Block",Vector3.new(0.72,1.0,0.20),Vector3.new(-1.25,0.35,-2.84),Color3.fromRGB(38,46,52),SMOOTH),
			part("Status","Block",Vector3.new(0.46,0.18,0.08),Vector3.new(-1.25,0.77,-2.96),Color3.fromRGB(68,194,129),NEON),
	}),
	}),

	BlackProjectContainmentUnit = table.freeze({
		SectionId = "RestrictedPrototype", Family = "PROTOTYPE", ModelSource = "MODEL_BUILDER_HERO",
		Parts = table.freeze({
			part("BaseCradle","Block",Vector3.new(6.2,1.15,6.2),Vector3.new(0,-3.40,0),Color3.fromRGB(38,47,54),METAL),
			part("TopFrame","Block",Vector3.new(6.0,0.85,6.0),Vector3.new(0,3.55,0),Color3.fromRGB(43,53,61),METAL),
			part("PillarFL","Block",Vector3.new(0.62,6.8,0.62),Vector3.new(-2.65,0,-2.65),Color3.fromRGB(45,57,65),METAL),
			part("PillarFR","Block",Vector3.new(0.62,6.8,0.62),Vector3.new(2.65,0,-2.65),Color3.fromRGB(45,57,65),METAL),
			part("PillarBL","Block",Vector3.new(0.62,6.8,0.62),Vector3.new(-2.65,0,2.65),Color3.fromRGB(45,57,65),METAL),
			part("PillarBR","Block",Vector3.new(0.62,6.8,0.62),Vector3.new(2.65,0,2.65),Color3.fromRGB(45,57,65),METAL),
			part("Core","Ball",Vector3.new(2.25,2.25,2.25),Vector3.new(0,0.25,0),Color3.fromRGB(86,221,237),NEON,nil,0.04),
			part("StabilizerL","Block",Vector3.new(2.1,0.45,0.45),Vector3.new(-1.95,0.25,0),Color3.fromRGB(128,72,162),METAL),
			part("StabilizerR","Block",Vector3.new(2.1,0.45,0.45),Vector3.new(1.95,0.25,0),Color3.fromRGB(128,72,162),METAL),
			part("StabilizerF","Block",Vector3.new(0.45,0.45,2.1),Vector3.new(0,0.25,-1.95),Color3.fromRGB(128,72,162),METAL),
			part("StabilizerB","Block",Vector3.new(0.45,0.45,2.1),Vector3.new(0,0.25,1.95),Color3.fromRGB(128,72,162),METAL),
			part("StatusPanel","Block",Vector3.new(2.0,1.05,0.18),Vector3.new(0,-1.85,-3.05),Color3.fromRGB(34,50,59),SMOOTH),
			part("WarningStrip","Block",Vector3.new(1.45,0.14,0.08),Vector3.new(0,-1.55,-3.17),Color3.fromRGB(230,71,89),NEON),
	}),
	}),
})

local Order = table.freeze({
	"ShippingBox",
	"Refrigerator",
	"Couch",
	"GamingPC",
	"ArcadeCabinet",
	"ShowCarEngine",
	"EngineBlock",
	"DesignerFragranceTrunk",
	"PaintingTransportCrate",
	"JewelrySafe",
	"BlackProjectContainmentUnit",
})

return table.freeze({
	Order = Order,
	Recipes = Recipes,
})
