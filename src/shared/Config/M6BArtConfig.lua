--!strict

local function style(family: string, base: Color3, secondary: Color3, accent: Color3, material: Enum.Material, lightColor: Color3, overheadHeight: number)
	return table.freeze({
		Family = family,
		Base = base,
		Secondary = secondary,
		Accent = accent,
		Material = material,
		LightColor = lightColor,
		OverheadHeight = overheadHeight,
	})
end

-- M6B visual foundation: stylized, chunky, colorful, clean Roblox art.
-- MODEL SHAPE > COLOR > LIGHTING > SIMPLE MATERIAL > TEXTURE.
local SectionStyles = table.freeze({
	Receiving = style("ReceivingDepartment", Color3.fromRGB(65, 78, 91), Color3.fromRGB(72, 118, 166), Color3.fromRGB(245, 193, 62), Enum.Material.Metal, Color3.fromRGB(255, 244, 220), 18),
	HomeBasics = style("HomeDepartment", Color3.fromRGB(117, 84, 61), Color3.fromRGB(201, 178, 139), Color3.fromRGB(228, 143, 71), Enum.Material.WoodPlanks, Color3.fromRGB(255, 220, 176), 13.5),
	Appliances = style("ApplianceDepartment", Color3.fromRGB(78, 91, 107), Color3.fromRGB(198, 207, 214), Color3.fromRGB(91, 180, 228), Enum.Material.Metal, Color3.fromRGB(205, 235, 255), 20.5),

	-- Reserved palettes/families for later M6B work. The correction pass MUST NOT
	-- build these sections until the first three have visually passed.
	Furniture = style("FurnitureBay", Color3.fromRGB(110, 79, 62), Color3.fromRGB(155, 108, 78), Color3.fromRGB(104, 183, 156), Enum.Material.WoodPlanks, Color3.fromRGB(244, 220, 190), 17),
	Electronics = style("TechShelf", Color3.fromRGB(42, 53, 72), Color3.fromRGB(55, 95, 133), Color3.fromRGB(62, 209, 236), Enum.Material.Metal, Color3.fromRGB(190, 226, 255), 18),
	Recreation = style("RecreationBay", Color3.fromRGB(74, 68, 97), Color3.fromRGB(104, 88, 144), Color3.fromRGB(112, 220, 118), Enum.Material.SmoothPlastic, Color3.fromRGB(226, 210, 255), 17),
	GarageAuto = style("GarageRack", Color3.fromRGB(59, 61, 66), Color3.fromRGB(145, 55, 48), Color3.fromRGB(244, 185, 55), Enum.Material.Metal, Color3.fromRGB(255, 225, 185), 18),
	Construction = style("ConstructionRack", Color3.fromRGB(82, 83, 77), Color3.fromRGB(197, 130, 45), Color3.fromRGB(248, 194, 57), Enum.Material.Metal, Color3.fromRGB(255, 232, 185), 19),
	HeavyGoods = style("HeavyPad", Color3.fromRGB(67, 72, 75), Color3.fromRGB(92, 102, 103), Color3.fromRGB(238, 174, 55), Enum.Material.Metal, Color3.fromRGB(220, 230, 235), 21),
	Industrial = style("IndustrialCell", Color3.fromRGB(57, 70, 73), Color3.fromRGB(61, 105, 109), Color3.fromRGB(58, 194, 191), Enum.Material.Metal, Color3.fromRGB(190, 235, 232), 23),
	PremiumInteriors = style("PremiumBay", Color3.fromRGB(144, 129, 113), Color3.fromRGB(212, 195, 166), Color3.fromRGB(229, 180, 87), Enum.Material.SmoothPlastic, Color3.fromRGB(255, 229, 196), 18),
	LuxuryGoods = style("LuxuryCabinet", Color3.fromRGB(37, 35, 40), Color3.fromRGB(86, 47, 54), Color3.fromRGB(224, 176, 79), Enum.Material.Metal, Color3.fromRGB(244, 216, 180), 19),
	ArtCollectibles = style("GalleryStorage", Color3.fromRGB(63, 52, 71), Color3.fromRGB(103, 70, 118), Color3.fromRGB(205, 146, 229), Enum.Material.SmoothPlastic, Color3.fromRGB(238, 222, 255), 20),
	Secure = style("SecureCell", Color3.fromRGB(45, 52, 61), Color3.fromRGB(61, 82, 105), Color3.fromRGB(94, 173, 231), Enum.Material.Metal, Color3.fromRGB(195, 225, 255), 20),
	RestrictedPrototype = style("ContainmentFrame", Color3.fromRGB(38, 44, 51), Color3.fromRGB(105, 46, 62), Color3.fromRGB(50, 216, 221), Enum.Material.Metal, Color3.fromRGB(180, 230, 235), 23),
})

return table.freeze({
	SectionStyles = SectionStyles,
	ProofSections = table.freeze({
		Receiving = true,
		HomeBasics = true,
		Appliances = true,
	}),
	MainAisleHalfWidth = 19,
	StorageOpeningPadding = 4.5,
	SlotStatus = table.freeze({
		VacantColor = Color3.fromRGB(232, 145, 55),
		VacantTransparency = 0.28,
		OccupiedTransparency = 0.52,
		RestockFlashTransparency = 0.02,
	}),
	Performance = table.freeze({
		UsePerSlotPointLights = false,
		UseTextures = false,
		MaximumDepartmentLightsPerSection = 2,
	}),
})
