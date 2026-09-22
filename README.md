# ONE TRIP

A 12-player Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk ONE MORE before making it back to your van.

## Current milestone

M1 - Core Carry Prototype

The repository now contains the minimum playable loop required to test:

Find item -> Grab -> visible pile grows -> risk increases -> decide whether to continue -> return carefully -> unload -> receive temporary test score -> repeat

### M1 includes

- server-authoritative shared-item grabbing
- eight centrally configured test items
- deterministic automatic carry stacking
- separate Base Instability and Current Sway
- Weight-based movement slowdown
- distinct Bulk, Tall, Wide, and Compact behavior
- movement filtering based on actual character motion
- readable pile wobble
- recoverable near-collapse warning
- Partial Collapse as the active failure mode
- owner protection for freshly dropped objects
- temporary unload/test score
- F3 developer telemetry
- simple M1 graybox test room

### M1 intentionally excludes

- DataStores
- progression/upgrades
- final Cash economy
- rarity
- collections
- events
- monetization
- final UI/art
- final 12-player warehouse
- pets/rebirths/trading/combat/quests

## Controls

E / mobile GRAB button - grab nearest valid item

Q - drop the top carried item

F3 - toggle developer carry telemetry

## Developer carry presets

Players default to Beginner.

During Studio testing, change the Player attribute CarryPreset to either Beginner or Veteran. The carry service recalculates live.

## Tooling

Use aftman install, then rojo serve.

To build a place file, run rojo build -o OneTrip.rbxlx.

See docs/CORE_MECHANIC.md and docs/M1_PLAYTEST.md.
