# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading/resale bay.

## Current milestone

**M3 CORRECTION — Economy Scale + Warehouse Architecture — awaiting Studio validation**

M1/M1.1 carry feel, M2 multiplayer ownership, M2.1 Load Pressure/Strain, M2.3 ditch sacrifice, and the M3 SELL/KEEP passive-Stock concept remain preserved.

M4 persistence/offline progression has **not** started.

## Economy correction

The economy now supports a deliberately larger Roblox-style presentation scale while balancing around **time/effort to improvement**, not arbitrary big numbers.

Each item config defines:

- `PassivePerMinute`
- `TargetBreakEvenMinutes`

Immediate SELL value is derived centrally as:

`PassivePerMinute × TargetBreakEvenMinutes`

This keeps SELL and KEEP economically related instead of inventing two unrelated values.

Current correction-pass test values:

- Box: SELL $600 / KEEP +$50/min / ~12m break-even
- Microwave: SELL $1.8K / KEEP +$120/min / ~15m
- Lamp: SELL $1.35K / KEEP +$90/min / ~15m
- Chair: SELL $3.96K / KEEP +$220/min / ~18m
- Tire: SELL $3.24K / KEEP +$180/min / ~18m
- TV: SELL $10K / KEEP +$500/min / ~20m
- Couch: SELL $18.7K / KEEP +$850/min / ~22m
- Safe: SELL $30K / KEEP +$1.2K/min / ~25m

These are NOT final balance numbers. The architecture also documents progression bands from tens/hundreds per minute through millions per minute without implementing progression purchases yet.

### Stock liquidation / no double-dipping

Choosing KEEP sacrifices the original full immediate SELL opportunity.

If the player later removes a kept item through **MANAGE STOCK**, the item pays a configurable salvage value instead of its original full SELL value.

Current default salvage is **20%** of original SELL value.

This prevents:

`KEEP → earn passive forever → later receive the original full SELL value anyway`.

Stock remains physical, permanent for the session, limited by Stock Slots, and server-authoritative.

## Large-number presentation

`src/shared/NumberFormat.lua` formats economy values using readable suffixes such as:

- K
- M
- B
- T

The game does not need an infinite-number system yet; this simply prevents values like `1045238297` from cluttering the UI when `1.05B` is clearer.

## Warehouse architecture correction

The old radial structure is removed.

The active graybox is now **620 × 620 studs** with all 12 player loading/resale bays placed along a common front loading side.

The warehouse is organized as a navigable facility rather than concentric loot rings:

1. **Receiving / Dispatch apron** — shared social/readability area in front of all bays.
2. **General Goods sector** — flexible low/medium objects.
3. **Appliances / Electronics sector** — microwaves, TVs, mixed-value goods.
4. **Furniture / Oversized sector** — chairs, couches, wide/bulky objects.
5. **Industrial / Heavy sector** — tires, safes, weight-heavy objects.
6. **Cross-Aisle 1** — early/mid lateral social connection.
7. **Cross-Aisle 2** — deeper lateral social connection.
8. **Deep storage band** — separate deep opportunities in every sector, not one center loot pile.

Players are not assigned to sectors.

Near / Mid / Deep now describe **travel depth inside sectors**, not literal circular rings.

## Current route geometry

Approximate straight-line bay-unload distance to the nearest opportunity at each depth:

- Near: ~76–101 studs
- Mid: ~163–176 studs
- Deep: ~275–283 studs

At 16 studs/s unloaded speed:

- Near: ~4.8–6.3s
- Mid: ~10.2–11.0s
- Deep: ~17.2–17.7s

At the current heavily-loaded 9.5 studs/s minimum speed:

- Near: ~8.0–10.7s
- Mid: ~17.1–18.5s
- Deep: ~28.9–29.7s

These are geometry estimates. Rack avoidance, turns, sway management and route choice can make actual Studio times longer.

## Loot distribution

There are currently **36 authoritative shared opportunities**, spread as nine opportunities per sector rather than dense mixed-item clusters.

Opportunities are represented as rack bays, receiving pallets, floor staging, oversized zones and secure/deep positions.

The graybox uses solid rack rows for partial occlusion so players cannot see the entire warehouse from spawn, while wide freight lanes and cross-aisles preserve multiplayer visibility.

## Route choice foundation

Each sector exposes:

- a broad freight route intended to be readable for giant piles
- a narrower, turn-heavier service route
- two shared cross-aisles for changing sectors

This is still graybox geometry and MUST be Studio-tested for dominant-route problems before approval.

## Stock foundation

- default: **3 Stock Slots**
- development capacities: **3 / 5 / 7 / 10** using server Player `StockSlotCapacity`
- `DevPassiveIncomeMultiplier` accelerates passive earnings for Studio testing
- kept items remain physically visible in the owner's bay
- Stock objects are anchored, non-colliding, non-queryable and cannot be stolen
- passive income is calculated centrally; there is no loop per kept item

## Preserved carry / loss behavior

- GRAB / carrying feel
- Base Instability
- Current Sway
- Load Pressure
- collapse consequence
- intentional Q / ButtonB ditch sacrifice
- multiplayer item authority

## Still excluded

- DataStore persistence
- true offline income
- progression purchases
- Carry Rig progression
- Stock Slot purchases
- rarity ladder
- Secret deliveries
- buyer contracts
- traditional Luck
- final warehouse art
- final prop set
- monetization
- pets/workers
- rebirths

## Current validation docs

- `docs/M2_3_PLAYTEST.md` — ditch sacrifice / Load Pressure validation
- `docs/M3_PLAYTEST.md` — SELL / KEEP passive Stock validation
- `docs/CORRECTION_ECONOMY_WAREHOUSE_PLAYTEST.md` — big-number economy + new sector warehouse validation
