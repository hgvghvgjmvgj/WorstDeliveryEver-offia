--!strict

export type ShapeTag = "Compact" | "Tall" | "Wide"

export type ItemDefinition = {
	DisplayName: string,
	Value: number,
	Weight: number,
	Bulk: number,
	Shape: ShapeTag,
	TestSize: Vector3,
}

local Items: {[string]: ItemDefinition} = {
	Box = {
		DisplayName = "Box",
		Value = 15,
		Weight = 1,
		Bulk = 1,
		Shape = "Compact",
		TestSize = Vector3.new(3, 3, 3),
	},
	Microwave = {
		DisplayName = "Microwave",
		Value = 40,
		Weight = 2,
		Bulk = 2,
		Shape = "Compact",
		TestSize = Vector3.new(4, 2.5, 3),
	},
	Lamp = {
		DisplayName = "Lamp",
		Value = 40,
		Weight = 1,
		Bulk = 1,
		Shape = "Tall",
		TestSize = Vector3.new(2, 7, 2),
	},
	Chair = {
		DisplayName = "Chair",
		Value = 55,
		Weight = 2,
		Bulk = 2,
		Shape = "Wide",
		TestSize = Vector3.new(4, 5, 4),
	},
	Tire = {
		DisplayName = "Tire",
		Value = 30,
		Weight = 2,
		Bulk = 1,
		Shape = "Compact",
		TestSize = Vector3.new(3.5, 3.5, 2),
	},
	TV = {
		DisplayName = "TV",
		Value = 70,
		Weight = 3,
		Bulk = 2,
		Shape = "Wide",
		TestSize = Vector3.new(6, 4, 1.5),
	},
	Couch = {
		DisplayName = "Couch",
		Value = 100,
		Weight = 3,
		Bulk = 4,
		Shape = "Wide",
		TestSize = Vector3.new(9, 4, 3.5),
	},
	Safe = {
		DisplayName = "Safe",
		Value = 100,
		Weight = 6,
		Bulk = 2,
		Shape = "Compact",
		TestSize = Vector3.new(4, 5, 4),
	},
}

return table.freeze(Items)
