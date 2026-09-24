# ONE TRIP — M6C.1 AURA + PRESTIGE POLISH REPORT

## Status
Implemented as layered visual-only services on top of M6C. Final M6 polish remains blocked pending Studio/mobile/mixed-pile review.

## Latest correction after screenshot review
The first M6C.1 aura pass was rejected because it read as a flat showroom halo/outline rather than the stronger Roblox aura language requested.

The corrected pass now adds:
- segmented ground sigils/rune rings;
- curved energy arcs;
- rising energy lines;
- stronger vertical energy presence for Mythic+;
- Cosmic orbit arcs;
- controlled energy wisps/sparks;
- PointLights only on Cosmic/Eternal.

The old `Highlight` + flat `AuraPlate` presentation is removed by the final aura layer.

## Rarity aura behavior
| Tier | Final M6C.1 aura language |
| --- | --- |
| Common | No aura. |
| Uncommon | No global aura; remains almost normal. |
| Rare | Small segmented ground ring only. |
| Epic | Clear double sigil/rune ground presence. |
| Legendary | Ground sigil + curved energy arcs + rising energy + restrained wisps. |
| Mythic | Stronger sigil + side energy shell + more rising energy + sparks. |
| Cosmic | Containment/orbit aura + rising energy + stars/wisps + subtle light. |
| Eternal | White-gold/prismatic final-form sigil + strongest controlled arcs/rays + subtle light. |

This remains intentionally lighter than simulator-style particle spam. Item silhouette is still the first read.

## Base-model corrections after screenshot review
### Couch
The procedural couch was rejected. `M6C1ModelCorrectionService` now hides its generic physics-root visual and builds a readable sofa around the same invisible authoritative root:
- low seat base;
- tall angled back;
- thick arms;
- three separate seat cushions;
- three separate back cushions;
- visible feet;
- rarity trim at Epic+.

### Gaming PC
The old version read as a generic tech cabinet. It now uses the same invisible authoritative root with a clearer gaming-PC visual:
- dark tower chassis;
- glass side panel;
- motherboard/GPU/PSU structure;
- three front intake fans;
- top vent;
- feet;
- rarity-colored IO/fan lighting.

Both remain Massless/CanCollide=false visual geometry. Carry physics, Weight, Bulk, economy and rarity selection are unchanged.

## Multi-row Studio gallery
The old one-item-at-a-time gallery was too slow for review.

Default behavior now shows this proof set as simultaneous rows:
- Refrigerator
- Couch
- GamingPC
- ArcadeCabinet
- ShowCarEngine
- DesignerFragranceTrunk
- JewelrySafe
- BlackProjectContainmentUnit

Before Play:
```lua
workspace:SetAttribute("M6CBuildRarityGallery", true)
```

The default `M6CGalleryMode` is `PROOF`, so no BaseItemId swapping is required.

Single-item mode remains available:
```lua
workspace:SetAttribute("M6CGalleryMode", "SINGLE")
workspace:SetAttribute("M6CGalleryBaseItemId", "Refrigerator")
```

Custom multiple rows:
```lua
workspace:SetAttribute("M6CGalleryBaseItemIds", "Refrigerator,Couch,GamingPC,JewelrySafe")
```

Optional spacing/origin:
```lua
workspace:SetAttribute("M6CGalleryRowSpacing", 18)
workspace:SetAttribute("M6CGalleryOrigin", Vector3.new(0,4.5,470))
```

Disable afterward:
```lua
workspace:SetAttribute("M6CBuildRarityGallery", false)
```

## Runtime telemetry
Under `Workspace.OneTripPrototype`:
- `M6C1ModelCorrectionsApplied`
- `M6C1EnergyAuraEnabled`
- `M6C1EnergyAuraApplied`
- `M6C1EnergyBeamCount`
- `M6C1EnergyParticleEmitterCount`
- `M6C1EnergyPointLightCount`
- `M6CGalleryRowCount`
- `M6CGalleryMode`

## Performance discipline
- Common/Uncommon: no aura instances.
- Rare: geometry-only small ring.
- Epic: geometry/beam presence, no heavy particle stack.
- Legendary/Mythic: low-rate energy emitters.
- Cosmic/Eternal: only tiers receiving M6C.1 PointLights.
- All aura geometry is visual-only, welded, Massless, non-colliding, non-querying.

## Meshy status
Meshy was explicitly requested for weak custom assets. The Meshy skill was loaded, but this execution environment cannot currently install/run the required Meshy CLI because the npm fallback times out. No fake Meshy output was claimed. The item architecture keeps stable BaseItemIds and invisible physics roots so later Meshy/custom meshes can replace Couch/PC/hero visuals without changing gameplay data.

## Remaining custom-mesh / Blender / Meshy priorities
Highest-value candidates remain:
- Royal Grand Piano
- Show Car Engine
- Cosmic / Experimental Reactor Core
- Black-Project Containment Unit
- Zero-Point Containment Unit
- Creator Command Center
- Deluxe Arcade Pod
- Titan Vault Safe

If Meshy becomes available, Couch and Gaming PC may also be compared against the Studio-native corrections before deciding whether a mesh replacement is worthwhile.

## Stop condition
Do not move into final M6 polish automatically. Review the multi-row proof gallery, real mixed-rarity 6/8/10/12-item piles, mobile readability and runtime effect counts first.
