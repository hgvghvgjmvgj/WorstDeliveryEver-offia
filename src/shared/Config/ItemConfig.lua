--!strict

export type ShapeTag = "Compact" | "Tall" | "Wide"

export type ItemDefinition = {
	Name: string,
	Value: number,
	Weight: number,
	Bulk: number,
	ShapeTag: ShapeTag,
}

local Items: {[string]: ItemDefinition} = {
	Box = { Name = "Box", Value = 15, Weight = 1, Bulk = 1, ShapeTag = "Compact" },
	Microwave = { Name = "Microwave", Value = 40, Weight = 2, Bulk = 2, ShapeTag = "Compact" },
	Lamp = { Name = "Lamp", Value = 40, Weight = 1, Bulk = 1, ShapeTag = "Tall" },
	Chair = { Name = "Chair", Value = 55, Weight = 2, Bulk = 2, ShapeTag = "Wide" },
	Tire = { Name = "Tire", Value = 30, Weight = 2, Bulk = 1, ShapeTag = "Compact" },
	TV = { Name = "TV", Value = 70, Weight = 3, Bulk = 2, ShapeTag = "Wide" },
	Couch = { Name = "Couch", Value = 100, Weight = 3, Bulk = 4, ShapeTag = "Wide" },
	Safe = { Name = "Safe", Value = 100, Weight = 6, Bulk = 2, ShapeTag = "Compact" },
}

return table.freeze(Items)
