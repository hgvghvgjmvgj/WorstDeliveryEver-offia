# ONE TRIP — M4.1 SUPPLY / OPPORTUNITY ECONOMY PLAYTEST

M4.1 is a focused correction. Do **not** begin M5 until this gate is reviewed.

## What changed

The warehouse still starts stocked, but individual pickups no longer start tiny independent respawn timers.

One server-authoritative supply controller now owns replenishment across all sectors.

Current M4.1 test tuning:

- solo initial target: 12 active objects per sector = 48 total
- 12-player target: 16 active objects per sector = 64 total
- centralized supply tick: every 4 seconds
- solo refill budget: 1 object/tick maximum
- 12-player refill budget: 5 objects/tick maximum
- severely depleted warehouse: at most +1 emergency refill attempt/tick
- ordinary vacancy window: about 15–30s solo
- strong vacancy window: about 30–60s solo
- high-value vacancy window: about 45–90s solo
- full-server timing scale bottoms at 65% of solo windows; supply does not scale x12

Those are test values, not final production tuning.

## Value bands

Current M4.1 uses immediate SELL value only as a temporary supply signal:

- Ordinary: below $5K
- Strong: $5K–$11,999
- High: $12K+

M5 rarity/section systems are not implemented.

## Anti-camping behavior

- taking an item makes that authored location vacant
- vacancy has a value-sensitive minimum age before it can refill
- replenishment happens only on the centralized supply tick
- the exact item removed from a spawn receives a very large same-location selection penalty
- refill item is selected from the same sector + travel-depth authored pool, not arbitrary floor positions
- strong/high removal also gates replacement of that value band elsewhere in the same sector for most of the vacancy window
- when a sector is severely depleted, ordinary/mid inventory receives recovery pressure while high-value items are suppressed

The goal is that waiting beside one Safe location is worse than exploring current warehouse state.

## Debug telemetry

Select `Workspace > OneTripPrototype` while running.

Useful attributes:

- `SupplyActiveObjects`
- `SupplyTargetPerSector`
- `SupplyConsumed`
- `SupplyReplenished`
- `SupplyConsumedPerMinute`
- `SupplyReplenishedPerMinute`
- `SupplyHighValueConsumed`
- `SupplyHighValueReplenished`
- `SupplyAverageVacancySeconds`
- `SupplySeverelyDepletedSectors`
- `Supply_<sector>_Active`
- `Supply_<sector>_Target`
- `Supply_<sector>_Health`

Sector health is internal debug state:

- Healthy
- Reduced
- Low
- SeverelyDepleted

To get a concise server summary every ~30 seconds, set on `OneTripPrototype`:

`SupplyDebugPrintEnabled = true`

It is false by default so production output is not spammed.

Existing `[ONE TRIP][M4 ECON TEST]` telemetry remains active.

---

# TEST A — Initial population

1. Start a fresh solo server.
2. Inspect `Workspace > OneTripPrototype > Items`.
3. Expect about 48 active objects: ~12 per sector.
4. Walk each sector once.
5. Confirm the warehouse still feels stocked rather than empty.

FAIL if M4.1 solved farming by making the initial warehouse sparse.

# TEST B — Solo depletion memory

Perform three or more normal SELL runs without waiting intentionally.

Run 1 should feel stocked.

Run 2 should visibly encounter some vacancies created by Run 1.

Run 3+ should sometimes make you:

- go farther
- switch aisle
- switch sector
- choose a weaker available object
- adapt instead of repeating the exact first route

FAIL if the warehouse looks identical every trip.

FAIL if the warehouse becomes almost completely barren.

# TEST C — Strong-item SELL opportunity cost

1. Find a TV, Couch, or Safe.
2. Note its exact source area.
3. SELL it.
4. Immediately return to that area.
5. Confirm the exact same opportunity is not already waiting for you.
6. Stay nearby long enough to observe replenishment behavior.

The location may eventually refill, but timing and replacement should not be deterministic and the exact removed item should not be guaranteed.

# TEST D — KEEP opportunity cost

1. On a comparable strong item, choose KEEP instead.
2. Notice the immediate SELL Cash you gave up.
3. Return to the source area.
4. Confirm that opportunity is still meaningfully scarce.

Question: does KEEP now feel more like converting a limited warehouse opportunity into permanent income?

# TEST E — Spawn camping

1. Identify the best known Safe/TV/Couch source location.
2. Stand beside it after taking its item.
3. Wait.
4. Compare the result with actively searching another aisle/sector.

PASS direction: exploration should clearly be the better use of time.

FAIL if the best strategy is still “stand here until the same thing returns.”

# TEST F — Fixed farm circuit

Build the best deterministic route you can find, e.g.:

Safe → TV → Couch → SELL → same route again.

Repeat it several times.

PASS direction:

- some expected positions remain empty
- replacements differ
- sector depletion changes the best route
- adapting beats memorizing one timer circuit

FAIL if the same high-value objects reliably regenerate just before you return.

# TEST G — Supply telemetry

During repeated solo runs, record:

- `SupplyConsumedPerMinute`
- `SupplyReplenishedPerMinute`
- `SupplyAverageVacancySeconds`
- active object count
- sector health
- high-value consumed vs replenished

Expected qualitative direction:

`consumption > replenishment` during aggressive solo farming for meaningful periods, followed by gradual recovery rather than instant reset.

# TEST H — Economy retest

Repeat the existing M4 economy tests after the supply correction.

Collect at least 6–10 `[ONE TRIP][M4 ECON TEST]` lines.

Report:

- average active $/min
- median active $/min
- average trip duration
- average items/run
- variance between runs
- whether fixed farming still works

Do not judge success only by whether $/min decreases. If ~$18K/min remains possible but now depends on finding and exploiting changing opportunities, that can be acceptable.

# TEST I — Passive comparison

After the corrected active telemetry, compare current Stock:

- weak 3-slot setup
- average early 3-slot setup
- strong early 3-slot setup

Record total passive $/min and compare each against corrected active $/min.

Do not rebalance passive again until this data exists unless there is an obvious extreme issue.

# TEST J — Upgrade usefulness

Retest existing upgrades without changing their values:

- Strength
- Carry Space
- Control
- Mobility

Ask:

> Does this upgrade help me capitalize on a valuable current opportunity?

Examples:

- carrying one more valuable object before someone else gets it
- safely returning with an awkward load
- moving to a less-depleted sector faster

If upgrades still feel pointless, report that. Do not silently redesign progression during M4.1.

# TEST K — 12-player supply

Use as many Studio clients as practical, ideally approaching 12.

Observe:

- total active objects
- sector depletion
- player dispersion
- valuable-item competition
- starvation
- supply recovery
- server/client performance

At 12 players the target is up to 16 objects/sector = 64 active, with at most ~5 normal refill attempts every 4 seconds plus the severe-depletion emergency allowance.

PASS direction: competition without starvation.

FAIL if everybody always has infinite best loot.

FAIL if everybody constantly has nothing.

# TEST L — Persistence/economy regression

M4.1 must not break:

- first-valid-grab authority
- collapse loss
- ditch sacrifice
- Delivery Review
- SELL
- KEEP
- Stock liquidation
- passive income
- persistent Cash/upgrades/Stock
- temporary balance-test DataStore namespace

# Approval questions

M4.1 is ready for project-lead review only when these feel true:

- initial warehouse still feels stocked
- pickups visibly alter future runs
- exact high-value spawn camping is unreliable
- fixed circuits are weaker than adapting
- SELL now sacrifices a real current opportunity
- KEEP gains real opportunity cost
- solo warehouse depletes but recovers
- full servers have competition without severe starvation
- active economy telemetry reflects changing warehouse state
- no carry/progression/map redesign was required

**STOP after M4.1 review. Do not begin M5 from this document.**
