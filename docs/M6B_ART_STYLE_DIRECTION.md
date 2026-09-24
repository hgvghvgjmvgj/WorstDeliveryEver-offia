# ONE TRIP — M6B ART STYLE DIRECTION

## Status
This document is the M6B visual source of truth. It explicitly overrides any photorealistic, texture-heavy, grunge-heavy, or realism-first warehouse direction.

# Core target

**STYLIZED, COLORFUL, CHUNKY, CLEAN, READABLE ROBLOX ART**

Visual quality should come primarily from:

- strong models
- silhouettes
- proportions
- color
- lighting
- shape language
- animation
- rarity-specific design
- clean material choices

Do not rely on:

- realistic grunge textures
- photoreal concrete
- scratches everywhere
- dense PBR detail
- tiny realistic surface imperfections
- excessive texture maps

# Visual hierarchy

**MODEL SHAPE > COLOR > LIGHTING > SIMPLE MATERIAL > TEXTURE**

For every environment/item, ask:

> Would this still look appealing in Roblox with simple materials and no realistic texture detail?

If no, redesign shape/color/lighting instead of adding texture detail.

# Roblox material philosophy

Prefer:

- SmoothPlastic
- Metal
- Glass
- carefully used Neon
- clean custom colors
- simple low-detail materials

Texture use should be restrained. If a texture does not materially improve readability or identity, do not use it.

# Environment style

The warehouse is a **stylized Roblox mega-warehouse**, not a realistic Amazon fulfillment center.

Use exaggerated readable architecture:

- thicker racks
- chunky ceiling supports
- oversized section signs
- strong doors/security frames
- readable pallets
- large machinery silhouettes
- oversized lighting fixtures

Everything must read on mobile.

The base warehouse architecture can remain cohesive and darker/neutral enough for loot to pop, but sections 1–10 must not become endless gray/brown rooms.

## Section palette direction

- Receiving: warm cardboard + yellow + blue accents
- Home Basics: warm colorful household goods
- Appliances: clean cool appliance colorways
- Furniture: warm wood/color upholstery accents
- Electronics: blue/cyan product lighting
- Recreation: green/purple/orange
- Garage & Auto: red + yellow + black
- Construction: orange/yellow
- Heavy Equipment: industrial yellow / muted safety accents
- Industrial: cool teal/blue machinery accents
- Premium Interiors: cream + warm gold + rich colors
- Luxury Goods: black + gold + burgundy/emerald
- Art & Collectibles: purple + rich jewel tones
- Secure: cold steel + gold/blue security accents
- Restricted / Prototype: red/magenta + cyan energy details

Color can come from cargo, shelves, trims, signs, lights and section accents rather than painting the entire room one saturated color.

# Item art philosophy

Items should feel like **polished Roblox collectibles based on real-world objects**.

They should be:

- instantly readable
- colorful
- slightly exaggerated
- chunky
- satisfying to stack
- visually distinct

Do not recreate real objects slavishly if exaggerated proportions improve readability or fun.

Example stylized fridge:

- chunky handles
- clean bright panels
- obvious door separation
- simple screen
- exaggerated proportions

instead of realistic refrigerator texture/detail.

# Rarity visual ladder

## COMMON — normal polished object

Common has:

- no aura
- no rarity geometry
- no particles
- no glowing trim

Common does **not** mean ugly. It should still be clean, colorful where appropriate and desirable.

Examples:

- Common Couch: appealing stylized upholstery/color
- Common Gaming PC: clean dark case with subtle colored fans
- Common Fragrance Trunk: premium-looking but ordinary case

## UNCOMMON — slightly nicer normal object

Uncommon remains close to Common.

Possible differences:

- slightly nicer colorway
- small green accent
- improved trim
- subtle material improvement
- small badge/detail

It may barely look different from far away. That is intentional.

## RARE — clearly upgraded

Use:

- stronger blue accent
- upgraded colorway
- slightly cooler geometry/detail
- illuminated small component where appropriate
- modest trim redesign

Still avoid giant auras.

## EPIC — special version

Epic is where design changes become more obvious.

Possible:

- new accent pieces
- upgraded silhouette
- purple lighting details
- stronger trim
- futuristic/premium details
- one or two unique geometry additions

## LEGENDARY — major premium redesign

Legendary should immediately produce a **"THAT LOOKS SICK"** reaction.

Do not just recolor gold.

Use:

- more elaborate silhouette
- gold/amber trim
- unique decorative panels
- additional structural features
- distinctive lights
- tasteful glow
- premium animated detail

## MYTHIC — fantasy-level redesign

Mythic should feel intentionally rebuilt, not particle-coated.

Use where appropriate:

- stronger silhouette changes
- unusual materials/colors
- magenta/crimson energy accents
- floating/suspended small elements
- animated lighting
- noticeably different construction

## COSMIC — otherworldly version

Primary language:

- cyan
- deep blue
- purple
- controlled space/energy motifs

Possible:

- floating elements
- energy containment
- animated rings
- shifting emissive pieces
- unique geometry
- subtle star-like particles

Never put cyan Neon over a Common mesh and call it Cosmic.

## ETERNAL — ultimate prestige version

Eternal is the best version of the object.

Direction:

- white-gold
- pale gold
- iridescent/prismatic accents
- elegant high-tier silhouette
- unique animated pieces
- premium controlled glow
- unmistakable geometry

Avoid chaotic rainbow particle spam.

# Rarity escalation rule

The visual gap should read approximately as:

- Common: normal item
- Uncommon: slightly nicer normal item
- Rare: noticeably upgraded
- Epic: special version
- Legendary: major premium redesign
- Mythic: fantasy-level redesign
- Cosmic: otherworldly version
- Eternal: ultimate prestige version

Starting around Epic/Legendary, rarity must increasingly alter **MODEL DESIGN**, not only color.

# Modular production strategy

Do **not** create eight independent heavy Blender models for every object.

Preferred pipeline:

**base model + rarity geometry kits + materials + lights + attachments + selected hero upgrades**

This keeps mobile performance and production scope sane.

Examples of reusable rarity kits:

- upgraded corner/edge trims
- alternate handles/clasps
- display/screen modules
- lamps/light strips
- small animated rings
- floating accent modules
- emblem/badge kits
- crown/halo structural pieces for select Eternal objects

Hero objects can receive bespoke additions where their silhouette/social value justifies it.

# Production implication

M6B should prioritize:

1. silhouette and proportion language
2. section palette / architecture language
3. Common base-model quality
4. modular Rare/Epic kits
5. stronger Legendary/Mythic redesign kits
6. Cosmic/Eternal hero-level treatments
7. restrained VFX/audio polish

Textures/PBR are optional finishing tools only, never the foundation.
