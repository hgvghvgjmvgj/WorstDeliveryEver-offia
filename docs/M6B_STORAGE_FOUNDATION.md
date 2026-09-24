# ONE TRIP — M6B STYLIZED STORAGE FOUNDATION

> **CORRECTION / CURRENT STATUS:** Do not propagate M6B art across all 15 sections yet. The active visual-quality proof is limited to Sections 1–3: Receiving & Returns, Home Basics, and Appliances. See `docs/M6B_SECTIONS_1_3_VISUAL_PROOF.md`.

## Locked visual rule

ONE TRIP is a stylized Roblox mega-warehouse, not a photoreal fulfillment center.

Visual priority:

**MODEL SHAPE > COLOR > LIGHTING > SIMPLE MATERIAL > TEXTURE**

Use chunky silhouettes, exaggerated supports, clean colors, SmoothPlastic/Metal/Glass and restrained Neon accents. Do not rely on grunge, dense PBR detail, realistic scratches or texture noise.

## Core warehouse read

The long shared runway remains:

- left storage/search area;
- wide main shared freight aisle;
- right storage/search area.

The central freight aisle stays clear for high-Speed traversal, giant carried piles, multiplayer visibility and social spectacle.

## Current proof scope

| # | Section | Current M6B department language | Primary read |
| ---: | --- | --- | --- |
| 1 | Receiving & Returns | pallet racks + package/sorting storage + intake staging | busy warehouse intake |
| 2 | Home Basics | low warm household shelving + open furniture pockets | familiar home goods storage |
| 3 | Appliances | tall reinforced appliance frames + wide machine bays | bigger, cleaner appliance storage |

Sections 4–15 intentionally remain graybox until the first-three-section screenshot gate passes.

## Current implementation

`M6BStorageService` now builds M6B storage only around the real ItemSpawns in Sections 1–3.

Every proof-section spawn opportunity keeps a visible platform/bay after its item is taken. An empty opportunity still reads as a place where cargo can return.

SharedFocal and SharedStaging positions receive a more visible aisle-edge treatment, but they have **no rarity guarantee or rarity bonus**.

`M6BRestockPresentationService` drives simple slot status feedback where M6B slots exist:

- empty slot: warm vacant indicator;
- occupied slot: section-accent indicator;
- new refill: short bright pulse before settling.

The supply and rarity algorithms remain authoritative and unchanged by this presentation layer.

## Rarity art foundation

Full-body Neon has been removed from high-tier cargo presentation.

The base object remains readable and desirable at Common.

- Common: polished normal object; no rarity kit.
- Uncommon: tiny quality badge/accent only.
- Rare: obvious upgraded trim.
- Epic: first meaningful silhouette additions.
- Legendary: premium structural frame/details.
- Mythic: stronger special construction + energy nodes.
- Cosmic: otherworldly containment/fin geometry + restrained particles.
- Eternal: clean white-gold prestige geometry + restrained ultimate effects.

This is a modular production foundation, not the final hero-quality item pass.

## Performance rules

- anchored environment;
- no PointLight on every storage slot;
- only two strategic department lights per proof section;
- no texture dependency;
- no unnecessary physics;
- storage stays outside the main freight corridor;
- StreamingEnabled compatibility remains a runtime verification target;
- repeated final families should migrate toward reusable MeshParts where that materially reduces instance cost.

## Do not continue to Section 4 yet

The pass condition is visual, not code-complete:

1. Receiving reads as warehouse intake without its sign.
2. Home Basics reads as home-goods storage without its sign.
3. Appliances reads as large appliance storage without its sign.
4. The main freight lane is obvious and usable at high Speed.
5. The Rig I checkpoint reads as an industrial security checkpoint, not a red wall.
6. Empty/restock positions remain understandable.
7. Representative cargo reads clearly at player height/mobile scale.
8. Screenshot A–D review passes.

Until then, continue iteration on Sections 1–3 only.
