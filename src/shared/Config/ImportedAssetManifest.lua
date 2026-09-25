--!strict

-- ONE TRIP cargo visual-source manifest (scalable architecture).
--
-- Every BaseItemId in LootCatalog is covered here exactly once:
--   SourceType "CreatorStore" + Status "Approved"  -> production import; the
--       sanitized template in ServerStorage/OneTripImportedAssets replaces the
--       procedural fallback at runtime (via manifest.Assets below).
--   SourceType "CreatorStore" + Status "Candidate" -> unverified free-asset
--       foundation. NEVER auto-imported by IMPORT APPROVED ASSETS and never
--       applied at runtime. It can be imported individually from the ONE TRIP
--       Model Builder (type the CargoId, click IMPORT/REBUILD SELECTED) purely
--       for visual inspection, then promoted to Approved or rejected.
--   SourceType "Studio" -> simple Studio-built geometry (boxes, crates, pallets,
--       industrial frames, fictional equipment). Built procedurally by the
--       Studio source pipeline; no asset id needed.
--
-- Replacing a bad asset id is a one-line edit in this file. There are no
-- special cases scattered across services.

local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))

local ImportPipelineVersion = "M6C.1-CREATOR-STORE-NATURAL-V3"

-- User-approved production imports (authoritative, user-selected):
--   Couch            10710790394    (gray couch - preserve natural gray)
--   Refrigerator     482124502      (preserve source appearance)
--   ArcadeCabinet    105044479380665(original Freddy/FNAF cabinet - preserve
--                                   source appearance; NO repaint, ever)
local approvedTable: {[string]: any} = {
	Couch = table.freeze({
		CargoId = "Couch",
		AssetId = 10710790394,
		SectionId = "Furniture",
		TargetBounds = Vector3.new(10.5, 4.4, 4.1),
		PreserveNaturalColor = true,
		RemoveAllExternalTextures = false,
		ReviewOrder = 1,
	}),
	Refrigerator = table.freeze({
		CargoId = "Refrigerator",
		AssetId = 482124502,
		SectionId = "Appliances",
		TargetBounds = Vector3.new(4.6, 8.0, 4.4),
		PreserveNaturalColor = true,
		RemoveAllExternalTextures = false,
		ReviewOrder = 2,
	}),
	ArcadeCabinet = table.freeze({
		CargoId = "ArcadeCabinet",
		AssetId = 105044479380665,
		SectionId = "Recreation",
		TargetBounds = Vector3.new(4.8, 8.4, 4.6),
		PreserveNaturalColor = true,
		RemoveAllExternalTextures = false,
		ApplyOneTripArcadePaint = false,
		ReviewOrder = 3,
	}),
}

local ApprovedDefinitions = table.freeze(approvedTable)

-- Candidate Creator Store foundations. Candidates only; each must pass visual
-- inspection in the import gallery before being promoted into ApprovedDefinitions.
-- Reject any asset that is ugly, ultra-high-poly, broken, or unusable on mobile.
local candidateTable: {[string]: number} = {
	OfficeChair = 6216316789,
	Toolbox = 9119272667,
	Suitcase = 6828006133,
	DiningChairBasic = 122562769,
	Washer = 10953288775,
	Television = 438645946,
	SpeakerSystem = 3128028735,
	Wardrobe = 13356885574,
	UprightPiano = 11294758178,
	Treadmill = 18516971667,
	GamingChairPremium = 4794979976,
	VendingMachine = 265882564,
	PrototypeServer = 12395775426,
	LuxuryDisplayCase = 5360143567,
	GrandfatherClock = 925596723,
	GrandCrystalChandelier = 10301817894,
}
local CandidateAssetIds = table.freeze(candidateTable)

local assets: {[string]: any} = {}
local sources: {[string]: any} = {}
local counts = {
	Total = 0,
	CreatorStoreApproved = 0,
	CreatorStoreCandidate = 0,
	Studio = 0,
}

for baseId, base in LootCatalog.ById do
	local approved = ApprovedDefinitions[baseId]
	local candidateAssetId = CandidateAssetIds[baseId]

	if approved then
		assets[baseId] = approved
		sources[baseId] = table.freeze({
			SourceType = "CreatorStore",
			Status = "Approved",
			CargoId = baseId,
			AssetId = approved.AssetId,
			SectionId = base.SectionId,
			TargetBounds = approved.TargetBounds,
			PreserveNaturalColor = approved.PreserveNaturalColor,
			RemoveAllExternalTextures = approved.RemoveAllExternalTextures,
			ReviewOrder = approved.ReviewOrder,
			StudioKind = base.ModelKind,
		})
		counts.CreatorStoreApproved += 1
	elseif candidateAssetId ~= nil then
		sources[baseId] = table.freeze({
			SourceType = "CreatorStore",
			Status = "Candidate",
			CargoId = baseId,
			AssetId = candidateAssetId,
			SectionId = base.SectionId,
			TargetBounds = base.Size,
			PreserveNaturalColor = true,
			RemoveAllExternalTextures = false,
			StudioKind = base.ModelKind,
		})
		counts.CreatorStoreCandidate += 1
	else
		sources[baseId] = table.freeze({
			SourceType = "Studio",
			CargoId = baseId,
			SectionId = base.SectionId,
			TargetBounds = base.Size,
			StudioBuildKind = base.ModelKind,
			StudioKind = base.ModelKind,
		})
		counts.Studio += 1
	end
	counts.Total += 1
end

return table.freeze({
	StorageFolderName = "OneTripImportedAssets",
	ReviewGalleryAttribute = "M6CImportedReviewGallery",
	ImportPipelineVersion = ImportPipelineVersion,
	-- Runtime + plugin import contract (approved templates only). Shape is
	-- identical to the pre-manifest definitions so existing consumers keep
	-- working unchanged.
	Assets = table.freeze(assets),
	-- Full-catalog visual source map: one authoritative entry per base item.
	ItemVisualSources = table.freeze(sources),
	Counts = table.freeze(counts),
	CandidateAssetIds = CandidateAssetIds,
})
