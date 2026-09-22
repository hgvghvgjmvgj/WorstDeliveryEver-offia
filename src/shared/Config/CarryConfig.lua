--!strict

return table.freeze({
	BaseWalkSpeed = 16,
	MinimumLoadedWalkSpeed = 9.5,
	GrabDistance = 10,
	TechnicalMaxItems = 28,
	DroppedItemProtectionSeconds = 2.5,

	Beginner = table.freeze({
		Strength = 7,
		CarrySpace = 5,
		Control = 1.0,
	}),

	Veteran = table.freeze({
		Strength = 30,
		CarrySpace = 20,
		Control = 2.6,
	}),

	Movement = table.freeze({
		VelocityDeadzone = 1.5,
		AccelerationDeadzone = 10,
		TurnMinimumSpeed = 4,
		TurnAngleDeadzoneDegrees = 10,
		AccelerationGain = 0.055,
		TurnGain = 0.48,
		MovingRecoveryRate = 1.15,
		StoppedRecoveryRate = 2.9,
		MovementOscillationScale = 0.22,
		VisualUpdateHz = 20,
		StateUpdateHz = 10,
	}),

	BaseInstability = table.freeze({
		WeightPressureStart = 0.50,
		WeightPressureScale = 0.58,
		BulkPressureStart = 0.55,
		BulkPressureScale = 0.46,
		LayerContribution = 0.035,
		TallBaseContribution = 0.025,
		TallLayerContribution = 0.018,
		WideContribution = 0.035,
		HighWeightPerLayer = 0.014,
		ControlExponent = 0.55,
		MaxBaseInstability = 1.25,
	}),

	Danger = table.freeze({
		SlightWobble = 0.28,
		Unstable = 0.50,
		Dangerous = 0.72,
		NearCollapse = 0.90,
		CollapseRisk = 1.00,
		RecoveryRisk = 0.82,
		MinimumBaseForCollapse = 0.34,
		SwayRiskScale = 0.72,
		CollapseWarningSeconds = 0.85,
	}),

	Failure = table.freeze({
		Mode = "PartialCollapse",
		PartialCollapseFraction = 0.35,
		MinimumDroppedItems = 1,
	}),

	Stack = table.freeze({
		ItemsPerLayer = 3,
		LayerHeight = 3.0,
		BaseForwardOffset = -2.45,
		BaseHeight = 0.7,
		SideSpacing = 2.3,
		MaxVisualLeanDegrees = 18,
		MaxVisualPitchDegrees = 11,
		MaxVisualOffsetStuds = 0.38,
	}),
})
