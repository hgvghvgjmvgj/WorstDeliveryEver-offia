local ItemConfig = {}

ItemConfig.Order = {
	"GroceryBag",
	"Eggs",
	"Milk",
	"Watermelon",
	"SodaCase",
}

ItemConfig.Items = {
	GroceryBag = {
		DisplayName = "Grocery Bag",
		Weight = 1,
		Reward = 10,
		Size = Vector3.new(2.2, 2.6, 1.2),
		Color = Color3.fromRGB(193, 145, 89),
	},
	Eggs = {
		DisplayName = "Eggs",
		Weight = 1,
		Reward = 16,
		Size = Vector3.new(2.6, 0.8, 1.5),
		Color = Color3.fromRGB(238, 223, 185),
	},
	Milk = {
		DisplayName = "Milk",
		Weight = 2,
		Reward = 22,
		Size = Vector3.new(1.4, 2.4, 1.4),
		Color = Color3.fromRGB(232, 239, 245),
	},
	Watermelon = {
		DisplayName = "Watermelon",
		Weight = 4,
		Reward = 38,
		Size = Vector3.new(2.7, 2.7, 2.7),
		Color = Color3.fromRGB(71, 150, 74),
	},
	SodaCase = {
		DisplayName = "Soda Case",
		Weight = 5,
		Reward = 48,
		Size = Vector3.new(3.2, 1.6, 2.2),
		Color = Color3.fromRGB(194, 55, 55),
	},
}

function ItemConfig.Get(itemId)
	return ItemConfig.Items[itemId]
end

return ItemConfig
