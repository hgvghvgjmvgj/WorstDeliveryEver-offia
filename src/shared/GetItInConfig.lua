local GetItInConfig = {
	BaseWalkSpeed = 16,
	CarryWalkSpeed = 11,

	GrabDistance = 5.5,
	MaxGrabSeparation = 18,

	RotateStepDegrees = 15,
	TiltDegrees = 90,

	PositionResponsiveness = 12,
	OrientationResponsiveness = 8,
	MaxMoveForce = 30000,
	MaxTurnTorque = 24000,
	MaxMoveVelocity = 22,
	MaxAngularVelocity = 2.8,

	CouchStartCFrame = CFrame.new(0, 2.1, -12),
	CouchSize = Vector3.new(10, 4, 3.2),

	DoorCenterZ = 10,
	DoorWidth = 5.5,
	DoorHeight = 8.5,

	SuccessZ = 24,
	ResetDelay = 2.2,
}

return GetItInConfig
