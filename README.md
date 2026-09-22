# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading bay.

## Current milestone

**M2.1 - Carry Urgency / Strain Fix / awaiting playtest validation**

M1/M1.1 carry feel and M2 multiplayer warehouse behavior remain locked.

M2.1 adds one internal carry concept:

**Strain = how difficult it becomes to keep holding an overloaded pile together over time.**

Strain is load-dependent, not a universal trip timer.

- comfortable loads create effectively no Strain pressure
- risky overloads accumulate Strain over time
- stopping still reduces Current Sway
- stopping does not reset or pause overload Strain
- high Strain makes Sway recover more slowly
- high Strain makes movement mistakes create more Sway
- high/critical Strain creates persistent pile tremble even while stationary
- sufficiently overloaded piles can eventually collapse if held too long
- reducing the actual load allows Strain to decay
- unloading/death resets the current-trip Strain

There is no player-facing Strain percentage or collapse countdown.

The first teaching phase may show: HEAVY LOADS GET HARDER TO HOLD.
After the first successful delivery, normal play relies on the pile itself.

## M2 environment remains unchanged

- target: 12 players
- 216 x 216 stud warehouse graybox
- shared Item Floor
- four stock clusters
- 32 normal stock positions
- twelve session-assigned loading bays
- owner-only unload zones
- first-valid-server-grab wins
- player collision disabled

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
- **F3** - developer telemetry, including Strain and load severity

## Tooling

Use aftman install, then rojo serve.

Build with: rojo build -o OneTrip.rbxlx

See docs/M2_1_PLAYTEST.md for the Strain validation gate.