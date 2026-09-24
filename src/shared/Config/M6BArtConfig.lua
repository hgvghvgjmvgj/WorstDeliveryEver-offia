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
--
-- Storage progression is intentional:
-- 1-3 normal warehouse -> 4-6 specialized commercial -> 7-9 heavy industrial
-- -> 10 advanced industrial -> 11-12 premium/luxury -> 13 collector
-- -> 14 vault -> 15 experimental containment.
local SectionStyles = table.freeze({
	Receiving = style("ReceivingDepartment", Color3.fromRGB(65, 78, 91), Color3.fromRGB(72, 118, 166), Color3.fromRGB(245, 193, 62), Enum.Material.Metal, Color3.fromRGB(255, 244, 220), 18),
	HomeBasics = style("HomeDepartment", Color3.fromRGB(117, 84, 61), Color3.fromRGB(201, 178, 139), Color3.fromRGB(228, 143, 71), Enum.Material.WoodPlanks, Color3.fromRGB(255, 220, 176), 13.5),
	Appliances = style("ApplianceDepartment", Color3.fromRGB(78, 91, 107), Color3.fromRGB(198, 207, 214), Color3.fromRGB(91, 180, 228), Enum.Material.Metal, Color3.fromRGB(205, 235, 255), 20.5),

	Furniture = style("FurnitureShowroomBay", Color3.fromRGB(110, 79, 62), Color3.fromRGB(155, 108, 78), Color3.fromRGB(104, 183, 156), Enum.Material.WoodPlanks, Color3.fromRGB(244, 220, 190), 17),
	Electronics = style("OrganizedTechCell", Color3.fromRGB(42, 53, 72), Color3.fromRGB(55, 95, 133), Color3.fromRGB(62, 209, 236), Enum.Material.Metal, Color3.fromRGB(190, 226, 255), 18.5),
	Recreation = style("RecreationDisplaySystem", Color3.fromRGB(74, 68, 97), Color3.fromRGB(104, 88, 144), Color3.fromRGB(112, 220, 118), Enum.Material.SmoothPlastic, Color3.fromRGB(226, 210, 255), 17.2),
	GarageAuto = style("AutomotiveHeavyRack", Color3.fromRGB(59, 61, 66), Color3.fromRGB(145, 55, 48), Color3.fromRGB(244, 185, 55), Enum.Material.Metal, Color3.fromRGB(255, 225, 185), 19),
	Construction = style("CommercialScaffoldStorage", Color3.fromRGB(82, 83, 77), Color3.fromRGB(197, 130, 45), Color3.fromRGB(248, 194, 57), Enum.Material.Metal, Color3.fromRGB(255, 232, 185), 21),
	HeavyGoods = style("MassiveEquipmentCradle", Color3.fromRGB(67, 72, 75), Color3.fromRGB(92, 102, 103), Color3.fromRGB(238, 174, 55), Enum.Material.Metal, Color3.fromRGB(220, 230, 235), 23),
	Industrial = style("EngineeredMachineryCell", Color3.fromRGB(57, 70, 73), Color3.fromRGB(61, 105, 109), Color3.fromRGB(58, 194, 191), Enum.Material.Metal, Color3.fromRGB(190, 235, 232), 28),
	PremiumInteriors = style("ProtectedPremiumBay", Color3.fromRGB(83, 75, 68), Color3.fromRGB(190, 171, 145), Color3.fromRGB(229, 180, 87), Enum.Material.SmoothPlastic, Color3.fromRGB(255, 229, 196), 19.5),
	LuxuryGoods = style("LuxuryVaultShowroomStorage", Color3.fromRGB(37, 35, 40), Color3.fromRGB(86, 47, 54), Color3.fromRGB(224, 176, 79), Enum.Material.Metal, Color3.fromRGB(244, 216, 180), 20.5),
	ArtCollectibles = style("MuseumBackroomStorage", Color3.fromRGB(63, 52, 71), Color3.fromRGB(103, 70, 118), Color3.fromRGB(205, 146, 229), Enum.Material.SmoothPlastic, Color3.fromRGB(238, 222, 255), 21),
	Secure = style("ArmoredVaultCell", Color3.fromRGB(45, 52, 61), Color3.fromRGB(61, 82, 105), Color3.fromRGB(94, 173, 231), Enum.Material.Metal, Color3.fromRGB(195, 225, 255), 23),
	RestrictedPrototype = style("ExperimentalContainmentDock", Color3.fromRGB(38, 44, 51), Color3.fromRGB(105, 46, 62), Color3.fromRGB(50, 216, 221), Enum.Material.Metal, Color3.fromRGB(180, 230, 235), 27),
})

return table.freeze({
	SectionStyles = SectionStyles,

	-- The approved first-three service remains intentionally isolated so later
	-- work cannot accidentally redesign it while Sections 4-15 evolve.
	ProofSections = table.freeze({
		Receiving = true,
		HomeBasics = true,
		Appliances = true,
	}),

	DepthBands = table.freeze({
		Furniture = "SPECIALIZED_COMMERCIAL",
		Electronics = "SPECIALIZED_COMMERCIAL",
		Recreation = "SPECIALIZED_COMMERCIAL",
		GarageAuto = "HEAVY_INDUSTRIAL",
		Construction = "HEAVY_INDUSTRIAL",
		HeavyGoods = "HEAVY_INDUSTRIAL",
		Industrial = "ADVANCED_INDUSTRIAL",
		PremiumInteriors = "PREMIUM",
		LuxuryGoods = "LUXURY",
		ArtCollectibles = "COLLECTOR",
		Secure = "VAULT",
		RestrictedPrototype = "EXPERIMENTAL",
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
