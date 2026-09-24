# ONE TRIP — M6A.1 Shared Warehouse Runway Playtest

Option D is the current default graybox test layout. Option C is rejected for final direction but A/B/C remain recoverable until D passes runtime validation.

## Scope lock

M6A.1 changes map structure only. Do not rebalance prices, rarity odds/caps, handling, carrying, Stock, Collection, Mastery, Rare Finds, or upgrades during this gate unless a blocking integration bug is discovered.

## Selecting layouts

Before Play, set the Workspace attribute `M6LayoutMode`:

- `A` — old wide baseline
- `B` — previous long spine experiment
- `C` — rejected radial experiment
- `D` — Shared Warehouse Runway

If the attribute is absent/invalid, D is the default.

## Option D exact graybox dimensions

- Loot runway width: **176 studs**
- Loot runway length: **528 studs**
- Runway front Z: **256**
- Runway back Z: **-272**
- Six section depth: **88 studs each**
- Main shared freight aisle: **38 studs wide**
- Shallow storage paths: **14 studs wide**
- Cross aisles: **18 studs wide**
- Home / delivery apron: **380 × 150 studs**
- Home reference Z for travel estimates: **265**
- Warehouse mouth uses the full 176-stud runway width; there is no tiny doorway.

Section centers:

| Section | Center Z | Distance from home reference | ~16 stud/s | ~25 stud/s | ~12 stud/s loaded | ~9.5 stud/s loaded |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Receiving | 212 | 53 | 3.3s | 2.1s | 4.4s | 5.6s |
| Appliances | 124 | 141 | 8.8s | 5.6s | 11.8s | 14.8s |
| Furniture | 36 | 229 | 14.3s | 9.2s | 19.1s | 24.1s |
| HeavyGoods | -52 | 317 | 19.8s | 12.7s | 26.4s | 33.4s |
| Industrial | -140 | 405 | 25.3s | 16.2s | 33.8s | 42.6s |
| Secure | -228 | 493 | 30.8s | 19.7s | 41.1s | 51.9s |

Deep Secure markers extend roughly another 30 studs beyond section center, so the far meaningful opportunities are ~523 studs from the home reference (~32.7s at Starter 16 stud/s before pathing).

These are geometric estimates, not runtime pass results.

## Bay arrangement

All bays retain `Bay01`–`Bay12`, BayIndex, SpawnMarker, UnloadZone, ProcessingArea, StockSlots, owner label, van placeholder, and relative Stock/trophy geometry.

Every bay looks toward `(0, 0, 250)` — the communal departure / warehouse mouth.

Left cluster:

- Bay01: `(-130, 0, 360)`
- Bay02: `(-78, 0, 360)`
- Bay03: `(-130, 0, 320)`
- Bay04: `(-78, 0, 320)`
- Bay05: `(-130, 0, 280)`
- Bay06: `(-78, 0, 280)`

Right cluster:

- Bay07: `(78, 0, 360)`
- Bay08: `(130, 0, 360)`
- Bay09: `(78, 0, 320)`
- Bay10: `(130, 0, 320)`
- Bay11: `(78, 0, 280)`
- Bay12: `(130, 0, 280)`

This is six bays on the left and six on the right, compressed into 2-column × 3-row social clusters rather than a 500+ stud line.

## Spawn distribution

Every section has exactly **16** unique spawn markers, preserving the current full-server per-section capacity.

Per section:

- **4 shared focal / shared staging markers** near the central aisle/crossing sightline
- **12 regular storage markers** farther into left/right storage

Total Option D markers: **96**

Total shared focal/staging markers: **24**

Shared focal markers do not receive modified rarity odds. They use the same supply + rarity transform pipeline as every other marker.

Marker contract preserved:

- unique Name
- ItemId fallback
- ZoneName
- ZoneDepth
- SectorName
- SectionIndex
- SectionDisplayName
- OpportunityName
- OpportunityKind
- RestockSeconds

Exact SectorName values remain:

`Receiving`, `Appliances`, `Furniture`, `HeavyGoods`, `Industrial`, `Secure`.

## Route structure

- One 38-stud main freight aisle through all six sections.
- Two 14-stud shallow storage paths per section.
- One 18-stud section-center cross aisle per section for searching/convergence.
- Five additional 18-stud transition cross aisles at section boundaries.
- No parallel full-length alternate highways.
- No maze.
- Main aisle provides easier steering only; it has no mechanical safety/reset behavior.

## Section graybox identity

- Receiving: low pallet clusters; easiest/openest geometry.
- Appliances: organized appliance rows.
- Furniture: larger bulky staging footprints.
- HeavyGoods: equipment cages.
- Industrial: machine bays.
- Secure: controlled secure cells.

These are primitive structure tests only, not final art.

# REQUIRED RUNTIME GATE

## Test A — solo readability

1. Start fresh in Option D.
2. Leave assigned bay.
3. Run Receiving → Secure without a minimap.
4. Confirm farther/deeper direction is immediately obvious.
5. Confirm map feels dramatically less spread out than A/C.

Record actual home → section times.

## Test B — four players

Use 4 clients if available.

Pass if:

- players see each other frequently,
- players naturally reuse the same freight aisle,
- players occasionally target the same desirable cargo,
- ordinary cargo still feels available.

## Test C — 12-player simulation

Observe:

- apron crowding,
- warehouse mouth,
- Receiving,
- freight aisle,
- transition cross aisles,
- shared focal markers,
- Secure,
- delivery returns.

Fail if basic cargo starvation, camera chaos, or one-pad dogpiles dominate.

## Test D — same item race

Two players reach the same world item simultaneously.

Pass only if:

- exactly one server-confirmed winner,
- no ghost duplicate,
- no duplicate reward,
- no reservation deadlock,
- normal grab-distance rule remains enforced.

## Test E — visible high rarity

Studio only; do not change production rarity probabilities.

Example:

- `DevForceSection = Receiving`
- `DevForceRarity = Legendary` or `Mythic` / `Cosmic`
- `DevForceBaseItemId = OfficeChair`
- toggle `DevSpawnNow = true`

Try until the forced item occupies a useful visible opportunity. With multiple clients, see whether more than one player notices/responds.

## Test F — focal-marker camping

Consume a good item at a focal marker and wait there.

Pass if:

- it does not instantly replace itself,
- same item is not guaranteed,
- strong/high opportunities retain vacancy/scarcity,
- staying on one exact square is not obviously the best strategy.

## Test G — Starter to Secure

Starter stats; physically run to Secure.

Pass if:

- access is fully open,
- no progression wall exists,
- deep cargo still reports/behaves Dangerous or Unmanageable where appropriate,
- player understands that loot/handling is the gate.

## Test H — upgraded Secure return

Use a rig capable of extracting Secure cargo.

Measure:

- Secure → home unloaded,
- Secure → home with light valuable load,
- Secure → home with Dangerous pile,
- near-collapse return if practical.

Return must leave enough time for Load Pressure, Sway, instability, and collapse decisions to matter.

## Test I — ONE MORE

Load to Risky/Dangerous and begin returning.

At a cross aisle or shared focal sightline, see whether nearby cargo causes a genuine temptation to deviate deeper/across storage.

Fail if returning is always a thoughtless straight walk with no temptation.

## Test J — bays

For all 12 bays verify:

- assignment,
- SpawnMarker orientation,
- respawn facing communal departure,
- UnloadZone,
- ProcessingArea,
- SELL/KEEP flow,
- Stock slot indexes,
- physical Stock,
- trophy showcase,
- owner label readability.

## Test K — Collection regression

Deliver at least one item from each section.

Confirm:

- base discovery,
- Best Rarity,
- Section Mastery,
- Rare Finds,
- persisted trophies

remain section/item-data driven and unaffected by geometry.

## Test L — supply regression

Per section inspect:

- active count,
- target,
- depletion,
- vacancy,
- replenishment,
- correct transformed M5 catalog,
- hero section correctness,
- unique marker names,
- no dead markers.

Also verify Legendary/Mythic/Cosmic/Eternal caps and claim cooldown telemetry remain unchanged.

## Mobile check

Use a mobile-sized emulator viewport and test:

- leaving bays,
- warehouse mouth,
- main aisle with huge pile,
- entering/exiting storage paths,
- cross aisles,
- Secure return,
- finding own bay.

Fail if large piles + narrow map make camera navigation unusable.

# STATIC STATUS

Implemented/static checks:

- D is selectable and default.
- A/B/C remain recoverable.
- D uses exact existing section IDs/order.
- D remains physically open through Secure.
- no M5 economy/rarity/handling/Collection/Stock/supply code was rewritten for D.
- 96 unique D marker names are generated structurally (16 per section).
- 4/16 positions per section are tagged SharedFocal/SharedStaging; no rarity boost is attached to the tags.
- all bay components are built from the existing bay relative config.
- WarehouseAccessService only restores the old internal phase wall for A.

Runtime pending:

- true travel times,
- multiplayer contention,
- same-item race under latency,
- supply vacancy/restock behavior after play,
- rarity cap/cooldown behavior in live D session,
- handling return feel,
- ONE MORE psychology,
- bay/trophy/Stock reconnect behavior,
- mobile camera.

# PASS DECISION

Do **not** call M6A.1 passed from static inspection alone.

Default recommendation until runtime gate is completed: **NEEDS RUNTIME VALIDATION**.

If D passes, stop and get Prompter review before removing A/B/C or starting final M6 art/modeling.
