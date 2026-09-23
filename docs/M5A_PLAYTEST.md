# ONE TRIP — M5A LONG WAREHOUSE PLAYTEST

M5B and M5C are NOT started. This gate validates only the long warehouse and section architecture.

## Build scope

M5A changes the graybox warehouse from four parallel prototype sectors into six sequential sections:

1. Receiving & General Storage
2. Appliances & Electronics
3. Furniture & Oversized
4. Heavy Goods & Equipment
5. Industrial Storage
6. Secure High-Value Storage

Near / Mid / Deep are no longer player-facing concepts. `ZoneDepth` remains only as an internal compatibility input for the existing M4.1 supply controller.

The old eight prototype items remain temporary placeholders in M5A. Do NOT judge final loot identity yet; the 72+ item catalog and rarity system belong to M5B.

## Current dimensions

- Facility shell: **700 × 900 studs**
- Current section width: **620 studs**
- Each current section length: **90 studs**
- Current freight spine: approximately **618 studs**
- Left/right service route: approximately **607 studs** each
- Cross-aisles between sections: **5**
- Authored item positions: **16 per section / 96 total**
- M4.1 active supply target: **12 per section solo / 16 per section full server**
- Expected active objects: approximately **72 solo / 96 full server**

The shell intentionally contains inaccessible future-expansion buffer behind Secure. `CurrentPlayableBoundary` prevents players entering that empty space.

## Theoretical straight-line travel baseline

The assigned-bay spawn marker is approximately Z=396.5. These are geometry estimates, not measured playtest results.

| Section | Approx distance to center | 16 studs/s | 25 studs/s | Loaded example 12 studs/s |
| --- | ---: | ---: | ---: | ---: |
| Receiving | 149.5 | 9.3s | 6.0s | 12.5s |
| Appliances | 249.5 | 15.6s | 10.0s | 20.8s |
| Furniture | 349.5 | 21.8s | 14.0s | 29.1s |
| Heavy Goods | 449.5 | 28.1s | 18.0s | 37.5s |
| Industrial | 549.5 | 34.3s | 22.0s | 45.8s |
| Secure | 649.5 | 40.6s | 26.0s | 54.1s |

From the operational freight crossing at Z=308 to the **front of Secure** is approximately **516 studs / 32.3 seconds at 16 studs/s**, fitting the M5A target for the deepest current section from the operational front.

An extreme load at the minimum ~9.5 studs/s would take about **68 seconds** from Secure center to a bay spawn in a straight-line estimate. This is a warning case: if normal deep loads spend most of the return at minimum speed, M5A may be too tedious and must be shortened/re-routed. Do not tune carry feel merely to hide a bad map.

## Route architecture

### Main freight route

- wide: 34 studs
- straight/smooth
- approximately 618 studs
- intended for giant unstable piles

### Service routes

- two side routes
- 18 studs wide
- approximately 607 studs
- slightly shorter than freight
- repeated small direction changes at section rhythm
- intended to be attractive while empty/light but less forgiving with unstable piles

### Cross-connections

- five major cross-aisles at section transitions
- one internal lateral connector through every section
- authored branches connect freight/service paths to storage pockets

The goal is that players can switch lane, change route, and react to warehouse state instead of following one mandatory corridor.

## Test A — top-down architecture

In Studio, use a high overhead camera and capture the whole playable warehouse.

PASS if:

- six sections read sequentially front-to-back
- freight route is obvious
- both service routes are visible
- cross-aisles genuinely connect the warehouse
- no giant unused playable void dominates the layout
- 12 bays still fit cleanly at the front

Send the screenshot to the project lead before M5B.

## Test B — section travel

From your assigned bay, run to each section using a sensible route.

Record actual approximate times to:

- Receiving
- Appliances
- Furniture
- Heavy Goods
- Industrial
- Secure

Test once at Level 1 Mobility and, if practical, once with upgraded Mobility.

PASS if:

- Receiving is quick
- Furniture/Heavy feel meaningfully deeper
- Industrial/Secure feel like a commitment
- the run still contains route/loot decisions rather than empty W-holding

## Test C — deep loaded return

Build a representative risky pile in Industrial or Secure and return to your bay.

Observe:

- total return time
- whether freight feels safer
- whether service route feels tempting but harder
- whether Load Pressure/Sway make the return tense
- whether the return becomes boring before it becomes tense

FAIL if ordinary deep returns routinely feel like 60–90 seconds of uneventful walking.

## Test D — route choice

Target the same general section three times:

1. main freight route
2. left service route / cross-aisle combination
3. right service route / alternate cross-aisle combination

PASS if all three are viable enough to consider.

FAIL if one exact straight path is obviously correct every time.

## Test E — section identity without signs

Temporarily ignore/hide section signage and walk the warehouse.

Ask whether graybox geometry alone roughly communicates:

- Receiving = open pallet/staging feel
- Appliances = boxed storage bays
- Furniture = broad oversized staging
- Heavy Goods = cages/heavy pads
- Industrial = machine/reinforced bays
- Secure = controlled cages/dividers

FAIL if every section feels like the same room with a different label.

## Test F — M4 regressions

Confirm briefly:

- Bay ownership/unload still works
- items are still server-authoritative
- M4.1 depletion/replenishment still works
- premium TV/Couch/Safe opportunity caps still work
- carrying/Sway/Load Pressure/collapse still feel unchanged
- SELL/KEEP/Stock still work

M5A must build on M4; it must not silently replace those systems.

## Test G — multiplayer architecture

With as many test clients as practical, look for:

- players spreading into different sections
- recurring encounters on freight/cross-aisles
- visible loaded players returning from deep sections
- no severe item starvation caused only by adding two sections
- acceptable server/client performance with the larger shell and 72–96 active-item target

A true 12-player result remains required before final M5 approval.

## Phase gate

Do NOT start M5B until the project lead reviews M5A.

Return/send:

1. overhead screenshot
2. actual Level 1 travel times
3. deep loaded return time + feel
4. preferred route(s)
5. whether any section feels empty/boring
6. whether section identities are readable without relying on signs
7. any collision/navigation problems
8. supply/carry regression notes

If M5A passes, only then proceed to M5B loot catalog + rarity.