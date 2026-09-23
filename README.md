# ONE TRIP

ONE TRIP is a Roblox multiplayer game about carrying an increasingly ridiculous pile of warehouse cargo and deciding whether to risk **ONE MORE** before making it back to your personal loading/resale bay.

The central skill is not precision placement. Items auto-stack into a controlled visual pile; movement, pile composition, Weight, Bulk, Shape, Load Pressure, and the player's handling progression determine how dangerous the return trip becomes.

## Current milestone

**M5B.1 — Natural Handling Progression — awaiting full runtime validation**

Do **not** begin M5C until the M5B.1 playtest gates pass.

Current implementation includes:

- 12-player shared warehouse
- 12 personal loading/resale bays
- six warehouse sections
- server-authoritative shared loot
- movement-driven carry instability
- Load Pressure / Strain anti-turtle system
- partial collapse loss
- intentional DITCH sacrifice
- SELL vs KEEP delivery decisions
- permanent physical Stock that generates passive Cash
- persistent Cash / Stock / upgrades
- capped offline Stock earnings
- natural handling progression through Strength / Carry Space / Control
- Mobility and Stock Slot upgrades
- Common → Eternal rarity
- 72 core base loot types + 6 rare-only hero objects
- server-side rarity caps/cooldowns for Legendary+
- first-pass rarity presentation and primitive object models

## Core design rule

> The warehouse is open; the loot is the gate.

Normal sections are not hard-locked by arbitrary progression doors. Players can physically reach deeper sections, but cargo becomes increasingly difficult to transport without sufficient Strength, Carry Space, and Control.

Progression should move the danger frontier outward rather than deleting the core risk.

## Warehouse sections

1. Receiving & General Storage
2. Appliances & Electronics
3. Furniture & Oversized
4. Heavy Goods & Equipment
5. Industrial Storage
6. Secure High-Value Storage

The facility is intentionally long enough that travel depth matters. The main freight route, service routes, section connectors, and 12-player social sightlines should remain readable even when players carry large piles.

## Carry model

The server owns carried-item membership and carry outcomes.

Important concepts remain separate:

- **Base Instability** — inherent danger created by the pile itself
- **Current Sway** — temporary movement/momentum instability
- **Load Pressure** — time/burden pressure that accumulates on overloaded piles

Stopping can reduce Current Sway, but it does not erase a fundamentally bad pile or instantly reset Load Pressure.

Desired strategy:

> careful urgency — do not sprint, do not turtle

Collapse is partial and severity-scaled. Lost cargo is removed from the current trip and cannot simply be picked back up.

Manual DITCH is an emergency sacrifice, not a free reset.

## Beginner tutorial rule

The explicit warning:

`STOP OR IT WILL FALL!`

is a beginner teaching aid only. After the player has successfully completed the first delivery in the current implementation, repeated collapse warnings rely primarily on pile motion/audio/visual feedback instead of constant instructional text.

Long-term, tutorial completion should become persistent rather than resetting every session.

## Progression

Current upgrade tracks:

### Strength

`15 → 17 → 19.5 → 22.5 → 26 → 30 → 34.5 → 40`

### Carry Space

`13 → 15 → 17.5 → 20.5 → 24 → 28 → 33 → 39`

### Control

`1.00 → 1.10 → 1.22 → 1.35 → 1.50 → 1.67 → 1.85 → 2.05`

### Mobility

`16 → 17.5 → 19 → 20.5 → 22 → 23.5 → 25`

Mobility is intentionally suppressed under heavy loads so late-game players still have consequential return trips.

### Stock Slots

`3 → 4 → 5 → 6 → 8 → 10`

The visible Handling Rig tier is derived from real Strength / Carry Space / Control stats. It is a readable summary, not the actual authoritative gate.

## SELL / KEEP / Stock

After a successful delivery:

- **SELL** gives a large immediate Cash payout and removes the item
- **KEEP** places the delivered object in a limited physical Stock Slot
- kept Stock remains visible in the player's bay
- kept Stock generates recurring passive Cash
- Stock can later be liquidated for a reduced salvage payout

The object itself is the passive generator. ONE TRIP does not use generic pets/workers as the primary passive-income identity.

Current default Stock capacity: **3**

Current liquidation ratio: **20%** of original SELL value

## Offline earnings

Persistent Stock produces capped offline earnings using server time.

Current **M5B test cap: 5 minutes** of saved Stock output.

This cap is intentionally temporary because M5 values are much larger than earlier prototype values. The final offline cap must be revisited after the wider progression/economy sinks are validated.

Current test DataStore namespace:

`OneTripPlayerData_M5B_1HandlingTest_v1`

Do not treat this temporary validation namespace as the final live-data plan.

## Loot + rarity

Current rarity ladder:

- Common
- Uncommon
- Rare
- Epic
- Legendary
- Mythic
- Cosmic
- Eternal

Rarity changes value and presentation but does **not** automatically multiply Weight/Bulk. The physical identity of the base object remains the handling problem.

Legendary+ supply has server-wide simultaneous caps and post-claim cooldowns.

Rare-only hero objects currently include one authored hero per section.

See:

`docs/M5B_PLAYTEST.md`

for the current rarity/economy validation plan.

## Persistence

`PlayerDataService` owns persistent player data using Roblox DataStoreService.

Current profile includes:

- Cash
- progression levels
- Stock contents and economic metadata
- passive fractional remainder
- last-seen server timestamp
- session ownership record

Safety currently includes:

- `UpdateAsync`
- session ownership / stale-lock timeout
- retries with backoff
- schema validation/sanitization
- autosave
- PlayerRemoving final save/release
- BindToClose
- temporary Studio fail-open profiles when API Services are unavailable

## Authority / exploit philosophy

Clients request actions and render feedback. They do not decide:

- item ownership
- item availability
- carried-item membership
- rarity
- collapse result
- SELL/KEEP payout
- Stock payout
- upgrade costs
- persistent profile values

Server-side distance checks exist for grabbing and handling previews.

Before public release, character-movement exploit protection still needs a dedicated design because Roblox character network ownership can allow speed/teleport abuse even when action validation is server-side.

## Current audit status

A repository-wide M5B.1 audit is tracked in:

`docs/M5B_1_REPO_AUDIT.md`

Recent audit fixes include:

- mobile DITCH button parity
- stale M4 progression wording removed
- UNMANAGEABLE junk-shield mitigation
- handling-preview RemoteEvent rate limiting
- low-rate handling-preview refresh to prevent stale UI
- progression state-request rate limiting
- obsolete M4 PremiumSupplyService removed
- obsolete TV/Couch/Safe premium-supply config removed

Important remaining pre-release work includes:

- replace carry-visual parsing with direct read-only CarryService state APIs
- protect economy state requests from remote spam
- resolve/persist an unfinished Delivery Review on disconnect/crash
- decide whether saved Stock uses historical economy snapshots or versioned recalculation
- unify old M4 supply selection and M5 final loot/rarity generation
- add movement/speed/teleport exploit protection
- make tutorial completion persistent
- complete small-phone UI validation
- perform final mobile/performance/12-player testing

## Still excluded / not justified yet

- pets/workers as the main progression identity
- rebirths
- trading
- combat / weapons
- aggressive PvP
- traditional personal Luck as the primary better-loot stat
- paid crash protection
- lootbox-style gambling
- unrelated minigames

## Required next step

Run the full M5B.1 playtest before numerical retuning or M5C.

Key questions:

1. Can a starter sequence-break Industrial/Secure cargo?
2. Do Strength / Carry Space / Control specializations feel meaningfully different?
3. Are upgrade costs too cheap once a new section becomes viable?
4. Can one lucky rarity skip too much progression?
5. Does SELL vs KEEP remain a real decision with M5 values?
6. Does Mobility create one deterministic optimal farm route?
7. Does the 12-player supply system create competition without feeling empty?
8. Do large piles and rarity presentation remain performant on mobile?

Do not tune those numbers from theory alone when a playtest can answer them directly.
