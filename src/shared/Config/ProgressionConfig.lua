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
				level(15, 0), level(17, 500), level(19.5, 1_200), level(22.5, 2_800),
				level(26, 6_500), level(30, 15_000), level(34.5, 35_000), level(40, 80_000),
			}),
		}),

		CarrySpace = table.freeze({
			DisplayName = "CARRY SPACE",
			ProfileField = "CarrySpaceLevel",
			Attribute = "CarrySpace",
			Description = "Support more Bulk and larger awkward piles.",
			Levels = table.freeze({
				level(13, 0), level(15, 450), level(17.5, 1_100), level(20.5, 2_600),
				level(24, 6_000), level(28, 14_000), level(33, 33_000), level(39, 76_000),
			}),
		}),

		Control = table.freeze({
			DisplayName = "CONTROL",
			ProfileField = "ControlLevel",
			Attribute = "CarryControl",
			Description = "Handle unstable stacks with better control and recovery, especially while moving quickly.",
			Levels = table.freeze({
				level(1.00, 0), level(1.10, 800), level(1.22, 1_800), level(1.35, 4_000),
				level(1.50, 9_000), level(1.67, 21_000), level(1.85, 48_000), level(2.05, 110_000),
			}),
		}),

		-- Mobility remains the persisted/internal stat. M6A.2 makes it the real
		-- solution to 1,300+ stud outward traversal rather than adding a second
		-- redundant Speed stat. The endgame ceiling is intentionally dramatic so
		-- mastered early sections become something advanced players can blast
		-- through; loaded return speed is still constrained by Weight/handling.
		Mobility = table.freeze({
			DisplayName = "SPEED",
			ProfileField = "MobilityLevel",
			Attribute = "MobilityWalkSpeed",
			Description = "Run through mastered sections much faster; heavy/dangerous loads suppress part of the bonus.",
			Levels = table.freeze({
				level(16.0, 0),
				level(22.0, 700),
				level(29.0, 1_600),
				level(37.0, 3_800),
				level(46.0, 9_000),
				level(55.0, 22_000),
				level(65.0, 55_000),
			}),
		}),

		StockSlots = table.freeze({
			DisplayName = "STOCK SLOTS",
			ProfileField = "StockSlotLevel",
			Attribute = "StockSlotCapacity",
			Description = "Keep more delivered objects generating passive income.",
			Levels = table.freeze({
				level(3, 0), level(4, 5_000), level(5, 15_000), level(6, 45_000),
				level(8, 120_000), level(10, 350_000),
			}),
		}),
	}),

	DefaultCarryRigTier = 1,
	PurchaseCooldownSeconds = 0.12,
})
