--!strict

-- M6C.1 Creator Store import proof. These three assets are user-approved and
-- intentionally limited to Common/base-model validation. Do not expand this
-- list until the visual proof passes review.

return table.freeze({
	StorageFolderName = "OneTripImportedAssets",
	ReviewGalleryAttribute = "M6CImportedReviewGallery",
	Assets = table.freeze({
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
			-- Blank multi-part arcade cabinet selected specifically so the import
			-- pipeline can paint separate shell, marquee, control, screen and button
			-- geometry. The previous textured single-shell proof asset could only be
			-- tinted as one color after texture sanitization.
			AssetId = 284785778,
			SectionId = "Recreation",
			TargetBounds = Vector3.new(4.8, 8.4, 4.6),
			PreserveNaturalColor = true,
			RemoveAllExternalTextures = false,
			ReviewOrder = 3,
		}),
	}),
})
