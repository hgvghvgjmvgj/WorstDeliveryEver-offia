# ONE TRIP — M6A.2 15-Section Depth + Speed/Carry Proof

This is still structural graybox. Do not start final art from this file.

## Current launch-plan geometry

- Shared runway width: **176 studs**
- Playable progression depth: **1,317 studs**
- Main freight aisle: **38 studs**
- Shallow side storage paths: **14 studs**
- Cross aisles: **18 studs**
- Home reference Z: **265**
- Runway begins Z **256**, current Section 15 playable back Z **-1061**
- Non-playable future-facility continuation exists beyond Section 15; there is no visible gameplay-end wall.

## 15 sections

| # | ID | Display name | Length | Theme | Representative graybox cargo |
|---:|---|---|---:|---|---|
| 1 | Receiving | Receiving & Returns | 60 | ordinary intake | Shipping Box, Toolbox, Rolling Cart |
| 2 | HomeBasics | Home Basics | 60 | common household goods | Desk Lamp, Dining Chair, Kitchen Cart |
| 3 | Appliances | Appliances | 65 | desirable household machines | Refrigerator, Washer, Oven Range |
| 4 | Furniture | Furniture | 70 | bulky household cargo | Couch, Mattress, Wardrobe |
| 5 | Electronics | Electronics | 72 | modern tech | Gaming PC, Console Bundle, Display Wall Crate |
| 6 | Recreation | Recreation | 75 | expensive fun equipment | Arcade Cabinet, Treadmill, Foosball Table |
| 7 | GarageAuto | Garage & Auto | 80 | vehicle/workshop goods | Engine Crate, Wheel Set, Shop Compressor |
| 8 | Construction | Construction | 85 | job-site equipment | Concrete Mixer, Scaffold Bundle, Plate Compactor |
| 9 | HeavyGoods | Heavy Equipment | 90 | intimidating heavy cargo | Commercial Safe, Generator, Equipment Cart |
| 10 | Industrial | Industrial Machinery | 95 | major industrial hardware | Engine Block, Transformer, Production Machine |
| 11 | PremiumInteriors | Premium Interiors | 100 | designer living spaces | Luxury Sofa, Marble Table, Chandelier Crate |
| 12 | LuxuryGoods | Luxury Goods | 105 | fictional prestige/designer cargo | Fragrance Trunk, Watch Display, Royal Oud Cabinet |
| 13 | ArtCollectibles | Art & Collectibles | 110 | collector/museum cargo | Painting Crate, Sculpture, Rare Instrument Case |
| 14 | Secure | Secure Vault | 120 | extreme-value protected goods | Jewelry Safe, Executive Vault, Containment Unit |
| 15 | RestrictedPrototype | Restricted / Prototype Storage | 130 | strange experimental cargo | Power Core, Advanced Scanner, Engineered Artifact |

Old persistent IDs are deliberately retained at their new progression positions: `Receiving` #1, `Appliances` #3, `Furniture` #4, `HeavyGoods` #9, `Industrial` #10, `Secure` #14.

## Geometric home → section-center estimates

These are straight-line estimates before real pathing/load effects.

| # | Section | Distance | Speed 16 | Speed 29 | Speed 47 |
|---:|---|---:|---:|---:|---:|
| 1 | Receiving | 39 | 2.4s | 1.3s | 0.8s |
| 2 | Home Basics | 99 | 6.2s | 3.4s | 2.1s |
| 3 | Appliances | 161.5 | 10.1s | 5.6s | 3.4s |
| 4 | Furniture | 229 | 14.3s | 7.9s | 4.9s |
| 5 | Electronics | 300 | 18.8s | 10.3s | 6.4s |
| 6 | Recreation | 373.5 | 23.3s | 12.9s | 7.9s |
| 7 | Garage & Auto | 451 | 28.2s | 15.6s | 9.6s |
| 8 | Construction | 533.5 | 33.3s | 18.4s | 11.4s |
| 9 | Heavy Equipment | 621 | 38.8s | 21.4s | 13.2s |
| 10 | Industrial Machinery | 713.5 | 44.6s | 24.6s | 15.2s |
| 11 | Premium Interiors | 811 | 50.7s | 28.0s | 17.3s |
| 12 | Luxury Goods | 913.5 | 57.1s | 31.5s | 19.4s |
| 13 | Art & Collectibles | 1021 | 63.8s | 35.2s | 21.7s |
| 14 | Secure Vault | 1136 | 71.0s | 39.2s | 24.2s |
| 15 | Restricted / Prototype | 1261 | 78.8s | 43.5s | 26.8s |

Current full center round trip to Section 15 is ~157.6s at 16, ~87.0s at 29, and ~53.7s at 47 if unloaded and perfectly straight. Loaded return is intentionally slower.

## Mobility / player-facing Speed test curve

Internal save/config identity remains `Mobility` / `MobilityLevel` / `MobilityWalkSpeed`.

Current test levels:

`16 → 20 → 24 → 29 → 34 → 40 → 47`

Existing purchase costs remain unchanged during this proof so economy telemetry is comparable.

Studio command-bar shortcuts for one player, if needed for isolated motion tests:

```lua
game.Players:GetPlayers()[1]:SetAttribute("MobilityWalkSpeed", 16)
game.Players:GetPlayers()[1]:SetAttribute("MobilityWalkSpeed", 29)
game.Players:GetPlayers()[1]:SetAttribute("MobilityWalkSpeed", 47)
```

Control comparison:

```lua
game.Players:GetPlayers()[1]:SetAttribute("CarryControl", 1.00)
game.Players:GetPlayers()[1]:SetAttribute("CarryControl", 1.50)
game.Players:GetPlayers()[1]:SetAttribute("CarryControl", 2.05)
```

Reconnect or buy an upgrade normally after debug overrides if you need the persisted level value reapplied.

## High-speed handling model

The existing CarryService still owns Base Instability, Dynamic Sway, Load Pressure, recovery and collapse.

M6A.2 adds a sampled motion-event layer in HandlingRuntimeService:

- raw high velocity alone does **not** add a permanent instability tax;
- rapid acceleration creates a temporary Sway-generation/recovery penalty;
- large speed loss / hard braking creates a penalty;
- turn angle creates a penalty amplified by travel speed;
- 145°+ reversal is treated as a maximum turn event;
- Control reduces event severity;
- event severity decays quickly after the maneuver;
- after ~0.65s of consistent speed/direction the player is considered in stable cruise;
- stable cruise returns the motion event multipliers to neutral;
- Base Instability and Load Pressure never disappear because of cruise.

Useful live Player attributes:

- `MotionSpeed`
- `MotionAcceleration`
- `MotionTurnDegrees`
- `MotionEventSeverity`
- `MotionCruiseStable`
- `HandlingSwayMultiplier`
- `HandlingRecoveryMultiplier`
- `CarryStrain`
- `CarryBaseInstability`

## Supply/performance proof

Every section owns 16 possible world markers: 4 shared focal/staging + 12 storage.

The active supply target was reduced from 12→16 per section to **8 solo → 12 full-server** for M6A.2.

Expected maximum healthy full-server target across 15 sections is therefore about **180 active world cargo**, not 240. This still needs real server/client performance measurement.

Legendary/Mythic/Cosmic/Eternal global caps and claim cooldowns were not increased for the 15-section map.

## Old-save / Collection migration

The DataStore namespace is intentionally unchanged.

Expected old profile behavior:

- Cash survives.
- Strength / Carry Space / Control / Mobility / Stock Slot levels survive.
- Stock survives using saved item/rate/value metadata.
- Existing `Receiving`, `Appliances`, `Furniture`, `HeavyGoods`, `Industrial`, `Secure` discoveries survive.
- Existing Best Rarity values survive.
- Existing mastery/reward flags survive.
- Existing Rare Finds survive.
- Nine new section Collection entries begin empty.
- Trophy service can display up to 15 section trophies without consuming Stock slots.

# RUNTIME TEST ORDER

## 1 — Boot / structural smoke test

- Pull latest and run `rojo serve`.
- Start Option D.
- Confirm output says M6A.2.
- Confirm all 15 section signs appear in correct order.
- Confirm the warehouse endpoint is not visually obvious from home.
- Run physically to Section 15; no progression door/barrier should stop you.

## 2 — Catalog correctness

In at least five inserted sections, confirm spawned cargo transforms to that section's catalog rather than Receiving/legacy fallback cargo.

Useful force example:

```text
DevForceSection = LuxuryGoods
DevForceRarity = Mythic
DevForceBaseItemId = DesignerFragranceTrunk
DevSpawnNow = true
```

Then also test:

```text
DevForceSection = RestrictedPrototype
DevForceRarity = Eternal
DevForceBaseItemId = ZeroPointContainmentUnit
DevSpawnNow = true
```

## 3 — Full-run travel

Measure HOME → Section 15 and return at:

- Speed 16
- Speed 29
- Speed 47

Record actual times, camera comfort and whether holding W becomes boring.

## 4 — Smooth high-speed cruise

At Speed 47 with a LIGHT/RISKY pile:

1. accelerate onto the main freight aisle;
2. hold a straight direction for several seconds;
3. confirm `MotionCruiseStable = true`;
4. confirm movement-generated Sway settles instead of increasing forever;
5. confirm Load Pressure / Base Instability still remain where applicable.

## 5 — Turn ladder

With the same load and speed, test approximately:

- 30° turn
- 60° turn
- 90° sharp turn
- 180° reversal

`MotionTurnDegrees` and `MotionEventSeverity` should rise with severity, and the pile reaction should become increasingly risky.

## 6 — Hard brake vs smooth brake

At high speed:

- panic stop;
- repeat but slow down gradually.

Hard braking should create a clearly stronger event.

## 7 — Control comparison

Repeat the 90° turn / hard brake at Control 1.00, 1.50 and 2.05.

Higher Control should reduce, not eliminate, event severity.

## 8 — Dangerous load

Use a Dangerous/near-collapse pile at high Mobility.

Pass only if:

- effective speed is suppressed;
- Speed still has some value;
- sharp inputs remain dangerous;
- stable cruise does not erase Load Pressure;
- collapse/DITCH choices still matter.

## 9 — Multiplayer competition

Use 4+ clients if possible in the same progression band.

Observe shared focal points/cross aisles. Fifteen sections must not make everyone invisible to one another.

## 10 — Supply/performance

Inspect world telemetry with all 15 sectors alive:

- total active items;
- active/target per sector;
- vacancy/replenishment;
- high-tier cap telemetry;
- rough server/client performance;
- mobile frame/camera feel.

## 11 — Collection old-save regression

Load a profile that already had M5C progress. Open Collection and verify the old six sections plus nine new tabs. Deliver at least one new-section object and reconnect.

## 12 — Trophy / Stock / bay regression

Verify assigned bay, unload, SELL/KEEP, physical Stock, passive income, Manage Stock, old trophies, and any newly earned trophy remain correct.

# STATIC STATUS

Implemented:

- 15-section centralized progression registry.
- 1,317-stud variable-depth runway.
- section endpoint continuation after #15.
- 15-section catalog generation.
- 144 core + 15 hero base objects.
- six persistent section IDs preserved.
- Collection sanitizer automatically supports all 15 sections.
- 15-trophy placeholder showcase support.
- Mobility/Speed 16→47 test curve.
- event-driven acceleration/brake/turn/reversal handling layer.
- stable-cruise detection.
- Control reduction of high-speed motion events.
- reduced 15-section supply target.
- no increase to production rarity weights/caps.

Runtime pending:

- actual full-run times;
- high-speed feel;
- camera/mobile;
- 12-player performance;
- live supply stability;
- multiplayer contention;
- old-save reconnect;
- economy pacing exposed by the deeper world.

# CURRENT RECOMMENDATION

**NEEDS RUNTIME VALIDATION.**

Do not lock geometry or start final art until the tests above pass and the Prompter/user reviews the result.
