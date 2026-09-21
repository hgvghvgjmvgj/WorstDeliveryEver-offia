local UpgradeConfig = {}

UpgradeConfig.Definitions = {
	Speed = {
		BaseCost = 100,
		CostGrowth = 1.35,
		EffectPerLevel = 0.05,
	},
	Grip = {
		BaseCost = 100,
		CostGrowth = 1.35,
		EffectPerLevel = 0.05,
	},
	CargoProtection = {
		BaseCost = 125,
		CostGrowth = 1.40,
		EffectPerLevel = 0.06,
	},
}

function UpgradeConfig.GetCost(upgradeName, currentLevel)
	local definition = UpgradeConfig.Definitions[upgradeName]
	assert(definition, ("Unknown upgrade: %s"):format(tostring(upgradeName)))

	return math.floor(definition.BaseCost * (definition.CostGrowth ^ currentLevel))
end

return UpgradeConfig
