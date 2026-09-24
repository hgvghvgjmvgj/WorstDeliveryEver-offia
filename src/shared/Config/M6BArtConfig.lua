--!strict

local function style(family: string, base: Color3, secondary: Color3, accent: Color3, material: Enum.Material)
	return table.freeze({
		Family = family,
		Base = base,
		Secondary = secondary,
		Accent = accent,
		Material = material,
	})
end

-- M6B visual foundation: stylized, chunky, colorful, clean Roblox art.
-- MODEL SHAPE > COLOR > LIGHTING > SIMPLE MATERIAL > TEXTURE.
local SectionStyles = table.freeze({
	Receiving = style("PalletRack", Color3.fromRGB(66, 84, 103), Color3.fromRGB(76, 125, 176), Color3.fromRGB(245, 194, 66), Enum.Material.Metal),
	HomeBasics = style("HomeShelf", Color3.fromRGB(117, 83, 60), Color3.fromRGB(185, 126, 73), Color3.fromRGB(239, 171, 85), Enum.Material.WoodPlanks),
	Appliances = style("ApplianceBay", Color3.fromRGB(78, 92, 108), Color3.fromRGB(119, 145, 172), Color3.fromRGB(111, 197, 233), Enum.Material.Metal),
	Furniture = style("FurnitureBay", Color3.fromRGB(110, 79, 62), Color3.fromRGB(155, 108, 78), Color3.fromRGB(104, 183, 156), Enum.Material.WoodPlanks),
	Electronics = style("TechShelf", Color3.fromRGB(42, 53, 72), Color3.fromRGB(55, 95, 133), Color3.fromRGB(62, 209, 236), Enum.Material.Metal),
	Recreation = style("RecreationBay", Color3.fromRGB(74, 68, 97), Color3.fromRGB(104, 88, 144), Color3.fromRGB(112, 220, 118), Enum.Material.SmoothPlastic),
	GarageAuto = style("GarageRack", Color3.fromRGB(59, 61, 66), Color3.fromRGB(145, 55, 48), Color3.fromRGB(244, 185, 55), Enum.Material.Metal),
	Construction = style("ConstructionRack", Color3.fromRGB(82, 83, 77), Color3.fromRGB(197, 130, 45), Color3.fromRGB(248, 194, 57), Enum.Material.Metal),
	HeavyGoods = style("HeavyPad", Color3.fromRGB(67, 72, 75), Color3.fromRGB(92, 102, 103), Color3.fromRGB(238, 174, 55), Enum.Material.Metal),
	Industrial = style("IndustrialCell", Color3.fromRGB(57, 70, 73), Color3.fromRGB(61, 105, 109), Color3.fromRGB(58, 194, 191), Enum.Material.Metal),
	PremiumInteriors = style("PremiumBay", Color3.fromRGB(144, 129, 113), Color3.fromRGB(212, 195, 166), Color3.fromRGB(229, 180, 87), Enum.Material.SmoothPlastic),
	LuxuryGoods = style("LuxuryCabinet", Color3.fromRGB(37, 35, 40), Color3.fromRGB(86, 47, 54), Color3.fromRGB(224, 176, 79), Enum.Material.Metal),
	ArtCollectibles = style("GalleryStorage", Color3.fromRGB(63, 52, 71), Color3.fromRGB(103, 70, 118), Color3.fromRGB(205, 146, 229), Enum.Material.SmoothPlastic),
	Secure = style("SecureCell", Color3.fromRGB(45, 52, 61), Color3.fromRGB(61, 82, 105), Color3.fromRGB(94, 173, 231), Enum.Material.Metal),
	RestrictedPrototype = style("ContainmentFrame", Color3.fromRGB(38, 44, 51), Color3.fromRGB(105, 46, 62), Color3.fromRGB(50, 216, 221), Enum.Material.Metal),
})

return table.freeze({
	SectionStyles = SectionStyles,
	MainAisleHalfWidth = 19,
	StorageOpeningPadding = 4.5,
	SlotStatus = table.freeze({
		VacantColor = Color3.fromRGB(232, 145, 55),
		VacantTransparency = 0.28,
		OccupiedTransparency = 0.52,
		RestockFlashTransparency = 0.02,
	}),
	Performance = table.freeze({
		MaximumDecorativePartsPerSlot = 7,
		UsePerSlotPointLights = false,
		UseTextures = false,
	}),
})
