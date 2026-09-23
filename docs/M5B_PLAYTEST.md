# ONE TRIP — M5B LOOT + RARITY PLAYTEST

M5C is NOT started. Validate this phase before collection/mastery work.

## Scope implemented

- 6 section-specific loot catalogs
- 12 core base objects per section = **72 core objects**
- 1 rare-only hero object per section = **6 hero objects**
- **78 total base object types** available to M5B
- Common → Eternal rarity ladder
- separate section economic scale and rarity economic scale
- rarity-preserving carry → SELL/KEEP → Stock → persistence path
- first-pass recognizable primitive models
- rarity materials/highlights/lights/particles/silhouette accents
- lightweight Rare+ world audio cue
- warehouse-wide Legendary+ caps/cooldowns layered over M4.1 supply
- Studio-only force/inspect controls
- legacy M4 Stock compatibility

## Section catalogs

### 1 — Receiving & General Storage
Core: Shipping Box, Toolbox, Suitcase, Cooler, Office Chair, Rolling Cart, Package Bundle, Storage Bin, Office Printer, Filing Cabinet, Folding Table, Mail Tub.

Hero: **Golden Pallet Jack** (Legendary+).

Core carry range: Weight 1–3, Bulk 1–3. Mostly compact/flexible.

### 2 — Appliances & Electronics
Core: Microwave, Television, Vacuum Cleaner, Mini Fridge, Refrigerator, Washing Machine, Clothes Dryer, Dishwasher, Oven Range, Speaker System, Gaming Monitor, Commercial Mixer.

Hero: **Prototype Smart Fridge** (Mythic+).

Core carry range: Weight 2–6, Bulk 2–4. Tall boxes + screens + appliances.

### 3 — Furniture & Oversized
Core: Floor Lamp, Armchair, Office Desk, Coffee Table, Dining Table, Couch, Mattress, Wardrobe, Recliner, Sectional Sofa, Bookcase, Upright Piano.

Hero: **Royal Grand Piano** (Legendary+).

Core carry range: Weight 1–8, Bulk 2–7. Strong Wide/Tall bias.

### 4 — Heavy Goods & Equipment
Core: Commercial Safe, Generator, Tire Stack, Rolling Tool Chest, Air Compressor, Vending Machine, Industrial Fan, Heavy Battery Unit, Commercial Freezer, Large Equipment Case, Pressure Washer, Equipment Cart.

Hero: **Titan Vault Safe** (Mythic+).

Core carry range: Weight 5–9, Bulk 2–5. Weight pressure becomes important.

### 5 — Industrial Storage
Core: Engine Block, Cable Reel, Industrial Pump, Transformer, Motor Assembly, Machine Gearbox, Steel Drum, Hydraulic Unit, Industrial Control Cabinet, Fabrication Welding Rig, Compressor Skid, Production Machine.

Hero: **Experimental Reactor Core** (Cosmic+).

Core carry range: Weight 7–16, Bulk 3–7. Extreme weight + awkward combinations.

### 6 — Secure High-Value Storage
Core: Luxury Display Case, Fine Art Crate, High-Security Case, Prototype Server Rack, Premium Medical Machine, Collector Cargo Chest, Concert Instrument Case, Precision Optics Case, Jewelry Safe, Auction House Crate, Research Prototype, Executive Vault Unit.

Hero: **Black-Project Containment Unit** (Cosmic+).

Core carry range: Weight 5–14, Bulk 3–5. High baseline value with mixed carry problems.

## Test rarity weights

These are M5 playtest weights, not locked live probabilities.

| Rarity | Weight | Economic scale |
| --- | ---: | ---: |
| Common | 65.00% | 1.00x |
| Uncommon | 20.00% | 1.25x |
| Rare | 9.00% | 1.60x |
| Epic | 4.00% | 2.20x |
| Legendary | 1.40% | 3.10x |
| Mythic | 0.45% | 4.50x |
| Cosmic | 0.13% | 6.80x |
| Eternal | 0.02% | 10.00x |

Legendary+ also has warehouse-wide simultaneous caps and claim cooldowns so a spectacular find cannot simply respawn elsewhere immediately.

## Section economic scales

| Section | Scale |
| --- | ---: |
| Receiving | 1.00x |
| Appliances | 2.20x |
| Furniture | 4.80x |
| Heavy Goods | 10.00x |
| Industrial | 21.00x |
| Secure | 45.00x |

Section scale and rarity scale remain separate dimensions.

## Common core SELL range by section

Approximate current ranges:

| Section | Common SELL range |
| --- | ---: |
| Receiving | $900–$2.3K |
| Appliances | $2.42K–$7.04K |
| Furniture | $4.08K–$18.72K |
| Heavy Goods | $12.5K–$26K |
| Industrial | $24.15K–$71.4K |
| Secure | $72K–$189K |

Hero items can exceed these ranges.

## Adjacent-section crossover sanity

The important rule is overlap, not exact equality.

Examples using core items:

- Receiving Eternal: **$9K–$23K** vs Appliances Rare: **$3.87K–$11.26K**
- Appliances Eternal: **$24.2K–$70.4K** vs Furniture Rare: **$6.53K–$29.95K**
- Furniture Eternal: **$40.8K–$187.2K** vs Heavy Rare: **$20K–$41.6K**
- Heavy Eternal: **$125K–$260K** vs Industrial Rare: **$38.64K–$114.24K**
- Industrial Eternal: **$241.5K–$714K** vs Secure Rare: **$115.2K–$302.4K**

This means high-rarity older-section finds remain economically relevant instead of being invalidated the instant the next section exists.

## Break-even architecture

SELL and KEEP scale together.

Current target function:

`3.0 + 1.2 × (sectionIndex - 1) + 0.6 × (rarityRank - 1)` minutes.

That produces roughly:

- Receiving Common: ~3 min
- Receiving Eternal: ~7.2 min
- Secure Common: ~9 min
- Secure Eternal: ~13.2 min

These are test values. Do not tune from theory alone.

## Studio debug controls

All controls are attributes on:

`Workspace > OneTripPrototype`

They are honored only while `RunService:IsStudio()` is true. No client RemoteEvent can invoke them in production.

### Force a rarity
Set:

`DevForceRarity = "Eternal"`

Valid values: Common, Uncommon, Rare, Epic, Legendary, Mythic, Cosmic, Eternal.

### Force a section
Set e.g.:

`DevForceSection = "Secure"`

Valid current section IDs:

Receiving, Appliances, Furniture, HeavyGoods, Industrial, Secure.

### Force a base object
Set e.g.:

`DevForceBaseItemId = "BlackProjectContainmentUnit"`

Hero objects still require a rarity at or above their configured minimum.

### Transform/spawn a test opportunity now
After setting the force attributes, toggle:

`DevSpawnNow = true`

The server selects an existing available opportunity in the requested section and transforms it to the forced test object/rarity without changing active supply count.

Example Eternal hero test:

- `DevForceSection = "Secure"`
- `DevForceRarity = "Eternal"`
- `DevForceBaseItemId = "BlackProjectContainmentUnit"`
- `DevSpawnNow = true`

Clear force strings afterward so natural supply resumes.

### Inspect an exact variant
Set e.g.:

`DevInspectItemId = "BlackProjectContainmentUnit__Eternal"`

Then read:

- `DevInspectStatus`
- `DevInspectSellValue`
- `DevInspectPassivePerMinute`
- `DevInspectRarity`
- `DevInspectSection`
- `DevInspectRarityMultiplier`
- `DevInspectSectionMultiplier`

Common variants use the base ID without a suffix. Example: `ShippingBox`.

## Rarity telemetry

Read attributes such as:

- `LootRarity_Common_Active`
- `LootRarity_Rare_Active`
- `LootRarity_Legendary_Active`
- `LootRarity_Legendary_NextInSeconds`
- `LootRarity_Eternal_Active`
- `LootRarity_Eternal_NextInSeconds`

Legendary+ natural supply is globally capped and gated after claim.

## Test A — section identity / variety

Walk each section naturally.

PASS if:

- Receiving looks populated by general/storage objects
- Appliances clearly reads as electronics/appliances
- Furniture is dominated by bulky furniture shapes
- Heavy Goods visibly trends heavier/equipment-like
- Industrial contains machinery/components
- Secure contains premium/controlled cargo

FAIL if the experience still looks like Box/Lamp/Microwave copied six times.

## Test B — carry-character differences

Pick representative loads in every section.

Verify Weight/Bulk/Shape differences actually feed the unchanged carry system:

- Receiving should be relatively flexible
- Furniture should create Bulk/Wide problems
- Heavy should create Weight pressure
- Industrial should become genuinely difficult for beginner stats
- Secure should mix high value with awkward/heavy choices

Do NOT retune carrying merely because M5B finally supplies harder objects.

## Test C — every rarity

Use debug controls. For the same base object, test:

Common → Uncommon → Rare → Epic → Legendary → Mythic → Cosmic → Eternal.

Verify:

- world presentation
- label readability
- pickup
- carried visual
- collapse/drop visual
- Delivery Review
- SELL value
- KEEP rate
- Stock display
- save/rejoin persistence

## Test D — distance readability

Place Common, Rare, Legendary, Mythic, Cosmic and Eternal objects down a long freight sightline.

Expected:

- Common = normal
- Uncommon = small color/material distinction
- Rare = visible highlight/material distinction
- Epic = stronger highlight/material
- Legendary = bright material + light, recognizable at moderate distance
- Mythic = stronger treatment + controlled particles
- Cosmic = strong glow/particles + silhouette fins
- Eternal = strongest highlight/glow/particles + crown-like silhouette accent

FAIL if Cosmic/Eternal read as merely another text color.

## Test E — hero social spectacle

Force at least:

- Royal Grand Piano Legendary/Eternal
- Experimental Reactor Core Cosmic/Eternal
- Black-Project Containment Unit Cosmic/Eternal

Look from far down an aisle.

The goal is an immediate "WHAT IS THAT?" reaction while staying performant.

## Test F — economic crossover

Use `DevInspectItemId` to compare at least five adjacent-section pairs.

Confirm earlier-section high rarity can beat meaningful low/mid rarity in the next section.

FAIL if every item in Section N becomes worthless the instant Section N+1 is considered.

## Test G — SELL / KEEP

Force several Rare+ opportunities from different sections.

For each:

- verify immediate SELL rises substantially
- verify passive KEEP rises substantially
- verify neither path is universally correct
- verify the exact variant survives into Stock and persistence

## Test H — rarity supply / anti-camping

Naturally claim or force a Legendary+ item, then clear debug forcing.

Watch `LootRarity_<Tier>_NextInSeconds`.

PASS if the claimed tier cannot immediately reappear everywhere while its gate is active.

M4.1 vacancy/replenishment pacing should still be visible underneath this layer.

## Test I — performance

Solo first:

- inspect part count/FPS while walking through all six sections
- inspect Cosmic/Eternal effects
- carry a large mixed pile containing several detailed models
- keep three detailed Stock objects in the bay

The presentation intentionally uses a few welded primitive detail parts per object, one Highlight at Rare+, one light at Legendary+, and one low-rate emitter at Mythic+. No object should create particle spam.

Then repeat with multiple clients if practical.

## Offline-income note

M5B keeps the existing persistent profile namespace but temporarily caps offline accrual to **5 minutes of live Stock output**. M5's value scale is now too large for the old 30-minute test cap. Revisit this when later M5 progression sinks are established.

## Phase pass condition

M5B passes when:

1. Section loot identity is obviously stronger than the 8-item prototype.
2. At least 12 core base types exist per section.
3. Common→Eternal works throughout all six sections.
4. Section and rarity economic dimensions remain independent.
5. Adjacent-section economic crossover exists.
6. Legendary+ opportunities do not trivially respawn/camp.
7. High tiers are visibly special at distance.
8. Carry, collapse, SELL, KEEP, Stock and persistence preserve exact variant identity.
9. First-pass model geometry is readable enough to judge carrying/silhouette behavior.
10. Performance remains acceptable enough to proceed to M5C.

STOP after validation. Do not begin M5C until reviewed.
