# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading/resale bay.

## Current milestone

**M3 MAP ARCHITECTURE V2 — Full-Footprint Long-Form Warehouse — awaiting Studio validation**

The previous warehouse correction was rejected after playtesting/visual review because gameplay still occupied one compressed region inside a much larger empty frame.

M1/M1.1 carry feel, M2 multiplayer authority, M2.1 Load Pressure/Strain, M2.3 ditch sacrifice, and the corrected M3 SELL/KEEP passive-Stock economy remain preserved.

M4 persistence/offline progression has **not** started.

## M3 economy foundation preserved

Each item economy config defines:

- `PassivePerMinute`
- `TargetBreakEvenMinutes`

Immediate SELL value is derived centrally as:

`PassivePerMinute × TargetBreakEvenMinutes`

Current test values are intentionally large and temporary:

- Box: SELL $600 / KEEP +$50/min
- Microwave: SELL $1.8K / KEEP +$120/min
- Lamp: SELL $1.35K / KEEP +$90/min
- Chair: SELL $3.96K / KEEP +$220/min
- Tire: SELL $3.24K / KEEP +$180/min
- TV: SELL $10K / KEEP +$500/min
- Couch: SELL $18.7K / KEEP +$850/min
- Safe: SELL $30K / KEEP +$1.2K/min

KEEP permanently sacrifices the original full SELL opportunity. Later Stock liquidation currently pays a configurable 20% salvage value so players cannot KEEP for passive earnings and later double-dip the full original sale price.

`src/shared/NumberFormat.lua` supports readable K / M / B / T economy presentation.

## Map Architecture V2

The old radial map and the first compressed-sector correction are no longer the active architecture.

Current facility footprint:

**660 × 420 studs**

The long dimension runs across the loading face; depth runs from the player bays into the warehouse. This lets the playable facility use nearly the entire frame while keeping Deep travel within useful gameplay timings.

### Loading side

- 12 player loading/resale bays across the primary loading side
- shared Receiving / Dispatch apron: approximately `640 × 70`
- freight crossing area
- two purposeful oversized receiving/staging pockets
- visible Stock and returning giant piles remain part of the shared social area

### Four long sectors

Each sector is approximately `140 × 295` studs and runs from Receiving toward Deep storage.

1. **General Goods** — open racks and pallets
2. **Appliances / Electronics** — larger storage-bay masses
3. **Furniture / Oversized** — broad open staging areas
4. **Industrial / Heavy** — heavy pads and cage-like storage

The layouts intentionally use different primitive geometry so the graybox does not read as one copied aisle repeated four times.

Players are never assigned to a sector.

### Travel depth

Near / Mid / Deep are physical route depth, not rooms or circular rings.

Current coordinate-audit estimates for each bay's closest practical opportunities:

- Near: roughly `90–122` route studs
- Mid: roughly `185–230` route studs
- Deep: roughly `317–347` route studs

At 16 studs/s before normal player movement/turning costs:

- Near: ~5.6–7.6s
- Mid: ~11.5–14.4s
- Deep: ~19.8–21.7s

At the current 9.5 studs/s heavily-loaded minimum speed:

- Near: ~9.5–12.8s
- Mid: ~19.4–24.2s
- Deep: ~33.3–36.5s

Studio timing still needs validation.

### Cross-aisles

- Mid Cross-Aisle at `Z = 18`, approximately 30 studs wide
- Deep Cross-Aisle at `Z = -92`, approximately 34 studs wide

They connect all four sectors, support route switching, and are intended as recurring social intersections for the 12-player server.

### Freight vs Service

Each sector has:

- **Main Freight Route** — ~295 studs full depth, 30 studs wide, straight/readable
- **Service Route** — ~276 studs end-to-end, 18 studs wide, shorter but with more directional changes

The goal is a natural carrying tradeoff: giant unstable piles prefer the wider route, while a smaller/controlled load can save some distance through the service path.

This tradeoff still requires Studio playtesting.

### Loot distribution

There are still 36 authoritative shared opportunities: nine per sector.

They are now spread through receiving positions, racks, storage bays, side branches, staging areas, cages and deep positions instead of sitting on obvious loot pads.

Spawn markers are invisible. Visible architecture provides the spatial context.

The target search rhythm is a meaningful opportunity/decision approximately every 3–6 seconds rather than constant dense loot or long empty walking.

### Full-footprint use

The meaningful coordinate envelope currently spans approximately:

- X: `-320` to `+320`
- Z: about `-199` to `+195`

inside a `660 × 420` footprint.

That is roughly 91% of the total floor by bounding-envelope coverage. This is not a claim that 91% is covered by solid props; it means gameplay/intentional spaces now occupy nearly the whole usable frame rather than being squeezed into one corner.

Large open regions now have explicit purposes: Receiving / Dispatch, cross-aisles, freight routes, oversized staging, or future Secure Storage connections.

## Preserved systems

Map V2 did not redesign:

- GRAB / carrying feel
- Base Instability
- Current Sway
- Load Pressure
- collapse consequence
- intentional ditch sacrifice
- SELL / KEEP
- passive Stock
- Cash
- bay Stock logic
- authoritative multiplayer item ownership

## Still excluded

- DataStore persistence
- true offline income
- progression purchases
- movement upgrades
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
- `docs/CORRECTION_ECONOMY_WAREHOUSE_PLAYTEST.md` — earlier correction gate
- `docs/MAP_ARCHITECTURE_V2_PLAYTEST.md` — active full-footprint warehouse validation gate

Do not begin M4 until Map Architecture V2 is reviewed in Studio.
