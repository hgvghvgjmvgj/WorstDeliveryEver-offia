# ONE TRIP — M5B.1 Repository Audit

Audit scope: full current `src/` tree plus active project/config docs, emphasizing architecture, server authority, exploits, balance assumptions, persistence, mobile parity, performance, and consistency with the current ONE TRIP design.

## Overall assessment

The codebase is in good shape for how quickly the prototype evolved. **There is no reason to rewrite it.** Core authority is server-side, persistence is careful, carry simulation is controlled, rarity is server-selected, and most tuning is centralized.

The main technical risk is now **prototype compatibility layers accumulating beside M5 systems**, making later balancing harder to reason about.

The main game-design risk is **progression/economy compression**, which must be measured in the current M5B.1 playtest rather than guessed from config alone.

---

# Fixed during this audit

## Mobile DITCH parity — FIXED

`InteractionController` previously created a touch GRAB button but no ditch/emergency-sacrifice touch control.

Touch players now receive a dedicated `DITCH` action.

## Stale milestone wording — FIXED

`ProgressionController` no longer displays `MAXED FOR M4`; it displays `MAXED`.

## UNMANAGEABLE junk-shield path — MITIGATED, MUST PLAYTEST

Original exploit path:

1. grab an UNMANAGEABLE valuable object
2. add cheap cargo above it
3. wait for grip failure to burn disposable top junk
4. preserve the underqualified valuable object longer

Current mitigation:

- the runtime remembers item count when the UNMANAGEABLE timer starts
- new top cargo added after that point is immediately stripped
- the original timer is preserved instead of reset

Required runtime test:

- starter grabs an UNMANAGEABLE Industrial/Secure object
- deliberately adds cheap cargo above it
- also test very fast back-to-back grabs around the 0.10s handling evaluation cadence
- confirm junk cannot materially extend the original object's survival window

Long-term cleaner implementation: CarryService should be able to remove the actual offending carried entry (and anything above it if stack integrity requires it) instead of HandlingRuntime relying on top-item stripping.

## HandlingPreview remote spam — FIXED

`HandlingPreview` had distance validation but no request-rate limit. An exploiter could repeatedly force carry scans + handling evaluation.

Server now rate-limits preview requests.

## Stale handling preview — FIXED

The normal client previously requested a preview only when the nearest item changed or progression changed. Ditch/collapse could therefore change the pile while the same nearby item kept an outdated READY/RISKY/DANGEROUS result.

The client now performs a low-rate preview refresh.

## Progression state-request spam — FIXED

`ProgressionAction("RequestState")` is now independently rate-limited instead of allowing unlimited server→client snapshots.

## Obsolete M4 PremiumSupplyService — REMOVED

The unused TV/Couch/Safe premium-cap service has been deleted.

Its inactive premium inventory/fallback tuning has also been removed from `SupplyConfig`.

## Repository source-of-truth docs — FIXED

The README was still describing M4, a 2-hour offline cap, and the old warehouse while live code is M5B.1.

README and architecture rules now reflect the current six-section M5B.1 project and this audit.

---

# Remaining architecture issues before release

## Handling/economy reconstruct carried state from carry visuals

`HandlingRuntimeService` and `EconomyService.CaptureCarriedItems` scan server-created carry visuals and parse names such as:

`Carry_<ItemId>_<Index>`

This is not currently a client exploit because the server owns those visuals, but presentation objects should not be an authoritative gameplay dependency.

Recommended correction before architecture freeze:

- expose `CarryService.GetCarriedItemIds(player)` and/or a read-only carry snapshot
- use it in HandlingRuntimeService
- use it in EconomyService delivery capture
- make visual part names presentation-only

## Two-stage M4 supply → M5 rarity transform

Current pipeline:

1. `ItemService` chooses/spawns a provisional legacy/prototype item from marker pools
2. `LootRarityService` transforms it into the final M5 section-specific base item + rarity

Pickup vacancy delay sees the final transformed ItemId, which is good, but some refill/value-band selection still originates from the provisional M4 layer.

Recommended pre-release pipeline: one server supply generation step chooses section, authored vacancy, final base item, rarity, hero eligibility, and final economy value before creating the world item.

Do not rewrite this in the middle of M5B.1 unless testing exposes an actual failure.

## Economy RequestState remains unbounded

`EconomyAction("RequestState")` returns a larger review/Stock snapshot and currently bypasses the economy action cooldown.

Normal UI uses this responsibly, but an exploiter can spam it.

Add a small independent read-request cooldown before public release.

## Character speed/teleport exploit protection is not implemented

Server-side distance checks are good, but Roblox character movement can be client-network-owned.

A speed/teleport exploiter may be able to make the server observe them near deep loot or their bay and bypass the intended travel-risk economy.

Before public release, add a tolerant movement-abuse strategy that protects item grab/unload/travel without punishing normal latency.

Do **not** make normal movement feel server-authoritative/laggy just to solve this.

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

The top end of each newly viable section can potentially finance a large portion—or in some cases all—of the next handling milestone. That may be exciting early pacing, or it may compress the whole warehouse progression into too few successful runs.

Measure:

- fresh-profile time to each Rig
- successful runs between Rig milestones
- how often one successful item pays the next full capability jump
- whether a lucky high-rarity item skips a full progression band
- whether Mobility/Stock Slot purchases remain competitive choices instead of everyone rushing handling

## Stock/passive acceleration at deep sections

Because SELL and KEEP scale together, deep-section Stock can generate very large passive rates.

Test whether three strong Industrial/Secure Stock pieces make the remaining upgrade economy collapse too quickly.

The current 5-minute offline cap is intentionally temporary and should not be treated as final balance.

## Early-section ultra-rares vs deep-section commons

M5B intentionally guarantees adjacent-section crossover, so a high-rarity older-section item can beat meaningful loot in the next section.

However, very deep commons can still exceed spectacular early-section rares. Test veteran behavior:

- does a veteran still care when a Cosmic/Eternal object appears in Receiving/Appliances?
- or do front-section rare spawns become visual spectacle with no meaningful chase value?

Do not inflate rarity multipliers blindly; that could create progression skips. Collection/flex value can also preserve relevance later.

## M4.2 early passive break-even is intentionally short

Do not treat low-end ~3–5 minute break-even as an accidental M5 regression.

Only retune if M5 runtime testing shows KEEP becomes automatic and SELL stops being a serious decision.

---

# Delivery / persistence reliability

## Unresolved Delivery Review is server-memory only

A successfully unloaded haul enters SELL/KEEP review, but unresolved review state is not persisted.

A disconnect/crash before the choice can lose the delivered haul.

Before public release either:

- persist pending Delivery Review safely, or
- use a deterministic safe fallback such as server-side SELL of unresolved delivered items

Service startup/removal ordering matters here because `PlayerDataService` currently owns the earliest `PlayerRemoving` save/release connection.

## Stock economic values are saved as snapshots

Saved Stock includes:

- `PassiveRatePerMinute`
- `OriginalSellValue`
- `SalvageValue`

Live economy changes can therefore leave old Stock at old rates.

Choose an explicit launch policy:

1. preserve historical snapshot values
2. recalculate from current config on load
3. add economy version + migration

## Tutorial completion is session-only

`TutorialWarningsEnabled` starts true for each new CarryService player state and turns off after the first successful unload of that session.

That means returning players can receive `STOP OR IT WILL FALL!` again every new server session.

The intended design is beginner/tutorial-only, so persistent tutorial completion should be added before launch.

---

# UI / mobile / performance watchlist

- `EconomySummary`, `ManageStock`, handling cards, and some prototype HUD surfaces still use fixed pixel widths. Test very small phone viewports before release.
- `CameraProtectionController` calls `GetDescendants()` every rendered frame; cache carried parts before M6 detailed models make this a mobile hotspot.
- `EconomyTelemetryController` is useful now but should be Studio/dev-gated before release.
- remove prototype-facing strings such as `TEST SCORE` and milestone debug prefixes before release UI freeze.
- full-size physical Stock models can exceed their bay slot footprint; test large furniture/pianos in 6–10 slot bays for overlap/readability.

---

# Config / maintainability watchlist

- move the current warehouse back-boundary coordinate into `WarehouseConfig` before future expansion
- legacy `CarryRigTier` coexists with live stat-derived `HandlingRigTier`; future systems must use the live handling tier and migrate/remove the legacy field later
- `NumberFormat` stops at T; extend suffixes if final late economy intentionally exceeds trillions by large amounts
- temporary M5B.1 DataStore namespace must not accidentally become the final live-data plan
- old prototype fields/constants should be removed once compatibility is no longer needed

---

# Systems that passed well

## Server authority

Strong overall:

- grab validation and distance server-side
- authoritative shared supply
- server rarity generation
- review IDs and Stock IDs validated
- server-defined upgrade prices
- server-owned persistence
- client UI not trusted for payouts/stats

## Data safety

Strong for current stage:

- `UpdateAsync`
- session ownership
- retries/backoff
- numeric sanitization
- schema guard
- duplicate-load protection
- autosave
- PlayerRemoving
- BindToClose
- offline cap
- server-side time

## Carry system

Strong architecture:

- authoritative carry state
- controlled stack visuals
- Weight/Bulk/Shape inputs
- movement-generated Sway
- Base Instability separated from Sway
- Load Pressure separate from immediate collapse risk
- Mobility suppression under load
- partial collapse
- manual sacrifice

## M5 handling progression

Direction is correct on paper:

- warehouse physically open
- cargo capability is the gate
- Rig Tier is a readable summary, not an arbitrary level lock
- section handling targets differ
- rarity does not automatically increase Weight/Bulk
- deep valuables use believable transport forms

Still requires runtime validation.

## Rarity presentation

Appropriate for M5 first pass:

- escalating highlights
- Legendary+ light
- Mythic+ controlled particles
- Cosmic/Eternal silhouette accents
- rarity audio
- restrained particle counts

Final art remains M6.

---

# Required M5B.1 playtest gates

Before continuing to M5C, test:

1. starter representative cargo in every section
2. starter runs directly to Secure and targets the best value/handling-efficiency object
3. UNMANAGEABLE stop/start cheese
4. junk-shield attempts, including rapid back-to-back grabs
5. one-section-ahead sequence breaking
6. Strength specialist vs Carry Space specialist vs Control specialist
7. time/runs to Rig I / II / III / IV / V
8. whether upgrade prices become trivial when a new section opens
9. whether one lucky rarity skips too much progression
10. whether Mobility creates a deterministic optimal farm circuit
11. SELL vs KEEP with M5 values
12. whether deep Stock passive income collapses progression pacing
13. veteran interest in early-section Cosmic/Eternal opportunities
14. 12-player supply depletion / rarity competition
15. small-phone UI with GRAB + DITCH + handling preview/economy UI
16. large-pile client performance
17. speed/teleport exploit attempts before public release

## Current recommendation

**Do not start M5C yet.**

Run M5B.1 first and use that data to decide whether handling thresholds, upgrade prices, rarity economics, Stock income, or section pacing actually need balance changes.

Avoid preemptive numerical retuning until those tests are complete.
