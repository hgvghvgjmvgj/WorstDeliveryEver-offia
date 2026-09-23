# ONE TRIP

ONE TRIP is a Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your loading/resale bay.

## Current milestone

**M2.3 — Drop / Load Pressure Reset Exploit Fix — awaiting Studio validation**

M1/M1.1 carry feel, M2 multiplayer ownership, M2.1 Load Pressure/Strain, and the approved-enough M2.2 warehouse/base structure remain preserved.

M3 economy has **not** started.

## M2.3 — ditching is a sacrifice

The intentional drop action is now a **ditch** rather than recoverable temporary storage.

- Q / ButtonB ditches exactly the top / most recently grabbed carried item.
- The item is removed from authoritative carried inventory first.
- Weight, Bulk, Run Value, Base Instability, and load severity are recomputed from what remains.
- The ditched object becomes a short presentation-only abandoned visual.
- Ditch visuals never enter the shared `Items` folder and are not grabbable by the owner or other players.
- Ditched items cannot contribute to delivery score.
- Repeated Q presses can sacrifice the whole load, but there is no separate full-dump action.
- Load Pressure does not instantly reset when the final item is ditched.
- With no carried items, residual Strain decays at `0.140` per second until it reaches zero.
- The Load Pressure HUD stays visible during that residual recovery period.
- Successful delivery and death/respawn still perform their intended hard trip reset.

See `docs/M2_3_PLAYTEST.md` for the M2.3 validation gate.

## Existing warehouse/base foundation

- 12-player shared warehouse
- 560 x 560 stud current graybox footprint
- Near / Mid / Deep travel-depth structure
- 36 authoritative shared item positions
- open social sightlines and large-stack routes
- 12 loading/resale bays around the outer perimeter
- owner-only delivery processing zones
- 3 visible future stock/display positions per bay
- 10 total reserved stock positions per bay for future expansion
- future Quick Sell and Bay Upgrade anchors
- 46-stud nonblocking ceiling-clearance reference
- player-facing LOAD PRESSURE meter

No selling, Cash, offline earnings, stock timers, or upgrades are implemented yet.

## LOAD PRESSURE

The server system is called Strain internally. Normal players see LOAD PRESSURE as:

- LOW
- BUILDING
- HIGH
- CRITICAL

The meter represents accumulated holding pressure. It is **not collapse chance** and exposes no exact percentage/countdown during normal play.

Collapse still depends on Base Instability, Current Sway, movement, recovery, stack composition, and Strain-modified difficulty.

F3 developer telemetry exposes exact internal Strain values for tuning.

## Item-loss states

### Successful delivery

Items reaching the player's bay are delivered. Future M3 systems will decide Cash / Stock behavior.

### Collapse loss

Failure removes the affected items from the current trip. Their visible debris is presentation-only and cannot be reclaimed.

### Intentional ditch

The player deliberately sacrifices the top item to reduce the remaining load. The abandoned visual is also presentation-only and cannot be reclaimed.

Untouched warehouse stock remains normal shared loot.

## Controls

- **E / mobile GRAB** — grab nearest highlighted available warehouse item
- **Q / ButtonB** — ditch the top / most recently grabbed carried item; it is lost from the trip
- **F3** — developer telemetry

## Still excluded

- Quick Sell economy
- stock/list sale timers
- offline earnings
- Cash balancing
- base upgrade purchases
- DataStores
- final progression
- final rarity
- collection
- contracts
- traditional Luck
- monetization
- final map art
- detailed models
- final UI polish
- pets / workers / helpers
- rebirths

## Current validation docs

- `docs/M2_2_PLAYTEST.md` — warehouse/base structure validation
- `docs/M2_3_PLAYTEST.md` — ditch sacrifice / Load Pressure exploit validation
