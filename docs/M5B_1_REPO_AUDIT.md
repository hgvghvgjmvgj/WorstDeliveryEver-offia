# ONE TRIP — M5B.1 Repository Audit

Audit scope: full current `src/` tree, emphasizing architecture, server authority, exploits, balance assumptions, persistence, mobile parity, performance, and consistency with the current ONE TRIP design.

## Overall assessment

The codebase is in good shape for how quickly the prototype evolved. There is no reason to rewrite it. Core authority is server-side, persistence is careful, carry physics are controlled, rarity is server-selected, and most tuning is centralized. The main risk is now prototype compatibility layers accumulating beside M5 systems and making future balancing harder to reason about.

## Fixed during this audit

### Mobile DITCH parity — FIXED
`InteractionController` previously created a touch GRAB button but no ditch/emergency-sacrifice touch control. Touch players now receive a dedicated `DITCH` action.

### Stale milestone wording — FIXED
`ProgressionController` no longer displays `MAXED FOR M4`; it displays `MAXED`.

### UNMANAGEABLE junk-shield exploit — FIXED
Previously, a player could potentially grab an UNMANAGEABLE valuable object, add cheap cargo above it, and make grip failure remove cheap top items first. The handling runtime now preserves the original UNMANAGEABLE grip-failure timer and immediately strips newly-added top cargo instead of letting it act as disposable armor.

Required runtime test: starter grabs an UNMANAGEABLE Industrial/Secure object, deliberately adds cheap cargo above it, and confirms the junk cannot extend the original object's survival window.

---

# Architecture issues to clean before release

## Handling/economy reconstruct carried state from carry visuals
`HandlingRuntimeService` and `EconomyService.CaptureCarriedItems` scan server-created carry visuals and parse names such as `Carry_<ItemId>_<Index>`.

This is not currently a client exploit because the server owns those visuals, but presentation objects should not be an authoritative gameplay dependency.

Recommended correction before architecture freeze:
- expose `CarryService.GetCarriedItemIds(player)` and/or a read-only carry snapshot
- use it in HandlingRuntimeService
- use it in EconomyService delivery capture
- make visual part names presentation-only

## Two-stage M4 supply → M5 rarity transform
Current pipeline:
1. `ItemService` chooses/spawns a legacy/prototype item from marker pools
2. `LootRarityService` transforms it into the final M5 section-specific base item + rarity

Pickup vacancy delay sees the final transformed ItemId, which is good, but some refill/value-band decisions still originate from the provisional M4 item layer. As M5 values diverge, this becomes harder to balance.

Recommended pre-release pipeline: one server supply generation step chooses section, authored vacancy, final base item, rarity, hero eligibility, and final economy value before creating the world item.

Do not rewrite this in the middle of M5B.1 unless testing exposes an actual failure.

## `PremiumSupplyService.lua` is dead legacy code
`Main.server.lua` does not start it and no active imports were found. Remove it once the M5 supply architecture is confirmed rather than leaving the old M4 premium-cap system beside the live pipeline.

---

# Test-first balance risks

## Possible progression compression
Do not silently retune yet.

Approximate marginal Strength + Carry Space + Control investment to each Rig milestone:
- Starter → Rig I: ~$1.75K
- Rig I → Rig II: ~$4.1K
- Rig II → Rig III: ~$9.4K
- Rig III → Rig IV: ~$21.5K
- Rig IV → Rig V: ~$50K

Current section economic scales:
- Receiving: 1.0x
- Appliances: 2.2x
- Furniture: 4.8x
- Heavy Goods: 10x
- Industrial: 21x
- Secure: 45x

Risk: each newly viable section may finance the next Rig milestone too quickly.

Measure fresh-profile time to each Rig, successful runs between Rig milestones, whether a lucky high-rarity item skips a full progression band, and whether Mobility/Stock Slot purchases remain competitive choices.

## M4.2 early passive break-even is intentionally short
Do not treat low-end ~3–5 minute break-even as an accidental M5 regression. M4.2 deliberately accepted shorter early payback to make ordinary KEEP choices noticeable against the measured active SELL economy. Only retune if M5 runtime testing shows KEEP becomes automatic.

---

# Delivery / persistence reliability

## Unresolved Delivery Review is server-memory only
A successfully unloaded haul enters a SELL/KEEP review, but unresolved review state is not persisted. A disconnect/crash before the choice can lose the delivered haul.

Before public release either persist pending delivery review state or use a deterministic safe fallback such as automatically selling unresolved delivered items on disconnect/shutdown.

## Stock economic values are saved as snapshots
Saved Stock records include PassiveRatePerMinute, OriginalSellValue, and SalvageValue. Live economy changes can therefore leave old Stock at old rates.

Choose an explicit launch policy: preserve snapshots, recalculate from current config on load, or add an economy version/migration path.

---

# UI / mobile / performance watchlist

- Test the fixed-size Manage Stock panel on small phones; convert to scale + `UISizeConstraint` if it clips.
- Handling preview can become stale if the carried pile changes but the nearby candidate stays the same; refresh on meaningful carry-count changes or at a low periodic rate.
- `CameraProtectionController` calls `GetDescendants()` every rendered frame; cache carried parts before M6 detailed models make this expensive on mobile.
- `EconomyTelemetryController` is useful now but should be Studio/dev-gated before release.
- Remove prototype-facing strings such as `TEST SCORE` and milestone debug prefixes before release UI freeze.

---

# Config / maintainability watchlist

- Move the current warehouse back-boundary coordinate into `WarehouseConfig` before future expansion.
- Legacy `CarryRigTier` coexists with live stat-derived `HandlingRigTier`; future systems must use the live handling tier and the legacy field should be cleaned/migrated later.
- `NumberFormat` currently stops at T; extend suffixes if the final late economy goes far beyond trillions.

---

# Systems that passed well

## Server authority
Strong overall: grab validation and distance server-side, authoritative supply, server rarity generation, review IDs/Stock IDs validated, server-defined upgrade prices, server-owned persistence, client UI not trusted for payouts/stats.

## Data safety
Strong for the current stage: `UpdateAsync`, session ownership, retries/backoff, numeric sanitization, schema guard, duplicate-load protection, autosave, PlayerRemoving, BindToClose, offline cap, server-side timing.

## Carry system
Strong architecture: authoritative item list, controlled stack visuals, Weight/Bulk/Shape inputs, movement-generated sway, Base Instability separated from Sway, Load Pressure separate from immediate collapse risk, Mobility suppression under load, partial collapse, manual sacrifice, tutorial warning removed after the first successful delivery.

## M5 handling progression
Direction is correct on paper: open warehouse, cargo capability as gate, Rig Tier as summary rather than arbitrary level, section-specific handling targets, rarity not automatically increasing Weight/Bulk, and deep valuables transported in believable containers. Still requires runtime validation.

## Rarity presentation
Appropriate for M5 first pass: escalating highlights, Legendary+ light, Mythic+ controlled particles, Cosmic/Eternal silhouette accents, rarity audio, restrained particle counts. Final art remains M6.

---

# Required M5B.1 playtest gates

Before continuing to M5C, test:
1. starter representative cargo in every section
2. starter runs directly to Secure and targets the best value/handling-efficiency object
3. UNMANAGEABLE stop/start cheese
4. junk-shield attempt after the audit patch
5. one-section-ahead sequence breaking
6. Strength specialist vs Carry Space specialist vs Control specialist
7. time/runs to Rig I / II / III / IV / V
8. whether upgrade prices become trivial when a new section opens
9. whether one lucky rarity skips too much progression
10. whether Mobility creates a deterministic optimal farm circuit
11. SELL vs KEEP with M5 values
12. 12-player supply depletion / rarity competition
13. small-phone UI with GRAB + DITCH + handling preview
14. large-pile client performance

## Current recommendation

Do not start M5C yet. Run M5B.1 first and use that data to decide whether handling thresholds, upgrade prices, rarity economics, or section pacing actually need balance changes. Avoid preemptive numerical retuning until those tests are complete.
