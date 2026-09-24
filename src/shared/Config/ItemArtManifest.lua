--!strict

local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))
local BatchConfig = require(script.Parent:WaitForChild("M6CProductionBatchConfig"))

-- M6C source of truth for cargo art production. Every current BaseItemId is
-- represented automatically; the 11-item representative checkpoint is tracked
-- explicitly without pretending visual review/custom-mesh work is complete.

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
	JewelrySafe = true,
	BlackProjectContainmentUnit = true,
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
	Checkpoint = 0,
}

for baseItemId, base in LootCatalog.ById do
	local source = HERO_SOURCE_OVERRIDES[baseItemId] or "STUDIO_PROCEDURAL_FINAL"
	local checkpoint = BatchConfig.Recipes[baseItemId] ~= nil
	if string.find(source, "BLENDER", 1, true) then
		counts.Blender += 1
	elseif string.find(source, "CUSTOM_MESH", 1, true) then
		counts.CustomMesh += 1
	else
		counts.Studio += 1
	end
	if base.Core == false then counts.Hero += 1 else counts.Core += 1 end
	if checkpoint then counts.Checkpoint += 1 end
	counts.Total += 1

	local requiresMeshReview = checkpoint and (
		string.find(source,"BLENDER",1,true) ~= nil or string.find(source,"CUSTOM_MESH",1,true) ~= nil
	)

	manifest[baseItemId] = table.freeze({
		ItemId = baseItemId,
		DisplayName = base.Name,
		Section = base.SectionId,
		ModelStatus = if checkpoint then "M6C_REPRESENTATIVE_CHECKPOINT" else "M6C_BASE_PROCEDURAL",
		ModelSource = if checkpoint then BatchConfig.Recipes[baseItemId].ModelSource else source,
		LongTermModelSource = source,
		Production = if string.find(source, "BLENDER", 1, true) then "Blender" elseif string.find(source, "CUSTOM_MESH", 1, true) then "Mesh" else "Studio",
		PrimaryColor = base.Color,
		Materials = table.freeze({ "SmoothPlastic", "Metal", "Glass", "ControlledNeon" }),
		Silhouette = string.format("%s/%s", tostring(base.ShapeTag), tostring(base.ModelKind)),
		ApproximateScale = base.Size,
		RarityGeometryStrategy = rarityStrategy(base),
		VFXPlan = if checkpoint then "STANDARD_ANCHORS+NATIVE_LAYERED_VFX+SINE_SWAP_READY" else "LEGACY_M6C_PENDING_REVIEW",
		CheckpointReady = checkpoint,
		VisualReviewPending = checkpoint,
		Completed = false,
		PlaceholderRemaining = if checkpoint then requiresMeshReview else true,
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
	RepresentativeBatchOrder = BatchConfig.Order,
})
