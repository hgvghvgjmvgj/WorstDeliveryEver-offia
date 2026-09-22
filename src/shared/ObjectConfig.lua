local ObjectConfig = {}

local red = Color3.fromRGB(232, 72, 79)
local redLight = Color3.fromRGB(247, 103, 108)
local blue = Color3.fromRGB(95, 184, 242)
local blueDark = Color3.fromRGB(55, 139, 204)
local orange = Color3.fromRGB(234, 145, 70)
local orangeLight = Color3.fromRGB(247, 170, 94)
local purple = Color3.fromRGB(133, 91, 190)
local purpleDark = Color3.fromRGB(78, 55, 111)
local dark = Color3.fromRGB(52, 48, 60)
local white = Color3.fromRGB(246, 245, 238)

ObjectConfig.Objects = {
	Couch = {
		DisplayName = "Oversized Couch",
		TiltAxis = "Z",
		ChallengeText = "TOO WIDE. TURN IT THROUGH.",
		Pieces = {
			-- Collision silhouette.
			{Size = Vector3.new(10, 2, 3.2), Offset = CFrame.new(0, 1.2, 0), Color = red},
			{Size = Vector3.new(10, 3.2, 0.8), Offset = CFrame.new(0, 3.1, 1.2), Color = red},
			{Size = Vector3.new(0.8, 2.8, 3.2), Offset = CFrame.new(-4.6, 2.0, 0), Color = red},
			{Size = Vector3.new(0.8, 2.8, 3.2), Offset = CFrame.new(4.6, 2.0, 0), Color = red},

			-- Visual-only cushions and feet.
			{Size = Vector3.new(2.7, 0.55, 2.5), Offset = CFrame.new(-3.0, 2.35, -0.05), Color = redLight, Collision = false},
			{Size = Vector3.new(2.7, 0.55, 2.5), Offset = CFrame.new(0, 2.35, -0.05), Color = redLight, Collision = false},
			{Size = Vector3.new(2.7, 0.55, 2.5), Offset = CFrame.new(3.0, 2.35, -0.05), Color = redLight, Collision = false},
			{Size = Vector3.new(0.45, 0.7, 0.45), Offset = CFrame.new(-4.1, 0.35, -1.05), Color = dark, Collision = false},
			{Size = Vector3.new(0.45, 0.7, 0.45), Offset = CFrame.new(4.1, 0.35, -1.05), Color = dark, Collision = false},
		},
		Challenge = {
			Kind = "NarrowDoor",
			DoorWidth = 5.6,
			DoorHeight = 8.5,
			SuccessCenter = Vector3.new(0, 3.5, 25),
			SuccessSize = Vector3.new(18, 12, 8),
		},
	},

	Wardrobe = {
		DisplayName = "Tall Fridge",
		TiltAxis = "X",
		ChallengeText = "LOW FIRST DOOR. OFFSET SECOND DOOR.",
		Pieces = {
			-- Collision body.
			{Size = Vector3.new(5.0, 10.2, 3.5), Offset = CFrame.new(0, 5.1, 0), Color = blue},

			-- Visual-only fridge details.
			{Size = Vector3.new(4.55, 3.35, 0.18), Offset = CFrame.new(0, 8.25, -1.78), Color = blueDark, Collision = false},
			{Size = Vector3.new(4.55, 6.1, 0.18), Offset = CFrame.new(0, 3.55, -1.78), Color = Color3.fromRGB(122, 207, 247), Collision = false},
			{Size = Vector3.new(0.22, 2.8, 0.25), Offset = CFrame.new(1.72, 6.3, -1.98), Color = white, Collision = false},
			{Size = Vector3.new(0.22, 2.0, 0.25), Offset = CFrame.new(1.72, 9.0, -1.98), Color = white, Collision = false},
			{Size = Vector3.new(5.3, 0.35, 3.75), Offset = CFrame.new(0, 10.15, 0), Color = white, Collision = false},
		},
		Challenge = {
			Kind = "LowThenOffset",
			FirstDoorWidth = 6.4,
			FirstDoorHeight = 6.7,
			SecondDoorCenterX = 3.1,
			SecondDoorWidth = 5.6,
			SecondDoorHeight = 8.8,
			SecondDoorOffsetZ = 14,
			SuccessCenter = Vector3.new(3.1, 3.5, 34),
			SuccessSize = Vector3.new(13, 12, 8),
		},
	},

	Sectional = {
		DisplayName = "L-Shaped Sectional",
		TiltAxis = "Z",
		ChallengeText = "L-SHAPE + OFFSET ENTRY. PLAN THE TURN.",
		Pieces = {
			-- Collision silhouette.
			{Size = Vector3.new(8.5, 2.4, 3.2), Offset = CFrame.new(-1.0, 1.2, 0), Color = orange},
			{Size = Vector3.new(3.2, 2.4, 7.0), Offset = CFrame.new(1.65, 1.2, 1.9), Color = orange},
			{Size = Vector3.new(8.5, 2.4, 0.7), Offset = CFrame.new(-1.0, 3.0, 1.25), Color = orange},
			{Size = Vector3.new(0.7, 2.4, 7.0), Offset = CFrame.new(2.9, 3.0, 1.9), Color = orange},

			-- Visual-only cushions.
			{Size = Vector3.new(2.6, 0.5, 2.45), Offset = CFrame.new(-3.1, 2.65, -0.05), Color = orangeLight, Collision = false},
			{Size = Vector3.new(2.6, 0.5, 2.45), Offset = CFrame.new(-0.25, 2.65, -0.05), Color = orangeLight, Collision = false},
			{Size = Vector3.new(2.45, 0.5, 2.7), Offset = CFrame.new(1.7, 2.65, 2.35), Color = orangeLight, Collision = false},
			{Size = Vector3.new(2.45, 0.5, 2.7), Offset = CFrame.new(1.7, 2.65, 5.05), Color = orangeLight, Collision = false},
		},
		Challenge = {
			Kind = "OffsetEntry",
			FirstDoorCenterX = -3.0,
			SecondDoorCenterX = 3.0,
			DoorWidth = 7.0,
			DoorHeight = 9.0,
			SuccessCenter = Vector3.new(3, 3.5, 29),
			SuccessSize = Vector3.new(16, 12, 8),
		},
	},

	Piano = {
		DisplayName = "Grand Piano",
		TiltAxis = "Z",
		ChallengeText = "GET THROUGH, THEN PIVOT AROUND THE CORNER.",
		Pieces = {
			-- Collision silhouette.
			{Size = Vector3.new(10.5, 2.5, 4.6), Offset = CFrame.new(-0.3, 3.6, 0), Color = purple},
			{Size = Vector3.new(5.5, 1.1, 2.0), Offset = CFrame.new(3.5, 2.0, -2.3), Color = purpleDark},
			{Size = Vector3.new(0.7, 3.0, 0.7), Offset = CFrame.new(-4.2, 1.5, -1.5), Color = dark},
			{Size = Vector3.new(0.7, 3.0, 0.7), Offset = CFrame.new(3.5, 1.5, 1.4), Color = dark},

			-- Visual-only keyboard/lid/pedals.
			{Size = Vector3.new(5.0, 0.24, 1.4), Offset = CFrame.new(3.5, 2.65, -2.75), Color = white, Collision = false},
			{Size = Vector3.new(9.8, 0.28, 4.1), Offset = CFrame.new(-0.4, 4.95, 0), Color = Color3.fromRGB(151, 106, 205), Collision = false},
			{Size = Vector3.new(1.3, 0.35, 0.5), Offset = CFrame.new(-0.2, 0.55, -0.3), Color = Color3.fromRGB(225, 185, 69), Collision = false},
		},
		Challenge = {
			Kind = "CornerHall",
			EntryWidth = 8.5,
			HallWidth = 16.0,
			CeilingHeight = 7.7,
			ExitClearanceX = 22,
			SuccessCenter = Vector3.new(14.5, 3.5, 20),
			SuccessSize = Vector3.new(14, 12, 8),
		},
	},
}

function ObjectConfig.Get(objectId)
	return ObjectConfig.Objects[objectId]
end

return ObjectConfig
