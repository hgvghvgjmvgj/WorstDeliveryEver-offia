--!strict

-- Fallback copy for the standalone plugin project. When the main ONE TRIP
-- place is synced, CreatorStoreImporter prefers ReplicatedStorage.Config
-- ImportedAssetManifest so runtime + importer stay on the same source of truth.

return table.freeze({
	Couch = table.freeze({
		CargoId = "Couch",
		AssetId = 10710790394,
		SectionId = "Furniture",
		TargetBounds = Vector3.new(10.5, 4.4, 4.1),
		PreserveNaturalColor = true,
		RemoveAllExternalTextures = false,
		ReviewOrder = 1,
	}),
	Refrigerator = table.freeze({
		CargoId = "Refrigerator",
		AssetId = 482124502,
		SectionId = "Appliances",
		TargetBounds = Vector3.new(4.6, 8.0, 4.4),
		PreserveNaturalColor = true,
		RemoveAllExternalTextures = false,
		ReviewOrder = 2,
	}),
	ArcadeCabinet = table.freeze({
		CargoId = "ArcadeCabinet",
		-- Blank multi-part arcade cabinet. The previous proof asset was largely a
		-- single textured shell, so stripping its branded texture left one mesh
		-- that Roblox could only tint one color. This asset gives the paint pass
		-- actual separate geometry to style.
		AssetId = 284785778,
		SectionId = "Recreation",
		TargetBounds = Vector3.new(4.8, 8.4, 4.6),
		PreserveNaturalColor = true,
		RemoveAllExternalTextures = false,
		ReviewOrder = 3,
	}),
})
