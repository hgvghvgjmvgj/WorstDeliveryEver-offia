# ONE TRIP — M4 PERSISTENCE + PROGRESSION PLAYTEST

M4 is **not approved** until the runtime tests in this document are completed. Repository inspection can verify architecture/invariants, but it cannot certify Roblox DataStore behavior, feel, or 12-client performance.

## Persistence test setup

For real persistence tests, use a published test place / experience with Studio API Services enabled. On the **server Player**, verify:

- `ProfileLoaded = true`
- `PersistenceStatus = PERSISTENT`
- `DataSchemaVersion = 1`

If API access is unavailable in Studio, M4 deliberately falls back to a temporary profile and sets `PersistenceStatus` to `TEMPORARY_STUDIO:...`. That mode is safe for gameplay testing but **does not count as a persistence pass**.

Current DataStore: `OneTripPlayerData_v1`.

## Default profile

A fresh persistent player should begin with:

- Cash: `$0`
- Strength Level 1 → 15
- Carry Space Level 1 → 13
- Control Level 1 → 1.00
- Mobility Level 1 → WalkSpeed 16
- Stock Slot Level 1 → 3 slots
- Carry Rig Tier 1 placeholder
- no kept Stock
- schema version 1

## TEST A — Fresh profile / first upgrade

1. Join on a clean profile.
2. Verify the defaults above.
3. Complete a basic run and SELL a Box (`$600` current test value).
4. Open **UPGRADES**.
5. Buy either Strength 1→2 for `$500` or Carry Space 1→2 for `$450`.
6. Verify Cash is deducted once.
7. Spam/double-click the purchase button.
8. Verify each accepted purchase advances exactly one level and charges the configured next-level cost exactly once.
9. Rejoin and verify the level and remaining Cash persist.

## TEST B — Carry progression

Compare the same load before/after several upgrades:

- Strength should reduce Weight pressure.
- Carry Space should reduce Bulk pressure.
- Control should reduce Base Instability / improve the practical stability frontier.
- None should remove Sway, Load Pressure, or collapse.

Use F3 telemetry where helpful. The stronger player should be able to attempt a more ridiculous load, not become immune to failure.

## TEST C — Mobility suppression

1. Record unloaded travel time over a fixed route at Mobility Level 1 (WalkSpeed 16).
2. Upgrade Mobility.
3. Verify unloaded/light travel is clearly faster.
4. Build a dangerously heavy load and repeat the return.
5. Verify most of the Mobility bonus is suppressed under heavy Weight.
6. Verify late Mobility does not let an absurd load sprint home at the full unloaded speed.

Current M4 maximum test Mobility is WalkSpeed 25 unloaded. High Weight ratios suppress most of the +9 bonus.

## TEST D — Stock Slot progression

Current capacity path:

`3 → 4 → 5 → 6 → 8 → 10`

1. Fill the starting 3 slots.
2. Buy Stock Slots Level 2 for `$5K`.
3. Verify capacity changes to 4.
4. Verify Stock Slot 4 becomes physically available in the bay.
5. KEEP a fourth item.
6. Rejoin and verify all four Stock items restore once in the correct physical slots.
7. Continue through later levels when testing higher Cash.

Stock Slot upgrades are intentionally more expensive than the first small carry upgrades.

## TEST E — Cash persistence

1. SELL known delivered items.
2. Record Cash.
3. Leave normally.
4. Rejoin.
5. Verify exact Cash restoration, excluding any legitimate offline passive earnings.
6. Purchase an upgrade, leave immediately, rejoin, and verify the purchase persists.

## TEST F — Stock persistence / no duplication

1. KEEP three known items.
2. Record their slot indexes and passive rates.
3. Rejoin.
4. Verify exactly three authoritative Stock entries restore.
5. Verify exactly three physical Stock displays restore in the same owner bay.
6. Verify no Stock object enters shared warehouse `Items`.
7. Verify nobody can grab/steal the displays.
8. Liquidate one Stock item, leave, rejoin.
9. Verify the liquidated item does **not** return.
10. Replace a weak item with a stronger delivered item, rejoin, and verify only the new Stock remains.

## TEST G — Autosave / shutdown / rapid rejoin

1. Make a progression change and remain in-server past the 60s autosave interval.
2. Verify no errors.
3. Leave and rejoin rapidly.
4. Verify no duplicate profile load or duplicate offline payout.
5. Test a controlled server shutdown if possible.
6. Verify Cash, upgrades, and Stock restore.
7. Watch output for save retry/session-lock warnings.

M4 uses an UpdateAsync session claim, a 180s stale-lock timeout, autosave, PlayerRemoving release, and BindToClose saving.

## TEST H — Schema/default repair

This test requires controlled development data manipulation.

1. Create a profile missing one progression field.
2. Load it.
3. Verify the missing field receives the Level 1 default while valid existing fields survive.
4. Supply an invalid Stock ItemId and verify it is discarded safely.
5. Supply an out-of-range level and verify it is clamped.
6. Verify `SchemaVersion` is normalized to 1.
7. A profile with a future/newer schema version should be refused rather than silently overwritten.

## TEST I — Offline earnings: short absence

1. KEEP Stock and record total passive rate and Cash.
2. Leave through a real persistence-enabled server.
3. Stay offline long enough to produce an obvious amount.
4. Rejoin.
5. Verify `WHILE YOU WERE AWAY` appears once.
6. Verify Cash increased by approximately:

`TotalPassiveRate / 60 × trusted elapsed seconds`

plus any saved fractional remainder.
7. Reconnect again immediately and verify the same absence is **not** paid twice.

The client clock must have no effect.

## TEST J — Offline cap

Current temporary cap: **2 hours**.

Using controlled test data / sufficient elapsed time:

1. Test an absence longer than two hours.
2. Verify only two hours are credited.
3. Test zero elapsed time → zero offline payout.
4. Test a LastSeen timestamp in the future → zero offline payout.
5. Test an absurd/stale elapsed time beyond the trusted window → zero payout rather than an enormous grant.

The two-hour value is M4 tuning, not final live balance.

## TEST K — SELL / KEEP / liquidation still correct

1. Deliver a Safe.
2. Verify current Delivery Review shows roughly `$30K` SELL vs `+$1.2K/min` KEEP.
3. SELL once → one immediate payout, no Stock.
4. KEEP another Safe → physical Stock, passive income, no immediate `$30K`.
5. Liquidate the kept Safe later → current 20% salvage (`$6K`), not original `$30K`.
6. Rejoin after each path and verify no double-dip / restored sold item.

## TEST L — Loot density: solo

M4 has **64 authored positions**, 16 in each sector. At one player, the target is **12 active per sector = 48 active objects**.

1. Start a one-player server.
2. Inspect `Workspace > OneTripPrototype > Items`.
3. Expect approximately 48 available items after initialization.
4. Walk General, Appliances, Furniture, Industrial.
5. Judge whether meaningful visible opportunities occur roughly every 3–6 seconds while actively searching.
6. Verify objects are distributed through racks/staging/cages rather than tiny clusters.
7. Verify the warehouse does not look visually flooded.

## TEST M — Loot density: scaling / 12 players

Current target scales approximately:

- 1 player: 12/sector → 48 total
- intermediate populations: between 12 and 16/sector
- 12 players: 16/sector → 64 total

Use Studio multi-client testing:

1. Increase player count.
2. Verify additional authored points populate rather than random open-floor items appearing.
3. At 12 players, verify up to all 64 points are active.
4. Watch for starvation in popular sectors.
5. Watch for clutter / rendering cost.
6. When player count falls, already-visible extra items may remain until taken; their disabled source points should then stop restocking.

## TEST N — Active vs passive progression

Compare similar play time:

**Player A:** owns Stock but mostly waits.

**Player B:** owns comparable Stock and continuously completes warehouse runs / improves Stock / buys upgrades.

Player B should materially outperform Player A. If passive Stock alone makes active running feel unnecessary, M4 balance fails even if calculations are correct.

## TEST O — Fresh profile progression feel

Play naturally from `$0` rather than granting test Cash.

### First 5 minutes
Record:
- time to first SELL
- first upgrade
- first KEEP
- number of obvious Stock improvements/replacements
- whether the next goal is understandable

### 10 minutes
Record:
- upgrade levels
- Cash
- total passive rate
- Stock composition
- whether progression still feels frequent

### 20 minutes
Record the same. Progression should now be more deliberate than minute 1–5, not equally explosive forever.

Current pricing is a playtest curve, not final balance.

## TEST P — Large-number handling

Using controlled server-side development data, test:

- thousands
- millions
- billions

Verify Cash, passive-rate labels and upgrade costs remain readable (`K/M/B/T`) and calculations do not overflow normal game use. M4 intentionally does not add an infinite-number library.

## TEST Q — Security / abuse

Attempt:

- client-spoofed upgrade level/value/cost
- repeated purchase remote spam
- old Stock IDs after liquidation
- old Review IDs after resolution
- keep beyond Stock capacity
- duplicate rapid reconnect for offline payout
- simultaneous save + disconnect
- two servers trying to own the same persistent profile

Expected: server owns all authoritative values; stale/invalid requests do nothing; active session lock prevents two live owners; final save waits for an in-flight autosave before release.

## Runtime approval questions

M4 should not be approved until these feel true:

- Early progression produces multiple satisfying decisions/upgrades quickly.
- Mobility improves exploration but not overloaded escape.
- Strength/Space/Control enable bigger risks without deleting risk.
- A new Stock Slot feels valuable.
- Returning to offline earnings feels rewarding but capped.
- Active warehouse play clearly beats passive-only waiting.
- The V2 warehouse feels populated, not cluttered.
- 12-player servers retain enough loot and acceptable performance.

**Do not begin M5 from this document. Project-lead review is required.**
