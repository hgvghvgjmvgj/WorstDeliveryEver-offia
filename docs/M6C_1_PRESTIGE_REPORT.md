# ONE TRIP — M6C.1 AURA + PRESTIGE POLISH REPORT

## Status
Implemented as a new final visual layer on top of M6C. Final M6 polish remains blocked pending Studio/mobile/mixed-pile review.

## Global changes
- Added `M6C1PrestigeService` after M6C base art + identity.
- Common: no aura or prestige effects.
- Uncommon: remains intentionally close to Common.
- Rare: first subtle occluded Highlight aura.
- Epic: stronger aura + faint under-object aura plate + additional silhouette shoulders.
- Legendary: premium aura, very low-rate sparks, crown rail/crest, item-aware premium structure.
- Mythic: stronger aura, low-rate energy sparks, suspended-looking nodes/spine.
- Cosmic: strong controlled aura, containment/orbit geometry, low-rate space-like particles, restrained PointLight.
- Eternal: strongest clean aura, white-gold/prismatic final-form frame, restrained particles + PointLight.

## Performance discipline
The aura layer intentionally avoids brute force.
- Common/Uncommon create no aura emitters/lights.
- Rare creates Highlight only.
- Epic adds Highlight + one faint geometry plate.
- Legendary/Mythic add one low-rate ParticleEmitter.
- Cosmic/Eternal are the only M6C.1 tiers that add a PointLight.
- All geometry is welded, Massless, CanCollide=false, CanTouch=false, CanQuery=false.

Runtime telemetry is exposed on `Workspace.OneTripPrototype`:
- `M6C1PrestigeEnabled`
- `M6C1AppliedInstances`
- `M6C1AuraCount`
- `M6C1ParticleEmitterCount`
- `M6C1PointLightCount`

## Priority base-item identity polish
M6C.1 adds additional recognition/detail to the priority categories where procedural bases could still read too generically.

### Appliances
- Refrigerator / Mini Fridge / Prototype Smart Fridge: clearer door split, kick plate, dispenser/display treatment.
- Washer / Dryer: dial + lower panel treatment.
- Microwave / Countertop Oven: dark front glass + controls.
- Oven Range: oven glass + knob row.

### Furniture
- Couch / Sectional / Luxury Sofa: stronger back-pillow silhouettes.
- Office Chair: center post + caster-arm language.
- Dining/Designer Chairs: clearer back inset.
- Mattress: edge piping.
- Coffee/Dining/Marble Tables: distinct top inset/material treatment.

### Electronics / Recreation
- Gaming PC: glass side, visible fans, GPU accent.
- Television / Gaming Monitor: clearer display panel.
- Arcade Cabinet: marquee, control deck, joystick.

### Garage / Industrial
- Engine family: headers + top intake.
- Compressor / pump / hydraulic family: tank + motor structure.

### Luxury / Fragrance
- Fragrance/parfum/oud/perfumer items: premium inner frame + visible bottle set and caps.

### Secure
- Safe/vault family: locking wheel, spokes, keypad.

### Restricted
- Restricted prototypes: visible contained energy focus + containment rails.

## Rarity behavior
| Tier | M6C.1 presence |
| --- | --- |
| Common | Normal polished object; no aura. |
| Uncommon | Close to normal; no global aura. |
| Rare | Subtle colored occluded outline/fill. |
| Epic | Clear aura + faint base plate + extra silhouette structure. |
| Legendary | Premium aura + low-rate sparks + premium frame/crest. |
| Mythic | Strong aura + energy nodes + more unusual structure. |
| Cosmic | Otherworldly aura + containment frames + controlled particles/light. |
| Eternal | Cleanest/brightest prestige aura + white-gold final-form frame + prismatic focus. |

## Studio proof set
Use the existing M6C gallery. Before Play:
```lua
workspace:SetAttribute("M6CBuildRarityGallery", true)
workspace:SetAttribute("M6CGalleryBaseItemId", "Refrigerator")
```
Restart Play after changing the BaseItemId.

Required cross-category checks:
- Refrigerator
- Couch
- GamingPC
- ArcadeCabinet
- ShowCarEngine
- DesignerFragranceTrunk
- JewelrySafe
- ExperimentalPowerCore
- BlackProjectContainmentUnit

Disable afterward:
```lua
workspace:SetAttribute("M6CBuildRarityGallery", false)
```

## Mixed-pile test
Create real carried stacks at 6 / 8 / 10 / 12 items with mixed rarities.

Pass if:
- special items remain visible;
- the base objects remain recognizable;
- aura does not merge into visual soup;
- Cosmic/Eternal feel exciting without hiding nearby cargo;
- mobile camera remains readable.

## Known review risks
1. `Highlight` presence may need device-specific transparency tuning after mobile testing.
2. Epic aura plate may need smaller diameter on very wide furniture/industrial objects.
3. M6C already supplies some high-tier geometry, so a few Eternal/Cosmic objects may become too busy when M6C.1 is layered on top; inspect the full cross-category set before increasing effects further.
4. Some hero assets still deserve real custom mesh/Blender replacement rather than additional procedural attachments.
5. Mixed piles are the real truth test; isolated gallery shots are not sufficient.

## Remaining custom-mesh / Blender priorities
Highest-value candidates remain:
- Royal Grand Piano
- Show Car Engine
- Cosmic / Experimental Reactor Core
- Black-Project Containment Unit
- Zero-Point Containment Unit
- Creator Command Center
- Deluxe Arcade Pod
- Titan Vault Safe

## Stop condition
Do not move into final M6 polish automatically. Review cross-category galleries, real carried mixed piles, mobile readability and performance first.
