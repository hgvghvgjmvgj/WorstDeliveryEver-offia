--!strict

local EconomyConfig = require(script.Parent:WaitForChild("EconomyConfig"))

export type ShapeTag = "Compact" | "Tall" | "Wide"

export type ItemDefinition = {
	Name: string,
	Value: number,
	Weight: number,
	Bulk: number,
	ShapeTag: ShapeTag,
}

local function sellValue(itemId: string): number
	local tuning = EconomyConfig.Items[itemId]
	if not tuning then
		return 0
	end
	return math.max(0, math.floor(tuning.PassivePerMinute * tuning.TargetBreakEvenMinutes + 0.5))
end

-- Value is the current immediate SELL / carried run value. Weight/Bulk/Shape remain
-- the carry-system inputs. Economy tuning itself stays centralized in EconomyConfig.
local Items: {[string]: ItemDefinition} = {
	Box = { Name = "Box", Value = sellValue("Box"), Weight = 1, Bulk = 1, ShapeTag = "Compact" },
	Microwave = { Name = "Microwave", Value = sellValue("Microwave"), Weight = 2, Bulk = 2, ShapeTag = "Compact" },
	Lamp = { Name = "Lamp", Value = sellValue("Lamp"), Weight = 1, Bulk = 1, ShapeTag = "Tall" },
	Chair = { Name = "Chair", Value = sellValue("Chair"), Weight = 2, Bulk = 2, ShapeTag = "Wide" },
	Tire = { Name = "Tire", Value = sellValue("Tire"), Weight = 2, Bulk = 1, ShapeTag = "Compact" },
	TV = { Name = "TV", Value = sellValue("TV"), Weight = 3, Bulk = 2, ShapeTag = "Wide" },
	Couch = { Name = "Couch", Value = sellValue("Couch"), Weight = 3, Bulk = 4, ShapeTag = "Wide" },
	Safe = { Name = "Safe", Value = sellValue("Safe"), Weight = 6, Bulk = 2, ShapeTag = "Compact" },
}

return table.freeze(Items)
