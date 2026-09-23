# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading/resale bay.

## Current milestone

**M3 — Delivery Economy: SELL vs KEEP — awaiting Studio validation**

M1/M1.1 carry feel, M2 multiplayer ownership, M2.1 Load Pressure/Strain, M2.2 warehouse/base structure, and M2.3 ditch sacrifice remain preserved.

M4 persistence/offline progression has **not** started.

## M3 delivery economy

Successful delivery creates a second decision instead of instantly converting everything to Cash.

The player gets a fast Delivery Review:

- **SELL ALL** — one-button large immediate Cash payout.
- select valuable items to **KEEP** — consumes limited bay Stock Slots and generates slow passive Cash.
- **SELL REST** — immediately sells everything not kept.

The authoritative rule is:

> SELL = money now.
>
> KEEP = long-term passive income, occupying a Stock Slot until the player deliberately sells it.

Kept Stock never auto-sells, never disappears on a timer, and never frees its slot by itself.

Server owns all Cash, delivered-item state, Stock slots, passive-income calculation, and Stock sales. Clients only send action intent using server-issued review/Stock IDs.

## Stock foundation

- default: **3 Stock Slots**
- development capacities: **3 / 5 / 7 / 10** using the server Player `StockSlotCapacity` attribute
- `DevPassiveIncomeMultiplier` can accelerate passive earnings for Studio testing without changing displayed base `+$X/min` rates
- SELL/passive-rate tuning is centralized in `src/shared/Config/EconomyConfig.lua`
- kept objects physically remain in the owner's bay
- Stock display objects are anchored, non-colliding, non-queryable, and cannot be stolen
- other players can see another player's kept objects
- Stock remains indefinitely until explicitly sold
- passive income is calculated centrally; there is no independent loop per stocked object

## Replacement rule

M3 uses an explicit sell-first replacement flow.

If all Stock Slots are full and the player delivers something better:

1. open **MANAGE STOCK**
2. choose an existing kept item
3. sell it for its normal immediate Sell Value
4. its passive contribution stops and its physical display disappears
5. the slot becomes free
6. return to Delivery Review and KEEP the stronger item

No valuable kept object is silently deleted or automatically replaced.

## Current item lifecycle

Normal warehouse item:

`World → Carried → Delivered Review → Sold`

or:

`World → Carried → Delivered Review → Kept in Stock → deliberately Sold later`

Collapse and intentional ditch remain separate terminal trip-loss paths and never enter the economy review.

## Current prototype economics

All values below are temporary M3 balance targets:

- Box: SELL $150 / KEEP +$1/min
- Microwave: SELL $400 / KEEP +$2/min
- Lamp: SELL $400 / KEEP +$2/min
- Chair: SELL $550 / KEEP +$3/min
- Tire: SELL $300 / KEEP +$2/min
- TV: SELL $700 / KEEP +$4/min
- Couch: SELL $1000 / KEEP +$5/min
- Safe: SELL $1000 / KEEP +$6/min

At base rates, a kept object takes roughly 150–200 minutes to generate the same Cash as selling immediately. This intentionally keeps active runs important and makes KEEP a long-term decision instead of an obvious short-term upgrade.

## Passive-income architecture

Each kept Stock entry records:

- unique Stock ID
- item identifier
- Stock Slot index
- source Delivery Review item ID
- Unix timestamp when kept
- passive rate per minute

The server periodically sums each player's Stock into one Total Passive Rate, accumulates fractional earnings, and only credits whole Cash when enough has accrued. This avoids one loop per item and avoids Cash/UI spam every frame.

M4 can later persist Stock contents plus timestamps and apply an offline earning cap without replacing the Stock data model.

M3 itself intentionally has no DataStores and no offline income. Disconnecting clears temporary session economy state.

## Existing warehouse/base foundation

- 12-player shared warehouse
- 560 x 560 stud current graybox footprint
- Near / Mid / Deep travel-depth structure
- 36 authoritative shared item positions
- open social sightlines and large-stack routes
- 12 loading/resale bays around the outer perimeter
- owner-only delivery processing zones
- 10 reserved physical Stock positions per bay
- player-facing LOAD PRESSURE meter

## LOAD PRESSURE / trip-loss behavior

The server system is called Strain internally. Normal players see LOAD PRESSURE as:

- LOW
- BUILDING
- HIGH
- CRITICAL

Intentional Q / ButtonB ditching sacrifices the top item and cannot be used as recoverable temporary storage. Collapse loss and ditch loss remain non-grabbable presentation-only trip losses.

## Controls / economy UI

- **E / mobile GRAB** — grab nearest highlighted available warehouse item
- **Q / ButtonB** — ditch the top / most recently grabbed carried item; it is lost from the trip
- Delivery Review — tap/click delivered rows to mark KEEP candidates
- **MANAGE STOCK** — inspect current Stock and explicitly sell an old kept item
- **F3** — developer carry telemetry

## Still excluded

- DataStore persistence
- true offline income
- Carry upgrades
- Stock Slot purchases
- passive-income upgrades
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
- `docs/M3_PLAYTEST.md` — corrected SELL / KEEP passive Stock validation
