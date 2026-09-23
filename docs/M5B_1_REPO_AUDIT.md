# ONE TRIP — M5B.1 Repository Audit

Audit scope: full current `src/` tree, with emphasis on architecture, server authority, exploit surfaces, balance assumptions, persistence, mobile parity, performance, and consistency with the current ONE TRIP design.

This document is intentionally not a gameplay redesign. Items marked **TEST FIRST** should not be balance-patched until the current M5B.1 runtime playtest produces evidence.

## Overall assessment

The codebase is in good shape for the speed at which the prototype evolved. Important strengths:

- core gameplay authority is server-side
- grab distance / availability is validated on the server
- economy actions and upgrade purchases are server-priced and validated
- persistence uses `UpdateAsync`, session ownership, retries, autosave, PlayerRemoving, and BindToClose
- carrying uses authoritative state rather than client physics
- Base Instability, Current Sway, and Load Pressure remain separate
- M5 rarity is server-selected
- the long warehouse is config-driven
- item/economy/handling tuning is mostly centralized
- player-player collision is disabled as intended
- the natural handling-gate direction is implemented without hard-locking normal warehouse sections

There is no reason to rewrite the project. The main risk is prototype compatibility layers accumulating beside M5 systems and making future balancing harder to reason about.

---

# FIXED DURING THIS AUDIT

## 1. Mobile DITCH parity

**Status: FIXED**

`InteractionController` previously created a touch button for GRAB but not for the manual ditch/emergency-sacrifice action.

That made an approved core risk mechanic unavailable to touch players.

The Drop action now creates a touch button titled `DITCH` with a separate position from GRAB.

## 2. Stale milestone wording

**Status: FIXED**

`ProgressionController` displayed `MAXED FOR M4` even though the project is now M5B.1.

It now displays simply `MAXED`.

---

# P0 — MUST RESOLVE / VALIDATE BEFORE M5B.1 APPROVAL

## 3. Grip-failure shielding exploit

**Status: OPEN — FIX BEFORE APPROVING M5B.1**

`HandlingRuntimeService` correctly identifies the worst handling item in the current pile, but `CarryService.ForceGripLoss()` currently removes the top carried item rather than the item responsible for the unmanageable load.

Potential sequence break:

1. player grabs a valuable cargo item that is UNMANAGEABLE
2. player stacks cheap items above it
3. grip failure burns the cheap top item
4. the valuable underqualified cargo survives
5. repeated sacrificial junk can extend the time the player has to move the valuable cargo

This undermines the design rule:

> The warehouse is open; the loot is the gate.

Recommended correction:

- runtime evaluation should retain the carried index of the actual worst item
- grip failure should remove that offending item and, if necessary for stack integrity, any items physically above it
- do not merely reset the timer and remove arbitrary top junk

Required exploit test after the fix:

- starter grabs an UNMANAGEABLE Secure/Industrial item
- starter deliberately adds cheap cargo above it
- confirm the underqualified target cannot be protected by sacrificial junk

## 4. M5B.1 handling runtime still depends on visual-rig parsing

**Status: OPEN — ARCHITECTURE CLEANUP HIGH PRIORITY**

Both handling and economy reconstruct carried inventory by scanning server-created carry visuals and parsing names like:

`Carry_<ItemId>_<Index>`

This is not currently a client exploit because the server creates/owns those visuals, but it makes presentation objects part of authoritative gameplay state.

Recommended correction:

Expose a read-only method from `CarryService`, e.g.:

- `GetCarriedItemIds(player)`
- optionally `GetCarrySnapshot(player)`

Then:

- `HandlingRuntimeService` reads CarryService state directly
- `EconomyService.CaptureCarriedItems` reads CarryService state directly
- visual object names become presentation only

This should be done before final release architecture freezes.

---

# P1 — TEST FIRST, THEN BALANCE

## 5. Possible progression compression

**Status: TEST FIRST — DO NOT SILENTLY RETUNE YET**

Current marginal cost to raise Strength + Carry Space + Control into each approximate rig milestone is roughly:

- Starter → Rig I: ~$1.75K
- Rig I → Rig II: ~$4.1K
- Rig II → Rig III: ~$9.4K
- Rig III → Rig IV: ~$21.5K
- Rig IV → Rig V: ~$50K

Cumulative handling investment through Rig V is roughly ~$86.75K, before Mobility / Stock Slot spending.

M5 section economic scales rise aggressively:

- Receiving: 1.0x
- Appliances: 2.2x
- Furniture: 4.8x
- Heavy Goods: 10x
- Industrial: 21x
- Secure: 45x

This may be correct, or it may allow each newly viable section to finance the next Rig milestone too quickly.

Do NOT change costs before runtime testing.

Required playtest metrics:

- fresh-profile time to Rig I / II / III / IV / V
- number of successful runs between Rig milestones
- whether one lucky Rare+ item skips an entire progression band
- whether Stock Slot / Mobility purchases remain competitive choices versus rushing handling stats

Desired feeling:

- early progression fast
- first few capability unlocks exciting
- later Rig advancement increasingly meaningful
- upgrades unlock new practical cargo opportunities rather than becoming a trivial tax

## 6. M4.2 passive break-even is intentionally short at the low end

**Status: ACCEPTED FOR CURRENT TEST — RUNTIME VALIDATION REQUIRED**

Do not treat the current low-end ~3–5 minute break-even as an accidental M5 regression.

M4.2 explicitly accepted shorter early break-even to make ordinary KEEP choices noticeable against the measured active SELL economy.

Test whether KEEP becomes automatic in actual M5 gameplay.

Only retune if players stop seriously considering SELL.

---

# P1 — SUPPLY / RARITY ARCHITECTURE

## 7. Two-stage M4 supply → M5 loot transform

**Status: WORKS, BUT SHOULD BE UNIFIED BEFORE RELEASE**

Current pipeline:

1. `ItemService` selects/spawns a legacy/prototype item from authored marker pools
2. `LootRarityService` transforms that part into the final M5 section-specific base item + rarity

This preserved M4.1 supply behavior while M5 was being built, but it creates two sources of loot logic.

Important nuance:

- vacancy delay after pickup uses the final transformed ItemId, which is good
- some refill/value-band selection decisions still originate from the provisional legacy item pool

As M5 values diverge further, this becomes harder to balance confidently.

Recommended pre-release architecture:

A single supply generation step should choose:

- section
- authored vacancy
- final base item
- rarity
- hero eligibility
- final economy value

before the world item is created.

Do not rewrite this during M5B.1 playtesting unless it causes actual failures. Schedule the unification before release/M6 architecture freeze.

## 8. `PremiumSupplyService.lua` is dead legacy code

**Status: DEAD CODE — CLEAN BEFORE RELEASE**

The service contains the older M4.2 TV/Couch/Safe premium-cap logic.

`Main.server.lua` does not require/start it and code search found no active references.

It currently does not affect gameplay.

Recommended action:

- remove it once M5 supply architecture is confirmed
- or move historical logic into docs/git history instead of keeping a misleading unused live service

---

# P1 — DELIVERY / PERSISTENCE RELIABILITY

## 9. Unresolved Delivery Review exists only in server memory

**Status: OPEN — IMPORTANT BEFORE PUBLIC RELEASE**

After a successful unload, the haul enters a SELL/KEEP Delivery Review in `EconomyService`.

That review is not currently persisted as part of the player profile.

If a player disconnects/crashes after unloading but before resolving SELL/KEEP, the delivered haul can disappear.

This is not an exploit in the player's favor, but it can feel like lost progress.

Recommended solution before release:

Either:

- persist pending delivered items/review state safely

or:

- apply a deterministic safe fallback on disconnect/server shutdown (for example SELL unresolved items server-side)

Do not allow a successful delivery to vanish because the UI was unresolved.

## 10. Stock values are saved as snapshots

**Status: DESIGN DECISION REQUIRED BEFORE LIVE BALANCE PATCHES**

Saved Stock records include:

- PassiveRatePerMinute
- OriginalSellValue
- SalvageValue

This means existing Stock can retain old balance values after a future economy update unless migration/recalculation is performed.

Before live release choose a policy:

### Option A — snapshot forever
Old items preserve historical rates.

Pros: item history feels stable.
Cons: balance changes create legacy overpowered/underpowered Stock.

### Option B — recalculate from current ItemConfig/EconomyConfig on load

Pros: live balance stays consistent.
Cons: player-owned Stock can change value after updates.

### Option C — explicit economy version + migration

Best long-term control, more complexity.

Do not leave this accidental.

---

# P2 — UI / MOBILE / PERFORMANCE

## 11. Manage Stock panel is less responsive than other major menus

`EconomyController` has a fixed-size `ManageStock` frame while other primary panels use scale/constraints.

Test small phone viewports.

If clipping occurs, convert it to responsive scale + UISizeConstraint before launch.

## 12. Handling preview can become stale when the pile changes but the nearest object does not

`HandlingController` requests a preview when the nearest candidate changes or progression attributes change.

A pile collapse/ditch can change whether the same nearby candidate is READY/RISKY/DANGEROUS while the candidate itself remains the same.

Potential solutions:

- request preview after meaningful CarryState item-count changes
- or periodically refresh the current candidate at a low rate

Not a security issue.

## 13. Camera protection scans carry descendants every RenderStepped

Fine at prototype scale.

As M6 adds detailed multi-part models and carried piles approach the technical cap, this can become a mobile hotspot.

Optimize later using:

- cached carried visual parts
- add/remove listeners
- avoid `GetDescendants()` every rendered frame

## 14. Economy telemetry is always active

`EconomyTelemetryController` currently runs for every client and prints M4 testing output.

Keep it during current balancing.

Before public release:

- gate it to Studio/dev mode
- or replace it with proper analytics/custom events

## 15. Prototype-facing strings remain

Examples include:

- `TEST SCORE`
- M4/M5 debug print prefixes
- prototype names

Fine during active development.

Clean them before release UI freeze.

---

# P2 — CONFIG / MAINTAINABILITY

## 16. Future expansion boundary coordinate is hard-coded

`WarehouseAccessService` places the current back boundary at a literal world coordinate instead of reading a dedicated value from `WarehouseConfig`.

Not a gameplay issue now.

Move it into warehouse configuration before future section expansion to avoid map/config drift.

## 17. Legacy `CarryRigTier` remains beside live `HandlingRigTier`

The profile still carries older rig-tier state while live handling progression derives `HandlingRigTier` from Strength/CarrySpace/Control.

Do not let future systems accidentally use the legacy field as the gate.

Clean/migrate after M5B.1 is proven.

## 18. Number formatting currently stops at T

Fine for current M5 numbers.

If the final economy intentionally goes well beyond trillions, add suffixes before launch so values do not become `1000T`, `1000000T`, etc.

---

# SYSTEMS THAT PASSED THIS AUDIT WELL

## Server authority

Strong overall.

- grab requests validated server-side
- server checks actual distance
- supply state authoritative
- rarity generated server-side
- economy choices validated by review IDs
- Stock IDs validated on liquidation
- upgrade prices/costs server-defined
- persistence server-owned
- client UI is not trusted for payout/stat values

## Data safety

Strong for current development stage.

- `UpdateAsync`
- session ownership
- retries/backoff
- numeric sanitization
- schema version guard
- duplicate-load protection
- autosave
- PlayerRemoving save/release
- BindToClose
- offline-time cap and server timestamp handling

## Carry system

Core architecture remains strong.

- authoritative item list
- controlled stack visuals
- Weight/Bulk/Shape inputs
- movement-based sway
- Base Instability separated from Sway
- Load Pressure separated from immediate collapse risk
- loaded Mobility suppression
- partial collapse
- manual sacrifice
- tutorial warning disables after successful first delivery

## M5 natural handling progression

Design implementation is directionally correct.

- open warehouse
- item capability is the progression gate
- Rig is only a readable summary
- actual stats still matter
- sections have distinct handling targets
- rarity does not multiply Weight/Bulk
- starter Secure cargo is intentionally difficult because of physical transport forms

Still requires real playtesting.

## Rarity presentation

Appropriate for M5 first-pass production.

- escalating visual language
- rare highlights
- Legendary+ lights
- Mythic+ controlled particles
- Cosmic/Eternal silhouette accents
- audio cue
- low particle rates

Final art remains M6 work.

---

# M5B.1 PLAYTEST GATES AFTER THIS AUDIT

Before continuing to M5C, explicitly test:

1. Starter attempts representative cargo in every section.
2. Starter runs directly to Secure and tries the best value/handling-efficiency object.
3. UNMANAGEABLE stop/start cheese.
4. UNMANAGEABLE cheap-junk shielding after the grip-failure fix.
5. One-section-ahead sequence breaking.
6. Strength specialist vs Space specialist vs Control specialist.
7. Time/runs to Rig I / II / III / IV / V.
8. Whether upgrade prices feel trivial once a new section becomes viable.
9. Whether one lucky rarity skips too much progression.
10. Whether Mobility creates a single deterministic farm circuit.
11. SELL vs KEEP with M5 values.
12. 12-player supply depletion / rarity competition.
13. Small-phone UI including GRAB + DITCH + handling preview.
14. Large-pile client performance.

# Current recommendation

Do not start M5C yet.

First:

- fix the grip-failure shielding exploit
- run the actual M5B.1 playtest
- use that data to decide whether progression costs/handling bands need balance changes

Avoid preemptive economy/stat retuning until those tests are complete.
