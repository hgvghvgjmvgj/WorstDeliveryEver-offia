# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading/resale bay.

## Current milestone

**M3 — Delivery Economy: Quick Sell vs Stock/List — awaiting Studio validation**

M1/M1.1 carry feel, M2 multiplayer ownership, M2.1 Load Pressure/Strain, M2.2 warehouse/base structure, and M2.3 ditch sacrifice remain preserved.

M4 persistence/offline progression has **not** started.

## M3 delivery economy

Successful delivery no longer ends as a pure instant-money loop.

The player now gets a fast Delivery Review:

- **QUICK SELL ALL** — one-button immediate Cash using existing prototype item Value.
- select valuable items to **STOCK** — consumes limited bay slots for a larger delayed payout.
- **QUICK SELL REST** — immediately resolves everything that was not Stocked.

Server owns all Cash, delivered-item state, stock slots, listing timers, payouts, and sale completion. Clients only send action intent using server-issued review/item IDs.

## Stock foundation

- default: **3 Stock Slots**
- development capacities: **3 / 5 / 7 / 10** using the server Player `StockSlotCapacity` attribute
- server Player `DevSaleSpeedMultiplier` accelerates newly-created listings for timer testing
- Stock payout/timer tuning is centralized in `src/shared/Config/EconomyConfig.lua`
- Stock objects physically appear in the owner's bay
- Stock display objects are anchored, non-colliding, non-queryable, and cannot be stolen
- other players can see another player's listed objects
- listings sell once, grant Cash once, free their slot, and remove their physical display
- Stock does **not** generate permanent cash-per-second income

## Current item lifecycle

Normal warehouse item:

`World → Carried → Delivered Review → Quick Sold`

or:

`World → Carried → Delivered Review → Stocked → Sold`

Collapse and intentional ditch remain separate terminal trip-loss paths and never enter the economy review.

## Current prototype economics

Quick Sell starts from the existing `ItemConfig.Value`.

Current Stock tuning:

- Box: $15 now / ~$20 later / ~20s
- Microwave: $40 now / ~$55 later / ~30s
- Lamp: $40 now / ~$59 later / ~38s
- Chair: $55 now / ~$74 later / ~42s
- Tire: $30 now / ~$45 later / ~32s
- TV: $70 now / ~$102 later / ~50s
- Couch: $100 now / ~$140 later / ~65s
- Safe: $100 now / ~$155 later / ~75s

These are prototype values only, not final economy balance.

## Persistence readiness

M3 stores active listing data in a shape that can later be persisted:

- item identifier
- listing start Unix timestamp
- effective sale duration
- expected payout
- Stock Slot index
- unique listing ID

M3 intentionally does not use DataStores and does not simulate offline sales. Disconnecting clears temporary economy state. M4 will add persistence/offline elapsed-time handling.

## Existing warehouse/base foundation

- 12-player shared warehouse
- 560 x 560 stud current graybox footprint
- Near / Mid / Deep travel-depth structure
- 36 authoritative shared item positions
- open social sightlines and large-stack routes
- 12 loading/resale bays around the outer perimeter
- owner-only delivery processing zones
- 10 reserved physical stock positions per bay
- player-facing LOAD PRESSURE meter

## LOAD PRESSURE / trip-loss behavior

The server system is called Strain internally. Normal players see LOAD PRESSURE as:

- LOW
- BUILDING
- HIGH
- CRITICAL

Intentional Q / ButtonB ditching sacrifices the top item and cannot be used as recoverable temporary storage. Collapse loss and ditch loss remain non-grabbable presentation-only trip losses.

## Controls

- **E / mobile GRAB** — grab nearest highlighted available warehouse item
- **Q / ButtonB** — ditch the top / most recently grabbed carried item; it is lost from the trip
- Delivery Review — tap/click delivered rows to mark Stock candidates
- **F3** — developer carry telemetry

## Still excluded

- DataStore persistence
- true offline selling
- Carry upgrades
- Stock Slot purchases
- sale-speed upgrades
- buyer contracts
- final rarity system
- collection
- Secret deliveries
- traditional Luck
- monetization
- workers
- pets
- rebirths
- final bay art
- final warehouse art
- polished final UI

## Current validation docs

- `docs/M2_2_PLAYTEST.md` — warehouse/base structure validation
- `docs/M2_3_PLAYTEST.md` — ditch sacrifice / Load Pressure validation
- `docs/M3_PLAYTEST.md` — Quick Sell / Stock delivery economy validation
