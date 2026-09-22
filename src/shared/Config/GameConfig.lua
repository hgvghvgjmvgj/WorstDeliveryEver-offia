--!strict

return table.freeze({
	GameName = "ONE TRIP",
	PrototypeVersion = "M0",

	MaxPlayersTarget = 12,

	World = table.freeze({
		FootprintStuds = 216,
		ItemFloorSize = Vector3.new(96, 1, 96),
		BayRadius = 88,
		BaySize = Vector3.new(24, 1, 22),
		BayCount = 12,
	}),

	Prototype = table.freeze({
		NormalItemTargetPerPlayer = 2.5,
		DesiredTravelSecondsMin = 5,
		DesiredTravelSecondsMax = 10,
	}),
})
