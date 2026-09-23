# ONE TRIP — MAP ARCHITECTURE V2 PLAYTEST

This rebuild is not approved until Studio validation is complete.

Do **not** begin M4 from this document.

## Scope preserved

Do not retune or redesign during this gate unless a test specifically exposes a map problem:

- GRAB / carry feel
- Base Instability
- Current Sway
- Load Pressure
- collapse
- intentional ditch sacrifice
- SELL / KEEP economy
- passive Stock
- Cash
- bay Stock logic

## Current V2 geometry

- Facility footprint: `660 x 420` studs
- 12 bays across the primary loading side
- Receiving / Dispatch apron: `640 x 70`
- Four active sectors, each approximately `140 x 295`
- Mid cross-aisle: `Z = 18`, width `30`
- Deep cross-aisle: `Z = -92`, width `34`
- 36 authoritative shared loot opportunities total
- 9 opportunities per sector
- Deep / Secure Storage landmark at the back wall

## Sector identities

### General Goods

Open racks, pallets, flexible/light objects, more open sightlines.

### Appliances / Electronics

Larger storage-bay masses and display areas.

### Furniture / Oversized

Wider open staging areas and bulky-object space.

### Industrial / Heavy

Heavy pads, cage-like structures and larger spacing.

These are graybox identities, not final art.

## Route-depth targets

Coordinate audit currently estimates the nearest practical opportunity per bay around:

- Near: ~90–122 route studs
- Mid: ~185–230 route studs
- Deep: ~317–347 route studs

At 16 studs/s before player behavior/turning:

- Near: ~5.6–7.6 seconds
- Mid: ~11.5–14.4 seconds
- Deep: ~19.8–21.7 seconds

At current 9.5 studs/s heavily-loaded minimum speed:

- Near: ~9.5–12.8 seconds
- Mid: ~19.4–24.2 seconds
- Deep: ~33.3–36.5 seconds

Actual Studio traversal must be measured. These are geometry estimates only.

## Route choice

### Freight

- 30-stud-wide main route
- straight/readable
- full sector depth ~295 studs
- intended for large unstable piles

### Service

- 18-stud-wide route
- approximately 276 studs end-to-end
- more direction changes
- intended to save some distance while demanding more turning

The shortcut must not become both safest and fastest.

---

# TEST A — FULL TOP-DOWN REVIEW

Take one full overhead screenshot with the entire facility visible.

Check:

- Does meaningful structure occupy most of the frame?
- Is there any unexplained giant empty concrete area?
- Do the four sectors visibly extend deep into the building?
- Do General, Appliances, Furniture and Industrial look different even as graybox?
- Is Deep actually far from the loading line?
- Can you understand the whole loot layout instantly from the bay area? If yes, occlusion is too weak.
- Does it still resemble repeated test shelves? If yes, fail.

Do not approve V2 without this screenshot review.

# TEST B — NEAR / MID / DEEP TRAVEL

From a typical bay:

1. Run to a Near opportunity and record time.
2. Run to a Mid opportunity and record time.
3. Run to a Deep opportunity and record time.
4. Repeat from an outer bay and a central bay.

Starting unloaded targets:

- Near: roughly 4–7s
- Mid: roughly 8–14s
- Deep: roughly 15–23s

Slight deviations are acceptable if actual play feels better.

Fail if Deep still feels like it is right beside Mid.

# TEST C — LOOT SEARCH RHYTHM

Walk each sector normally without grabbing everything.

Target:

- meaningful visible/route decision roughly every 3–6 seconds
- not necessarily a pickup every 3–6 seconds
- no giant dead walking stretches
- no view containing 20–30 obvious grabbable items

Check partial occlusion from structures.

# TEST D — SECTOR IDENTITY

Run all four sectors without reading the big sign after entering.

Ask whether the graybox layout itself communicates different space:

- General = open racks/pallets
- Appliances = larger storage bays
- Furniture = wider staging
- Industrial = cages/heavy pads

Fail if it feels like the same copied aisle four times.

# TEST E — FREIGHT VS SERVICE

Take a dangerous pile from Deep.

Return once using Main Freight Route.

Record:

- time
- Load Pressure behavior
- how many meaningful turns
- whether the large pile fits comfortably

Repeat using Service Route.

Expected:

- Service is somewhat shorter
- Service requires more direction changes
- Freight is easier/readable for a giant unstable load
- neither route is universally correct

Fail if one route is both faster and safer.

# TEST F — CROSS-AISLES

Use both major cross-aisles to switch sectors during a run.

Verify:

- route switching feels obvious
- cross-aisles are wide enough for huge stacks
- players are visible crossing them
- they create alternate return paths
- they do not feel like narrow maze hallways

# TEST G — BAY FAIRNESS

Test at least:

- Bay 01
- one left-middle bay
- one right-middle bay
- Bay 12

Measure practical route time to that bay's closest useful Near, Mid and Deep options.

Coordinate audit currently puts each bay's closest Near option within roughly 90–122 route studs and Deep cross-aisle access within roughly 262–289 route studs.

Outer bays being closer to outer sectors is acceptable because sectors should be balanced around different object problems.

Fail if one bay is consistently closer to the strongest overall gameplay route.

# TEST H — 12 PLAYERS

Use Studio multi-client testing.

Observe:

- distribution by sector
- players visible at Dispatch
- players visible at both cross-aisles
- congestion
- loot starvation
- whether everybody runs to the same deepest sector
- whether everybody becomes completely isolated
- frame rate

Target:

- roughly 2–4 players can naturally occupy different regions without assignments
- repeated social intersections still happen

# TEST I — LARGE PILES

Test a ridiculous/high pile through:

- General freight aisle
- Appliances storage bays
- Furniture staging
- Industrial cages
- both cross-aisles
- Service route turns

Check:

- camera
- clearance
- pile clipping
- annoying collision traps
- mobile-friendly turning room

# TEST J — EMPTY SPACE AUDIT

Any large open space must have a clear reason:

- Receiving / Dispatch
- freight crossing
- oversized staging
- cross-aisle
- secure/future connection

If a region is simply empty because content was squeezed elsewhere, V2 fails.

# TEST K — DOMINANT STRATEGIES

Specifically test:

- Deep camping
- Industrial always-best behavior
- fastest-and-safest shortcut
- loot starvation
- repeated sector camping
- bay advantage

Do not solve economy balance inside this map gate unless geometry itself causes the dominance.

# PASS CONDITION

V2 passes only when the facility feels like a large, intentional, interconnected warehouse where three consecutive runs can plausibly choose a different:

- sector
- depth
- return route

without the experience becoming empty walking.

When Studio validation is complete, report failures before approving the next milestone.

**Do not start M4.**
