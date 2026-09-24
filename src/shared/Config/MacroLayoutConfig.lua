--!strict

local function frozen<T>(value: T): T
	return table.freeze(value)
end

local SECTION_ORDER = frozen({ "Receiving", "Appliances", "Furniture", "HeavyGoods", "Industrial", "Secure" })

local SECTION_META = frozen({
	Receiving = frozen({
		Index = 1,
		DisplayName = "RECEIVING & GENERAL STORAGE",
		Color = Color3.fromRGB(76, 92, 104),
		Depth = 1,
		FallbackItemId = "Box",
	}),
	Appliances = frozen({
		Index = 2,
		DisplayName = "APPLIANCES & ELECTRONICS",
		Color = Color3.fromRGB(70, 91, 116),
		Depth = 1,
		FallbackItemId = "TV",
	}),
	Furniture = frozen({
		Index = 3,
		DisplayName = "FURNITURE & OVERSIZED",
		Color = Color3.fromRGB(104, 83, 68),
		Depth = 2,
		FallbackItemId = "Chair",
	}),
	HeavyGoods = frozen({
		Index = 4,
		DisplayName = "HEAVY GOODS & EQUIPMENT",
		Color = Color3.fromRGB(93, 89, 73),
		Depth = 2,
		FallbackItemId = "Tire",
	}),
	Industrial = frozen({
		Index = 5,
		DisplayName = "INDUSTRIAL STORAGE",
		Color = Color3.fromRGB(82, 86, 78),
		Depth = 3,
		FallbackItemId = "Tire",
	}),
	Secure = frozen({
		Index = 6,
		DisplayName = "SECURE HIGH-VALUE STORAGE",
		Color = Color3.fromRGB(79, 73, 70),
		Depth = 3,
		FallbackItemId = "TV",
	}),
})

local B_SECTION_CENTERS = frozen({
	Receiving = 245,
	Appliances = 155,
	Furniture = 65,
	HeavyGoods = -25,
	Industrial = -115,
	Secure = -205,
})

local C_RINGS = frozen({
	Receiving = frozen({ Inner = 132, Outer = 176 }),
	Appliances = frozen({ Inner = 186, Outer = 234 }),
	Furniture = frozen({ Inner = 244, Outer = 302 }),
	HeavyGoods = frozen({ Inner = 312, Outer = 362 }),
	Industrial = frozen({ Inner = 372, Outer = 430 }),
	Secure = frozen({ Inner = 440, Outer = 500 }),
})

local D_SECTION_CENTERS = frozen({
	Receiving = 212,
	Appliances = 124,
	Furniture = 36,
	HeavyGoods = -52,
	Industrial = -140,
	Secure = -228,
})

local Config = {
	-- M6A comparison mode. A/B/C remain recoverable while M6A.1 tests D.
	-- Workspace attribute `M6LayoutMode` may override this before Play starts.
	DefaultMode = "D",
	SectionOrder = SECTION_ORDER,
	Sections = SECTION_META,

	OptionA = frozen({
		Name = "CURRENT WIDE WAREHOUSE",
		Description = "M5A baseline; preserved exactly through legacy WorldService.",
	}),

	OptionB = frozen({
		Name = "LONG PROGRESSION SPINE",
		Footprint = Vector3.new(520, 1, 900),
		WallHeight = 32,
		HubCenter = Vector3.new(0, 0, 356),
		HubSize = Vector3.new(490, 0.12, 92),
		FreightStartZ = 310,
		FreightEndZ = -254,
		FreightWidth = 36,
		ServiceWidth = 17,
		SectionDepth = 80,
		SectionWidth = 450,
		SectionCenters = B_SECTION_CENTERS,
		BayStartX = -242,
		BaySpacing = 44,
		BayZ = 405,
		FallbackSpawnPosition = Vector3.new(0, 3, 335),
	}),

	OptionC = frozen({
		Name = "POLYGONAL CONCENTRIC WAREHOUSE",
		Footprint = Vector3.new(1040, 1, 1040),
		WallHeight = 34,
		HubRadius = 118,
		BayRadius = 94,
		OuterRadius = 510,
		PolygonSides = 16,
		FreightWidth = 38,
		ServiceWidth = 15,
		SpokeAnglesDegrees = frozen({ 0, 90, 180, 270 }),
		ServiceAnglesDegrees = frozen({ 45, 135, 225, 315 }),
		Rings = C_RINGS,
		FallbackSpawnPosition = Vector3.new(0, 3, 0),
	}),

	OptionD = frozen({
		Name = "SHARED WAREHOUSE RUNWAY",
		RunwayWidth = 176,
		RunwayFrontZ = 256,
		RunwayBackZ = -272,
		RunwayLength = 528,
		SectionDepth = 88,
		SectionCenters = D_SECTION_CENTERS,
		FreightWidth = 38,
		StoragePathWidth = 14,
		CrossAisleWidth = 18,
		WallHeight = 32,

		HomeApronCenter = Vector3.new(0, 0, 325),
		HomeApronSize = Vector3.new(380, 0.12, 150),
		HomeReferenceZ = 265,
		SharedDepartureZ = 266,
		BayOuterX = 130,
		BayInnerX = 78,
		BayRowsZ = frozen({ 360, 320, 280 }),
		BayLookTarget = Vector3.new(0, 0, 250),
		FallbackSpawnPosition = Vector3.new(0, 3, 270),

		MarkersPerSection = 16,
		SharedFocalMarkersPerSection = 4,
	}),
}

function Config.ResolveMode(value: any): string
	if value == "A" or value == "B" or value == "C" or value == "D" then
		return value
	end
	return Config.DefaultMode
end

return table.freeze(Config)
