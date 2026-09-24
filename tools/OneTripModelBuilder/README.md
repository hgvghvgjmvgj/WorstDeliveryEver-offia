# ONE TRIP — AI Model Builder (MVP)

A purpose-built Roblox Studio plugin for the ONE TRIP asset workflow.

## What it does

1. ChatGPT/dev bot generates a JSON model recipe.
2. Paste the recipe into the plugin.
3. Click **VALIDATE**.
4. Click **BUILD MODEL**.
5. The plugin creates a Model in Workspace and automatically adds:
   - `CargoId`, `SectionId`, `Rarity`, and `OneTripGenerated` attributes
   - `_OT_Root` as the `PrimaryPart`
   - an invisible `CarryHitbox`
   - VFX anchor attachments (`VFX_Core`, `VFX_Top`, `VFX_Left`, `VFX_Right`, `VFX_Front`)
   - undo/redo history support

The plugin is intentionally isolated from the runtime game project under `tools/OneTripModelBuilder`.

## Recipe schema

```json
{
  "Name": "LuxuryFragranceTrunk",
  "CargoId": "LuxuryFragranceTrunk",
  "SectionId": "LuxuryGoods",
  "Rarity": "Common",
  "Origin": [0,5,0],
  "BuildAtSelection": true,
  "Parts": [
    {
      "Name": "Body",
      "Type": "Block",
      "Size": [8,4,5],
      "Position": [0,0,0],
      "Rotation": [0,0,0],
      "Color": [65,34,82],
      "Material": "SmoothPlastic",
      "Transparency": 0,
      "CanCollide": true
    }
  ]
}
```

Supported `Type` values:

- `Block`
- `Cylinder`
- `Ball`
- `Wedge`
- `CornerWedge`

`Position` and `Rotation` are local to the generated model. Rotation values are degrees.

## Recommended AI instruction

Use this when asking ChatGPT/dev bot to create an asset recipe:

> Output ONLY valid JSON for the ONE TRIP Model Builder schema. Use stylized Roblox-friendly geometry, simple materials, strong silhouette, chunky proportions, bright/readable colors, and no realistic texture dependence. Keep the model optimized and use no more parts than necessary.

## Build with Rojo

From the repository root:

```bash
cd tools/OneTripModelBuilder
rojo build -o OneTripModelBuilder.rbxm
```

Or run:

```bash
cd tools/OneTripModelBuilder
rojo serve
```

and sync it into a temporary Studio place.

The project root contains `src/init.server.lua`, so Rojo maps the plugin entry Script with `Builder.lua` and `Examples.lua` as child ModuleScripts.

## Install in Roblox Studio

1. Build `OneTripModelBuilder.rbxm` with Rojo.
2. Insert the generated model/script into a temporary Studio place.
3. Use **Save as Local Plugin** so Roblox runs it with the `plugin` global.
4. Open the **ONE TRIP** toolbar and select **Model Builder**.

## Sine VFX workflow

The model builder does **not** attempt to fake or replace Sine VFX.

Instead, every generated asset receives standardized VFX anchors:

- `VFX_Core`
- `VFX_Top`
- `VFX_Left`
- `VFX_Right`
- `VFX_Front`

Use Sine VFX to author the polished effect layers on those anchors. This keeps the model generator deterministic while letting Sine handle professional particle/beam/mesh effect authoring.

Recommended pipeline:

1. Generate the final base model with ONE TRIP Model Builder.
2. Apply rarity geometry/material changes.
3. Use Sine VFX on the standardized anchors for Legendary/Mythic/Cosmic/Eternal effects.
4. Save the approved effect as a reusable rarity preset/template.
5. Keep Common/Uncommon nearly effect-free.

Do not assume a programmable Sine API unless its installed version explicitly exposes one. The current plugin deliberately provides integration points without depending on undocumented Sine internals.

## Current version

MVP `0.1.0`.

Next likely additions:

- edit/regenerate selected generated model
- reusable component library (`Handle`, `Wheel`, `Screen`, `Trim`, etc.)
- rarity geometry kits
- recipe export/import helpers
- optional Sine VFX preset workflow once its supported automation surface is confirmed
