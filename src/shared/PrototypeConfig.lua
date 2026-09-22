local PrototypeConfig = {
	BaseWalkSpeed = 16,
	MinimumWalkSpeed = 10,
	WalkSpeedLossPerWeight = 0.34,

	MaxBalance = 100,
	RecoveryPerSecond = 18,
	MovementStrainPerWeight = 0.30,
	TurnStrainPerWeight = 2.4,
	SharpTurnDotThreshold = 0.965,
	MovingSpeedThreshold = 1.5,

	TripBonusPerExtraItem = 0.15,
	ResultDelay = 2.5,

	CarryOffsets = {
		CFrame.new(-1.8, 0.3, -0.5) * CFrame.Angles(0, 0, math.rad(12)),
		CFrame.new(1.8, 0.2, -0.5) * CFrame.Angles(0, 0, math.rad(-12)),
		CFrame.new(-1.35, 2.0, 0.0) * CFrame.Angles(0, 0, math.rad(-7)),
		CFrame.new(1.35, 2.1, 0.0) * CFrame.Angles(0, 0, math.rad(8)),
		CFrame.new(0.0, 3.35, 0.1) * CFrame.Angles(0, 0, math.rad(3)),
	},
}

return PrototypeConfig
