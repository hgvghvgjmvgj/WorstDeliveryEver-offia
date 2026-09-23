# ONE TRIP — M2.3 Playtest Gate

## Scope

M2.3 is a targeted exploit fix. It does not begin M3 economy and does not redesign carrying feel, Sway, Base Instability, the warehouse, bays, multiplayer, or normal stock spawning.

The rule under test is:

> DROPPING SHOULD BE A SACRIFICE, NOT A FREE RESET.

## Controls

- **E / mobile GRAB** — grab highlighted available warehouse item
- **Q / ButtonB** — intentionally ditch the top / most recently grabbed carried item
- **F3** — developer telemetry, including exact internal Strain

There is no dedicated full-load dump button in M2.3. Repeated Q presses can ditch the entire load one item at a time, and every ditched item is lost from that trip.

## Expected M2.3 behavior

When Q is pressed:

1. The server removes exactly the top / most recently grabbed item from authoritative carried state.
2. Weight, Bulk, Run Value, Base Instability, and load severity are recomputed from the remaining pile.
3. The removed item becomes a short presentation-only abandoned visual in `LostTripItems`.
4. The abandoned visual has `Available=false`, `CanQuery=false`, `CanTouch=false`, and never enters the shared `Items` folder.
5. Neither the owner nor another player can grab that abandoned visual.
6. The abandoned visual fades/despawns after the configured M2.3 ditch lifetime.
7. The original warehouse spawn system continues its normal independent restock behavior.
8. Existing Load Pressure is not reduced directly by the ditch. A lighter remaining load changes future generation/recovery naturally.
9. If the final carried item is ditched, residual Load Pressure remains and decays at the configured unloaded recovery rate instead of snapping to zero.
10. Successful delivery and death/respawn still perform their intended hard trip reset.

## Test A — Old Exploit

1. Start a fresh Play session.
2. Press F3 so exact Strain is visible.
3. Build a load until LOAD PRESSURE is clearly elevated.
4. Press Q repeatedly until all carried items are ditched.
5. Stand beside the abandoned visuals and press E / attempt to target them.
6. Wait through their visual lifetime.

PASS if:

- ditched visuals never receive a GRAB prompt
- item count remains zero unless a normal warehouse item is grabbed
- the exact abandoned objects cannot be reclaimed
- Run Value for those ditched objects is gone
- residual Strain is visible after the final ditch and then decays instead of instantly becoming 0.000

## Test B — Single Sacrifice

1. Build a dangerous multi-item load.
2. Note F3 Weight, Bulk, Run Value, Strain, and item count.
3. Press Q once.

PASS if:

- exactly one item leaves the pile
- it is the top / most recently grabbed item
- item count falls by exactly one
- Weight/Bulk/Run Value decrease by that item's values
- remaining stack immediately becomes easier according to its new composition
- Strain does not jump to zero
- the abandoned object cannot be targeted or grabbed
- remaining haul can still be delivered normally

## Test C — Save the Run

1. Build enough load to reach HIGH or CRITICAL Load Pressure.
2. Continue until the pile is genuinely difficult to control.
3. Ditch one top item.
4. If still too dangerous, make a deliberate second sacrifice.
5. Recover and attempt to reach the bay with what remains.

PASS if the decision feels like:

> I lost something valuable, but sacrificing it gave the remaining haul a real chance to survive.

Fail if Q feels like a free pause/reset or if sacrificing items does not materially improve the remaining load.

## Test D — Cost Matters

1. Make a valuable item the most recently grabbed/top item, such as a Safe in the current prototype set.
2. Add enough extra load to create danger.
3. Press Q.
4. Check Run Value before and after.
5. Deliver the remaining pile.

PASS if the ditched item's value is removed from the current run and never appears in the delivered score.

The intended reaction is:

> Damn, I lost that.

## Test E — Full Dump

1. Build HIGH/CRITICAL Load Pressure with several items.
2. Press Q repeatedly until item count reaches zero.
3. Watch LOAD PRESSURE and F3 Strain immediately after the final ditch.
4. Attempt to grab the abandoned visuals.

PASS if:

- every ditched item is permanently removed from that trip
- none of the abandoned visuals is grabbable
- LOAD PRESSURE remains visible while residual Strain is above zero
- residual Strain decays gradually rather than snapping to zero
- the player cannot dump, rest, and rebuild from those exact abandoned objects

At the current tuning, unloaded recovery is `0.140` Strain per second. From 1.0 to 0.0 is approximately 7.1 seconds; from the CRITICAL threshold of 0.86 down below HIGH at 0.62 is approximately 1.7 seconds if the player carries nothing.

## Test F — Collapse vs Ditch

### Ditch path

1. Grab several items.
2. Press Q once.
3. In Explorer during Play, inspect `Workspace > OneTripPrototype > LostTripItems`.
4. Confirm the visual has `TripLossKind = Ditch` and `Available = false`.

### Collapse path

1. Build an unstable pile and intentionally trigger a collapse loss.
2. Inspect `LostTripItems` again.
3. Confirm collapse visuals have `TripLossKind = Collapse` and `Available = false`.

PASS if:

- both paths remove items from carried state before creating loss visuals
- neither loss visual exists in the authoritative shared `Items` folder
- neither can be delivered
- neither can be grabbed
- no item exists simultaneously as carried + abandoned + reward
- normal untouched warehouse stock remains grabbable

## Multiplayer sanity check

Run two clients if practical:

1. Player A grabs and ditches an item.
2. Player B walks to the abandoned visual and tries to grab it.
3. Player A also tries to grab it again.

PASS if neither player can interact with the abandoned visual.

## Known follow-up observation — not part of M2.3

Prototype warehouse stock points currently restock quickly after a stock item is picked up. Therefore a player who returns to a normal stock point may eventually obtain a **fresh warehouse replacement of the same item type**. That is not the abandoned object and is intentionally not changed in M2.3 because item spawning is outside this targeted fix.

If later playtesting shows players can abuse rapid normal stock restocks to reproduce the same pressure-reset strategy, address that as a separate stock/restock design issue rather than making ditched objects reclaimable again.

## M2.3 pass gate

M2.3 passes when Tests A, B, E, and F are mechanically correct in Studio and Tests C/D feel like meaningful sacrifice decisions rather than free resets.

Do not begin M3 economy until this gate is reviewed.
