# ONE TRIP — M6C CARGO ART REPORT

## Status
M6C is implemented as a broad procedural base-model + modular-rarity production pass, but it is **NOT final-complete yet**. Roblox Studio/mobile/mixed-pile review and selected custom-mesh/Blender hero replacements remain required before final M6 polish.

The approved M6B warehouse/environment remains unchanged by this report.

# A. Central item-art manifest

Source of truth:

`src/shared/Config/ItemArtManifest.lua`

It is generated directly from `LootCatalog.ById`, so every current launch BaseItemId receives an entry automatically.

Every entry records:
- ItemId
- DisplayName
- Section
- ModelStatus
- ModelSource
- Studio / Mesh / Blender production recommendation
- primary color
- simple material policy
- silhouette classification
- rarity geometry strategy
- completed flag
- placeholder flag
- hero status / minimum hero rarity
- required-rarity-test status

The manifest deliberately keeps `Completed=false` and `PlaceholderRemaining=true` during this pass. M6C should not claim completion merely because procedural geometry exists.

Runtime attributes on `Workspace > OneTripPrototype` expose:
- `M6CManifestItems`
- `M6CManifestStudio`
- `M6CManifestMesh`
- `M6CManifestBlender`
- `M6CRepresentedBaseItems`
- `M6CAppliedInstances`

# B. Base-model architecture

Service:

`src/server/Services/M6CCargoArtService.lua`

The M6C layer runs after the old presentation layer and replaces generic old `LootDetails` / rarity effects with a unified cargo-art folder named `M6CArt`.

Visual pieces are:
- welded to the authoritative cargo root;
- Massless;
- non-colliding;
- non-touching;
- non-querying;
- shadow-limited for small detail pieces.

This means visual complexity does not become gameplay collision complexity.

## Generic silhouette families
The base pass supports reusable final-style recipes for:
- Crate / Bundle
- Case / Chest
- Chair
- Cart
- Screen
- Appliance / Tall Appliance
- Washer
- Speaker
- Lamp
- Table
- Sofa
- Mattress
- Cabinet
- Piano
- Safe
- Cylinder / Fan
- Engine
- Machine
- Core
- Display
- fallback/legacy cargo

These recipes prioritize chunky silhouette and mobile readability over realistic texture detail.

## Item-aware identity additions
The first item-aware pass additionally recognizes and redesigns important families including:
- refrigerators/fridges
- arcade cabinets
- gaming PCs
- bicycles/exercise bikes
- treadmills
- engines
- mixers/concrete machines
- fans
- Royal Grand Piano
- Golden Pallet Jack
- Creator Command Center
- fragrance/parfum/perfumer/oud/atomizer cargo
- painting/fine-art cargo
- gemstone/jewelry cargo
- Restricted / Prototype cargo

These additions sit on top of ModelKind rather than replacing the shared optimized base recipe.

# C. Current rarity architecture

The root object keeps its recognizable base design and base-color identity. Rarity increasingly adds model design rather than simply recoloring the whole object.

## Common
- no rarity geometry;
- normal polished item;
- no aura / particles.

## Uncommon
- tiny restrained quality badge;
- no magic treatment.

## Rare
- visible colored trim;
- small status accent;
- still fundamentally the normal object.

## Epic
- top-cap / side modules;
- first strong silhouette changes;
- more special but still readable.

## Legendary
Item-aware premium redesign:
- furniture: premium edge/piping/emblem language;
- engines/machines/cores: engineered rails + premium core detail;
- cases/other cargo: reinforced premium corner system;
- gold/amber used as detail, not a full-object gold paint job.

## Mythic
- stronger construction modules;
- suspended-looking side nodes;
- special braces;
- magenta/crimson rarity color can become a design component.

## Cosmic
- containment-ring geometry;
- structural fins;
- controlled cyan/deep-blue/violet energy language;
- very low-rate star-like particles (currently ~1.6/sec per Cosmic item).

## Eternal
- white-gold / pale-gold crown geometry;
- prestige spines;
- restrained local prestige light;
- additional item-aware focus for luxury fragrance or machinery/core families;
- no rainbow particle spam.

# D. Rarity comparison gallery

Service:

`src/server/Services/M6CRarityGalleryService.lua`

The gallery is Studio-only and OFF by default.

Before Play, set:

```lua
workspace:SetAttribute("M6CBuildRarityGallery", true)
workspace:SetAttribute("M6CGalleryBaseItemId", "ShippingBox")
```

Then start Play.

The service creates one Common -> Eternal row using the live ItemId variants and the live M6C rendering service.

Change `M6CGalleryBaseItemId` and restart Play for other objects.

Useful test examples:

```text
ShippingBox
Refrigerator
Couch
GamingPC
ArcadeCabinet
ShowCarEngine
EngineBlock
DesignerFragranceTrunk / another current fragrance BaseItemId
PaintingTransportFrame / another current Art BaseItemId
JewelrySafe / another current Secure BaseItemId
BlackProjectContainmentUnit / another current Restricted BaseItemId
```

If an example name is not present in the current catalog, use the actual matching BaseItemId shown by the catalog/Collection debug tools.

To disable:

```lua
workspace:SetAttribute("M6CBuildRarityGallery", false)
```

# E. Hero production recommendations

The manifest currently reserves higher production effort for selected hero assets.

## Studio hero candidates
- Golden Pallet Jack
- Model Home Starter Set
- Prototype Smart Fridge

Reason: strong silhouette can be achieved cleanly with optimized Roblox-native geometry without requiring external mesh complexity.

## Custom-mesh candidates
- Creator Command Center
- Deluxe Arcade Pod
- Titan Vault Safe

Reason: they benefit from a unique silhouette and cleaner consolidated geometry, but do not inherently require a full Blender-heavy workflow.

## Blender candidates
- Royal Grand Piano
- Show-Car Engine
- Experimental/Cosmic Reactor Core family
- Black-Project Containment Unit

Reason: these are rare/showcase assets with distinctive curved/mechanical silhouettes where a carefully optimized custom mesh can materially improve thumbnails, hero moments and recognizability.

This is a production recommendation, not a statement that those external meshes already exist.

# F. Performance discipline

Current implementation deliberately avoids:
- per-item texture maps;
- PBR-heavy materials;
- visual mesh collision;
- particles on Common/Uncommon;
- full-body Neon rarity treatment;
- many PointLights on ordinary items.

Current expensive rarity pieces are concentrated in Cosmic/Eternal.

The next runtime performance review must inspect:
- active world cargo count;
- M6C visual-part count;
- Cosmic particle count;
- Eternal PointLight count;
- 8-12 item carried piles;
- multiple players carrying high-rarity piles;
- Stock displays;
- StreamingEnabled behavior.

# G. Required runtime visual tests

## 1. Early Common/base cargo
Check Receiving/Home Basics/Appliances from player height.

Common must look polished without rarity effects.

## 2. Mid-game base cargo
Check Furniture, Electronics, Recreation, Garage/Auto and Industrial objects.

The object type must be identifiable before reading its label.

## 3. Luxury
Check fictional fragrance/luxury cargo on its actual storage architecture.

Bottles/cases must read at mobile distance and must not depend on tiny detail.

## 4. Secure / Restricted
Common cargo must already feel protected/valuable or strange/experimental before rarity treatment.

## 5. Required rarity lineups
Use the Studio gallery on representative items across radically different categories.

Judge whether each step is actually visible:
Common -> Uncommon -> Rare -> Epic -> Legendary -> Mythic -> Cosmic -> Eternal.

## 6. Mixed pile
Carry at minimum:
- Common
- Rare
- Epic
- Legendary
- Mythic

Preferably add Cosmic for a second stress test.

Fail if:
- object silhouettes become unreadable;
- rarity geometry overlaps disastrously;
- light/effect spam hides the pile;
- performance drops noticeably.

## 7. Mobile
At a phone-sized landscape viewport, verify:
- object type readable without zoom;
- Rare+ distinction readable;
- Legendary/Mythic/Cosmic look desirable;
- item labels do not become the only way to identify cargo.

# H. Remaining placeholders / incomplete work

M6C is NOT complete until these are reviewed/replaced as necessary:
- many BaseItemIds still share procedural ModelKind recipes rather than bespoke item recipes;
- selected hero assets still need custom-mesh/Blender replacement decisions executed;
- luxury fragrance family needs final catalog-specific item-by-item review;
- Art/Secure/Restricted families need player-height review for sufficient base-item differentiation;
- final rarity audio assets are not authored yet;
- final reveal/delivery audio stings are not authored yet;
- animated hero components are only structurally prepared, not fully animated;
- Collection thumbnail/render strategy is not finalized;
- Stock display needs explicit final-model review;
- no Roblox Studio screenshots are generated by this repository pass;
- mobile/performance results remain runtime pending.

# I. Current recommendation

**NEEDS RUNTIME / ART REVIEW.**

The M6C architecture and broad base/rarity coverage are in place, but do not proceed into final M6 polish yet.

First review:
1. Common cargo readability across early/mid/late sections.
2. Common -> Eternal gallery for the required representative categories.
3. Mixed-rarity carry pile.
4. Phone-sized mobile view.
5. Hero candidate quality vs need for custom mesh/Blender.

Only after these pass should the manifest entries be changed from `PlaceholderRemaining=true` / `Completed=false` to final-complete states.
