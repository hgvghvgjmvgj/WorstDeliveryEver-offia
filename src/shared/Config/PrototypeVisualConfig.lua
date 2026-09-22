--!strict

local Visuals = {
	Order = table.freeze({ "Box", "Microwave", "Lamp", "Chair", "Tire", "TV", "Couch", "Safe" }),

	Items = table.freeze({
		Box = table.freeze({ Size = Vector3.new(3, 3, 3), Color = Color3.fromRGB(202, 151, 93) }),
		Microwave = table.freeze({ Size = Vector3.new(4, 2.5, 3), Color = Color3.fromRGB(180, 184, 190) }),
		Lamp = table.freeze({ Size = Vector3.new(1.6, 7, 1.6), Color = Color3.fromRGB(242, 214, 100) }),
		Chair = table.freeze({ Size = Vector3.new(4.5, 5, 4), Color = Color3.fromRGB(167, 112, 77) }),
		Tire = table.freeze({ Size = Vector3.new(3.5, 3.5, 2), Color = Color3.fromRGB(52, 54, 59) }),
		TV = table.freeze({ Size = Vector3.new(6, 4, 1.5), Color = Color3.fromRGB(58, 68, 83) }),
		Couch = table.freeze({ Size = Vector3.new(9, 4, 3.5), Color = Color3.fromRGB(87, 139, 184) }),
		Safe = table.freeze({ Size = Vector3.new(4, 5, 4), Color = Color3.fromRGB(89, 99, 110) }),
	}),
}

return table.freeze(Visuals)
