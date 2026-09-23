# ONE TRIP — M3 DELIVERY ECONOMY PLAYTEST

M3 is not approved until the Studio tests below are completed. This document separates code-level invariants from feel/performance checks that require Roblox Studio.

## Setup

1. Pull `main`.
2. Restart `rojo serve` and reconnect Studio.
3. Start a fresh server/play session.
4. Default server Player attributes should be:
   - `StockSlotCapacity = 3`
   - `DevSaleSpeedMultiplier = 1`
5. For fast timer testing, set `DevSaleSpeedMultiplier` on the **server Player** to `10` or higher before creating new listings.
6. To test expansion placeholders without changing code, set server `StockSlotCapacity` to `3`, `5`, `7`, or `10`.

## Expected player loop

Warehouse → Carry → Bay delivery → Delivery Review → Quick Sell and/or Stock → immediately return to carrying → Stock listings sell independently later.

## TEST A — Quick Sell All

1. Deliver a haul with several known items.
2. Confirm the Delivery Review appears and Cash has not increased merely because the unload succeeded.
3. Press `QUICK SELL ALL — START NEXT RUN` once.
4. Verify Cash increases by the sum of each item's existing prototype Value.
5. Verify the review closes.
6. Spam/click the button again if possible.
7. Verify no second payout occurs.
8. Start another warehouse run immediately.

Expected code invariant: the server owns the current ReviewId and delivered entries; once sold, those entries are removed and the same ReviewId cannot pay again.

## TEST B — Stock One

1. Deliver multiple items including a Safe.
2. Select Safe in Delivery Review.
3. Confirm UI shows approximately `$100 NOW`, `~$155 STOCK`, and the buyer ETA.
4. Press `STOCK SELECTED (1)`.
5. Verify Safe disappears from the unresolved review list.
6. Verify one bay Stock Slot becomes occupied.
7. Verify a physical Safe appears in the bay.
8. Verify the display has no GRAB prompt and cannot be taken.
9. Press `QUICK SELL REST`.
10. Verify immediate Cash includes only the items that were Quick Sold.
11. Wait for the Safe buyer and verify the delayed payout arrives separately.

## TEST C — Fill Slots

1. Use default `StockSlotCapacity = 3`.
2. Deliver at least four items.
3. Stock three.
4. Confirm HUD reads `STOCK 3 / 3 • 0 FREE`.
5. Attempt to select/Stock another delivered item.
6. Verify Stock action is unavailable/rejected.
7. Verify Quick Sell still resolves the remaining item.

Repeat later by setting the server Player attribute to 5, 7, and 10. Verify the matching graybox slot markers become active without a code edit.

## TEST D — Sale Completion

For quick testing set `DevSaleSpeedMultiplier = 10` on the server Player before listing.

1. Stock a known item.
2. Leave it alone until its timer finishes.
3. Verify exactly one payout.
4. Verify occupied count decreases by one.
5. Verify the physical display disappears.
6. Verify its Stock Slot reads FREE again.
7. Verify a lightweight `ITEM SOLD! +$...` notice appears.
8. Wait longer and verify no repeated payout.

## TEST E — Stock While Playing

1. Stock one item.
2. Leave the bay immediately.
3. Grab/carry another warehouse haul.
4. Let the first listing complete while moving/carrying.
5. Verify Cash and Stock HUD update without interrupting the carry system.
6. Verify the carrying pile, Sway, Load Pressure, and collapse behavior are unaffected.

## TEST F — Multiple Simultaneous Listings

1. Stock three different items such as Box, TV, and Safe.
2. Confirm all three have independent physical displays.
3. Their configured durations should differ.
4. Verify each completes independently.
5. Verify each slot frees independently.
6. Verify total Cash equals the three authoritative expected payouts exactly once each.

## TEST G — Multiplayer / 12 Players

Use Studio multi-client testing if available.

For each player:

1. Confirm a unique bay.
2. Deliver items.
3. Stock at least one item.
4. Look into another player's bay and verify their Stock object is visible.
5. Attempt to grab another player's Stock object.
6. Verify it cannot be targeted, carried, or stolen.
7. Let listings complete for several players simultaneously.
8. Verify each player receives only their own payout.
9. Verify no Stock display appears in the wrong bay.
10. Watch server/client output for errors and assess performance.

This cannot be certified from repository inspection alone; it requires Studio multi-client testing.

## TEST H — Disconnect

1. Create active Stock listings.
2. Disconnect the player before the buyer timer completes.
3. Verify no server errors/leaks.
4. Verify the player's temporary Stock displays are cleaned from the released bay.
5. Rejoin.
6. Verify M3 does **not** pretend the old listings survived or sold offline.

M4 will replace this temporary-session behavior with persistence/offline elapsed-time handling.

## TEST I — Duplication / Remote Spam

Try aggressively:

- double-clicking Quick Sell All
- rapidly pressing Stock Selected
- sending Stock Selected and Quick Sell Rest close together
- repeating an old review action after the review closes
- attempting to Stock more items than free slots
- unloading while an earlier Delivery Review is unresolved
- disconnecting during an active listing

Expected:

- one delivered entry transitions only once
- one listing occupies one slot
- one listing pays once
- unresolved review prevents a second unload from destroying another carried haul
- invalid/stale ReviewIds do nothing
- client-supplied money/timer/value data is never accepted

## Current prototype economics

Quick Sell starts from existing `ItemConfig.Value`.

Current Stock examples at normal speed:

- Box: $15 now / ~$20 Stock / ~20s
- Microwave: $40 now / ~$55 Stock / ~30s
- Lamp: $40 now / ~$59 Stock / ~38s
- Chair: $55 now / ~$74 Stock / ~42s
- Tire: $30 now / ~$45 Stock / ~32s
- TV: $70 now / ~$102 Stock / ~50s
- Couch: $100 now / ~$140 Stock / ~65s
- Safe: $100 now / ~$155 Stock / ~75s

These values are deliberately prototype tuning, not final economy balance.

## Feel questions

After mechanical tests pass, answer:

- Did Quick Sell All feel fast enough to get back to carrying?
- Did you ever choose immediate Cash even though Stock paid more?
- Did limited slots make a valuable object feel worth thinking about?
- Did you care when a slot became free?
- Did physical Stock in another bay catch your attention?
- Did you ever stand around waiting instead of playing another run?

If Stock is always obviously correct, adjust per-item premium/duration later. If Stock is never attractive, increase opportunity value. Do not add more systems to solve tuning.

## Known M3 technical debt to watch

The delivery bridge currently captures the server-created carry visual records immediately before `CarryService.Unload` clears authoritative carry state. The client cannot spoof those records, so the economy remains server-controlled, but this adapter is presentation-coupled. A future CarryService refactor should expose authoritative carried entries directly before persistence work becomes complex.

Do not begin M4 from this document. M3 requires project-lead review after Studio validation.
