--!strict

local SectionConfig = require(script.Parent:WaitForChild("SectionConfig"))

local function frozen<T>(value: T): T
	return table.freeze(value)
end

-- A/B/C remain temporarily recoverable for comparison/debug, so their old six
-- section traversal list stays isolated from the 15-section launch runway.
local LEGACY_SECTION_ORDER = frozen({ "Receiving", "Appliances", "Furniture", "HeavyGoods", "Industrial", "Secure" })

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

local runwayFrontZ = 256
local runwayBackZ = runwayFrontZ - SectionConfig.TotalLength

local Config = {
	DefaultMode = "D",

	-- Legacy comparison compatibility.
	SectionOrder = LEGACY_SECTION_ORDER,
	LaunchSectionOrder = SectionConfig.Order,
	Sections = SectionConfig.Sections,

	OptionA = frozen({
		Name = "CURRENT WIDE WAREHOUSE",
		Description = "M5A baseline; preserved through legacy WorldService.",
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
		Name = "15-SECTION SHARED WAREHOUSE RUNWAY",
		SectionOrder = SectionConfig.Order,
		RunwayWidth = 176,
		RunwayFrontZ = runwayFrontZ,
		RunwayBackZ = runwayBackZ,
		RunwayLength = SectionConfig.TotalLength,
		FreightWidth = 38,
		StoragePathWidth = 14,
		CrossAisleWidth = 18,
		WallHeight = 34,

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

		-- The playable launch plan is already very deep, but Section 15 still
		-- visually continues into a non-playable future facility instead of ending
		-- on a visible back wall.
		LongTermDepth = frozen({
			FinalLengthLocked = false,
			VisualContinuationLength = 260,
			CurrentPlayableBackZ = runwayBackZ,
			FutureExpansionPurpose = "FutureRunwayExtensionOrAnnex",
		}),
	}),
}

function Config.ResolveMode(value: any): string
	if value == "A" or value == "B" or value == "C" or value == "D" then
		return value
	end
	return Config.DefaultMode
end

return table.freeze(Config)
