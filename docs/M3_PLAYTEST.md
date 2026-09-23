# ONE TRIP — M3 SELL VS KEEP ECONOMY PLAYTEST

M3 is not approved until the Studio tests below are completed. The corrected Stock rule is permanent for this milestone:

> SELL = large immediate Cash.
>
> KEEP = occupies a Stock Slot indefinitely and generates slow passive Cash until deliberately sold.

There are no buyer timers and no automatic Stock sales.

## Setup

1. Pull `main`.
2. Restart `rojo serve` and reconnect Studio.
3. Start a fresh server/play session.
4. Default server Player attributes should be:
   - `StockSlotCapacity = 3`
   - `DevPassiveIncomeMultiplier = 1`
5. For accelerated passive-income testing, set `DevPassiveIncomeMultiplier` on the **server Player** to `60`. This makes one real minute of passive earnings arrive in roughly one test second while the HUD continues to show the base `+$X/min` rate.
6. To test expansion placeholders without changing code, set server `StockSlotCapacity` to `3`, `5`, `7`, or `10`.

## Expected player loop

Warehouse → Carry → Bay delivery → Delivery Review → SELL and/or KEEP → immediately return to carrying → kept Stock remains in the bay and generates passive income.

## TEST A — SELL

1. Deliver a haul with several known items.
2. Confirm Delivery Review appears and Cash has not increased merely because unload succeeded.
3. Press `SELL ALL — START NEXT RUN`.
4. Verify Cash increases by the configured M3 Sell Values exactly once.
5. Verify the review closes.
6. Spam/click the old button area or attempt stale actions if possible.
7. Verify no second payout occurs.
8. Start another warehouse run immediately.

Expected invariant: delivered entries are removed from authoritative Delivery Review before Cash is granted, so the same review item cannot pay twice.

## TEST B — KEEP

1. Deliver multiple items including a Safe.
2. Select Safe in Delivery Review.
3. Confirm the row shows approximately `SELL $1000 NOW` and `KEEP +$6/min`.
4. Press `KEEP SELECTED (1)`.
5. Verify Safe disappears from unresolved Delivery Review.
6. Verify one bay Stock Slot becomes occupied.
7. Verify a physical Safe remains in the bay indefinitely.
8. Verify the display has no GRAB prompt and cannot be taken.
9. Press `SELL REST` for the other delivered items.
10. Verify immediate Cash includes only the sold items.
11. Wait well beyond the former timed-sale duration and verify Safe does **not** auto-sell or disappear.

## TEST C — PASSIVE INCOME

For practical testing set `DevPassiveIncomeMultiplier = 60` on the server Player.

1. Keep a Box (`+$1/min`), TV (`+$4/min`), and Safe (`+$6/min`).
2. Confirm HUD says `PASSIVE INCOME +$11/min`.
3. At multiplier 60, expect about `$11` per real test second, allowing for Heartbeat/tick timing.
4. Verify Cash rises while all three objects remain physically present.
5. Verify no item disappears when Cash is credited.
6. Set multiplier back to `1` and verify the displayed base passive rate remains `+$11/min`.

Expected invariant: one centralized server calculation sums Stock rates. There is no independent loop per Stock item.

## TEST D — FULL STOCK

1. Use default `StockSlotCapacity = 3`.
2. Fill all three slots.
3. Deliver another item.
4. Select it for KEEP.
5. Verify KEEP is unavailable/rejected because Stock is full.
6. Verify SELL remains available.
7. Open `MANAGE STOCK` and verify all three kept items and their passive rates are visible.

The player must sell an old Stock item before keeping the new one. Capacity may never silently overflow.

## TEST E — REPLACE WEAKER STOCK

1. Fill all three slots with low/mid items.
2. Deliver a better passive item such as a Safe.
3. Open `MANAGE STOCK`.
4. Choose one weaker Stock row and press its sell action.
5. Verify the old physical display disappears.
6. Verify its passive contribution immediately leaves the total rate.
7. Verify its normal configured Sell Value is paid exactly once.
8. Return to Delivery Review.
9. KEEP the new Safe.
10. Verify the freed slot now shows Safe physically.
11. Verify Safe's passive rate is included in the new total.
12. Verify there is no duplicate model, duplicate passive contribution, or missing/extra Cash.

This explicit sell-first flow is the M3 replacement rule. Nothing valuable is silently deleted.

## TEST F — MULTIPLAYER

Use Studio multi-client testing if available.

For each player:

1. Confirm a unique bay.
2. Deliver and KEEP different items.
3. Look into other players' bays and verify their Stock objects are visible.
4. Attempt to grab another player's Stock object.
5. Verify it cannot be targeted, carried, collided with annoyingly, or stolen.
6. Accelerate passive income for several players.
7. Verify each player receives Cash only from their own Stock.
8. Verify no Stock display appears in the wrong bay.
9. Watch server/client output for errors and assess performance.

This cannot be certified from repository inspection alone; it requires Studio multi-client testing.

## TEST G — LONG SESSION

1. Keep several Stock items.
2. Leave the bay.
3. Complete multiple warehouse runs, including heavy Load Pressure/collapse scenarios.
4. Verify passive Cash continues in the background.
5. Verify passive updates do not interrupt grabbing, Carry, Sway, Load Pressure, ditching, or delivery review.
6. Verify kept Stock never auto-sells regardless of session length.

## TEST H — DISCONNECT

1. KEEP Stock items.
2. Disconnect the player.
3. Verify no server errors/leaks.
4. Verify temporary physical Stock displays are cleaned from the released bay.
5. Rejoin.
6. Verify M3 does **not** pretend Stock or offline income persisted.

M4 will add DataStore persistence and offline elapsed-time/cap handling. The M3 Stock record already stores item identity, slot, Stock ID, stocked timestamp, and passive rate so it can be serialized later.

## TEST I — DUPLICATION / REMOTE SPAM

Try aggressively:

- double-clicking SELL ALL
- rapidly pressing KEEP SELECTED
- sending KEEP and SELL actions close together
- repeating an old ReviewId after review closes
- attempting KEEP with more selected items than free slots
- repeatedly pressing SELL on the same stocked item
- unloading while an earlier Delivery Review remains unresolved
- disconnecting while passive Stock exists

Expected:

- one delivered entry transitions only once
- one Stock entry occupies one slot
- one Stock entry contributes passive income once
- selling Stock removes it before granting its sell payout
- stale Stock IDs cannot pay twice
- unresolved review prevents a second unload from destroying another carried haul
- invalid/stale ReviewIds do nothing
- client-supplied money/passive-rate data is never accepted

## Current prototype economics

All M3 economy tuning is centralized in `src/shared/Config/EconomyConfig.lua`.

- Box: SELL `$150` / KEEP `+$1/min`
- Microwave: SELL `$400` / KEEP `+$2/min`
- Lamp: SELL `$400` / KEEP `+$2/min`
- Chair: SELL `$550` / KEEP `+$3/min`
- Tire: SELL `$300` / KEEP `+$2/min`
- TV: SELL `$700` / KEEP `+$4/min`
- Couch: SELL `$1000` / KEEP `+$5/min`
- Safe: SELL `$1000` / KEEP `+$6/min`

At base rates, KEEP takes roughly 150–200 minutes to generate the equivalent of selling immediately. These are prototype values, not final balance.

## Feel questions

After mechanical tests pass, answer:

- Did SELL ALL feel fast enough to get back to carrying?
- Did a Safe create a real `$1000 now` vs `+$6/min` hesitation?
- When all three slots were full, did finding a stronger passive item make the weakest Stock feel replaceable?
- Did opening MANAGE STOCK feel quick rather than like homework?
- Did physical Stock in another bay catch your attention?
- Did passive income feel useful without making active warehouse runs pointless?
- Did you ever regret KEEP because you needed immediate Cash?

If KEEP is obviously always correct, reduce passive rates/increase sell values. If KEEP is never interesting, carefully increase passive opportunity. Do not add more systems to solve tuning yet.

## Known M3 technical debt to watch

The delivery bridge still captures server-created carry visual records immediately before `CarryService.Unload` clears authoritative carry state. The client cannot spoof those records, so the economy remains server-controlled, but this adapter is presentation-coupled. A future CarryService refactor should expose authoritative carried entries directly before persistence work becomes complex.

Do not begin M4 from this document. M3 requires project-lead review after Studio validation.
