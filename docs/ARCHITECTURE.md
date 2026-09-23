# ONE TRIP — Architecture Rules

## Authority model

The server owns gameplay truth.

Clients may request actions and render feedback, but they do not authoritatively decide:

- shared-item ownership or availability
- rarity
- carried-item membership
- carry handling bands
- collapse/loss results
- unload results
- SELL / KEEP rewards
- Stock income
- upgrade costs
- persistent profile values

A client-facing UI prediction may be convenient, but the server must validate the real action.

## Authoritative-state rule

Gameplay state should live in service-owned tables/data, not be reconstructed from presentation objects.

In particular:

- CarryService should remain the source of truth for carried items
- Economy should consume a read-only CarryService snapshot rather than infer inventory from visual part names
- Handling should consume authoritative carry state rather than scan the visual rig
- physical Stock displays are presentation of server-owned Stock state, not the Stock state itself

The current M5B.1 visual-rig parsing path is accepted technical debt for validation, but should be removed before release architecture freezes.

## Shared modules

Shared modules contain:

- immutable item/loot definitions
- economy tuning
- carry tuning
- rarity tuning
- progression tuning
- warehouse geometry/content config
- remote names
- formatting/cross-boundary constants

Keep tuning centralized. Avoid scattering balancing numbers through server/client scripts.

## Server services

Current responsibilities:

### WorldService
Builds the warehouse graybox, section structures, authored item markers, bays, routes and future expansion anchors.

### BayService
Assigns one of 12 bays to each player and owns bay ownership presentation.

### ItemService
Owns world-item availability, first-valid pickup, vacancy/replenishment pacing and lost-trip visuals.

### LootRarityService
Transforms current supply into the M5 base-item + rarity catalog and owns rarity caps/cooldowns/debug forcing.

The M4 supply-selection layer and M5 final-loot transform should eventually be unified into one generation pipeline.

### CarryService
Owns carried-item membership, controlled pile layout, Base Instability, Current Sway, Load Pressure, collapse and manual ditch consequences.

### HandlingRuntimeService
Maps the player's real Strength / Carry Space / Control against the current load and supplies READY / RISKY / DANGEROUS / UNMANAGEABLE behavior.

### PlayerDataService
Owns persistent profiles, session locking, migration/sanitization, offline earnings, autosave and shutdown saving.

### ProgressionService
Owns upgrade purchases and stat-derived Handling Rig summaries.

### EconomyService
Owns Delivery Review, SELL / KEEP, persistent Stock and passive income.

### UnloadService
Transitions an authoritative carried haul into the economy Delivery Review at the player's own bay.

### CollisionService
Prevents player-player body blocking.

## Client responsibilities

Clients own:

- input
- contextual GRAB / DITCH presentation
- handling previews
- HUD / Load Pressure display
- economy/progression UI
- local camera protection
- local visual/audio feedback
- development telemetry presentation

Clients must not calculate authoritative rewards or carry success.

## Remote-event rules

Every client→server RemoteEvent must have:

1. type validation
2. ownership/context validation
3. distance/state validation where relevant
4. server-side values/costs rather than client-provided values
5. a reasonable rate limit when the request can be spammed

Read-only `RequestState` paths are still attack surfaces if they serialize/send large snapshots repeatedly.

## Character movement caveat

Server-side distance checks do not by themselves stop Roblox speed/teleport exploits because character movement can be client-network-owned.

Before public release, add a tolerant movement-abuse strategy that protects the warehouse travel economy without punishing normal latency.

Do not solve this by making normal movement feel server-laggy.

## Carry architecture rules

1. Prefer controlled/deterministic stacking over independently simulated network physics.
2. Keep **Base Instability**, **Current Sway**, and **Load Pressure** separate.
3. Standing still may reduce Sway but must not completely solve a fundamentally dangerous pile.
4. Load Pressure should create careful urgency rather than a hidden hard timer.
5. Collapse/DITCH loss must not become free drop-rest-regrab cheese.
6. Carried piles must not become collision weapons.
7. Progression moves the danger frontier outward; it does not delete risk.
8. Rarity does not automatically make the same physical object heavier just because its value is higher.

## Economy architecture rules

1. One primary currency: Cash.
2. SELL = immediate value.
3. KEEP = physical Stock slot + recurring passive income.
4. Passive Stock must not make active warehouse runs irrelevant.
5. Stock capacity is limited and upgradeable.
6. Liquidation should not allow permanent passive earnings plus full original SELL value.
7. Offline income must be capped/versioned deliberately.
8. A successfully delivered haul must not disappear because a Delivery Review was unresolved during disconnect/crash.

## Loot / progression rules

1. No traditional personal Luck stat as the main better-loot progression.
2. Better opportunities come from deeper sections, improved handling capability, server-wide rare opportunities, and later justified demand systems.
3. High progression means more opportunities, not guaranteed rarity inflation.
4. Rare objects need visible/mechanical identity, not only recolor/value multiplication.
5. Normal warehouse sections remain physically open unless a future design explicitly justifies a gate.

## Mobile / multiplayer rules

1. Target server size: 12 players.
2. Mobile is a first-class control/layout target.
3. GRAB and emergency DITCH must both be available on touch.
4. Players do not body-block or knock one another over.
5. Normal shared loot uses first valid server-confirmed pickup.
6. Social competition should come from shared opportunities and visible spectacle, not sabotage.

## Development rules

1. Build/test the risky interaction before wrapping more systems around it.
2. Fix demonstrated problems with the smallest system that preserves the core fantasy.
3. Do not retune from theory when a targeted playtest can answer the question.
4. Keep milestone/test docs current so old prototype rules are not mistaken for live design.
5. Remove dead compatibility code once the replacement system is proven.
6. Add new item/system properties only when they create a meaningful player decision.
7. Avoid hidden RNG that causes unexplained failure.
8. Preserve the visible physical pile and physical Stock identity.
9. Keep the game playable/readable with 12 players and large piles.
10. Stop expanding a phase when its validation gate is not yet passed.
