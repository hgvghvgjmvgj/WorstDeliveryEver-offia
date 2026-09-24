--!strict

local function level(value: number, cost: number)
	return table.freeze({ Value = value, Cost = cost })
end

return table.freeze({
	TrackOrder = table.freeze({ "Strength", "CarrySpace", "Control", "Mobility", "StockSlots" }),

	Tracks = table.freeze({
		Strength = table.freeze({
			DisplayName = "STRENGTH",
			ProfileField = "StrengthLevel",
			Attribute = "CarryStrength",
			Description = "Carry heavier loads before Weight becomes dangerous.",
			Levels = table.freeze({
				level(15, 0),
				level(17, 1_200),
				level(19.5, 8_000),
				level(22.5, 40_000),
				level(26, 180_000),
				level(30, 700_000),
				level(34.5, 1_600_000),
				level(40, 3_500_000),
			}),
		}),

		CarrySpace = table.freeze({
			DisplayName = "CARRY SPACE",
			ProfileField = "CarrySpaceLevel",
			Attribute = "CarrySpace",
			Description = "Support more Bulk and larger awkward piles.",
			Levels = table.freeze({
				level(13, 0),
				level(15, 1_100),
				level(17.5, 7_000),
				level(20.5, 35_000),
				level(24, 160_000),
				level(28, 650_000),
				level(33, 1_500_000),
				level(39, 3_200_000),
			}),
		}),

		Control = table.freeze({
			DisplayName = "CONTROL",
			ProfileField = "ControlLevel",
			Attribute = "CarryControl",
			Description = "Handle unstable stacks with better control and recovery, especially while moving quickly.",
			Levels = table.freeze({
				level(1.00, 0),
				level(1.10, 2_200),
				level(1.22, 15_000),
				level(1.35, 75_000),
				level(1.50, 310_000),
				level(1.67, 1_150_000),
				level(1.85, 2_400_000),
				level(2.05, 5_000_000),
			}),
		}),

		-- M6A.3 economy test curve. Speed solves the long warehouse, but each step
		-- must compete with Rig progress instead of being an automatic cheap max.
		Mobility = table.freeze({
			DisplayName = "SPEED",
			ProfileField = "MobilityLevel",
			Attribute = "MobilityWalkSpeed",
			Description = "Run through mastered sections much faster; heavy/dangerous loads suppress part of the bonus.",
			Levels = table.freeze({
				level(20.0, 0),
				level(28.0, 2_500),
				level(38.0, 12_000),
				level(49.0, 60_000),
				level(61.0, 250_000),
				level(74.0, 1_000_000),
				level(88.0, 4_000_000),
			}),
		}),

		-- Stock capacity is a permanent economic investment. Prices are aligned to
		-- the same progression bands as Rig/Speed so Stock remains a real choice.
		StockSlots = table.freeze({
			DisplayName = "STOCK SLOTS",
			ProfileField = "StockSlotLevel",
			Attribute = "StockSlotCapacity",
			Description = "Keep more delivered objects generating passive income.",
			Levels = table.freeze({
				level(3, 0),
				level(4, 12_000),
				level(5, 45_000),
				level(6, 160_000),
				level(8, 650_000),
				level(10, 2_400_000),
			}),
		}),
	}),

	DefaultCarryRigTier = 1,
	PurchaseCooldownSeconds = 0.12,
})
