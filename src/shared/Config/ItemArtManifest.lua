--!strict

local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))

-- M6C source of truth for cargo art production. The manifest is generated from
-- LootCatalog.ById so every launch BaseItemId is represented automatically.
-- Explicit overrides identify assets that deserve custom-mesh/Blender effort.

local HERO_SOURCE_OVERRIDES = table.freeze({
	GoldenPalletJack = "STUDIO_HERO",
	ModelHomeStarterSet = "STUDIO_HERO",
	PrototypeSmartFridge = "STUDIO_HERO",
	RoyalGrandPiano = "BLENDER_CANDIDATE",
	CreatorCommandCenter = "CUSTOM_MESH_CANDIDATE",
	DeluxeArcadePod = "CUSTOM_MESH_CANDIDATE",
	ShowCarEngine = "BLENDER_CANDIDATE",
	TitanVaultSafe = "CUSTOM_MESH_CANDIDATE",
	CosmicReactorCore = "BLENDER_CANDIDATE",
	BlackProjectContainmentUnit = "BLENDER_CANDIDATE",
	ZeroPointContainmentUnit = "BLENDER_CANDIDATE",
})

local REQUIRED_RARITY_TESTS = table.freeze({
	ShippingBox = true,
	Refrigerator = true,
	Couch = true,
	GamingPC = true,
	ArcadeCabinet = true,
	ShowCarEngine = true,
	EngineBlock = true,
	DesignerFragranceTrunk = true,
	PaintingTransportCrate = true,
	ArtworkCrate = true,
	JewelrySafe = true,
	BlackProjectContainmentUnit = true,
	ExperimentalPowerCore = true,
})

local function rarityStrategy(base: any): string
	local sectionId = tostring(base.SectionId or "")
	local kind = tostring(base.ModelKind or "Legacy")
	if sectionId == "LuxuryGoods" then return "LUXURY_TRIM+DISPLAY+LIGHTS" end
	if sectionId == "ArtCollectibles" then return "COLLECTOR_FRAME+PRESTIGE_GEOMETRY" end
	if sectionId == "Secure" then return "ARMORED_TRIM+SECURITY_GEOMETRY" end
	if sectionId == "RestrictedPrototype" then return "CONTAINMENT+ENERGY_GEOMETRY" end
	if kind == "Engine" or kind == "Machine" or kind == "Core" then return "MECHANICAL_MODULES+ENERGY_CORE" end
	if kind == "Sofa" or kind == "Chair" or kind == "Table" or kind == "Piano" then return "PREMIUM_FURNITURE_TRIM+SILHOUETTE" end
	if kind == "Screen" or kind == "Speaker" or kind == "Cabinet" then return "TECH_TRIM+DISPLAY_LIGHTS" end
	return "MODULAR_TRIM+SILHOUETTE_KIT"
end

local manifest: {[string]: any} = {}
local counts = {
	Total = 0,
	Studio = 0,
	CustomMesh = 0,
	Blender = 0,
	Hero = 0,
	Core = 0,
}

for baseItemId, base in LootCatalog.ById do
	local source = HERO_SOURCE_OVERRIDES[baseItemId] or "STUDIO_PROCEDURAL_FINAL"
	if string.find(source, "BLENDER", 1, true) then
		counts.Blender += 1
	elseif string.find(source, "CUSTOM_MESH", 1, true) then
		counts.CustomMesh += 1
	else
		counts.Studio += 1
	end
	if base.Core == false then counts.Hero += 1 else counts.Core += 1 end
	counts.Total += 1

	manifest[baseItemId] = table.freeze({
		ItemId = baseItemId,
		DisplayName = base.Name,
		Section = base.SectionId,
		ModelStatus = "M6C_BASE_PROCEDURAL",
		ModelSource = source,
		Production = if string.find(source, "BLENDER", 1, true) then "Blender" elseif string.find(source, "CUSTOM_MESH", 1, true) then "Mesh" else "Studio",
		PrimaryColor = base.Color,
		Materials = table.freeze({ "SmoothPlastic", "Metal", "Glass", "ControlledNeon" }),
		Silhouette = string.format("%s/%s", tostring(base.ShapeTag), tostring(base.ModelKind)),
		RarityGeometryStrategy = rarityStrategy(base),
		Completed = false,
		PlaceholderRemaining = true,
		Hero = base.Core == false,
		HeroMinRarity = base.HeroMinRarity,
		RequiredRarityTest = REQUIRED_RARITY_TESTS[baseItemId] == true,
	})
end

return table.freeze({
	Items = table.freeze(manifest),
	Counts = table.freeze(counts),
	RequiredRarityTests = REQUIRED_RARITY_TESTS,
	HeroSourceOverrides = HERO_SOURCE_OVERRIDES,
})
