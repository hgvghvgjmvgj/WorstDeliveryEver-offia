# ONE TRIP — M6C.1 CREATOR STORE IMPORT PROOF

## Scope
This is a three-model pipeline proof only.

Approved assets:
- Couch — Creator Store asset `10710790394`
- Refrigerator — Creator Store asset `482124502`
- ArcadeCabinet — Creator Store asset `105044479380665`

Do not expand to the rest of the catalog and do not create rarity art until these three pass visual review.

## Studio import workflow
1. Pull latest repo and sync the main ONE TRIP place.
2. Build/install/sync `tools/OneTripModelBuilder` as usual.
3. Open **ONE TRIP > Model Builder**.
4. Press **IMPORT APPROVED ASSETS**.
5. If Roblox rejects public third-party assets, enable **Allow Loading Third Party Assets** in Studio/Game Settings and retry.
6. Confirm the plugin reports success/failure, source ID, removed descendants, removed scripts, final part count, bounds, scale, and warnings.
7. Confirm sanitized templates exist at:
   - `ServerStorage/OneTripImportedAssets/Couch`
   - `ServerStorage/OneTripImportedAssets/Refrigerator`
   - `ServerStorage/OneTripImportedAssets/ArcadeCabinet`
8. Save the place so these unmanaged ServerStorage templates persist.
9. Press **OPEN REVIEW GALLERY**.

Review gallery location:
`Workspace/OneTripImportedAssetReview`

The row is Couch → Refrigerator → Arcade Cabinet with neutral background, review lights, intended game scale, and labels containing Cargo ID + source asset ID.

## Sanitization checks
For each production template confirm:
- no `Script`
- no `LocalScript`
- no `ModuleScript`
- no remotes/bindables
- no unrelated sounds/animation systems/prompts
- visual BaseParts have gameplay collisions disabled
- `CarryHitbox` exists
- VFX anchors exist: `VFX_Core`, `VFX_Top`, `VFX_Left`, `VFX_Right`, `VFX_Front`
- `CargoId`, `BaseItemId`, `SectionId`, `SourceAssetId`, `Sanitized=true` metadata exists

## Arcade copyright cleanup
The importer deletes Decal / Texture / SurfaceAppearance content from the approved Arcade asset and clears MeshPart TextureID where possible. It then neutralizes the cabinet to a ONE TRIP-original light-gray shell with a dark native screen, clean control deck, and simple original button colors.

Fail the asset if recognizable Freddy/Fazbear/FNAF branding is still visibly baked into geometry or cannot be removed cleanly.

## Runtime integration
Runtime looks for sanitized templates in `ServerStorage/OneTripImportedAssets`.

For these three BaseItemIds only:
- template exists → hide authoritative gameplay root and weld cloned sanitized visuals to it;
- template missing → clear warning + safe existing procedural fallback.

The authoritative root remains responsible for Weight/Bulk/carry/stacking/economy. Imported geometry is visual-only and non-colliding.

During this proof, rejected M6C procedural rarity-art/VFX services are not started.

## Required playtest
After importing + saving:
1. Play a normal Option D session.
2. Force/spawn or locate Couch, Refrigerator, ArcadeCabinet.
3. Confirm each uses imported visual geometry.
4. Pick up each item.
5. Carry multiple items.
6. Drop/ditch if applicable.
7. Deliver each.
8. Test SELL and KEEP paths where practical.
9. Confirm visuals do not fall apart or remain behind.
10. Rejoin and confirm saved imported templates still exist in the place.
11. Inspect Arcade closely for copyrighted presentation.
12. Judge scale/proportions at player height and on a carried pile.

## Stop gate
Do not mass-import additional Creator Store assets and do not rebuild rarity VFX until Couch + Refrigerator + Arcade Cabinet are visually approved.

## Current implementation status
Code path: implemented.
Actual `AssetService:LoadAssetAsync` imports: require Studio execution.
Actual rendered-model review/playtest: pending Studio execution.
