# ONE TRIP — M6C PRODUCTION REPRESENTATIVE BATCH REPORT

## Status

**IMPLEMENTED / RUNTIME VISUAL REVIEW REQUIRED**

This is the required M6C production checkpoint. Do not mass-produce the rest of the catalog or move into final M6 polish until this 11-item batch is approved in Roblox Studio.

## Representative batch

| # | BaseItemId | Category | Current checkpoint source | Long-term note |
|---:|---|---|---|---|
| 1 | ShippingBox | early crate | Model Builder-style Studio recipe | Studio final candidate |
| 2 | Refrigerator | appliance | Model Builder-style Studio recipe | Studio final candidate |
| 3 | Couch | furniture | Model Builder-style Studio recipe | Studio final candidate after visual review |
| 4 | GamingPC | electronics | Model Builder-style Studio recipe | Studio final candidate after visual review |
| 5 | ArcadeCabinet | recreation | Model Builder-style Studio recipe | Studio/custom mesh only if silhouette still weak |
| 6 | ShowCarEngine | auto hero | Model Builder-style hero proof | Blender/custom mesh remains likely |
| 7 | EngineBlock | industrial | Model Builder-style Studio recipe | Studio final candidate |
| 8 | DesignerFragranceTrunk | luxury | Model Builder-style Studio recipe | Studio final candidate / important family proof |
| 9 | PaintingTransportCrate | art | Model Builder-style Studio recipe | Studio final candidate |
| 10 | JewelrySafe | secure | Model Builder-style Studio recipe | Studio final candidate |
| 11 | BlackProjectContainmentUnit | restricted hero | Model Builder-style hero proof | Blender/custom mesh remains likely |

Runtime recipes live in:

`src/shared/Config/M6CProductionBatchConfig.lua`

The ONE TRIP Model Builder now ships built-in Refrigerator, Couch, Gaming PC, and Fragrance Trunk examples that use the same production language.

## Visual authority

The checkpoint deliberately disables the rejected generic M6C/M6C.1 art, model-correction, prestige, and old energy-aura runtime layers.

For the 11 proof items the visual stack is now:

1. existing authoritative item root / gameplay data;
2. `M6CProductionBatchService` final proof model;
3. family-aware rarity geometry;
4. `M6CProfessionalVFXService` layered rarity VFX.

Non-batch items remain on the existing `LootPresentationService` fallback until this checkpoint passes. This prevents mass-producing an unproven art/VFX system.

## Base-model philosophy

Common models are designed to read without rarity effects:

- Shipping Box: recognizable taped shipping carton + label.
- Refrigerator: split doors, long handles, display, kick plate.
- Couch: real sofa silhouette with frame, arms, separate seat/back cushions and feet.
- Gaming PC: tower chassis, glass side, three front fans, motherboard, GPU, PSU and top vent.
- Arcade Cabinet: marquee, screen, control deck, joystick/buttons.
- Show-Car Engine: V-engine-like block/head silhouette, intake, air stack, pulleys, valve covers.
- Engine Block: industrial engine block/head/shaft/pipes/status panel.
- Designer Fragrance Trunk: hard case, glass display, chunky clasps, oversized visible bottles.
- Painting Transport Crate: transport frame, cross braces, museum label panel.
- Jewelry Safe: thick safe door, locking wheel/spokes, keypad/status.
- Black-Project Containment Unit: heavy containment frame, suspended core, four stabilizers and warning panel.

All visual geometry is welded/massless/non-colliding. Gameplay remains on the existing authoritative item root.

## Rarity geometry hierarchy

- Common — polished normal object; no rarity geometry.
- Uncommon — tiny quality badge only.
- Rare — restrained upgraded trim.
- Epic — family-aware silhouette modules begin.
- Legendary — obvious premium crown/base/frame redesign.
- Mythic — suspended-looking nodes / special spine construction.
- Cosmic — containment/orbit hardware integrated into the object.
- Eternal — clean white-gold/pearl final-form pieces; not simply more Cosmic clutter.

Family-aware Epic+ geometry differs for furniture, appliances/tech, machinery, luxury, art, secure, and prototype cargo.

# Professional VFX

## SINE VFX STATUS

# NOT PROGRAMMATICALLY ACCESSIBLE

Repository and Model Builder inspection found no callable/documented Sine ModuleScript/API or reusable Sine asset library available to this development environment.

No undocumented Sine API is invented.

The native checkpoint VFX uses the standardized attachments:

- `VFX_Core`
- `VFX_Top`
- `VFX_Left`
- `VFX_Right`
- `VFX_Front`

A future Sine-authored texture, mesh, beam or preset can replace native effect layers on these anchors without changing cargo IDs, gameplay or rarity data.

## Current tier behavior

### Common
No VFX.

### Uncommon
No continuous VFX.

### Rare
Very occasional tiny glint only.

### Epic
First small composition:
- subtle Beam accent;
- tiny intermittent glints.

### Legendary
First major effect tier:
- short spawn burst;
- two curved halo Beams;
- low-rate premium sparks.

### Mythic
Legendary foundation plus:
- side-to-top energy arcs;
- low-rate rising wisps;
- restrained light pulse.

### Cosmic
Major layered composition:
- short reveal burst;
- two animated 3D Beam rings;
- controlled star drift;
- restrained point light;
- slower idle state after reveal.

### Eternal
Cleaner prestige rather than higher particle density:
- white-gold/pearl color sequence;
- slower/smoother dual ring motion;
- lower star rate than Cosmic;
- restrained premium light.

## Spawn vs idle

Spawn/reveal burst is short-lived and separate from the idle composition. Spawn intensity does not loop forever.

## Carried-pile protection

When an item is carried, the VFX service detects the carry presentation and scales ongoing effect intensity to approximately 46%.

This is specifically to prevent an 8–12-item pile from becoming a giant ball of light.

## Distance culling

`M6CVFXCullingController` runs client-side:

- effects enabled inside ~135 studs;
- effects disabled past ~155 studs;
- updates at 4 Hz;
- applies only to M6C professional ParticleEmitters, Beams, and PointLights.

This prevents distant warehouse/Stock VFX from paying full render cost on mobile.

## Runtime counters

Inspect `Workspace.OneTripPrototype`:

- `M6CProductionBatchEnabled`
- `M6CProductionBatchModelCount`
- `M6CProfessionalVFXEnabled`
- `M6CProfessionalVFXApplied`
- `M6CProfessionalVFXEmitters`
- `M6CProfessionalVFXBeams`
- `M6CProfessionalVFXLights`
- `M6CSineStatus`

# Studio review

## Build the 11-row gallery

Before Play:

```lua
workspace:SetAttribute("M6CBuildRarityGallery", true)
workspace:SetAttribute("M6CGalleryMode", "PROOF")
```

Restart Play.

The gallery now creates all 11 representative rows automatically:

1. Shipping Box
2. Refrigerator
3. Couch
4. Gaming PC
5. Arcade Cabinet
6. Show-Car Engine
7. Engine Block
8. Designer Fragrance Trunk
9. Painting Transport Crate
10. Jewelry Safe
11. Black-Project Containment Unit

For one row only:

```lua
workspace:SetAttribute("M6CGalleryMode", "SINGLE")
workspace:SetAttribute("M6CGalleryBaseItemId", "DesignerFragranceTrunk")
```

Disable afterward:

```lua
workspace:SetAttribute("M6CBuildRarityGallery", false)
```

# Required screenshot review

Capture in Studio:

A. Common Shipping Box.

B. Common Refrigerator.

C. Common Couch.

D. Designer Fragrance Trunk.

E. Black-Project Containment Unit.

F. Refrigerator Common → Eternal lineup.

G. Designer Fragrance Trunk Common → Eternal lineup.

H. Legendary/Mythic/Cosmic/Eternal with VFX visible.

I. A real mixed-rarity carried pile.

J. Rare/high-tier cargo sitting naturally in finished warehouse storage.

Screenshots are runtime deliverables and must not be fabricated from static code inspection.

# Mixed-pile test

Use a real 6 / 8 / 10 / 12 item stack with several rarities.

Pass if:

- cargo silhouettes remain readable;
- higher rarity still stands out;
- effects do not merge into one light blob;
- camera remains readable on mobile;
- carried Cosmic/Eternal still feel premium at reduced intensity.

# Known remaining work before checkpoint can pass

1. Roblox Studio runtime/visual inspection is still required.
2. Show-Car Engine and Black-Project Containment Unit may still earn true custom-mesh/Blender replacements after the proof is judged.
3. Royal Grand Piano, reactor/core hero items and several other heroes are outside this first 11-item checkpoint.
4. Native particle textures are temporary production-safe placeholders; Sine-authored sprites/meshes can replace them later through the standardized anchors.
5. Delivery VFX is not yet hooked to the final unload/delivery presentation. Do not add that until the base + rarity + spawn/idle system passes visual review.
6. Collection thumbnail/final showcase framing is not part of this checkpoint.
7. No claim is made that the remaining catalog has final M6C models yet.

# Stop condition

STOP here.

Do not mass-produce the remaining catalog until the required Studio screenshots, mixed-pile readability, mobile performance and representative rarity escalation are reviewed and approved.
