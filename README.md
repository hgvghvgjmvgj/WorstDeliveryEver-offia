# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading/resale bay.

## Current milestone

**M4 — Persistence + Real Progression Foundation — awaiting Studio validation**

The Map Architecture V2 macro-layout is locked for this milestone. M4 adds persistence, real Cash upgrades, offline Stock earnings and denser warehouse population without redesigning the approved carry/map systems.

M5 has **not** started.

## Persistent profile

`src/server/Services/PlayerDataService.lua` owns persistent player data through Roblox DataStoreService.

Current saved schema (version 1) contains:

- Cash
- Strength Level
- Carry Space Level
- Control Level
- Mobility Level
- Stock Slot Level
- future-facing Carry Rig Tier
- every occupied Stock Slot and its economic metadata
- passive fractional remainder
- trusted last-seen timestamp
- session ownership record while connected

Safety includes UpdateAsync session claiming, retries/backoff, sanitization/default repair, schema version checks, autosave, PlayerRemoving final save/session release and BindToClose saving.

If Studio API Services are unavailable, Studio uses a clearly marked temporary profile rather than pretending persistence passed.

## Offline Stock earnings

Saved Stock remains conceptually productive while the player is away.

On the next persistent load, the server atomically calculates:

`Total saved passive rate / 60 × trusted elapsed seconds`

using server time, then claims the profile session in the same UpdateAsync transaction. This prevents reconnecting repeatedly to claim the same absence.

Current temporary offline cap: **2 hours**.

Invalid/negative/future elapsed time produces no offline award. The client clock is never trusted.

## M4 upgrades

All upgrades use **Cash**.

Current test tracks:

### Strength

Comfortable Weight frontier:

`15 → 17 → 19.5 → 22.5 → 26 → 30 → 34.5 → 40`

### Carry Space

Comfortable Bulk frontier:

`13 → 15 → 17.5 → 20.5 → 24 → 28 → 33 → 39`

### Control

Improves handling of increasingly unstable stacks:

`1.00 → 1.10 → 1.22 → 1.35 → 1.50 → 1.67 → 1.85 → 2.05`

### Mobility

Unloaded/search WalkSpeed:

`16 → 17.5 → 19 → 20.5 → 22 → 23.5 → 25`

Mobility is load-suppressed. The faster exploration bonus is strongest unloaded/lightly loaded; dangerous Weight ratios retain only a small fraction of it so absurd loads still have consequential returns.

### Stock Slots

Physical Stock capacity:

`3 → 4 → 5 → 6 → 8 → 10`

Slot upgrades are intentionally priced above the first small carry upgrades because each slot permanently increases passive-income potential.

All test values/costs live in `src/shared/Config/ProgressionConfig.lua` and are not final live balance.

## SELL / KEEP economy

The corrected big-number direction remains:

- Box: SELL $600 / KEEP +$50/min
- Microwave: SELL $1.8K / KEEP +$120/min
- Lamp: SELL $1.35K / KEEP +$90/min
- Chair: SELL $3.96K / KEEP +$220/min
- Tire: SELL $3.24K / KEEP +$180/min
- TV: SELL $10K / KEEP +$500/min
- Couch: SELL $18.7K / KEEP +$850/min
- Safe: SELL $30K / KEEP +$1.2K/min

SELL value is derived from passive rate × target break-even time.

KEEP sacrifices the original full SELL opportunity. Later liquidation currently pays **20% salvage**, preventing permanent passive earnings plus a full-value cash-out double dip.

`src/shared/NumberFormat.lua` keeps large Cash/rates readable with K / M / B / T suffixes.

## Stock persistence

Kept Stock is persistent and server-authoritative.

On join:

`saved Stock → runtime Stock state → physical owner-bay display → passive contribution`

A sold/replaced Stock entry is removed from the profile and must not reappear after rejoin. Physical Stock remains non-colliding, non-queryable and non-stealable.

## Warehouse V2 + M4 density

The macro-layout remains **660 × 420 studs** with:

- 12 bays on the primary loading side
- Receiving / Dispatch apron
- General Goods
- Appliances / Electronics
- Furniture / Oversized
- Industrial / Heavy
- Mid Cross-Aisle
- Deep Cross-Aisle
- Freight vs service-route choices

M4 increases authored loot opportunities from **36 to 64** without changing the building layout.

Current server-controlled population target:

- solo: 12 active per sector = **48 active objects**
- population scales upward with player count
- 12 players: 16 active per sector = **64 active objects**

Spawn positions remain authored rack/pallet/staging/cage locations. The server does not randomly scatter loot across open floor.

When server population decreases, existing extra objects are not visibly deleted; disabled source points simply stop restocking after those objects are taken.

## Preserved core systems

M4 does not intentionally redesign:

- GRAB / carry feel
- deterministic pile layout
- Base Instability
- movement-driven Current Sway
- Load Pressure / Strain
- partial collapse consequence
- intentional ditch sacrifice
- multiplayer first-valid-grab authority
- V2 warehouse macro architecture
- SELL vs KEEP
- permanent physical Stock

Progression moves the danger frontier outward rather than deleting it.

## Still excluded

- final rarity ladder
- Mythic / Cosmic / Secret content
- collection
- personalized buyers/contracts
- major server-wide events
- traditional Luck stat
- hard warehouse progression locks
- final Carry Rig models
- final warehouse art
- final UI
- monetization
- rebirths
- pets/workers
- trading

## Validation

M4 requires real Studio/DataStore/multi-client validation before approval.

Use:

`docs/M4_PLAYTEST.md`

Persistence tests only count when the server Player reports `PersistenceStatus = PERSISTENT`. A `TEMPORARY_STUDIO:...` profile is useful for gameplay testing but intentionally does not persist.

**Do not begin M5 until M4 is reviewed.**
