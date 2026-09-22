# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading/resale bay.

## Current milestone

**M2.2 - Warehouse + Player Bay / Base Redesign / awaiting Studio validation**

M1/M1.1 carry feel, M2 multiplayer ownership, and M2.1 Carry Strain remain locked.

## M2.2 structure

- 12-player concentric shared warehouse
- 500 x 500 stud overall graybox footprint
- structured Near / Mid / Deep risk gradient
- 36 authoritative shared item positions
- open sightlines instead of narrow aisle mazes
- 12 open loading/resale bays around the outer ring
- owner-only delivery processing zones
- 3 visible future stock/display positions per bay
- 10 total reserved stock positions per bay for future expansion
- future Quick Sell and Bay Upgrade anchors
- 4 reserved future warehouse expansion points
- 46-stud nonblocking ceiling-clearance reference
- player-facing LOAD PRESSURE meter

## Warehouse depth

### Near / General Goods

Mostly Boxes, Microwaves, Lamps, Chairs, and ordinary TVs.

Closest safe opportunity layer.

### Mid Warehouse

More TVs, Couches, Chairs, and Safes.

Longer return route with more meaningful carry pressure.

### Deep / High Value Test

Mostly Safes, Couches, and TVs using the existing prototype item set.

Designed to make the return trip long enough for dangerous loads and Load Pressure to matter.

## Approximate distance measurements

Measured from bay unload locations to the nearest stock opportunity:

- Near: about 63-88 studs depending on bay/cluster alignment
- Mid: about 113-151 studs
- Deep: about 180-199 studs

At normal 16-stud walk speed this is roughly:

- Near: about 3.9-5.5 seconds
- Mid: about 7.1-9.4 seconds
- Deep: about 11.3-12.4 seconds

At the current heavily-loaded 9.5-stud minimum movement speed:

- Near: about 6.6-9.3 seconds
- Mid: about 11.9-15.9 seconds
- Deep: about 18.9-20.9 seconds

These are geometry estimates, not forced timers.

## Bay foundation

Each bay remains session-owned and contains:

- SpawnMarker
- Delivery / Processing area
- owner-only UnloadZone
- placeholder van
- StockSlots folder
- visible StockSlot01-03
- reserved StockSlot04-10 expansion anchors
- FutureQuickSellAnchor
- FutureBayUpgradeAnchor

No selling, Cash, offline earnings, timers, or upgrades are implemented yet.

## LOAD PRESSURE

The underlying server system is still called Strain internally.

Normal players now see LOAD PRESSURE as a simple meter with:

- LOW
- BUILDING
- HIGH
- CRITICAL

The bar shows holding pressure only. It is **not collapse chance** and it does not show an exact percentage/countdown.

Collapse still depends on the existing Base Instability, Current Sway, movement, recovery, stack composition, and Strain-modified difficulty.

F3 developer telemetry still exposes exact internal Strain values for tuning.

## Prototype stock distribution

- Near: 16 positions, average prototype item value about 39
- Mid: 12 positions, average prototype item value about 74
- Deep: 8 positions, average prototype item value about 93

This uses existing items only and does not implement rarity or personal Luck.

## Still excluded

- Quick Sell economy
- stock/list sale timers
- offline earnings
- Cash balancing
- base upgrade purchases
- DataStores
- final progression
- final rarity
- collection
- contracts
- traditional Luck
- monetization
- final map art
- detailed models
- final UI polish
- pets / workers / helpers
- rebirths

## Controls

- **E / mobile GRAB** - grab nearest highlighted available item
- **Q** - intentionally drop the top item
- **F3** - developer telemetry

See `docs/M2_2_PLAYTEST.md` for the M2.2 validation gate.