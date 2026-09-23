# ONE TRIP — ECONOMY SCALE + WAREHOUSE CORRECTION PLAYTEST

This correction pass must be Studio-validated before M4 or progression purchases begin.

## Setup

1. Pull `main`.
2. Restart `rojo serve` and reconnect Studio.
3. Start a fresh Play session.
4. Confirm server Player attributes:
   - `StockSlotCapacity = 3`
   - `DevPassiveIncomeMultiplier = 1`
5. For accelerated passive testing only, set `DevPassiveIncomeMultiplier = 60` on the SERVER Player.

---

# PART A — ECONOMY

## A1 — Big-number SELL / KEEP

Deliver one of each prototype item over several runs.

Expected current test values:

- Box: SELL $600 / KEEP +$50/min
- Microwave: SELL $1.8K / KEEP +$120/min
- Lamp: SELL $1.35K / KEEP +$90/min
- Chair: SELL $3.96K / KEEP +$220/min
- Tire: SELL $3.24K / KEEP +$180/min
- TV: SELL $10K / KEEP +$500/min
- Couch: SELL $18.7K / KEEP +$850/min
- Safe: SELL $30K / KEEP +$1.2K/min

Verify the UI uses K/M/B/T formatting rather than unreadable raw values.

## A2 — SELL

1. Deliver an item.
2. SELL it.
3. Verify immediate Cash exactly once.
4. Verify no Stock entry/display is created.
5. Spam the SELL action if possible and verify no duplicate payout.

## A3 — KEEP / passive

1. KEEP a known item.
2. Verify it occupies exactly one Stock Slot.
3. Verify its physical object remains in the bay.
4. Verify its passive rate is shown in the HUD and Stock display.
5. Set `DevPassiveIncomeMultiplier = 60` for a quick test.
6. Verify Cash increases at approximately the configured base rate per test second.
7. Verify the Stock object does not auto-sell/disappear.

## A4 — break-even relation

Check code/config math rather than final feel balance:

`SELL = PassivePerMinute × TargetBreakEvenMinutes`

Verify current break-even targets range approximately 12–25 minutes.

The exact numbers are not final. Judge whether the relationship is understandable and easy to tune.

## A5 — no full-value double-dipping

1. KEEP an item.
2. Let it earn passive Cash.
3. Open MANAGE STOCK.
4. Liquidate it.
5. Verify liquidation pays only the configured salvage amount, not original full SELL value.
6. Current default salvage should be 20% of original SELL.
7. Verify passive contribution stops immediately.
8. Verify physical display disappears.
9. Verify slot frees.
10. Spam liquidation and verify one payout only.

## A6 — replacement pressure

1. Fill all 3 Stock Slots with weaker items.
2. Deliver a stronger passive item.
3. Verify KEEP cannot exceed capacity.
4. Decide whether to SELL the new item or liquidate one old Stock item.
5. Liquidate the weakest item.
6. KEEP the stronger delivered item.
7. Verify passive total changes correctly and no duplicate/lost Cash occurs.

## A7 — large-number headroom

Temporarily inspect/test formatter values around:

- 950
- 1,200
- 15,000
- 1,250,000
- 1,050,000,000
- 2,500,000,000,000

Expected readable outputs approximately:

- 950
- 1.2K
- 15K
- 1.25M
- 1.05B
- 2.5T

No progression purchase system should be added during this test.

---

# PART B — WAREHOUSE

## B1 — first visual read

From the loading apron, verify the map no longer reads as concentric loot rings.

Expected read:

`12 BAYS → RECEIVING/DISPATCH → FOUR SECTORS → CROSS-AISLES → DEEP STORAGE`

The four sector identities should be visually obvious from labels/floor/rack layout even before final art.

## B2 — solo route depth

Run from several bays to the nearest opportunity at each depth.

Geometry target before route penalties:

- Near: ~76–101 studs
- Mid: ~163–176 studs
- Deep: ~275–283 studs

At 16 studs/s, rough unloaded travel target:

- Near: ~4.8–6.3s
- Mid: ~10.2–11.0s
- Deep: ~17.2–17.7s

Record actual Studio travel times because racks, path choice and turning make real paths longer.

## B3 — loaded return

Repeat with a dangerous/heavy pile.

At the current 9.5 studs/s minimum loaded movement speed, pure distance estimates are:

- Near: ~8.0–10.7s
- Mid: ~17.1–18.5s
- Deep: ~28.9–29.7s

Judge whether Deep feels like a meaningful commitment without becoming empty walking.

## B4 — loot spacing

Walk one sector front-to-back.

Expected:

- loot is not sitting in tiny mixed clusters
- opportunities appear at racks/pallets/staging areas
- players make a decision every few seconds
- not every object is visible from spawn
- no 20-second dead stretches
- no view containing dozens of simultaneously grabbable objects

## B5 — sector identity

Test each sector:

### General Goods
Should feel flexible / lower-pressure / mixed.

### Appliances / Electronics
Should center around Microwaves/TVs and mixed shapes.

### Furniture / Oversized
Should visibly feature Chair/Couch/Wide-object problems.

### Industrial / Heavy
Should visibly feature Tire/Safe/Weight problems.

No sector should feel like the only rational route simply because its expected value dominates everything else.

## B6 — cross-aisles / social intersections

Use both cross-aisles to change sectors without returning to the apron.

Verify:

- lanes are wide enough for ridiculous stacks
- players can see others crossing
- they do not become choke points
- they create social contact without forcing everyone onto one loot pile

## B7 — freight vs service route

Compare each sector's broad freight route with the service route.

Observe:

- actual travel time
- number/sharpness of turns
- camera comfort
- Sway generated by turns
- large-pile clearance

If one path is both fastest AND safest, the route choice is not solved yet. Report that rather than hiding it.

## B8 — bay fairness

Test multiple bay positions, including:

- far left
- left-center
- center
- right-center
- far right

The current nearest-depth geometry is intentionally close across bay positions, but actual paths must be checked.

No bay should receive a permanent massive advantage to the best route/value.

## B9 — 12-player test

Use Studio multi-client testing if available.

Observe:

- player distribution by sector
- whether everyone still piles into one sector
- cross-aisle encounters
- loading-apron social visibility
- loot starvation after several players clear one area
- congestion with giant stacks
- whether dispersed sectors feel lonely
- frame rate / replication

This cannot be certified from repository inspection alone.

## B10 — deep camping

Have one or more players remain around Deep opportunities.

Check whether short restock times make camping the strongest strategy.

If yes, do NOT solve it with personal Luck. Flag restock/spawn distribution for a later targeted correction.

---

# PASS GATE

Do not approve the correction until:

- big-number economy displays correctly
- SELL/KEEP stays meaningful
- Stock liquidation prevents full-value double-dipping
- active runs still matter
- radial map read is gone
- sectors feel spatially distinct
- Near/Mid/Deep read as travel depth
- loot is sufficiently spaced
- 12-player distribution is acceptable
- freight/service route choice is not obviously fake
- no severe bay advantage is found

Do not begin M4 automatically after this test. Project-lead review is required.
