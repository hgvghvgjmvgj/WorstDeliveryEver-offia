# ONE TRIP — AI Model Builder

Purpose-built Roblox Studio plugin for ONE TRIP cargo production.

## What it does

1. ChatGPT/dev bot generates a structured JSON model recipe.
2. Paste the recipe into the plugin or load one of the built-in M6C examples.
3. Click **VALIDATE**.
4. Click **BUILD MODEL**.
5. The plugin creates a Model in Workspace and automatically adds:
   - `CargoId`, `SectionId`, `Rarity`, and `OneTripGenerated` attributes
   - `_OT_Root` as the `PrimaryPart`
   - an invisible `CarryHitbox`
   - standardized VFX anchors (`VFX_Core`, `VFX_Top`, `VFX_Left`, `VFX_Right`, `VFX_Front`)
   - undo/redo history support

The plugin is intentionally isolated from the runtime project under `tools/OneTripModelBuilder`.

## M6C production checkpoint

The built-in example buttons now expose four representative production recipes:

- Refrigerator
- Couch
- Gaming PC
- Designer Fragrance Trunk

These recipes mirror the same strong-silhouette/simple-material construction language used by `src/shared/Config/M6CProductionBatchConfig.lua`. The runtime checkpoint currently contains 11 representative cargo recipes; the plugin remains the Studio inspection/editing path for those recipe patterns.

The current M6C production rule is:

**base model identity first → rarity geometry second → VFX third**.

Do not use VFX to rescue an unreadable base model.

## Recipe schema

```json
{
  "Name": "DesignerFragranceTrunk",
  "CargoId": "DesignerFragranceTrunk",
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

> Output ONLY valid JSON for the ONE TRIP Model Builder schema. Use stylized Roblox-friendly geometry, simple materials, strong silhouette, chunky proportions, bright/readable colors, and no realistic texture dependence. Keep the model optimized and use no more parts than necessary.

## Build with Rojo

```bash
cd tools/OneTripModelBuilder
rojo build -o OneTripModelBuilder.rbxm
```

or:

```bash
cd tools/OneTripModelBuilder
rojo serve
```

The project root contains `src/init.server.lua`, so Rojo maps the plugin entry Script with `Builder.lua` and `Examples.lua` as child ModuleScripts.

## Install in Roblox Studio

1. Build `OneTripModelBuilder.rbxm` with Rojo.
2. Insert it into a temporary Studio place.
3. Use **Save as Local Plugin** so Roblox runs it with the `plugin` global.
4. Open the **ONE TRIP** toolbar and select **Model Builder**.

## Sine VFX workflow

The Model Builder does **not** invent a Sine API.

Every generated asset receives:

- `VFX_Core`
- `VFX_Top`
- `VFX_Left`
- `VFX_Right`
- `VFX_Front`

Repository inspection for the M6C checkpoint found no callable/documented Sine ModuleScript/API or reusable Sine asset library inside the project. Therefore current runtime status is:

**NOT PROGRAMMATICALLY ACCESSIBLE**

The native M6C VFX service uses these same anchors, so a Sine-authored texture/mesh/effect can later replace a native layer without changing cargo IDs, physics, rarity data, or attachment conventions.

Do not claim direct Sine integration unless the installed version exposes an actual supported automation surface.

## Current version

MVP `0.2.0` — M6C representative production checkpoint.

Likely next additions after visual approval:

- edit/regenerate selected generated model
- reusable component library (`Handle`, `Wheel`, `Screen`, `Trim`, `Bottle`, etc.)
- reusable rarity geometry kits
- recipe export/import helpers
- Sine asset-assisted presets if the installed plugin exposes reusable assets or a documented API
