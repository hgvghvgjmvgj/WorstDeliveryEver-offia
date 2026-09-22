--!strict

local Visuals = {
	Order = table.freeze({ "Box", "Microwave", "Lamp", "Chair", "Tire", "TV", "Couch", "Safe" }),

	Items = table.freeze({
		Box = table.freeze({ Size = Vector3.new(3.2, 3.2, 3.2), Color = Color3.fromRGB(202, 151, 93) }),
		Microwave = table.freeze({ Size = Vector3.new(4.4, 2.7, 3.2), Color = Color3.fromRGB(180, 184, 190) }),
		Lamp = table.freeze({ Size = Vector3.new(1.5, 8.5, 1.5), Color = Color3.fromRGB(242, 214, 100) }),
		Chair = table.freeze({ Size = Vector3.new(5.2, 5.3, 4.2), Color = Color3.fromRGB(167, 112, 77) }),
		Tire = table.freeze({ Size = Vector3.new(3.8, 3.8, 2.1), Color = Color3.fromRGB(52, 54, 59) }),
		TV = table.freeze({ Size = Vector3.new(7.2, 4.5, 1.6), Color = Color3.fromRGB(58, 68, 83) }),
		Couch = table.freeze({ Size = Vector3.new(10.5, 4.4, 4.1), Color = Color3.fromRGB(87, 139, 184) }),
		Safe = table.freeze({ Size = Vector3.new(4.8, 5.4, 4.8), Color = Color3.fromRGB(89, 99, 110) }),
	}),
}

return table.freeze(Visuals)
