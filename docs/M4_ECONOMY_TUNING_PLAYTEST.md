# ONE TRIP — M4 ECONOMY TUNING PATCH PLAYTEST

This is a targeted M4 balance correction. M5 is not started.

## Goal

Make permanent Stock economically relevant enough to test while preserving active warehouse runs as the strongest progression driver.

Diagnostic target for a well-filled early Stock setup:

**approximately 20–30% of comparable active earning power.**

This is temporary M4 tuning. M5 section baseline power + rarity will replace the current compressed prototype hierarchy.

## Current tuning

| Item | Old KEEP | New KEEP | Old SELL | New SELL | New break-even |
| --- | ---: | ---: | ---: | ---: | ---: |
| Box | +$50/min | +$150/min | $600 | $900 | 6 min |
| Lamp | +$90/min | +$240/min | $1.35K | $1.68K | 7 min |
| Microwave | +$120/min | +$320/min | $1.8K | $2.24K | 7 min |
| Tire | +$180/min | +$450/min | $3.24K | $3.6K | 8 min |
| Chair | +$220/min | +$600/min | $3.96K | $4.8K | 8 min |
| TV | +$500/min | +$900/min | $10K | $9K | 10 min |
| Couch | +$850/min | +$1.4K/min | $18.7K | $16.8K | 12 min |
| Safe | +$1.2K/min | +$2K/min | $30K | $24K | 12 min |

SELL remains derived from `PassivePerMinute × TargetBreakEvenMinutes`.

The current 20% Stock liquidation/salvage rule is unchanged.

## Important persistence note

Existing saved Stock keeps the economic metadata it had when it was originally KEPT. This patch does not silently rewrite already-owned persistent Stock.

For clean tuning tests:

- use a fresh profile, or
- liquidate old test Stock and KEEP new copies after pulling this patch.

## Active-income telemetry

`EconomyTelemetryController` measures a practical test trip from first GRAB until its Delivery Review is resolved.

For clean active-income samples, resolve the Delivery Review with **SELL ALL**.

After each measured trip, Client Output prints:

`[ONE TRIP][M4 ECON TEST] ...`

The LocalPlayer also receives client-side development attributes:

- `DevLastTripSeconds`
- `DevLastTripItems`
- `DevLastTripSellPotential`
- `DevLastTripPotentialCashPerMinute`
- `DevLastTripCashDelta`
- `DevLastTripAdjustedCashPerMinute`
- `DevCurrentPassiveRate`

These are diagnostics only. They are not authoritative gameplay state and are not saved.

## TEST A — Fresh / very-low-level active income

Use a fresh profile with no purchased Carry upgrades.

Run at least 5 complete cycles:

`warehouse → GRAB → return → SELL ALL → immediately start next run`

Record each `[M4 ECON TEST]` line.

Calculate/record:

- average item count
- average SELL value per trip
- average trip seconds
- average potential active $/min
- average adjusted Cash-delta $/min

Use normal play rather than deliberately optimizing one special route.

## TEST B — 1–3 early Carry upgrades

Buy approximately 1–3 early Strength / Carry Space / Control upgrades.

Repeat at least 5 full SELL ALL trips.

Record the same metrics.

Specifically attempt the practical approximately 10-object Entry haul reported during playtesting.

Record:

- actual item count
- actual SELL payout
- elapsed trip time
- active $/min
- whether the load felt easy / moderate / greedy

Do not nerf carry behavior during this test.

## TEST C — Conservative active player

Use safe loads that rarely approach Critical Load Pressure.

Repeat 5 cycles and calculate average active $/min.

This is the comparison target for a risk-averse early player.

## TEST D — Greedy / efficient active player

Use the largest practical repeatable load you can regularly deliver without intentionally forcing collapses.

Repeat 5 cycles and calculate average active $/min.

This establishes the realistic high end of early active earning power.

## TEST E — Passive relevance

Build three plausible early Stock sets rather than only testing three Safes.

Suggested samples:

1. weak: Box + Lamp + Microwave = **+$710/min**
2. developed early: Microwave + Tire + Chair = **+$1.37K/min**
3. strong current prototype: Chair + TV + Safe = **+$3.5K/min**

For each set, compare total passive $/min against the matching active profile from Tests A–D.

Formula:

`Passive percentage = Stock $/min ÷ active $/min × 100`

Diagnostic target for a well-filled comparable early Stock setup:

**~20–30%.**

Weak Stock may sit below that range. Strong Stock may temporarily exceed it if the player has sacrificed meaningfully better SELL opportunities.

## TEST F — SELL vs KEEP

Deliver each of the following separately:

- Box
- Chair
- TV
- Safe

For each item ask both:

1. Does SELL meaningfully move me toward a current upgrade?
2. Does KEEP meaningfully improve my Stock?

Current decision examples:

- Box: $900 now vs +$150/min
- Chair: $4.8K now vs +$600/min
- TV: $9K now vs +$900/min
- Safe: $24K now vs +$2K/min

FAIL if KEEP is obviously useless.

FAIL if KEEP is automatically correct every time.

## TEST G — Stock replacement

Fill all 3 slots.

Deliver an item moderately better than the weakest current Stock.

Verify the decision is understandable:

- liquidate weak Stock for existing salvage value and KEEP the new item, or
- SELL the new item for immediate upgrade Cash.

Do not increase Stock capacity for this test.

## TEST H — Active still wins

Compare two equivalent accounts/setups over the same real time window:

### Passive-only

Owns Stock and performs no warehouse runs.

### Active + same Stock

Owns identical Stock and repeatedly completes warehouse runs.

The active player should progress materially faster.

## TEST I — Large-number readability

Verify current UI remains readable at:

- 1.2K
- 15.4K
- 2.8M
- 1.1B

No raw giant integer walls should appear in normal economy UI.

## Known temporary balance risk

The M4 offline cap is still 2 hours. Higher passive rates make offline returns stronger than before. Do not change persistence architecture in this patch; record whether the 2-hour payout feels excessive and feed that result into the next balance pass.

Example current upper prototype Stock:

`3 Safes = +$6K/min`

At the 2-hour cap that can theoretically produce `$720K` while away. That may be too generous relative to the finite M4 upgrade tree, but it should be evaluated after active-income measurements rather than changed blindly.

## Pass condition

This patch passes when:

- Stock is visibly useful during early play,
- a full comparable early Stock setup is roughly in the diagnostic 20–30% active-income neighborhood,
- active running still clearly wins,
- SELL vs KEEP is a legitimate tradeoff,
- the approximately 10-object Entry haul has real measured $/min data,
- no carry/progression/map systems were nerfed to protect passive income.

**Do not begin M5.**
