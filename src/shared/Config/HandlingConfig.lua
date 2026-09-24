--!strict

local SectionConfig = require(script.Parent:WaitForChild("SectionConfig"))

local HandlingConfig = {}

HandlingConfig.SectionOrder = SectionConfig.Order

HandlingConfig.SectionProfiles = table.freeze({
	Receiving = table.freeze({ RecommendedRig = 0, Strength = Vector2.new(9,16), CarrySpace = Vector2.new(8,14), Control = Vector2.new(0.90,1.08), WeightReference = 4.5, BulkReference = 4.5 }),
	HomeBasics = table.freeze({ RecommendedRig = 0, Strength = Vector2.new(10,17), CarrySpace = Vector2.new(9,15), Control = Vector2.new(0.92,1.12), WeightReference = 5.5, BulkReference = 6.0 }),
	Appliances = table.freeze({ RecommendedRig = 1, Strength = Vector2.new(13,20), CarrySpace = Vector2.new(11,17), Control = Vector2.new(0.98,1.18), WeightReference = 7.0, BulkReference = 5.5 }),
	Furniture = table.freeze({ RecommendedRig = 2, Strength = Vector2.new(14,25), CarrySpace = Vector2.new(12,18.5), Control = Vector2.new(1.02,1.32), WeightReference = 11.5, BulkReference = 10.5 }),
	Electronics = table.freeze({ RecommendedRig = 2, Strength = Vector2.new(16,25), CarrySpace = Vector2.new(13,20), Control = Vector2.new(1.05,1.35), WeightReference = 10.0, BulkReference = 8.0 }),
	Recreation = table.freeze({ RecommendedRig = 2, Strength = Vector2.new(17,26), CarrySpace = Vector2.new(14,21), Control = Vector2.new(1.07,1.38), WeightReference = 12.0, BulkReference = 10.0 }),
	GarageAuto = table.freeze({ RecommendedRig = 3, Strength = Vector2.new(18,28), CarrySpace = Vector2.new(14,21), Control = Vector2.new(1.10,1.42), WeightReference = 16.0, BulkReference = 9.0 }),
	Construction = table.freeze({ RecommendedRig = 3, Strength = Vector2.new(19,30), CarrySpace = Vector2.new(15,22), Control = Vector2.new(1.12,1.45), WeightReference = 19.0, BulkReference = 10.0 }),
	HeavyGoods = table.freeze({ RecommendedRig = 3, Strength = Vector2.new(18,30), CarrySpace = Vector2.new(13,20), Control = Vector2.new(1.08,1.38), WeightReference = 17.0, BulkReference = 7.0 }),
	Industrial = table.freeze({ RecommendedRig = 4, Strength = Vector2.new(24,35), CarrySpace = Vector2.new(17,25), Control = Vector2.new(1.20,1.58), WeightReference = 25.0, BulkReference = 9.0 }),
	PremiumInteriors = table.freeze({ RecommendedRig = 4, Strength = Vector2.new(25,36), CarrySpace = Vector2.new(19,27), Control = Vector2.new(1.24,1.62), WeightReference = 20.0, BulkReference = 14.0 }),
	LuxuryGoods = table.freeze({ RecommendedRig = 4, Strength = Vector2.new(26,37), CarrySpace = Vector2.new(20,28), Control = Vector2.new(1.28,1.68), WeightReference = 20.0, BulkReference = 14.0 }),
	ArtCollectibles = table.freeze({ RecommendedRig = 5, Strength = Vector2.new(27,38), CarrySpace = Vector2.new(21,29), Control = Vector2.new(1.32,1.72), WeightReference = 22.0, BulkReference = 15.0 }),
	Secure = table.freeze({ RecommendedRig = 5, Strength = Vector2.new(27,38), CarrySpace = Vector2.new(19,29), Control = Vector2.new(1.34,1.75), WeightReference = 28.0, BulkReference = 11.0 }),
	RestrictedPrototype = table.freeze({ RecommendedRig = 5, Strength = Vector2.new(30,42), CarrySpace = Vector2.new(23,32), Control = Vector2.new(1.42,1.88), WeightReference = 35.0, BulkReference = 17.0 }),
})

-- Rig tier remains a readable summary, not a hard section key. One capability
-- band intentionally spans multiple sections; actual handling always uses the
-- three underlying stats so specialized builds remain meaningful.
HandlingConfig.RigMilestones = table.freeze({
	table.freeze({ Tier = 0, Name = "STARTER", Strength = 15, CarrySpace = 13, Control = 1.00 }),
	table.freeze({ Tier = 1, Name = "RIG I", Strength = 17, CarrySpace = 15, Control = 1.10 }),
	table.freeze({ Tier = 2, Name = "RIG II", Strength = 19.5, CarrySpace = 17.5, Control = 1.22 }),
	table.freeze({ Tier = 3, Name = "RIG III", Strength = 22.5, CarrySpace = 20.5, Control = 1.35 }),
	table.freeze({ Tier = 4, Name = "RIG IV", Strength = 26, CarrySpace = 24, Control = 1.50 }),
	table.freeze({ Tier = 5, Name = "RIG V", Strength = 30, CarrySpace = 28, Control = 1.67 }),
})

HandlingConfig.Bands = table.freeze({
	READY = table.freeze({ MinimumRatio = 0.97, BaseInstabilityBonus = 0, InstabilityFloor = 0, SwayMultiplier = 1.00, RecoveryMultiplier = 1.00, MovementMultiplier = 1.00, StrainFloor = 0 }),
	RISKY = table.freeze({ MinimumRatio = 0.82, BaseInstabilityBonus = 0.07, InstabilityFloor = 0.10, SwayMultiplier = 1.15, RecoveryMultiplier = 0.88, MovementMultiplier = 0.94, StrainFloor = 0.14 }),
	DANGEROUS = table.freeze({ MinimumRatio = 0.65, BaseInstabilityBonus = 0.20, InstabilityFloor = 0.32, SwayMultiplier = 1.40, RecoveryMultiplier = 0.66, MovementMultiplier = 0.80, StrainFloor = 0.44 }),
	UNMANAGEABLE = table.freeze({ MinimumRatio = 0, BaseInstabilityBonus = 0.44, InstabilityFloor = 0.60, SwayMultiplier = 1.78, RecoveryMultiplier = 0.38, MovementMultiplier = 0.60, StrainFloor = 0.76 }),
})

HandlingConfig.Pile = table.freeze({
	StrengthPerTotalWeight = 0.92,
	SpacePerTotalBulk = 0.90,
	BaseControl = 0.94,
	ControlPerBaseInstability = 0.62,
	ControlPerWideItem = 0.035,
	ControlPerTallItem = 0.028,
	MaximumShapeControlBonus = 0.30,
})

HandlingConfig.GripFailure = table.freeze({
	MaxSeconds = 3.8,
	MinSeconds = 2.35,
	SecondsPerRatioBelowDangerous = 3.6,
	WarningText = "GRIP FAILING - THIS LOAD IS TOO MUCH FOR YOUR RIG!",
	FailureText = "GRIP FAILED - ITEM LOST. UPGRADE YOUR HANDLING.",
})

local function lerp(a: number, b: number, alpha: number): number
	return a + (b - a) * math.clamp(alpha, 0, 1)
end

local function rounded(value: number, step: number): number
	return math.floor(value / step + 0.5) * step
end

function HandlingConfig.RequirementsFor(base: any, tunedWeight: number, tunedBulk: number)
	local profile = HandlingConfig.SectionProfiles[base.SectionId]
	if not profile then return table.freeze({ Strength = tunedWeight, CarrySpace = tunedBulk, Control = 1.0 }) end
	local weightAlpha = math.clamp(tunedWeight / profile.WeightReference, 0, 1)
	local bulkAlpha = math.clamp(tunedBulk / profile.BulkReference, 0, 1)
	local combined = math.max(weightAlpha, bulkAlpha)
	local shapeBonus = if base.ShapeTag == "Wide" then 0.055 elseif base.ShapeTag == "Tall" then 0.040 else 0
	local heroBonus = if base.Core == false then 0.035 else 0
	return table.freeze({
		Strength = rounded(lerp(profile.Strength.X, profile.Strength.Y, weightAlpha), 0.5),
		CarrySpace = rounded(lerp(profile.CarrySpace.X, profile.CarrySpace.Y, bulkAlpha), 0.5),
		Control = rounded(lerp(profile.Control.X, profile.Control.Y, combined) + shapeBonus + heroBonus, 0.01),
	})
end

function HandlingConfig.RigTierFromStats(strength: number, carrySpace: number, control: number): number
	local result = 0
	for _, milestone in HandlingConfig.RigMilestones do
		if strength + 1e-6 >= milestone.Strength and carrySpace + 1e-6 >= milestone.CarrySpace and control + 1e-6 >= milestone.Control then result = milestone.Tier else break end
	end
	return result
end

function HandlingConfig.RigName(tier: number): string
	for _, milestone in HandlingConfig.RigMilestones do if milestone.Tier == tier then return milestone.Name end end
	return "STARTER"
end

function HandlingConfig.NextRigMilestone(tier: number)
	for _, milestone in HandlingConfig.RigMilestones do if milestone.Tier == tier + 1 then return milestone end end
	return nil
end

function HandlingConfig.SectionRecommendedRig(sectionId: string): number
	local profile = HandlingConfig.SectionProfiles[sectionId]
	return if profile then profile.RecommendedRig else 0
end

function HandlingConfig.BandForRatio(ratio: number): string
	if ratio >= HandlingConfig.Bands.READY.MinimumRatio then return "READY" end
	if ratio >= HandlingConfig.Bands.RISKY.MinimumRatio then return "RISKY" end
	if ratio >= HandlingConfig.Bands.DANGEROUS.MinimumRatio then return "DANGEROUS" end
	return "UNMANAGEABLE"
end

function HandlingConfig.Evaluate(stats: any, definition: any, totalWeight: number, totalBulk: number, baseInstability: number, wideCount: number, tallCount: number)
	local requirements = definition.Handling or { Strength = definition.Weight, CarrySpace = definition.Bulk, Control = 1.0 }
	local pile = HandlingConfig.Pile
	local effectiveStrength = math.max(requirements.Strength, totalWeight * pile.StrengthPerTotalWeight)
	local effectiveSpace = math.max(requirements.CarrySpace, totalBulk * pile.SpacePerTotalBulk)
	local shapeControl = math.min(pile.MaximumShapeControlBonus, wideCount * pile.ControlPerWideItem + tallCount * pile.ControlPerTallItem)
	local effectiveControl = math.max(requirements.Control, pile.BaseControl + baseInstability * pile.ControlPerBaseInstability + shapeControl)
	local strengthRatio = stats.Strength / math.max(0.1, effectiveStrength)
	local spaceRatio = stats.CarrySpace / math.max(0.1, effectiveSpace)
	local controlRatio = stats.Control / math.max(0.1, effectiveControl)
	local ratio = math.min(strengthRatio, spaceRatio, controlRatio)
	local weakness = "STRENGTH"
	if spaceRatio <= strengthRatio and spaceRatio <= controlRatio then weakness = "CARRY SPACE" elseif controlRatio <= strengthRatio and controlRatio <= spaceRatio then weakness = "CONTROL" end
	local band = HandlingConfig.BandForRatio(ratio)
	local tuning = HandlingConfig.Bands[band]
	return {
		Band = band,
		Ratio = ratio,
		Weakness = weakness,
		RequiredStrength = effectiveStrength,
		RequiredCarrySpace = effectiveSpace,
		RequiredControl = effectiveControl,
		BaseInstabilityBonus = tuning.BaseInstabilityBonus,
		InstabilityFloor = tuning.InstabilityFloor,
		SwayMultiplier = tuning.SwayMultiplier,
		RecoveryMultiplier = tuning.RecoveryMultiplier,
		MovementMultiplier = tuning.MovementMultiplier,
		StrainFloor = tuning.StrainFloor,
	}
end

function HandlingConfig.GripFailureSeconds(ratio: number): number
	local config = HandlingConfig.GripFailure
	local shortfall = math.max(0, HandlingConfig.Bands.DANGEROUS.MinimumRatio - ratio)
	return math.clamp(config.MaxSeconds - shortfall * config.SecondsPerRatioBelowDangerous, config.MinSeconds, config.MaxSeconds)
end

return table.freeze(HandlingConfig)
