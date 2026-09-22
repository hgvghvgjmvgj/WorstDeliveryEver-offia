local ObjectConfig = {}

local red = Color3.fromRGB(239, 73, 78)
local blue = Color3.fromRGB(101, 181, 255)
local orange = Color3.fromRGB(239, 151, 74)
local purple = Color3.fromRGB(159, 103, 221)

ObjectConfig.Objects = {
	Couch = {
		DisplayName = "Oversized Couch",
		TiltAxis = "Z",
		ChallengeText = "TOO WIDE. TURN IT THROUGH.",
		Pieces = {
			{Size = Vector3.new(10, 2, 3.2), Offset = CFrame.new(0, 1.2, 0), Color = red},
			{Size = Vector3.new(10, 3.2, 0.8), Offset = CFrame.new(0, 3.1, 1.2), Color = red},
			{Size = Vector3.new(0.8, 2.8, 3.2), Offset = CFrame.new(-4.6, 2.0, 0), Color = red},
			{Size = Vector3.new(0.8, 2.8, 3.2), Offset = CFrame.new(4.6, 2.0, 0), Color = red},
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
		DisplayName = "Tall Wardrobe",
		TiltAxis = "X",
		ChallengeText = "LOW FIRST DOOR. OFFSET SECOND DOOR.",
		Pieces = {
			{Size = Vector3.new(5.0, 10.2, 3.5), Offset = CFrame.new(0, 5.1, 0), Color = blue},
			{Size = Vector3.new(0.18, 9.5, 0.15), Offset = CFrame.new(0, 5.1, -1.83), Color = Color3.fromRGB(220, 239, 255)},
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
			{Size = Vector3.new(8.5, 2.4, 3.2), Offset = CFrame.new(-1.0, 1.2, 0), Color = orange},
			{Size = Vector3.new(3.2, 2.4, 7.0), Offset = CFrame.new(1.65, 1.2, 1.9), Color = orange},
			{Size = Vector3.new(8.5, 2.4, 0.7), Offset = CFrame.new(-1.0, 3.0, 1.25), Color = Color3.fromRGB(210, 119, 55)},
			{Size = Vector3.new(0.7, 2.4, 7.0), Offset = CFrame.new(2.9, 3.0, 1.9), Color = Color3.fromRGB(210, 119, 55)},
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
		DisplayName = "Grand Piano-ish Thing",
		TiltAxis = "Z",
		ChallengeText = "GET THROUGH, THEN PIVOT AROUND THE CORNER.",
		Pieces = {
			{Size = Vector3.new(10.5, 2.5, 4.6), Offset = CFrame.new(-0.3, 3.6, 0), Color = purple},
			{Size = Vector3.new(5.5, 1.1, 2.0), Offset = CFrame.new(3.5, 2.0, -2.3), Color = Color3.fromRGB(105, 75, 157)},
			{Size = Vector3.new(0.7, 3.0, 0.7), Offset = CFrame.new(-4.2, 1.5, -1.5), Color = Color3.fromRGB(68, 52, 83)},
			{Size = Vector3.new(0.7, 3.0, 0.7), Offset = CFrame.new(3.5, 1.5, 1.4), Color = Color3.fromRGB(68, 52, 83)},
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
