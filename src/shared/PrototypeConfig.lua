local PrototypeConfig = {
	BaseWalkSpeed = 16,
	MinimumWalkSpeed = 10,
	WalkSpeedLossPerWeight = 0.38,

	MaxBalance = 100,
	SafeWeight = 3,
	RecoveryPerSecond = 13,
	MovementStrainPerExcessWeight = 0.85,
	HeavyWeightThreshold = 8,
	HeavyMovementStrainPerExcessWeight = 0.45,
	TurnStrainPerWeight = 1.40,
	SharpTurnDotThreshold = 0.97,
	MovingSpeedThreshold = 1.5,

	HazardBaseSpike = 18,
	HazardSpikePerWeight = 2.6,
	HazardHitCooldown = 0.65,

	JumpBaseSpike = 12,
	JumpSpikePerWeight = 2.1,

	ResultDelay = 2.5,

	PayoutMultipliers = {
		1.00,
		1.15,
		1.35,
		1.65,
		2.15,
	},

	CarryOffsets = {
		CFrame.new(-1.8, 0.3, -0.5) * CFrame.Angles(0, 0, math.rad(12)),
		CFrame.new(1.8, 0.2, -0.5) * CFrame.Angles(0, 0, math.rad(-12)),
		CFrame.new(-1.35, 2.0, 0.0) * CFrame.Angles(0, 0, math.rad(-7)),
		CFrame.new(1.35, 2.1, 0.0) * CFrame.Angles(0, 0, math.rad(8)),
		CFrame.new(0.0, 3.35, 0.1) * CFrame.Angles(0, 0, math.rad(3)),
	},
}

function PrototypeConfig.GetPayoutMultiplier(itemCount)
	if itemCount <= 0 then
		return 0
	end

	return PrototypeConfig.PayoutMultipliers[math.min(itemCount, #PrototypeConfig.PayoutMultipliers)]
		or PrototypeConfig.PayoutMultipliers[#PrototypeConfig.PayoutMultipliers]
end

return PrototypeConfig
