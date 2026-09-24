--!strict

local SectionConfig = require(script.Parent:WaitForChild("SectionConfig"))

local ClearanceConfig = {}

ClearanceConfig.RigNames = table.freeze({
	[0] = "STARTER",
	[1] = "RIG I",
	[2] = "RIG II",
	[3] = "RIG III",
	[4] = "RIG IV",
	[5] = "RIG V",
})

-- M6A.3 progression bands. Clearance is derived from the live HandlingRigTier;
-- nothing here is persisted separately.
ClearanceConfig.RequiredRigBySection = table.freeze({
	Receiving = 0,
	HomeBasics = 0,
	Appliances = 1,
	Furniture = 2,
	Electronics = 2,
	Recreation = 2,
	GarageAuto = 3,
	Construction = 3,
	HeavyGoods = 3,
	Industrial = 4,
	PremiumInteriors = 4,
	LuxuryGoods = 4,
	ArtCollectibles = 5,
	Secure = 5,
	RestrictedPrototype = 5,
})

ClearanceConfig.Checkpoints = table.freeze({
	table.freeze({ BeforeSection = "Appliances", RequiredRig = 1 }),
	table.freeze({ BeforeSection = "Furniture", RequiredRig = 2 }),
	table.freeze({ BeforeSection = "GarageAuto", RequiredRig = 3 }),
	table.freeze({ BeforeSection = "Industrial", RequiredRig = 4 }),
	table.freeze({ BeforeSection = "ArtCollectibles", RequiredRig = 5 }),
})

ClearanceConfig.SectionsUnlockedAtRig = table.freeze({
	[0] = table.freeze({ "Receiving", "HomeBasics" }),
	[1] = table.freeze({ "Appliances" }),
	[2] = table.freeze({ "Furniture", "Electronics", "Recreation" }),
	[3] = table.freeze({ "GarageAuto", "Construction", "HeavyGoods" }),
	[4] = table.freeze({ "Industrial", "PremiumInteriors", "LuxuryGoods" }),
	[5] = table.freeze({ "ArtCollectibles", "Secure", "RestrictedPrototype" }),
})

function ClearanceConfig.RequiredRig(sectionId: string): number
	return ClearanceConfig.RequiredRigBySection[sectionId] or 0
end

function ClearanceConfig.CanAccess(rigTier: number, sectionId: string): boolean
	return math.max(0, math.floor(rigTier + 0.5)) >= ClearanceConfig.RequiredRig(sectionId)
end

function ClearanceConfig.RigName(tier: number): string
	return ClearanceConfig.RigNames[math.clamp(math.floor(tier + 0.5), 0, 5)] or "STARTER"
end

function ClearanceConfig.SectionName(sectionId: string): string
	local section = SectionConfig.Sections[sectionId]
	return if section then section.DisplayName else sectionId
end

function ClearanceConfig.NewSectionsForTier(tier: number): {string}
	return ClearanceConfig.SectionsUnlockedAtRig[math.clamp(math.floor(tier + 0.5), 0, 5)] or {}
end

return table.freeze(ClearanceConfig)
