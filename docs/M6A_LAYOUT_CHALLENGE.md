# ONE TRIP — M6A MACRO LAYOUT CHALLENGE

Status: IMPLEMENTED FOR RUNTIME COMPARISON. FINAL LAYOUT NOT LOCKED.

M6A is a geometry/feel test only. Do not use this phase to judge final art, final models, final lighting, or final rarity VFX.

## Switching layouts in Studio

The M6 builder reads the `Workspace` String attribute `M6LayoutMode` when Play starts.

While NOT in Play mode, use the Command Bar:

```lua
workspace:SetAttribute("M6LayoutMode", "A")
```

or:

```lua
workspace:SetAttribute("M6LayoutMode", "B")
```

or:

```lua
workspace:SetAttribute("M6LayoutMode", "C")
```

Then start Play. If the attribute is absent/invalid, M6A defaults to **C**.

The active prototype root publishes:

- `M6A_Mode`
- `M6A_LayoutName`
- `M6A_TestStatus`
- candidate dimensions
- section distance estimates

under `Workspace > OneTripPrototype`.

---

# OPTION A — CURRENT WIDE WAREHOUSE

This is the exact M5A baseline, preserved through the old `WorldService`.

Approximate footprint:

- 700 studs wide
- 900 studs long
- six sequential 90-stud sections
- long central freight path
- left/right service paths
- front row of 12 bays

Prior observed playtest:

- about 40 seconds to reach Secure from the player's starting area
- macro distance felt meaningfully long
- major weakness: early sections visually/spatially blended together and the facility felt too wide/spread out

Overhead concept:

```text
[BAY][BAY][BAY][BAY][BAY][BAY][BAY][BAY][BAY][BAY][BAY][BAY]
===================== DISPATCH =====================

 SVC      |            FREIGHT            |      SVC
          |                                |
----------+--------- RECEIVING ------------+----------
          |                                |
----------+-------- APPLIANCES ------------+----------
          |                                |
----------+--------- FURNITURE ------------+----------
          |                                |
----------+----------- HEAVY --------------+----------
          |                                |
----------+--------- INDUSTRIAL -----------+----------
          |                                |
----------+----------- SECURE -------------+----------
```

Purpose in M6A: fair baseline, not a strawman.

---

# OPTION B — LONG PROGRESSION SPINE

Implemented footprint:

- 520 × 900 studs
- 36-stud central freight spine
- 17-stud left/right service routes
- six 80-stud-deep sections
- ~450-stud usable section width
- 16 item opportunities per section
- 12 bays at the front hub

Overhead concept:

```text
[BAYS + SOCIAL / DELIVERY]
           |
     ===== FREIGHT =====
    /        |         \
  SVC     RECEIVING     SVC
    \        |         /
     ---- APPLIANCES ----
    /        |         \
  SVC     FURNITURE     SVC
    \        |         /
     ------- HEAVY -------
    /        |         \
  SVC     INDUSTRIAL    SVC
    \        |         /
     ------- SECURE -------
```

Static straight-line center distances from dispatch:

| Section | Studs | ~16 studs/s | ~25 studs/s |
|---|---:|---:|---:|
| Receiving | 111 | 6.9s | 4.4s |
| Appliances | 201 | 12.6s | 8.0s |
| Furniture | 291 | 18.2s | 11.6s |
| Heavy | 381 | 23.8s | 15.2s |
| Industrial | 471 | 29.4s | 18.8s |
| Secure | 561 | 35.1s | 22.4s |

These are NOT runtime measurements. Turns, bay spawn position, cargo detours and loading change real times.

Intended strengths:

- strongest linear progression readability
- less lateral dead space than A
- immediately understandable "deeper = farther"
- freight versus service route choice stays easy to read
- easy future extension behind Secure

Main risk:

- can become a dressed-up hallway if local storage/search spaces fail to create enough greed decisions
- return path may feel repetitive because home is always in one obvious direction

---

# OPTION C — POLYGONAL CONCENTRIC WAREHOUSE

This is the strongest experimental candidate.

Implemented structure:

- approximately 1040 × 1040 graybox footprint
- 118-stud-radius central home/social hub
- 12 bays arranged around a 94-stud bay radius
- six outward progression rings
- 16-sided polygonal ring construction
- four major 38-stud freight spokes
- four 15-stud diagonal service cuts
- short storage arcs around freight junctions
- 16 item opportunities per section
- section geometry changes by ring
- four future outer expansion points

Concept:

```text
                    [ SECURE ]
             [ INDUSTRIAL RING ]
          [   HEAVY GOODS RING   ]
       [      FURNITURE RING       ]
    [       APPLIANCES RING          ]
 [          RECEIVING RING             ]

               \     |     /
                \    |    /
          ====== CENTRAL ======
          ===== HOME HUB ======
                /    |    \
               /     |     \

      12 bays / Stock / trophies / delivery

Major freight spokes: N / E / S / W
Service cuts: diagonals between them
Progression: OUTWARD, never pizza slices.
```

Ring dimensions:

| Section | Inner radius | Outer radius | Center | ~16 studs/s | ~25 studs/s |
|---|---:|---:|---:|---:|---:|
| Receiving | 132 | 176 | 154 | 9.6s | 6.2s |
| Appliances | 186 | 234 | 210 | 13.1s | 8.4s |
| Furniture | 244 | 302 | 273 | 17.1s | 10.9s |
| Heavy | 312 | 362 | 337 | 21.1s | 13.5s |
| Industrial | 372 | 430 | 401 | 25.1s | 16.0s |
| Secure | 440 | 500 | 470 | 29.4s | 18.8s |

Again: these are radial-distance estimates, NOT runtime travel times.

Intended strengths:

- home is always conceptually inward
- progression reads as farther from home = more advanced
- four freight spokes create repeated social convergence
- dangerous loaded returns naturally aim toward a visible center
- Stock/trophies/bays become a shared social spectacle
- storage arcs can place temptation directly beside a return artery
- future expansion can add another outer ring or specialized annex

Main risks to test:

- ring circumference can create pointless lateral walking if players ignore junction clusters
- 12 bays can make the center visually noisy
- radial camera/navigation may be worse on mobile
- service cuts may be either genuinely useful or visually confusing
- large outer-ring cargo must not make the ring feel empty between junctions

---

# SECTION GRAYBOX IDENTITY

Both new candidates preserve the exact six section IDs. Their primitive geometry intentionally differs before art:

- **Receiving** — low pallet/staging masses, approachable/open
- **Appliances** — taller rectangular storage rows
- **Furniture** — broad low staging areas and bulky footprints
- **Heavy Goods** — equipment cages and more serious obstruction
- **Industrial** — taller machine-bay masses
- **Secure** — vault/cell-like graybox structures

Final materials/models/lighting are NOT part of M6A.

---

# SYSTEM COMPATIBILITY

A/B/C preserve:

- exact section IDs
- 16 authored item opportunities per section in B/C
- `SectorName`, `ZoneDepth`, `SectionIndex`, `SectionDisplayName` marker metadata
- existing central ItemService supply controller
- M5B rarity transformation
- rarity global caps/cooldowns
- open physical access
- handling-based loot gating
- current 12-bay contract
- delivery zones
- Stock slots
- mastery trophy bay placement
- Collection/Mastery/Rare Finds
- Carry/Sway/Load Pressure/collapse/DITCH

No M6A code changes rarity odds, economy values, item handling requirements, Collection data, or progression stats.

---

# PLAYTEST ORDER

Do not compare the candidates from memory hours apart. Use the same routine for all three.

## PASS 1 — EMPTY TRAVEL

For each mode:

1. Fresh spawn.
2. Run directly to Receiving, Appliances, Furniture, Heavy, Industrial, Secure.
3. Record rough times.
4. Ask whether deeper/better is obvious WITHOUT reading every sign.
5. Note any stretches where you are just holding W with nothing to think about.

## PASS 2 — LOADED RETURN

For each mode:

1. Build a light pile and return.
2. Build a medium pile and return.
3. Build a clearly Dangerous pile and return.
4. Use the smooth freight route once.
5. Use a service/shortcut route once.

Record whether route choice changes carrying difficulty in a fair way.

## PASS 3 — ONE MORE TEST

This matters more than raw travel time.

1. Load up until the pile is clearly risky.
2. Start heading home.
3. At the first reasonable return junction, LOOK for nearby cargo.
4. Ask: "Do I genuinely want to risk one more?"

If the geometry rarely creates that thought, the candidate is failing the core fantasy.

## PASS 4 — FRESH PLAYER SECURE

Run straight to Secure as Starter.

Successful layout feeling:

> I am not ready for this, but I want to be.

Failure:

> This is just the same warehouse farther away.

## PASS 5 — ADVANCED EARLY-SECTION RETURN

With upgrades, revisit Receiving/Appliances.

Check whether old sections remain fast and convenient for:

- Collection gaps
- Best Rarity chasing
- Rare Finds
- mastery

## PASS 6 — MULTIPLAYER

With several clients, watch:

- home hub / bays
- first section
- freight intersections
- rare cargo
- overloaded players returning

Do players naturally see each other without becoming crowded?

## PASS 7 — MOBILE

At mobile viewport size, test:

- huge carried pile
- section transitions
- service route
- freight route
- return-home orientation
- bay delivery

If basic navigation needs a minimap, mark the layout down.

---

# EVALUATION MATRIX

Score each from 1–10 only after actually playing it.

| Criterion | A | B | C |
|---|---:|---:|---:|
| 1. Progression readability | | | |
| 2. Core carry fantasy | | | |
| 3. Greed / "one more" decisions | | | |
| 4. Loaded return tension | | | |
| 5. Low travel boredom | | | |
| 6. Social convergence | | | |
| 7. Section identity | | | |
| 8. Rarity visibility | | | |
| 9. Route choice | | | |
| 10. Mobile usability | | | |
| 11. 12-player congestion | | | |
| 12. Expansion potential | | | |
| 13. Art-production practicality | | | |
| 14. Roblox/mobile performance | | | |
| 15. ONE TRIP identity | | | |

Do NOT fill this by aesthetic preference alone.

---

# STATIC PRE-PLAY EXPECTATION — NOT FINAL RESULT

Option A remains the baseline with known width/readability problems.

Option B is expected to win pure progression clarity and production simplicity, but risks repetitive out-and-back traversal.

Option C is expected to be strongest for home orientation, social spectacle, repeated return decisions and ONE TRIP identity, but has the highest navigation/congestion risk and therefore MUST earn the win in runtime testing.

No final layout is locked until A/B/C have been played.

---

# M6A STOP CONDITION

After comparison, choose ONE layout or one precisely-described hybrid.

Then STOP.

Do not begin:

- detailed environment art
- final item models
- final materials
- final lighting
- final rarity VFX/audio
- polished trophy art

until Prompter review approves the macro geometry.
