local ObjectConfig = {}

ObjectConfig.Order = {
	"Couch",
	"Fridge",
	"DiningTable",
}

ObjectConfig.Objects = {
	Couch = {
		DisplayName = "Oversized Couch",
		Size = Vector3.new(10, 4, 3.2),
		Color = Color3.fromRGB(239, 73, 78),
		TiltAxis = "Z",
		ChallengeText = "TOO WIDE. FIND THE ANGLE.",
	},
	Fridge = {
		DisplayName = "Tall Fridge",
		Size = Vector3.new(4.7, 9.4, 4.4),
		Color = Color3.fromRGB(104, 191, 255),
		TiltAxis = "X",
		ChallengeText = "TOO TALL. MAYBE DON'T KEEP IT UPRIGHT.",
	},
	DiningTable = {
		DisplayName = "Huge Dining Table",
		Size = Vector3.new(8.2, 3.0, 6.4),
		Color = Color3.fromRGB(180, 112, 70),
		TiltAxis = "Z",
		ChallengeText = "WIDE AND DEEP. GOOD LUCK.",
	},
}

function ObjectConfig.Get(objectId)
	return ObjectConfig.Objects[objectId]
end

return ObjectConfig
