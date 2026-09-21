local CargoConfig = {}

CargoConfig.Definitions = {
	CardboardBox = {
		Id = "CardboardBox",
		DisplayName = "Cardboard Box",
		ModelName = "CardboardBox",
		BaseReward = 50,
		MaxHealth = 100,
		Weight = 1,
		FragilityMultiplier = 0.75,
	},
	Television = {
		Id = "Television",
		DisplayName = "Television",
		ModelName = "Television",
		BaseReward = 100,
		MaxHealth = 100,
		Weight = 2,
		FragilityMultiplier = 1.10,
	},
	GamingPC = {
		Id = "GamingPC",
		DisplayName = "Gaming PC",
		ModelName = "GamingPC",
		BaseReward = 140,
		MaxHealth = 100,
		Weight = 2,
		FragilityMultiplier = 1.35,
	},
	WeddingCake = {
		Id = "WeddingCake",
		DisplayName = "Wedding Cake",
		ModelName = "WeddingCake",
		BaseReward = 180,
		MaxHealth = 100,
		Weight = 1,
		FragilityMultiplier = 1.75,
	},
	Microwave = {
		Id = "Microwave",
		DisplayName = "Microwave",
		ModelName = "Microwave",
		BaseReward = 120,
		MaxHealth = 100,
		Weight = 3,
		FragilityMultiplier = 0.95,
	},
}

CargoConfig.Order = {
	"CardboardBox",
	"Television",
	"GamingPC",
	"WeddingCake",
	"Microwave",
}

return CargoConfig
