# ONE TRIP - M2 Multiplayer Warehouse Playtest

M2 asks one question:

> Does ONE TRIP become more entertaining when approximately 12 players share the warehouse?

Do not judge final art. Judge visibility, competition, spectacle, traffic, restocking, bay clarity, and performance.

## Setup

1. Sync the latest main branch through Rojo.
2. In Roblox Studio use multi-client testing.
3. Test 4 players first, then 12 players.
4. Confirm server Output contains: [ONE TRIP] M2 multiplayer warehouse foundation loaded
5. Confirm each client prints: [ONE TRIP] M2 client loaded

## Test A - Bay assignment

With multiple players joining close together:

- every player receives a unique BayIndex
- no two active players share a bay
- each player spawns facing the shared floor
- each local player sees only their own bay highlight
- shared bay labels show the correct owner
- leaving releases the bay
- a later joiner can receive the released bay

FAIL if a player has no understandable home bay or two players share ownership.

## Test B - Owner-only unload

Carry items to your assigned bay and unload.

Then walk the same stack through another player's unload zone.

Expected:

- your bay unloads normally
- another player's zone does nothing
- visual unload still remains visible to nearby players

## Test C - Shared grab conflict

Put two clients next to the same world item and attempt to GRAB simultaneously.

Expected:

- exactly one server-confirmed player receives it
- item enters exactly one carried inventory
- other player receives no item and no punishment
- stock restocks once
- no duplicate score can result

Repeat several times.

## Test D - Stock pressure

At 12 players, have everyone repeatedly grab items.

The floor starts with 32 normal stock points distributed over four clusters.

Observe:

- the entire floor should not routinely become empty
- restock should feel quick without making competition meaningless
- several routes/options should remain visible
- one tiny choke point should not dominate all pickups

Current restock tuning is item-specific from about 1.2 to 2.5 seconds.

## Test E - Traffic

Have all 12 players make normal trips simultaneously.

Watch:

- bay entrances
- paths from perimeter to central floor
- movement between clusters
- players returning with large piles
- center crossings

Expected:

- frequent visual contact with other players
- no player body-blocking
- no carried-pile collision griefing
- enough space to turn with absurd loads
- compact enough that the room feels populated

FAIL if the map feels like twelve isolated plots or if traffic becomes annoying rather than entertaining.

## Test F - Stack spectacle

Build several large stacks at once.

From another player's perspective verify:

- piles replicate correctly
- upper-layer wobble is visible
- dangerous stacks are readable at a distance
- collapses attract attention
- unload animations are visible
- other players' piles create social comparison without interfering with control

## Test G - Collapse isolation

Cause a collapse around other players.

Expected:

- collapse-lost items remain non-interactable presentation debris
- nobody can steal them
- lost visuals disappear cleanly
- normal warehouse stock continues independently
- remaining carried pile still works

## Test H - First five seconds

Join as a fresh client without being told what to do.

Expected immediate read:

- your bay/van is around you
- the shared Item Floor is directly in front of you
- other players and their piles are visible when the server is populated
- nearby shared items make GRAB discoverable
- no long tutorial interrupts play

The first-run STOP OR IT WILL FALL warning remains allowed until the first successful delivery. After that, the player must read the pile itself.

## Test I - 12-player performance

With 12 clients:

- create simultaneous medium/large piles
- have players turn/wobble/collapse at the same time
- continuously grab/restock
- make several simultaneous unloads

Watch for:

- major frame drops
- replication delays
- items visually desyncing from carried state
- delayed grab ownership
- duplicate objects
- stuck bay ownership
- excessive server warnings/errors

Do not optimize purely theoretical bottlenecks if the test remains healthy. Record actual failures.

## PASS signals

M2 should feel more entertaining than solo because:

- other people's stupid piles are fun to watch
- seeing somebody nearly lose a load creates reaction
- shared item competition creates light he-got-it-first tension
- the warehouse feels alive
- returning to your own bay creates a readable route
- social activity does not sabotage the core carrying skill

## FAIL signals

Do not proceed if:

- shared grabbing duplicates items
- bays double-assign
- players unload at the wrong bay
- stock is routinely empty
- body blocking/griefing becomes part of failure
- piles are hard to see because the room is too large
- 12 players make the center unreadably cramped
- multiplayer makes the carry mechanic less enjoyable
- performance falls apart under simultaneous large piles

If M2 fails, fix the multiplayer foundation. Do not add progression to cover it up.