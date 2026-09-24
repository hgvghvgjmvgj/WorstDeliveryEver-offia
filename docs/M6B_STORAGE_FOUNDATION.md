# ONE TRIP — M6B STYLIZED STORAGE FOUNDATION

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

## Section storage language

| # | Section | M6B storage family | Primary read |
| ---: | --- | --- | --- |
| 1 | Receiving & Returns | PalletRack | pallet racks, package cages, staging |
| 2 | Home Basics | HomeShelf | warmer household shelving |
| 3 | Appliances | ApplianceBay | wide appliance slots and machine bays |
| 4 | Furniture | FurnitureBay | open furniture platforms/pockets |
| 5 | Electronics | TechShelf | clean organized tech shelves |
| 6 | Recreation | RecreationBay | playful varied product bays |
| 7 | Garage & Auto | GarageRack | tool/tire/workshop storage |
| 8 | Construction | ConstructionRack | reinforced job-site rack language |
| 9 | Heavy Equipment | HeavyPad | oversized staging pads and frames |
| 10 | Industrial Machinery | IndustrialCell | tall machinery cells / gantry language |
| 11 | Premium Interiors | PremiumBay | cleaner protected premium storage |
| 12 | Luxury Goods | LuxuryCabinet | dark premium cabinets / glass / gold trim |
| 13 | Art & Collectibles | GalleryStorage | museum-backroom frames and pedestals |
| 14 | Secure Vault | SecureCell | armored cells / security storage |
| 15 | Restricted / Prototype | ContainmentFrame | advanced containment/docking frames |

The storage structure itself must communicate that the player entered a different section.

## Current implementation

`M6BStorageService` removes the old generic M6A storage blocks in Option D and builds storage modules around the real ItemSpawns.

Every spawn opportunity keeps a visible platform/bay after its item is taken. Therefore an empty opportunity still reads as a place where cargo can return.

SharedFocal and SharedStaging positions receive a more visible aisle-edge treatment, but they have **no rarity guarantee or rarity bonus**.

`M6BRestockPresentationService` drives simple slot status feedback:

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
- Cosmic: otherworldly containment/fin geometry + very restrained particles.
- Eternal: clean white-gold prestige geometry + restrained ultimate effects.

This is a modular production foundation, not the final hero-quality item pass.

## Performance rules

- anchored environment;
- no per-slot PointLights;
- no texture dependency;
- roughly <= 9 simple environment primitives per opportunity in this first pass;
- no unnecessary physics;
- storage stays outside the main freight corridor;
- StreamingEnabled compatibility remains a later runtime verification target;
- final repeated rack families should migrate toward reusable MeshParts where that materially reduces instance cost.

## Not complete yet

This first M6B slice is not final art. Still pending:

- final section architecture silhouettes and landmarks;
- final ceiling/beam system;
- proper modular MeshPart rack kits;
- final lighting/atmospheric depth;
- final cargo base models;
- hero cargo redesigns;
- richer rarity-specific geometry by ModelKind;
- rarity animation;
- final audio;
- polished restock mechanical animation/sound;
- mobile/performance optimization pass;
- bay/home visual pass;
- trophy visual pass;
- Collection UI visual polish.

## Runtime gate for this slice

Before increasing visual density, verify in Studio:

1. Stand at home and confirm the freight aisle is still immediately readable.
2. Sprint through Receiving/Electronics/Industrial at high Speed; storage must not make the route confusing.
3. Carry a large Wide pile through storage/search paths; no accidental trapping or camera disaster.
4. Walk Sections 1–15 and judge whether storage family changes are visible without reading signs.
5. Take cargo and verify the empty slot remains visually obvious.
6. Wait for a restock and verify the status-light pulse makes the new arrival noticeable without giant UI.
7. Force a Legendary+ into a visible focal opportunity and confirm multiple nearby players could notice it.
8. Confirm focal opportunities are still capable of spawning ordinary Common cargo.
9. Test two+ players searching opposite sides of the same section; partial sightlines should remain.
10. Mobile-emulate the narrowest search spaces.
11. Inspect instance/performance cost before adding decorative density.
12. Compare Common through Eternal versions of one object; rarity should increasingly change geometry, not only color.

Do not interpret this first procedural module pass as final modeling quality. It exists to lock composition, storage language, spawn presentation and rarity-art architecture before expensive asset production.
