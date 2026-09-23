# ONE TRIP — M5B CARRY DIFFICULTY CORRECTION PLAYTEST

This is still M5B. M5C is NOT started.

## Purpose

Validate that the expanded M5B loot catalog now creates meaningful section-based carrying difficulty without changing the approved carry mechanic.

Rarity itself does NOT increase Weight/Bulk for the same base object. Difficulty comes from base object + section. Rare-only hero objects receive a modest extra burden.

## Current section carry scales

- Receiving: Weight x1.00, Bulk x1.00
- Appliances: Weight x1.05, Bulk x1.05
- Furniture: Weight x1.05, Bulk x1.25
- Heavy Goods: Weight x1.25, Bulk x1.10
- Industrial: Weight x1.40, Bulk x1.20
- Secure: Weight x1.50, Bulk x1.30
- Rare-only hero objects: additional Weight x1.10, Bulk x1.10

Level 1 reference: Strength 15, Carry Space 13, Control 1.0.

## Critical forced test

In Studio under Workspace > OneTripPrototype:

- DevForceSection = `Secure`
- DevForceRarity = `Eternal`
- DevForceBaseItemId = `BlackProjectContainmentUnit`
- toggle DevSpawnNow = true

Expected tuned Black-Project Containment Unit stats are approximately:

- Weight: 26.5
- Bulk: 10.0
- Shape: Tall

At Level 1, carrying it alone should already be consequential:

- Mobility should be heavily suppressed.
- Load Pressure should build quickly.
- Sharp acceleration/turning should create meaningful danger.
- Adding even one additional medium/heavy object should feel reckless.
- It must remain technically possible to attempt the trip; this is not a level lock.

FAIL if the item still feels like ordinary cargo.
FAIL if Level 1 can casually sprint/turn home with it without pressure.
FAIL if it is effectively impossible even with careful movement.

## Progression comparison

Repeat the same forced cargo using stronger Strength/Carry Space/Control levels.

Expected:

- upgraded player still respects the object,
- but the same trip becomes substantially more manageable,
- progression creates real opportunity rather than simply increasing numbers on UI.

## Section identity sanity

Sample several normal items from each section.

Expected trend:

- Receiving: forgiving and stackable.
- Appliances: moderate mixed loads.
- Furniture: Bulk/Wide pressure is the main problem.
- Heavy Goods: Weight becomes the main problem.
- Industrial: high Weight plus awkward combinations.
- Secure: mixed difficult profiles with several objects that Level 1 should not casually combine.

Not every Secure item must be brutally heavy. Some high-value cases/art cargo may remain lighter so load-building decisions still vary.

## Regression checks

Confirm no change to:

- carry input/feel,
- Sway formulas,
- Load Pressure formulas,
- collapse behavior,
- M5A warehouse geometry,
- M4.1 replenishment pacing,
- SELL vs KEEP rules,
- rarity probabilities/economics.

## Debug inspection

Set `DevInspectItemId` to a complete runtime item id, for example:

`BlackProjectContainmentUnit__Eternal`

Then inspect OneTripPrototype attributes:

- DevInspectWeight
- DevInspectBulk
- DevInspectShape
- DevInspectSellValue
- DevInspectPassivePerMinute
- DevInspectRarity
- DevInspectSection

## Pass condition

M5B carry difficulty passes when the player reaction to valuable deep cargo becomes:

> "This thing is worth a ton, but can I actually get it home with anything else?"

and upgrades materially expand what combinations are practical, without adding hard level locks or changing the core carry mechanic.

STOP after validation. Do not begin M5C until reviewed.
