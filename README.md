# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading bay.

## Current milestone

**M2 - Multiplayer Warehouse Foundation / awaiting 12-player validation**

M1/M1.1 proved the carrying interaction is enjoyable enough to continue. The following behavior is treated as locked core unless multiplayer exposes a genuine technical issue:

- GRAB feel
- automatic exaggerated pile presentation
- Weight / Bulk / ShapeTag behavior
- Base Instability + Current Sway
- movement-driven balancing
- recovery
- scaled partial-collapse consequence
- collapse-lost items being lost for that trip
- unload feel
- first-run STOP OR IT WILL FALL teaching behavior

## M2 environment

- target: 12 players
- 216 x 216 stud warehouse graybox
- one shared central Item Floor
- four visible stock clusters
- 32 normal stock positions at full restock
- twelve perimeter loading bays
- session-only server bay ownership
- owner-only unload zones
- server-authoritative first-valid-grab-wins reservation
- item-specific 1.2-2.5 second restock timing
- player-to-player collision remains disabled
- carried piles remain visible to everyone

## Shared floor clusters

- GENERAL
- ELECTRONICS
- FURNITURE
- HEAVY

These are traffic-distribution labels for testing, not final warehouse art or permanent content taxonomy.

## Bay behavior

On join, the server assigns the first available bay.

Each assigned player:

- receives a BayIndex attribute
- spawns/respawns at that bay facing the shared floor
- sees their bay highlighted locally
- sees the bay number in the prototype HUD
- can unload only at their own bay

When a player leaves, the bay becomes available again.

No bay assignment is persisted.

## Still excluded

- progression
- permanent Cash economy
- DataStores
- rarity
- collections
- events
- monetization
- final warehouse art
- final UI
- cosmetics
- pets / rebirths / trading / combat / quests

## Controls

- **E / mobile GRAB** - grab nearest highlighted available item
- **Q** - intentionally drop the top item
- **F3** - developer carry telemetry

## Tooling

Use aftman install, then rojo serve.

Build with: rojo build -o OneTrip.rbxlx

See docs/M2_PLAYTEST.md for the milestone validation gate.